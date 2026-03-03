"""SGI run CLI: generates GR worldlines and invokes backends via bridge.

No CAT/EPT equations are implemented here.
"""

from __future__ import annotations
import argparse
from pathlib import Path
import json
import numpy as np

from .sgi_experiment_spec import SGIConfig, Pulse, InitialState, pulses_from_string, pulses_to_string, template_split_mirror_recombine, template_four_pulse_close
from .sgi_worldlines_gr import simulate_1d, simulate_1d_shaped, closure_metrics
from .sgi_closure_solver import solve_by_scaling_last_pulse, solve_by_two_pulse_durations
from .sgi_backend_bridge import run_gr_baseline, run_extended_backend

def _write_csv(path: Path, header, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    import csv
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(list(header))
        for r in rows:
            w.writerow(list(r))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--sgidb", default=None, help="Optional path to SGI sqlite database (built from paper-extracted txt). If provided, exports measured curves into the run folder.")
    ap.add_argument("--backend", default="baseline", choices=["baseline","extended"], help="Which backend to run for phase/visibility (baseline=SR proxy, extended=CAT/EPT adapter).")
    ap.add_argument("--lambda0", type=float, default=None, help="Extended backend: lambda0 (s^-1) overrides preset if set.")
    ap.add_argument("--lambda-preset", default="off", help="Extended backend: named lambda preset.")
    ap.add_argument("--metric-mode", default="minkowski", choices=["minkowski","schwarzschild"], help="Extended backend metric mode.")
    ap.add_argument("--metric-mass-kg", type=float, default=5.972e24, help="Extended backend metric mass (kg) for schwarzschild.")
    ap.add_argument("--dt", type=float, default=1e-6)
    ap.add_argument("--mass-kg", type=float, default=1.0e-26)
    ap.add_argument("--mu-eff", type=float, default=9.2740100783e-24)
    ap.add_argument("--gravity", type=float, default=9.80665)
    ap.add_argument("--init-z", type=float, default=0.0)
    ap.add_argument("--init-v", type=float, default=0.0)
    ap.add_argument("--template", default="custom", choices=["custom","split_mirror_recombine","four_pulse_close"])
    ap.add_argument("--grad", type=float, default=200.0, help="template base gradient (T/m)")
    ap.add_argument("--t1", type=float, default=0.002, help="template duration 1 (s)")
    ap.add_argument("--t2", type=float, default=0.002, help="template duration 2 (s)")
    ap.add_argument("--t3", type=float, default=0.002, help="template duration 3 (s)")
    ap.add_argument("--t4", type=float, default=0.002, help="template duration 4 (s) for four-pulse")
    ap.add_argument("--pulses", default="+200:0.002,-200:0.002,+200:0.002",
                    help="comma list grad_T_per_m:duration_s (used when --template custom)")
    ap.add_argument("--auto-close", action="store_true", help="tune pulse durations to improve closure (GR baseline)")
    ap.add_argument("--auto-close-mode", default="scale_last", choices=["scale_last","two_pulse"], help="closure solver mode")
    ap.add_argument("--close-grid", type=int, default=81, help="grid resolution for closure solver")
    ap.add_argument("--shape", default="none", choices=["none","tanh"], help="pulse edge shaping for GR worldline generation")
    ap.add_argument("--ramp-frac", type=float, default=0.15, help="fraction of pulse duration used for tanh ramps")

    ap.add_argument("--run-extended", action="store_true")
    ap.add_argument("--context-json", default=None, help="optional JSON blob or path passed to extended backend")

    args = ap.parse_args()
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    # Export measured SGI curves (paper-extracted) if sgidb provided
    meas_db_exports = None
    if args.sgidb:
        try:
            from scripts.sgi_db import export_all
            db_path = Path(args.sgidb)
            meas_dir = out_dir / "meas_sgi_db"
            mapping = export_all(db_path, meas_dir)
            meas_db_exports = {"db_path": str(db_path), "export_dir": str(meas_dir), "tables": mapping}
        except Exception as e:
            meas_db_exports = {"error": str(e), "db_path": str(args.sgidb)}

    # Build pulses from template or custom string
    if args.template == "split_mirror_recombine":
        pulses = template_split_mirror_recombine(args.grad, args.t1, args.t2, args.t3)
    elif args.template == "four_pulse_close":
        pulses = template_four_pulse_close(args.grad, args.t1, args.t2, args.t3, args.t4)
    else:
        pulses = pulses_from_string(args.pulses)

    cfg = SGIConfig(
        gravity_m_per_s2=float(args.gravity),
        mu_eff_J_per_T=float(args.mu_eff),
        mass_kg=float(args.mass_kg),
        pulses=pulses,
    )
    init = InitialState(z0_m=float(args.init_z), v0_m_per_s=float(args.init_v))

    # Optional closure tuning (GR baseline only)
    close_info = None
    if args.auto_close and (cfg.pulses is not None) and len(cfg.pulses) > 0:
        if args.auto_close_mode == "two_pulse" and len(cfg.pulses) >= 2:
            res = solve_by_two_pulse_durations(cfg, init, dt_s=float(args.dt), n_grid=int(args.close_grid))
        else:
            res = solve_by_scaling_last_pulse(cfg, init, dt_s=float(args.dt), n_grid=int(args.close_grid))
        cfg = SGIConfig(axis=cfg.axis, gravity_m_per_s2=cfg.gravity_m_per_s2, mu_eff_J_per_T=cfg.mu_eff_J_per_T, mass_kg=cfg.mass_kg, pulses=res.pulses)
        close_info = {
            "mode": args.auto_close_mode,
            "best_metrics": res.metrics,
            "pulses": pulses_to_string(res.pulses),
            "history": res.history,
        }

    world = simulate_1d_shaped(cfg, init, dt_s=float(args.dt), shape=args.shape, ramp_frac=float(args.ramp_frac))
    cm = closure_metrics(world)

    # export trajectories
    for k, wl in world.items():
        _write_csv(out_dir/f"{k}.csv",
                   ["t_s","z_m","v_m_per_s","a_m_per_s2"],
                   zip(wl.t_s, wl.z_m, wl.v_m_per_s, wl.a_m_per_s2))

    # GR baseline
    gr = run_gr_baseline(world, mass_kg=cfg.mass_kg)

    # Extended backend
    ext = None
    if args.run_extended:
        ctx = {}
        if args.context_json:
            # allow JSON string or file path
            p = Path(args.context_json)
            if p.exists():
                ctx = json.loads(p.read_text(encoding="utf-8"))
            else:
                ctx = json.loads(args.context_json)
        ctx.update({"mass_kg": cfg.mass_kg, "mu_eff_J_per_T": cfg.mu_eff_J_per_T, "gravity": cfg.gravity_m_per_s2})
        ext = run_extended_backend(world, context=ctx)

    summary = {
        "closure": cm,
        "gr_baseline": {k: (v.tolist() if hasattr(v, "tolist") else v) for k,v in gr.items()},
        "extended": ext,
    }
    (out_dir/"summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

# Export closure solver history if present
if close_info and close_info.get("history"):
    hist = close_info["history"]
    # write as CSV with union of keys
    keys = sorted({k for row in hist for k in row.keys()})
    import csv
    with (out_dir/"closure_solver_history.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=keys)
        w.writeheader()
        for row in hist:
            w.writerow(row)

    manifest = {
        "artifacts": {
            "arm_plus_csv": str(out_dir/"arm_plus.csv"),
            "arm_minus_csv": str(out_dir/"arm_minus.csv"),
            "summary_json": str(out_dir/"summary.json"),
            "meas_sgi_db_dir": str(out_dir/"meas_sgi_db"),
            "closure_solver_history_csv": str(out_dir/"closure_solver_history.csv"),
        }
    }
    (out_dir/"run_manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")

if __name__ == "__main__":
    main()
