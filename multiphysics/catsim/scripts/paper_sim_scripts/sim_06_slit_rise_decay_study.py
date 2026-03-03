#!/usr/bin/env python3
"""Sim 06 -- Slit rise/decay parameter study (Extended Fig 1c).

Priority: HIGH

Sweeps the logistic rise rate (alpha) and exponential decay rate (beta) to
characterise how slit temporal shape affects fringe visibility and spacing.

Sweeps
------
1. Rise time: 2 to 40 fs in steps of 2 fs.
   alpha_inv_s = 2*ln(9) / (rise_fs * 1e-15)
   Both standard and CAT/EPT runs at S = 800 fs.

2. Decay time: 100 to 800 fs in steps of 50 fs.
   beta_inv_s = 1 / (decay_fs * 1e-15)
   Both standard and CAT/EPT runs at S = 800 fs.

Panels
------
A: Visibility vs rise_time_fs (standard + CAT/EPT)
B: Visibility vs decay_time_fs (standard + CAT/EPT)
C: Fringe spacing vs rise_time_fs (standard + CAT/EPT)

Outputs
-------
outputs/sim06_panelA_V_vs_rise.png
outputs/sim06_panelB_V_vs_decay.png
outputs/sim06_panelC_fringe_vs_rise.png
outputs/sim06_rise_sweep.csv
outputs/sim06_decay_sweep.csv
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
        extract_fringe_spacing_THz,
    )
except ImportError as exc:
    print(f"[sim_06] ERROR: Could not import simulation module: {exc}")
    print("  Ensure the webapp/py directory is on your PYTHONPATH.")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Parameters
# ---------------------------------------------------------------------------
SEPARATION_FS = 800
LAMBDA_ENT = 1e12  # entropic rate for CAT/EPT runs (1/s)
BAND_THZ = 10.0    # analysis band half-width for visibility/fringe extraction

# Default slit parameters (overridden by sweep)
DEFAULT_ALPHA_INV_S = 0.5e15
DEFAULT_BETA_INV_S = 1.0 / 400e-15

# Rise sweep
RISE_FS_VALUES = np.arange(2, 42, 2, dtype=float)  # 2 to 40 fs, step 2

# Decay sweep
DECAY_FS_VALUES = np.arange(100, 850, 50, dtype=float)  # 100 to 800 fs, step 50


def alpha_from_rise_fs(rise_fs: float) -> float:
    """Logistic rise rate from 10-90% rise time in fs."""
    return 2.0 * np.log(9.0) / (rise_fs * 1e-15)


def beta_from_decay_fs(decay_fs: float) -> float:
    """Decay rate from characteristic decay time in fs."""
    return 1.0 / (decay_fs * 1e-15)


def extract_observables(result: dict, f0_hz: float) -> tuple:
    """Extract visibility and fringe spacing from a band result."""
    freq_hz = result["freq_hz_band"]
    intensity = result["intensity_band"]

    # Convert to THz for observable extraction
    freq_THz = freq_hz / 1e12
    carrier_THz = f0_hz / 1e12
    detuning_THz = freq_THz - carrier_THz

    vis = extract_visibility_paper(detuning_THz, intensity, band_THz=BAND_THZ)
    fringe = extract_fringe_spacing_THz(detuning_THz, intensity, band_THz=BAND_THZ)
    return vis, fringe


def make_config(
    alpha_inv_s: float,
    beta_inv_s: float,
    use_cat_ept: bool = False,
) -> TimeDoubleSlitConfig:
    """Build simulation config."""
    kwargs = dict(
        separation_s=SEPARATION_FS * 1e-15,
        alpha_inv_s=alpha_inv_s,
        beta_inv_s=beta_inv_s,
        use_cat_ept=use_cat_ept,
    )
    if use_cat_ept:
        kwargs["cat_mode"] = "coherence"
        kwargs["lambda_ent_inv_s"] = LAMBDA_ENT
    return TimeDoubleSlitConfig(**kwargs)


# ---------------------------------------------------------------------------
# Rise sweep
# ---------------------------------------------------------------------------
def run_rise_sweep() -> dict:
    """Sweep slit rise time from 2 to 40 fs.

    Returns dict with arrays: rise_fs, V_std, V_cat, fringe_std, fringe_cat.
    """
    V_std_list, V_cat_list = [], []
    fringe_std_list, fringe_cat_list = [], []

    for rise_fs in RISE_FS_VALUES:
        alpha = alpha_from_rise_fs(rise_fs)
        print(f"  Rise sweep: rise = {rise_fs:.0f} fs, alpha = {alpha:.3e} /s", flush=True)

        # Standard
        cfg_std = make_config(alpha_inv_s=alpha, beta_inv_s=DEFAULT_BETA_INV_S,
                              use_cat_ept=False)
        res_std = simulate_time_double_slit_band(cfg_std)
        v_s, f_s = extract_observables(res_std, cfg_std.f0_hz)
        V_std_list.append(v_s)
        fringe_std_list.append(f_s)

        # CAT/EPT
        cfg_cat = make_config(alpha_inv_s=alpha, beta_inv_s=DEFAULT_BETA_INV_S,
                              use_cat_ept=True)
        res_cat = simulate_time_double_slit_band(cfg_cat)
        v_c, f_c = extract_observables(res_cat, cfg_cat.f0_hz)
        V_cat_list.append(v_c)
        fringe_cat_list.append(f_c)

    return {
        "rise_fs": np.array(RISE_FS_VALUES),
        "V_std": np.array(V_std_list),
        "V_cat": np.array(V_cat_list),
        "fringe_std": np.array(fringe_std_list),
        "fringe_cat": np.array(fringe_cat_list),
    }


# ---------------------------------------------------------------------------
# Decay sweep
# ---------------------------------------------------------------------------
def run_decay_sweep() -> dict:
    """Sweep slit decay time from 100 to 800 fs.

    Returns dict with arrays: decay_fs, V_std, V_cat.
    """
    V_std_list, V_cat_list = [], []

    for decay_fs in DECAY_FS_VALUES:
        beta = beta_from_decay_fs(decay_fs)
        print(f"  Decay sweep: decay = {decay_fs:.0f} fs, beta = {beta:.3e} /s", flush=True)

        # Standard
        cfg_std = make_config(alpha_inv_s=DEFAULT_ALPHA_INV_S, beta_inv_s=beta,
                              use_cat_ept=False)
        res_std = simulate_time_double_slit_band(cfg_std)
        v_s, _ = extract_observables(res_std, cfg_std.f0_hz)
        V_std_list.append(v_s)

        # CAT/EPT
        cfg_cat = make_config(alpha_inv_s=DEFAULT_ALPHA_INV_S, beta_inv_s=beta,
                              use_cat_ept=True)
        res_cat = simulate_time_double_slit_band(cfg_cat)
        v_c, _ = extract_observables(res_cat, cfg_cat.f0_hz)
        V_cat_list.append(v_c)

    return {
        "decay_fs": np.array(DECAY_FS_VALUES),
        "V_std": np.array(V_std_list),
        "V_cat": np.array(V_cat_list),
    }


# ---------------------------------------------------------------------------
# Plotting
# ---------------------------------------------------------------------------
def plot_panel_a(rise_data: dict) -> None:
    """Panel A: Visibility vs rise time."""
    print("  Plotting Panel A: V vs rise_time ...", flush=True)
    fig, ax = plt.subplots(figsize=(8, 5))

    ax.plot(rise_data["rise_fs"], rise_data["V_std"],
            "o-", color="black", label="Standard", markersize=4, linewidth=1.2)
    ax.plot(rise_data["rise_fs"], rise_data["V_cat"],
            "s--", color="tab:blue", label="CAT/EPT", markersize=4, linewidth=1.2)

    ax.set_xlabel("Slit rise time (fs)", fontsize=12)
    ax.set_ylabel("Fringe visibility V", fontsize=12)
    ax.set_title("Panel A: Visibility vs slit rise time (S = 800 fs)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "sim06_panelA_V_vs_rise.png", dpi=200)
    plt.close(fig)
    print(f"    Saved {OUT_DIR / 'sim06_panelA_V_vs_rise.png'}")


def plot_panel_b(decay_data: dict) -> None:
    """Panel B: Visibility vs decay time."""
    print("  Plotting Panel B: V vs decay_time ...", flush=True)
    fig, ax = plt.subplots(figsize=(8, 5))

    ax.plot(decay_data["decay_fs"], decay_data["V_std"],
            "o-", color="black", label="Standard", markersize=4, linewidth=1.2)
    ax.plot(decay_data["decay_fs"], decay_data["V_cat"],
            "s--", color="tab:blue", label="CAT/EPT", markersize=4, linewidth=1.2)

    ax.set_xlabel("Slit decay time (fs)", fontsize=12)
    ax.set_ylabel("Fringe visibility V", fontsize=12)
    ax.set_title("Panel B: Visibility vs slit decay time (S = 800 fs)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "sim06_panelB_V_vs_decay.png", dpi=200)
    plt.close(fig)
    print(f"    Saved {OUT_DIR / 'sim06_panelB_V_vs_decay.png'}")


def plot_panel_c(rise_data: dict) -> None:
    """Panel C: Fringe spacing vs rise time."""
    print("  Plotting Panel C: fringe spacing vs rise_time ...", flush=True)
    fig, ax = plt.subplots(figsize=(8, 5))

    ax.plot(rise_data["rise_fs"], rise_data["fringe_std"],
            "o-", color="black", label="Standard", markersize=4, linewidth=1.2)
    ax.plot(rise_data["rise_fs"], rise_data["fringe_cat"],
            "s--", color="tab:blue", label="CAT/EPT", markersize=4, linewidth=1.2)

    ax.set_xlabel("Slit rise time (fs)", fontsize=12)
    ax.set_ylabel("Fringe spacing (THz)", fontsize=12)
    ax.set_title("Panel C: Fringe spacing vs slit rise time (S = 800 fs)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "sim06_panelC_fringe_vs_rise.png", dpi=200)
    plt.close(fig)
    print(f"    Saved {OUT_DIR / 'sim06_panelC_fringe_vs_rise.png'}")


# ---------------------------------------------------------------------------
# CSV output
# ---------------------------------------------------------------------------
def save_rise_csv(rise_data: dict) -> None:
    """Save rise sweep data to CSV."""
    print("  Saving CSV: rise sweep ...", flush=True)
    header = "rise_fs,V_std,V_cat,fringe_std_THz,fringe_cat_THz"
    data = np.column_stack([
        rise_data["rise_fs"],
        rise_data["V_std"],
        rise_data["V_cat"],
        rise_data["fringe_std"],
        rise_data["fringe_cat"],
    ])
    path = OUT_DIR / "sim06_rise_sweep.csv"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
    print(f"    Saved {path}")


def save_decay_csv(decay_data: dict) -> None:
    """Save decay sweep data to CSV."""
    print("  Saving CSV: decay sweep ...", flush=True)
    header = "decay_fs,V_std,V_cat"
    data = np.column_stack([
        decay_data["decay_fs"],
        decay_data["V_std"],
        decay_data["V_cat"],
    ])
    path = OUT_DIR / "sim06_decay_sweep.csv"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
    print(f"    Saved {path}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    print("=" * 70)
    print("Sim 06: Slit rise/decay parameter study (Extended Fig 1c)")
    print("=" * 70)

    print(f"\nFixed parameters:")
    print(f"  Separation S = {SEPARATION_FS} fs")
    print(f"  CAT/EPT lambda_ent = {LAMBDA_ENT:.0e} /s")
    print(f"  Analysis band = +/- {BAND_THZ} THz")

    # Rise sweep
    print(f"\n[1/4] Running rise sweep ({len(RISE_FS_VALUES)} points) ...")
    rise_data = run_rise_sweep()

    # Decay sweep
    print(f"\n[2/4] Running decay sweep ({len(DECAY_FS_VALUES)} points) ...")
    decay_data = run_decay_sweep()

    # Plots
    print("\n[3/4] Generating plots ...")
    plot_panel_a(rise_data)
    plot_panel_b(decay_data)
    plot_panel_c(rise_data)

    # CSV
    print("\n[4/4] Saving CSV data ...")
    save_rise_csv(rise_data)
    save_decay_csv(decay_data)

    print("\n" + "=" * 70)
    print("Sim 06 complete. All outputs in:", OUT_DIR)
    print("=" * 70)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
