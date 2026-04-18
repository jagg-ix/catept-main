#!/usr/bin/env python3
"""PySCF -> catsim interoperability demo (optional).

Builds a RHF Fock matrix via PySCF and exports a Hamiltonian timeline CSV.

This demo produces a *contract* that other engines in the repo can ingest:
  - t_s
  - tau_ent_s
  - lambda_s_inv
  - H_R(t) (Fock) exported via catsim_core.export.timeline

It also supports the repo's optional spacetime coupling layer:
  lambda_eff = lambda_base * redshift * (1 + efe_gain * residual)
where the residual is, by default, a cheap proxy derived from a phi(t) profile.

No baseline optics simulations depend on this demo.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.export.timeline import export_hamiltonian_timeline_csv
from catsim_core.gates.status import write_status
from catsim_core.pyscf.adapter import PySCFMoleculeSpec, build_contract_from_pyscf, pyscf_available
from catsim_core.fields.phi_profile import PhiProfile
from catsim_core.spacetime.coupler import build_coupler_from_config, export_spacetime_coupler_csv


def _load_yaml(path: Path) -> dict:
    try:
        import yaml  # type: ignore
    except Exception as e:
        raise RuntimeError("PyYAML required for --config") from e
    return yaml.safe_load(path.read_text()) or {}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="", help="Optional YAML config (overrides CLI args)")
    ap.add_argument("--out", required=True)
    ap.add_argument("--atom", default="H 0 0 0; H 0 0 0.74")
    ap.add_argument("--basis", default="sto-3g")
    ap.add_argument("--n", type=int, default=50)
    ap.add_argument("--lambda", dest="lambda_val", type=float, default=1.0)
    args = ap.parse_args()

    outdir = Path(args.out)
    outdir.mkdir(parents=True, exist_ok=True)

    if not pyscf_available():
        write_status(outdir, ok=False, status="SKIP", details="PySCF not available")
        (outdir / "summary.json").write_text(json.dumps({"status": "SKIP", "reason": "PySCF not available"}, indent=2))
        return 0

    cfg = {}
    if str(args.config).strip():
        cfg = _load_yaml(Path(args.config))

    # Time grid
    t_max_s = float(cfg.get("time", {}).get("t_max_s", 1e-12)) if cfg else 1e-12
    n = int(cfg.get("time", {}).get("n_steps", args.n)) if cfg else args.n
    t_s = np.linspace(0.0, t_max_s, n)

    # Molecule
    atom = str(cfg.get("system", {}).get("atom", args.atom)) if cfg else args.atom
    basis = str(cfg.get("system", {}).get("basis", args.basis)) if cfg else args.basis
    spec = PySCFMoleculeSpec(atom=atom, basis=basis)

    # Lambda model: const or phi-profile
    lam0 = float(cfg.get("lambda_model", {}).get("lambda_const_s_inv", args.lambda_val)) if cfg else float(args.lambda_val)
    phi_csv = str(cfg.get("lambda_model", {}).get("phi_profile_csv", "")) if cfg else ""

    profile = None
    if phi_csv.strip():
        profile = PhiProfile.from_csv(phi_csv)

    def lambda_base(t: float) -> float:
        if profile is None:
            return float(lam0)
        return float(profile.lambda_eff(float(t)))

    # Provide a cheap residual proxy from the phi-profile derivative if present
    def efe_residual_proxy(t: float) -> float:
        if profile is None:
            return 0.0
        return float(abs(profile.dphi_dt(float(t))))

    coupler = build_coupler_from_config(
        cfg=cfg,
        lambda_base=lambda_base,
        efe_residual_provider=efe_residual_proxy,
        redshift_provider=None,
    )

    lambda_s_inv = np.asarray([float(coupler.lambda_eff(float(t))) for t in t_s], dtype=float)
    dt = float(t_s[1] - t_s[0]) if len(t_s) > 1 else 0.0
    tau_ent_s = np.cumsum(lambda_s_inv) * dt

    contract = build_contract_from_pyscf(
        spec=spec,
        t_s=t_s,
        tau_ent_s=tau_ent_s,
        lambda_s_inv=lambda_s_inv,
        name="pyscf_rhf_demo",
        meta={"atom": atom, "basis": basis},
    )
    export_hamiltonian_timeline_csv(contract, outdir / "hamiltonian_timeline.csv")

    export_spacetime_coupler_csv(
        out_csv=str(outdir / "spacetime_coupler.csv"),
        t_s=[float(x) for x in np.asarray(t_s, dtype=float)],
        coupler=coupler,
    )

    write_status(outdir, ok=True, status="PASS", details="PySCF contract exported")
    (outdir / "summary.json").write_text(json.dumps({"status": "PASS", "dim": contract.dim, "n": len(t_s)}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
