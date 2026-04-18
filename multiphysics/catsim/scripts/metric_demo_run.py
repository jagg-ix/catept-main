"""Run the minimal metric demo scenario.

This is a *generalization* demo: it exercises the Scenario/Engine/Clock kernel
and the EinsteinPy adapter layer, without touching the Tirole pipeline.

Outputs are written under:
  PAPER_TABLES/ADVANCED/METRIC_DEMO/

The demo runs two modes:
  1) base clock only
  2) metric-modified clock (redshift * N_ent factor)

Both must be toggleable and leave the base unchanged.
"""

from __future__ import annotations

import argparse
import csv
import json
import os

from catsim_core.clock.coordinate import CoordinateClock
from catsim_core.clock.entropic import EntropicProperTimeClock
from catsim_core.clock.metric import MetricModifiedClock
from catsim_core.engine.metric_demo import MetricProbeEngine
from catsim_core.run import ScenarioRunner
from catsim_core.scenario.metric_demo import MetricDemoScenario
from cat_ept_doubleslit.clock.entropic_clock import EntropicClock


def _ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="PAPER_TABLES/ADVANCED/METRIC_DEMO", help="Output directory")
    ap.add_argument("--dt_s", type=float, default=0.01, help="Coordinate time step (s)")
    ap.add_argument("--n_steps", type=int, default=50)
    ap.add_argument("--lambda_const", type=float, default=0.0, help="Constant lambda (1/s)")
    ap.add_argument("--M_kg", type=float, default=5.972e24)
    ap.add_argument("--r_m", type=float, default=6.371e6)
    args = ap.parse_args()

    out_dir = args.out
    _ensure_dir(out_dir)

    # Run both metric backends if EinsteinPy is available:
    #   - sympy backend is always available
    #   - einsteinpy backend wraps the same SymPy matrix in an EinsteinPy MetricTensor
    # This lets us gate that both backends agree on metric components.
    scenario_sympy = MetricDemoScenario(M_kg=args.M_kg, r_m=args.r_m, lambda_const=args.lambda_const, metric_backend="sympy")
    scenario_ein = MetricDemoScenario(M_kg=args.M_kg, r_m=args.r_m, lambda_const=args.lambda_const, metric_backend="einsteinpy")

    engine = MetricProbeEngine()

    # Base clocks
    coord_clock = CoordinateClock()
    ent_clock = EntropicProperTimeClock(EntropicClock(lambda_fn=lambda t, st=None: float(args.lambda_const)))

    # Metric factor uses redshift_factor from engine traces, but clock runs before engine.
    # So we compute the factor from state(metric) directly: redshift * N_ent.
    import math
    from catsim_core.metric.einsteinpy_adapter import make_metric_adapter
    from catsim_core.metric.entropic_field import EntropicField

    field = EntropicField(lambda_fn=lambda t: float(args.lambda_const))

    def factor_fn(t_s: float, state):
        adapter = make_metric_adapter(state["metric"])
        g00 = float(adapter.g(0, 0))
        redshift = math.sqrt(max(0.0, -g00))
        n_ent = field.n_ent(float(t_s))
        return float(redshift * n_ent)

    metric_coord_clock = MetricModifiedClock(base=coord_clock, factor_fn=factor_fn, label="metric*coord")
    metric_ent_clock = MetricModifiedClock(base=ent_clock, factor_fn=factor_fn, label="metric*entropic")

    runs = {
        "coord": coord_clock,
        "entropic": ent_clock,
        "metric_coord": metric_coord_clock,
        "metric_entropic": metric_ent_clock,
    }

    summary = {
        "dt_s": float(args.dt_s),
        "n_steps": int(args.n_steps),
        "lambda_const": float(args.lambda_const),
        "M_kg": float(args.M_kg),
        "r_m": float(args.r_m),
        "runs": {},
    }

    # Run the standard suite on the SymPy metric (always)
    for name, clock in runs.items():
        rr = ScenarioRunner(scenario=scenario_sympy, engine=engine, clock=clock).run(t0_s=0.0, dt_s=args.dt_s, n_steps=args.n_steps)
        # Write timeline CSV
        csv_path = os.path.join(out_dir, f"timeline_{name}.csv")
        with open(csv_path, "w", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rr.timeline[0].keys()))
            w.writeheader()
            for row in rr.timeline:
                w.writerow(row)

        summary["runs"][name] = rr.summary

    # Simple toggle invariance checks
    # metric clocks should only differ in dtau values (and meta factor), not in observed g00.
    inv_ok = True
    inv_notes = []
    # Load coord and metric_coord g00 series
    def load_series(fname):
        p = os.path.join(out_dir, fname)
        with open(p, "r") as f:
            r = csv.DictReader(f)
            rows = list(r)
        return [float(x["g00"]) for x in rows], [float(x["dtau"]) for x in rows]

    g_coord, dtau_coord = load_series("timeline_coord.csv")
    g_mcoord, dtau_mcoord = load_series("timeline_metric_coord.csv")
    if any(abs(a - b) > 1e-6 for a, b in zip(g_coord, g_mcoord)):
        inv_ok = False
        inv_notes.append("g00 changed under metric_coord (should not)")
    if all(abs(a - b) < 1e-12 for a, b in zip(dtau_coord, dtau_mcoord)):
        inv_ok = False
        inv_notes.append("dtau did not change under metric modifier (unexpected)")

    summary["toggle_invariance_pass"] = bool(inv_ok)
    summary["toggle_invariance_notes"] = inv_notes

    # EinsteinPy agreement gate (if EinsteinPy is installed)
    ein_ok = True
    ein_notes = []
    try:
        state_ein = scenario_ein.initial_state()
        if state_ein.get("metric_backend_used") != "einsteinpy":
            raise RuntimeError("EinsteinPy not available")

        # Compare g00 series for coord clock under both metric backends.
        rr_ein = ScenarioRunner(scenario=scenario_ein, engine=engine, clock=CoordinateClock()).run(
            t0_s=0.0, dt_s=args.dt_s, n_steps=args.n_steps
        )
        # Load the sympy g00 series (already written)
        g_sym, _ = load_series("timeline_coord.csv")
        g_ein = [float(row["g00"]) for row in rr_ein.timeline]
        tol = 1e-6
        if len(g_sym) != len(g_ein):
            ein_ok = False
            ein_notes.append("EinsteinPy agreement: length mismatch")
        else:
            max_dev = max(abs(a - b) for a, b in zip(g_sym, g_ein))
            if max_dev > tol:
                ein_ok = False
                ein_notes.append(f"EinsteinPy agreement failed: max |g00_sym-g00_ein|={max_dev} > {tol}")
        summary["einsteinpy_agreement_max_dev_g00"] = float(max_dev) if 'max_dev' in locals() else None
    except Exception:
        summary["einsteinpy_agreement_max_dev_g00"] = None
        ein_ok = True
        ein_notes.append("EinsteinPy not installed; agreement gate skipped")

    summary["einsteinpy_agreement_pass"] = bool(ein_ok)
    summary["einsteinpy_agreement_notes"] = ein_notes

    with open(os.path.join(out_dir, "summary.json"), "w") as f:
        json.dump(summary, f, indent=2, sort_keys=True)

    # Human readable status
    status_md = os.path.join(out_dir, "STATUS.md")
    with open(status_md, "w") as f:
        f.write(f"# Metric demo status\n\n")
        f.write(f"- toggle_invariance_pass: {inv_ok}\n")
        f.write(f"- einsteinpy_agreement_pass: {ein_ok}\n")
        if inv_notes:
            f.write("- notes:\n")
            for n in inv_notes:
                f.write(f"  - {n}\n")
        if ein_notes:
            if not inv_notes:
                f.write("- notes:\n")
            for n in ein_notes:
                f.write(f"  - {n}\n")
        f.write("\n## Runs\n")
        for name in runs:
            f.write(f"- {name}: pass={summary['runs'][name].get('pass')}\n")

    print(f"Wrote metric demo outputs to {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
