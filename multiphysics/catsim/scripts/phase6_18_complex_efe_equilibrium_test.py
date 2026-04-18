"""Phase 6.18: Complex EFE equilibrium-limit test (Paper3).

Goal
----
Provide a *fast* gate confirming the correspondence property:
  phi constant  =>  Λ_{μν} = 0, S_{μν} = 0  => residual norm == 0 (within tol)

This is a regression safety harness for tensor integration paths.

Outputs
-------
PAPER_TABLES/PHASE6_18/
  - complex_efe_equilibrium.csv
  - summary.json
  - STATUS.md
"""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np

from catsim_core.ogrepy.complex_efe_models import get_residual_provider


def main() -> None:
    out_dir = Path("PAPER_TABLES/PHASE6_18")
    out_dir.mkdir(parents=True, exist_ok=True)

    # Minimal local config (no YAML dependency here)
    cfg = {
        "spacetime": {
            "enabled": True,
            "efe": {
                "model": "paper3_v1",
                "metric_kind": "minkowski",
                "phi_expr": "0",  # equilibrium (constant)
                "lambda_mode": "trace_adjusted",
                "kappa": "1",
            },
        }
    }

    provider = get_residual_provider("paper3_v1", cfg)

    t_s = np.linspace(0.0, 1.0, 9)
    r = np.array([provider(float(t)) for t in t_s], dtype=float)

    tol = 1e-10
    passed = bool(np.all(r <= tol))

    # Write CSV
    csv_path = out_dir / "complex_efe_equilibrium.csv"
    with csv_path.open("w", encoding="utf-8") as f:
        f.write("t_s,residual_norm\n")
        for t, rv in zip(t_s, r):
            f.write(f"{float(t)},{float(rv)}\n")

    summary = {
        "phase": "6.18",
        "model": "paper3_v1",
        "metric": "minkowski",
        "phi_expr": "0",
        "tol": tol,
        "max_residual": float(np.max(r)),
        "pass": passed,
    }

    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    status = "PASS" if passed else "FAIL"
    (out_dir / "STATUS.md").write_text(
        f"# Phase 6.18 — Complex EFE equilibrium test\n\nStatus: **{status}**\n\n" + json.dumps(summary, indent=2) + "\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
