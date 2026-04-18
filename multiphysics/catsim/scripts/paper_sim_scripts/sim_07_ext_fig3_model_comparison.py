#!/usr/bin/env python3
"""Sim 07 -- Extended Fig 3a-c: model comparison (CRITICAL).

Priority: CRITICAL

The key comparison: three models on the same axes for each slit separation.

For separations [400, 600, 800, 1000, 1200] fs:
1. Standard diffraction model  (use_cat_ept=False)
2. CAT/EPT coherence mode      (use_cat_ept=True, cat_mode="coherence", lambda_ent=1e12)
3. CAT/EPT amplitude mode      (use_cat_ept=True, cat_mode="amplitude", gamma_entropic=0.5)

Panels
------
5-panel figure (one per separation), each overlaying:
  - Standard spectrum (black solid)
  - Coherence-mode spectrum (blue solid)
  - Amplitude-mode spectrum (red dashed)
with visibility annotations.

Outputs
-------
outputs/sim07_model_comparison_5panel.png
outputs/sim07_model_comparison_S{sep}fs.png  (individual panels)
outputs/sim07_model_comparison.csv
"""
from __future__ import annotations

import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Resolve project paths
# ---------------------------------------------------------------------------
SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(PROJECT_ROOT / "webapp" / "py"))

OUT_DIR = SCRIPT_DIR / "outputs"
OUT_DIR.mkdir(parents=True, exist_ok=True)

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402

import numpy as np  # noqa: E402

try:
    from cat_ept_doubleslit.experiments.time_double_slit import (
        TimeDoubleSlitConfig,
        simulate_time_double_slit_band,
    )
    from cat_ept_doubleslit.observables import (
        extract_visibility_paper,
    )
except ImportError as exc:
    print(f"[sim_07] ERROR: Could not import simulation module: {exc}")
    print("  Ensure the webapp/py directory is on your PYTHONPATH.")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Parameters
# ---------------------------------------------------------------------------
SEPARATIONS_FS = [400, 600, 800, 1000, 1200]
LAMBDA_ENT = 1e12       # coherence-mode entropic rate (1/s)
GAMMA_ENTROPIC = 0.5    # amplitude-mode damping strength
BAND_THZ = 10.0         # analysis band half-width for visibility extraction
HALF_WIDTH_HZ = 15e12   # band half-width for spectrum extraction


def make_config_standard(sep_fs: float) -> TimeDoubleSlitConfig:
    """Standard diffraction model (no CAT/EPT)."""
    return TimeDoubleSlitConfig(
        separation_s=sep_fs * 1e-15,
        use_cat_ept=False,
    )


def make_config_coherence(sep_fs: float) -> TimeDoubleSlitConfig:
    """CAT/EPT coherence mode."""
    return TimeDoubleSlitConfig(
        separation_s=sep_fs * 1e-15,
        use_cat_ept=True,
        cat_mode="coherence",
        lambda_ent_inv_s=LAMBDA_ENT,
    )


def make_config_amplitude(sep_fs: float) -> TimeDoubleSlitConfig:
    """CAT/EPT amplitude mode."""
    return TimeDoubleSlitConfig(
        separation_s=sep_fs * 1e-15,
        use_cat_ept=True,
        cat_mode="amplitude",
        gamma_entropic=GAMMA_ENTROPIC,
    )


def extract_vis(result: dict, f0_hz: float) -> float:
    """Extract visibility from band result."""
    freq_hz = result["freq_hz_band"]
    intensity = result["intensity_band"]
    freq_THz = freq_hz / 1e12
    carrier_THz = f0_hz / 1e12
    detuning_THz = freq_THz - carrier_THz
    return extract_visibility_paper(detuning_THz, intensity, band_THz=BAND_THZ)


# ---------------------------------------------------------------------------
# Run all simulations
# ---------------------------------------------------------------------------
def run_all() -> dict:
    """Run 3 models x 5 separations = 15 simulations.

    Returns dict mapping (sep_fs, model_name) -> (result, visibility).
    """
    all_results = {}

    for sep_fs in SEPARATIONS_FS:
        print(f"\n  --- S = {sep_fs} fs ---", flush=True)

        # Standard
        print(f"    [standard]  ...", end="", flush=True)
        cfg_std = make_config_standard(sep_fs)
        res_std = simulate_time_double_slit_band(cfg_std, half_width_hz=HALF_WIDTH_HZ)
        vis_std = extract_vis(res_std, cfg_std.f0_hz)
        all_results[(sep_fs, "standard")] = (res_std, vis_std)
        print(f" V = {vis_std:.4f}")

        # Coherence
        print(f"    [coherence] ...", end="", flush=True)
        cfg_coh = make_config_coherence(sep_fs)
        res_coh = simulate_time_double_slit_band(cfg_coh, half_width_hz=HALF_WIDTH_HZ)
        vis_coh = extract_vis(res_coh, cfg_coh.f0_hz)
        all_results[(sep_fs, "coherence")] = (res_coh, vis_coh)
        print(f" V = {vis_coh:.4f}")

        # Amplitude
        print(f"    [amplitude] ...", end="", flush=True)
        cfg_amp = make_config_amplitude(sep_fs)
        res_amp = simulate_time_double_slit_band(cfg_amp, half_width_hz=HALF_WIDTH_HZ)
        vis_amp = extract_vis(res_amp, cfg_amp.f0_hz)
        all_results[(sep_fs, "amplitude")] = (res_amp, vis_amp)
        print(f" V = {vis_amp:.4f}")

    return all_results


# ---------------------------------------------------------------------------
# Plotting
# ---------------------------------------------------------------------------
def plot_5panel(all_results: dict) -> None:
    """Create 5-panel figure with all separations."""
    print("\n  Plotting 5-panel model comparison ...", flush=True)

    fig, axes = plt.subplots(1, 5, figsize=(24, 5), sharey=True)

    for idx, sep_fs in enumerate(SEPARATIONS_FS):
        ax = axes[idx]

        # Standard
        res_std, vis_std = all_results[(sep_fs, "standard")]
        f_std = res_std["freq_hz_band"] / 1e12  # THz
        carrier_THz = 230.2  # default f0
        det_std = f_std - carrier_THz

        # Coherence
        res_coh, vis_coh = all_results[(sep_fs, "coherence")]
        f_coh = res_coh["freq_hz_band"] / 1e12
        det_coh = f_coh - carrier_THz

        # Amplitude
        res_amp, vis_amp = all_results[(sep_fs, "amplitude")]
        f_amp = res_amp["freq_hz_band"] / 1e12
        det_amp = f_amp - carrier_THz

        ax.plot(det_std, res_std["intensity_band"],
                color="black", linewidth=1.0, label=f"Std (V={vis_std:.3f})")
        ax.plot(det_coh, res_coh["intensity_band"],
                color="tab:blue", linewidth=1.0, label=f"Coh (V={vis_coh:.3f})")
        ax.plot(det_amp, res_amp["intensity_band"],
                color="tab:red", linewidth=1.0, linestyle="--",
                label=f"Amp (V={vis_amp:.3f})")

        ax.set_xlabel("Detuning (THz)", fontsize=10)
        ax.set_title(f"S = {sep_fs} fs", fontsize=11, fontweight="bold")
        ax.legend(fontsize=7, loc="upper right")
        ax.grid(True, alpha=0.3)
        ax.set_xlim(-BAND_THZ, BAND_THZ)

    axes[0].set_ylabel("Normalized intensity", fontsize=11)

    fig.suptitle(
        "Extended Fig 3: Standard vs CAT/EPT Coherence vs Amplitude",
        fontsize=14, fontweight="bold", y=1.02,
    )
    fig.tight_layout()
    path = OUT_DIR / "sim07_model_comparison_5panel.png"
    fig.savefig(path, dpi=200, bbox_inches="tight")
    plt.close(fig)
    print(f"    Saved {path}")


def plot_individual_panels(all_results: dict) -> None:
    """Create individual plots per separation for higher resolution."""
    print("  Plotting individual panels ...", flush=True)
    carrier_THz = 230.2

    for sep_fs in SEPARATIONS_FS:
        fig, ax = plt.subplots(figsize=(8, 5))

        res_std, vis_std = all_results[(sep_fs, "standard")]
        res_coh, vis_coh = all_results[(sep_fs, "coherence")]
        res_amp, vis_amp = all_results[(sep_fs, "amplitude")]

        det_std = res_std["freq_hz_band"] / 1e12 - carrier_THz
        det_coh = res_coh["freq_hz_band"] / 1e12 - carrier_THz
        det_amp = res_amp["freq_hz_band"] / 1e12 - carrier_THz

        ax.plot(det_std, res_std["intensity_band"],
                color="black", linewidth=1.2,
                label=f"Standard (V = {vis_std:.4f})")
        ax.plot(det_coh, res_coh["intensity_band"],
                color="tab:blue", linewidth=1.2,
                label=f"CAT/EPT coherence (V = {vis_coh:.4f})")
        ax.plot(det_amp, res_amp["intensity_band"],
                color="tab:red", linewidth=1.2, linestyle="--",
                label=f"CAT/EPT amplitude (V = {vis_amp:.4f})")

        ax.set_xlabel("Detuning (THz)", fontsize=12)
        ax.set_ylabel("Normalized intensity", fontsize=12)
        ax.set_title(f"S = {sep_fs} fs: Standard vs Coherence vs Amplitude", fontsize=13)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_xlim(-BAND_THZ, BAND_THZ)

        fig.tight_layout()
        path = OUT_DIR / f"sim07_model_comparison_S{sep_fs}fs.png"
        fig.savefig(path, dpi=200)
        plt.close(fig)
        print(f"    Saved {path}")


# ---------------------------------------------------------------------------
# CSV output
# ---------------------------------------------------------------------------
def save_csv(all_results: dict) -> None:
    """Save all spectra and visibilities to CSV.

    The CSV has columns: separation_fs, freq_THz, I_standard, I_coherence, I_amplitude
    Each separation block is appended sequentially.
    """
    print("  Saving CSV: model comparison data ...", flush=True)

    rows = []
    carrier_THz = 230.2

    for sep_fs in SEPARATIONS_FS:
        res_std, vis_std = all_results[(sep_fs, "standard")]
        res_coh, vis_coh = all_results[(sep_fs, "coherence")]
        res_amp, vis_amp = all_results[(sep_fs, "amplitude")]

        # Use standard frequencies as reference (all should be identical)
        freq_THz = res_std["freq_hz_band"] / 1e12
        I_std = res_std["intensity_band"]

        # Interpolate coherence and amplitude onto same frequency grid
        freq_coh = res_coh["freq_hz_band"] / 1e12
        freq_amp = res_amp["freq_hz_band"] / 1e12
        I_coh = np.interp(freq_THz, freq_coh, res_coh["intensity_band"])
        I_amp = np.interp(freq_THz, freq_amp, res_amp["intensity_band"])

        for i in range(len(freq_THz)):
            rows.append([sep_fs, freq_THz[i], I_std[i], I_coh[i], I_amp[i]])

    header = "separation_fs,freq_THz,I_standard,I_coherence,I_amplitude"
    data = np.array(rows)
    path = OUT_DIR / "sim07_model_comparison.csv"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
    print(f"    Saved {path}")

    # Also save a summary table
    summary_rows = []
    for sep_fs in SEPARATIONS_FS:
        _, vis_std = all_results[(sep_fs, "standard")]
        _, vis_coh = all_results[(sep_fs, "coherence")]
        _, vis_amp = all_results[(sep_fs, "amplitude")]
        summary_rows.append([sep_fs, vis_std, vis_coh, vis_amp])

    header_s = "separation_fs,V_standard,V_coherence,V_amplitude"
    data_s = np.array(summary_rows)
    path_s = OUT_DIR / "sim07_visibility_summary.csv"
    np.savetxt(path_s, data_s, delimiter=",", header=header_s, comments="")
    print(f"    Saved {path_s}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    print("=" * 70)
    print("Sim 07: Extended Fig 3 -- Model Comparison (CRITICAL)")
    print("=" * 70)

    print(f"\nModels:")
    print(f"  1. Standard diffraction (no CAT/EPT)")
    print(f"  2. CAT/EPT coherence  (lambda_ent = {LAMBDA_ENT:.0e} /s)")
    print(f"  3. CAT/EPT amplitude  (gamma = {GAMMA_ENTROPIC})")
    print(f"\nSeparations: {SEPARATIONS_FS} fs")
    print(f"Total runs: {len(SEPARATIONS_FS) * 3}")

    # Run all 15 simulations
    print("\n[1/3] Running all simulations ...")
    all_results = run_all()

    # Plots
    print("\n[2/3] Generating plots ...")
    plot_5panel(all_results)
    plot_individual_panels(all_results)

    # CSV
    print("\n[3/3] Saving CSV data ...")
    save_csv(all_results)

    # Print visibility summary
    print("\n" + "-" * 50)
    print("Visibility Summary:")
    print(f"{'S (fs)':>8s}  {'Standard':>10s}  {'Coherence':>10s}  {'Amplitude':>10s}")
    print("-" * 50)
    for sep_fs in SEPARATIONS_FS:
        _, vis_std = all_results[(sep_fs, "standard")]
        _, vis_coh = all_results[(sep_fs, "coherence")]
        _, vis_amp = all_results[(sep_fs, "amplitude")]
        print(f"{sep_fs:>8.0f}  {vis_std:>10.4f}  {vis_coh:>10.4f}  {vis_amp:>10.4f}")

    print("\n" + "=" * 70)
    print("Sim 07 complete. All outputs in:", OUT_DIR)
    print("=" * 70)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
