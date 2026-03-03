#!/usr/bin/env python3
"""Paper's central prediction: V(S) = exp(-lambda_ent * S).

Runs separations from 100 to 2000 fs in steps of 25 fs for multiple
lambda_ent values.  Extracts visibility_paper and visibility_robust,
and compares against the theoretical exponential decay.

Produces:
  - Main plot: V(S) curves for each lambda_ent with theoretical overlays
  - Residual plot: actual V - theoretical V
  - Log(V) vs S plot (should be linear if model is correct)
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
SEPARATIONS_FS = np.arange(100, 2001, 25, dtype=float)
LAMBDA_ENT_VALUES = [0.0, 0.1e12, 0.5e12, 1.0e12, 1.5e12, 2.0e12]
HALF_WIDTH_HZ = 15e12
CARRIER_THZ = 230.2
BAND_THZ = 10.0


def _make_cfg(
    separation_fs: float,
    lambda_ent_inv_s: float,
) -> TimeDoubleSlitConfig:
    """Build a CAT/EPT-on config. lambda_ent=0 gives coherent (no decoherence) limit."""
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
        use_cat_ept=True,
        cat_mode="coherence",
        lambda_ent_inv_s=lambda_ent_inv_s,
    )


def main() -> int:
    outdir = Path(__file__).resolve().parent / "outputs"
    outdir.mkdir(parents=True, exist_ok=True)

    print("=" * 72)
    print("sim_04_visibility_decay.py")
    print("  V(S) = exp(-lambda_ent * S): Visibility decay")
    print("=" * 72)

    # Storage: {lambda_ent -> {sep_fs -> (V_paper, V_robust)}}
    results: dict[float, dict[float, tuple[float, float]]] = {}
    csv_rows: list[dict] = []

    total_runs = len(SEPARATIONS_FS) * len(LAMBDA_ENT_VALUES)
    run_idx = 0
    t0 = time.time()

    for lam in LAMBDA_ENT_VALUES:
        results[lam] = {}
        for sep_fs in SEPARATIONS_FS:
            sep_fs = float(sep_fs)
            run_idx += 1
            if run_idx % 50 == 0 or run_idx == 1:
                print(f"  [{run_idx}/{total_runs}] lambda={lam:.2e}, S={sep_fs:.0f} fs ...")

            cfg = _make_cfg(sep_fs, lambda_ent_inv_s=lam)
            out = simulate_time_double_slit_band(cfg, half_width_hz=HALF_WIDTH_HZ)

            freq_THz = out["freq_hz_band"] * 1e-12
            obs = build_spectral_observables(
                slit_separation_fs=sep_fs,
                frequency_THz=freq_THz,
                intensity=out["intensity_band"],
                carrier_THz=CARRIER_THZ,
                band_THz=BAND_THZ,
            )

            V_paper = obs.visibility_paper
            V_robust = obs.visibility_robust

            # Theoretical: V_theory = exp(-lambda * S)
            S_s = sep_fs * 1e-15
            V_theory = float(np.exp(-lam * S_s))

            results[lam][sep_fs] = (V_paper, V_robust)
            csv_rows.append({
                "separation_fs": sep_fs,
                "lambda_ent": lam,
                "V_paper": V_paper,
                "V_robust": V_robust,
                "V_theory": V_theory,
            })

    elapsed = time.time() - t0
    print(f"\n  All {total_runs} runs completed in {elapsed:.1f} s")

    # ------------------------------------------------------------------
    # Prepare arrays for plotting
    # ------------------------------------------------------------------
    sep_arr = np.array(SEPARATIONS_FS, dtype=float)
    S_s_arr = sep_arr * 1e-15  # in seconds

    # ------------------------------------------------------------------
    # Plot 1: V(S) curves with theoretical overlays
    # ------------------------------------------------------------------
    print("  Generating V(S) main plot ...")

    colors = ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#8c564b"]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10),
                                    gridspec_kw={"height_ratios": [3, 1]})

    for ci, lam in enumerate(LAMBDA_ENT_VALUES):
        V_paper_arr = np.array([results[lam][s][0] for s in sep_arr])
        V_theory_arr = np.exp(-lam * S_s_arr)

        lam_label = f"$\\lambda$={lam/1e12:.1f}" if lam > 0 else "$\\lambda$=0"

        # Measured visibility (paper method)
        ax1.plot(sep_arr, V_paper_arr, "o", color=colors[ci], ms=3, alpha=0.6,
                 label=f"V_paper {lam_label}")
        # Theoretical
        ax1.plot(sep_arr, V_theory_arr, "-", color=colors[ci], lw=1.5, alpha=0.8,
                 label=f"Theory {lam_label}")

        # Residuals
        residual = V_paper_arr - V_theory_arr
        ax2.plot(sep_arr, residual, "o-", color=colors[ci], ms=2, lw=0.8,
                 alpha=0.7, label=lam_label)

    ax1.set_ylabel("Visibility V(S)", fontsize=12)
    ax1.set_title("Visibility Decay: V(S) = exp($-\\lambda_{ent} \\cdot S$)", fontsize=14)
    ax1.legend(fontsize=7, ncol=2, loc="upper right")
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.05, 1.15)

    ax2.axhline(0, color="black", lw=0.8, ls="--")
    ax2.set_xlabel("Slit separation (fs)", fontsize=12)
    ax2.set_ylabel("Residual (V_paper - V_theory)", fontsize=11)
    ax2.legend(fontsize=7, ncol=3)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig_path1 = outdir / "fig_visibility_decay.png"
    fig.savefig(fig_path1, dpi=200)
    plt.close(fig)
    print(f"  Saved: {fig_path1}")

    # ------------------------------------------------------------------
    # Plot 2: log(V) vs S (should be linear)
    # ------------------------------------------------------------------
    print("  Generating log(V) vs S plot ...")

    fig2, ax = plt.subplots(1, 1, figsize=(10, 6))

    for ci, lam in enumerate(LAMBDA_ENT_VALUES):
        V_paper_arr = np.array([results[lam][s][0] for s in sep_arr])
        # Only plot log where V > 0
        mask = V_paper_arr > 0
        if np.any(mask):
            ax.plot(sep_arr[mask], np.log(V_paper_arr[mask]), "o", color=colors[ci],
                    ms=3, alpha=0.6)

        # Theoretical line: log(V) = -lambda * S
        if lam > 0:
            log_theory = -lam * S_s_arr
            ax.plot(sep_arr, log_theory, "-", color=colors[ci], lw=1.5, alpha=0.8,
                    label=f"$\\lambda$={lam/1e12:.1f}: slope = {-lam*1e-15:.4f} fs$^{{-1}}$")
        else:
            ax.axhline(0, color=colors[ci], lw=1.0, ls="--", alpha=0.5,
                       label="$\\lambda$=0 (no decay)")

    ax.set_xlabel("Slit separation (fs)", fontsize=12)
    ax.set_ylabel("ln(V)", fontsize=12)
    ax.set_title("Linearity check: ln V(S) vs S", fontsize=14)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig2.tight_layout()
    fig_path2 = outdir / "fig_visibility_logV_vs_S.png"
    fig2.savefig(fig_path2, dpi=200)
    plt.close(fig2)
    print(f"  Saved: {fig_path2}")

    # ------------------------------------------------------------------
    # Plot 3: V_robust comparison
    # ------------------------------------------------------------------
    print("  Generating V_robust comparison plot ...")

    fig3, ax3 = plt.subplots(1, 1, figsize=(10, 6))

    for ci, lam in enumerate(LAMBDA_ENT_VALUES):
        V_robust_arr = np.array([results[lam][s][1] for s in sep_arr])
        V_theory_arr = np.exp(-lam * S_s_arr)

        lam_label = f"$\\lambda$={lam/1e12:.1f}" if lam > 0 else "$\\lambda$=0"

        ax3.plot(sep_arr, V_robust_arr, "o", color=colors[ci], ms=3, alpha=0.6,
                 label=f"V_robust {lam_label}")
        ax3.plot(sep_arr, V_theory_arr, "-", color=colors[ci], lw=1.2, alpha=0.7)

    ax3.set_xlabel("Slit separation (fs)", fontsize=12)
    ax3.set_ylabel("Visibility (robust)", fontsize=12)
    ax3.set_title("Robust Visibility vs Theory", fontsize=14)
    ax3.legend(fontsize=7, ncol=2)
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(-0.05, 1.15)

    fig3.tight_layout()
    fig_path3 = outdir / "fig_visibility_robust_decay.png"
    fig3.savefig(fig_path3, dpi=200)
    plt.close(fig3)
    print(f"  Saved: {fig_path3}")

    # ------------------------------------------------------------------
    # CSV output
    # ------------------------------------------------------------------
    csv_path = outdir / "visibility_decay.csv"
    fieldnames = ["separation_fs", "lambda_ent", "V_paper", "V_robust", "V_theory"]
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
