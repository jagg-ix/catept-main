"""Run the kernel entropic step demo scenario.

Usage:
  python scripts/entropic_step_demo_run.py --out PAPER_TABLES/ADVANCED/ENTROPIC_STEP_DEMO
"""

from __future__ import annotations

import argparse
from pathlib import Path

from catsim_core.scenario.entropic_step_demo import EntropicStepDemoConfig, EntropicStepDemoScenario


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out", required=True)
    p.add_argument("--steps", type=int, default=50)
    p.add_argument("--dtau", type=float, default=1e-15)
    p.add_argument("--dx", type=float, default=1e-6)
    p.add_argument("--lambda0", type=float, default=1e12)
    p.add_argument("--lambda_slope", type=float, default=0.0)
    args = p.parse_args()

    cfg = EntropicStepDemoConfig(
        steps=args.steps,
        dtau_target=args.dtau,
        dx=args.dx,
        lambda0=args.lambda0,
        lambda_slope=args.lambda_slope,
    )
    scen = EntropicStepDemoScenario(cfg)
    scen.run(Path(args.out))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
