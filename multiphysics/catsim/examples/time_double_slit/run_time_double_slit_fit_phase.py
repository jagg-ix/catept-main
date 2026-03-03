"""Fit a simple time-refraction phase model to an observed spectrum CSV.

Input CSV format:
  f_THz,I
or
  f_Hz,I

This script fits the baseline (no CAT/EPT) model *or* a CAT/EPT-on variant,
depending on flags, then saves an overlay plot and prints the best-fit params.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

from cat_ept_doubleslit.experiments.time_double_slit import TimeDoubleSlitConfig, bandpass_normalize
from cat_ept_doubleslit.experiments.time_double_slit_fit import PhasePolyParams, fit_phase_poly_to_spectrum


def _load_csv(path: Path) -> tuple[np.ndarray, np.ndarray]:
    data = np.genfromtxt(path, delimiter=",", names=True)
    cols = list(data.dtype.names)
    fcol = cols[0]
    icol = cols[1]
    f = np.asarray(data[fcol], dtype=float)
    I = np.asarray(data[icol], dtype=float)
    # heuristic: THz if values look like 100-1000
    if np.nanmax(np.abs(f)) < 1e6:
        f = f * 1e12
    return f, I


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", type=str, required=True, help="Observed spectrum CSV (freq,intensity)")
    ap.add_argument("--out", type=str, default="out_fit_phase")

    # base physics knobs (should match experiment approximately)
    ap.add_argument("--f0_thz", type=float, default=230.2)
    ap.add_argument("--separation_fs", type=float, default=800.0)
    ap.add_argument("--alpha_inv_fs", type=float, default=0.5)
    ap.add_argument("--beta_inv_fs", type=float, default=1.0 / 400.0)
    ap.add_argument("--dt_fs", type=float, default=0.2)
    ap.add_argument("--window_ps", type=float, default=6.0)
    ap.add_argument("--band_half_thz", type=float, default=15.0)

    # CAT/EPT knobs (optional)
    ap.add_argument("--cat", action="store_true")
    ap.add_argument("--lambda0_inv_fs", type=float, default=0.0)
    ap.add_argument("--kappa", type=float, default=0.0)
    ap.add_argument("--lambda_floor_inv_fs", type=float, default=0.0)
    ap.add_argument("--gamma", type=float, default=0.0)

    # fit controls
    ap.add_argument("--rounds", type=int, default=25)
    args = ap.parse_args()

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    f_obs, I_obs = _load_csv(Path(args.csv))

    base_cfg = TimeDoubleSlitConfig(
        f0_hz=args.f0_thz * 1e12,
        separation_s=args.separation_fs * 1e-15,
        alpha_inv_s=args.alpha_inv_fs * 1e15,
        beta_inv_s=args.beta_inv_fs * 1e15,
        dt_s=args.dt_fs * 1e-15,
        t_window_s=args.window_ps * 1e-12,
        use_cat_ept=bool(args.cat),
        lambda0_inv_s=args.lambda0_inv_fs * 1e15,
        lambda_kappa=float(args.kappa),
        lambda_floor_inv_s=args.lambda_floor_inv_fs * 1e15,
        gamma_entropic=float(args.gamma),
    )

    res = fit_phase_poly_to_spectrum(
        f_obs_hz=f_obs,
        I_obs=I_obs,
        base_cfg=base_cfg,
        band_half_width_hz=args.band_half_thz * 1e12,
        init=PhasePolyParams(0.0, 0.0, 0.0),
        n_rounds=int(args.rounds),
    )

    print("Best-fit PhasePolyParams:")
    print(f"  phi0 = {res.best_params.phi0:.6g} rad")
    print(f"  phi1 = {res.best_params.phi1_rad_per_s:.6g} rad/s")
    print(f"  phi2 = {res.best_params.phi2_rad_per_s2:.6g} rad/s^2")
    print(f"Best loss: {res.best_loss:.6g}")

    # Re-simulate with best params and plot overlay in band
    cfg_best = TimeDoubleSlitConfig(**{**base_cfg.__dict__})
    cfg_best.phase_fn = res.best_params.to_phase_fn()
    from cat_ept_doubleslit.experiments.time_double_slit import simulate_time_double_slit

    sim = simulate_time_double_slit(cfg_best)
    f0 = float(cfg_best.f0_hz)
    f_obs_b, I_obs_b = bandpass_normalize(f_obs, I_obs, f0, args.band_half_thz * 1e12)
    f_sim_b, I_sim_b = bandpass_normalize(sim["freq_hz"], sim["intensity"], f0, args.band_half_thz * 1e12)

    plt.figure()
    plt.plot(f_obs_b / 1e12, I_obs_b, label="observed")
    plt.plot(f_sim_b / 1e12, I_sim_b, label="fit")
    plt.xlabel("Frequency (THz)")
    plt.ylabel("Normalized intensity")
    plt.title("Time double-slit: phase fit" + (" (CAT/EPT-on)" if args.cat else ""))
    plt.legend()
    plt.tight_layout()
    plt.savefig(outdir / "fit_overlay.png", dpi=180)
    plt.close()

    np.savetxt(
        outdir / "fit_params.txt",
        np.array([[res.best_params.phi0, res.best_params.phi1_rad_per_s, res.best_params.phi2_rad_per_s2, res.best_loss]]),
        header="phi0_rad,phi1_rad_per_s,phi2_rad_per_s2,loss",
        delimiter=",",
        comments="",
    )


if __name__ == "__main__":
    main()
