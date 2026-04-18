#!/usr/bin/env python3
"""Phase 6.6b: Complex EFE equilibrium-limit sanity check.

Goal
----
Verify the *equilibrium limit* stated in the CAT/EPT geometric paper:
  - if the entropic field is constant (\nabla phi = 0), then the entropic stress
    S_{mu nu} vanishes (up to chosen model conventions) and the imaginary
    curvature contribution Lambda_{mu nu} vanishes.

We test this in the simplest setting:
  - Minkowski metric (diag(-1, 1, 1, 1))
  - phi(t,x,y,z) = const
  - T_{mu nu} = 0

Expected:
  - S == 0
  - Lambda == 0
  - residual Frobenius norm == 0

This is a software invariant gate: it ensures the symbolic tensor plumbing
is consistent with the documented equilibrium reduction.
"""

from __future__ import annotations

import json
from pathlib import Path

import sympy as sp

from catsim_core.gates.status import write_status
from catsim_core.ogrepy.complex_efe import complex_efe_residual


def _all_zero(M: sp.Matrix) -> bool:
    for i in range(M.shape[0]):
        for j in range(M.shape[1]):
            if sp.simplify(M[i, j]) != 0:
                return False
    return True


def main() -> int:
    outdir = Path("PAPER_TABLES/ADVANCED/OGREPY_COMPLEX_EFE_EQUILIBRIUM")
    outdir.mkdir(parents=True, exist_ok=True)

    # Coordinates
    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)

    # Minkowski metric (signature - + + +)
    eta = sp.diag(-1, 1, 1, 1)

    # Constant entropic field
    phi0 = sp.Symbol("phi0", real=True)
    phi = phi0

    # Vacuum stress-energy
    T = sp.zeros(4, 4)

    # Compute complex residual and its components
    res = complex_efe_residual(metric=eta, coords=coords, phi=phi, T=T)

    S = res.S
    Lambda = res.Lambda
    R = res.residual
    resid_norm = float(sp.sqrt(sum((sp.simplify(R[i, j]) ** 2) for i in range(4) for j in range(4))))

    ok = _all_zero(S) and _all_zero(Lambda) and _all_zero(R)

    summary = {
        "status": "PASS" if ok else "FAIL",
        "checks": {
            "S_zero": _all_zero(S),
            "Lambda_zero": _all_zero(Lambda),
            "Residual_zero": _all_zero(R),
        },
        "residual_fro_norm": resid_norm,
    }
    (outdir / "summary.json").write_text(json.dumps(summary, indent=2))
    write_status(outdir, ok=ok, status=summary["status"], details="equilibrium limit")

    # Export matrices for debugging
    (outdir / "S_mu_nu.txt").write_text(str(S))
    (outdir / "Lambda_mu_nu.txt").write_text(str(Lambda))
    (outdir / "Residual_mu_nu.txt").write_text(str(R))

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
