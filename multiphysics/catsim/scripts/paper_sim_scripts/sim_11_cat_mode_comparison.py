#!/usr/bin/env python3
"""CAT Mode Comparison: compare coherence vs amplitude CAT/EPT modes.

For separations [200, 400, 600, 800, 1000, 1200, 1400] fs:
  1. Standard (no CAT/EPT)
  2. Coherence mode with lambda_ent = 1e12
  3. Amplitude mode with gamma_entropic values [0.1, 0.5, 1.0, 2.0]

Extract V for each.

Produces:
  - Plot: V vs S for each mode/param combination
  - CSV: separation_fs, mode, param_value, V_paper, V_robust

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
SEPARATIONS_FS = [200, 400, 600, 800, 1000, 1200, 1400]
LAMBDA_ENT_COHERENCE = 1.0e12
GAMMA_ENTROPIC_VALUES = [0.1, 0.5, 1.0, 2.0]
HALF_WIDTH_HZ = 15e12
CARRIER_THZ = 230.2
BAND_THZ = 10.0


def _make_cfg(
    separation_fs: float,
    use_cat_ept: bool = False,
    cat_mode: str = "coherence",
    lambda_ent_inv_s: float = 0.0,
    gamma_entropic: float = 0.0,
) -> TimeDoubleSlitConfig:
    """Build a TimeDoubleSlitConfig with mode selection."""
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
        cat_mode=cat_mode,
        lambda_ent_inv_s=lambda_ent_inv_s,
        gamma_entropic=gamma_entropic,
    )


def main() -> int:
    outdir = Path(__file__).resolve().parent / "outputs"
    outdir.mkdir(parents=True, exist_ok=True)

    print("=" * 72)
    print("sim_11_cat_mode_comparison.py")
    print("  Compare coherence vs amplitude CAT/EPT modes")
    print("=" * 72)

    csv_rows: list[dict] = []
    t0 = time.time()

    # Results storage: key -> list of V_paper indexed by separation
    results: dict[str, list[float]] = {}
    results_robust: dict[str, list[float]] = {}

    # Track total runs for progress
    total_runs = len(SEPARATIONS_FS) * (1 + 1 + len(GAMMA_ENTROPIC_VALUES))
    run_idx = 0

    # -- Label keys --
    label_std = "Standard (no CAT/EPT)"
    label_coh = f"Coherence (lam={LAMBDA_ENT_COHERENCE:.0e})"
    amp_labels = [f"Amplitude (gamma={g})" for g in GAMMA_ENTROPIC_VALUES]

    all_labels = [label_std, label_coh] + amp_labels
    for lbl in all_labels:
        results[lbl] = []
        results_robust[lbl] = []

    for sep_fs in SEPARATIONS_FS:
        # 1. Standard
        run_idx += 1
        print(f"  [{run_idx}/{total_runs}] S={sep_fs} fs, Standard ...")
        cfg = _make_cfg(sep_fs, use_cat_ept=False)
        out = simulate_time_double_slit_band(cfg, half_width_hz=HALF_WIDTH_HZ)
        freq_THz = out["freq_hz_band"] * 1e-12
        obs = build_spectral_observables(
            slit_separation_fs=float(sep_fs),
            frequency_THz=freq_THz,
            intensity=out["intensity_band"],
            carrier_THz=CARRIER_THZ,
            band_THz=BAND_THZ,
        )
        results[label_std].append(obs.visibility_paper)
        results_robust[label_std].append(obs.visibility_robust)
        csv_rows.append({
            "separation_fs": sep_fs,
            "mode": "standard",
            "param_value": 0.0,
            "V_paper": obs.visibility_paper,
            "V_robust": obs.visibility_robust,
        })

        # 2. Coherence mode
        run_idx += 1
        print(f"  [{run_idx}/{total_runs}] S={sep_fs} fs, Coherence (lambda_ent={LAMBDA_ENT_COHERENCE:.1e}) ...")
        cfg = _make_cfg(
            sep_fs,
            use_cat_ept=True,
            cat_mode="coherence",
            lambda_ent_inv_s=LAMBDA_ENT_COHERENCE,
        )
        out = simulate_time_double_slit_band(cfg, half_width_hz=HALF_WIDTH_HZ)
        freq_THz = out["freq_hz_band"] * 1e-12
        obs = build_spectral_observables(
            slit_separation_fs=float(sep_fs),
            frequency_THz=freq_THz,
            intensity=out["intensity_band"],
            carrier_THz=CARRIER_THZ,
            band_THz=BAND_THZ,
        )
        results[label_coh].append(obs.visibility_paper)
        results_robust[label_coh].append(obs.visibility_robust)
        csv_rows.append({
            "separation_fs": sep_fs,
            "mode": "coherence",
            "param_value": LAMBDA_ENT_COHERENCE,
            "V_paper": obs.visibility_paper,
            "V_robust": obs.visibility_robust,
        })

        # 3. Amplitude mode for each gamma
        for gi, gamma in enumerate(GAMMA_ENTROPIC_VALUES):
            run_idx += 1
            lbl = amp_labels[gi]
            print(f"  [{run_idx}/{total_runs}] S={sep_fs} fs, Amplitude (gamma={gamma}) ...")
            cfg = _make_cfg(
                sep_fs,
                use_cat_ept=True,
                cat_mode="amplitude",
                gamma_entropic=gamma,
            )
            out = simulate_time_double_slit_band(cfg, half_width_hz=HALF_WIDTH_HZ)
            freq_THz = out["freq_hz_band"] * 1e-12
            obs = build_spectral_observables(
                slit_separation_fs=float(sep_fs),
                frequency_THz=freq_THz,
                intensity=out["intensity_band"],
                carrier_THz=CARRIER_THZ,
                band_THz=BAND_THZ,
            )
            results[lbl].append(obs.visibility_paper)
            results_robust[lbl].append(obs.visibility_robust)
            csv_rows.append({
                "separation_fs": sep_fs,
                "mode": "amplitude",
                "param_value": gamma,
                "V_paper": obs.visibility_paper,
                "V_robust": obs.visibility_robust,
            })

    elapsed = time.time() - t0
    print(f"\n  All {total_runs} simulations completed in {elapsed:.1f} s")

    # ------------------------------------------------------------------
    # Plot: V vs S for each mode/param
    # ------------------------------------------------------------------
    print("  Generating comparison figure ...")
    fig, ax = plt.subplots(figsize=(10, 7))

    sep_arr = np.array(SEPARATIONS_FS, dtype=float)

    # Standard: thick black
    ax.plot(
        sep_arr, results[label_std],
        "ko-", lw=2.0, markersize=6,
        label=label_std,
    )

    # Coherence: thick blue with star marker, annotated as paper-preferred
    ax.plot(
        sep_arr, results[label_coh],
        "b*-", lw=2.0, markersize=10,
        label=label_coh + " [paper-preferred]",
    )

    # Amplitude modes: dashed lines, warm colors
    amp_colors = ["#e6550d", "#fd8d3c", "#fdae6b", "#fdd0a2"]
    amp_markers = ["s", "D", "^", "v"]
    for gi, gamma in enumerate(GAMMA_ENTROPIC_VALUES):
        lbl = amp_labels[gi]
        ax.plot(
            sep_arr, results[lbl],
            linestyle="--", color=amp_colors[gi], marker=amp_markers[gi],
            lw=1.2, markersize=5,
            label=lbl,
        )

    ax.set_xlabel("Slit separation S (fs)", fontsize=12)
    ax.set_ylabel("Visibility V_paper", fontsize=12)
    ax.set_title("CAT/EPT Mode Comparison: Coherence vs Amplitude", fontsize=14)
    ax.legend(fontsize=8, loc="best")
    ax.grid(True, alpha=0.3)

    # Annotate the paper-preferred mode
    ax.annotate(
        "Paper-preferred\n(coherence mode)",
        xy=(sep_arr[3], results[label_coh][3]),
        xytext=(sep_arr[3] + 150, results[label_coh][3] + 0.1),
        fontsize=8,
        arrowprops=dict(arrowstyle="->", color="blue", lw=1.2),
        color="blue",
    )

    fig.tight_layout()
    fig_path = outdir / "cat_mode_comparison.png"
    fig.savefig(fig_path, dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"  Saved: {fig_path}")

    # ------------------------------------------------------------------
    # CSV output
    # ------------------------------------------------------------------
    csv_path = outdir / "cat_mode_comparison.csv"
    fieldnames = ["separation_fs", "mode", "param_value", "V_paper", "V_robust"]
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
