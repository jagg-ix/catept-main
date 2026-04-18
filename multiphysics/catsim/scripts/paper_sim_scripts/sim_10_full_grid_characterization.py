#!/usr/bin/env python3
"""Full Grid Characterization: comprehensive separation x lambda_ent grid sweep.

Separations: 200, 400, 600, 800, 1000, 1200, 1400 fs
lambda_ent:  0, 0.1e12, 0.25e12, 0.5e12, 0.75e12, 1.0e12, 1.5e12, 2.0e12 s^-1

For each (S, lambda) pair, run CAT/EPT in coherence mode.
Extract V_paper, V_robust, fringe spacing, asymmetry.

Produces:
  - Heatmap A: V(S, lambda_ent) -- the visibility landscape
  - Heatmap B: fringe_spacing(S, lambda_ent)
  - Line plot C: V vs lambda_ent for selected separations overlaid
  - Master CSV: separation_fs, lambda_ent, V_paper, V_robust, fringe_THz, asymmetry

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
from matplotlib.colors import Normalize  # noqa: E402

from cat_ept_doubleslit.experiments.time_double_slit import (  # noqa: E402
    TimeDoubleSlitConfig,
    simulate_time_double_slit_band,
)
from cat_ept_doubleslit.observables import build_spectral_observables  # noqa: E402

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SEPARATIONS_FS = [200, 400, 600, 800, 1000, 1200, 1400]
LAMBDA_ENT_VALUES = [0.0, 0.1e12, 0.25e12, 0.5e12, 0.75e12, 1.0e12, 1.5e12, 2.0e12]
HALF_WIDTH_HZ = 15e12
CARRIER_THZ = 230.2
BAND_THZ = 10.0

# Separations to highlight in line plot C
LINE_PLOT_SEPS = [200, 400, 800, 1200, 1400]


def _make_cfg(
    separation_fs: float,
    use_cat_ept: bool,
    lambda_ent_inv_s: float = 0.0,
) -> TimeDoubleSlitConfig:
    """Build a TimeDoubleSlitConfig for a given separation and CAT/EPT state."""
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
    print("sim_10_full_grid_characterization.py")
    print("  Comprehensive separation x lambda_ent grid sweep")
    print("=" * 72)

    n_sep = len(SEPARATIONS_FS)
    n_lam = len(LAMBDA_ENT_VALUES)
    total_runs = n_sep * n_lam

    # 2D grids for heatmaps
    V_paper_grid = np.full((n_lam, n_sep), np.nan)
    V_robust_grid = np.full((n_lam, n_sep), np.nan)
    fringe_grid = np.full((n_lam, n_sep), np.nan)
    asym_grid = np.full((n_lam, n_sep), np.nan)

    csv_rows: list[dict] = []
    run_idx = 0
    t0 = time.time()

    for j, sep_fs in enumerate(SEPARATIONS_FS):
        for k, lam in enumerate(LAMBDA_ENT_VALUES):
            run_idx += 1
            use_cat = lam > 0.0
            mode_str = "cat_ept" if use_cat else "standard"
            print(f"  [{run_idx}/{total_runs}] S={sep_fs} fs, lambda_ent={lam:.2e} s^-1 ({mode_str}) ...")

            cfg = _make_cfg(sep_fs, use_cat_ept=use_cat, lambda_ent_inv_s=lam)
            out = simulate_time_double_slit_band(cfg, half_width_hz=HALF_WIDTH_HZ)

            freq_THz = out["freq_hz_band"] * 1e-12
            obs = build_spectral_observables(
                slit_separation_fs=float(sep_fs),
                frequency_THz=freq_THz,
                intensity=out["intensity_band"],
                carrier_THz=CARRIER_THZ,
                band_THz=BAND_THZ,
            )

            V_paper_grid[k, j] = obs.visibility_paper
            V_robust_grid[k, j] = obs.visibility_robust
            fringe_grid[k, j] = obs.fringe_spacing_THz
            asym_grid[k, j] = obs.asymmetry_fraction

            csv_rows.append({
                "separation_fs": sep_fs,
                "lambda_ent": lam,
                "V_paper": obs.visibility_paper,
                "V_robust": obs.visibility_robust,
                "fringe_THz": obs.fringe_spacing_THz,
                "asymmetry": obs.asymmetry_fraction,
            })

    elapsed = time.time() - t0
    print(f"\n  All {total_runs} grid simulations completed in {elapsed:.1f} s")

    # ------------------------------------------------------------------
    # Plot A: Heatmap of V_paper(S, lambda_ent)
    # ------------------------------------------------------------------
    print("  Generating heatmap figures ...")
    sep_arr = np.array(SEPARATIONS_FS, dtype=float)
    lam_arr = np.array(LAMBDA_ENT_VALUES, dtype=float)

    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # Heatmap A: Visibility landscape
    ax = axes[0]
    im = ax.imshow(
        V_paper_grid,
        aspect="auto",
        origin="lower",
        extent=[sep_arr[0], sep_arr[-1], 0, len(lam_arr) - 1],
        cmap="viridis",
        interpolation="nearest",
    )
    ax.set_xticks(sep_arr)
    ax.set_xticklabels([f"{int(s)}" for s in sep_arr], fontsize=8)
    ax.set_yticks(range(len(lam_arr)))
    ax.set_yticklabels([f"{l:.2e}" for l in lam_arr], fontsize=7)
    ax.set_xlabel("Separation S (fs)", fontsize=11)
    ax.set_ylabel("lambda_ent (s^-1)", fontsize=11)
    ax.set_title("(A) Visibility V_paper(S, lambda_ent)", fontsize=12)
    cb = fig.colorbar(im, ax=ax, shrink=0.8)
    cb.set_label("V_paper", fontsize=10)

    # Annotate cells
    for k in range(n_lam):
        for j in range(n_sep):
            val = V_paper_grid[k, j]
            if np.isfinite(val):
                ax.text(
                    sep_arr[j], k,
                    f"{val:.2f}",
                    ha="center", va="center", fontsize=6,
                    color="white" if val < 0.5 else "black",
                )

    # Heatmap B: Fringe spacing
    ax = axes[1]
    im2 = ax.imshow(
        fringe_grid,
        aspect="auto",
        origin="lower",
        extent=[sep_arr[0], sep_arr[-1], 0, len(lam_arr) - 1],
        cmap="plasma",
        interpolation="nearest",
    )
    ax.set_xticks(sep_arr)
    ax.set_xticklabels([f"{int(s)}" for s in sep_arr], fontsize=8)
    ax.set_yticks(range(len(lam_arr)))
    ax.set_yticklabels([f"{l:.2e}" for l in lam_arr], fontsize=7)
    ax.set_xlabel("Separation S (fs)", fontsize=11)
    ax.set_ylabel("lambda_ent (s^-1)", fontsize=11)
    ax.set_title("(B) Fringe spacing (THz)", fontsize=12)
    cb2 = fig.colorbar(im2, ax=ax, shrink=0.8)
    cb2.set_label("Fringe spacing (THz)", fontsize=10)

    # Annotate cells
    for k in range(n_lam):
        for j in range(n_sep):
            val = fringe_grid[k, j]
            if np.isfinite(val):
                ax.text(
                    sep_arr[j], k,
                    f"{val:.1f}",
                    ha="center", va="center", fontsize=6,
                    color="white" if val < np.nanmedian(fringe_grid) else "black",
                )

    fig.suptitle("Full Grid Characterization: Separation x lambda_ent", fontsize=14, y=1.02)
    fig.tight_layout()
    fig_heatmap_path = outdir / "full_grid_heatmaps.png"
    fig.savefig(fig_heatmap_path, dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {fig_heatmap_path}")

    # ------------------------------------------------------------------
    # Plot C: Line plot -- V vs lambda_ent for selected separations
    # ------------------------------------------------------------------
    print("  Generating line plot C ...")
    fig_c, ax_c = plt.subplots(figsize=(9, 6))

    colors = plt.cm.tab10(np.linspace(0, 1, len(LINE_PLOT_SEPS)))

    for ci, sep_fs in enumerate(LINE_PLOT_SEPS):
        j = SEPARATIONS_FS.index(sep_fs)
        V_line = V_paper_grid[:, j]
        ax_c.plot(
            lam_arr * 1e-12, V_line,
            "o-", color=colors[ci], lw=1.5, markersize=5,
            label=f"S = {sep_fs} fs",
        )

    ax_c.set_xlabel("lambda_ent (x 10^12 s^-1)", fontsize=11)
    ax_c.set_ylabel("Visibility V_paper", fontsize=11)
    ax_c.set_title("(C) V vs lambda_ent for selected separations", fontsize=13)
    ax_c.legend(fontsize=9)
    ax_c.grid(True, alpha=0.3)
    fig_c.tight_layout()
    fig_line_path = outdir / "full_grid_V_vs_lambda.png"
    fig_c.savefig(fig_line_path, dpi=200, bbox_inches="tight")
    plt.close(fig_c)
    print(f"  Saved: {fig_line_path}")

    # ------------------------------------------------------------------
    # CSV output
    # ------------------------------------------------------------------
    csv_path = outdir / "full_grid_characterization.csv"
    fieldnames = ["separation_fs", "lambda_ent", "V_paper", "V_robust", "fringe_THz", "asymmetry"]
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
