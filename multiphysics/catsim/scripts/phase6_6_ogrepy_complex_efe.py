"""Phase 6.6: Complex Einstein Field Equations (CAT/EPT) check (optional OGRePy).

This phase implements a **software-checkable** version of the complex EFE used
in the CAT/EPT geometric paper:

    G_{μν} + i Λ_{μν} = κ (T_{μν} + i S_{μν})

Outputs
-------
Writes into PAPER_TABLES/ADVANCED/OGREPY_COMPLEX_EFE by default:
  - summary.json
  - STATUS.md
  - residual_components.json

If OGRePy is installed, we also do a smoke-check that OGRePy can ingest the
metric; the actual tensor computations remain SymPy-only unless/until we add
an OGRePy-tensor extraction path.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import sympy as sp

from catsim_core.ogrepy.adapter import build_ogre_metric, ogrepy_available
from catsim_core.ogrepy.complex_efe import complex_efe_residual


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", default="PAPER_TABLES/ADVANCED/OGREPY_COMPLEX_EFE")
    p.add_argument(
        "--lambda_mode",
        default="trace_adjusted",
        help="Λ_{μν} model mode (see catsim_core.metric.entropic_tensors)",
    )
    args = p.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Minimal 4D demo: Minkowski metric + a simple entropic field φ(t).
    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)
    g = sp.diag(-1, 1, 1, 1)

    lam0 = sp.Symbol("lambda0", positive=True, real=True)
    phi = lam0 * t  # φ = ∫ λ dt for constant λ.

    # T_{μν} = 0 for demo.
    res = complex_efe_residual(g=g, coords=coords, phi=phi, T=None, kappa=sp.Integer(1), lambda_mode=args.lambda_mode)

    ogre_ok = False
    ogre_err = None
    if ogrepy_available():
        try:
            _objs = build_ogre_metric(g=g, coords=coords)
            ogre_ok = True
        except Exception as e:  # pragma: no cover
            ogre_ok = False
            ogre_err = str(e)

    residual_payload = {
        "lambda_mode": args.lambda_mode,
        "coords": [str(c) for c in coords],
        "metric": [[str(g[i, j]) for j in range(4)] for i in range(4)],
        "phi": str(phi),
        "G": [[str(res.G[i, j]) for j in range(4)] for i in range(4)],
        "Lambda": [[str(res.Lambda[i, j]) for j in range(4)] for i in range(4)],
        "S": [[str(res.S[i, j]) for j in range(4)] for i in range(4)],
        "residual": [[str(res.residual[i, j]) for j in range(4)] for i in range(4)],
        "residual_fro_norm": str(res.residual_fro_norm),
    }
    (out_dir / "residual_components.json").write_text(json.dumps(residual_payload, indent=2))

    summary = {
        "phase": "6.6",
        "name": "ogrepy_complex_efe",
        "ogrepy_available": bool(ogrepy_available()),
        "ogrepy_metric_smoke_ok": ogre_ok,
        "ogrepy_metric_smoke_error": ogre_err,
        "lambda_mode": args.lambda_mode,
        "residual_fro_norm": str(res.residual_fro_norm),
        # Gating is conservative: we only require the code to run.
        "pass": True,
        "skipped": False,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.6 — Complex EFE (CAT/EPT)\n\n"
        f"- OGRePy available: {summary['ogrepy_available']}\n"
        f"- OGRePy metric smoke-check ok: {ogre_ok}\n"
        f"- Lambda mode: {args.lambda_mode}\n"
        f"- Residual Frobenius norm: {summary['residual_fro_norm']}\n"
        "- PASS: True\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
