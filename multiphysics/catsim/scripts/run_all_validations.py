#!/usr/bin/env python3
"""Run all 10 validation targets and produce a unified summary.

Usage:
    cd multiphysics/catsim
    PYTHONPATH=src python scripts/run_all_validations.py
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
SRC_DIR = REPO_ROOT / "src"
WEBAPP_PY = SCRIPT_DIR.parents[2] / "webapp" / "py"

sys.path.insert(0, str(SRC_DIR))
sys.path.insert(0, str(WEBAPP_PY))

from validate_targets_critical import main as run_critical
from validate_targets_high import main as run_high
from validate_targets_medium import main as run_medium


def main():
    out_dir = REPO_ROOT / "analysis" / "cat_ept_figures" / "validation"
    out_dir.mkdir(parents=True, exist_ok=True)

    t0 = time.time()
    print("=" * 70)
    print("  FULL VALIDATION SUITE: CAT/EPT vs Tirole Experimental Data")
    print("=" * 70)

    # Run all target groups
    print("\n>>> Running CRITICAL targets (1-4)...")
    critical = run_critical()

    print("\n>>> Running HIGH targets (5-7)...")
    high = run_high()

    print("\n>>> Running MEDIUM targets (8-10)...")
    medium = run_medium()

    elapsed = time.time() - t0

    # Merge into unified summary
    full_summary = {
        "metadata": {
            "description": "CAT/EPT validation against Tirole et al. (Nature Physics 2023)",
            "targets_run": 10,
            "elapsed_seconds": round(elapsed, 1),
            "data_source": "data_pipeline/user_scripts/double_slit.sqlite3",
            "model": "temporal_double_slit_spectrum (Gaussian slit, analytic Fourier)",
            "carrier_THz": 230.2,
            "rise_time_fs": 7.0,
            "lambda0_inv_s": 1e15,
        },
        "critical": critical,
        "high": high,
        "medium": medium,
    }

    # Write unified summary
    (out_dir / "VALIDATION_SUMMARY.json").write_text(
        json.dumps(full_summary, indent=2, default=str)
    )

    # Print scorecard
    print("\n" + "=" * 70)
    print("  VALIDATION SCORECARD")
    print("=" * 70)

    def score(metric_std, metric_cat, lower_is_better=True):
        """Return winner and delta."""
        if lower_is_better:
            winner = "CAT/EPT" if metric_cat < metric_std else "Standard"
            delta = metric_std - metric_cat
        else:
            winner = "CAT/EPT" if metric_cat > metric_std else "Standard"
            delta = metric_cat - metric_std
        return winner, delta

    # Target 1
    for s_tag in ["S800fs", "S500fs"]:
        t1 = critical.get("target1_spectral_shape", {}).get(s_tag, {})
        if t1:
            w, d = score(t1["rmse_std"], t1["rmse_cat"])
            print(f"  T1 Spectral ({s_tag}): RMSE std={t1['rmse_std']:.4f} cat={t1['rmse_cat']:.4f} -> {w} (delta={d:.4f})")

    # Target 2
    t2 = critical.get("target2_fringe_spacing", {})
    if t2:
        print(f"  T2 Fringe spacing: mean_rel_err std={t2['mean_rel_error_std']:.4f} cat={t2['mean_rel_error_cat']:.4f}")

    # Target 3
    for s_tag in ["S800fs", "S500fs"]:
        t3 = critical.get("target3_visibility", {}).get(s_tag, {})
        if t3:
            print(f"  T3 Visibility ({s_tag}): V_exp={t3['V_exp_paper']:.4f} V_std={t3['V_sim_std']:.4f} V_cat={t3['V_sim_cat']:.4f}")

    # Target 4
    for tag in ["cal500_pred800", "cal800_pred500"]:
        t4 = critical.get("target4_calibrate_predict", {}).get(tag, {})
        if t4:
            w, d = score(t4["rmse_pred_std"], t4["rmse_pred_cat"])
            print(f"  T4 {tag}: RMSE_pred std={t4['rmse_pred_std']:.4f} cat={t4['rmse_pred_cat']:.4f} -> {w} ({t4['prediction_improvement_pct']:.1f}%)")

    # Target 5
    t5 = high.get("target5_interferogram", {})
    if t5:
        print(f"  T5 Interferogram 2D: corr std={t5['correlation_2d_std']:.4f} cat={t5['correlation_2d_cat']:.4f}")

    # Target 6
    t6 = high.get("target6_asymmetry", {})
    if t6:
        exp_a = t6.get("experiment", {})
        print(f"  T6 Asymmetry: exp red={exp_a.get('extent_red_THz', '?'):.1f} blue={exp_a.get('extent_blue_THz', '?'):.1f} THz (both models symmetric)")

    # Target 7
    t7 = high.get("target7_rise_time", {})
    if t7:
        for rt_key in sorted(t7.keys()):
            rt = t7[rt_key]
            print(f"  T7 Rise {rt['rise_time_fs']}fs: r std={rt['pearson_r_std']:.4f} cat={rt['pearson_r_cat']:.4f}")

    # Target 8
    t8 = medium.get("target8_time_domain", {})
    if t8:
        print(f"  T8 Time-domain: r std={t8['pearson_r_std']:.4f} cat={t8['pearson_r_cat']:.4f}")

    # Target 9
    t9 = medium.get("target9_visibility_decay", {})
    if t9:
        print(f"  T9 V(S) decay: fit lambda={t9['exp_fit_lambda_inv_s']:.3e} 1/s, model gamma={t9['model_gamma_std']:.3e}")

    # Target 10
    t10 = medium.get("target10_second_peak", {})
    if t10:
        print(f"  T10 Second peak: sim={t10['sim_ratio_percent']:.2f}% paper={t10['paper_ratio_percent']:.2f}%")

    print(f"\n  Elapsed: {elapsed:.1f}s")
    print(f"  Results: {out_dir}/VALIDATION_SUMMARY.json")
    print("=" * 70)


if __name__ == "__main__":
    main()
