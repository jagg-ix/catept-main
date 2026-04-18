#!/usr/bin/env python3
"""Validation Targets 1-4 (CRITICAL): Spectral shape, fringe spacing, visibility, calibrate-predict.

Compares CAT/EPT simulation output against Tirole et al. (Nature Physics 2023)
experimental data extracted from the SQLite database.

Outputs:
  - validation/target1_spectral_shape_*.png + .csv
  - validation/target2_fringe_vs_separation.png + .csv
  - validation/target3_visibility.json
  - validation/target4_calibrate_predict_*.png + .csv + .json
"""

from __future__ import annotations

import json
import sqlite3
import sys
from dataclasses import asdict
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

from cat_ept_doubleslit.db import load_spectra, load_spectra_by_slit_separation
from cat_ept_doubleslit.fit import fit_rate_grid_temporal
from cat_ept_doubleslit.models import temporal_double_slit_spectrum
from cat_ept_doubleslit.experiments.time_double_slit import bandpass_normalize

# ---- Constants from Tirole paper ----
CARRIER_THz = 230.2
CARRIER_Hz = CARRIER_THz * 1e12
RISE_FS = 7.0
RISE_S = RISE_FS * 1e-15
HALF_WIDTH_Hz = 15e12
LAMBDA0 = 1e15

DB_PATH = REPO_ROOT / "data_pipeline" / "user_scripts" / "double_slit.sqlite3"
OBS_DB = REPO_ROOT / "PAPER_TABLES" / "OBSERVABLES" / "results.sqlite3"


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
# TARGET 1: Spectral Shape Match
# =========================================================================
def target1_spectral_shape(out_dir: Path) -> dict:
    """Overlay simulated spectrum on experimental spectrum at S=500 fs and S=800 fs."""
    print("=" * 60)
    print("TARGET 1: Spectral Shape Match (CRITICAL)")
    print("=" * 60)

    results = {}
    for fig_ref, S_fs in [("Fig_2a", 800), ("Fig_2b", 500)]:
        # Load experimental data
        f_exp_THz, I_exp_raw = load_spectra(str(DB_PATH), ref=fig_ref)
        f_exp_Hz = f_exp_THz * 1e12

        # Bandpass normalize
        f_bp_Hz, I_bp = bandpass_normalize(f_exp_Hz, I_exp_raw, CARRIER_Hz, HALF_WIDTH_Hz)
        det_Hz = f_bp_Hz - CARRIER_Hz
        det_THz = det_Hz / 1e12

        # Sort
        order = np.argsort(det_Hz)
        det_Hz, I_bp, det_THz = det_Hz[order], I_bp[order], det_THz[order]

        # Grid search for best-fit rates
        rate_grid = np.linspace(0, 5e14, 600)
        sep_s = S_fs * 1e-15

        res_std = fit_rate_grid_temporal(
            det_Hz, I_bp, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="standard", rate_grid=rate_grid, fit_affine=False
        )
        res_cat = fit_rate_grid_temporal(
            det_Hz, I_bp, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="entropic", rate_grid=rate_grid, fit_affine=False,
            lambda0_s_inv=LAMBDA0
        )

        # Compute model spectra at best-fit rates
        I_std, V_std = temporal_double_slit_spectrum(
            det_Hz, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="standard", gamma_s_inv=res_std.rate_value
        )
        I_cat, V_cat = temporal_double_slit_spectrum(
            det_Hz, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="entropic", lambda_ent_s_inv=res_cat.rate_value,
            lambda0_s_inv=LAMBDA0
        )

        rmse_std = rmse(I_bp, I_std)
        rmse_cat = rmse(I_bp, I_cat)
        r_std = pearson_r(I_bp, I_std)
        r_cat = pearson_r(I_bp, I_cat)

        results[f"S{S_fs}fs"] = {
            "figure_ref": fig_ref,
            "S_fs": S_fs,
            "std_rate": res_std.rate_value,
            "cat_rate": res_cat.rate_value,
            "rmse_std": rmse_std,
            "rmse_cat": rmse_cat,
            "pearson_r_std": r_std,
            "pearson_r_cat": r_cat,
            "V_std": V_std,
            "V_cat": V_cat,
            "n_points": len(I_bp),
        }

        print(f"  {fig_ref} (S={S_fs} fs):")
        print(f"    Standard: gamma={res_std.rate_value:.3e} 1/s, RMSE={rmse_std:.4f}, r={r_std:.4f}")
        print(f"    CAT/EPT:  lambda={res_cat.rate_value:.3e} 1/s, RMSE={rmse_cat:.4f}, r={r_cat:.4f}")

        # Plot overlay
        fig, axes = plt.subplots(1, 3, figsize=(18, 5))

        axes[0].plot(det_THz, I_bp, 'k-', label='Data', linewidth=1)
        axes[0].plot(det_THz, I_std, 'b--', label=f'Standard (RMSE={rmse_std:.3f})', linewidth=1)
        axes[0].plot(det_THz, I_cat, 'r-.', label=f'CAT/EPT (RMSE={rmse_cat:.3f})', linewidth=1)
        axes[0].set_xlabel('Detuning (THz)')
        axes[0].set_ylabel('Normalized Intensity')
        axes[0].set_title(f'{fig_ref}: S={S_fs} fs — Full Overlay')
        axes[0].legend(fontsize=8)

        # Residuals
        axes[1].plot(det_THz, I_bp - I_std, 'b-', label='Standard residual', alpha=0.7)
        axes[1].plot(det_THz, I_bp - I_cat, 'r-', label='CAT/EPT residual', alpha=0.7)
        axes[1].axhline(0, color='k', linewidth=0.5)
        axes[1].set_xlabel('Detuning (THz)')
        axes[1].set_ylabel('Residual')
        axes[1].set_title('Residuals')
        axes[1].legend(fontsize=8)

        # Zoom into central fringes
        mask = np.abs(det_THz) < 5
        if np.any(mask):
            axes[2].plot(det_THz[mask], I_bp[mask], 'k-', label='Data', linewidth=1.5)
            axes[2].plot(det_THz[mask], I_std[mask], 'b--', label='Standard', linewidth=1)
            axes[2].plot(det_THz[mask], I_cat[mask], 'r-.', label='CAT/EPT', linewidth=1)
            axes[2].set_xlabel('Detuning (THz)')
            axes[2].set_ylabel('Normalized Intensity')
            axes[2].set_title('Central Fringes (|det| < 5 THz)')
            axes[2].legend(fontsize=8)

        plt.suptitle(f'TARGET 1: Spectral Shape — {fig_ref} (S={S_fs} fs)', fontsize=14)
        plt.tight_layout()
        plt.savefig(out_dir / f"target1_spectral_shape_{fig_ref}.png", dpi=150)
        plt.close()

        # Save CSV
        arr = np.column_stack([det_THz, I_bp, I_std, I_cat])
        header = "detuning_THz,data,standard_model,cat_ept_model"
        np.savetxt(out_dir / f"target1_spectral_{fig_ref}.csv", arr,
                   delimiter=",", header=header, comments="")

    return results


# =========================================================================
# TARGET 2: Fringe Spacing vs Separation (1/S law)
# =========================================================================
def target2_fringe_vs_separation(out_dir: Path) -> dict:
    """Verify 1/S fringe spacing law from simulation matches experimental Fig 2e."""
    print("\n" + "=" * 60)
    print("TARGET 2: Fringe Spacing vs Separation (CRITICAL)")
    print("=" * 60)

    # Load experimental Fig_2e data
    con = sqlite3.connect(str(DB_PATH))
    cur = con.cursor()
    cur.execute("SELECT Slit_separation_fs, Oscillation_THz FROM Fig_2e WHERE Series='raw' ORDER BY Slit_separation_fs")
    rows = cur.fetchall()
    con.close()

    S_exp_fs = np.array([r[0] for r in rows])
    period_exp_THz = np.array([r[1] for r in rows])

    # Only use positive separations for meaningful physics
    pos_mask = S_exp_fs > 50
    S_pos = S_exp_fs[pos_mask]
    period_pos = period_exp_THz[pos_mask]

    # Simulate at each experimental separation
    period_sim_std = []
    period_sim_cat = []

    for S_fs in S_pos:
        sep_s = float(abs(S_fs)) * 1e-15
        # Theoretical fringe period: delta_f = 1/S
        theoretical_period = 1.0 / (sep_s * 1e12)  # THz

        # Simulate and extract fringe spacing via FFT
        det_Hz = np.linspace(-10e12, 10e12, 2000)
        I_std, _ = temporal_double_slit_spectrum(
            det_Hz, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="standard", gamma_s_inv=5.84e12
        )
        I_cat, _ = temporal_double_slit_spectrum(
            det_Hz, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="entropic", lambda_ent_s_inv=6.68e12,
            lambda0_s_inv=LAMBDA0
        )

        # Extract fringe spacing from FFT of oscillations
        def extract_period(I, det):
            # Remove envelope by high-pass
            from numpy.fft import fft, fftfreq
            df = det[1] - det[0]
            n = len(det)
            F = fft(I - np.mean(I))
            freqs = fftfreq(n, d=df)
            power = np.abs(F[:n//2])
            freqs_pos = freqs[:n//2]
            # Find dominant peak (skip DC)
            start_idx = max(3, int(n * 0.005))
            peak_idx = start_idx + np.argmax(power[start_idx:])
            if freqs_pos[peak_idx] > 0:
                period = 1.0 / freqs_pos[peak_idx] / 1e12  # THz
            else:
                period = theoretical_period
            return period

        p_std = extract_period(I_std, det_Hz)
        p_cat = extract_period(I_cat, det_Hz)
        period_sim_std.append(p_std)
        period_sim_cat.append(p_cat)

    period_sim_std = np.array(period_sim_std)
    period_sim_cat = np.array(period_sim_cat)

    # Also compute theoretical 1/S
    period_theory = 1.0 / (S_pos * 1e-15) / 1e12  # THz

    # Compute relative errors
    rel_err_std = np.abs(period_sim_std - period_pos) / np.maximum(period_pos, 1e-10)
    rel_err_cat = np.abs(period_sim_cat - period_pos) / np.maximum(period_pos, 1e-10)
    rel_err_theory = np.abs(period_theory - period_pos) / np.maximum(period_pos, 1e-10)

    results = {
        "n_points": len(S_pos),
        "S_range_fs": [float(S_pos.min()), float(S_pos.max())],
        "mean_rel_error_std": float(np.mean(rel_err_std)),
        "mean_rel_error_cat": float(np.mean(rel_err_cat)),
        "mean_rel_error_theory_1_over_S": float(np.mean(rel_err_theory)),
        "rmse_period_std": float(rmse(period_sim_std, period_pos)),
        "rmse_period_cat": float(rmse(period_sim_cat, period_pos)),
    }

    print(f"  {len(S_pos)} positive-separation points")
    print(f"  Mean relative error (std):     {results['mean_rel_error_std']:.4f}")
    print(f"  Mean relative error (CAT/EPT): {results['mean_rel_error_cat']:.4f}")
    print(f"  Mean relative error (1/S law): {results['mean_rel_error_theory_1_over_S']:.4f}")

    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    axes[0].scatter(S_pos, period_pos, c='k', s=30, label='Experiment (raw)', zorder=5)
    axes[0].plot(S_pos, period_sim_std, 'b-o', markersize=4, label='Standard sim', alpha=0.7)
    axes[0].plot(S_pos, period_sim_cat, 'r-s', markersize=4, label='CAT/EPT sim', alpha=0.7)
    S_dense = np.linspace(S_pos.min(), S_pos.max(), 200)
    axes[0].plot(S_dense, 1.0 / (S_dense * 1e-15) / 1e12, 'g--', label='Theory 1/S', alpha=0.5)
    axes[0].set_xlabel('Slit Separation (fs)')
    axes[0].set_ylabel('Fringe Period (THz)')
    axes[0].set_title('Fringe Period vs Separation')
    axes[0].legend(fontsize=8)

    # Log-log
    axes[1].loglog(S_pos, period_pos, 'ko', markersize=6, label='Experiment')
    axes[1].loglog(S_pos, period_sim_std, 'b^', markersize=5, label='Standard')
    axes[1].loglog(S_pos, period_sim_cat, 'rs', markersize=5, label='CAT/EPT')
    axes[1].loglog(S_dense, 1.0 / (S_dense * 1e-15) / 1e12, 'g--', label='1/S', alpha=0.5)
    axes[1].set_xlabel('Slit Separation (fs)')
    axes[1].set_ylabel('Fringe Period (THz)')
    axes[1].set_title('Log-Log: 1/S Law Check')
    axes[1].legend(fontsize=8)

    # Relative error
    axes[2].bar(np.arange(len(S_pos)) - 0.15, rel_err_std, 0.3, label='Standard', alpha=0.7, color='b')
    axes[2].bar(np.arange(len(S_pos)) + 0.15, rel_err_cat, 0.3, label='CAT/EPT', alpha=0.7, color='r')
    axes[2].set_xlabel('Point index')
    axes[2].set_ylabel('|sim - exp| / exp')
    axes[2].set_title('Relative Error per Point')
    axes[2].legend(fontsize=8)

    plt.suptitle('TARGET 2: Fringe Spacing vs Separation (1/S Law)', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target2_fringe_vs_separation.png", dpi=150)
    plt.close()

    # CSV
    arr = np.column_stack([S_pos, period_pos, period_sim_std, period_sim_cat, period_theory])
    header = "S_fs,period_exp_THz,period_std_THz,period_cat_THz,period_theory_THz"
    np.savetxt(out_dir / "target2_fringe_vs_separation.csv", arr,
               delimiter=",", header=header, comments="")

    return results


# =========================================================================
# TARGET 3: Visibility at S=500 and S=800 fs
# =========================================================================
def target3_visibility(out_dir: Path) -> dict:
    """Compare simulated visibility to experimentally-extracted visibility."""
    print("\n" + "=" * 60)
    print("TARGET 3: Visibility at S=500 fs and S=800 fs (CRITICAL)")
    print("=" * 60)

    # Load experimental observables
    con = sqlite3.connect(str(OBS_DB))
    cur = con.cursor()
    cur.execute("""SELECT figure_ref, slit_separation_fs, fringe_spacing_THz,
                   visibility_paper, visibility_robust
                   FROM obs_spectral WHERE figure_ref IN ('Fig_2a', 'Fig_2b')
                   AND series='raw'""")
    exp_obs = {}
    for r in cur.fetchall():
        exp_obs[r[0]] = {
            "S_fs": r[1], "fringe_THz": r[2],
            "V_paper": r[3], "V_robust": r[4]
        }
    con.close()

    results = {}
    rate_grid = np.linspace(0, 5e14, 600)

    # Scan lambda_ent values to see visibility sensitivity
    lambda_scan = np.linspace(0, 2e13, 50)

    for fig_ref, S_fs in [("Fig_2a", 800), ("Fig_2b", 500)]:
        sep_s = S_fs * 1e-15

        # Load and normalize data
        f_THz, I_raw = load_spectra(str(DB_PATH), ref=fig_ref)
        f_Hz = f_THz * 1e12
        f_bp, I_bp = bandpass_normalize(f_Hz, I_raw, CARRIER_Hz, HALF_WIDTH_Hz)
        det_Hz = f_bp - CARRIER_Hz

        # Fit best rates
        res_std = fit_rate_grid_temporal(
            det_Hz, I_bp, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="standard", rate_grid=rate_grid, fit_affine=False
        )
        res_cat = fit_rate_grid_temporal(
            det_Hz, I_bp, separation_s=sep_s, slit_rise_s=RISE_S,
            mode="entropic", rate_grid=rate_grid, fit_affine=False,
            lambda0_s_inv=LAMBDA0
        )

        # Extract visibility from simulation
        V_sim_std = res_std.predicted_visibility
        V_sim_cat = res_cat.predicted_visibility

        # Experimental values
        exp = exp_obs.get(fig_ref, {})
        V_exp_paper = exp.get("V_paper", float("nan"))
        V_exp_robust = exp.get("V_robust", float("nan"))

        # Visibility vs lambda scan
        V_lambda = []
        for lam in lambda_scan:
            _, V = temporal_double_slit_spectrum(
                np.array([0.0]), separation_s=sep_s, slit_rise_s=RISE_S,
                mode="entropic", lambda_ent_s_inv=lam, lambda0_s_inv=LAMBDA0
            )
            V_lambda.append(V)
        V_lambda = np.array(V_lambda)

        results[f"S{S_fs}fs"] = {
            "S_fs": S_fs,
            "V_sim_std": V_sim_std,
            "V_sim_cat": V_sim_cat,
            "V_exp_paper": V_exp_paper,
            "V_exp_robust": V_exp_robust,
            "std_rate": res_std.rate_value,
            "cat_rate": res_cat.rate_value,
            "delta_V_std_vs_paper": abs(V_sim_std - V_exp_paper) if V_sim_std else None,
            "delta_V_cat_vs_paper": abs(V_sim_cat - V_exp_paper) if V_sim_cat else None,
        }

        print(f"  {fig_ref} (S={S_fs} fs):")
        print(f"    Experiment:  V_paper={V_exp_paper:.4f}, V_robust={V_exp_robust:.4f}")
        print(f"    Standard:    V_sim={V_sim_std:.4f}  (gamma={res_std.rate_value:.3e})")
        print(f"    CAT/EPT:     V_sim={V_sim_cat:.4f}  (lambda={res_cat.rate_value:.3e})")

    # Plot visibility comparison
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    for i, (fig_ref, S_fs) in enumerate([("Fig_2a", 800), ("Fig_2b", 500)]):
        r = results[f"S{S_fs}fs"]
        categories = ['V_paper\n(exp)', 'V_robust\n(exp)', 'Standard\n(sim)', 'CAT/EPT\n(sim)']
        values = [r["V_exp_paper"], r["V_exp_robust"], r["V_sim_std"], r["V_sim_cat"]]
        colors = ['gray', 'gray', 'blue', 'red']

        bars = axes[i].bar(categories, values, color=colors, alpha=0.7)
        for bar, val in zip(bars, values):
            axes[i].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
                        f'{val:.4f}', ha='center', fontsize=9)
        axes[i].set_ylabel('Visibility')
        axes[i].set_title(f'{fig_ref}: S={S_fs} fs')
        axes[i].set_ylim(0, 1.1)

    plt.suptitle('TARGET 3: Visibility Comparison — Experiment vs Simulation', fontsize=14)
    plt.tight_layout()
    plt.savefig(out_dir / "target3_visibility.png", dpi=150)
    plt.close()

    return results


# =========================================================================
# TARGET 4: Calibrate-then-Predict Protocol
# =========================================================================
def target4_calibrate_predict(out_dir: Path) -> dict:
    """Fit rate on one S, predict the other S without refitting."""
    print("\n" + "=" * 60)
    print("TARGET 4: Calibrate-then-Predict (CRITICAL)")
    print("=" * 60)

    rate_grid = np.linspace(0, 5e14, 600)
    results = {}

    for cal_S, pred_S, cal_ref, pred_ref in [
        (500, 800, "Fig_2b", "Fig_2a"),
        (800, 500, "Fig_2a", "Fig_2b"),
    ]:
        # Load calibration data
        f_cal_THz, I_cal_raw = load_spectra(str(DB_PATH), ref=cal_ref)
        f_cal_Hz = f_cal_THz * 1e12
        f_cal_bp, I_cal = bandpass_normalize(f_cal_Hz, I_cal_raw, CARRIER_Hz, HALF_WIDTH_Hz)
        det_cal = f_cal_bp - CARRIER_Hz
        order = np.argsort(det_cal)
        det_cal, I_cal = det_cal[order], I_cal[order]

        # Load prediction data
        f_pred_THz, I_pred_raw = load_spectra(str(DB_PATH), ref=pred_ref)
        f_pred_Hz = f_pred_THz * 1e12
        f_pred_bp, I_pred = bandpass_normalize(f_pred_Hz, I_pred_raw, CARRIER_Hz, HALF_WIDTH_Hz)
        det_pred = f_pred_bp - CARRIER_Hz
        order = np.argsort(det_pred)
        det_pred, I_pred = det_pred[order], I_pred[order]

        cal_sep_s = cal_S * 1e-15
        pred_sep_s = pred_S * 1e-15

        # Fit on calibration set
        fit_std = fit_rate_grid_temporal(
            det_cal, I_cal, separation_s=cal_sep_s, slit_rise_s=RISE_S,
            mode="standard", rate_grid=rate_grid, fit_affine=False
        )
        fit_cat = fit_rate_grid_temporal(
            det_cal, I_cal, separation_s=cal_sep_s, slit_rise_s=RISE_S,
            mode="entropic", rate_grid=rate_grid, fit_affine=False,
            lambda0_s_inv=LAMBDA0
        )

        # Predict (NO refit)
        I_cal_std, _ = temporal_double_slit_spectrum(
            det_cal, separation_s=cal_sep_s, slit_rise_s=RISE_S,
            mode="standard", gamma_s_inv=fit_std.rate_value
        )
        I_cal_cat, _ = temporal_double_slit_spectrum(
            det_cal, separation_s=cal_sep_s, slit_rise_s=RISE_S,
            mode="entropic", lambda_ent_s_inv=fit_cat.rate_value,
            lambda0_s_inv=LAMBDA0
        )

        I_pred_std, V_pred_std = temporal_double_slit_spectrum(
            det_pred, separation_s=pred_sep_s, slit_rise_s=RISE_S,
            mode="standard", gamma_s_inv=fit_std.rate_value
        )
        I_pred_cat, V_pred_cat = temporal_double_slit_spectrum(
            det_pred, separation_s=pred_sep_s, slit_rise_s=RISE_S,
            mode="entropic", lambda_ent_s_inv=fit_cat.rate_value,
            lambda0_s_inv=LAMBDA0
        )

        rmse_cal_std = rmse(I_cal, I_cal_std)
        rmse_cal_cat = rmse(I_cal, I_cal_cat)
        rmse_pred_std = rmse(I_pred, I_pred_std)
        rmse_pred_cat = rmse(I_pred, I_pred_cat)

        tag = f"cal{cal_S}_pred{pred_S}"
        results[tag] = {
            "calibration_S_fs": cal_S,
            "prediction_S_fs": pred_S,
            "std_rate": fit_std.rate_value,
            "cat_rate": fit_cat.rate_value,
            "rmse_cal_std": rmse_cal_std,
            "rmse_cal_cat": rmse_cal_cat,
            "rmse_pred_std": rmse_pred_std,
            "rmse_pred_cat": rmse_pred_cat,
            "V_pred_std": V_pred_std,
            "V_pred_cat": V_pred_cat,
            "prediction_improvement_pct": (rmse_pred_std - rmse_pred_cat) / rmse_pred_std * 100,
        }

        print(f"\n  Calibrate on S={cal_S} fs ({cal_ref}), predict S={pred_S} fs ({pred_ref}):")
        print(f"    Standard: gamma={fit_std.rate_value:.3e}, RMSE_cal={rmse_cal_std:.4f}, RMSE_pred={rmse_pred_std:.4f}")
        print(f"    CAT/EPT:  lambda={fit_cat.rate_value:.3e}, RMSE_cal={rmse_cal_cat:.4f}, RMSE_pred={rmse_pred_cat:.4f}")
        print(f"    Prediction improvement: {results[tag]['prediction_improvement_pct']:.2f}%")

        # Plot calibration + prediction
        fig, axes = plt.subplots(2, 2, figsize=(16, 10))

        # Calibration overlays
        det_cal_THz = det_cal / 1e12
        axes[0, 0].plot(det_cal_THz, I_cal, 'k-', label='Data', linewidth=1)
        axes[0, 0].plot(det_cal_THz, I_cal_std, 'b--', label=f'Standard (RMSE={rmse_cal_std:.3f})')
        axes[0, 0].set_title(f'Calibration S={cal_S} fs — Standard')
        axes[0, 0].legend(fontsize=8)
        axes[0, 0].set_xlabel('Detuning (THz)')

        axes[0, 1].plot(det_cal_THz, I_cal, 'k-', label='Data', linewidth=1)
        axes[0, 1].plot(det_cal_THz, I_cal_cat, 'r--', label=f'CAT/EPT (RMSE={rmse_cal_cat:.3f})')
        axes[0, 1].set_title(f'Calibration S={cal_S} fs — CAT/EPT')
        axes[0, 1].legend(fontsize=8)
        axes[0, 1].set_xlabel('Detuning (THz)')

        # Prediction overlays
        det_pred_THz = det_pred / 1e12
        axes[1, 0].plot(det_pred_THz, I_pred, 'k-', label='Data', linewidth=1)
        axes[1, 0].plot(det_pred_THz, I_pred_std, 'b--', label=f'Standard (RMSE={rmse_pred_std:.3f})')
        axes[1, 0].set_title(f'Prediction S={pred_S} fs — Standard (NO REFIT)')
        axes[1, 0].legend(fontsize=8)
        axes[1, 0].set_xlabel('Detuning (THz)')

        axes[1, 1].plot(det_pred_THz, I_pred, 'k-', label='Data', linewidth=1)
        axes[1, 1].plot(det_pred_THz, I_pred_cat, 'r--', label=f'CAT/EPT (RMSE={rmse_pred_cat:.3f})')
        axes[1, 1].set_title(f'Prediction S={pred_S} fs — CAT/EPT (NO REFIT)')
        axes[1, 1].legend(fontsize=8)
        axes[1, 1].set_xlabel('Detuning (THz)')

        plt.suptitle(f'TARGET 4: Calibrate ({cal_S} fs) → Predict ({pred_S} fs)', fontsize=14)
        plt.tight_layout()
        plt.savefig(out_dir / f"target4_{tag}.png", dpi=150)
        plt.close()

        # CSV
        np.savetxt(out_dir / f"target4_{tag}_cal.csv",
                   np.column_stack([det_cal_THz, I_cal, I_cal_std, I_cal_cat]),
                   delimiter=",", header="detuning_THz,data,std_model,cat_model", comments="")
        np.savetxt(out_dir / f"target4_{tag}_pred.csv",
                   np.column_stack([det_pred_THz, I_pred, I_pred_std, I_pred_cat]),
                   delimiter=",", header="detuning_THz,data,std_model,cat_model", comments="")

    return results


# =========================================================================
# MAIN
# =========================================================================
def main():
    out_dir = Path(__file__).resolve().parent.parent / "analysis" / "cat_ept_figures" / "validation"
    ensure_dir(out_dir)

    summary = {}
    summary["target1_spectral_shape"] = target1_spectral_shape(out_dir)
    summary["target2_fringe_spacing"] = target2_fringe_vs_separation(out_dir)
    summary["target3_visibility"] = target3_visibility(out_dir)
    summary["target4_calibrate_predict"] = target4_calibrate_predict(out_dir)

    # Save summary
    (out_dir / "targets_critical_summary.json").write_text(json.dumps(summary, indent=2, default=str))
    print("\n" + "=" * 60)
    print("CRITICAL targets (1-4) complete. Results in:")
    print(f"  {out_dir}")
    print("=" * 60)

    return summary


if __name__ == "__main__":
    main()
