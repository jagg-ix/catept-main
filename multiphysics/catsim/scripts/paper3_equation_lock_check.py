"""Lock-check a small set of Paper3 equations used by the CAT/EPT metric layer.

This is **not** a full physics validation. It is a software regression check
that the implemented tensors match the explicit algebra we intend to use.

Checks:
  1) For EntropicConnectionModel(mode='non_metricity'), C^λ_{μν} matches the
     Weyl-type connection correction:

       C^λ_{μν} = - (δ^λ_μ ∂_ν φ + δ^λ_ν ∂_μ φ - g_{μν} ∂^λ φ)

  2) For EntropicConnectionModel(mode='metric_compatible'), C is identically 0.

Outputs:
  PAPER_TABLES/ADVANCED/PAPER3_LOCK_CHECK/summary.json
  PAPER_TABLES/ADVANCED/PAPER3_LOCK_CHECK/STATUS.md

This script is designed to be deterministic and fast.
"""

from __future__ import annotations

import json
from pathlib import Path

import sympy as sp

from catsim_core.metric.entropic_connection import EntropicConnectionModel


def _grad_phi_cov(phi: sp.Expr, coords: tuple[sp.Symbol, ...]) -> list[sp.Expr]:
    return [sp.simplify(sp.diff(phi, c)) for c in coords]


def main() -> int:
    out_dir = Path("PAPER_TABLES/ADVANCED/PAPER3_LOCK_CHECK")
    out_dir.mkdir(parents=True, exist_ok=True)

    # Simple 2D Lorentzian test (keeps algebra small)
    t, x = sp.symbols("t x", real=True)
    coords = (t, x)
    g = sp.diag(-1, 1)
    g_inv = g.inv()

    # Pick a φ that depends on both coordinates
    phi = t + 2 * x
    grad_cov = _grad_phi_cov(phi, coords)

    # --- model 1: non-metricity
    model_nm = EntropicConnectionModel(mode="non_metricity")
    C_nm = model_nm.c_tensor(g=g, g_inv=g_inv, grad_phi_cov=grad_cov)

    # Expected by explicit formula
    # Compute ∂^λ φ
    grad_contra = [sp.simplify(sum(g_inv[lam, rho] * grad_cov[rho] for rho in range(2))) for lam in range(2)]
    C_exp = sp.MutableDenseNDimArray.zeros(2, 2, 2)
    for lam in range(2):
        for mu in range(2):
            for nu in range(2):
                d_lm = sp.Integer(1) if lam == mu else sp.Integer(0)
                d_ln = sp.Integer(1) if lam == nu else sp.Integer(0)
                C_exp[lam, mu, nu] = sp.simplify(- (d_lm * grad_cov[nu] + d_ln * grad_cov[mu] - g[mu, nu] * grad_contra[lam]))

    # numeric check at a point
    subs_pt = {t: 1.0, x: 0.25}
    max_abs = 0.0
    for lam in range(2):
        for mu in range(2):
            for nu in range(2):
                d = sp.simplify(C_nm[lam, mu, nu] - C_exp[lam, mu, nu])
                dn = float(d.subs(subs_pt).evalf())
                max_abs = max(max_abs, abs(dn))

    # --- model 2: metric-compatible should be identically zero
    model_mc = EntropicConnectionModel(mode="metric_compatible")
    C_mc = model_mc.c_tensor(g=g, g_inv=g_inv, grad_phi_cov=grad_cov)
    max_abs_mc = 0.0
    for lam in range(2):
        for mu in range(2):
            for nu in range(2):
                dn = float(sp.simplify(C_mc[lam, mu, nu]).subs(subs_pt).evalf())
                max_abs_mc = max(max_abs_mc, abs(dn))

    tol = 1e-12
    passed = (max_abs <= tol) and (max_abs_mc <= tol)
    summary = {
        "tol": tol,
        "max_abs_diff_non_metricity": max_abs,
        "max_abs_metric_compatible": max_abs_mc,
        "pass": passed,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.md").write_text(
        "# Paper3 Lock Check\n\n"
        f"- tol: {tol}\n"
        f"- max_abs_diff_non_metricity: {max_abs}\n"
        f"- max_abs_metric_compatible: {max_abs_mc}\n"
        f"- PASS: {passed}\n"
    )
    return 0 if passed else 2


if __name__ == "__main__":
    raise SystemExit(main())
