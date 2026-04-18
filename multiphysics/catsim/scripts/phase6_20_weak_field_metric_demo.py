#!/usr/bin/env python3
"""Phase 6.18 — Weak-field metric preset demo (effective-medium hook).

Goal
----
Provide a conservative, optics-friendly demonstration of "curved spacetime"
coupling without modifying MEEP kernels:

  1) Use a weak-field redshift factor a = sqrt(-g00) from a Newtonian potential
     Phi(z)=g*z.
  2) Feed that into SpacetimeCoupler so backends see
         lambda_eff(t) = lambda_base(t) * a.
  3) Export a small CSV so other phases (MEEP/PySCF/QuTiP) can reuse.

This is intentionally *not* a full GR-Maxwell solver.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.spacetime.coupler import SpacetimeCoupler, export_spacetime_coupler_csv
from catsim_core.spacetime.metric_presets import make_redshift_provider


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str, required=True)
    ap.add_argument("--t_final_s", type=float, default=1e-12)
    ap.add_argument("--n", type=int, default=200)
    ap.add_argument("--lambda_const", type=float, default=1.0e12)
    # Weak field params
    ap.add_argument("--g_m_s2", type=float, default=9.81)
    ap.add_argument("--z_m", type=float, default=1.0)
    ap.add_argument("--z0_m", type=float, default=0.0)
    args = ap.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    redshift_fn = make_redshift_provider(
        preset="weak_field_plane",
        preset_kwargs={"g_m_s2": float(args.g_m_s2), "z_m": float(args.z_m), "z0_m": float(args.z0_m)},
    )
    coupler = SpacetimeCoupler(
        lambda_base=lambda t: float(args.lambda_const),
        redshift_fn=redshift_fn,
        efe_gain=0.0,
        efe_residual_fn=None,
    )

    t_s = np.linspace(0.0, float(args.t_final_s), int(args.n), dtype=float)
    csv_path = out_dir / "spacetime_coupler_weak_field.csv"
    export_spacetime_coupler_csv(out_csv=str(csv_path), t_s=t_s, coupler=coupler)

    details = {
        "phase": "6.18",
        "status": "PASS",
        "produced": [csv_path.name, "summary.json", "STATUS.md"],
        "t_final_s": float(args.t_final_s),
        "n": int(args.n),
        "lambda_const": float(args.lambda_const),
        "metric_preset": "weak_field_plane",
        "g_m_s2": float(args.g_m_s2),
        "z_m": float(args.z_m),
        "z0_m": float(args.z0_m),
        "redshift_factor_at_t0": float(coupler.redshift_factor(0.0)),
    }

    (out_dir / "summary.json").write_text(json.dumps(details, indent=2) + "\n", encoding="utf-8")
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.18 — Weak-field metric preset\n\nStatus: **PASS**\n\n" + json.dumps(details, indent=2) + "\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
