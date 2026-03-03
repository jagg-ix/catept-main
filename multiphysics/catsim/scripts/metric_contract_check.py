"""Metric/connection contract checks (optional EinsteinPy bridge).

This script is intentionally lightweight and depends only on SymPy.
If EinsteinPy is installed, it will also attempt a small integration smoke test.

Gates implemented:
  - Equilibrium limit: grad(phi)=0 => imaginary sector off (Eqs. (38)-(40)).
  - Second Law: lambda >= 0 (Eq. (8)).
  - Causality: lambda <= c / l_min (Eq. (7)).

Outputs:
  - PAPER_LOGS/metric_check/summary.json
  - PAPER_LOGS/metric_check/STATUS.md
"""

from __future__ import annotations

import json
from pathlib import Path

import sympy as sp

from catsim_core.metric.gates_metric_limits import (
    gate_causality_bound,
    gate_equilibrium_limit,
    gate_second_law,
)


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    out_dir = root / "PAPER_LOGS" / "metric_check"
    out_dir.mkdir(parents=True, exist_ok=True)

    # Minimal synthetic scenario: Minkowski metric + constant phi
    # grad(phi)=0 should enforce equilibrium-limit gate.
    grad_phi_norm = 0.0
    lambda_min = 0.0
    lambda_max = 1.0
    c_over_lmin = 1.0e43  # paper uses Planck-scale example; we keep it a permissive constant.

    gates = [
        gate_equilibrium_limit(grad_phi_norm=grad_phi_norm),
        gate_second_law(lambda_min=lambda_min),
        gate_causality_bound(lambda_max=lambda_max, c_over_lmin=c_over_lmin),
    ]

    passed_all = all(g.passed for g in gates)
    summary = {
        "passed": bool(passed_all),
        "gates": [
            {"name": g.name, "passed": bool(g.passed), "details": g.details} for g in gates
        ],
        "notes": {
            "sympy": str(sp.__version__),
            "einsteinpy_present": False,
        },
    }

    # Optional EinsteinPy smoke: create a MetricTensor and ensure adapter can read it.
    try:
        from einsteinpy.symbolic import MetricTensor

        t, x, y, z = sp.symbols("t x y z")
        g = sp.diag(-1, 1, 1, 1)
        mt = MetricTensor(g, (t, x, y, z))
        # Access a component
        _ = mt.tensor()[0, 0]
        summary["notes"]["einsteinpy_present"] = True
        summary["notes"]["einsteinpy_smoke"] = "ok"
    except Exception as e:
        summary["notes"]["einsteinpy_smoke"] = f"skipped_or_failed: {type(e).__name__}"

    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    (out_dir / "STATUS.md").write_text(
        "# metric_check\n\n" + ("PASS" if passed_all else "FAIL") + "\n",
        encoding="utf-8",
    )

    return 0 if passed_all else 2


if __name__ == "__main__":
    raise SystemExit(main())
