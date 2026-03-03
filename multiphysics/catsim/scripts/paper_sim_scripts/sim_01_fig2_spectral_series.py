#!/usr/bin/env python3
"""Paper Fig 2a-d: Spectral diffraction at multiple slit separations.

For each slit separation, run:
  - Standard QM (use_cat_ept=False)
  - CAT/EPT (use_cat_ept=True) with multiple lambda_ent values

Produces:
  - 2x4 multi-panel figure with overlaid spectra
  - Master CSV with observables for every (separation, lambda_ent) pair

Output directory: outputs/ (relative to this script).
"""

from __future__ import annotations

import csv
import sys
import time
from dataclasses import asdict
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
SEPARATIONS_FS = [200, 400, 500, 600, 800, 1000, 1200, 1400]
LAMBDA_ENT_VALUES = [0.0, 0.5e12, 1.0e12, 1.5e12]
HALF_WIDTH_HZ = 15e12
CARRIER_THZ = 230.2
BAND_THZ = 10.0


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
    print("sim_01_fig2_spectral_series.py")
    print("  Spectral diffraction at multiple slit separations")
    print("=" * 72)

    # ------------------------------------------------------------------
    # Storage for all results
    # ------------------------------------------------------------------
    # Key: (separation_fs, label_str) -> dict with freq arrays + observables
    all_results: dict[tuple[float, str], dict] = {}
    csv_rows: list[dict] = []

    total_runs = len(SEPARATIONS_FS) * (1 + len(LAMBDA_ENT_VALUES))
    run_idx = 0
    t0 = time.time()

    for sep_fs in SEPARATIONS_FS:
        # --- Standard QM run ---
        run_idx += 1
        label = "std"
        print(f"  [{run_idx}/{total_runs}] S={sep_fs} fs, mode=standard ...")
        cfg_std = _make_cfg(sep_fs, use_cat_ept=False)
        out_std = simulate_time_double_slit_band(cfg_std, half_width_hz=HALF_WIDTH_HZ)

        freq_THz = out_std["freq_hz_band"] * 1e-12
        obs_std = build_spectral_observables(
            slit_separation_fs=float(sep_fs),
            frequency_THz=freq_THz,
            intensity=out_std["intensity_band"],
            carrier_THz=CARRIER_THZ,
            band_THz=BAND_THZ,
        )
        all_results[(sep_fs, label)] = {
            "freq_THz": freq_THz,
            "intensity": out_std["intensity_band"],
            "obs": obs_std,
        }
        csv_rows.append({
            "separation_fs": sep_fs,
            "lambda_ent": 0.0,
            "mode": "standard",
            "visibility_paper": obs_std.visibility_paper,
            "visibility_robust": obs_std.visibility_robust,
            "fringe_spacing_THz": obs_std.fringe_spacing_THz,
            "asymmetry": obs_std.asymmetry_fraction,
        })

        # --- CAT/EPT runs for each lambda_ent ---
        for lam in LAMBDA_ENT_VALUES:
            run_idx += 1
            label_cat = f"cat_lam{lam:.1e}"
            print(f"  [{run_idx}/{total_runs}] S={sep_fs} fs, CAT/EPT lambda_ent={lam:.2e} ...")
            cfg_cat = _make_cfg(sep_fs, use_cat_ept=True, lambda_ent_inv_s=lam)
            out_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=HALF_WIDTH_HZ)

            freq_THz_cat = out_cat["freq_hz_band"] * 1e-12
            obs_cat = build_spectral_observables(
                slit_separation_fs=float(sep_fs),
                frequency_THz=freq_THz_cat,
                intensity=out_cat["intensity_band"],
                carrier_THz=CARRIER_THZ,
                band_THz=BAND_THZ,
            )
            all_results[(sep_fs, label_cat)] = {
                "freq_THz": freq_THz_cat,
                "intensity": out_cat["intensity_band"],
                "obs": obs_cat,
            }
            csv_rows.append({
                "separation_fs": sep_fs,
                "lambda_ent": lam,
                "mode": "cat_ept",
                "visibility_paper": obs_cat.visibility_paper,
                "visibility_robust": obs_cat.visibility_robust,
                "fringe_spacing_THz": obs_cat.fringe_spacing_THz,
                "asymmetry": obs_cat.asymmetry_fraction,
            })

    elapsed = time.time() - t0
    print(f"\n  All {total_runs} simulations completed in {elapsed:.1f} s")

    # ------------------------------------------------------------------
    # Plot: 2x4 multi-panel figure
    # ------------------------------------------------------------------
    print("  Generating multi-panel figure ...")
    fig, axes = plt.subplots(2, 4, figsize=(20, 9), sharex=True, sharey=True)
    axes_flat = axes.flatten()

    colors_cat = ["#1f77b4", "#2ca02c", "#d62728", "#9467bd"]

    for panel_idx, sep_fs in enumerate(SEPARATIONS_FS):
        ax = axes_flat[panel_idx]

        # Standard QM
        res_std = all_results[(sep_fs, "std")]
        detuning_std = res_std["freq_THz"] - CARRIER_THZ
        ax.plot(detuning_std, res_std["intensity"], color="black", lw=1.0,
                alpha=0.8, label="Std QM")

        # CAT/EPT for each lambda_ent
        for ci, lam in enumerate(LAMBDA_ENT_VALUES):
            label_cat = f"cat_lam{lam:.1e}"
            res_cat = all_results[(sep_fs, label_cat)]
            detuning_cat = res_cat["freq_THz"] - CARRIER_THZ
            lam_label = f"$\\lambda$={lam/1e12:.1f} THz$^{{-1}}$" if lam > 0 else "$\\lambda$=0"
            ax.plot(detuning_cat, res_cat["intensity"], color=colors_cat[ci],
                    lw=0.8, alpha=0.7, label=lam_label)

        ax.set_title(f"S = {sep_fs} fs", fontsize=11)
        ax.set_xlim(-12, 12)
        if panel_idx == 0:
            ax.legend(fontsize=6, loc="upper right")

    for ax in axes[1, :]:
        ax.set_xlabel("Detuning from carrier (THz)", fontsize=10)
    for ax in axes[:, 0]:
        ax.set_ylabel("Normalized intensity", fontsize=10)

    fig.suptitle("Fig 2a-d: Temporal Double-Slit Spectral Diffraction", fontsize=14, y=0.98)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    fig_path = outdir / "fig2_spectral_series.png"
    fig.savefig(fig_path, dpi=200)
    plt.close(fig)
    print(f"  Saved: {fig_path}")

    # ------------------------------------------------------------------
    # CSV output
    # ------------------------------------------------------------------
    csv_path = outdir / "fig2_spectral_series.csv"
    fieldnames = ["separation_fs", "lambda_ent", "mode",
                  "visibility_paper", "visibility_robust",
                  "fringe_spacing_THz", "asymmetry"]
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
