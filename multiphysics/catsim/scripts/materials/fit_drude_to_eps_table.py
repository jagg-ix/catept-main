#!/usr/bin/env python3
"""Fit Drude parameters (eps_inf, omega_p, gamma) to a complex eps(ω) table.

This is intentionally dependency-light: it uses a coarse-to-fine search
that works with numpy only (no SciPy required). It is good enough to
initialize a higher-quality optimizer if you later add one.

Input CSV columns (required):
  f_THz, eps_real, eps_imag

Outputs:
  - best_fit.json  (eps_inf, omega_p, gamma, loss)
  - best_fit.yaml  (same, plus helper text)
  - overlay.csv    (f_THz, eps_real, eps_imag, eps_fit_real, eps_fit_imag)

Usage:
  python scripts/materials/fit_drude_to_eps_table.py \
      --in data/materials/ITO_eps_table_measured.csv \
      --outdir PAPER_TABLES/ADVANCED/MATERIALS/FIT_ITO \
      --eps_inf_range 2.0 8.0 \
      --omega_p_range 1.0e15 4.0e15 \
      --gamma_range 1.0e13 5.0e14
"""

from __future__ import annotations

import argparse
from pathlib import Path
import json
import numpy as np
import pandas as pd
import yaml


def drude_eps(omega_rad_s: np.ndarray, eps_inf: float, omega_p: float, gamma: float) -> np.ndarray:
    return eps_inf - (omega_p**2) / (omega_rad_s**2 + 1j * gamma * omega_rad_s)


def loss_fn(eps_true: np.ndarray, eps_fit: np.ndarray) -> float:
    # relative-ish loss to avoid overweighting large |eps|
    denom = np.maximum(1e-9, np.abs(eps_true))
    r = (eps_fit - eps_true) / denom
    return float(np.mean(np.real(r*np.conj(r))))


def coarse_to_fine_search(omega: np.ndarray, eps_true: np.ndarray,
                          eps_inf_rng, omega_p_rng, gamma_rng,
                          passes: int = 4, grid0: int = 14) -> dict:
    lo_e, hi_e = eps_inf_rng
    lo_wp, hi_wp = omega_p_rng
    lo_g, hi_g = gamma_rng

    best = None
    for p in range(passes):
        n = max(6, int(grid0 / (1.5**p)))
        eps_infs = np.linspace(lo_e, hi_e, n)
        omega_ps = np.geomspace(lo_wp, hi_wp, n)
        gammas   = np.geomspace(lo_g, hi_g, n)

        for ei in eps_infs:
            for wp in omega_ps:
                # vectorize over gamma
                for g in gammas:
                    eps_fit = drude_eps(omega, ei, wp, g)
                    L = loss_fn(eps_true, eps_fit)
                    if (best is None) or (L < best['loss']):
                        best = {'eps_inf': float(ei), 'omega_p': float(wp), 'gamma': float(g), 'loss': float(L)}

        # tighten ranges around best (log-space for wp, g)
        ei = best['eps_inf']; wp = best['omega_p']; g = best['gamma']
        span_e = (hi_e - lo_e) * 0.35
        lo_e, hi_e = max(0.5, ei - span_e), ei + span_e

        def tighten_log(x, lo, hi, factor=2.5):
            lx = np.log10(x)
            dlo = (np.log10(hi) - np.log10(lo)) / factor
            return 10**(lx - dlo), 10**(lx + dlo)

        lo_wp, hi_wp = tighten_log(wp, lo_wp, hi_wp)
        lo_g,  hi_g  = tighten_log(g,  lo_g,  hi_g)

    return best


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--in', dest='inp', required=True)
    ap.add_argument('--outdir', required=True)
    ap.add_argument('--eps_inf_range', type=float, nargs=2, default=[2.0, 8.0])
    ap.add_argument('--omega_p_range', type=float, nargs=2, default=[1e15, 4e15])
    ap.add_argument('--gamma_range', type=float, nargs=2, default=[1e13, 5e14])
    ap.add_argument('--passes', type=int, default=4)
    ap.add_argument('--grid0', type=int, default=14)
    args = ap.parse_args()

    df = pd.read_csv(args.inp)
    for c in ('f_THz','eps_real','eps_imag'):
        if c not in df.columns:
            raise SystemExit(f"missing column {c} in {args.inp}")

    f = df['f_THz'].to_numpy(dtype=float)
    omega = 2*np.pi*f*1e12
    eps_true = df['eps_real'].to_numpy(dtype=float) + 1j*df['eps_imag'].to_numpy(dtype=float)

    best = coarse_to_fine_search(
        omega, eps_true,
        tuple(args.eps_inf_range),
        tuple(args.omega_p_range),
        tuple(args.gamma_range),
        passes=args.passes,
        grid0=args.grid0,
    )

    eps_fit = drude_eps(omega, best['eps_inf'], best['omega_p'], best['gamma'])
    overlay = pd.DataFrame({
        'f_THz': f,
        'eps_real': np.real(eps_true),
        'eps_imag': np.imag(eps_true),
        'eps_fit_real': np.real(eps_fit),
        'eps_fit_imag': np.imag(eps_fit),
    })

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    (outdir/'best_fit.json').write_text(json.dumps(best, indent=2))
    (outdir/'best_fit.yaml').write_text(yaml.safe_dump({
        'best_fit': best,
        'notes': [
            "Drude fit produced by dependency-light coarse-to-fine search (numpy only).",
            "Use this as an initializer for higher-precision fits if desired.",
        ],
    }, sort_keys=False))
    overlay.to_csv(outdir/'overlay.csv', index=False)
    print(f"[ok] wrote {outdir/'best_fit.json'} and overlay.csv")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
