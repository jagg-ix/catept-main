"""Reproduce the paper's *time double-slit diffraction* spectrum with an on/off CAT/EPT toggle.

Baseline model (CAT/EPT off):
    I(f) = | F[ r(t) * E_probe(t) ] |^2

CAT/EPT-on variant (conservative software toggle):
    compute a nonnegative rate λ(t) tied to the modulation edges,
    τ_ent(t)=∫ λ dt,
    apply an amplitude weight exp(-γ τ_ent) before Fourier transform.

This is *not* claiming the paper uses CAT/EPT; it is an explicit A/B comparison harness.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

from cat_ept_doubleslit.experiments.time_double_slit import TimeDoubleSlitConfig, simulate_time_double_slit


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--separation_fs", type=float, default=800.0)
    ap.add_argument("--alpha_inv_fs", type=float, default=0.5)  # 1/(2 fs)
    ap.add_argument("--beta_inv_fs", type=float, default=1.0 / 400.0)
    ap.add_argument("--dt_fs", type=float, default=0.2)
    ap.add_argument("--window_ps", type=float, default=6.0)
    ap.add_argument("--out", type=str, default="out_time_double_slit")

    # CAT/EPT knobs
    ap.add_argument("--cat", action="store_true", help="Enable CAT/EPT-on run")
    ap.add_argument("--lambda0_inv_fs", type=float, default=0.0)
    ap.add_argument("--kappa", type=float, default=0.0)
    ap.add_argument("--lambda_floor_inv_fs", type=float, default=0.0)
    ap.add_argument("--gamma", type=float, default=0.0)
    args = ap.parse_args()

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    base_cfg = TimeDoubleSlitConfig(
        separation_s=args.separation_fs * 1e-15,
        alpha_inv_s=args.alpha_inv_fs * 1e15,
        beta_inv_s=args.beta_inv_fs * 1e15,
        dt_s=args.dt_fs * 1e-15,
        t_window_s=args.window_ps * 1e-12,
        use_cat_ept=False,
    )
    base = simulate_time_double_slit(base_cfg)

    cat = None
    if args.cat:
        cat_cfg = TimeDoubleSlitConfig(
            **{**base_cfg.__dict__},
            use_cat_ept=True,
            lambda0_inv_s=args.lambda0_inv_fs * 1e15,
            lambda_kappa=float(args.kappa),
            lambda_floor_inv_s=args.lambda_floor_inv_fs * 1e15,
            gamma_entropic=float(args.gamma),
        )
        cat = simulate_time_double_slit(cat_cfg)

    # Plot spectrum near f0.
    f_thz = base["freq_hz"] / 1e12
    I0 = base["intensity"] / np.max(base["intensity"])
    plt.figure()
    plt.plot(f_thz, I0, label="baseline")
    if cat is not None:
        I1 = cat["intensity"] / np.max(cat["intensity"])
        plt.plot(f_thz, I1, label="CAT/EPT-on")
    plt.xlim((base_cfg.f0_hz / 1e12 - 15.0, base_cfg.f0_hz / 1e12 + 15.0))
    plt.xlabel("Frequency (THz)")
    plt.ylabel("Normalized intensity")
    plt.title(f"Time double-slit diffraction (S={args.separation_fs:.0f} fs)")
    plt.legend()
    plt.tight_layout()
    plt.savefig(outdir / "spectrum_compare.png", dpi=180)
    plt.close()

    # Plot r(t) and optional λ(t)
    t_fs = base["t_s"] * 1e15
    plt.figure()
    plt.plot(t_fs, np.real(base["r_t"]), label="r(t) amplitude")
    plt.xlabel("Time (fs)")
    plt.ylabel("r(t)")
    plt.title("Double time-slit reflection coefficient")
    plt.tight_layout()
    plt.savefig(outdir / "reflection_rt.png", dpi=180)
    plt.close()

    if cat is not None and cat["lambda_t"] is not None:
        plt.figure()
        plt.plot(t_fs, cat["lambda_t"] / 1e15)
        plt.xlabel("Time (fs)")
        plt.ylabel("lambda(t) (1/fs)")
        plt.title("CAT/EPT-on: entropic rate proxy")
        plt.tight_layout()
        plt.savefig(outdir / "lambda_t.png", dpi=180)
        plt.close()

    # Save CSV for downstream fitting
    np.savetxt(outdir / "spectrum_baseline.csv", np.c_[f_thz, I0], delimiter=",", header="f_THz,I_norm", comments="")
    if cat is not None:
        I1 = cat["intensity"] / np.max(cat["intensity"])
        np.savetxt(outdir / "spectrum_cat.csv", np.c_[f_thz, I1], delimiter=",", header="f_THz,I_norm", comments="")


if __name__ == "__main__":
    main()
