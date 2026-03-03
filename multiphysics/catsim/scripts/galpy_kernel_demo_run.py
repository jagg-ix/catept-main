"""Run galpy orbit demo through the Scenario/Engine/Clock kernel.

This is the "next step" after the standalone galpy demo: use the shared
kernel interfaces so galpy behaves like other optional backends.

The script is intentionally optional:
  * if galpy is not installed or the submodule is not initialized, it writes
    SKIP status and exits with code 0.
  * it never touches the Tirole pipeline outputs.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys


def _ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def _try_enable_submodule(repo_root: str) -> None:
    # Allow running from a bundle or a git checkout with submodules.
    third_party = os.path.join(repo_root, "third_party", "galpy")
    if os.path.isdir(third_party) and third_party not in sys.path:
        sys.path.insert(0, third_party)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="PAPER_TABLES/ADVANCED/GALPY_KERNEL_DEMO")
    ap.add_argument("--dt_s", type=float, default=1.0e5)
    ap.add_argument("--n_steps", type=int, default=200)
    ap.add_argument("--lambda_const", type=float, default=0.0, help="Constant lambda (1/s)")
    ap.add_argument("--clock", choices=["coordinate", "entropic"], default="entropic")
    ap.add_argument("--ro_kpc", type=float, default=8.0)
    ap.add_argument("--vo_kms", type=float, default=220.0)
    args = ap.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    _try_enable_submodule(repo_root)

    out_dir = args.out
    _ensure_dir(out_dir)

    summary = {
        "dt_s": float(args.dt_s),
        "n_steps": int(args.n_steps),
        "lambda_const": float(args.lambda_const),
        "clock": str(args.clock),
        "ro_kpc": float(args.ro_kpc),
        "vo_kms": float(args.vo_kms),
        "skipped": False,
    }

    try:
        # Import galpy; if missing, mark SKIP.
        import galpy  # noqa: F401
    except Exception:
        summary["skipped"] = True
        summary["skip_reason"] = "galpy not available (install or init submodule)"
        with open(os.path.join(out_dir, "summary.json"), "w") as f:
            json.dump(summary, f, indent=2, sort_keys=True)
        with open(os.path.join(out_dir, "STATUS.md"), "w") as f:
            f.write("# GALPY kernel demo\n\n")
            f.write("- status: SKIP\n")
            f.write(f"- reason: {summary['skip_reason']}\n")
        print(summary["skip_reason"])
        return 0

    from catsim_core.clock.coordinate import CoordinateClock
    from catsim_core.clock.entropic import EntropicProperTimeClock
    from catsim_core.engine.galpy_orbit import GalpyOrbitEngine, build_galpy_orbit_series
    from catsim_core.gates.output_schema import gate_has_time_tau_lambda
    from catsim_core.run import ScenarioRunner
    from catsim_core.scenario.galpy_orbit_demo import GalpyOrbitDemoScenario
    from cat_ept_doubleslit.clock.entropic_clock import EntropicClock

    series = build_galpy_orbit_series(
        n_steps=int(args.n_steps),
        dt_s=float(args.dt_s),
        ro_kpc=float(args.ro_kpc),
        vo_kms=float(args.vo_kms),
    )
    engine = GalpyOrbitEngine(series)
    scenario = GalpyOrbitDemoScenario()

    if args.clock == "coordinate":
        clock = CoordinateClock()
    else:
        clock = EntropicProperTimeClock(EntropicClock(lambda_fn=lambda t, st=None: float(args.lambda_const)))

    rr = ScenarioRunner(scenario=scenario, engine=engine, clock=clock).run(t0_s=0.0, dt_s=float(args.dt_s), n_steps=int(args.n_steps))

    # Postprocess kernel timeline into the contract (t, tau_ent, lambda).
    tau = 0.0
    rows = []
    for row in rr.timeline:
        tau += float(row.get("dtau", 0.0))
        rows.append(
            {
                **row,
                "tau_ent_s": float(tau),
                "lambda_s_inv": float(row.get("lambda_eff", 0.0)),
            }
        )

    # Schema gate
    gate = gate_has_time_tau_lambda(rows[0].keys())
    summary["schema_gate"] = {"passed": bool(gate.passed), "details": gate.details}
    summary["pass"] = bool(gate.passed)

    # Write timeline
    csv_path = os.path.join(out_dir, "timeline.csv")
    with open(csv_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        for r in rows:
            w.writerow(r)

    with open(os.path.join(out_dir, "summary.json"), "w") as f:
        json.dump(summary, f, indent=2, sort_keys=True)

    with open(os.path.join(out_dir, "STATUS.md"), "w") as f:
        f.write("# GALPY kernel demo\n\n")
        f.write(f"- pass: {summary['pass']}\n")
        if not gate.passed:
            f.write("- schema gate failed\n")

    print(f"Wrote GALPY kernel demo outputs to {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
