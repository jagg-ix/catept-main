#!/usr/bin/env python3
"""Paper Fig 2e: Oscillation period (fringe spacing) vs slit separation.

Key theoretical prediction: fringe spacing Delta_nu = 1/S.

Runs separations from 200 to 1400 fs in steps of 50 fs for both standard QM
and CAT/EPT (lambda_ent = 1e12 s^-1).

Produces:
  - Main plot: fringe_spacing_THz vs separation_fs with theoretical 1/S overlay
  - Residual plot: deviation from 1/S law
  - CSV with all data

Output directory: outputs/ (relative to this script).
"""

from __future__ import annotations

import csv
import sys
import time
from pathlib import Path

import numpy as np

# ---------------------------------------------------------------------------
# Path setup
# ---------------------------------------------------------------------------
sys.path.insert(0, str(Path(__file__).resolve().parents[4] / "webapp" / "py"))

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

from cat_ept_doubleslit.experiments.time_double_slit import (  # noqa: E402
    TimeDoubleSlitConfig,
    simulate_time_double_slit_band,
)
from cat_ept_doubleslit.observables import build_spectral_observables  # noqa: E402

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SEPARATIONS_FS = np.arange(200, 1401, 50, dtype=float)
HALF_WIDTH_HZ = 15e12
CARRIER_THZ = 230.2
BAND_THZ = 10.0
LAMBDA_ENT_CAT = 1.0e12  # s^-1


def _make_cfg(
    separation_fs: float,
    use_cat_ept: bool,
    lambda_ent_inv_s: float = 0.0,
) -> TimeDoubleSlitConfig:
    return TimeDoubleSlitConfig(
        f0_hz=230.2e12,
        probe_fwhm_field_s=794e-15,
        separation_s=separation_fs * 1e-15,
        alpha_inv_s=0.5e15,
        beta_inv_s=1.0 / 400e-15,
        A=0.5,
        B=0.5,
        C=0.0,
        dt_s=0.2e-15,
        t_window_s=6e-12,
        use_cat_ept=use_cat_ept,
        cat_mode="coherence",
        lambda_ent_inv_s=lambda_ent_inv_s,
    )


def main() -> int:
    outdir = Path(__file__).resolve().parent / "outputs"
    outdir.mkdir(parents=True, exist_ok=True)

    print("=" * 72)
    print("sim_02_fig2e_period_vs_separation.py")
    print("  Fringe spacing vs slit separation (1/S law)")
    print("=" * 72)

    fringe_std_list = []
    fringe_cat_list = []
    theory_list = []
    sep_list = []

    total = len(SEPARATIONS_FS)
    t0 = time.time()

    for idx, sep_fs in enumerate(SEPARATIONS_FS):
        sep_fs = float(sep_fs)
        print(f"  [{idx + 1}/{total}] S = {sep_fs:.0f} fs ...")

        # Standard QM
        cfg_std = _make_cfg(sep_fs, use_cat_ept=False)
        out_std = simulate_time_double_slit_band(cfg_std, half_width_hz=HALF_WIDTH_HZ)
        freq_THz_std = out_std["freq_hz_band"] * 1e-12
        obs_std = build_spectral_observables(
            slit_separation_fs=sep_fs,
            frequency_THz=freq_THz_std,
            intensity=out_std["intensity_band"],
            carrier_THz=CARRIER_THZ,
            band_THz=BAND_THZ,
        )

        # CAT/EPT
        cfg_cat = _make_cfg(sep_fs, use_cat_ept=True, lambda_ent_inv_s=LAMBDA_ENT_CAT)
        out_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=HALF_WIDTH_HZ)
        freq_THz_cat = out_cat["freq_hz_band"] * 1e-12
        obs_cat = build_spectral_observables(
            slit_separation_fs=sep_fs,
            frequency_THz=freq_THz_cat,
            intensity=out_cat["intensity_band"],
            carrier_THz=CARRIER_THZ,
            band_THz=BAND_THZ,
        )

        # Theoretical prediction: Delta_nu (THz) = 1000 / S_fs
        # Because 1/S = 1/(S_fs * 1e-15) Hz = 1e15/S_fs Hz = 1000/S_fs THz
        theory_1_over_S = 1000.0 / sep_fs

        sep_list.append(sep_fs)
        fringe_std_list.append(obs_std.fringe_spacing_THz)
        fringe_cat_list.append(obs_cat.fringe_spacing_THz)
        theory_list.append(theory_1_over_S)

    elapsed = time.time() - t0
    print(f"\n  All {total} separation pairs completed in {elapsed:.1f} s")

    sep_arr = np.array(sep_list)
    fringe_std = np.array(fringe_std_list)
    fringe_cat = np.array(fringe_cat_list)
    theory_arr = np.array(theory_list)

    # ------------------------------------------------------------------
    # Plot 1: Fringe spacing vs separation
    # ------------------------------------------------------------------
    print("  Generating main plot ...")
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), gridspec_kw={"height_ratios": [3, 1]})

    ax1.plot(sep_arr, fringe_std, "o-", color="#1f77b4", ms=4, lw=1.2, label="Standard QM")
    ax1.plot(sep_arr, fringe_cat, "s-", color="#d62728", ms=4, lw=1.2, label=f"CAT/EPT ($\\lambda$={LAMBDA_ENT_CAT/1e12:.1f} THz$^{{-1}}$)")
    ax1.plot(sep_arr, theory_arr, "--", color="black", lw=1.5, alpha=0.7, label="Theory: $\\Delta\\nu = 1/S$")

    ax1.set_ylabel("Fringe spacing (THz)", fontsize=12)
    ax1.set_title("Fig 2e: Oscillation Period vs Slit Separation", fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(sep_arr[0] - 20, sep_arr[-1] + 20)

    # ------------------------------------------------------------------
    # Plot 2: Residuals from 1/S law
    # ------------------------------------------------------------------
    residual_std = fringe_std - theory_arr
    residual_cat = fringe_cat - theory_arr

    ax2.plot(sep_arr, residual_std, "o-", color="#1f77b4", ms=3, lw=1.0, label="Std residual")
    ax2.plot(sep_arr, residual_cat, "s-", color="#d62728", ms=3, lw=1.0, label="CAT/EPT residual")
    ax2.axhline(0, color="black", lw=0.8, ls="--")
    ax2.set_xlabel("Slit separation (fs)", fontsize=12)
    ax2.set_ylabel("Residual (THz)", fontsize=12)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(sep_arr[0] - 20, sep_arr[-1] + 20)

    fig.tight_layout()
    fig_path = outdir / "fig2e_period_vs_separation.png"
    fig.savefig(fig_path, dpi=200)
    plt.close(fig)
    print(f"  Saved: {fig_path}")

    # ------------------------------------------------------------------
    # CSV output
    # ------------------------------------------------------------------
    csv_path = outdir / "fig2e_period_vs_separation.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["separation_fs", "fringe_std", "fringe_cat", "theory_1_over_S"])
        for s, fs, fc, th in zip(sep_arr, fringe_std, fringe_cat, theory_arr):
            writer.writerow([f"{s:.1f}", f"{fs:.6g}", f"{fc:.6g}", f"{th:.6g}"])
    print(f"  Saved: {csv_path}")

    print("  Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
