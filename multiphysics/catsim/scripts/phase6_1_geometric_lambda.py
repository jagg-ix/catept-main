#!/usr/bin/env python3
"""Phase 6.1 (ADVANCED / proxy): Geometric lambda from group velocity.

Adds two modes (configs/enz_model.yaml):
  - drude: eps(ω) from Drude parameters
  - table: eps(ω) loaded from a CSV (freq_THz, eps_real, eps_imag)

This is a *diagnostic* consistency check, not a claim.
Outputs:
  PAPER_TABLES/ADVANCED/GEOMETRIC_LAMBDA/
    - vg_lambda_vs_freq.csv
    - lambda_eff_by_S.csv
    - summary.json
    - PARAMETERS.txt
    - STATUS.txt
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

from cat_ept_doubleslit.utils.run_id import compute_run_id

from catsim_core.constants import find_repo_root
from catsim_core.data_sources.export import write_data_sources_json

import numpy as np
import pandas as pd

from cat_ept_doubleslit.advanced.enz_dielectric import (
    DrudeParams,
    eps_drude,
    group_velocity,
    load_eps_table,
    omega_grid_from_THz,
)


def _estimate_enz_frequency_THz(freq_THz: np.ndarray, eps: np.ndarray) -> tuple[float, str]:
    """Estimate ENZ frequency from complex permittivity.

    Primary method: find a sign change in Re(eps) and linearly interpolate the zero.
    Fallback method: pick the frequency where |Re(eps)| is minimized.

    Returns:
      (enz_THz, method)
    """
    eps_re = np.real(eps)
    sgn = np.sign(eps_re)

    # Find indices where sign changes between consecutive points
    idx = np.where(sgn[:-1] * sgn[1:] < 0)[0]
    if idx.size > 0:
        i = int(idx[0])
        x0, x1 = float(freq_THz[i]), float(freq_THz[i + 1])
        y0, y1 = float(eps_re[i]), float(eps_re[i + 1])
        # Linear interpolation for y=0
        if y1 != y0:
            xz = x0 - y0 * (x1 - x0) / (y1 - y0)
            return float(xz), 're_zero_cross'

    # Fallback: closest-to-zero real part
    j = int(np.argmin(np.abs(eps_re)))
    return float(freq_THz[j]), 'min_abs_re'


def _load_simple_yaml(path: Path) -> dict:
    out = {}
    for line in path.read_text().splitlines():
        line = line.split('#', 1)[0].strip()
        if not line or ':' not in line:
            continue
        k, v = line.split(':', 1)
        k = k.strip()
        v = v.strip().strip('"').strip("'")
        # try number
        try:
            if any(ch in v for ch in ('.','e','E')):
                out[k] = float(v)
            else:
                out[k] = int(v)
            continue
        except Exception:
            pass
        out[k] = v
    return out


def _read_phase5_lambda(pred_status_json: Path) -> float:
    js = json.loads(pred_status_json.read_text())
    lam = js.get('lambda_ent_best_inv_s')
    if lam is None:
        # older path
        lam = js.get('cat', {}).get('lambda_ent_best_inv_s')
    if lam is None:
        raise ValueError(f"Could not find lambda_ent_best_inv_s in {pred_status_json}")
    return float(lam)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--paper_tables', default='PAPER_TABLES')
    ap.add_argument('--pred_status', default='PAPER_TABLES/PREDICTIONS/status.json')
    ap.add_argument('--spectral_obs', default='PAPER_TABLES/OBSERVABLES/obs_spectral.csv')
    ap.add_argument('--figure', default='Fig_2f')
    ap.add_argument('--config', default='configs/enz_model.yaml')
    ap.add_argument('--carrier_THz', type=float, default=230.2)
    ap.add_argument('--grid_min_THz', type=float, default=190.0)
    ap.add_argument('--grid_max_THz', type=float, default=270.0)
    ap.add_argument('--grid_n', type=int, default=1601)
    args = ap.parse_args()

    outdir = Path(args.paper_tables) / 'ADVANCED' / 'GEOMETRIC_LAMBDA'
    outdir.mkdir(parents=True, exist_ok=True)

    cfg_path = Path(args.config)
    cfg = _load_simple_yaml(cfg_path)
    mode = str(cfg.get('mode', 'drude')).strip()

    # Load Phase 5 fitted scalar lambda
    lam_fit = _read_phase5_lambda(Path(args.pred_status))

    # Build omega grid
    freq_THz = np.linspace(args.grid_min_THz, args.grid_max_THz, args.grid_n)
    omega = omega_grid_from_THz(freq_THz)

    # Compute eps(ω)
    provenance_lines = []
    if mode == 'table':
        table_path = cfg.get('eps_table_csv', '')
        if not table_path:
            raise ValueError("mode=table but eps_table_csv is empty")
        omega_t, eps_t = load_eps_table(table_path)
        # interpolate eps on our grid
        # interpolate real and imag separately in frequency domain
        f_t = omega_t / (2 * math.pi) / 1e12
        eps_re = np.interp(freq_THz, f_t, np.real(eps_t))
        eps_im = np.interp(freq_THz, f_t, np.imag(eps_t))
        eps = eps_re + 1j * eps_im
        provenance_lines += [
            f"mode: table",
            f"eps_table_csv: {table_path}",
        ]
    else:
        p = DrudeParams(
            eps_inf=float(cfg.get('eps_inf', 3.5)),
            omega_p=float(cfg.get('omega_p', 2.5e15)),
            gamma=float(cfg.get('gamma', 1.0e14)),
        )
        eps = eps_drude(omega, p)
        note = str(cfg.get('drude_param_note', '')).strip()
        src = str(cfg.get('drude_param_source', '')).strip()
        provenance_lines += [
            f"mode: drude",
            f"eps_inf: {p.eps_inf}",
            f"omega_p(rad/s): {p.omega_p}",
            f"gamma(rad/s): {p.gamma}",
            f"drude_param_note: {note}" if note else "drude_param_note: (none)",
            f"drude_param_source: {src}" if src else "drude_param_source: (none)",
            "NOTE: Replace Drude numbers with SI/fit values for paper-locked runs.",
        ]

    # ENZ frequency gate: ensure the modeled ENZ point is consistent with the configured anchor.
    enz_cfg_THz = float(cfg.get('enz_frequency_THz', 227.0))
    enz_tol_THz = float(cfg.get('enz_tolerance_THz', 5.0))
    enz_est_THz, enz_method = _estimate_enz_frequency_THz(freq_THz, eps)
    enz_delta_THz = float(abs(enz_est_THz - enz_cfg_THz))
    enz_gate_pass = bool(np.isfinite(enz_est_THz) and enz_delta_THz <= enz_tol_THz)

    provenance_lines += [
        f"enz_frequency_THz(cfg): {enz_cfg_THz}",
        f"enz_tolerance_THz: {enz_tol_THz}",
        f"enz_frequency_THz(est): {enz_est_THz} ({enz_method})",
        f"enz_delta_THz: {enz_delta_THz}",
        f"enz_gate: {'PASS' if enz_gate_pass else 'FAIL'}",
    ]

    vg = group_velocity(omega, eps)

    # geometric lambda proposal: lam_geom(ω)=A/|vg(ω)|, calibrate A using lam_fit at carrier
    carrier_omega = omega_grid_from_THz([args.carrier_THz])[0]
    carrier_vg = float(np.interp(args.carrier_THz, freq_THz, np.abs(vg)))
    if not np.isfinite(carrier_vg) or carrier_vg <= 0:
        raise RuntimeError('carrier_vg invalid; check dielectric config')
    A = lam_fit * carrier_vg
    lam_geom = A / np.abs(vg)

    df = pd.DataFrame({
        'freq_THz': freq_THz,
        'vg_m_per_s': vg,
        'lambda_geom_inv_s': lam_geom,
    })
    df.to_csv(outdir / 'vg_lambda_vs_freq.csv', index=False)

    # Effective lambda per S: weight by baseline spectrum if present
    obs = pd.read_csv(args.spectral_obs)
    # Backwards/forwards compatibility: some bundles use `figure_ref`.
    if 'figure' not in obs.columns and 'figure_ref' in obs.columns:
        obs = obs.rename(columns={'figure_ref': 'figure'})
    if 'S_fs' not in obs.columns and 'slit_separation_fs' in obs.columns:
        obs = obs.rename(columns={'slit_separation_fs': 'S_fs'})
    obs = obs[obs['figure'] == args.figure].copy()
    # effective lam = median( lambda_geom at carrier ) as default; per-S weighting requires spectra artifacts
    obs['lambda_eff_geom_inv_s'] = np.interp(args.carrier_THz, freq_THz, lam_geom)
    obs[['figure','S_fs','lambda_eff_geom_inv_s']].to_csv(outdir / 'lambda_eff_by_S.csv', index=False)

    status = 'PASS' if enz_gate_pass else 'FAIL'
    summary = {
        'mode': mode,
        'carrier_THz': args.carrier_THz,
        'enz_cfg_THz': enz_cfg_THz,
        'enz_est_THz': enz_est_THz,
        'enz_est_method': enz_method,
        'enz_tolerance_THz': enz_tol_THz,
        'enz_delta_THz': enz_delta_THz,
        'enz_gate_status': status,
        'lambda_fit_inv_s': lam_fit,
        'calibration_A': A,
        'carrier_vg_m_per_s': carrier_vg,
        'note': 'ADVANCED proxy diagnostic: geometric lambda from group velocity. Not a claim.'
    }
    # Deterministic run_id (no timestamps): derived from bundle version + inputs.
    repo_root = Path(__file__).resolve().parents[1]
    bv_path = repo_root / 'BUNDLE_VERSION.txt'
    bundle_version = bv_path.read_text().strip() if bv_path.exists() else 'unknown'
    run_id = compute_run_id(
        bundle_version=bundle_version,
        script_id='phase6.1_geometric_lambda',
        db_path=args.spectral_obs,
        config_paths=[cfg_path],
    )
    summary['run_id'] = run_id
    (outdir / 'run_id.txt').write_text(run_id + '\n')

    # Emit a data-source manifest to make runs reproducible.
    # (Vendored tables like constants, and any cached downloads.)
    repo_root = find_repo_root(Path(__file__).resolve())
    ds_path = outdir / 'data_sources.json'
    ds = write_data_sources_json(repo_root=repo_root, out_path=ds_path)
    # Some older implementations of write_data_sources_json write the file and
    # return None. Treat that as an empty manifest for provenance text.
    if ds is None:
        ds = {}
    provenance_lines.append('')
    provenance_lines.append('[data_sources]')
    provenance_lines.append(f"manifest: {ds_path.name}")
    provenance_lines.append(f"items: {len(ds.get('sources', []))}")

    (outdir / 'summary.json').write_text(json.dumps(summary, indent=2))
    (outdir / 'PARAMETERS.txt').write_text("\n".join(provenance_lines) + "\n")
    (outdir / 'STATUS.txt').write_text(status + '\n')
    (outdir / 'STATUS.md').write_text(
        "# Phase 6.1 — Geometric λ diagnostic (ENZ)\n\n"
        f"- mode: `{mode}`\n"
        f"- carrier_THz: {args.carrier_THz}\n"
        f"- enz_frequency_THz (config): {enz_cfg_THz}\n"
        f"- enz_frequency_THz (estimated): {enz_est_THz:.3f} ({enz_method})\n"
        f"- enz_gate: |Δ|={enz_delta_THz:.3f} THz ≤ {enz_tol_THz} THz → **{status}**\n"
        f"- status: **{status}**\n"
        f"- run_id: `{run_id}`\n\n"        "This phase is a diagnostic consistency check (proxy), not a physical claim.\n"
        "See `PARAMETERS.txt` for provenance and `vg_lambda_vs_freq.csv` for curves.\n"
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
