"""Run galpy CAT/EPT orbit demo through the Scenario/Engine/Clock kernel.

This demo shows how CAT/EPT support for galpy works without complexifying galpy:
  * entropic proper time tau_ent is tracked by the clock
  * optional nonconservative *real* entropic forces (drag) modify the orbit

The script is optional and safe:
  * if galpy is not installed / submodule not initialized, we SKIP (exit 0)
  * it never touches Tirole outputs

Outputs:
  PAPER_TABLES/ADVANCED/GALPY_CAT_EPT/
    - timeline.csv (includes t_s, tau_ent_s, lambda_s_inv)
    - STATUS.md
    - summary.json
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
from glob import glob

from catsim_core.config import load_config, get_nested


def _ensure_dir(path: str) -> None:
    os.makedirs(path, exist_ok=True)


def _try_enable_submodule(repo_root: str) -> None:
    third_party = os.path.join(repo_root, "third_party", "galpy")
    if os.path.isdir(third_party) and third_party not in sys.path:
        sys.path.insert(0, third_party)


def _autodiscover_phi_profile(repo_root: str) -> str:
    """Find a Phase 6.4 Paper3 tensor profile CSV, if one exists.

    Preferred:
      PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES/profiles/tensor_profile_S_500fs.csv
    Fallback:
      first tensor_profile_*.csv in the profiles directory
    """
    profiles_dir = os.path.join(repo_root, "PAPER_TABLES", "ADVANCED", "TENSOR_OBSERVABLES", "profiles")
    if not os.path.isdir(profiles_dir):
        return ""

    preferred = os.path.join(profiles_dir, "tensor_profile_S_500fs.csv")
    if os.path.isfile(preferred):
        return preferred

    # tolerate formatting variants (e.g., S_500.000000fs)
    cand = glob(os.path.join(profiles_dir, "tensor_profile_S_500*fs.csv"))
    if cand:
        return sorted(cand)[0]

    any_prof = glob(os.path.join(profiles_dir, "tensor_profile_*.csv"))
    if any_prof:
        return sorted(any_prof)[0]
    return ""


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", default="configs/galpy_cat_ept.yaml")
    args = ap.parse_args()

    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    _try_enable_submodule(repo_root)

    cfg = load_config(os.path.join(repo_root, args.config))

    out_dir = str(get_nested(cfg, "run", "out_dir", default="PAPER_TABLES/ADVANCED/GALPY_CAT_EPT"))
    dt_s = float(get_nested(cfg, "run", "dt_s", default=1.0e5))
    n_steps = int(get_nested(cfg, "run", "n_steps", default=400))

    ro_kpc = float(get_nested(cfg, "units", "ro_kpc", default=8.0))
    vo_kms = float(get_nested(cfg, "units", "vo_kms", default=220.0))

    st0 = {
        "R": float(get_nested(cfg, "initial_state", "R_ro", default=1.0)),
        "vR": float(get_nested(cfg, "initial_state", "vR_vo", default=0.0)),
        "vT": float(get_nested(cfg, "initial_state", "vT_vo", default=1.0)),
        "phi": float(get_nested(cfg, "initial_state", "phi_rad", default=0.0)),
    }

    cat_enabled = bool(get_nested(cfg, "cat_ept", "enabled", default=True))
    lam_const = float(get_nested(cfg, "cat_ept", "lambda_const_s_inv", default=0.0))
    kappa_drag = float(get_nested(cfg, "cat_ept", "kappa_drag", default=1.0))
    force_mode = str(get_nested(cfg, "cat_ept", "force_mode", default="drag"))

    # grad-phi entropic force params (optional)
    kappa_grad_phi = float(get_nested(cfg, "cat_ept", "grad_phi", "kappa_grad_phi", default=0.0))
    phi_radial_scale_ro = float(get_nested(cfg, "cat_ept", "grad_phi", "phi_radial_scale_ro", default=1.0))
    phi_profile_csv = str(get_nested(cfg, "cat_ept", "grad_phi", "phi_profile_csv", default=""))
    phi_profile_csv = phi_profile_csv.strip()
    eq_expect = bool(get_nested(cfg, "cat_ept", "grad_phi", "equilibrium_expect", default=False))

    tol_invar = float(get_nested(cfg, "gates", "tol_invariance_abs", default=1.0e-10))
    l_min_m = float(get_nested(cfg, "gates", "l_min_m", default=1.0))
    c_m_s = float(get_nested(cfg, "gates", "c_m_s", default=299792458.0))

    _ensure_dir(os.path.join(repo_root, out_dir))

    summary = {
        "config": args.config,
        "out_dir": out_dir,
        "dt_s": dt_s,
        "n_steps": n_steps,
        "ro_kpc": ro_kpc,
        "vo_kms": vo_kms,
        "initial_state": st0,
        "cat_ept": {
            "enabled": cat_enabled,
            "lambda_const_s_inv": lam_const,
            "kappa_drag": kappa_drag,
            "force_mode": force_mode,
            "grad_phi": {
                "kappa_grad_phi": kappa_grad_phi,
                "phi_radial_scale_ro": phi_radial_scale_ro,
                "phi_profile_csv": phi_profile_csv,
                "equilibrium_expect": eq_expect,
            },
        },
        "gates": {"tol_invariance_abs": tol_invar, "l_min_m": l_min_m, "c_m_s": c_m_s},
        "skipped": False,
    }

    try:
        import galpy  # noqa: F401
    except Exception:
        summary["skipped"] = True
        summary["skip_reason"] = "galpy not available (install or init submodule)"
        outp = os.path.join(repo_root, out_dir)
        with open(os.path.join(outp, "summary.json"), "w") as f:
            json.dump(summary, f, indent=2, sort_keys=True)
        with open(os.path.join(outp, "STATUS.md"), "w") as f:
            f.write("# GALPY CAT/EPT demo\n\n- status: SKIP\n")
            f.write(f"- reason: {summary['skip_reason']}\n")
        print(summary["skip_reason"])
        return 0

    from catsim_core.clock.entropic import EntropicProperTimeClock
    from catsim_core.engine.galpy_orbit_cat_ept import GalpyOrbitCATEPTEngine
    from catsim_core.gates.output_schema import gate_has_time_tau_lambda
    from catsim_core.run import ScenarioRunner
    from catsim_core.scenario.galpy_orbit_cat_ept_demo import GalpyOrbitCATEPTScenario
    from cat_ept_doubleslit.clock.entropic_clock import EntropicClock
    from catsim_core.fields.phi_profile import PhiProfile

    # Optional: wire lambda from a phi(t) profile (Phase 6.4 output).
    # If empty, auto-discover a Phase 6.4 tensor profile under PAPER_TABLES/ADVANCED/TENSOR_OBSERVABLES/profiles.
    phi_model = None
    lambda_fn = lambda t, st=None: lam_const
    profile_path = ""
    if not phi_profile_csv:
        profile_path = _autodiscover_phi_profile(repo_root)
        if profile_path:
            # store relative path for provenance
            try:
                phi_profile_csv = os.path.relpath(profile_path, repo_root)
            except Exception:
                phi_profile_csv = profile_path
            summary["cat_ept"]["grad_phi"]["phi_profile_autodiscovered"] = True
            summary["cat_ept"]["grad_phi"]["phi_profile_csv"] = phi_profile_csv
    else:
        profile_path = os.path.join(repo_root, phi_profile_csv) if not os.path.isabs(phi_profile_csv) else phi_profile_csv

    if profile_path:
        if os.path.isfile(profile_path):
            phi_model = PhiProfile.from_csv(profile_path)
            lambda_fn = lambda t, st=None: float(phi_model.lambda_eff(float(t)))
        else:
            summary["cat_ept"]["grad_phi"]["phi_profile_csv_missing"] = True
            summary["cat_ept"]["grad_phi"]["phi_profile_csv_resolved"] = profile_path

    # Clock always provides lambda + dtau (dtau = lambda * dt).
    clock = EntropicProperTimeClock(EntropicClock(lambda_fn=lambda_fn))

    # Engine can still be run in baseline mode by setting cat_ept_enabled=False.
    engine = GalpyOrbitCATEPTEngine(
        ro_kpc=ro_kpc,
        vo_kms=vo_kms,
        cat_ept_enabled=cat_enabled,
        lambda_const_s_inv=lam_const,
        kappa_drag=kappa_drag,
        force_mode=force_mode,
        kappa_grad_phi=kappa_grad_phi,
        phi_radial_scale_ro=phi_radial_scale_ro,
    )

    scenario = GalpyOrbitCATEPTScenario(initial_state=st0, phi_model=phi_model)
    rr = ScenarioRunner(scenario=scenario, engine=engine, clock=clock).run(t0_s=0.0, dt_s=dt_s, n_steps=n_steps)

    # Contract: add tau_ent and lambda fields.
    tau = 0.0
    rows = []
    for row in rr.timeline:
        tau += float(row.get("dtau", 0.0))
        rows.append({**row, "tau_ent_s": float(tau), "lambda_s_inv": float(row.get("lambda_eff", 0.0))})

    schema_gate = gate_has_time_tau_lambda(rows[0].keys())

    # Simple causality/law checks (for constant lambda). If profile-driven lambda, we check only its min/max from timeline.
    lambda_max_allowed = float(c_m_s) / float(l_min_m)
    lam_vals = [float(r.get("lambda_eff", 0.0)) for r in rr.timeline]
    passed_law = (min(lam_vals) >= 0.0) and (max(lam_vals) <= lambda_max_allowed)

    # Toggle invariance: run baseline engine (no entropic force) and compare if cat_ept disabled.
    # We interpret "invariance" as: if enabled=False then drag is zero and state trajectory matches.
    engine_base = GalpyOrbitCATEPTEngine(
        ro_kpc=ro_kpc,
        vo_kms=vo_kms,
        cat_ept_enabled=False,
        lambda_const_s_inv=lam_const,
        kappa_drag=kappa_drag,
        force_mode=force_mode,
        kappa_grad_phi=kappa_grad_phi,
        phi_radial_scale_ro=phi_radial_scale_ro,
    )
    rr_base = ScenarioRunner(scenario=scenario, engine=engine_base, clock=clock).run(t0_s=0.0, dt_s=dt_s, n_steps=n_steps)

    max_dev = 0.0
    for a, b in zip(rr_base.timeline, rr.timeline):
        # Compare the raw state observables produced by the scenario.
        for key in ("R_ro", "vR_vo", "vT_vo", "phi_rad"):
            da = float(a.get(key, 0.0))
            db = float(b.get(key, 0.0))
            max_dev = max(max_dev, abs(da - db))

    # Invariance gates:
    #  (A) strict toggle invariance: if cat_ept.enabled=false, max_dev should be ~0.
    #  (B) optional equilibrium correspondence: if equilibrium_expect=true, we also expect max_dev ~0
    #      even when enabled (e.g., grad-phi with zero gradient).
    invariance_pass = True
    invariance_checked = False
    if not cat_enabled:
        invariance_checked = True
        invariance_pass = max_dev <= tol_invar
    elif eq_expect:
        invariance_checked = True
        invariance_pass = max_dev <= tol_invar

    summary.update(
        {
            "schema_gate": {"passed": bool(schema_gate.passed), "details": schema_gate.details},
            "law_gate": {"passed": bool(passed_law), "lambda_max_allowed": lambda_max_allowed},
            "invariance_gate": {
                "passed": bool(invariance_pass),
                "max_dev": max_dev,
                "tol": tol_invar,
                "checked": bool(invariance_checked),
                "checked_when_disabled": True,
                "checked_when_equilibrium_expect": bool(eq_expect),
            },
        }
    )

    summary["pass"] = bool(schema_gate.passed and passed_law and invariance_pass)

    outp = os.path.join(repo_root, out_dir)

    # Write timeline
    csv_path = os.path.join(outp, "timeline.csv")
    with open(csv_path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        for r in rows:
            w.writerow(r)

    with open(os.path.join(outp, "summary.json"), "w") as f:
        json.dump(summary, f, indent=2, sort_keys=True)

    with open(os.path.join(outp, "STATUS.md"), "w") as f:
        f.write("# GALPY CAT/EPT demo\n\n")
        f.write(f"- pass: {summary['pass']}\n")
        f.write(f"- schema_gate: {summary['schema_gate']['passed']}\n")
        f.write(f"- law_gate: {summary['law_gate']['passed']}\n")
        f.write(f"- invariance_gate: {summary['invariance_gate']['passed']}\n")

    print(f"Wrote GALPY CAT/EPT outputs to {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
