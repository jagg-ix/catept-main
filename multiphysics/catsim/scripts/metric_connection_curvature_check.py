"""Check curvature equivalence under the entropic connection toggle.

Paper3 correspondence principle: in equilibrium (\nabla\phi = 0), the entropic
correction tensor C must vanish, hence \tilde\Gamma = \Gamma and curvature must
match. We test this at the Ricci-tensor level.

This script is lightweight (pure SymPy) and does not require EinsteinPy.
"""

from __future__ import annotations

import json
from pathlib import Path

import sympy as sp

from catsim_core.metric.curvature import ricci_tensor_from_connection
from catsim_core.metric.entropic_connection import EntropicConnectionModel, entropic_christoffels
from catsim_core.metric.entropic_tensors import christoffel_symbols, inverse_metric
from catsim_core.metric.gates_metric_limits import gate_connection_curvature_equivalence


def main() -> int:
    outdir = Path("PAPER_TABLES/ADVANCED/CONNECTION_CURVATURE")
    outdir.mkdir(parents=True, exist_ok=True)

    t, x, y, z = sp.symbols("t x y z", real=True)
    coords = (t, x, y, z)

    # Minkowski signature (-,+,+,+) so Levi-Civita Christoffels are 0.
    g = sp.diag(-1, 1, 1, 1)
    g_inv = inverse_metric(g)
    Gamma = christoffel_symbols(g, coords)

    # equilibrium case: constant phi => grad = 0 => C = 0
    phi0 = sp.Integer(7)
    grad0 = [sp.diff(phi0, c) for c in coords]
    C0 = EntropicConnectionModel(mode="non_metricity").c_tensor(g=g, g_inv=g_inv, grad_phi_cov=grad0)
    Gamma_tilde0 = entropic_christoffels(Gamma=Gamma, C=C0)
    Ric0 = ricci_tensor_from_connection(Gamma=Gamma, coords=coords)
    RicT0 = ricci_tensor_from_connection(Gamma=Gamma_tilde0, coords=coords)
    gate0 = gate_connection_curvature_equivalence(Ricci_base=Ric0, Ricci_tilde=RicT0, tol=1e-12)

    # non-equilibrium sanity: linear phi => C != 0 generally => curvature differs
    phi1 = x
    grad1 = [sp.diff(phi1, c) for c in coords]
    C1 = EntropicConnectionModel(mode="non_metricity").c_tensor(g=g, g_inv=g_inv, grad_phi_cov=grad1)
    Gamma_tilde1 = entropic_christoffels(Gamma=Gamma, C=C1)
    RicT1 = ricci_tensor_from_connection(Gamma=Gamma_tilde1, coords=coords)

    # Diagnostics
    def max_abs(m: sp.Matrix) -> float:
        return float(max(abs(complex(sp.N(v))) for v in list(m)))

    summary = {
        "equilibrium_gate": {"passed": bool(gate0.passed), **gate0.details},
        "non_equilibrium_max_abs_Ricci_tilde": max_abs(RicT1),
    }
    (outdir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

    status = [
        "# CONNECTION_CURVATURE STATUS",
        f"equilibrium_gate_pass: {gate0.passed}",
        f"max_abs_Ricci_diff_equilibrium: {gate0.details.get('max_abs_Ricci_diff')}",
        f"max_abs_Ricci_tilde_linear_phi: {summary['non_equilibrium_max_abs_Ricci_tilde']}",
    ]
    (outdir / "STATUS.md").write_text("\n".join(status) + "\n", encoding="utf-8")

    return 0 if gate0.passed else 2


if __name__ == "__main__":
    raise SystemExit(main())
