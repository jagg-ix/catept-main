#!/usr/bin/env python3
"""Sim 05 -- Time-domain reflectivity characterization (Extended Fig 1a).

Priority: HIGH

Produces R(t) time-domain plots showing the temporal double-slit structure:
two logistic bumps separated by S.  Also shows lambda(t) (entropic rate) and
tau_ent(t) (cumulative entropic time) when CAT/EPT is enabled.

Panels
------
A: |r(t)| for separations [400, 600, 800, 1000, 1200] fs overlaid.
B: lambda(t) for S=800 fs, standard vs CAT/EPT.
C: Cumulative tau_ent(t) for S=800 fs.

Outputs
-------
outputs/sim05_panelA_r_vs_t.png
outputs/sim05_panelB_lambda_t.png
outputs/sim05_panelC_tau_ent_t.png
outputs/sim05_time_domain_r.csv
outputs/sim05_lambda_tau_S800.csv
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
        simulate_time_double_slit,
    )
except ImportError as exc:
    print(f"[sim_05] ERROR: Could not import simulation module: {exc}")
    print("  Ensure the webapp/py directory is on your PYTHONPATH.")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Parameters
# ---------------------------------------------------------------------------
SEPARATIONS_FS = [400, 600, 800, 1000, 1200]
REFERENCE_S_FS = 800  # separation used for panels B and C
LAMBDA_ENT = 1e12      # entropic rate for CAT/EPT runs (1/s)

# Plotting window around the slit region
PLOT_WINDOW_FS = 3000  # +/- around center


def make_config(separation_fs: float, use_cat_ept: bool = False) -> TimeDoubleSlitConfig:
    """Build a TimeDoubleSlitConfig for a given separation."""
    cfg = TimeDoubleSlitConfig(
        separation_s=separation_fs * 1e-15,
        use_cat_ept=use_cat_ept,
    )
    if use_cat_ept:
        cfg = TimeDoubleSlitConfig(
            separation_s=separation_fs * 1e-15,
            use_cat_ept=True,
            cat_mode="coherence",
            lambda_ent_inv_s=LAMBDA_ENT,
        )
    return cfg


def run_standard_sweep() -> dict:
    """Run standard (no CAT/EPT) simulations for all separations.

    Returns a dict mapping separation_fs -> result dict.
    """
    results = {}
    for s_fs in SEPARATIONS_FS:
        print(f"  [Panel A] Running S = {s_fs} fs (standard) ...", flush=True)
        cfg = make_config(s_fs, use_cat_ept=False)
        results[s_fs] = simulate_time_double_slit(cfg)
    return results


def run_cat_ept_reference() -> dict:
    """Run CAT/EPT simulation for the reference separation (800 fs)."""
    print(f"  [Panel B/C] Running S = {REFERENCE_S_FS} fs (CAT/EPT) ...", flush=True)
    cfg = make_config(REFERENCE_S_FS, use_cat_ept=True)
    return simulate_time_double_slit(cfg)


# ---------------------------------------------------------------------------
# Plotting helpers
# ---------------------------------------------------------------------------
def to_fs(t_s: np.ndarray) -> np.ndarray:
    """Convert seconds to femtoseconds."""
    return t_s * 1e15


def time_mask(t_fs: np.ndarray, window_fs: float) -> np.ndarray:
    """Boolean mask for |t| <= window_fs."""
    return np.abs(t_fs) <= window_fs


# ---------------------------------------------------------------------------
# Panel A: |r(t)| for multiple separations
# ---------------------------------------------------------------------------
def plot_panel_a(std_results: dict) -> None:
    print("  Plotting Panel A: |r(t)| for all separations ...", flush=True)
    fig, ax = plt.subplots(figsize=(10, 5))

    colors = plt.cm.viridis(np.linspace(0.15, 0.85, len(SEPARATIONS_FS)))
    for idx, s_fs in enumerate(SEPARATIONS_FS):
        res = std_results[s_fs]
        t_fs = to_fs(res["t_s"])
        r_mag = np.abs(res["r_t"])
        mask = time_mask(t_fs, PLOT_WINDOW_FS)
        ax.plot(t_fs[mask], r_mag[mask], color=colors[idx],
                label=f"S = {s_fs} fs", linewidth=1.2)

    ax.set_xlabel("Time (fs)", fontsize=12)
    ax.set_ylabel("|r(t)|", fontsize=12)
    ax.set_title("Panel A: Time-domain reflectivity |r(t)| -- double-slit structure",
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "sim05_panelA_r_vs_t.png", dpi=200)
    plt.close(fig)
    print(f"    Saved {OUT_DIR / 'sim05_panelA_r_vs_t.png'}")


# ---------------------------------------------------------------------------
# Panel B: lambda(t) for S=800 fs (standard vs CAT/EPT)
# ---------------------------------------------------------------------------
def plot_panel_b(std_result: dict, cat_result: dict) -> None:
    print("  Plotting Panel B: lambda(t) for S=800 fs ...", flush=True)
    fig, ax = plt.subplots(figsize=(10, 5))

    t_fs = to_fs(cat_result["t_s"])
    mask = time_mask(t_fs, PLOT_WINDOW_FS)

    lam_cat = cat_result.get("lambda_t")
    if lam_cat is not None:
        ax.plot(t_fs[mask], lam_cat[mask], color="tab:blue",
                label=f"CAT/EPT (lambda_ent={LAMBDA_ENT:.0e} /s)", linewidth=1.2)

    # Standard run does not produce lambda_t (it is None), so we show zero baseline
    ax.axhline(0, color="black", linestyle="--", alpha=0.5, label="Standard (no CAT/EPT)")

    ax.set_xlabel("Time (fs)", fontsize=12)
    ax.set_ylabel("lambda(t) (1/s)", fontsize=12)
    ax.set_title(f"Panel B: Entropic rate lambda(t) -- S = {REFERENCE_S_FS} fs",
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "sim05_panelB_lambda_t.png", dpi=200)
    plt.close(fig)
    print(f"    Saved {OUT_DIR / 'sim05_panelB_lambda_t.png'}")


# ---------------------------------------------------------------------------
# Panel C: cumulative tau_ent(t) for S=800 fs
# ---------------------------------------------------------------------------
def plot_panel_c(cat_result: dict) -> None:
    print("  Plotting Panel C: cumulative tau_ent(t) for S=800 fs ...", flush=True)
    fig, ax1 = plt.subplots(figsize=(10, 5))

    t_fs = to_fs(cat_result["t_s"])
    mask = time_mask(t_fs, PLOT_WINDOW_FS)

    r_mag = np.abs(cat_result["r_t"])
    ax1.plot(t_fs[mask], r_mag[mask], color="gray", alpha=0.5,
             label="|r(t)|", linewidth=1.0)
    ax1.set_xlabel("Time (fs)", fontsize=12)
    ax1.set_ylabel("|r(t)|", fontsize=12, color="gray")
    ax1.tick_params(axis="y", labelcolor="gray")

    ax2 = ax1.twinx()
    tau_ent = cat_result.get("tau_ent_t")
    if tau_ent is not None:
        ax2.plot(t_fs[mask], tau_ent[mask], color="tab:red",
                 label="tau_ent(t)", linewidth=1.5)
    ax2.set_ylabel("tau_ent(t) (dimensionless)", fontsize=12, color="tab:red")
    ax2.tick_params(axis="y", labelcolor="tab:red")

    # Combined legend
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, fontsize=10, loc="upper left")

    ax1.set_title(f"Panel C: Cumulative entropic time tau_ent(t) -- S = {REFERENCE_S_FS} fs",
                  fontsize=13)
    ax1.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "sim05_panelC_tau_ent_t.png", dpi=200)
    plt.close(fig)
    print(f"    Saved {OUT_DIR / 'sim05_panelC_tau_ent_t.png'}")


# ---------------------------------------------------------------------------
# CSV output
# ---------------------------------------------------------------------------
def save_csv_r(std_results: dict) -> None:
    """Save |r(t)| for all separations into a single CSV."""
    print("  Saving CSV: time-domain |r(t)| ...", flush=True)

    # Use time array from first separation (all identical)
    ref = std_results[SEPARATIONS_FS[0]]
    t_fs = to_fs(ref["t_s"])
    mask = time_mask(t_fs, PLOT_WINDOW_FS)
    t_out = t_fs[mask]

    header = "t_fs"
    columns = [t_out]
    for s_fs in SEPARATIONS_FS:
        r_mag = np.abs(std_results[s_fs]["r_t"])[mask]
        header += f",r_mag_S{s_fs}fs"
        columns.append(r_mag)

    data = np.column_stack(columns)
    path = OUT_DIR / "sim05_time_domain_r.csv"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
    print(f"    Saved {path}")


def save_csv_lambda_tau(cat_result: dict) -> None:
    """Save lambda(t), tau_ent(t) for S=800 fs into CSV."""
    print("  Saving CSV: lambda_t, tau_ent_t for S=800 fs ...", flush=True)

    t_fs = to_fs(cat_result["t_s"])
    mask = time_mask(t_fs, PLOT_WINDOW_FS)

    lam_t = cat_result.get("lambda_t")
    tau_t = cat_result.get("tau_ent_t")

    if lam_t is None:
        lam_t = np.zeros_like(t_fs)
    if tau_t is None:
        tau_t = np.zeros_like(t_fs)

    header = "t_fs,lambda_t,tau_ent_t"
    data = np.column_stack([t_fs[mask], lam_t[mask], tau_t[mask]])
    path = OUT_DIR / "sim05_lambda_tau_S800.csv"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
    print(f"    Saved {path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    print("=" * 70)
    print("Sim 05: Time-domain reflectivity characterization (Extended Fig 1a)")
    print("=" * 70)

    # Panel A: standard runs across separations
    print("\n[1/4] Running standard simulations for all separations ...")
    std_results = run_standard_sweep()

    # Panels B and C: CAT/EPT run at reference separation
    print("\n[2/4] Running CAT/EPT simulation at S = 800 fs ...")
    cat_result = run_cat_ept_reference()

    # Also get standard result at reference separation for comparison
    std_ref = std_results[REFERENCE_S_FS]

    # Plotting
    print("\n[3/4] Generating plots ...")
    plot_panel_a(std_results)
    plot_panel_b(std_ref, cat_result)
    plot_panel_c(cat_result)

    # CSV
    print("\n[4/4] Saving CSV data ...")
    save_csv_r(std_results)
    save_csv_lambda_tau(cat_result)

    print("\n" + "=" * 70)
    print("Sim 05 complete. All outputs in:", OUT_DIR)
    print("=" * 70)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
