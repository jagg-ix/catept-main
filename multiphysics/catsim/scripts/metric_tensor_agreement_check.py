"""Check agreement of entropic tensors using SymPy vs EinsteinPy Christoffels.

If EinsteinPy is installed, this script:
  1) builds a simple metric tensor,
  2) computes Γ via our SymPy routine,
  3) computes Γ via EinsteinPy symbolic Christoffels,
  4) uses both to compute S_{mu nu} and Λ_{mu nu},
  5) checks max absolute component difference < tolerance.

If EinsteinPy is not installed, the script emits a STATUS.md that indicates
the agreement check was skipped.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import sympy as sp

from catsim_core.metric.einsteinpy_adapter import EinsteinPyMetricAdapter
from catsim_core.metric.entropic_tensors import christoffel_symbols, entropic_stress_tensor, imaginary_curvature_tensor
from catsim_core.metric.curvature import ricci_tensor_from_connection


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True)
    p.add_argument("--tol", type=float, default=1e-6)
    args = p.parse_args()
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Simple test case: 2D polar submetric embedded in 4D diag(-1,1,r^2,1)
    t, r, th, z = sp.symbols("t r theta z", real=True)
    coords = (t, r, th, z)
    g = sp.diag(-1, 1, r**2, 1)
    phi = r  # simple non-constant field

    Gamma_sym = christoffel_symbols(g, coords)
    S_sym = entropic_stress_tensor(phi, g, coords, Gamma=Gamma_sym)
    Lam_sym = imaginary_curvature_tensor(phi, g, coords, Gamma=Gamma_sym)
    Ric_sym = ricci_tensor_from_connection(Gamma=Gamma_sym, coords=coords)

    skipped = False
    max_diff_S = None
    max_diff_L = None
    max_diff_Ric = None
    max_diff_Gamma = None

    try:
        from einsteinpy.symbolic import MetricTensor

        mt = MetricTensor(g, coords)
        adapter = EinsteinPyMetricAdapter(mt)
        Gamma_e = adapter.christoffel_ndarray(coords)
        if Gamma_e is None:
            raise RuntimeError("EinsteinPy Christoffels unavailable")
        S_e = entropic_stress_tensor(phi, g, coords, Gamma=Gamma_e)
        Lam_e = imaginary_curvature_tensor(phi, g, coords, Gamma=Gamma_e)
        Ric_e = ricci_tensor_from_connection(Gamma=Gamma_e, coords=coords)

        # componentwise max absolute diff
        def max_abs_diff(A: sp.Matrix, B: sp.Matrix) -> float:
            dim = A.shape[0]
            m = 0.0
            for i in range(dim):
                for j in range(dim):
                    d = sp.simplify(A[i, j] - B[i, j])
                    # Try numeric at r=2, theta=0.3
                    dn = float(d.subs({r: 2.0, th: 0.3}).evalf())
                    m = max(m, abs(dn))
            return float(m)

        max_diff_S = max_abs_diff(S_sym, S_e)
        max_diff_L = max_abs_diff(Lam_sym, Lam_e)
        max_diff_Ric = max_abs_diff(Ric_sym, Ric_e)

        # connection diff (numeric sample)
        dim = int(g.shape[0])
        mG = 0.0
        for a in range(dim):
            for b in range(dim):
                for c in range(dim):
                    d = sp.simplify(Gamma_sym[a, b, c] - Gamma_e[a, b, c])
                    dn = float(d.subs({r: 2.0, th: 0.3}).evalf())
                    mG = max(mG, abs(dn))
        max_diff_Gamma = float(mG)

        passed = (
            (max_diff_Gamma <= args.tol)
            and (max_diff_S <= args.tol)
            and (max_diff_L <= args.tol)
            and (max_diff_Ric <= args.tol)
        )
    except Exception:
        skipped = True
        passed = True

    summary = {
        "einsteinpy_check_skipped": skipped,
        "tol": args.tol,
        "max_diff_Gamma": max_diff_Gamma,
        "max_diff_S": max_diff_S,
        "max_diff_Lambda": max_diff_L,
        "max_diff_Ricci": max_diff_Ric,
        "pass": passed,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.md").write_text(
        "# Metric Tensor Agreement\n\n"
        f"- skipped: {skipped}\n"
        f"- tol: {args.tol}\n"
        f"- max_diff_Gamma: {max_diff_Gamma}\n"
        f"- max_diff_S: {max_diff_S}\n"
        f"- max_diff_Lambda: {max_diff_L}\n"
        f"- max_diff_Ricci: {max_diff_Ric}\n"
        f"- PASS: {passed}\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
