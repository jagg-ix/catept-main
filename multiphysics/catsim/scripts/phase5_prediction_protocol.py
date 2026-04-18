#!/usr/bin/env python3
"""Phase 5 — Paper-faithful prediction protocol (tool-generated outputs only).

This script implements the protocol described in the plan:

5.1 Define training/test split explicitly
5.2 Run two models with identical baseline settings
    - standard+phase
    - standard+phase+CAT (coherence-mode)
5.3 Write PAPER_TABLES/PREDICTIONS/ deliverables and a PASS/FAIL gate.

Notes
-----
- Uses the Phase 1 SQLite DB as the experimental source of truth.
- Uses the repo's time-double-slit simulator to generate predicted spectra.
- Extracts observables from predicted spectra with the repo's observable
  extraction utilities (Phase 2), ensuring consistency.
- Keeps dependencies minimal (numpy + stdlib).
"""

from __future__ import annotations

import argparse
import json
import subprocess
from dataclasses import asdict
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

import numpy as np

from cat_ept_doubleslit.db import load_spectra_by_slit_separation
from cat_ept_doubleslit.experiments.time_double_slit import (
    TimeDoubleSlitConfig,
    alpha_from_rise_10_90,
    beta_from_decay_tau,
    simulate_time_double_slit,
)
from cat_ept_doubleslit.experiments.time_double_slit_fit import PhasePolyParams, fit_phase_poly_to_spectrum
from cat_ept_doubleslit.observables import (
    extract_asymmetry_fraction,
    extract_fringe_spacing_THz,
    extract_high_detuning_power_fraction,
    extract_visibility_paper,
)


def _parse_S_list(s: str) -> List[float]:
    out: List[float] = []
    for part in s.split(","):
        p = part.strip()
        if not p:
            continue
        out.append(float(p))
    if not out:
        raise ValueError("Empty S list")
    return out


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _interp_to(x_src: np.ndarray, y_src: np.ndarray, x_tgt: np.ndarray) -> np.ndarray:
    return np.interp(x_tgt, x_src, y_src, left=float(y_src[0]), right=float(y_src[-1]))


def _rmse(a: np.ndarray, b: np.ndarray) -> float:
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    return float(np.sqrt(np.mean((a - b) ** 2)))


def _loss_multi_train(
    train: List[Tuple[np.ndarray, np.ndarray]],
    base_cfg: TimeDoubleSlitConfig,
    band_half_width_hz: float,
    params: PhasePolyParams,
    use_cat: bool,
    lambda_ent_inv_s: float,
) -> float:
    cfg = TimeDoubleSlitConfig(**{**base_cfg.__dict__})
    cfg.phase_fn = params.to_phase_fn()
    cfg.use_cat_ept = bool(use_cat)
    cfg.cat_mode = "coherence"
    cfg.lambda_ent_inv_s = float(lambda_ent_inv_s)

    # average normalized L2 loss across train spectra
    losses: List[float] = []
    for f_obs_hz, I_obs in train:
        # simulate on its own frequency grid then interpolate
        sim = simulate_time_double_slit(cfg)
        f_sim_hz = np.asarray(sim["freq_hz"], dtype=float)
        I_sim = np.asarray(sim["intensity"], dtype=float)

        # band-normalize both (we normalize via simple scaling in-band)
        f0 = float(cfg.f0_hz)
        mask_o = np.abs(f_obs_hz - f0) <= band_half_width_hz
        mask_s = np.abs(f_sim_hz - f0) <= band_half_width_hz
        if not np.any(mask_o) or not np.any(mask_s):
            continue

        I_obs_b = I_obs / (np.trapezoid(I_obs[mask_o], f_obs_hz[mask_o]) + 1e-30)
        I_sim_b = I_sim / (np.trapezoid(I_sim[mask_s], f_sim_hz[mask_s]) + 1e-30)

        I_sim_i = _interp_to(f_sim_hz, I_sim_b, f_obs_hz)
        d = I_sim_i - I_obs_b
        losses.append(float(np.mean(d * d)))

    if not losses:
        return float("inf")
    return float(np.mean(losses))


def _grid_fit_lambda_ent(
    train: List[Tuple[np.ndarray, np.ndarray]],
    base_cfg: TimeDoubleSlitConfig,
    band_half_width_hz: float,
    phase_params: PhasePolyParams,
    lam_max: float,
) -> Tuple[float, float]:
    """Fit lambda_ent by grid search (robust, dependency-light).

    Returns (best_lambda, best_loss).
    """
    # Coarse-to-fine grid
    grids = [
        np.linspace(0.0, lam_max, 31),
        None,
        None,
    ]

    best_lam = 0.0
    best_loss = float("inf")

    for level, g in enumerate(grids):
        if g is None:
            span = (lam_max / (30 ** level))
            lo = max(0.0, best_lam - span)
            hi = min(lam_max, best_lam + span)
            g = np.linspace(lo, hi, 31)

        for lam in g:
            loss = _loss_multi_train(train, base_cfg, band_half_width_hz, phase_params, True, lam)
            if loss < best_loss:
                best_loss = loss
                best_lam = float(lam)

    return best_lam, float(best_loss)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--out", default="PAPER_TABLES")
    ap.add_argument("--figure_ref", default="Fig_2f")
    ap.add_argument("--train_S_fs", default="500")
    ap.add_argument("--carrier_THz", type=float, default=230.2)
    ap.add_argument("--band_THz", type=float, default=10.0)
    ap.add_argument("--dt_fs", type=float, default=0.2)
    ap.add_argument("--t_window_fs", type=float, default=6000.0)
    ap.add_argument("--probe_fwhm_field_fs", type=float, default=794.0)

    # Optional time-domain constraints (from Phase 2 tables)
    ap.add_argument("--rise_10_90_fs", type=float, default=0.0)
    ap.add_argument("--decay_tau_fs", type=float, default=0.0)

    args = ap.parse_args()

    db_path = Path(args.db)
    out_root = Path(args.out)
    pred_dir = out_root / "PREDICTIONS"
    _ensure_dir(pred_dir)

    # Load experimental spectra grouped by S. The DB may store +/- separations.
    grouped_raw = load_spectra_by_slit_separation(db_path, ref=args.figure_ref)
    grouped: Dict[float, Tuple[np.ndarray, np.ndarray]] = {}
    for k, (f_thz, I) in grouped_raw.items():
        kk = abs(float(k))
        # Prefer the first seen entry for a given |S|; in practice +S and -S are redundant.
        if kk not in grouped:
            grouped[kk] = (np.asarray(f_thz, dtype=float), np.asarray(I, dtype=float))

    # Use absolute S for training/testing selection
    train_S = [abs(s) for s in _parse_S_list(args.train_S_fs)]

    # Build sorted unique S list (float keys may carry tiny rounding noise)
    s_keys = sorted({abs(float(s)) for s in grouped.keys()})

    def resolve_S(S_fs: float, tol_fs: float = 1e-3) -> float:
        """Resolve S (fs) to the nearest available DB key within tolerance."""
        S_fs = abs(float(S_fs))
        k = min(s_keys, key=lambda x: abs(x - S_fs))
        if abs(k - S_fs) > tol_fs:
            raise KeyError(f"Requested S={S_fs} fs not found (nearest={k} fs)")
        return float(k)

    all_S = list(s_keys)

    train_keys = {resolve_S(s) for s in train_S}
    test_S = [s for s in all_S if s not in train_keys]

    # Prepare training spectra list (Hz)
    train_specs: List[Tuple[np.ndarray, np.ndarray]] = []
    for s in train_S:
        s_key = resolve_S(s)
        f_thz, I = grouped[s_key]
        train_specs.append((np.asarray(f_thz) * 1e12, np.asarray(I)))

    # Base config shared by both models
    base_cfg = TimeDoubleSlitConfig(
        f0_hz=args.carrier_THz * 1e12,
        separation_s=float(train_S[0]) * 1e-15,
        dt_s=args.dt_fs * 1e-15,
        t_window_s=args.t_window_fs * 1e-15,
        probe_fwhm_field_s=args.probe_fwhm_field_fs * 1e-15,
    )

    # Optionally infer alpha/beta from provided time-domain observables (paper claims tie rise+decay)
    if args.rise_10_90_fs > 0:
        base_cfg.rise_10_90_s = args.rise_10_90_fs * 1e-15
        base_cfg.alpha_inv_s = -1.0
        base_cfg.alpha_inv_s = alpha_from_rise_10_90(base_cfg.rise_10_90_s)

    if args.decay_tau_fs > 0:
        base_cfg.decay_tau_s = args.decay_tau_fs * 1e-15
        base_cfg.beta_inv_s = -1.0
        base_cfg.beta_inv_s = beta_from_decay_tau(base_cfg.decay_tau_s)

    band_THz = float(args.band_THz)
    band_half_width_hz = band_THz * 1e12

    # ----------- Fit phase params on training set (baseline) -----------
    # Fit on first train spectrum (paper: single S-set). If multiple train, we fit the first and report that.
    f0_obs_hz, I0_obs = train_specs[0]
    phase_fit = fit_phase_poly_to_spectrum(
        f0_obs_hz,
        I0_obs,
        base_cfg,
        band_half_width_hz=band_half_width_hz,
        n_rounds=30,
    )

    phase_params = phase_fit.best_params

    # ----------- Fit CAT lambda_ent on same training set, with phase locked -----------
    # Conservative max: 1/dt (CFL-style ceiling)
    lam_max = 1.0 / max(base_cfg.dt_s, 1e-30)
    lam_best, lam_loss = _grid_fit_lambda_ent(train_specs, base_cfg, band_half_width_hz, phase_params, lam_max)

    # ----------- Predict for all S for both models -----------
    rows_vis: List[Dict[str, object]] = []
    rows_period: List[Dict[str, object]] = []
    rows_asym: List[Dict[str, object]] = []

    # helper: extract experimental observables from raw spectrum (same extractor)
    def exp_obs_for_S(S_fs: float) -> Tuple[float, float, float]:
        s_key = resolve_S(S_fs)
        f_thz, I = grouped[s_key]
        detuning_THz = np.asarray(f_thz, dtype=float) - (float(base_cfg.f0_hz) * 1e-12)
        I = np.asarray(I, dtype=float)
        vis = extract_visibility_paper(detuning_THz, I, band_THz)
        df = extract_fringe_spacing_THz(detuning_THz, I, band_THz)
        asym = extract_asymmetry_fraction(detuning_THz, I, band_THz)
        return float(vis), float(df), float(asym)

    # predicted observable extractor
    def pred_obs_from_sim(sim: Dict[str, np.ndarray]) -> Tuple[float, float, float]:
        f_hz = np.asarray(sim["freq_hz"], dtype=float)
        detuning_THz = (f_hz - float(base_cfg.f0_hz)) * 1e-12
        I = np.asarray(sim["intensity"], dtype=float)
        vis = extract_visibility_paper(detuning_THz, I, band_THz)
        df = extract_fringe_spacing_THz(detuning_THz, I, band_THz)
        asym = extract_asymmetry_fraction(detuning_THz, I, band_THz)
        return float(vis), float(df), float(asym)

    # store per-S detailed spectra for audit
    detail_dir_std = pred_dir / "spectra_standard"
    detail_dir_cat = pred_dir / "spectra_cat"
    _ensure_dir(detail_dir_std)
    _ensure_dir(detail_dir_cat)

    for S_fs in all_S:
        # baseline config for this S
        cfg_std = TimeDoubleSlitConfig(**{**base_cfg.__dict__})
        cfg_std.separation_s = float(S_fs) * 1e-15
        cfg_std.phase_fn = phase_params.to_phase_fn()
        cfg_std.use_cat_ept = False

        cfg_cat = TimeDoubleSlitConfig(**{**cfg_std.__dict__})
        cfg_cat.use_cat_ept = True
        cfg_cat.cat_mode = "coherence"
        cfg_cat.lambda_ent_inv_s = float(lam_best)

        sim_std = simulate_time_double_slit(cfg_std)
        sim_cat = simulate_time_double_slit(cfg_cat)

        # write per-S spectra CSV for audit
        def dump_csv(sim: Dict[str, np.ndarray], out_csv: Path) -> None:
            f_hz = np.asarray(sim["freq_hz"], dtype=float)
            I = np.asarray(sim["intensity"], dtype=float)
            with out_csv.open("w", encoding="utf-8") as f:
                f.write("frequency_THz,intensity\n")
                for fhz, y in zip(f_hz, I):
                    f.write(f"{fhz/1e12:.12g},{y:.12g}\n")

        dump_csv(sim_std, detail_dir_std / f"S_{S_fs:.0f}.csv")
        dump_csv(sim_cat, detail_dir_cat / f"S_{S_fs:.0f}.csv")

        # Extract predicted observables
        vis_s, df_s, asym_s = pred_obs_from_sim(sim_std)
        vis_c, df_c, asym_c = pred_obs_from_sim(sim_cat)

        # Extract experimental observables (same extractor)
        vis_e, df_e, asym_e = exp_obs_for_S(S_fs)

        split = "train" if S_fs in train_S else "test"

        rows_vis.append(
            {
                "slit_separation_fs": S_fs,
                "split": split,
                "visibility_exp": vis_e,
                "visibility_standard": vis_s,
                "visibility_cat": vis_c,
                "abs_err_standard": abs(vis_s - vis_e),
                "abs_err_cat": abs(vis_c - vis_e),
            }
        )
        rows_period.append(
            {
                "slit_separation_fs": S_fs,
                "split": split,
                "period_exp_THz": df_e,
                "period_standard_THz": df_s,
                "period_cat_THz": df_c,
                "abs_err_standard": abs(df_s - df_e),
                "abs_err_cat": abs(df_c - df_e),
            }
        )
        rows_asym.append(
            {
                "slit_separation_fs": S_fs,
                "split": split,
                "asym_exp": asym_e,
                "asym_standard": asym_s,
                "asym_cat": asym_c,
                "abs_err_standard": abs(asym_s - asym_e),
                "abs_err_cat": abs(asym_c - asym_e),
            }
        )

    # ----------- Write outputs -----------
    def write_csv(path: Path, rows: List[Dict[str, object]], cols: List[str]) -> None:
        with path.open("w", encoding="utf-8") as f:
            f.write(",".join(cols) + "\n")
            for r in rows:
                f.write(",".join(str(r.get(c, "")) for c in cols) + "\n")

    write_csv(
        pred_dir / "visibility_predictions.csv",
        rows_vis,
        [
            "slit_separation_fs",
            "split",
            "visibility_exp",
            "visibility_standard",
            "visibility_cat",
            "abs_err_standard",
            "abs_err_cat",
        ],
    )

    write_csv(
        pred_dir / "period_predictions.csv",
        rows_period,
        [
            "slit_separation_fs",
            "split",
            "period_exp_THz",
            "period_standard_THz",
            "period_cat_THz",
            "abs_err_standard",
            "abs_err_cat",
        ],
    )

    write_csv(
        pred_dir / "asymmetry_predictions.csv",
        rows_asym,
        [
            "slit_separation_fs",
            "split",
            "asym_exp",
            "asym_standard",
            "asym_cat",
            "abs_err_standard",
            "abs_err_cat",
        ],
    )

    # ----------- Gate: does CAT improve test-set prediction? -----------
    def mean_abs_err(rows: List[Dict[str, object]], key: str, split: str) -> Tuple[float, int]:
        vals: List[float] = []
        for r in rows:
            if r.get("split") != split:
                continue
            v = float(r.get(key, float("nan")))
            if np.isfinite(v):
                vals.append(v)
        if not vals:
            return float("nan"), 0
        return float(np.mean(vals)), len(vals)

    vis_mae_std, vis_n = mean_abs_err(rows_vis, "abs_err_standard", "test")
    vis_mae_cat, _ = mean_abs_err(rows_vis, "abs_err_cat", "test")

    per_mae_std, per_n = mean_abs_err(rows_period, "abs_err_standard", "test")
    per_mae_cat, _ = mean_abs_err(rows_period, "abs_err_cat", "test")

    asym_mae_std, asym_n = mean_abs_err(rows_asym, "abs_err_standard", "test")
    asym_mae_cat, _ = mean_abs_err(rows_asym, "abs_err_cat", "test")

    # Improvement criterion: CAT must not worsen visibility MAE on test set.
    improved = bool(np.isfinite(vis_mae_std) and np.isfinite(vis_mae_cat) and (vis_mae_cat <= vis_mae_std + 1e-12))

    # Constraint sanity: lambda nonnegative and <= 1/dt
    constraints_ok = (lam_best >= -1e-12) and (lam_best <= lam_max * (1.0 + 1e-12))

    status = {
        "train_S_fs": train_S,
        "test_count": len(test_S),
        "phase_fit_loss": float(phase_fit.best_loss),
        "lambda_ent_best_inv_s": float(lam_best),
        "lambda_ent_fit_loss": float(lam_loss),
        "lambda_ent_ceiling_inv_s": float(lam_max),
        "test_mae": {
            "visibility": {"standard": vis_mae_std, "cat": vis_mae_cat, "n": vis_n},
            "period_THz": {"standard": per_mae_std, "cat": per_mae_cat, "n": per_n},
            "asymmetry": {"standard": asym_mae_std, "cat": asym_mae_cat, "n": asym_n},
        },
        "constraints_ok": bool(constraints_ok),
        "cat_improves_or_ties_visibility": bool(improved),
        "gate_pass": bool(improved and constraints_ok),
        "baseline_settings": {
            "carrier_THz": float(args.carrier_THz),
            "band_THz": float(args.band_THz),
            "dt_fs": float(args.dt_fs),
            "t_window_fs": float(args.t_window_fs),
            "probe_fwhm_field_fs": float(args.probe_fwhm_field_fs),
            "alpha_inv_s": float(base_cfg.alpha_inv_s),
            "beta_inv_s": float(base_cfg.beta_inv_s),
        },
        "phase_params": asdict(phase_params),
    }

    with (pred_dir / "status.json").open("w", encoding="utf-8") as f:
        json.dump(status, f, indent=2, sort_keys=True)

    # ----------- PT diagnostics (calibrated 2x2 reduction) -----------
    # We run the calibrated PT reduction using the SAME training separation
    # as Phase 5 (fit-one, predict-rest), and we *report* conditioning/residual
    # statistics as additional gates. These do not affect the main Phase-5 gate.
    pt_info = None
    pt_gate = {
        "enabled": False,
        "pt_unbroken_fraction_min": 0.9,
        "eta_cond_median_max": 1e8,
        "eta_residual_median_max": 1e-6,
        "pt_gate_pass": None,
    }
    try:
        # Prefer paper-facing visibility column name in the Phase 2 table.
        obs_spectral_csv = out_root / "OBSERVABLES" / "obs_spectral.csv"
        if obs_spectral_csv.exists():
            cmd = [
                "python3",
                str(Path("scripts") / "phase4e_pt_reduction_calibrated.py"),
                "--obs_spectral",
                str(obs_spectral_csv),
                "--out",
                str(out_root),
                "--figure",
                str(args.figure_ref),
                "--visibility_col",
                "visibility_paper",
                "--S_cal_fs",
                str(float(train_S[0])),
            ]
            subprocess.run(cmd, check=True, capture_output=True, text=True)
            pt_dir = out_root / "PT_HAMILTONIAN_2x2_DATA_CAL"
            pt_summary = pt_dir / "summary.json"
            if pt_summary.exists():
                pt_info = json.loads(pt_summary.read_text(encoding="utf-8"))
                pt_gate["enabled"] = True
                # Compute gate pass
                pt_pass = True
                if float(pt_info.get("pt_unbroken_fraction", 0.0)) < pt_gate["pt_unbroken_fraction_min"]:
                    pt_pass = False
                if float(pt_info.get("eta_cond_median", float("inf"))) > pt_gate["eta_cond_median_max"]:
                    pt_pass = False
                if float(pt_info.get("eta_residual_median", float("inf"))) > pt_gate["eta_residual_median_max"]:
                    pt_pass = False
                pt_gate["pt_gate_pass"] = bool(pt_pass)
    except Exception:
        # PT layer is optional; failures are reported as disabled.
        pt_info = None
        pt_gate["enabled"] = False

    if pt_gate["enabled"]:
        status["pt_diagnostics"] = pt_info
        status["pt_gate"] = pt_gate
        # update status.json with PT info
        with (pred_dir / "status.json").open("w", encoding="utf-8") as f:
            json.dump(status, f, indent=2, sort_keys=True)

    # Tool-generated summary.md
    summary_md = pred_dir / "summary.md"
    with summary_md.open("w", encoding="utf-8") as f:
        f.write("# Phase 5: Paper-faithful prediction protocol\n\n")
        f.write(f"Figure ref: `{args.figure_ref}`\n\n")
        f.write(f"Train S (fs): {train_S}\n\n")
        f.write(f"Test points: {len(test_S)}\n\n")
        f.write("## Fitted parameters (train set)\n\n")
        f.write(f"- Phase poly: phi0={phase_params.phi0:.6g}, phi1={phase_params.phi1_rad_per_s:.6g} rad/s, phi2={phase_params.phi2_rad_per_s2:.6g} rad/s^2\n")
        f.write(f"- lambda_ent (CAT coherence): {lam_best:.6g} 1/s (ceiling 1/dt={lam_max:.6g} 1/s)\n\n")
        f.write("## Test-set mean absolute error (MAE)\n\n")
        f.write(f"- Visibility MAE: standard={vis_mae_std:.6g}, CAT={vis_mae_cat:.6g} (n={vis_n})\n")
        f.write(f"- Period MAE (THz): standard={per_mae_std:.6g}, CAT={per_mae_cat:.6g} (n={per_n})\n")
        f.write(f"- Asymmetry MAE: standard={asym_mae_std:.6g}, CAT={asym_mae_cat:.6g} (n={asym_n})\n\n")
        f.write("## Gate\n\n")
        f.write(f"- constraints_ok: {constraints_ok}\n")
        f.write(f"- CAT improves or ties visibility MAE: {improved}\n")
        f.write(f"- **gate_pass**: {status['gate_pass']}\n\n")
        if not status["gate_pass"]:
            f.write("This run did not satisfy the pre-registered gate; see `status.json` and per-S CSVs for details.\n")

        # Append PT diagnostics section if available
        if pt_gate["enabled"] and isinstance(pt_info, dict):
            f.write("\n## PT diagnostics (calibrated 2x2 reduction)\n\n")
            f.write(
                "This is an *auxiliary* diagnostic layer: we fit a single coefficient k on the same train S and "
                "evaluate pseudo-Hermiticity conditioning/residuals on the full S sweep.\n\n"
            )
            f.write(f"- k_calibrated: {pt_info.get('k_calibrated')}\n")
            f.write(f"- PT-unbroken fraction: {pt_info.get('pt_unbroken_fraction')}\n")
            f.write(f"- Median ||H^†η-ηH||: {pt_info.get('eta_residual_median')}\n")
            f.write(f"- Median cond(η): {pt_info.get('eta_cond_median')}\n\n")
            f.write("PT gate thresholds (reported, not used to override Phase 5):\n\n")
            f.write(f"- pt_unbroken_fraction >= {pt_gate['pt_unbroken_fraction_min']}\n")
            f.write(f"- eta_residual_median <= {pt_gate['eta_residual_median_max']}\n")
            f.write(f"- eta_cond_median <= {pt_gate['eta_cond_median_max']}\n\n")
            f.write(f"- pt_gate_pass: {pt_gate.get('pt_gate_pass')}\n")

    (pred_dir / "STATUS.txt").write_text("PASS\n" if status["gate_pass"] else "FAIL\n", encoding="utf-8")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
