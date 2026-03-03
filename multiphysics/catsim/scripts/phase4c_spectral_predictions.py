"""Phase 4C: spectral forward-model training and cross-S prediction.

This script produces tool-generated artifacts under PAPER_TABLES/ and is intended
to be run after:
  - Phase 1 (XLSX->SQLite) and
  - Phase 2 (observable extraction tables).

What it does:
  1) Load observed spectra for Fig_2f (sweep over slit separation S) from SQLite.
  2) Load time-domain rise/decay observables (Fig_2g-derived) from
     PAPER_TABLES/OBSERVABLES/obs_time_domain.csv and compute robust medians.
  3) Fit baseline phase polynomial parameters on ONE calibration spectrum S_cal
     using the standard model (CAT/EPT off).
  4) With the fitted phase locked, fit a single CAT/EPT coherence-decay rate
     lambda_ent on that same calibration spectrum (CAT/EPT on, cat_mode=coherence).
  5) Predict spectra for all other S values with phase locked (and lambda_ent for
     CAT), and write per-S RMSE and overlay plots.

Outputs:
  PAPER_TABLES/SPECTRAL_PREDICTIONS/
    standard/  (per-S csv+png)
    cat/       (per-S csv+png)
    summary.csv
    fit_params.json
    STATUS.txt

No SciPy dependency.
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import numpy as np
import pandas as pd
import sqlite3

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

from cat_ept_doubleslit.experiments.time_double_slit import TimeDoubleSlitConfig, bandpass_normalize
from cat_ept_doubleslit.experiments.time_double_slit_fit import PhasePolyParams, fit_phase_poly_to_spectrum


def _ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def _rmse(a: np.ndarray, b: np.ndarray) -> float:
    a = np.asarray(a, dtype=float)
    b = np.asarray(b, dtype=float)
    return float(np.sqrt(np.mean((a - b) ** 2)))


def load_fig2f_spectra(db_path: str) -> pd.DataFrame:
    """Return spectra rows for Fig_2f with columns: S_fs, freq_THz, intensity."""
    con = sqlite3.connect(db_path)
    q = """
    select s.slit_separation_fs as S_fs,
           s.frequency_thz as freq_THz,
           s.intensity as intensity,
           s.series as series
    from spectra s
    join experiments e on e.id = s.experiment_id
    where e.figure_ref = 'Fig_2f'
    """
    df = pd.read_sql_query(q, con)
    con.close()
    df = df.dropna(subset=["S_fs", "freq_THz", "intensity"])
    df["S_fs"] = df["S_fs"].astype(float)
    df["freq_THz"] = df["freq_THz"].astype(float)
    df["intensity"] = df["intensity"].astype(float)
    return df


def load_time_domain_observables(obs_time_csv: str) -> pd.DataFrame:
    df = pd.read_csv(obs_time_csv)
    # expected columns from Phase 2: S_fs, rise_10_90_s, decay_tau_s, ...
    return df


def infer_rise_decay_medians(obs_time: pd.DataFrame) -> tuple[float, float]:
    # robust medians over positive values
    rise = obs_time.get("rise_10_90_s")
    decay = obs_time.get("decay_tau_s")
    rise_vals = np.asarray(rise, dtype=float) if rise is not None else np.array([])
    decay_vals = np.asarray(decay, dtype=float) if decay is not None else np.array([])
    rise_vals = rise_vals[np.isfinite(rise_vals) & (rise_vals > 0)]
    decay_vals = decay_vals[np.isfinite(decay_vals) & (decay_vals > 0)]
    rise_med = float(np.median(rise_vals)) if rise_vals.size else 0.0
    decay_med = float(np.median(decay_vals)) if decay_vals.size else 0.0
    return rise_med, decay_med


def simulate_spectrum(cfg: TimeDoubleSlitConfig) -> tuple[np.ndarray, np.ndarray]:
    """Run the simulator and return (freq_hz, intensity) arrays."""
    from cat_ept_doubleslit.experiments.time_double_slit import simulate_time_double_slit

    out = simulate_time_double_slit(cfg)
    return np.asarray(out["freq_hz"], dtype=float), np.asarray(out["intensity"], dtype=float)


def fit_lambda_entropic_on_calibration(
    f_obs_hz: np.ndarray,
    I_obs: np.ndarray,
    base_cfg_cat: TimeDoubleSlitConfig,
    band_half_width_hz: float,
    lam_grid: np.ndarray,
) -> tuple[float, float]:
    """1D grid search for lambda_ent minimizing L2 loss on bandpass-normalized spectrum."""
    f0 = float(base_cfg_cat.f0_hz)
    f_obs_b, I_obs_b = bandpass_normalize(f_obs_hz, I_obs, f0, band_half_width_hz)

    best_lam = float(lam_grid[0])
    best_loss = float("inf")

    for lam in lam_grid:
        cfg = TimeDoubleSlitConfig(**{**base_cfg_cat.__dict__})
        cfg.lambda_ent_inv_s = float(lam)
        f_sim, I_sim = simulate_spectrum(cfg)
        f_sim_b, I_sim_b = bandpass_normalize(f_sim, I_sim, f0, band_half_width_hz)
        # interpolate sim -> obs band grid
        I_sim_i = np.interp(f_obs_b, f_sim_b, I_sim_b, left=float(I_sim_b[0]), right=float(I_sim_b[-1]))
        loss = float(np.mean((I_sim_i - I_obs_b) ** 2))
        if loss < best_loss:
            best_loss = loss
            best_lam = float(lam)

    return best_lam, best_loss


def write_overlay_plot(
    out_png: Path,
    freq_THz: np.ndarray,
    I_obs: np.ndarray,
    I_std: np.ndarray,
    I_cat: np.ndarray,
    title: str,
) -> None:
    plt.figure(figsize=(8, 4.5))
    plt.plot(freq_THz, I_obs, label="exp")
    plt.plot(freq_THz, I_std, label="standard")
    plt.plot(freq_THz, I_cat, label="CAT/EPT")
    plt.xlabel("Frequency (THz)")
    plt.ylabel("Normalized intensity (bandpass)")
    plt.title(title)
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_png)
    plt.close()


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", required=True)
    ap.add_argument("--paper_tables", default="PAPER_TABLES")
    ap.add_argument("--carrier_THz", type=float, default=230.2)
    ap.add_argument("--band_THz", type=float, default=10.0)
    ap.add_argument("--cal_S_fs", type=float, default=500.0)
    ap.add_argument("--dt_fs", type=float, default=0.2)
    ap.add_argument("--t_window_ps", type=float, default=6.0)
    ap.add_argument("--lam_max", type=float, default=1.5e13, help="max lambda_ent in 1/s")
    ap.add_argument("--lam_steps", type=int, default=60)
    args = ap.parse_args()

    paper_tables = Path(args.paper_tables)
    out_root = paper_tables / "SPECTRAL_PREDICTIONS"
    out_std = out_root / "standard"
    out_cat = out_root / "cat"
    _ensure_dir(out_std)
    _ensure_dir(out_cat)

    # Load observed spectra
    df = load_fig2f_spectra(args.db)
    if df.empty:
        raise SystemExit("No Fig_2f spectra found in DB")

    # Load time-domain observables (Phase 2)
    obs_time_csv = paper_tables / "OBSERVABLES" / "obs_time_domain.csv"
    if not obs_time_csv.exists():
        raise SystemExit(f"Missing {obs_time_csv}. Run Phase 2 first.")
    obs_time = load_time_domain_observables(str(obs_time_csv))
    rise_med, decay_med = infer_rise_decay_medians(obs_time)

    # group by S
    S_vals = np.array(sorted(df["S_fs"].unique()), dtype=float)

    # choose calibration S (nearest)
    S_cal = float(S_vals[np.argmin(np.abs(S_vals - float(args.cal_S_fs)))])

    band_half_width_hz = float(args.band_THz) * 1e12
    f0_hz = float(args.carrier_THz) * 1e12

    # observed calibration spectrum
    dcal = df[df["S_fs"] == S_cal].sort_values("freq_THz")
    f_obs_hz = dcal["freq_THz"].to_numpy(dtype=float) * 1e12
    I_obs = dcal["intensity"].to_numpy(dtype=float)

    # base config (standard)
    base_cfg = TimeDoubleSlitConfig(
        f0_hz=f0_hz,
        separation_s=abs(S_cal) * 1e-15,
        dt_s=float(args.dt_fs) * 1e-15,
        t_window_s=float(args.t_window_ps) * 1e-12,
        use_cat_ept=False,
        cat_mode="coherence",
        alpha_inv_s=0.0,
        beta_inv_s=0.0,
        rise_10_90_s=rise_med,
        decay_tau_s=decay_med,
    )

    # Fit phase polynomial on calibration S
    fit_res = fit_phase_poly_to_spectrum(
        f_obs_hz,
        I_obs,
        base_cfg,
        band_half_width_hz=band_half_width_hz,
        n_rounds=22,
    )
    phase_params = fit_res.best_params

    # Prepare CAT config with phase locked
    base_cfg_cat = TimeDoubleSlitConfig(**{**base_cfg.__dict__})
    base_cfg_cat.use_cat_ept = True
    base_cfg_cat.phase_fn = phase_params.to_phase_fn()

    # Infer lambda0 from dt (CFL anchor) if needed
    from cat_ept_doubleslit.entropic_time import lambda0_from_cfl_time_step

    lam0 = lambda0_from_cfl_time_step(base_cfg_cat.dt_s)
    base_cfg_cat.lambda0_inv_s = lam0

    # Fit lambda_ent on calibration S with phase fixed (grid search)
    lam_grid = np.linspace(0.0, float(args.lam_max), int(args.lam_steps))
    lam_best, lam_loss = fit_lambda_entropic_on_calibration(
        f_obs_hz,
        I_obs,
        base_cfg_cat,
        band_half_width_hz,
        lam_grid,
    )

    # Save fit parameters
    fit_params = {
        "calibration_S_fs": S_cal,
        "carrier_THz": float(args.carrier_THz),
        "band_THz": float(args.band_THz),
        "dt_fs": float(args.dt_fs),
        "t_window_ps": float(args.t_window_ps),
        "rise_med_s": rise_med,
        "decay_med_s": decay_med,
        "phase_poly": {
            "phi0": phase_params.phi0,
            "phi1_rad_per_s": phase_params.phi1_rad_per_s,
            "phi2_rad_per_s2": phase_params.phi2_rad_per_s2,
            "fit_loss": float(fit_res.best_loss),
        },
        "cat": {
            "lambda0_inv_s": float(lam0),
            "lambda_ent_best_inv_s": float(lam_best),
            "lambda_fit_loss": float(lam_loss),
            "lam_grid_max": float(args.lam_max),
            "lam_grid_steps": int(args.lam_steps),
        },
    }
    (out_root / "fit_params.json").write_text(json.dumps(fit_params, indent=2))

    # Evaluate predictions across S
    rows = []

    for S in S_vals:
        dS = df[df["S_fs"] == float(S)].sort_values("freq_THz")
        f_obs = dS["freq_THz"].to_numpy(dtype=float) * 1e12
        I_o = dS["intensity"].to_numpy(dtype=float)

        # normalize obs to band
        f_obs_b, I_obs_b = bandpass_normalize(f_obs, I_o, f0_hz, band_half_width_hz)

        # standard config with locked phase
        cfg_std = TimeDoubleSlitConfig(**{**base_cfg.__dict__})
        cfg_std.separation_s = abs(float(S)) * 1e-15
        cfg_std.phase_fn = phase_params.to_phase_fn()
        cfg_std.use_cat_ept = False

        f_sim_std, I_sim_std = simulate_spectrum(cfg_std)
        f_std_b, I_std_b = bandpass_normalize(f_sim_std, I_sim_std, f0_hz, band_half_width_hz)
        I_std_i = np.interp(f_obs_b, f_std_b, I_std_b, left=float(I_std_b[0]), right=float(I_std_b[-1]))

        # CAT config with locked phase and fitted lambda
        cfg_cat = TimeDoubleSlitConfig(**{**base_cfg_cat.__dict__})
        cfg_cat.separation_s = abs(float(S)) * 1e-15
        cfg_cat.phase_fn = phase_params.to_phase_fn()
        cfg_cat.lambda_ent_inv_s = float(lam_best)
        f_sim_cat, I_sim_cat = simulate_spectrum(cfg_cat)
        f_cat_b, I_cat_b = bandpass_normalize(f_sim_cat, I_sim_cat, f0_hz, band_half_width_hz)
        I_cat_i = np.interp(f_obs_b, f_cat_b, I_cat_b, left=float(I_cat_b[0]), right=float(I_cat_b[-1]))

        rmse_std = _rmse(I_std_i, I_obs_b)
        rmse_cat = _rmse(I_cat_i, I_obs_b)

        rows.append(
            {
                "S_fs": float(S),
                "rmse_standard": rmse_std,
                "rmse_cat": rmse_cat,
                "rmse_improvement": rmse_std - rmse_cat,
            }
        )

        # write per-S csv (bandpass grid)
        per = pd.DataFrame(
            {
                "freq_hz": f_obs_b,
                "freq_THz": f_obs_b / 1e12,
                "I_obs": I_obs_b,
                "I_standard": I_std_i,
                "I_cat": I_cat_i,
            }
        )
        per_name = f"S_{int(round(float(S)))}fs.csv"
        per.to_csv(out_root / per_name, index=False)

        # overlay plot
        title = f"Fig2f spectrum (S={float(S):.0f} fs)"
        write_overlay_plot(out_root / f"S_{int(round(float(S)))}fs.png", per["freq_THz"].to_numpy(), per["I_obs"].to_numpy(), per["I_standard"].to_numpy(), per["I_cat"].to_numpy(), title)

    summary = pd.DataFrame(rows).sort_values("S_fs")
    summary.to_csv(out_root / "summary.csv", index=False)

    # save quick aggregate plot
    plt.figure(figsize=(7.5, 4.5))
    plt.plot(summary["S_fs"], summary["rmse_standard"], label="standard")
    plt.plot(summary["S_fs"], summary["rmse_cat"], label="CAT/EPT")
    plt.xlabel("Slit separation S (fs)")
    plt.ylabel("RMSE (bandpass-normalized spectrum)")
    plt.title("Phase-locked cross-S spectral prediction")
    plt.legend()
    plt.tight_layout()
    plt.savefig(out_root / "rmse_vs_S.png")
    plt.close()

    status = {
        "phase_fit_loss": float(fit_res.best_loss),
        "lambda_fit_loss": float(lam_loss),
        "lambda_ent_best_inv_s": float(lam_best),
        "n_S": int(summary.shape[0]),
        "mean_rmse_standard": float(summary["rmse_standard"].mean()),
        "mean_rmse_cat": float(summary["rmse_cat"].mean()),
    }
    (out_root / "STATUS.txt").write_text(json.dumps(status, indent=2) + "\n")

    # Also copy the key per-model artifacts into model-specific folders for convenience
    for folder, col in [(out_std, "I_standard"), (out_cat, "I_cat")]:
        _ensure_dir(folder)
        # store per-S normalized curves for that model
        for S in S_vals:
            src = out_root / f"S_{int(round(float(S)))}fs.csv"
            d = pd.read_csv(src)
            d2 = d[["freq_THz", "I_obs", col]].rename(columns={col: "I_model"})
            d2.to_csv(folder / src.name, index=False)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
