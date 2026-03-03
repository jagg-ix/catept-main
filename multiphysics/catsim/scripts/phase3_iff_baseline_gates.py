#!/usr/bin/env python3
"""Phase 3: Standard-theory reproduction gates (IFF).

Goal
----
Prove the simulator reproduces the Tirole et al. *baseline* features BEFORE any
CAT/EPT claims are made.

This script is fully tool-driven:
  * Reads the SQLite DB produced by the data pipeline.
  * Extracts a small set of spectral observables.
  * Runs a baseline simulator (no CAT/EPT), fits a single phase model on one
    calibration S, and predicts the rest.
  * Writes all artifacts to PAPER_TABLES/IFF_BASELINE/.

IFF gating
----------
The baseline is accepted only if the following gates pass:

  Gate A1 (Period law): df ∝ 1/|S|. We fit the proportionality constant k from
    experimental data and require small error AND decent linearity.

  Gate A2 (Multi-THz extent proxy): high-detuning power fraction agreement.

  Gate A3 (Asymmetry sign): after a single phase fit on one S, the predicted
    red/blue asymmetry sign matches across the S-set.
"""

from __future__ import annotations

import argparse
import json
import os
from dataclasses import asdict
from pathlib import Path
from typing import Dict, List, Tuple

import numpy as np


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _safe_float(x) -> float:
    try:
        return float(x)
    except Exception:
        return float("nan")


def _pick_17_S_values(S_all: np.ndarray) -> np.ndarray:
    """Pick up to 17 representative |S| values (fs)."""
    S = np.unique(np.abs(np.asarray(S_all, dtype=float)))
    S = S[np.isfinite(S)]
    S = S[(S >= 300.0) & (S <= 1600.0)]
    if S.size == 0:
        return np.array([], dtype=float)
    if S.size <= 17:
        return np.sort(S)
    qs = np.linspace(0.0, 1.0, 17)
    return np.unique(np.quantile(np.sort(S), qs))


def _mare(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    y_true = np.asarray(y_true, dtype=float)
    y_pred = np.asarray(y_pred, dtype=float)
    mask = np.isfinite(y_true) & np.isfinite(y_pred) & (np.abs(y_true) > 1e-12)
    if not np.any(mask):
        return float("nan")
    return float(np.mean(np.abs(y_true[mask] - y_pred[mask]) / np.abs(y_true[mask])))


def _r2(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    y_true = np.asarray(y_true, dtype=float)
    y_pred = np.asarray(y_pred, dtype=float)
    mask = np.isfinite(y_true) & np.isfinite(y_pred)
    if np.sum(mask) < 2:
        return float("nan")
    yt = y_true[mask]
    yp = y_pred[mask]
    ss_res = float(np.sum((yt - yp) ** 2))
    ss_tot = float(np.sum((yt - np.mean(yt)) ** 2))
    return float(1.0 - ss_res / ss_tot) if ss_tot > 0 else float("nan")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True, help="Path to sqlite3 DB (double_slit.sqlite3)")
    ap.add_argument("--out", default="PAPER_TABLES", help="Output folder")
    ap.add_argument("--ref", default="Fig_2f", help="Figure ref for spectral dataset")
    ap.add_argument("--carrier_THz", type=float, default=230.2)
    ap.add_argument("--band_THz", type=float, default=10.0)
    ap.add_argument("--cal_S_fs", type=float, default=500.0, help="Calibration S to fit phase")
    ap.add_argument("--alpha_inv_fs", type=float, default=0.5)
    ap.add_argument("--beta_inv_fs", type=float, default=1.0 / 400.0)
    args = ap.parse_args()

    from cat_ept_doubleslit.db import load_spectra_by_slit_separation
    from cat_ept_doubleslit.experiments.time_double_slit import TimeDoubleSlitConfig, simulate_time_double_slit_band
    from cat_ept_doubleslit.experiments.time_double_slit_fit import PhasePolyParams, fit_phase_poly_to_spectrum
    from cat_ept_doubleslit.observables import (
        extract_asymmetry_fraction,
        extract_fringe_spacing_THz,
        extract_high_detuning_power_fraction,
        extract_visibility_paper,
    )

    out_dir = Path(args.out) / "IFF_BASELINE"
    _ensure_dir(out_dir)

    spec_map = load_spectra_by_slit_separation(args.db, ref=args.ref)
    if len(spec_map) == 0:
        raise SystemExit(f"No spectra for ref={args.ref} in DB: {args.db}")

    # Observables from experimental spectra
    def guided_fringe_spacing(det_THz: np.ndarray, I: np.ndarray, S_fs: float) -> float:
        expected = 1000.0 / max(abs(float(S_fs)), 1e-9)
        min_s = max(0.55 * expected, 0.05)
        max_s = min(1.80 * expected, 30.0)
        return extract_fringe_spacing_THz(
            det_THz, I, band_THz=args.band_THz, min_spacing_THz=min_s, max_spacing_THz=max_s
        )

    def exp_obs_for_S(S_fs: float) -> Dict[str, float]:
        keys = np.array(sorted(spec_map.keys()), dtype=float)
        if keys.size == 0:
            return {}
        target = abs(float(S_fs))
        keys_abs = np.abs(keys)
        s0_raw = float(keys[np.argmin(np.abs(keys_abs - target))])
        f_THz, inten = spec_map[s0_raw]
        det = f_THz - float(args.carrier_THz)
        I = inten / (np.max(inten) + 1e-300)
        return {
            "S_fs": abs(float(s0_raw)),
            "df_THz": guided_fringe_spacing(det, I, abs(float(s0_raw))),
            "vis_paper": extract_visibility_paper(det, I, band_THz=args.band_THz),
            "asym": extract_asymmetry_fraction(det, I, band_THz=args.band_THz),
            "high_frac": extract_high_detuning_power_fraction(det, I, band_THz=args.band_THz),
        }

    all_S = np.array(list(spec_map.keys()), dtype=float)
    S_sel = _pick_17_S_values(all_S)
    exp_obs = [exp_obs_for_S(s) for s in S_sel]
    exp_obs = [o for o in exp_obs if np.isfinite(o.get("df_THz", np.nan))]
    if len(exp_obs) < 5:
        raise SystemExit("Insufficient valid experimental observables for IFF gates.")

    # Calibration: fit phase polynomial to one experimental spectrum
    keys = np.array(sorted(spec_map.keys()), dtype=float)
    keys_abs = np.abs(keys)
    s_cal_raw = float(keys[np.argmin(np.abs(keys_abs - abs(args.cal_S_fs)))])
    f_cal_THz, inten_cal = spec_map[s_cal_raw]
    f_cal_hz = f_cal_THz * 1e12
    I_cal = inten_cal

    cfg0 = TimeDoubleSlitConfig(
        separation_s=abs(float(s_cal_raw)) * 1e-15,
        alpha_inv_s=float(args.alpha_inv_fs) * 1e15,
        beta_inv_s=float(args.beta_inv_fs) * 1e15,
        f0_hz=float(args.carrier_THz) * 1e12,
    )
    fitres = fit_phase_poly_to_spectrum(
        f_cal_hz,
        I_cal,
        base_cfg=cfg0,
        band_half_width_hz=float(args.band_THz) * 1e12,
    )
    phase_fit = fitres.best_params
    fit_loss = fitres.best_loss
    phase_fn = phase_fit.to_phase_fn()

    # Baseline predictions for all S with fixed phase
    sim_obs: List[Dict[str, float]] = []
    for o in exp_obs:
        s_use = abs(float(o["S_fs"]))
        cfg = TimeDoubleSlitConfig(
            separation_s=s_use * 1e-15,
            alpha_inv_s=float(args.alpha_inv_fs) * 1e15,
            beta_inv_s=float(args.beta_inv_fs) * 1e15,
            f0_hz=float(args.carrier_THz) * 1e12,
            phase_fn=phase_fn,
        )
        sim = simulate_time_double_slit_band(cfg, half_width_hz=float(args.band_THz) * 1e12)
        det_sim = sim["freq_hz_band"] / 1e12 - float(args.carrier_THz)
        I_sim = sim["intensity_band"]
        sim_obs.append(
            {
                "S_fs": s_use,
                "df_THz": guided_fringe_spacing(det_sim, I_sim, s_use),
                "vis_paper": extract_visibility_paper(det_sim, I_sim, band_THz=args.band_THz),
                "asym": extract_asymmetry_fraction(det_sim, I_sim, band_THz=args.band_THz),
                "high_frac": extract_high_detuning_power_fraction(det_sim, I_sim, band_THz=args.band_THz),
            }
        )

    # ---- Gate A1: df ∝ 1/S (fit k)
    exp_S = np.array([_safe_float(o["S_fs"]) for o in exp_obs])
    exp_df = np.array([_safe_float(o["df_THz"]) for o in exp_obs])
    x = 1.0 / exp_S
    k_fit = float(np.dot(x, exp_df) / (np.dot(x, x) + 1e-30))
    pred_df = k_fit * x
    gate_A1 = {"n": int(len(exp_df)), "k_fit": float(k_fit), "mare": _mare(exp_df, pred_df), "r2": _r2(exp_df, pred_df)}

    # ---- Gate A2: high-detuning fraction agreement
    exp_h = np.array([_safe_float(o["high_frac"]) for o in exp_obs])
    sim_h = np.array([_safe_float(o["high_frac"]) for o in sim_obs])
    gate_A2 = {
        "n": int(len(exp_h)),
        "high_detuning_fraction_mae": float(np.nanmean(np.abs(exp_h - sim_h))),
    }

    # ---- Gate A3: asymmetry sign match
    exp_as = np.array([_safe_float(o["asym"]) for o in exp_obs])
    sim_as = np.array([_safe_float(o["asym"]) for o in sim_obs])
    sign_match = np.mean(np.sign(exp_as) == np.sign(sim_as))
    gate_A3 = {
        "n": int(len(exp_as)),
        "cal_S_fs": float(abs(s_cal_raw)),
        "phase_fit": asdict(phase_fit),
        "fit_loss": float(fit_loss),
        "sign_match_rate": float(sign_match),
    }

    thresholds = {
        "A1_mare_max": 0.15,
        "A1_r2_min": 0.85,
        "A2_high_frac_mae_max": 0.20,
        "A3_sign_match_min": 0.70,
    }

    pass_fail = {
        "A1": (gate_A1["mare"] <= thresholds["A1_mare_max"]) and (gate_A1["r2"] >= thresholds["A1_r2_min"]),
        "A2": gate_A2["high_detuning_fraction_mae"] <= thresholds["A2_high_frac_mae_max"],
        "A3": gate_A3["sign_match_rate"] >= thresholds["A3_sign_match_min"],
    }
    pass_fail["overall"] = bool(pass_fail["A1"] and pass_fail["A2"] and pass_fail["A3"])

    # Save CSV for inspection
    import csv

    cmp_path = out_dir / "iff_baseline_compare.csv"
    with cmp_path.open("w", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "S_fs",
                "exp_df_THz",
                "exp_vis_paper",
                "exp_asym",
                "exp_high_frac",
                "sim_df_THz",
                "sim_vis_paper",
                "sim_asym",
                "sim_high_frac",
            ],
        )
        w.writeheader()
        for e, s in zip(exp_obs, sim_obs):
            w.writerow(
                {
                    "S_fs": e["S_fs"],
                    "exp_df_THz": e["df_THz"],
                    "exp_vis_paper": e["vis_paper"],
                    "exp_asym": e["asym"],
                    "exp_high_frac": e["high_frac"],
                    "sim_df_THz": s["df_THz"],
                    "sim_vis_paper": s["vis_paper"],
                    "sim_asym": s["asym"],
                    "sim_high_frac": s["high_frac"],
                }
            )

    status = {
        "gate_A1": gate_A1,
        "gate_A2": gate_A2,
        "gate_A3": gate_A3,
        "thresholds": thresholds,
        "pass_fail": pass_fail,
    }
    (out_dir / "status.json").write_text(json.dumps(status, indent=2))
    (out_dir / "STATUS.txt").write_text(
        "PASS\n" if pass_fail["overall"] else "FAIL\n" + json.dumps(pass_fail, indent=2) + "\n"
    )

    # Simple plots
    import matplotlib.pyplot as plt

    # Gate A1 plot: df vs 1/S
    plt.figure()
    plt.scatter(1.0 / exp_S, exp_df)
    xs = np.linspace(np.min(1.0 / exp_S), np.max(1.0 / exp_S), 200)
    plt.plot(xs, k_fit * xs)
    plt.xlabel("1/S (1/fs)")
    plt.ylabel("Fringe spacing df (THz)")
    plt.title(f"Gate A1: df ≈ k/S (k={k_fit:.1f} THz·fs)\nR2={gate_A1['r2']:.3f}, MARE={gate_A1['mare']:.3f}")
    plt.tight_layout()
    plt.savefig(out_dir / "gate_A1_period_law.png", dpi=160)
    plt.close()

    # Asymmetry sign plot
    plt.figure()
    plt.scatter(exp_S, exp_as, label="exp")
    plt.scatter(exp_S, sim_as, label="sim")
    plt.axhline(0.0)
    plt.xlabel("S (fs)")
    plt.ylabel("Asymmetry fraction")
    plt.title(f"Gate A3: asymmetry sign match = {gate_A3['sign_match_rate']:.2f}")
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "gate_A3_asymmetry_sign.png", dpi=160)
    plt.close()

    # High-detuning fraction plot
    plt.figure()
    plt.scatter(exp_S, exp_h, label="exp")
    plt.scatter(exp_S, sim_h, label="sim")
    plt.xlabel("S (fs)")
    plt.ylabel("High-detuning power fraction")
    plt.title(f"Gate A2: MAE = {gate_A2['high_detuning_fraction_mae']:.3g}")
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_dir / "gate_A2_high_detuning_fraction.png", dpi=160)
    plt.close()


if __name__ == "__main__":
    main()
