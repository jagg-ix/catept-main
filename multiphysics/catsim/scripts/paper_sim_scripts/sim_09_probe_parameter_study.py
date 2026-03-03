#!/usr/bin/env python3
"""Probe Parameter Study: sweep probe parameters and show their effect on spectral signatures.

(a) Sweep probe_fwhm_fs from 200 to 2000 fs (steps of 100).
    S=800 fs fixed. Run standard + CAT/EPT (lambda_ent=1e12).
    Extract V, fringe spacing.

(b) Sweep carrier frequency f0_THz from 220 to 240 THz (steps of 1).
    S=800 fs fixed. Run standard + CAT/EPT.
    Extract V, fringe spacing.

(c) Sweep band_half_width_THz from 5 to 25 THz (steps of 2.5).
    Show how observation bandwidth affects extracted V.

Produces:
  - 3-panel figure (one per sweep), each showing V_std vs V_cat
  - Master CSV: param_name, param_value, V_std, V_cat, fringe_std, fringe_cat

Output directory: outputs/ (relative to this script).
"""

from __future__ import annotations

import csv
import sys
import time
from pathlib import Path

import numpy as np

# ---------------------------------------------------------------------------
# Path setup: ensure webapp/py is importable
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
SEPARATION_FS = 800.0
LAMBDA_ENT = 1.0e12
HALF_WIDTH_HZ = 15e12
CARRIER_THZ = 230.2
BAND_THZ = 10.0

# Sweep (a): probe FWHM
FWHM_FS_VALUES = list(range(200, 2001, 100))

# Sweep (b): carrier frequency
F0_THZ_VALUES = list(range(220, 241, 1))

# Sweep (c): band half-width
BAND_HW_THZ_VALUES = [5.0, 7.5, 10.0, 12.5, 15.0, 17.5, 20.0, 22.5, 25.0]


def _make_cfg(
    separation_fs: float = SEPARATION_FS,
    use_cat_ept: bool = False,
    lambda_ent_inv_s: float = 0.0,
    probe_fwhm_fs: float = 794.0,
    f0_thz: float = 230.2,
) -> TimeDoubleSlitConfig:
    """Build a TimeDoubleSlitConfig with configurable probe parameters."""
    return TimeDoubleSlitConfig(
        f0_hz=f0_thz * 1e12,
        probe_fwhm_field_s=probe_fwhm_fs * 1e-15,
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


def _extract_obs(out: dict, carrier_thz: float = CARRIER_THZ, band_thz: float = BAND_THZ):
    """Extract spectral observables from a simulation output."""
    freq_THz = out["freq_hz_band"] * 1e-12
    return build_spectral_observables(
        slit_separation_fs=SEPARATION_FS,
        frequency_THz=freq_THz,
        intensity=out["intensity_band"],
        carrier_THz=carrier_thz,
        band_THz=band_thz,
    )


def main() -> int:
    outdir = Path(__file__).resolve().parent / "outputs"
    outdir.mkdir(parents=True, exist_ok=True)

    print("=" * 72)
    print("sim_09_probe_parameter_study.py")
    print("  Sweep probe parameters: FWHM, carrier freq, band width")
    print("=" * 72)

    csv_rows: list[dict] = []
    t0_global = time.time()

    # ------------------------------------------------------------------
    # (a) Sweep probe FWHM
    # ------------------------------------------------------------------
    print("\n--- (a) Sweeping probe FWHM ---")
    fwhm_V_std = []
    fwhm_V_cat = []
    fwhm_fringe_std = []
    fwhm_fringe_cat = []

    total_a = len(FWHM_FS_VALUES)
    for i, fwhm_fs in enumerate(FWHM_FS_VALUES, 1):
        print(f"  [{i}/{total_a}] probe_fwhm = {fwhm_fs} fs ...")

        # Standard
        cfg_std = _make_cfg(probe_fwhm_fs=float(fwhm_fs), use_cat_ept=False)
        out_std = simulate_time_double_slit_band(cfg_std, half_width_hz=HALF_WIDTH_HZ)
        obs_std = _extract_obs(out_std)

        # CAT/EPT
        cfg_cat = _make_cfg(probe_fwhm_fs=float(fwhm_fs), use_cat_ept=True, lambda_ent_inv_s=LAMBDA_ENT)
        out_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=HALF_WIDTH_HZ)
        obs_cat = _extract_obs(out_cat)

        fwhm_V_std.append(obs_std.visibility_paper)
        fwhm_V_cat.append(obs_cat.visibility_paper)
        fwhm_fringe_std.append(obs_std.fringe_spacing_THz)
        fwhm_fringe_cat.append(obs_cat.fringe_spacing_THz)

        csv_rows.append({
            "param_name": "probe_fwhm_fs",
            "param_value": fwhm_fs,
            "V_std": obs_std.visibility_paper,
            "V_cat": obs_cat.visibility_paper,
            "fringe_std": obs_std.fringe_spacing_THz,
            "fringe_cat": obs_cat.fringe_spacing_THz,
        })

    # ------------------------------------------------------------------
    # (b) Sweep carrier frequency
    # ------------------------------------------------------------------
    print("\n--- (b) Sweeping carrier frequency f0 ---")
    f0_V_std = []
    f0_V_cat = []
    f0_fringe_std = []
    f0_fringe_cat = []

    total_b = len(F0_THZ_VALUES)
    for i, f0_thz in enumerate(F0_THZ_VALUES, 1):
        print(f"  [{i}/{total_b}] f0 = {f0_thz} THz ...")

        cfg_std = _make_cfg(f0_thz=float(f0_thz), use_cat_ept=False)
        out_std = simulate_time_double_slit_band(cfg_std, half_width_hz=HALF_WIDTH_HZ)
        obs_std = _extract_obs(out_std, carrier_thz=float(f0_thz))

        cfg_cat = _make_cfg(f0_thz=float(f0_thz), use_cat_ept=True, lambda_ent_inv_s=LAMBDA_ENT)
        out_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=HALF_WIDTH_HZ)
        obs_cat = _extract_obs(out_cat, carrier_thz=float(f0_thz))

        f0_V_std.append(obs_std.visibility_paper)
        f0_V_cat.append(obs_cat.visibility_paper)
        f0_fringe_std.append(obs_std.fringe_spacing_THz)
        f0_fringe_cat.append(obs_cat.fringe_spacing_THz)

        csv_rows.append({
            "param_name": "f0_THz",
            "param_value": f0_thz,
            "V_std": obs_std.visibility_paper,
            "V_cat": obs_cat.visibility_paper,
            "fringe_std": obs_std.fringe_spacing_THz,
            "fringe_cat": obs_cat.fringe_spacing_THz,
        })

    # ------------------------------------------------------------------
    # (c) Sweep band half-width
    # ------------------------------------------------------------------
    print("\n--- (c) Sweeping band half-width ---")
    bw_V_std = []
    bw_V_cat = []
    bw_fringe_std = []
    bw_fringe_cat = []

    # For this sweep, run one standard and one CAT simulation, then
    # re-extract observables at each bandwidth.
    print("  Running standard simulation ...")
    cfg_std = _make_cfg(use_cat_ept=False)
    out_std = simulate_time_double_slit_band(cfg_std, half_width_hz=25e12)

    print("  Running CAT/EPT simulation ...")
    cfg_cat = _make_cfg(use_cat_ept=True, lambda_ent_inv_s=LAMBDA_ENT)
    out_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=25e12)

    total_c = len(BAND_HW_THZ_VALUES)
    for i, bw_thz in enumerate(BAND_HW_THZ_VALUES, 1):
        print(f"  [{i}/{total_c}] band_half_width = {bw_thz} THz ...")

        obs_std_bw = _extract_obs(out_std, band_thz=bw_thz)
        obs_cat_bw = _extract_obs(out_cat, band_thz=bw_thz)

        bw_V_std.append(obs_std_bw.visibility_paper)
        bw_V_cat.append(obs_cat_bw.visibility_paper)
        bw_fringe_std.append(obs_std_bw.fringe_spacing_THz)
        bw_fringe_cat.append(obs_cat_bw.fringe_spacing_THz)

        csv_rows.append({
            "param_name": "band_half_width_THz",
            "param_value": bw_thz,
            "V_std": obs_std_bw.visibility_paper,
            "V_cat": obs_cat_bw.visibility_paper,
            "fringe_std": obs_std_bw.fringe_spacing_THz,
            "fringe_cat": obs_cat_bw.fringe_spacing_THz,
        })

    elapsed = time.time() - t0_global
    print(f"\n  All sweeps completed in {elapsed:.1f} s")

    # ------------------------------------------------------------------
    # Plot: 3 panels
    # ------------------------------------------------------------------
    print("  Generating 3-panel figure ...")
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel (a): V vs probe FWHM
    ax = axes[0]
    ax.plot(FWHM_FS_VALUES, fwhm_V_std, "ko-", markersize=4, lw=1.2, label="V_std")
    ax.plot(FWHM_FS_VALUES, fwhm_V_cat, "rs-", markersize=4, lw=1.2, label="V_cat")
    ax.set_xlabel("Probe FWHM (fs)", fontsize=11)
    ax.set_ylabel("Visibility (paper)", fontsize=11)
    ax.set_title("(a) Probe FWHM sweep", fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel (b): V vs carrier frequency
    ax = axes[1]
    ax.plot(F0_THZ_VALUES, f0_V_std, "ko-", markersize=4, lw=1.2, label="V_std")
    ax.plot(F0_THZ_VALUES, f0_V_cat, "rs-", markersize=4, lw=1.2, label="V_cat")
    ax.set_xlabel("Carrier frequency f0 (THz)", fontsize=11)
    ax.set_ylabel("Visibility (paper)", fontsize=11)
    ax.set_title("(b) Carrier frequency sweep", fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel (c): V vs band half-width
    ax = axes[2]
    ax.plot(BAND_HW_THZ_VALUES, bw_V_std, "ko-", markersize=4, lw=1.2, label="V_std")
    ax.plot(BAND_HW_THZ_VALUES, bw_V_cat, "rs-", markersize=4, lw=1.2, label="V_cat")
    ax.set_xlabel("Band half-width (THz)", fontsize=11)
    ax.set_ylabel("Visibility (paper)", fontsize=11)
    ax.set_title("(c) Observation bandwidth sweep", fontsize=12)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle(
        f"Probe Parameter Study (S={SEPARATION_FS:.0f} fs, lambda_ent={LAMBDA_ENT:.1e} s^-1)",
        fontsize=13,
        y=1.02,
    )
    fig.tight_layout()
    fig_path = outdir / "probe_parameter_study.png"
    fig.savefig(fig_path, dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {fig_path}")

    # ------------------------------------------------------------------
    # CSV output
    # ------------------------------------------------------------------
    csv_path = outdir / "probe_parameter_study.csv"
    fieldnames = ["param_name", "param_value", "V_std", "V_cat", "fringe_std", "fringe_cat"]
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for row in csv_rows:
            writer.writerow(row)
    print(f"  Saved: {csv_path}")

    print("  Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
