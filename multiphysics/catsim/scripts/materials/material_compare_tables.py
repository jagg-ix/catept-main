#!/usr/bin/env python3
"""Material accuracy comparison table generator (Option C).

Produces a compact table of ENZ diagnostics and Drude-fit error metrics.

Inputs:
  --enz_config configs/enz_model.yaml (or any compatible yaml)
  --eps_table  optional CSV (f_THz, eps_real, eps_imag). If omitted, uses the mode in yaml.

Outputs:
  PAPER_TABLES/ADVANCED/MATERIALS/material_accuracy.csv
  PAPER_TABLES/ADVANCED/MATERIALS/material_accuracy.json

This does *not* claim ground-truth without measured eps(ω); it is a
traceable diagnostic for how 'paper-locked' the material model is.
"""

from __future__ import annotations

import argparse, json
from pathlib import Path
import numpy as np
import pandas as pd
import yaml


def drude_eps(omega: np.ndarray, eps_inf: float, omega_p: float, gamma: float) -> np.ndarray:
    return eps_inf - (omega_p**2) / (omega**2 + 1j*gamma*omega)


def estimate_enz(freq_THz: np.ndarray, eps: np.ndarray) -> tuple[float, str]:
    eps_re = np.real(eps)
    sgn = np.sign(eps_re)
    idx = np.where(np.diff(sgn) != 0)[0]
    if len(idx) > 0:
        i = int(idx[0])
        x0, x1 = freq_THz[i], freq_THz[i+1]
        y0, y1 = eps_re[i], eps_re[i+1]
        enz = float(x0 + (0 - y0) * (x1 - x0) / (y1 - y0))
        return enz, "sign-change"
    j = int(np.argmin(np.abs(eps_re)))
    return float(freq_THz[j]), "min-abs-Re"


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--enz_config', default='configs/enz_model.yaml')
    ap.add_argument('--outdir', default='PAPER_TABLES/ADVANCED/MATERIALS')
    args = ap.parse_args()

    cfg = yaml.safe_load(Path(args.enz_config).read_text())
    enz_target = float(cfg.get('enz_frequency_THz', 227.0))
    tol = float(cfg.get('enz_tolerance_THz', 5.0))
    mode = cfg.get('mode', 'drude')

    if mode == 'table' and cfg.get('eps_table_csv'):
        df = pd.read_csv(cfg['eps_table_csv'])
        f = df['f_THz'].to_numpy(float)
        eps = df['eps_real'].to_numpy(float) + 1j*df['eps_imag'].to_numpy(float)
        src = f"table:{cfg['eps_table_csv']}"
    else:
        eps_inf = float(cfg.get('eps_inf', 3.9))
        omega_p = float(cfg.get('omega_p', 2.8e15))
        gamma = float(cfg.get('gamma', 1e14))
        f = np.linspace(150.0, 350.0, 2000)
        omega = 2*np.pi*f*1e12
        eps = drude_eps(omega, eps_inf, omega_p, gamma)
        src = f"drude:eps_inf={eps_inf},omega_p={omega_p},gamma={gamma}"

    enz_est, method = estimate_enz(f, eps)
    delta = float(abs(enz_est - enz_target))
    passed = bool(delta <= tol)

    # diagnostics at target frequency (nearest sample)
    j = int(np.argmin(np.abs(f - enz_target)))
    eps_at = eps[j]

    row = {
        'material': cfg.get('material', 'UNKNOWN'),
        'mode': mode,
        'source': src,
        'enz_target_THz': enz_target,
        'enz_est_THz': enz_est,
        'enz_method': method,
        'enz_delta_THz': delta,
        'enz_tolerance_THz': tol,
        'enz_gate': 'PASS' if passed else 'FAIL',
        'eps_re_at_target': float(np.real(eps_at)),
        'eps_im_at_target': float(np.imag(eps_at)),
    }

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)
    pd.DataFrame([row]).to_csv(outdir/'material_accuracy.csv', index=False)
    (outdir/'material_accuracy.json').write_text(json.dumps(row, indent=2))
    print(f"[ok] wrote {outdir/'material_accuracy.csv'}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
