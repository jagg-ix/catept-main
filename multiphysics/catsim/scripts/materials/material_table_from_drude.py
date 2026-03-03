#!/usr/bin/env python3
"""Generate eps(ω) table CSV from Drude parameters.

This supports Option C (Material Accuracy Push):
- Create a reproducible eps(ω) table for Phase 6.1 `mode: table`
- Make fitting/comparison workflows deterministic (no hidden in-code defaults)

CSV output columns:
  f_THz, eps_real, eps_imag

Usage:
  python scripts/materials/material_table_from_drude.py \
      --eps_inf 3.9 --omega_p 2.8e15 --gamma 1.0e14 \
      --f_min_THz 150 --f_max_THz 350 --n 2000 \
      --out data/materials/ITO_eps_table_proxy.csv
"""

from __future__ import annotations

import argparse
from pathlib import Path
import numpy as np
import pandas as pd


def drude_eps(omega_rad_s: np.ndarray, eps_inf: float, omega_p: float, gamma: float) -> np.ndarray:
    # eps(ω)= eps_inf - (ω_p^2)/(ω^2 + i γ ω)
    return eps_inf - (omega_p**2) / (omega_rad_s**2 + 1j * gamma * omega_rad_s)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--eps_inf', type=float, required=True)
    ap.add_argument('--omega_p', type=float, required=True, help='rad/s')
    ap.add_argument('--gamma', type=float, required=True, help='rad/s')
    ap.add_argument('--f_min_THz', type=float, default=150.0)
    ap.add_argument('--f_max_THz', type=float, default=350.0)
    ap.add_argument('--n', type=int, default=2000)
    ap.add_argument('--out', required=True)
    args = ap.parse_args()

    f_THz = np.linspace(args.f_min_THz, args.f_max_THz, args.n)
    omega = 2*np.pi*f_THz*1e12
    eps = drude_eps(omega, args.eps_inf, args.omega_p, args.gamma)

    df = pd.DataFrame({
        'f_THz': f_THz,
        'eps_real': np.real(eps),
        'eps_imag': np.imag(eps),
    })
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(out, index=False)
    print(f"[ok] wrote {out} ({len(df)} rows)")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
