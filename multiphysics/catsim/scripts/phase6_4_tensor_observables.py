#!/usr/bin/env python3
"""Phase 6.4 (ADVANCED): Export Paper3 tensors as observables alongside Phase 6 bounds.

This is an intentionally *paper-faithful* bridge: it converts Phase 6 bound inputs
(visibility loss + a rate proxy) into a small set of geometric tensor components that
can be tracked across slit separations.

We do **not** claim a unique physical identification of "S" with a spacetime coordinate.
Instead, this script provides two reproducible mappings for diagnostics:

  (A) window mode (legacy):
      - Use Phase 5 best-fit GKLS-rate proxy (lambda_ent) as a constant rate λ.
      - Use a time window Δt inferred from Phase 6.3 (default: |S| in femtoseconds).
      - Define φ(t) = λ t and evaluate Paper3 tensors at t = Δt.

  (B) profile mode (preferred when available):
      - Reconstruct a paper-style reflectivity r(t) for each S using the simulator's
        TimeDoubleSlitConfig (alpha/beta/ITO slit shape).
      - Build a toggleable λ(t) proxy from r(t) (same stable proxy used in CAT/EPT-on runs).
      - Define φ(t)=∫λ(t) dt and evaluate tensors along the temporal slit.
      - Export both summary observables and downsampled time profiles.

Profile mode keeps the core project discipline: *additive, toggleable, and gated*.

Outputs under PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES/:
  - tensor_observables.csv
  - summary.json
  - STATUS.md

"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import pandas as pd
import sympy as sp

from cat_ept_doubleslit.utils.run_id import compute_run_id

from catsim_core.units import parse_quantity
from catsim_core.metric.entropic_tensors import entropic_stress_tensor, imaginary_curvature_tensor


def _numeric_tensors_time_only(
    t_s: np.ndarray,
    lam_t: np.ndarray,
    phi_t: np.ndarray,
    mode: str,
    alpha: float | None,
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """Fast numeric tensors for Minkowski metric when φ depends only on time.

    Returns arrays (S00, S11, Lam00, Lam11) matching the covariant components.

    Assumptions:
      - g = diag(-1,1,1,1)
      - φ = φ(t)
      - ∂0 φ = dφ/dt = λ(t)
      - ∂0∂0 φ = dλ/dt

    This is intentionally conservative and avoids symbolic overhead.
    """

    t_s = np.asarray(t_s, dtype=float)
    lam_t = np.asarray(lam_t, dtype=float)
    phi_t = np.asarray(phi_t, dtype=float)
    if t_s.size < 3:
        raise ValueError("Need at least 3 time samples")
    dt = float(t_s[1] - t_s[0])
    if dt <= 0:
        raise ValueError("Nonpositive dt")

    # S_{μν} = -∂_μ φ ∂_ν φ + 1/2 g_{μν} (∂φ)^2
    # Here (∂φ)^2 = g^{00} (∂0 φ)^2 = -λ^2
    lam2 = lam_t * lam_t
    S00 = -lam2 + 0.5 * (-1.0) * (-lam2)  # = -1/2 λ^2
    S11 = 0.0 + 0.5 * (1.0) * (-lam2)     # = -1/2 λ^2

    dlam_dt = np.gradient(lam_t, dt)
    H00 = dlam_dt
    trH = -dlam_dt  # g^{00} H00

    m = str(mode).lower()
    if m == "hessian":
        Lam00 = H00
        Lam11 = 0.0 * H00
    elif m == "einstein_like":
        # H_{μν} - 1/2 g_{μν} tr(H)
        Lam00 = H00 - 0.5 * (-1.0) * trH
        Lam11 = 0.0 - 0.5 * (1.0) * trH
    elif m == "trace_adjusted":
        # H_{μν} - 1/4 g_{μν} tr(H)
        Lam00 = H00 - 0.25 * (-1.0) * trH
        Lam11 = 0.0 - 0.25 * (1.0) * trH
    elif m == "trace_adjusted_weighted":
        a = float(alpha) if alpha is not None else 0.25
        Lam00 = H00 - a * (-1.0) * trH
        Lam11 = 0.0 - a * (1.0) * trH
    else:
        # default to trace_adjusted
        Lam00 = H00 - 0.25 * (-1.0) * trH
        Lam11 = 0.0 - 0.25 * (1.0) * trH

    return S00.astype(float), S11.astype(float), Lam00.astype(float), Lam11.astype(float)


def _load_tensor_cfg(cfg_path: Path) -> dict:
    if not cfg_path.exists():
        return {}
    try:
        import yaml

        return yaml.safe_load(cfg_path.read_text()) or {}
    except Exception:
        # yaml optional: treat missing/invalid as empty
        return {}


def _load_paper_faithful_time_slit_params(repo_root: Path) -> dict:
    """Load the *paper-faithful* slit + probe parameters used by the pipeline.

    Phase 6.4 profile mode must be anchored to the same configuration used by
    Phase 3/5 baselines whenever possible.

    Preferred source: PAPER_LOGS/config_snapshot.json (created by the pipeline).
    Fallback sources: PAPER_LOGS/STATUS/PREDICTIONS__status.json.
    Final fallback: TimeDoubleSlitConfig defaults.
    """

    candidates = [
        repo_root / "PAPER_LOGS" / "config_snapshot.json",
        repo_root / "PAPER_LOGS" / "STATUS" / "PREDICTIONS__status.json",
    ]
    for p in candidates:
        if not p.exists():
            continue
        try:
            d = json.loads(p.read_text())
        except Exception:
            continue

        # config_snapshot.json nests phase5 status under "phase5_status_json".
        if isinstance(d, dict) and "phase5_status_json" in d:
            d = d.get("phase5_status_json", {})

        if not isinstance(d, dict):
            continue

        bs = d.get("baseline_settings", {})
        if isinstance(bs, dict) and bs:
            return bs
    return {}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--paper_tables", default="PAPER_TABLES")
    ap.add_argument(
        "--bounds_csv",
        default="PAPER_TABLES/ADVANCED/BOUNDS/info_visibility_bound.csv",
        help="Input from Phase 6.3 (selected estimator).",
    )
    ap.add_argument("--tensor_config", default="configs/paper3_tensors.yaml")
    ap.add_argument(
        "--window_col",
        default="gkls_window_fs",
        help="Time window column to use (fs). Fallback: |slit_separation_fs|.",
    )
    ap.add_argument("--out", default="PAPER_TABLES")
    args = ap.parse_args()

    bounds_path = Path(args.bounds_csv)
    if not bounds_path.exists():
        raise SystemExit(f"Missing bounds CSV: {bounds_path}")

    cfg = _load_tensor_cfg(Path(args.tensor_config))
    lam_cfg = (cfg.get("lambda_tensor", {}) if isinstance(cfg, dict) else {})
    mode = str(lam_cfg.get("mode", "trace_adjusted"))
    alpha = lam_cfg.get("alpha", None)
    ent_time = bool((cfg.get("entropic_time", {}) or {}).get("enabled", False))
    phi_profile_cfg = (cfg.get("phi_profile", {}) or {}) if isinstance(cfg, dict) else {}
    profile_enabled = bool(phi_profile_cfg.get("enabled", True))
    profile_downsample = int(phi_profile_cfg.get("downsample_points", 220))
    profile_kappa = float(phi_profile_cfg.get("lambda_kappa", 1.0))
    profile_floor = float(phi_profile_cfg.get("lambda_floor_inv_s", 0.0))
    tol = float(((cfg.get("gates", {}) or {}).get("tol", 1e-9)))

    df = pd.read_csv(bounds_path)
    if len(df) == 0:
        raise SystemExit("Bounds CSV is empty")

    repo_root = Path(__file__).resolve().parents[1]
    paper_params = _load_paper_faithful_time_slit_params(repo_root)

    # Symbolic setup (computed once)
    t = sp.Symbol("t", real=True)
    lam = sp.Symbol("lam", real=True, nonnegative=True)
    phi = lam * t
    # Base metric: Minkowski diag(-1,1,1,1)
    g = sp.diag(-1, 1, 1, 1)
    coords = (t, sp.Symbol("x"), sp.Symbol("y"), sp.Symbol("z"))

    # Optional "entropic time" coordinate mode for tensor evaluation:
    # treat the time coordinate as τ with metric component g_{ττ} = -1/λ^2 (constant-λ demo).
    if ent_time:
        g = sp.diag(-(1 / (lam**2)), 1, 1, 1)

    S_sym = entropic_stress_tensor(phi, g, coords)
    Lam_sym = imaginary_curvature_tensor(
        phi,
        g,
        coords,
        mode=mode,
        alpha=sp.Rational(alpha) if (alpha is not None and isinstance(alpha, (int, float))) else alpha,
    )

    # Profile mode uses the same simulator module that drives Phase 3/5 so it stays paper-faithful.
    # We keep it *soft*: if imports fail, we fall back to window mode.
    sim_ok = False
    try:
        from cat_ept_doubleslit.experiments.time_double_slit import TimeDoubleSlitConfig, simulate_time_double_slit

        sim_ok = True
    except Exception:
        TimeDoubleSlitConfig = None  # type: ignore
        simulate_time_double_slit = None  # type: ignore

    rows = []
    profiles_dir = Path(args.out) / "ADVANCED" / "TENSOR_OBSERVABLES" / "profiles"
    if profile_enabled and sim_ok:
        profiles_dir.mkdir(parents=True, exist_ok=True)
    for _, r in df.iterrows():
        S_fs = float(r.get("slit_separation_fs", np.nan))
        lam_inv_s = float(r.get("lambda_phase5_inv_s", np.nan))
        if not np.isfinite(lam_inv_s) or lam_inv_s < 0:
            continue
        win_fs = float(r.get(args.window_col, np.nan))
        if not np.isfinite(win_fs):
            win_fs = abs(S_fs)

        # convert fs -> s
        win_s = float(parse_quantity({"value": win_fs, "unit": "fs"}, kind="time").value)
        # evaluate at t = window (coordinate time or τ for entropic_time mode)
        subs = {lam: lam_inv_s, t: win_s}
        S_num = np.array(S_sym.subs(subs)).astype(np.float64)
        Lam_num = np.array(Lam_sym.subs(subs)).astype(np.float64)

        out_row = {
                "slit_separation_fs": S_fs,
                "window_fs": win_fs,
                "window_s": win_s,
                "lambda_inv_s": lam_inv_s,
                "phi_window": float(lam_inv_s * win_s),
                "lambda_mode": mode,
                "entropic_time": bool(ent_time),
                "S_00": float(S_num[0, 0]),
                "S_11": float(S_num[1, 1]),
                "S_trace": float(np.trace(S_num)),
                "Lambda_00": float(Lam_num[0, 0]),
                "Lambda_11": float(Lam_num[1, 1]),
                "Lambda_trace": float(np.trace(Lam_num)),
        }

        # Preferred: build a φ(t) profile from the reflectivity model and export evolved tensors.
        if profile_enabled and sim_ok:
            try:
                # Pull paper-faithful slit/probe discretization parameters from the
                # pipeline snapshot when available (Phase 3/5 baselines).
                alpha_inv_s = float(paper_params.get("alpha_inv_s", 0.5e15))
                beta_inv_s = float(paper_params.get("beta_inv_s", (1.0 / 400e-15)))
                carrier_THz = paper_params.get("carrier_THz", None)
                probe_fwhm_field_fs = paper_params.get("probe_fwhm_field_fs", None)
                dt_fs = paper_params.get("dt_fs", None)
                t_window_fs = paper_params.get("t_window_fs", None)

                f0_hz = float(carrier_THz) * 1e12 if carrier_THz is not None else 230.2e12
                probe_fwhm_field_s = float(probe_fwhm_field_fs) * 1e-15 if probe_fwhm_field_fs is not None else 794e-15
                dt_s = float(dt_fs) * 1e-15 if dt_fs is not None else 0.2e-15
                t_window_s = float(t_window_fs) * 1e-15 if t_window_fs is not None else 6e-12

                cfg_sim = TimeDoubleSlitConfig(
                    f0_hz=f0_hz,
                    probe_fwhm_field_s=probe_fwhm_field_s,
                    separation_s=abs(float(S_fs)) * 1e-15,
                    alpha_inv_s=alpha_inv_s,
                    beta_inv_s=beta_inv_s,
                    A=0.5,
                    B=0.5,
                    C=0.0,
                    t_window_s=t_window_s,
                    dt_s=dt_s,
                    use_cat_ept=True,
                    # Use the Phase 5 λ as the baseline rate; add a small, stable edge-localized proxy.
                    lambda0_inv_s=float(lam_inv_s),
                    lambda_kappa=float(profile_kappa),
                    lambda_floor_inv_s=float(profile_floor),
                    # In profile mode, we are not using g(S) factorization; only need λ(t), τ(t).
                    cat_mode="amplitude",
                )
                sim = simulate_time_double_slit(cfg_sim)
                t_s = np.asarray(sim.get("t_s"), dtype=float)
                lam_t = np.asarray(sim.get("lambda_t"), dtype=float)
                tau_t = np.asarray(sim.get("tau_ent_s"), dtype=float)

                # Fallbacks if keys differ
                if t_s.size == 0:
                    t_s = np.asarray(sim.get("t"), dtype=float)
                if lam_t.size == 0:
                    lam_t = np.asarray(sim.get("lam_t"), dtype=float)
                if tau_t.size == 0:
                    tau_t = np.asarray(sim.get("tau_t"), dtype=float)

                # Basic validity
                if t_s.size >= 3 and lam_t.size == t_s.size and tau_t.size == t_s.size:
                    # Enforce nonnegativity for the tensor mapping.
                    lam_t = np.maximum(lam_t, 0.0)

                    # If running in entropic-time coordinates, treat φ(τ)=τ (paper: φ = ∫λ dt).
                    if ent_time:
                        # Use τ as coordinate, φ=τ, dφ/dτ=1, d²φ/dτ²=0.
                        # Use a constant λ_bar for g_{ττ} = -1/λ_bar² (consistent with earlier demos).
                        lam_bar = float(np.median(lam_t[np.isfinite(lam_t)])) if np.any(np.isfinite(lam_t)) else float(lam_inv_s)
                        lam_bar = max(lam_bar, 1e-30)
                        tau = tau_t
                        phi_prof = tau
                        # In τ-coordinates: λ(τ) := dφ/dτ = 1.
                        lam_tau = np.ones_like(tau, dtype=float)
                        S00_prof = -0.5 * np.ones_like(tau)
                        S11_prof = -0.5 * np.ones_like(tau)
                        Lam00_prof = np.zeros_like(tau)
                        Lam11_prof = np.zeros_like(tau)
                        t_coord = tau
                        t_col = "tau_ent_s"
                        out_row.update({"lambda_bar_inv_s": lam_bar, "profile_coord": "tau"})
                    else:
                        phi_prof = tau_t
                        S00_prof, S11_prof, Lam00_prof, Lam11_prof = _numeric_tensors_time_only(
                            t_s=t_s,
                            lam_t=lam_t,
                            phi_t=phi_prof,
                            mode=mode,
                            alpha=float(alpha) if isinstance(alpha, (int, float)) else None,
                        )
                        t_coord = t_s
                        t_col = "t_s"
                        out_row.update({"profile_coord": "t"})

                    # Summary observables
                    out_row.update(
                        {
                            "profile_enabled": True,
                            "profile_peak_lambda_inv_s": float(np.nanmax(lam_t)) if lam_t.size else np.nan,
                            "profile_peak_phi": float(np.nanmax(phi_prof)) if phi_prof.size else np.nan,
                            "profile_peak_abs_Lambda_00": float(np.nanmax(np.abs(Lam00_prof))) if Lam00_prof.size else np.nan,
                            "profile_peak_abs_S_00": float(np.nanmax(np.abs(S00_prof))) if S00_prof.size else np.nan,
                        }
                    )

                    # Downsample and write profile (bounded size, reproducible)
                    n = int(profile_downsample)
                    n = max(min(n, int(t_coord.size)), 20)
                    idx = np.unique(np.linspace(0, t_coord.size - 1, n).round().astype(int))
                    prof_df = pd.DataFrame(
                        {
                            t_col: t_coord[idx],
                            "phi": np.asarray(phi_prof)[idx],
                            "lambda_like": (lam_tau[idx] if ent_time else lam_t[idx]),
                            "S_00": np.asarray(S00_prof)[idx],
                            "Lambda_00": np.asarray(Lam00_prof)[idx],
                        }
                    )
                    tag = f"S_{float(S_fs):.6g}fs".replace("-", "m")
                    prof_df.to_csv(profiles_dir / f"tensor_profile_{tag}.csv", index=False)
                else:
                    out_row.update({"profile_enabled": False, "profile_note": "missing_profile_arrays"})
            except Exception as e:
                out_row.update({"profile_enabled": False, "profile_note": f"profile_failed:{type(e).__name__}"})
        else:
            out_row.update({"profile_enabled": False, "profile_note": "profile_disabled_or_sim_missing"})

        rows.append(out_row)

    out_dir = Path(args.out) / "ADVANCED" / "TENSOR_OBSERVABLES"
    out_dir.mkdir(parents=True, exist_ok=True)

    # repo_root already computed above
    bv_path = repo_root / "BUNDLE_VERSION.txt"
    bundle_version = bv_path.read_text().strip() if bv_path.exists() else "unknown"
    run_id = compute_run_id(
        bundle_version=bundle_version,
        script_id="phase6.4_tensor_observables",
        db_path=str(bounds_path),
        config_paths=[args.tensor_config],
    )

    out_csv = out_dir / "tensor_observables.csv"
    out_df = pd.DataFrame(rows).sort_values(["slit_separation_fs"])
    out_df.to_csv(out_csv, index=False)

    # Gates (conservative):
    # - Always require finite exported tensors.
    # - If entropic-time coordinate mode is enabled, φ(τ)=τ implies d²φ/dτ²=0, so Λ00 should be ~0.
    max_abs_lambda00_window = float(np.nanmax(np.abs(out_df["Lambda_00"].to_numpy()))) if len(out_df) else float("nan")
    finite_ok = bool(len(out_df) > 0)
    for col in ["S_00", "Lambda_00", "S_11", "Lambda_11"]:
        if col in out_df.columns:
            finite_ok = finite_ok and bool(np.all(np.isfinite(out_df[col].to_numpy())))

    max_abs_profile = float("nan")
    if "profile_peak_abs_Lambda_00" in out_df.columns and np.any(out_df.get("profile_enabled", False)):
        max_abs_profile = float(np.nanmax(out_df["profile_peak_abs_Lambda_00"].to_numpy()))

    if ent_time and np.isfinite(max_abs_profile):
        pass_gate = bool(finite_ok and (max_abs_profile <= tol))
    else:
        # In coordinate-time profile mode Λ00 is generally nonzero; we gate only finiteness.
        pass_gate = bool(finite_ok)

    summary = {
        "run_id": run_id,
        "bundle_version": bundle_version,
        "lambda_mode": mode,
        "entropic_time": bool(ent_time),
        "rows": int(len(out_df)),
        "max_abs_Lambda_00_window": max_abs_lambda00_window,
        "max_abs_profile_Lambda_00": max_abs_profile,
        "tol": tol,
        "PASS": pass_gate,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2, sort_keys=True))
    status = "PASS" if pass_gate else "FAIL"
    (out_dir / "STATUS.md").write_text(
        "\n".join(
            [
                f"# Phase 6.4 Tensor Observables: {status}",
                "",
                f"- run_id: `{run_id}`",
                f"- lambda_mode: `{mode}`",
                f"- entropic_time: `{bool(ent_time)}`",
                f"- rows: {len(out_df)}",
                f"- max_abs_Lambda_00_window: {max_abs_lambda00_window:.3e}",
                f"- max_abs_profile_Lambda_00: {max_abs_profile:.3e} (tol={tol:.1e})",
            ]
        )
        + "\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
