#!/usr/bin/env python3
"""Sim 08 -- Geometric enhancement factor via ENZ materials (Paper Fig 5).

Priority: HIGH

Key physics: lambda_ENZ = lambda_thermal * (c / v_g) where v_g is the group
velocity in an epsilon-near-zero (ENZ) material.

Drude model: epsilon(omega) = 1 - omega_p^2 / omega^2
  => v_g = c * sqrt(1 - (lambda/lambda_p)^2)      [lambda > lambda_p, propagating]
  => enhancement = c / v_g = 1 / sqrt(1 - (lambda_p/lambda)^2)

The ENZ point is at lambda_p ~ 1550 nm (omega_p sets this).

Sweeps
------
Wavelength from 900 to 2000 nm.  For each:
  - v_g from ENZ dispersion
  - Enhancement = c / v_g
  - V(S) = exp(-lambda_ENZ * S / v_g) for standard vs ENZ-enhanced

Panels
------
A: v_g/c vs wavelength (showing slow-down near ENZ point)
B: Enhancement factor c/v_g vs wavelength
C: V(S) for standard vs ENZ-enhanced at lambda = 1550 nm

Outputs
-------
outputs/sim08_panelA_vg_vs_wavelength.png
outputs/sim08_panelB_enhancement_vs_wavelength.png
outputs/sim08_panelC_V_vs_S.png
outputs/sim08_geometric_enhancement.csv
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

# Attempt to import the simulation module (used only for V(S) comparison in
# Panel C).  If unavailable, we compute the analytic model standalone.
try:
    from cat_ept_doubleslit.experiments.time_double_slit import (
        TimeDoubleSlitConfig,
        simulate_time_double_slit_band,
    )
    from cat_ept_doubleslit.observables import extract_visibility_paper
    HAS_SIM = True
except ImportError:
    HAS_SIM = False
    print("[sim_08] WARNING: simulation module not available; "
          "Panel C will use analytic model only.")


# ---------------------------------------------------------------------------
# Physical constants
# ---------------------------------------------------------------------------
C_M_S = 2.998e8          # speed of light (m/s)
LAMBDA_P_NM = 1550.0     # plasma wavelength = ENZ point (nm)
LAMBDA_THERMAL = 1e12    # baseline thermal entropic rate (1/s) -- paper default

# Wavelength sweep
WAVELENGTH_NM = np.linspace(900, 2000, 500)

# Separation sweep for Panel C
SEPARATION_FS = np.linspace(100, 2000, 200)

# Reference wavelength for Panel C comparison
REF_WAVELENGTH_NM = 1550.0
BAND_THZ = 10.0


# ---------------------------------------------------------------------------
# ENZ dispersion model (Drude, lossless)
# ---------------------------------------------------------------------------
def epsilon_drude(wavelength_nm: np.ndarray, lambda_p_nm: float) -> np.ndarray:
    """Drude dielectric function: epsilon(lambda) = 1 - (lambda/lambda_p)^2.

    Note: This is the *simplified* lossless Drude model where
    epsilon(omega) = 1 - omega_p^2/omega^2 and omega_p corresponds to lambda_p.
    In terms of wavelength: epsilon = 1 - (lambda/lambda_p)^2 since omega = 2*pi*c/lambda.

    Wait -- let us be precise.  omega_p = 2*pi*c / lambda_p.
    epsilon(omega) = 1 - omega_p^2/omega^2 = 1 - (lambda/lambda_p)^2.

    Actually:  omega_p^2 / omega^2 = (lambda / lambda_p)^2 only if we use the
    *correct* Drude form.  Let's verify:
      omega = 2*pi*c/lambda,  omega_p = 2*pi*c/lambda_p
      omega_p^2/omega^2 = lambda^2/lambda_p^2.

    So epsilon = 1 - lambda^2 / lambda_p^2.
    ENZ at lambda = lambda_p.  For lambda < lambda_p: epsilon > 0 (propagating).
    For lambda > lambda_p: epsilon < 0 (evanescent).
    """
    return 1.0 - (wavelength_nm / lambda_p_nm) ** 2


def group_velocity_ratio(wavelength_nm: np.ndarray, lambda_p_nm: float) -> np.ndarray:
    """v_g / c for the Drude model in the propagating regime (lambda < lambda_p).

    For a Drude medium with epsilon = 1 - omega_p^2/omega^2:
      n(omega) = sqrt(epsilon) = sqrt(1 - omega_p^2/omega^2)
      v_g = c * sqrt(1 - omega_p^2/omega^2) = c * sqrt(1 - (lambda/lambda_p)^2)

    This is valid for lambda < lambda_p (propagating regime).
    For lambda >= lambda_p, v_g is not real-valued (evanescent); we return NaN.
    """
    eps = epsilon_drude(wavelength_nm, lambda_p_nm)
    vg_ratio = np.where(eps > 0, np.sqrt(eps), np.nan)
    return vg_ratio


def enhancement_factor(wavelength_nm: np.ndarray, lambda_p_nm: float) -> np.ndarray:
    """Enhancement factor c / v_g = 1 / sqrt(1 - (lambda/lambda_p)^2).

    Diverges as lambda -> lambda_p from below (ENZ regime).
    """
    vg_ratio = group_velocity_ratio(wavelength_nm, lambda_p_nm)
    return np.where(np.isfinite(vg_ratio) & (vg_ratio > 0),
                    1.0 / vg_ratio, np.nan)


def visibility_analytic(separation_fs: np.ndarray, lambda_ent: float) -> np.ndarray:
    """Analytic visibility: V(S) = exp(-lambda_ent * S).

    lambda_ent in 1/s, separation in fs.
    """
    S_s = separation_fs * 1e-15
    return np.exp(-lambda_ent * S_s)


# ---------------------------------------------------------------------------
# Panel A: v_g/c vs wavelength
# ---------------------------------------------------------------------------
def plot_panel_a() -> None:
    print("  Plotting Panel A: v_g/c vs wavelength ...", flush=True)
    fig, ax = plt.subplots(figsize=(8, 5))

    vg_ratio = group_velocity_ratio(WAVELENGTH_NM, LAMBDA_P_NM)

    ax.plot(WAVELENGTH_NM, vg_ratio, color="tab:blue", linewidth=1.5)

    # Mark the ENZ point
    ax.axvline(LAMBDA_P_NM, color="tab:red", linestyle="--", alpha=0.7,
               label=f"ENZ point ({LAMBDA_P_NM:.0f} nm)")
    ax.axhline(0, color="gray", linestyle="-", alpha=0.3)

    ax.set_xlabel("Wavelength (nm)", fontsize=12)
    ax.set_ylabel("v_g / c", fontsize=12)
    ax.set_title("Panel A: Group velocity slow-down near ENZ", fontsize=13)
    ax.set_ylim(-0.1, 1.1)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    path = OUT_DIR / "sim08_panelA_vg_vs_wavelength.png"
    fig.savefig(path, dpi=200)
    plt.close(fig)
    print(f"    Saved {path}")


# ---------------------------------------------------------------------------
# Panel B: Enhancement factor c/v_g vs wavelength
# ---------------------------------------------------------------------------
def plot_panel_b() -> None:
    print("  Plotting Panel B: enhancement factor vs wavelength ...", flush=True)
    fig, ax = plt.subplots(figsize=(8, 5))

    enh = enhancement_factor(WAVELENGTH_NM, LAMBDA_P_NM)

    ax.plot(WAVELENGTH_NM, enh, color="tab:red", linewidth=1.5)

    # Mark the ENZ point
    ax.axvline(LAMBDA_P_NM, color="tab:red", linestyle="--", alpha=0.7,
               label=f"ENZ point ({LAMBDA_P_NM:.0f} nm)")

    ax.set_xlabel("Wavelength (nm)", fontsize=12)
    ax.set_ylabel("Enhancement factor c / v_g", fontsize=12)
    ax.set_title("Panel B: Geometric enhancement near ENZ", fontsize=13)
    ax.set_ylim(0, 20)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Inset: zoom near ENZ
    ax_inset = fig.add_axes([0.55, 0.45, 0.35, 0.35])
    near_mask = (WAVELENGTH_NM > 1400) & (WAVELENGTH_NM < 1550)
    ax_inset.plot(WAVELENGTH_NM[near_mask], enh[near_mask], color="tab:red", linewidth=1.2)
    ax_inset.axvline(LAMBDA_P_NM, color="tab:red", linestyle="--", alpha=0.5)
    ax_inset.set_xlabel("nm", fontsize=8)
    ax_inset.set_ylabel("c/v_g", fontsize=8)
    ax_inset.set_title("Near ENZ", fontsize=9)
    ax_inset.grid(True, alpha=0.3)

    fig.tight_layout()
    path = OUT_DIR / "sim08_panelB_enhancement_vs_wavelength.png"
    fig.savefig(path, dpi=200)
    plt.close(fig)
    print(f"    Saved {path}")


# ---------------------------------------------------------------------------
# Panel C: V(S) standard vs ENZ-enhanced
# ---------------------------------------------------------------------------
def plot_panel_c() -> None:
    """Panel C: visibility vs separation for standard and ENZ-enhanced.

    The ENZ-enhanced rate is:
        lambda_ENZ = lambda_thermal * (c / v_g)

    At the reference wavelength near ENZ, c/v_g >> 1, so the entropic
    decoherence is much stronger, reducing visibility for the same separation.

    If the simulation module is available, we also overlay numerically computed
    visibilities at a few discrete separations.
    """
    print("  Plotting Panel C: V(S) standard vs ENZ-enhanced ...", flush=True)
    fig, ax = plt.subplots(figsize=(8, 5))

    # Standard visibility (no ENZ enhancement)
    V_std = visibility_analytic(SEPARATION_FS, LAMBDA_THERMAL)

    # ENZ-enhanced at reference wavelength
    # Pick a wavelength slightly below ENZ to be in the propagating regime
    enz_wavelengths_nm = [1500.0, 1530.0, 1545.0]
    colors_enz = ["tab:orange", "tab:red", "darkred"]

    ax.plot(SEPARATION_FS, V_std, color="black", linewidth=1.5,
            label=f"Standard (lambda = {LAMBDA_THERMAL:.0e} /s)")

    for wl_nm, color in zip(enz_wavelengths_nm, colors_enz):
        enh = float(enhancement_factor(np.array([wl_nm]), LAMBDA_P_NM)[0])
        if not np.isfinite(enh):
            continue
        lambda_enz = LAMBDA_THERMAL * enh
        V_enz = visibility_analytic(SEPARATION_FS, lambda_enz)
        ax.plot(SEPARATION_FS, V_enz, color=color, linewidth=1.2, linestyle="--",
                label=f"ENZ {wl_nm:.0f} nm (enh={enh:.1f}x, lambda={lambda_enz:.2e} /s)")

    # Overlay simulation results if available
    if HAS_SIM:
        print("    Running numerical simulations for comparison ...", flush=True)
        sim_seps_fs = [400, 600, 800, 1000, 1200]
        vis_sim_std = []
        for s_fs in sim_seps_fs:
            cfg = TimeDoubleSlitConfig(
                separation_s=s_fs * 1e-15,
                use_cat_ept=True,
                cat_mode="coherence",
                lambda_ent_inv_s=LAMBDA_THERMAL,
            )
            res = simulate_time_double_slit_band(cfg)
            freq_THz = res["freq_hz_band"] / 1e12
            det_THz = freq_THz - cfg.f0_hz / 1e12
            vis = extract_visibility_paper(det_THz, res["intensity_band"], band_THz=BAND_THZ)
            vis_sim_std.append(vis)
            print(f"      S={s_fs} fs: V_sim = {vis:.4f}", flush=True)

        ax.scatter(sim_seps_fs, vis_sim_std, color="black", marker="o", zorder=5, s=40,
                   label="Numerical (coherence mode)")

    ax.set_xlabel("Slit separation S (fs)", fontsize=12)
    ax.set_ylabel("Fringe visibility V", fontsize=12)
    ax.set_title("Panel C: Visibility -- Standard vs ENZ-enhanced decoherence",
                 fontsize=13)
    ax.legend(fontsize=9, loc="upper right")
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.05)
    fig.tight_layout()
    path = OUT_DIR / "sim08_panelC_V_vs_S.png"
    fig.savefig(path, dpi=200)
    plt.close(fig)
    print(f"    Saved {path}")


# ---------------------------------------------------------------------------
# CSV output
# ---------------------------------------------------------------------------
def save_csv() -> None:
    """Save wavelength sweep data and V(S) data."""
    print("  Saving CSV: geometric enhancement data ...", flush=True)

    # Wavelength sweep
    vg_ratio = group_velocity_ratio(WAVELENGTH_NM, LAMBDA_P_NM)
    enh = enhancement_factor(WAVELENGTH_NM, LAMBDA_P_NM)

    # V at reference ENZ wavelength (1500 nm, safely propagating)
    ref_wl = 1500.0
    enh_ref = float(enhancement_factor(np.array([ref_wl]), LAMBDA_P_NM)[0])
    lambda_enz_ref = LAMBDA_THERMAL * enh_ref if np.isfinite(enh_ref) else LAMBDA_THERMAL

    # Standard visibility at a representative set of separations
    # For the wavelength-sweep CSV, pick a fixed separation
    fixed_sep_fs = 800.0
    V_std_val = float(np.exp(-LAMBDA_THERMAL * fixed_sep_fs * 1e-15))
    V_enz_arr = np.where(
        np.isfinite(enh),
        np.exp(-LAMBDA_THERMAL * enh * fixed_sep_fs * 1e-15),
        np.nan,
    )

    header = "wavelength_nm,v_g_over_c,enhancement,V_standard,V_enz"
    V_std_col = np.full_like(WAVELENGTH_NM, V_std_val)
    data = np.column_stack([WAVELENGTH_NM, vg_ratio, enh, V_std_col, V_enz_arr])
    path = OUT_DIR / "sim08_geometric_enhancement.csv"
    np.savetxt(path, data, delimiter=",", header=header, comments="")
    print(f"    Saved {path}")

    # V(S) comparison CSV
    V_std = visibility_analytic(SEPARATION_FS, LAMBDA_THERMAL)
    V_enz = visibility_analytic(SEPARATION_FS, lambda_enz_ref)
    header2 = f"separation_fs,V_standard,V_enz_{ref_wl:.0f}nm"
    data2 = np.column_stack([SEPARATION_FS, V_std, V_enz])
    path2 = OUT_DIR / "sim08_V_vs_S.csv"
    np.savetxt(path2, data2, delimiter=",", header=header2, comments="")
    print(f"    Saved {path2}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    print("=" * 70)
    print("Sim 08: Geometric enhancement via ENZ materials (Paper Fig 5)")
    print("=" * 70)

    print(f"\nParameters:")
    print(f"  ENZ plasma wavelength: {LAMBDA_P_NM} nm")
    print(f"  Baseline lambda_thermal: {LAMBDA_THERMAL:.0e} /s")
    print(f"  Wavelength sweep: {WAVELENGTH_NM[0]:.0f} - {WAVELENGTH_NM[-1]:.0f} nm "
          f"({len(WAVELENGTH_NM)} points)")
    print(f"  Simulation module available: {HAS_SIM}")

    # Panels A, B, C
    print("\n[1/2] Generating plots ...")
    plot_panel_a()
    plot_panel_b()
    plot_panel_c()

    # CSV
    print("\n[2/2] Saving CSV data ...")
    save_csv()

    # Print key enhancement values
    print("\n" + "-" * 50)
    print("Key enhancement values:")
    sample_wls = [1000, 1200, 1400, 1500, 1530, 1545]
    print(f"{'lambda (nm)':>12s}  {'v_g/c':>8s}  {'c/v_g':>8s}  {'lambda_ENZ':>12s}")
    print("-" * 50)
    for wl in sample_wls:
        vg = float(group_velocity_ratio(np.array([wl], dtype=float), LAMBDA_P_NM)[0])
        enh = float(enhancement_factor(np.array([wl], dtype=float), LAMBDA_P_NM)[0])
        if np.isfinite(enh):
            lam_enz = LAMBDA_THERMAL * enh
            print(f"{wl:>12.0f}  {vg:>8.4f}  {enh:>8.2f}  {lam_enz:>12.2e}")
        else:
            print(f"{wl:>12.0f}  {'N/A':>8s}  {'N/A':>8s}  {'N/A':>12s}")

    print("\n" + "=" * 70)
    print("Sim 08 complete. All outputs in:", OUT_DIR)
    print("=" * 70)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
