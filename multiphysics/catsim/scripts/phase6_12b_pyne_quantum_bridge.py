#!/usr/bin/env python3

"""Phase 6.12b: PyNE -> (EinsteinPy/Complex-EFE scalars) -> QuTiP/PySCF interop.

This phase demonstrates that *PyNE-produced rates* can drive the repo's quantum
engines using the same CAT/EPT timeline contract (t_s, tau_ent_s, lambda_s_inv).

Design:
  - Always runs without PyNE installed (uses analytic decay constant).
  - If QuTiP is installed, runs a tiny qubit demo evolution using lambda_eff(t).
  - If PySCF is installed, emits a Hamiltonian contract scaled by redshift.
  - If EinsteinPy/OGRePy are installed, their scalars can be injected via the
    repo's SpacetimeCoupler providers (kept optional).
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict

import numpy as np

from catsim_core.export.timeline import export_timeseries_csv, export_hamiltonian_timeline_csv
from catsim_core.pyne.adapter import build_pyne_decay_timeseries
from catsim_core.pyne.bridge import PyNEBridgeConfig, build_pyne_spacetime_coupler, compute_tau_ent_from_lambda
from catsim_core.spacetime.coupler import export_spacetime_coupler_csv


def _load_cfg(path: str) -> Dict[str, Any]:
    import yaml

    with open(path, "r") as f:
        return yaml.safe_load(f) or {}


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="configs/pyne_bridge.yaml")
    ap.add_argument("--out", default="PAPER_TABLES/ADVANCED/PYNE_BRIDGE")
    args = ap.parse_args()

    cfg = _load_cfg(args.config)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)

    # Time grid (coordinate time)
    t0 = float(cfg.get("t0_s", 0.0))
    t1 = float(cfg.get("t1_s", 1e-3))
    n = int(cfg.get("n_steps", 400))
    t_s = np.linspace(t0, t1, n)

    bridge_cfg = PyNEBridgeConfig(
        half_life_s=float(cfg.get("half_life_s", 1e-3)),
        nuclide=str(cfg.get("nuclide", "X")),
        n0=float(cfg.get("n0", 1.0)),
        spacetime=cfg.get("spacetime", None),
    )

    # Providers are optional; for now we leave them None (identity redshift, no residual).
    probe, coupler = build_pyne_spacetime_coupler(cfg=cfg, bridge_cfg=bridge_cfg)

    # Effective lambda profile for this run
    lambda_eff = np.array([coupler.lambda_eff(float(tt)) for tt in t_s], dtype=float)
    tau_ent = compute_tau_ent_from_lambda(t_s=t_s, lambda_fn=coupler.lambda_eff)

    # Export coupler diagnostics
    export_spacetime_coupler_csv(out_csv=str(out_dir / "spacetime_coupler.csv"), t_s=t_s, coupler=coupler)

    # Build decay probe timeseries
    ts = build_pyne_decay_timeseries(
        probe=probe,
        t_s=t_s,
        tau_ent_s=tau_ent,
        lambda_s_inv=lambda_eff,
        name="pyne_decay_probe",
        meta={"note": "Driven by SpacetimeCoupler.lambda_eff"},
    )
    export_timeseries_csv(contract=ts, path=out_dir / "pyne_decay_timeseries.csv")

    # Optional: QuTiP demonstration
    qutip_ok = False
    qutip_msg = "SKIP"
    try:
        from cat_ept_doubleslit.open_quantum.qutip_backend import evolve_complex_action_variable_lambda_t

        # 2-level toy system: H_R = 0.5 * sigma_z, J = I
        H_R = np.array([[0.5, 0.0], [0.0, -0.5]], dtype=float)
        J = np.eye(2, dtype=float)
        psi0 = np.array([1.0, 0.0], dtype=complex)
        res, lam_vals, tau_vals = evolve_complex_action_variable_lambda_t(
            H_R=H_R,
            J=J,
            psi0=psi0,
            tlist_s=t_s,
            lambda_fn=coupler.lambda_eff,
            hbar=float(cfg.get("hbar", 1.0)),
            normalize_output=bool(cfg.get("qutip_normalize", False)),
            e_ops={"pop0": np.array([[1.0, 0.0], [0.0, 0.0]]), "pop1": np.array([[0.0, 0.0], [0.0, 1.0]])},
        )

        # Export a compact expectation trace
        import csv

        with (out_dir / "qutip_expect.csv").open("w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["t_s", "tau_ent_s", "lambda_s_inv", "pop0", "pop1"])
            pop0 = res.expect.get("pop0", np.zeros_like(t_s))
            pop1 = res.expect.get("pop1", np.zeros_like(t_s))
            for i in range(len(t_s)):
                w.writerow([float(t_s[i]), float(tau_vals[i]), float(lam_vals[i]), float(pop0[i]), float(pop1[i])])

        qutip_ok = True
        qutip_msg = "PASS"
    except Exception as e:
        qutip_msg = f"SKIP: {e.__class__.__name__}"

    # Optional: PySCF demo contract export (reuse existing adapter if present)
    pyscf_ok = False
    pyscf_msg = "SKIP"
    try:
        from catsim_core.pyscf.adapter import pyscf_available, PySCFMoleculeSpec, build_contract_from_pyscf

        if pyscf_available():
            # Scale by redshift factor (identity if no metric provider)
            def scale_fn(tt: float) -> float:
                return float(coupler.redshift_factor(tt))

            spec = PySCFMoleculeSpec(
                atom=str(cfg.get("pyscf_molecule", "H 0 0 0; H 0 0 0.74")),
                basis=str(cfg.get("pyscf_basis", "sto-3g")),
            )
            Hc = build_contract_from_pyscf(
                spec=spec,
                t_s=t_s,
                tau_ent_s=tau_ent,
                lambda_s_inv=lambda_eff,
                name="pyscf_rhf_scaled",
                meta={"note": "Scaled by SpacetimeCoupler.redshift_factor"},
            )
            # Apply scalar redshift scaling to all matrices
            mats = np.asarray(Hc.matrices, dtype=complex)
            scales = np.asarray([scale_fn(float(tt)) for tt in t_s], dtype=float)
            mats2 = mats * scales[:, None, None]
            Hc2 = Hc.__class__(
                name=Hc.name,
                t_s=Hc.t_s,
                tau_ent_s=Hc.tau_ent_s,
                lambda_s_inv=Hc.lambda_s_inv,
                matrices=mats2,
                basis_labels=Hc.basis_labels,
                meta={**(Hc.meta or {}), "applied_redshift": True},
            )
            export_hamiltonian_timeline_csv(Hc2, out_dir / "pyscf_hamiltonian_timeline.csv")
            pyscf_ok = True
            pyscf_msg = "PASS"
        else:
            pyscf_msg = "SKIP: pyscf not installed"
    except Exception as e:
        pyscf_msg = f"SKIP: {e.__class__.__name__}"

    summary = {
        "phase": "6.12b",
        "name": "pyne_quantum_bridge",
        "config": args.config,
        "nuclide": probe.nuclide,
        "half_life_s": probe.half_life_s,
        "lambda_eff_min": float(np.min(lambda_eff)),
        "lambda_eff_max": float(np.max(lambda_eff)),
        "qutip": {"status": qutip_msg, "ok": bool(qutip_ok)},
        "pyscf": {"status": pyscf_msg, "ok": bool(pyscf_ok)},
        "outputs": [
            "spacetime_coupler.csv",
            "pyne_decay_timeseries.csv",
            "qutip_expect.csv" if qutip_ok else None,
            "pyscf_hamiltonian_timeline.csv" if pyscf_ok else None,
        ],
    }

    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    status = "PASS" if (qutip_ok or pyscf_ok) else "SKIP"
    (out_dir / "STATUS.md").write_text(f"# Phase 6.12b PyNE bridge\n\nStatus: **{status}**\n\n" + json.dumps(summary, indent=2))

    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
