"""Sanity check for the adaptive entropic stepping controller.

Validates the Paper3 Section 6.4 stepping rule implemented in
`catsim_core.clock.step_control.choose_entropic_step`.

We check two cases:
  1) dtau_target small enough => no reductions
  2) dtau_target too large => reductions occur but CFL passes
"""

from __future__ import annotations

import json
from pathlib import Path

from catsim_core.clock.step_control import choose_entropic_step


def main() -> int:
    outdir = Path("PAPER_TABLES/ADVANCED/ENTROPIC_STEP")
    outdir.mkdir(parents=True, exist_ok=True)

    # Use a toy CFL bound: dx=1m => max_dt ~ 3.3ns
    dx = 1.0
    lam = 1e9  # 1/s

    case1 = choose_entropic_step(dtau_target=1e-3, lambda_bar=lam, dx=dx)
    case2 = choose_entropic_step(dtau_target=10.0, lambda_bar=lam, dx=dx)

    summary = {
        "case1": case1.__dict__,
        "case2": case2.__dict__,
        "notes": {
            "expect_case1_reductions": 0,
            "expect_case2_reductions_ge1": True,
        },
    }
    (outdir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")
    status_lines = [
        "# ENTROPIC_STEP STATUS",
        f"case1_passed_cfl: {case1.passed_cfl}",
        f"case1_n_reductions: {case1.n_reductions}",
        f"case2_passed_cfl: {case2.passed_cfl}",
        f"case2_n_reductions: {case2.n_reductions}",
    ]
    (outdir / "STATUS.md").write_text("\n".join(status_lines) + "\n", encoding="utf-8")

    ok = case1.passed_cfl and case1.n_reductions == 0 and case2.passed_cfl and case2.n_reductions >= 1
    return 0 if ok else 2


if __name__ == "__main__":
    raise SystemExit(main())
