#!/usr/bin/env python3
"""Validation Targets 5-7 (HIGH): Interferogram, asymmetry, rise time.

Compares CAT/EPT simulation output against Tirole et al. (Nature Physics 2023)
experimental data extracted from the SQLite database.

Outputs:
  - validation/target5_interferogram_*.png + .csv
  - validation/target6_asymmetry.png + .json
  - validation/target7_rise_time_sensitivity.png + .csv
"""

from __future__ import annotations

import json
import sqlite3
import sys
from pathlib import Path

import numpy as np

# Paths
SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
SRC_DIR = REPO_ROOT / "src"
WEBAPP_PY = SCRIPT_DIR.parents[2] / "webapp" / "py"

sys.path.insert(0, str(SRC_DIR))

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import Normalize

from cat_ept_doubleslit.db import load_spectra_by_slit_separation
from cat_ept_doubleslit.models import temporal_double_slit_spectrum
from cat_ept_doubleslit.experiments.time_double_slit import bandpass_normalize

# Constants
CARRIER_THz = 230.2
CARRIER_Hz = CARRIER_THz * 1e12
RISE_FS = 7.0
RISE_S = RISE_FS * 1e-15
HALF_WIDTH_Hz = 15e12
LAMBDA0 = 1e15
# Best-fit rates from Target 1 / Target 4
GAMMA_STD = 5.84e12
LAMBDA_CAT = 6.68e12

DB_PATH = REPO_ROOT / "data_pipeline" / "user_scripts" / "double_slit.sqlite3"


def ensure_dir(p: Path) -> None:
    p.mkdir(parents=True, exist_ok=True)


def rmse(a, b):
    return float(np.sqrt(np.mean((np.asarray(a) - np.asarray(b)) ** 2)))


def pearson_r(a, b):
    a, b = np.asarray(a), np.asarray(b)
    a_m, b_m = a - a.mean(), b - b.mean()
    denom = np.sqrt(np.sum(a_m**2) * np.sum(b_m**2))
    if denom == 0:
        return 0.0
    return float(np.sum(a_m * b_m) / denom)


# =========================================================================
# TARGET 5: Full Interferogram Match (Fig 2f)
# =========================================================================
def target5_interferogram(out_dir: Path) -> dict:
    """Compare simulated 2D interferogram to experimental Fig 2f."""
    print("=" * 60)
    print("TARGET 5: Full Interferogram Match (HIGH)")
    print("=" * 60)

    # Load experimental interferogram
    exp_data = load_spectra_by_slit_separation(str(DB_PATH), ref="Fig_2f")
    separations = sorted(exp_data.keys())
    print(f"  {len(separations)} separations from {separations[0]:.0f} to {separations[-1]:.0f} fs")

    # Build 2D experimental array
    # Use common frequency grid from first separation
    f_ref, _ = exp_data[separations[0]]
    n_freq = len(f_ref)

    exp_matrix = np.zeros((len(separations), n_freq))
    for i, s in enumerate(separations):
        f, I = exp_data[s]
        if len(I) == n_freq:
            exp_matrix[i] = I
        else:
            exp_matrix[i] = np.interp(f_ref, f, I)

    # Normalize
    if exp_matrix.max() > 0:
        exp_matrix /= exp_matrix.max()

    # Simulate 2D interferograms for standard and CAT/EPT
    det_Hz = (f_ref - CARRIER_THz) * 1e12
    sim_std = np.zeros_like(exp_matrix)
    sim_cat = np.zeros_like(exp_matrix)

    for i, s_fs in enumerate(separations):
        sep_s = abs(float(s_fs)) * 1e-15
        if sep_s < 1e-18:
            sep_s = 1e-15  # avoid zero

        I_std, _ = temporal_double_slit_spectrum(
            det_Hz, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="standard", gamma_s_inv=GAMMA_STD
        )
        I_cat, _ = temporal_double_slit_spectrum(
            det_Hz, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="entropic", lambda_ent_s_inv=LAMBDA_CAT,
            lambda0_s_inv=LAMBDA0
        )
        sim_std[i] = I_std
        sim_cat[i] = I_cat

    # Normalize sim arrays
    if sim_std.max() > 0:
        sim_std /= sim_std.max()
    if sim_cat.max() > 0:
        sim_cat /= sim_cat.max()

    # 2D correlation
    corr_std = pearson_r(exp_matrix.ravel(), sim_std.ravel())
    corr_cat = pearson_r(exp_matrix.ravel(), sim_cat.ravel())
    rmse_std = rmse(exp_matrix.ravel(), sim_std.ravel())
    rmse_cat = rmse(exp_matrix.ravel(), sim_cat.ravel())

    results = {
        "n_separations": len(separations),
        "n_frequencies": n_freq,
        "correlation_2d_std": corr_std,
        "correlation_2d_cat": corr_cat,
        "rmse_2d_std": rmse_std,
        "rmse_2d_cat": rmse_cat,
        "separation_range_fs": [float(separations[0]), float(separations[-1])],
    }

    print(f"  2D Correlation — Standard: {corr_std:.4f}, CAT/EPT: {corr_cat:.4f}")
    print(f"  2D RMSE — Standard: {rmse_std:.4f}, CAT/EPT: {rmse_cat:.4f}")

    # Plot 3-panel comparison
    fig, axes = plt.subplots(1, 3, figsize=(20, 6))
    extent = [f_ref[0], f_ref[-1], separations[0], separations[-1]]

    vmin, vmax = 0, 1
    axes[0].imshow(exp_matrix, aspect='auto', origin='lower', extent=extent,
                   cmap='inferno', vmin=vmin, vmax=vmax)
    axes[0].set_title('Experiment (Fig 2f)')
    axes[0].set_xlabel('Frequency (THz)')
    axes[0].set_ylabel('Slit Separation (fs)')

    axes[1].imshow(sim_std, aspect='auto', origin='lower', extent=extent,
                   cmap='inferno', vmin=vmin, vmax=vmax)
    axes[1].set_title(f'Standard (r={corr_std:.3f})')
    axes[1].set_xlabel('Frequency (THz)')

    im = axes[2].imshow(sim_cat, aspect='auto', origin='lower', extent=extent,
                        cmap='inferno', vmin=vmin, vmax=vmax)
    axes[2].set_title(f'CAT/EPT (r={corr_cat:.3f})')
    axes[2].set_xlabel('Frequency (THz)')

    plt.colorbar(im, ax=axes, shrink=0.8, label='Normalized Intensity')
    plt.suptitle('TARGET 5: Full Interferogram Match (Fig 2f)', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target5_interferogram.png", dpi=150)
    plt.close()

    # Difference maps
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    diff_std = exp_matrix - sim_std
    diff_cat = exp_matrix - sim_cat
    vlim = max(np.abs(diff_std).max(), np.abs(diff_cat).max())

    axes[0].imshow(diff_std, aspect='auto', origin='lower', extent=extent,
                   cmap='RdBu_r', vmin=-vlim, vmax=vlim)
    axes[0].set_title(f'Residual: Exp - Standard (RMSE={rmse_std:.4f})')
    axes[0].set_xlabel('Frequency (THz)')
    axes[0].set_ylabel('Slit Separation (fs)')

    im = axes[1].imshow(diff_cat, aspect='auto', origin='lower', extent=extent,
                        cmap='RdBu_r', vmin=-vlim, vmax=vlim)
    axes[1].set_title(f'Residual: Exp - CAT/EPT (RMSE={rmse_cat:.4f})')
    axes[1].set_xlabel('Frequency (THz)')

    plt.colorbar(im, ax=axes, shrink=0.8, label='Residual')
    plt.suptitle('TARGET 5: Interferogram Residuals', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target5_interferogram_residuals.png", dpi=150)
    plt.close()

    return results


# =========================================================================
# TARGET 6: Spectral Extent and Asymmetry
# =========================================================================
def target6_asymmetry(out_dir: Path) -> dict:
    """Paper reports ~10 THz red side, ~4 THz blue side asymmetry."""
    print("\n" + "=" * 60)
    print("TARGET 6: Spectral Extent and Asymmetry (HIGH)")
    print("=" * 60)

    # Load raw Fig_2a spectrum
    con = sqlite3.connect(str(DB_PATH))
    cur = con.cursor()
    cur.execute("SELECT Frequency_THz, Counts_MHz FROM Fig_2a WHERE Series='raw' ORDER BY Frequency_THz")
    rows = cur.fetchall()
    con.close()

    f_exp_THz = np.array([r[0] for r in rows])
    I_exp = np.array([r[1] for r in rows])

    # Carrier frequency
    carrier = CARRIER_THz

    # Determine spectral extent
    I_norm = I_exp / I_exp.max()
    threshold = 0.05  # 5% of peak as noise floor

    above = I_norm > threshold
    f_above = f_exp_THz[above]
    extent_red = carrier - f_above.min()   # Red side (lower frequency)
    extent_blue = f_above.max() - carrier   # Blue side (higher frequency)

    # Paper values
    paper_red = 10.0   # THz
    paper_blue = 4.0   # THz

    # Simulate and check asymmetry
    det_Hz_sim = np.linspace(-15e12, 15e12, 3000)
    I_std, _ = temporal_double_slit_spectrum(
        det_Hz_sim, separation_s=800e-15, slit_rise_s=RISE_S,
        mode="standard", gamma_s_inv=GAMMA_STD
    )
    I_cat, _ = temporal_double_slit_spectrum(
        det_Hz_sim, separation_s=800e-15, slit_rise_s=RISE_S,
        mode="entropic", lambda_ent_s_inv=LAMBDA_CAT, lambda0_s_inv=LAMBDA0
    )

    # The analytic model is symmetric — check if CAT/EPT breaks symmetry
    det_THz_sim = det_Hz_sim / 1e12
    I_std_norm = I_std / I_std.max() if I_std.max() > 0 else I_std
    I_cat_norm = I_cat / I_cat.max() if I_cat.max() > 0 else I_cat

    # Measure sim extent
    above_std = I_std_norm > threshold
    above_cat = I_cat_norm > threshold
    sim_extent_std_red = abs(det_THz_sim[above_std].min()) if any(above_std) else 0
    sim_extent_std_blue = det_THz_sim[above_std].max() if any(above_std) else 0
    sim_extent_cat_red = abs(det_THz_sim[above_cat].min()) if any(above_cat) else 0
    sim_extent_cat_blue = det_THz_sim[above_cat].max() if any(above_cat) else 0

    # Asymmetry fraction: (red - blue) / (red + blue)
    exp_asym = (extent_red - extent_blue) / (extent_red + extent_blue) if (extent_red + extent_blue) > 0 else 0
    std_asym = (sim_extent_std_red - sim_extent_std_blue) / (sim_extent_std_red + sim_extent_std_blue) if (sim_extent_std_red + sim_extent_std_blue) > 0 else 0
    cat_asym = (sim_extent_cat_red - sim_extent_cat_blue) / (sim_extent_cat_red + sim_extent_cat_blue) if (sim_extent_cat_red + sim_extent_cat_blue) > 0 else 0

    results = {
        "experiment": {
            "extent_red_THz": float(extent_red),
            "extent_blue_THz": float(extent_blue),
            "asymmetry_fraction": float(exp_asym),
            "paper_red_THz": paper_red,
            "paper_blue_THz": paper_blue,
        },
        "standard_sim": {
            "extent_red_THz": float(sim_extent_std_red),
            "extent_blue_THz": float(sim_extent_std_blue),
            "asymmetry_fraction": float(std_asym),
        },
        "cat_ept_sim": {
            "extent_red_THz": float(sim_extent_cat_red),
            "extent_blue_THz": float(sim_extent_cat_blue),
            "asymmetry_fraction": float(cat_asym),
        },
        "note": "Analytic Gaussian model is symmetric by construction. Asymmetry in experiment is from material dispersion (ENZ physics)."
    }

    print(f"  Experimental:  red={extent_red:.1f} THz, blue={extent_blue:.1f} THz, asym={exp_asym:.3f}")
    print(f"  Paper reports: red~{paper_red} THz, blue~{paper_blue} THz")
    print(f"  Standard sim:  red={sim_extent_std_red:.1f} THz, blue={sim_extent_std_blue:.1f} THz, asym={std_asym:.3f}")
    print(f"  CAT/EPT sim:   red={sim_extent_cat_red:.1f} THz, blue={sim_extent_cat_blue:.1f} THz, asym={cat_asym:.3f}")
    print(f"  NOTE: Both model spectra are symmetric (Gaussian envelope). Asymmetry requires material dispersion.")

    # Plot
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: raw experimental spectrum with extents marked
    axes[0].plot(f_exp_THz - carrier, I_norm, 'k-', linewidth=1)
    axes[0].axhline(threshold, color='gray', linestyle='--', alpha=0.5, label=f'Threshold {threshold*100}%')
    axes[0].axvline(-extent_red, color='red', linestyle='--', alpha=0.7, label=f'Red extent: {extent_red:.1f} THz')
    axes[0].axvline(extent_blue, color='blue', linestyle='--', alpha=0.7, label=f'Blue extent: {extent_blue:.1f} THz')
    axes[0].set_xlabel('Detuning from carrier (THz)')
    axes[0].set_ylabel('Normalized intensity')
    axes[0].set_title('Experiment (Fig 2a raw)')
    axes[0].legend(fontsize=8)

    # Right: sim comparison
    axes[1].plot(det_THz_sim, I_std_norm, 'b-', label='Standard', alpha=0.7)
    axes[1].plot(det_THz_sim, I_cat_norm, 'r--', label='CAT/EPT', alpha=0.7)
    axes[1].axhline(threshold, color='gray', linestyle='--', alpha=0.5)
    axes[1].set_xlabel('Detuning (THz)')
    axes[1].set_ylabel('Normalized intensity')
    axes[1].set_title('Simulation (symmetric by construction)')
    axes[1].legend(fontsize=8)
    axes[1].set_xlim(-15, 15)

    plt.suptitle('TARGET 6: Spectral Extent & Asymmetry', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target6_asymmetry.png", dpi=150)
    plt.close()

    return results


# =========================================================================
# TARGET 7: Rise Time Sensitivity
# =========================================================================
def target7_rise_time(out_dir: Path) -> dict:
    """Match spectral shape across rise time variants (Extended Fig 3d)."""
    print("\n" + "=" * 60)
    print("TARGET 7: Rise Time Sensitivity (HIGH)")
    print("=" * 60)

    # Extended_Fig_3d has a wide-format table. Parse it.
    con = sqlite3.connect(str(DB_PATH))
    cur = con.cursor()
    cur.execute("SELECT * FROM Extended_Fig_3d")
    rows = cur.fetchall()

    # Get column names
    cur.execute("PRAGMA table_info(Extended_Fig_3d)")
    cols = [r[1] for r in cur.fetchall()]
    con.close()

    # Parse wide-format: first column is "Frequency_-_3.6_fs_rise_time_(THz)"
    # Rows alternate: frequency row, counts row for each rise time
    # Row 0: Counts - 3.6 fs rise time
    # Row 1: Frequency - 7 fs rise time
    # Row 2: Counts - 7 fs rise time
    # Row 3: Frequency - 17 fs rise time
    # Row 4: Counts - 17 fs rise time

    # Parse frequency from column names (excluding first)
    freq_3p6 = np.array([float(c) for c in cols[1:]])

    # Row data
    rise_times = [3.6, 7.0, 17.0]
    exp_spectra = {}

    # First row is "Counts - 3.6 fs rise time (MHz)"
    counts_3p6 = np.array([float(x) for x in rows[0][1:]])
    exp_spectra[3.6] = {"freq_THz": freq_3p6, "counts": counts_3p6}

    # Row 1 = "Frequency - 7 fs rise time (THz)" — frequencies
    freq_7 = np.array([float(x) for x in rows[1][1:]])
    counts_7 = np.array([float(x) for x in rows[2][1:]])
    exp_spectra[7.0] = {"freq_THz": freq_7, "counts": counts_7}

    # Rows 3,4 = 17 fs
    freq_17 = np.array([float(x) for x in rows[3][1:]])
    counts_17 = np.array([float(x) for x in rows[4][1:]])
    exp_spectra[17.0] = {"freq_THz": freq_17, "counts": counts_17}

    results = {}

    fig, axes = plt.subplots(len(rise_times), 2, figsize=(16, 4 * len(rise_times)))

    for i, tau_rise_fs in enumerate(rise_times):
        d = exp_spectra[tau_rise_fs]
        f_THz = d["freq_THz"]
        I_exp = d["counts"]

        # Normalize
        I_exp_n = I_exp / I_exp.max() if I_exp.max() > 0 else I_exp

        # Simulate with this rise time
        det_Hz = (f_THz - CARRIER_THz) * 1e12
        tau_rise_s = tau_rise_fs * 1e-15

        I_std, V_std = temporal_double_slit_spectrum(
            det_Hz, separation_s=800e-15, slit_rise_s=tau_rise_s,
            mode="standard", gamma_s_inv=GAMMA_STD
        )
        I_cat, V_cat = temporal_double_slit_spectrum(
            det_Hz, separation_s=800e-15, slit_rise_s=tau_rise_s,
            mode="entropic", lambda_ent_s_inv=LAMBDA_CAT, lambda0_s_inv=LAMBDA0
        )

        I_std_n = I_std / I_std.max() if I_std.max() > 0 else I_std
        I_cat_n = I_cat / I_cat.max() if I_cat.max() > 0 else I_cat

        r_std = pearson_r(I_exp_n, I_std_n)
        r_cat = pearson_r(I_exp_n, I_cat_n)
        rmse_std = rmse(I_exp_n, I_std_n)
        rmse_cat = rmse(I_exp_n, I_cat_n)

        results[f"rise_{tau_rise_fs}fs"] = {
            "rise_time_fs": tau_rise_fs,
            "rmse_std": rmse_std,
            "rmse_cat": rmse_cat,
            "pearson_r_std": r_std,
            "pearson_r_cat": r_cat,
            "V_std": V_std,
            "V_cat": V_cat,
            "n_freq_points": len(f_THz),
        }

        print(f"  Rise time {tau_rise_fs} fs:")
        print(f"    Standard: RMSE={rmse_std:.4f}, r={r_std:.4f}")
        print(f"    CAT/EPT:  RMSE={rmse_cat:.4f}, r={r_cat:.4f}")

        # Plot
        det_THz = f_THz - CARRIER_THz
        axes[i, 0].plot(det_THz, I_exp_n, 'k-', label='Experiment (model)', linewidth=1)
        axes[i, 0].plot(det_THz, I_std_n, 'b--', label=f'Standard (r={r_std:.3f})', linewidth=1)
        axes[i, 0].plot(det_THz, I_cat_n, 'r-.', label=f'CAT/EPT (r={r_cat:.3f})', linewidth=1)
        axes[i, 0].set_ylabel('Normalized Intensity')
        axes[i, 0].set_title(f'Rise time = {tau_rise_fs} fs')
        axes[i, 0].legend(fontsize=7)
        if i == len(rise_times) - 1:
            axes[i, 0].set_xlabel('Detuning (THz)')

        # Residuals
        axes[i, 1].plot(det_THz, I_exp_n - I_std_n, 'b-', label='Std residual', alpha=0.7)
        axes[i, 1].plot(det_THz, I_exp_n - I_cat_n, 'r-', label='CAT residual', alpha=0.7)
        axes[i, 1].axhline(0, color='k', linewidth=0.5)
        axes[i, 1].set_ylabel('Residual')
        axes[i, 1].set_title(f'Residuals — {tau_rise_fs} fs')
        axes[i, 1].legend(fontsize=7)
        if i == len(rise_times) - 1:
            axes[i, 1].set_xlabel('Detuning (THz)')

    plt.suptitle('TARGET 7: Rise Time Sensitivity (Extended Fig 3d)', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target7_rise_time_sensitivity.png", dpi=150)
    plt.close()

    return results


# =========================================================================
# MAIN
# =========================================================================
def main():
    out_dir = Path(__file__).resolve().parent.parent / "analysis" / "cat_ept_figures" / "validation"
    ensure_dir(out_dir)

    summary = {}
    summary["target5_interferogram"] = target5_interferogram(out_dir)
    summary["target6_asymmetry"] = target6_asymmetry(out_dir)
    summary["target7_rise_time"] = target7_rise_time(out_dir)

    (out_dir / "targets_high_summary.json").write_text(json.dumps(summary, indent=2, default=str))
    print("\n" + "=" * 60)
    print("HIGH priority targets (5-7) complete. Results in:")
    print(f"  {out_dir}")
    print("=" * 60)

    return summary


if __name__ == "__main__":
    main()
