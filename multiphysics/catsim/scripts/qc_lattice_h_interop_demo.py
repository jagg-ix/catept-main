#!/usr/bin/env python3
"""QC_lattice_H -> catsim interoperability demo (optional).

Outputs a Hamiltonian timeline CSV using the standard contract columns:
  t_s, tau_ent_s, lambda_s_inv, plus H_ij_re/im.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.export.timeline import export_hamiltonian_timeline_csv
from catsim_core.gates.status import write_status
from catsim_core.qc_lattice_h.adapter import QCLatticeHModel, build_contract_from_qc_lattice_h, qc_lattice_h_available


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    ap.add_argument("--n", type=int, default=200)
    ap.add_argument("--lambda", dest="lambda_val", type=float, default=1.0)
    args = ap.parse_args()

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    if not qc_lattice_h_available():
        write_status(outdir, ok=False, status="SKIP", details="QC_lattice_H not available")
        (outdir / "summary.json").write_text(json.dumps({"status": "SKIP", "reason": "QC_lattice_H not available"}, indent=2))
        return 0

    # Minimal demo builder: users should supply their own builder; here we just
    # produce a tiny 2x2 placeholder Hamiltonian that is compatible with the
    # contract.
    def demo_builder(params):
        w = float(params.get("w", 1.0))
        g = float(params.get("g", 0.1))
        return np.array([[0.0, g], [g, w]], dtype=float)

    model = QCLatticeHModel(build_hamiltonian=demo_builder, base_params={"w": 1.0, "g": 0.1})
    t_s = np.linspace(0.0, 1e-12, args.n)
    lam = float(args.lambda_val)
    lambda_s_inv = np.full_like(t_s, lam, dtype=float)
    tau_ent_s = np.cumsum(lambda_s_inv) * (t_s[1] - t_s[0])

    contract = build_contract_from_qc_lattice_h(
        model=model,
        t_s=t_s,
        tau_ent_s=tau_ent_s,
        lambda_s_inv=lambda_s_inv,
        param_schedule=None,
        name="qc_lattice_h_demo",
        meta={"note": "Replace demo_builder with real QC_lattice_H builder"},
    )

    export_hamiltonian_timeline_csv(contract, outdir / "hamiltonian_timeline.csv")
    write_status(outdir, ok=True, status="PASS", details="QC_lattice_H contract exported")
    (outdir / "summary.json").write_text(json.dumps({"status": "PASS", "dim": contract.dim, "n": len(t_s)}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
