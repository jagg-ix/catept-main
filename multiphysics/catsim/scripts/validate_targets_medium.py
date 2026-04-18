#!/usr/bin/env python3
"""Validation Targets 8-10 (MEDIUM): Time-domain slit shape, visibility decay law, second peak.

Compares CAT/EPT simulation output against Tirole et al. (Nature Physics 2023)
experimental data extracted from the SQLite database.

Outputs:
  - validation/target8_time_domain_slit.png + .csv
  - validation/target9_visibility_decay_law.png + .csv + .json
  - validation/target10_second_peak.png + .json
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

from cat_ept_doubleslit.db import load_spectra_by_slit_separation
from cat_ept_doubleslit.models import temporal_double_slit_spectrum
from cat_ept_doubleslit.experiments.time_double_slit import (
    TimeDoubleSlitConfig,
    simulate_time_double_slit,
)

# Constants
CARRIER_THz = 230.2
CARRIER_Hz = CARRIER_THz * 1e12
RISE_FS = 7.0
RISE_S = RISE_FS * 1e-15
HALF_WIDTH_Hz = 15e12
LAMBDA0 = 1e15
GAMMA_STD = 5.84e12
LAMBDA_CAT = 6.68e12
SECOND_PEAK_PERCENT = 0.93  # from paper

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
# TARGET 8: Time-Domain Slit Shape (Extended Fig 1a)
# =========================================================================
def target8_time_domain(out_dir: Path) -> dict:
    """Match |r(t)| trace shape from Extended Fig 1a."""
    print("=" * 60)
    print("TARGET 8: Time-Domain Slit Shape (MEDIUM)")
    print("=" * 60)

    # Load experimental data from Extended_Fig_1a
    con = sqlite3.connect(str(DB_PATH))
    cur = con.cursor()
    cur.execute("SELECT delay_fs, reflectivity FROM Extended_Fig_1a WHERE series='actual' ORDER BY delay_fs")
    rows = cur.fetchall()
    con.close()

    t_exp_fs = np.array([r[0] for r in rows])
    r_exp = np.array([r[1] for r in rows])

    print(f"  Loaded {len(t_exp_fs)} points from Extended_Fig_1a 'actual' series")
    print(f"  Time range: {t_exp_fs.min():.1f} to {t_exp_fs.max():.1f} fs")

    # Simulate single slit r(t) using the time_double_slit simulator
    # For a single slit, we set separation to something very small
    cfg_std = TimeDoubleSlitConfig(
        separation_s=800e-15,
        use_cat_ept=False,
    )
    res_std = simulate_time_double_slit(cfg_std)

    cfg_cat = TimeDoubleSlitConfig(
        separation_s=800e-15,
        use_cat_ept=True,
        cat_mode="coherence",
        lambda_ent_inv_s=1e12,
    )
    res_cat = simulate_time_double_slit(cfg_cat)

    t_sim_s = res_std["t_s"]
    t_sim_fs = t_sim_s * 1e15
    r_sim_std = np.abs(res_std["r_t"])
    r_sim_cat = np.abs(res_cat["r_t"])

    # Normalize all to [0,1]
    r_exp_n = r_exp / r_exp.max() if r_exp.max() > 0 else r_exp
    r_sim_std_n = r_sim_std / r_sim_std.max() if r_sim_std.max() > 0 else r_sim_std
    r_sim_cat_n = r_sim_cat / r_sim_cat.max() if r_sim_cat.max() > 0 else r_sim_cat

    # Interpolate simulation onto experimental time grid for comparison
    r_std_interp = np.interp(t_exp_fs, t_sim_fs, r_sim_std_n, left=0, right=0)
    r_cat_interp = np.interp(t_exp_fs, t_sim_fs, r_sim_cat_n, left=0, right=0)

    r_std_corr = pearson_r(r_exp_n, r_std_interp)
    r_cat_corr = pearson_r(r_exp_n, r_cat_interp)
    rmse_std = rmse(r_exp_n, r_std_interp)
    rmse_cat = rmse(r_exp_n, r_cat_interp)

    results = {
        "n_exp_points": len(t_exp_fs),
        "t_range_fs": [float(t_exp_fs.min()), float(t_exp_fs.max())],
        "pearson_r_std": r_std_corr,
        "pearson_r_cat": r_cat_corr,
        "rmse_std": rmse_std,
        "rmse_cat": rmse_cat,
    }

    print(f"  Standard: r={r_std_corr:.4f}, RMSE={rmse_std:.4f}")
    print(f"  CAT/EPT:  r={r_cat_corr:.4f}, RMSE={rmse_cat:.4f}")

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    axes[0].plot(t_exp_fs, r_exp_n, 'k-', linewidth=1, label='Experiment')
    axes[0].set_xlabel('Delay (fs)')
    axes[0].set_ylabel('|r(t)| (normalized)')
    axes[0].set_title('Experimental Single-Slit r(t)')
    axes[0].legend()

    axes[1].plot(t_sim_fs, r_sim_std_n, 'b-', linewidth=1, label='Standard sim')
    axes[1].plot(t_sim_fs, r_sim_cat_n, 'r--', linewidth=1, label='CAT/EPT sim')
    axes[1].set_xlabel('Time (fs)')
    axes[1].set_ylabel('|r(t)| (normalized)')
    axes[1].set_title('Simulated Slit Function')
    axes[1].legend()

    # Overlay on same grid
    axes[2].plot(t_exp_fs, r_exp_n, 'k-', linewidth=1.5, label='Experiment')
    axes[2].plot(t_exp_fs, r_std_interp, 'b--', linewidth=1, label=f'Standard (r={r_std_corr:.3f})')
    axes[2].plot(t_exp_fs, r_cat_interp, 'r-.', linewidth=1, label=f'CAT/EPT (r={r_cat_corr:.3f})')
    axes[2].set_xlabel('Delay (fs)')
    axes[2].set_ylabel('|r(t)| (normalized)')
    axes[2].set_title('Overlay Comparison')
    axes[2].legend(fontsize=8)

    plt.suptitle('TARGET 8: Time-Domain Slit Shape (Extended Fig 1a)', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target8_time_domain_slit.png", dpi=150)
    plt.close()

    # CSV
    arr = np.column_stack([t_exp_fs, r_exp_n, r_std_interp, r_cat_interp])
    header = "delay_fs,r_exp_norm,r_std_interp,r_cat_interp"
    np.savetxt(out_dir / "target8_time_domain_slit.csv", arr,
               delimiter=",", header=header, comments="")

    return results


# =========================================================================
# TARGET 9: Visibility Decay Law from Fig 2f
# =========================================================================
def target9_visibility_decay(out_dir: Path) -> dict:
    """Extract visibility at each separation from Fig_2f interferogram, fit V(S)=exp(-lambda*S)."""
    print("\n" + "=" * 60)
    print("TARGET 9: Visibility Decay Law (MEDIUM)")
    print("=" * 60)

    # Load interferogram data
    exp_data = load_spectra_by_slit_separation(str(DB_PATH), ref="Fig_2f")
    separations = sorted(exp_data.keys())
    pos_seps = [s for s in separations if s > 50]

    print(f"  {len(pos_seps)} positive separations (of {len(separations)} total)")

    # Extract visibility at each separation
    def extract_visibility(f_THz, I):
        """Simple fringe visibility: (I_max - I_min) / (I_max + I_min)."""
        if len(I) < 10:
            return 0.0
        I_smooth = np.convolve(I, np.ones(5)/5, mode='same')
        I_max = I_smooth.max()
        I_min = I_smooth.min()
        if I_max + I_min == 0:
            return 0.0
        return float((I_max - I_min) / (I_max + I_min))

    V_exp = []
    for s in pos_seps:
        f, I = exp_data[s]
        V_exp.append(extract_visibility(f, I))
    V_exp = np.array(V_exp)
    S_fs = np.array(pos_seps)
    S_s = S_fs * 1e-15

    # Simulate V(S) for both models using analytic formula
    V_std_arr = []
    V_cat_arr = []
    for s_fs in pos_seps:
        sep_s = s_fs * 1e-15
        _, V_std = temporal_double_slit_spectrum(
            np.array([0.0]), separation_s=sep_s, slit_rise_s=RISE_S,
            mode="standard", gamma_s_inv=GAMMA_STD
        )
        _, V_cat = temporal_double_slit_spectrum(
            np.array([0.0]), separation_s=sep_s, slit_rise_s=RISE_S,
            mode="entropic", lambda_ent_s_inv=LAMBDA_CAT, lambda0_s_inv=LAMBDA0
        )
        V_std_arr.append(V_std)
        V_cat_arr.append(V_cat)
    V_std_arr = np.array(V_std_arr)
    V_cat_arr = np.array(V_cat_arr)

    # Fit exponential decay to experimental visibility: V = A * exp(-lambda * S)
    # Use log-linear fit: log(V) = log(A) - lambda * S
    valid = V_exp > 0.01  # avoid log(0)
    if np.sum(valid) > 2:
        log_V = np.log(V_exp[valid])
        S_valid = S_s[valid]
        # linear fit: log_V = a + b * S
        A_fit = np.column_stack([np.ones_like(S_valid), S_valid])
        coeffs = np.linalg.lstsq(A_fit, log_V, rcond=None)[0]
        A_exp = np.exp(coeffs[0])
        lambda_exp = -coeffs[1]

        # Compute fitted curve
        S_dense = np.linspace(S_fs.min(), S_fs.max(), 200)
        V_fit = A_exp * np.exp(-lambda_exp * S_dense * 1e-15)

        # Residuals
        V_fit_at_data = A_exp * np.exp(-lambda_exp * S_s[valid])
        fit_residual = float(np.sqrt(np.mean((V_exp[valid] - V_fit_at_data)**2)))
    else:
        A_exp = 1.0
        lambda_exp = 0.0
        fit_residual = float('nan')
        S_dense = np.linspace(S_fs.min(), S_fs.max(), 200)
        V_fit = np.ones_like(S_dense)

    results = {
        "n_separations": len(pos_seps),
        "exp_fit_A": float(A_exp),
        "exp_fit_lambda_inv_s": float(lambda_exp),
        "exp_fit_lambda_inv_fs": float(lambda_exp * 1e-15),
        "exp_fit_residual_rmse": fit_residual,
        "model_gamma_std": GAMMA_STD,
        "model_lambda_cat": LAMBDA_CAT,
        "V_exp_at_S800": float(V_exp[np.argmin(np.abs(S_fs - 800))]) if len(S_fs) > 0 else None,
        "V_std_at_S800": float(V_std_arr[np.argmin(np.abs(S_fs - 800))]) if len(S_fs) > 0 else None,
        "V_cat_at_S800": float(V_cat_arr[np.argmin(np.abs(S_fs - 800))]) if len(S_fs) > 0 else None,
    }

    print(f"  Exponential fit: V = {A_exp:.4f} * exp(-{lambda_exp:.3e} * S)")
    print(f"  Fit residual RMSE: {fit_residual:.4f}")
    print(f"  Model gamma (std): {GAMMA_STD:.3e}, lambda (CAT): {LAMBDA_CAT:.3e}")

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # V vs S
    axes[0].scatter(S_fs, V_exp, c='k', s=20, label='Exp (from Fig 2f)', zorder=5)
    axes[0].plot(S_dense, V_fit, 'g--', label=f'Exp fit: A={A_exp:.2f}, $\\lambda$={lambda_exp:.2e}', alpha=0.7)
    axes[0].plot(S_fs, V_std_arr, 'b-o', markersize=4, label='Standard model', alpha=0.7)
    axes[0].plot(S_fs, V_cat_arr, 'r-s', markersize=4, label='CAT/EPT model', alpha=0.7)
    axes[0].set_xlabel('Slit Separation (fs)')
    axes[0].set_ylabel('Visibility')
    axes[0].set_title('Visibility vs Separation')
    axes[0].legend(fontsize=7)

    # Log scale
    axes[1].semilogy(S_fs, np.maximum(V_exp, 1e-6), 'ko', markersize=5, label='Experiment')
    axes[1].semilogy(S_dense, np.maximum(V_fit, 1e-6), 'g--', alpha=0.7, label='Exp fit')
    axes[1].semilogy(S_fs, np.maximum(V_std_arr, 1e-6), 'b-^', markersize=4, label='Standard', alpha=0.7)
    axes[1].semilogy(S_fs, np.maximum(V_cat_arr, 1e-6), 'r-s', markersize=4, label='CAT/EPT', alpha=0.7)
    axes[1].set_xlabel('Slit Separation (fs)')
    axes[1].set_ylabel('log(Visibility)')
    axes[1].set_title('Log Visibility (Exponential Decay Check)')
    axes[1].legend(fontsize=7)

    # Residual from exponential fit
    if np.sum(valid) > 2:
        residuals = V_exp[valid] - V_fit_at_data
        axes[2].bar(S_fs[valid], residuals, width=30, color='gray', alpha=0.7)
        axes[2].axhline(0, color='k', linewidth=0.5)
        axes[2].set_xlabel('Slit Separation (fs)')
        axes[2].set_ylabel('Residual (V_exp - V_fit)')
        axes[2].set_title('Exponential Fit Residuals')

    plt.suptitle('TARGET 9: Visibility Decay Law V(S) = A*exp(-lambda*S)', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target9_visibility_decay_law.png", dpi=150)
    plt.close()

    # CSV
    arr = np.column_stack([S_fs, V_exp, V_std_arr, V_cat_arr])
    header = "S_fs,V_exp,V_std,V_cat"
    np.savetxt(out_dir / "target9_visibility_decay.csv", arr,
               delimiter=",", header=header, comments="")

    return results


# =========================================================================
# TARGET 10: Second Peak Amplitude
# =========================================================================
def target10_second_peak(out_dir: Path) -> dict:
    """Paper reports second slit peak is 0.93% relative to first."""
    print("\n" + "=" * 60)
    print("TARGET 10: Second Peak Amplitude (MEDIUM)")
    print("=" * 60)

    # The paper's slit model has two features:
    # - Primary reflectivity transition (fast rise, slow decay)
    # - Second, smaller peak at ~0.93% amplitude
    # Check if our logistic slit model captures this

    # Simulate with our slit model
    cfg = TimeDoubleSlitConfig(
        separation_s=800e-15,
        use_cat_ept=False,
    )
    res = simulate_time_double_slit(cfg)

    t_s = res["t_s"]
    t_fs = t_s * 1e15
    r_t = res["r_t"]

    # The slit model: r(t) = A * f_ss(t - S/2) + B * f_ss(t + S/2)
    # where f_ss is a logistic (or sigmoidal) slit function
    # A is the first slit amplitude, B is the second slit amplitude
    # B/A should be ~0.93%

    # Load model parameters
    # From the config defaults
    # alpha = cfg.alpha_inv_s  (rise rate)
    # beta = cfg.beta_inv_s   (decay rate)

    # Measure the two peaks in the r(t) trace
    r_abs = np.abs(r_t)
    r_norm = r_abs / r_abs.max() if r_abs.max() > 0 else r_abs

    # Find the two slit peaks (local maxima)
    # Simple approach: split time domain at midpoint and find max in each half
    mid_idx = len(t_fs) // 2
    # Alternatively use the separation to locate slits
    S_fs = 800.0
    slit1_center = -S_fs / 2
    slit2_center = S_fs / 2

    # Window around each slit
    window_fs = 200  # fs window
    mask1 = np.abs(t_fs - slit1_center) < window_fs
    mask2 = np.abs(t_fs - slit2_center) < window_fs

    if np.any(mask1) and np.any(mask2):
        peak1 = r_abs[mask1].max()
        peak2 = r_abs[mask2].max()
        ratio_percent = (peak2 / peak1) * 100 if peak1 > 0 else float('nan')
    else:
        peak1, peak2, ratio_percent = 0, 0, float('nan')

    # Paper's expected ratio
    paper_ratio = SECOND_PEAK_PERCENT

    results = {
        "peak1_amplitude": float(peak1),
        "peak2_amplitude": float(peak2),
        "sim_ratio_percent": float(ratio_percent),
        "paper_ratio_percent": float(paper_ratio),
        "delta_percent": float(abs(ratio_percent - paper_ratio)),
        "note": "The default model has equal slit amplitudes (A=B=1). "
                "The 0.93% second peak requires setting B/A explicitly. "
                "This target checks whether the model CAN reproduce this via config."
    }

    print(f"  Sim peak1 = {peak1:.6f}, peak2 = {peak2:.6f}")
    print(f"  Sim ratio = {ratio_percent:.2f}% vs paper = {paper_ratio}%")
    print(f"  NOTE: Default model has equal amplitudes. Paper's 0.93% requires explicit B/A config.")

    # Also simulate with a modified second-peak amplitude
    # Check if the config supports this
    # The TimeDoubleSlitConfig has no explicit B/A ratio parameter in the current code,
    # so we note this as a model limitation.

    # Also load experimental Extended_Fig_1a to see if we can detect the two peaks
    con = sqlite3.connect(str(DB_PATH))
    cur = con.cursor()
    cur.execute("SELECT delay_fs, reflectivity FROM Extended_Fig_1a WHERE series='actual' ORDER BY delay_fs")
    rows = cur.fetchall()
    con.close()

    t_exp_fs = np.array([r[0] for r in rows])
    r_exp = np.array([r[1] for r in rows])
    r_exp_norm = r_exp / r_exp.max() if r_exp.max() > 0 else r_exp

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    axes[0].plot(t_fs, r_norm, 'b-', linewidth=1, label='Simulation |r(t)|')
    axes[0].axvline(slit1_center, color='gray', linestyle='--', alpha=0.5, label=f'Slit 1 center ({slit1_center} fs)')
    axes[0].axvline(slit2_center, color='gray', linestyle='--', alpha=0.5, label=f'Slit 2 center ({slit2_center} fs)')
    axes[0].set_xlabel('Time (fs)')
    axes[0].set_ylabel('|r(t)| (normalized)')
    axes[0].set_title('Simulated Slit Function')
    axes[0].legend(fontsize=7)

    axes[1].plot(t_exp_fs, r_exp_norm, 'k-', linewidth=1, label='Experiment')
    axes[1].set_xlabel('Delay (fs)')
    axes[1].set_ylabel('|r(t)| (normalized)')
    axes[1].set_title('Experimental Single-Slit (Ext Fig 1a)')
    axes[1].legend()

    # Comparison of peaks
    categories = ['Sim Peak 1', 'Sim Peak 2', f'Paper ratio\n({paper_ratio}%)']
    vals = [100.0, ratio_percent, paper_ratio]
    colors = ['blue', 'red', 'gray']
    axes[2].bar(categories, vals, color=colors, alpha=0.7)
    for j, (cat, val) in enumerate(zip(categories, vals)):
        axes[2].text(j, val + 1, f'{val:.2f}%', ha='center', fontsize=9)
    axes[2].set_ylabel('Relative Amplitude (%)')
    axes[2].set_title('Second Peak Amplitude')
    axes[2].set_ylim(0, max(vals) * 1.2)

    plt.suptitle('TARGET 10: Second Peak Amplitude (Paper: 0.93%)', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target10_second_peak.png", dpi=150)
    plt.close()

    return results


# =========================================================================
# MAIN
# =========================================================================
def main():
    out_dir = Path(__file__).resolve().parent.parent / "analysis" / "cat_ept_figures" / "validation"
    ensure_dir(out_dir)

    summary = {}
    summary["target8_time_domain"] = target8_time_domain(out_dir)
    summary["target9_visibility_decay"] = target9_visibility_decay(out_dir)
    summary["target10_second_peak"] = target10_second_peak(out_dir)

    (out_dir / "targets_medium_summary.json").write_text(json.dumps(summary, indent=2, default=str))
    print("\n" + "=" * 60)
    print("MEDIUM priority targets (8-10) complete. Results in:")
    print(f"  {out_dir}")
    print("=" * 60)

    return summary


if __name__ == "__main__":
    main()
