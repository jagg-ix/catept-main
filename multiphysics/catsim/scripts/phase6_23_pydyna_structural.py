#!/usr/bin/env python3
"""Phase 6.23 — pydyna structural adapter + CAT/EPT timeline.

This phase is a *safe* first step for integrating `ansys/pydyna`:

* Soft-import `pydyna` (SKIP if not available).
* Always export the entropic-time contract:
    t_s, tau_ent_s, lambda_eff_s_inv
* Provide a tiny structural placeholder observable (`load_scale`) that can be
  consumed by other modules (e.g., coupling into EM/quantum runs).

No LS-DYNA model is constructed here; the goal is to establish a stable bridge
surface and artifacts without disrupting Tirole baselines.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.structural.pydyna_bridge import PydynaCATBridge, PydynaCATConfig
from catsim_core.spacetime.coupler import SpacetimeCoupler
from catsim_core.spacetime.metric_presets import make_redshift_provider


def _write_status(out_dir: Path, status: str, details: dict) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "STATUS.md").write_text(
        f"# Phase 6.23 — pydyna Structural Adapter\n\nStatus: **{status}**\n\n" + json.dumps(details, indent=2) + "\n",
        encoding="utf-8",
    )
    (out_dir / "summary.json").write_text(json.dumps(details, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str, required=True)
    ap.add_argument("--dt_s", type=float, default=1e-6)
    ap.add_argument("--t_end_s", type=float, default=1e-3)
    ap.add_argument("--lambda_const", type=float, default=0.0)
    ap.add_argument("--metric_preset", type=str, default="identity")
    ap.add_argument("--g_m_s2", type=float, default=9.81)
    ap.add_argument("--z0_m", type=float, default=0.0)
    ap.add_argument("--z_m", type=float, default=0.0)
    ap.add_argument("--c_m_s", type=float, default=299792458.0)
    ap.add_argument("--cat_ept_mode", type=int, default=0)
    args = ap.parse_args()

    out_dir = Path(args.out)

    redshift_provider = make_redshift_provider(
        preset=str(args.metric_preset),
        preset_kwargs={
            "g_m_s2": float(args.g_m_s2),
            "z0_m": float(args.z0_m),
            "z_m": float(args.z_m),
            "c_m_s": float(args.c_m_s),
        },
    )
    coupler = SpacetimeCoupler(
        lambda_base=lambda t: float(args.lambda_const),
        redshift_fn=redshift_provider,
        efe_gain=0.0,
    )

    bridge = PydynaCATBridge(
        cfg=PydynaCATConfig(enabled=True, dt_s=float(args.dt_s), t_end_s=float(args.t_end_s)),
        coupler=coupler,
    )
    artifacts = bridge.run_demo(cat_ept_mode=bool(int(args.cat_ept_mode)))

    # CSV export
    out_dir.mkdir(parents=True, exist_ok=True)
    csv_path = out_dir / "pydyna_timeline.csv"
    with csv_path.open("w", encoding="utf-8") as f:
        f.write("t_s,tau_ent_s,lambda_eff_s_inv,load_scale\n")
        for tt, ta, la, ls in zip(
            artifacts["t_s"],
            artifacts["tau_ent_s"],
            artifacts["lambda_eff_s_inv"],
            artifacts["load_scale"],
        ):
            f.write(f"{float(tt):.18e},{float(ta):.18e},{float(la):.18e},{float(ls):.18e}\n")

    status = "PASS" if artifacts.get("pydyna_available", False) else "SKIP"
    details = {
        "phase": "6.23",
        "pydyna_available": bool(artifacts.get("pydyna_available", False)),
        "cat_ept_mode": bool(int(args.cat_ept_mode)),
        "metric_preset": str(args.metric_preset),
        "dt_s": float(args.dt_s),
        "t_end_s": float(args.t_end_s),
        "lambda_const": float(args.lambda_const),
        "artifacts": {
            "csv": str(csv_path.name),
        },
        "notes": "Demo runner only; stable integration point for future real pydyna models.",
    }

    _write_status(out_dir, status, details)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
