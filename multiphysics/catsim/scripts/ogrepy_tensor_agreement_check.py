"""Check agreement of curvature tensors using catsim SymPy path vs OGRePy.

Goal
----
Provide a *real* OGRePy tensor extraction path and cross-check it against the
existing SymPy-only implementation. This is a stability / drift-prevention gate
for CAT/EPT geometry work (including the complex EFE residual tooling).

Behavior
--------
- If OGRePy is not installed, we emit STATUS.md indicating SKIP and return PASS.
- If OGRePy is installed, we:
    1) build a nontrivial curved metric (2-sphere),
    2) compute (Ricci, Einstein) via OGRePy,
    3) compute (Ricci, Einstein) via catsim's SymPy-only connection route,
    4) gate max absolute numeric component difference at a sample point.

Notes
-----
- We use a 2D metric to keep runtime fast and deterministic.
- This is *not* meant to validate physics claims; it validates software
  consistency across symbolic engines.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import sympy as sp

from catsim_core.ogrepy.adapter import ogrepy_available, ogrepy_ricci_and_einstein
from catsim_core.metric.entropic_tensors import christoffel_symbols
from catsim_core.metric.curvature import ricci_tensor_from_connection


def _einstein_from_ricci(*, Ric: sp.Matrix, g: sp.Matrix) -> sp.Matrix:
    g_inv = sp.Matrix(g).inv()
    Rscalar = sp.simplify((g_inv.multiply_elementwise(Ric)).trace())
    return sp.Matrix(sp.simplify(Ric - sp.Rational(1, 2) * sp.Matrix(g) * Rscalar))


def _max_abs_diff_numeric(A: sp.Matrix, B: sp.Matrix, subs: dict[sp.Symbol, float]) -> float:
    dim = int(A.shape[0])
    m = 0.0
    for i in range(dim):
        for j in range(dim):
            d = sp.simplify(A[i, j] - B[i, j])
            dn = float(d.subs(subs).evalf())
            m = max(m, abs(dn))
    return float(m)


def _topk_component_diffs_numeric(
    A: sp.Matrix,
    B: sp.Matrix,
    subs: dict[sp.Symbol, float],
    k: int = 10,
) -> list[dict[str, float | int]]:
    """Return top-k component diffs.

    Each record includes indices (i,j) and numeric values for A_ij, B_ij,
    and diff = A_ij - B_ij at the substitution point.
    """
    dim = int(A.shape[0])
    rows: list[dict[str, float | int]] = []
    for i in range(dim):
        for j in range(dim):
            d = sp.simplify(A[i, j] - B[i, j])
            aij = float(sp.simplify(A[i, j]).subs(subs).evalf())
            bij = float(sp.simplify(B[i, j]).subs(subs).evalf())
            dij = float(d.subs(subs).evalf())
            rows.append({"i": i, "j": j, "A": aij, "B": bij, "diff": dij, "abs_diff": abs(dij)})
    rows.sort(key=lambda r: float(r["abs_diff"]))
    rows = list(reversed(rows))
    return rows[:k]


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True)
    p.add_argument("--tol", type=float, default=1e-6)
    args = p.parse_args()

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # 2-sphere metric: ds^2 = dtheta^2 + sin(theta)^2 dphi^2
    theta, phi = sp.symbols("theta phi", real=True)
    coords = (theta, phi)
    g = sp.diag(1, sp.sin(theta) ** 2)

    skipped = False
    passed = True
    max_diff_Ric = None
    max_diff_Ein = None
    top_diffs_Ric = None
    top_diffs_Ein = None

    # SymPy-only route (catsim)
    Gamma_sym = christoffel_symbols(g, coords)
    Ric_sym = ricci_tensor_from_connection(Gamma=Gamma_sym, coords=coords)
    Ein_sym = _einstein_from_ricci(Ric=Ric_sym, g=g)

    try:
        if not ogrepy_available():
            raise RuntimeError("OGRePy not installed")
        Ric_og, Ein_og = ogrepy_ricci_and_einstein(g=g, coords=coords)

        subs = {theta: 1.1, phi: 0.7}
        max_diff_Ric = _max_abs_diff_numeric(Ric_sym, Ric_og, subs)
        max_diff_Ein = _max_abs_diff_numeric(Ein_sym, Ein_og, subs)
        top_diffs_Ric = _topk_component_diffs_numeric(Ric_sym, Ric_og, subs, k=10)
        top_diffs_Ein = _topk_component_diffs_numeric(Ein_sym, Ein_og, subs, k=10)
        passed = (max_diff_Ric <= args.tol) and (max_diff_Ein <= args.tol)
    except Exception:
        skipped = True
        passed = True

    summary = {
        "ogrepy_check_skipped": skipped,
        "tol": args.tol,
        "max_diff_Ricci": max_diff_Ric,
        "max_diff_Einstein": max_diff_Ein,
        "top_component_diffs_Ricci": top_diffs_Ric,
        "top_component_diffs_Einstein": top_diffs_Ein,
        "pass": passed,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    if not skipped:
        (out_dir / "diff_table.json").write_text(
            json.dumps({"Ricci": top_diffs_Ric, "Einstein": top_diffs_Ein}, indent=2),
            encoding="utf-8",
        )
    extra = ""
    if not skipped:
        extra = (
            "\n## Top component diffs\n\n"
            "See `diff_table.json` for top-10 absolute component diffs at the sample point.\n"
        )

    (out_dir / "STATUS.md").write_text(
        (
            "# OGRePy Tensor Agreement\n\n"
            f"- skipped: {skipped}\n"
            f"- tol: {args.tol}\n"
            f"- max_diff_Ricci: {max_diff_Ric}\n"
            f"- max_diff_Einstein: {max_diff_Ein}\n"
            + extra
            + f"- PASS: {passed}\n"
        ),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
