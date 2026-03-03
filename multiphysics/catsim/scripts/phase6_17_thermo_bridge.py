#!/usr/bin/env python3
"""Phase 6.17: Thermodynamics bridge smoke + entropic-time coupling.

Produces:
  PAPER_TABLES/PHASE6/6.17_THERMO/entropy_timeline.csv
  PAPER_LOGS/PHASE6/6.17_THERMO/STATUS.md
  PAPER_LOGS/PHASE6/6.17_THERMO/summary.json

Behavior:
  - If selected engine deps are missing, writes SKIP.
  - Uses existing entropic proper-time contract: t_s, tau_ent_s, lambda_eff_s_inv.
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

from catsim_core.logs.status import write_status_md, write_summary_json
from catsim_core.data_sources.export import write_data_sources_json
from catsim_core.spacetime.coupler import build_coupler_from_config
from cat_ept_doubleslit.numerics.cfl_clock import CFLClock
from cat_ept_doubleslit.thermo import ThermoCATBridge


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out_dir", type=str, default="PAPER_TABLES/PHASE6/6.17_THERMO")
    ap.add_argument("--engine", type=str, default="calphad", choices=["calphad", "thermopack"])
    ap.add_argument("--cat_ept_mode", action="store_true")
    ap.add_argument("--lambda_const_s_inv", type=float, default=1.0e12)
    ap.add_argument("--t_max_s", type=float, default=1.0e-12)
    ap.add_argument("--dt_s", type=float, default=2.5e-15)
    ap.add_argument("--c_m_s", type=float, default=299792458.0)
    ap.add_argument("--l_min_m", type=float, default=1.0e-6)
    ap.add_argument("--T0_K", type=float, default=300.0)
    ap.add_argument("--dT_K", type=float, default=30.0)
    ap.add_argument("--P_Pa", type=float, default=101325.0)
    ap.add_argument("--config", type=str, default="")
    args = ap.parse_args()

    out_dir = Path(args.out_dir)
    log_dir = Path("PAPER_LOGS/PHASE6/6.17_THERMO")
    out_dir.mkdir(parents=True, exist_ok=True)
    log_dir.mkdir(parents=True, exist_ok=True)

    # Build coupler from an optional config, or fall back to constant lambda.
    cfg = {}
    if args.config:
        cfg = json.loads(Path(args.config).read_text(encoding="utf-8")) if args.config.endswith('.json') else {}

    coupler = build_coupler_from_config(cfg, lambda_base=args.lambda_const_s_inv)

    # Reuse the repo's CFL clock to generate a stable time grid.
    clock = CFLClock(c_m_s=args.c_m_s, l_min_m=args.l_min_m, cat_ept_mode=args.cat_ept_mode)
    contract = clock.make_time_contract(t_max_s=args.t_max_s, dt_s=args.dt_s, lambda_eff_fn=coupler.lambda_eff)

    bridge = ThermoCATBridge(engine=args.engine)
    if not bridge.available:
        write_status_md(log_dir / "STATUS.md", phase="6.17_THERMO", status="SKIP",
                        notes=["Thermo engine not available", "Install optional deps: pycalphad or thermopack"])
        write_summary_json(log_dir / "summary.json", {
            "phase": "6.17_THERMO",
            "status": "SKIP",
            "engine": args.engine,
            "cat_ept_mode": args.cat_ept_mode,
            "n_steps": 0,
        })
        return 0

    rows = []
    for t, tau, lam_inv in zip(contract.t_s, contract.tau_ent_s, contract.lambda_eff_s_inv):
        # simple temperature ramp to exercise API
        T = args.T0_K + args.dT_K * (t / max(args.t_max_s, 1e-30))
        res = bridge.entropy(T=T, P=args.P_Pa, t=t)
        lam = 0.0 if lam_inv == 0 else 1.0 / lam_inv
        rows.append({
            "t_s": float(t),
            "tau_ent_s": float(tau),
            "lambda_eff_s_inv": float(lam),
            "T_K": float(T),
            "P_Pa": float(args.P_Pa),
            "entropy_J_per_K": float(res.entropy_J_per_K),
            "engine": args.engine,
            "proxy": str(res.meta.get("proxy", "")),
        })

    out_csv = out_dir / "entropy_timeline.csv"
    with out_csv.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)

    write_status_md(log_dir / "STATUS.md", phase="6.17_THERMO", status="PASS",
                    notes=["Thermo bridge executed", f"engine={args.engine}", f"rows={len(rows)}"])
    write_summary_json(log_dir / "summary.json", {
        "phase": "6.17_THERMO",
        "status": "PASS",
        "engine": args.engine,
        "cat_ept_mode": args.cat_ept_mode,
        "n_steps": len(rows),
        "out_csv": str(out_csv),
        "lambda_const_s_inv": args.lambda_const_s_inv,
    })

    # Deterministic provenance for offline/repro bundles.
    repo_root = Path(__file__).resolve().parents[1]
    write_data_sources_json(log_dir / "data_sources.json", repo_root=repo_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
