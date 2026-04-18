"""Run QuTiP complex-action CAT/EPT evolution (optional).

This is an optional backend runner:
  - SKIPs safely if qutip is not installed
  - exports timeline.csv with the standard schema: t_s, tau_ent_s, lambda_s_inv
  - supports profile-driven lambda(t) via Paper3 phi(t) exports (Phase 6.4)

The purpose is to provide a repo-local, reproducible QuTiP integration that
does not touch the Tirole baselines.
"""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
from typing import Any, Dict, Optional

import numpy as np

from catsim_core.export.qutip_timeline import export_qutip_timeseries_csv
from catsim_core.gates.output_schema import gate_has_time_tau_lambda
from catsim_core.fields.phi_profile import PhiProfile
from catsim_core.spacetime.coupler import build_coupler_from_config, export_spacetime_coupler_csv
from catsim_core.data_sources.export import write_data_sources_json


def _try_load_yaml(path: Path) -> Dict[str, Any]:
    try:
        import yaml  # type: ignore
    except Exception:
        raise RuntimeError("PyYAML is required to use config-driven QuTiP runs")
    return yaml.safe_load(path.read_text())


def _discover_tensor_profile_csv(repo_root: Path) -> Optional[Path]:
    profiles_dir = repo_root / "PAPER_TABLES" / "ADVANCED" / "TENSOR_OBSERVABLES" / "profiles"
    if not profiles_dir.exists():
        return None
    # Prefer S=500fs profile if present
    cand = sorted(profiles_dir.glob("tensor_profile_S_500*fs.csv"))
    if cand:
        return cand[0]
    cand = sorted(profiles_dir.glob("tensor_profile_*.csv"))
    if cand:
        return cand[0]
    return None


def _lambda_from_config(cfg: Dict[str, Any], repo_root: Path):
    lm = cfg.get("lambda_model", {})
    phi_csv = str(lm.get("phi_profile_csv", "")).strip()
    auto = bool(lm.get("auto_discover_tensor_profile", True))
    lam0 = float(lm.get("lambda_const_s_inv", 1.0e12))

    profile: Optional[PhiProfile] = None
    profile_path: Optional[Path] = None
    if phi_csv:
        profile_path = Path(phi_csv)
        if not profile_path.is_absolute():
            profile_path = (repo_root / profile_path).resolve()
    elif auto:
        profile_path = _discover_tensor_profile_csv(repo_root)

    if profile_path and profile_path.exists():
        profile = PhiProfile.from_csv(str(profile_path))

    def lambda_base_fn(t_s: float) -> float:
        if profile is None:
            return lam0
        return float(profile.lambda_eff(float(t_s)))

    # Cheap scalar proxy for complex-EFE residual: |dphi/dt|
    # (only used when spacetime coupling is enabled)
    def efe_residual_proxy(t_s: float) -> float:
        if profile is None:
            return 0.0
        return float(abs(profile.dphi_dt(float(t_s))))

    return lambda_base_fn, profile_path, efe_residual_proxy


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--config", default="configs/qutip_cat_ept.yaml")
    args = p.parse_args()

    repo_root = Path(".").resolve()
    cfg = _try_load_yaml(Path(args.config))
    out_dir = Path(cfg.get("out_dir", "PAPER_TABLES/ADVANCED/QUTIP_COMPLEX_ACTION"))
    out_dir.mkdir(parents=True, exist_ok=True)

    skipped = False
    passed = True
    schema_ok = True
    schema_msg = "ok"
    details: Dict[str, Any] = {}

    try:
        import qutip as qt  # noqa: F401
    except Exception:
        skipped = True
        (out_dir / "summary.json").write_text(json.dumps({"skipped": True, "pass": True}, indent=2))
        (out_dir / "STATUS.md").write_text("# QuTiP CAT/EPT\n\n- skipped: true\n- PASS: true\n")
        # Deterministic provenance for offline/repro bundles.
        write_data_sources_json(out_dir / "data_sources.json", repo_root=repo_root)
        return 0

    try:
        from cat_ept_doubleslit.open_quantum.qutip_backend import (
            evolve_complex_action_tau_from_profile,
            evolve_complex_action_variable_lambda_t,
        )

        # --- time grid
        t_max_s = float(cfg.get("time", {}).get("t_max_s", 1.0e-12))
        n_steps = int(cfg.get("time", {}).get("n_steps", 400))
        tlist = np.linspace(0.0, t_max_s, n_steps)

        # --- 2-level toy system
        omega_hz = float(cfg.get("system", {}).get("omega_hz", 1.0e12))
        omega = 2.0 * np.pi * omega_hz
        sigma_z = np.array([[1.0, 0.0], [0.0, -1.0]], dtype=float)
        H_R = (omega / 2.0) * sigma_z
        J = 0.5 * (np.eye(2) - sigma_z)

        lambda_base_fn, profile_path, efe_residual_proxy = _lambda_from_config(cfg, repo_root)
        details["phi_profile_csv"] = str(profile_path) if profile_path else ""

        # --- optional spacetime coupling layer (EinsteinPy / complex-EFE residual)
        coupler = build_coupler_from_config(
            cfg=cfg,
            lambda_base=lambda_base_fn,
            efe_residual_provider=efe_residual_proxy,
            redshift_provider=None,
        )

        def lambda_fn(t_s: float) -> float:
            return float(coupler.lambda_eff(float(t_s)))

        # --- gates: second law
        lam_series = np.asarray([float(lambda_fn(float(t))) for t in tlist], dtype=float)
        if bool(cfg.get("gates", {}).get("enforce_second_law", True)):
            if float(np.min(lam_series)) < 0.0:
                passed = False
                details["second_law"] = "FAIL (lambda < 0)"

        # optional causality bound gate
        if bool(cfg.get("gates", {}).get("enforce_causality_bound", False)):
            c = float(cfg.get("gates", {}).get("c_m_s", 299792458.0))
            lmin = float(cfg.get("gates", {}).get("l_min_m", 1.0e-6))
            if float(np.max(lam_series)) > (c / lmin):
                passed = False
                details["causality_bound"] = "FAIL (lambda exceeds c/l_min)"

        # --- run mode
        integrate_in = str(cfg.get("mode", {}).get("integrate_in", "t")).strip().lower()
        e_ops = {"exp_sigmaz": sigma_z}

        if integrate_in == "tau":
            qres, lam_on_t, tau = evolve_complex_action_tau_from_profile(
                H_R=H_R,
                J=J,
                psi0=np.array([1.0, 0.0], dtype=complex),
                tlist_s=tlist,
                lambda_fn=lambda_fn,
                e_ops=e_ops,
                normalize_output=False,
            )
            # qres.tlist is tau-grid
            exp_sz = qres.expect["exp_sigmaz"]
            t_out = tlist
            tau_out = tau
            lam_out = lam_on_t
        else:
            qres, lam_out, tau_out = evolve_complex_action_variable_lambda_t(
                H_R=H_R,
                J=J,
                psi0=np.array([1.0, 0.0], dtype=complex),
                tlist_s=tlist,
                lambda_fn=lambda_fn,
                e_ops=e_ops,
                normalize_output=False,
            )
            exp_sz = qres.expect["exp_sigmaz"]
            t_out = qres.tlist

        # --- export
        out_csv = out_dir / "timeline.csv"
        export_qutip_timeseries_csv(
            out_csv=out_csv,
            t_s=[float(x) for x in np.asarray(t_out, dtype=float)],
            tau_ent_s=[float(x) for x in np.asarray(tau_out, dtype=float)],
            lambda_s_inv=[float(x) for x in np.asarray(lam_out, dtype=float)],
            expvals={"exp_sigmaz": [float(x) for x in np.asarray(exp_sz, dtype=float)]},
        )

        # Export coupling diagnostics (identity by default)
        export_spacetime_coupler_csv(
            out_csv=str(out_dir / "spacetime_coupler.csv"),
            t_s=[float(x) for x in np.asarray(tlist, dtype=float)],
            coupler=coupler,
        )

        # --- schema gate
        with out_csv.open("r", newline="") as f:
            header = next(csv.reader(f))
        gate = gate_has_time_tau_lambda(header)
        schema_ok, schema_msg = gate.passed, str(gate.details)
        if bool(cfg.get("gates", {}).get("enforce_schema", True)) and not schema_ok:
            passed = False

    except Exception as e:
        passed = False
        schema_ok = False
        schema_msg = f"error: {e}"

    summary = {
        "skipped": skipped,
        "pass": passed,
        "schema_ok": schema_ok,
        "schema_msg": schema_msg,
        "details": details,
    }
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    # Deterministic provenance for offline/repro bundles.
    write_data_sources_json(out_dir / "data_sources.json", repo_root=repo_root)
    (out_dir / "STATUS.md").write_text(
        "# QuTiP CAT/EPT Complex Action\n\n"
        f"- skipped: {skipped}\n"
        f"- schema_ok: {schema_ok} ({schema_msg})\n"
        f"- PASS: {passed}\n"
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
