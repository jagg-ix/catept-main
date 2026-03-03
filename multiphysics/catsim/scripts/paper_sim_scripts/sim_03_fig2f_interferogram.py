#!/usr/bin/env python3
"""Paper Fig 2f: Full spectral interferogram (2D: separation vs frequency).

Runs separations from -1400 to +1400 fs in steps of 50 fs.
For each separation, computes the band-limited spectrum via standard QM
and CAT/EPT (lambda_ent = 1e12 s^-1).

Produces:
  - Side-by-side 2D heatmaps: Standard QM (left) and CAT/EPT (right)
  - CSV in matrix format with frequency column headers

Output directory: outputs/ (relative to this script).
"""

from __future__ import annotations

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
from matplotlib.colors import Normalize  # noqa: E402

from cat_ept_doubleslit.experiments.time_double_slit import (  # noqa: E402
    TimeDoubleSlitConfig,
    simulate_time_double_slit_band,
)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
SEPARATIONS_FS = np.arange(-1400, 1401, 50, dtype=float)
HALF_WIDTH_HZ = 15e12
LAMBDA_ENT_CAT = 1.0e12  # s^-1
CARRIER_THZ = 230.2


def _make_cfg(
    separation_fs: float,
    use_cat_ept: bool,
    lambda_ent_inv_s: float = 0.0,
) -> TimeDoubleSlitConfig:
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
    print("sim_03_fig2f_interferogram.py")
    print("  Full spectral interferogram (2D: separation vs frequency)")
    print("=" * 72)

    total = len(SEPARATIONS_FS)
    t0 = time.time()

    # We will build 2D arrays after discovering the frequency axis from the first run.
    freq_THz_ref = None
    intensity_std_rows = []
    intensity_cat_rows = []

    for idx, sep_fs in enumerate(SEPARATIONS_FS):
        sep_fs = float(sep_fs)
        if (idx + 1) % 10 == 0 or idx == 0:
            print(f"  [{idx + 1}/{total}] S = {sep_fs:.0f} fs ...")

        # --- Standard QM ---
        cfg_std = _make_cfg(sep_fs, use_cat_ept=False)
        out_std = simulate_time_double_slit_band(cfg_std, half_width_hz=HALF_WIDTH_HZ)
        freq_THz_std = out_std["freq_hz_band"] * 1e-12

        if freq_THz_ref is None:
            freq_THz_ref = freq_THz_std.copy()

        # Interpolate onto the reference frequency grid for consistent 2D arrays
        intensity_std = np.interp(freq_THz_ref, freq_THz_std, out_std["intensity_band"])
        intensity_std_rows.append(intensity_std)

        # --- CAT/EPT ---
        cfg_cat = _make_cfg(sep_fs, use_cat_ept=True, lambda_ent_inv_s=LAMBDA_ENT_CAT)
        out_cat = simulate_time_double_slit_band(cfg_cat, half_width_hz=HALF_WIDTH_HZ)
        freq_THz_cat = out_cat["freq_hz_band"] * 1e-12
        intensity_cat = np.interp(freq_THz_ref, freq_THz_cat, out_cat["intensity_band"])
        intensity_cat_rows.append(intensity_cat)

    elapsed = time.time() - t0
    print(f"\n  All {total} separations completed in {elapsed:.1f} s")

    # Build 2D arrays
    detuning_THz = freq_THz_ref - CARRIER_THZ
    Z_std = np.array(intensity_std_rows)  # shape: (n_sep, n_freq)
    Z_cat = np.array(intensity_cat_rows)

    # ------------------------------------------------------------------
    # Plot: side-by-side 2D heatmaps
    # ------------------------------------------------------------------
    print("  Generating interferogram heatmaps ...")

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7), sharey=True)

    # Shared normalization for visual comparison
    vmin = 0.0
    vmax = max(Z_std.max(), Z_cat.max())
    norm = Normalize(vmin=vmin, vmax=vmax)

    # Standard QM
    im1 = ax1.pcolormesh(
        detuning_THz, SEPARATIONS_FS, Z_std,
        cmap="viridis", norm=norm, shading="auto"
    )
    ax1.set_xlabel("Detuning from carrier (THz)", fontsize=12)
    ax1.set_ylabel("Slit separation (fs)", fontsize=12)
    ax1.set_title("Standard QM", fontsize=13)
    ax1.set_xlim(-12, 12)
    fig.colorbar(im1, ax=ax1, label="Normalized intensity", shrink=0.8)

    # CAT/EPT
    im2 = ax2.pcolormesh(
        detuning_THz, SEPARATIONS_FS, Z_cat,
        cmap="viridis", norm=norm, shading="auto"
    )
    ax2.set_xlabel("Detuning from carrier (THz)", fontsize=12)
    ax2.set_title(f"CAT/EPT ($\\lambda_{{ent}}$ = {LAMBDA_ENT_CAT/1e12:.1f} THz$^{{-1}}$)", fontsize=13)
    ax2.set_xlim(-12, 12)
    fig.colorbar(im2, ax=ax2, label="Normalized intensity", shrink=0.8)

    fig.suptitle("Fig 2f: Spectral Interferogram (separation vs frequency)", fontsize=14, y=0.98)
    fig.tight_layout(rect=[0, 0, 1, 0.96])
    fig_path = outdir / "fig2f_interferogram.png"
    fig.savefig(fig_path, dpi=200)
    plt.close(fig)
    print(f"  Saved: {fig_path}")

    # ------------------------------------------------------------------
    # CSV output: matrix format
    # ------------------------------------------------------------------
    print("  Writing CSV matrices ...")

    # Standard QM matrix
    csv_std_path = outdir / "fig2f_interferogram_std.csv"
    header_cols = ["separation_fs"] + [f"{d:.4f}" for d in detuning_THz]
    with csv_std_path.open("w", encoding="utf-8") as f:
        f.write(",".join(header_cols) + "\n")
        for i, sep_fs in enumerate(SEPARATIONS_FS):
            vals = [f"{sep_fs:.1f}"] + [f"{v:.8e}" for v in Z_std[i, :]]
            f.write(",".join(vals) + "\n")
    print(f"  Saved: {csv_std_path}")

    # CAT/EPT matrix
    csv_cat_path = outdir / "fig2f_interferogram_cat.csv"
    with csv_cat_path.open("w", encoding="utf-8") as f:
        f.write(",".join(header_cols) + "\n")
        for i, sep_fs in enumerate(SEPARATIONS_FS):
            vals = [f"{sep_fs:.1f}"] + [f"{v:.8e}" for v in Z_cat[i, :]]
            f.write(",".join(vals) + "\n")
    print(f"  Saved: {csv_cat_path}")

    print("  Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
