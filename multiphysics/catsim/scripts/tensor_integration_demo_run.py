"""Run the Paper3 tensor integration demo.

This is a lightweight kernel-level run that produces a timeline CSV containing
  t_s, tau_ent_s, lambda_s_inv, and selected tensor components.

It uses configs/paper3_tensors.yaml to select Lambda_{mu nu} construction mode
and whether tensors should be evaluated in an entropic-time coordinate.
"""

from __future__ import annotations

from catsim_core.scenario.tensor_integration_demo import TensorIntegrationDemoScenario


def main() -> int:
    sc = TensorIntegrationDemoScenario()
    return sc.run()


if __name__ == "__main__":
    raise SystemExit(main())
