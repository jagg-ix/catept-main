#!/usr/bin/env python3
"""Phase 6.16 — MEEP↔PySCF bridge smoke test with CAT/EPT timeline.

This phase is intentionally lightweight:

* If PySCF is available, compute a small polarizability proxy and map it to a
  baseline epsilon.
* If MEEP is available, demonstrate that epsilon can be converted into a
  meep.Medium (no long FDTD run by default).
* Always export a CAT/EPT timeline contract:
    t_s, tau_ent_s, lambda_eff_s_inv, epsilon_t

The phase is considered PASS if it produced the CSV/summary artifacts. If one
or both optional dependencies are missing, it is SKIP (but still emits files).
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np

from catsim_core.data_sources.export import write_data_sources_json

from catsim_core.spacetime.coupler import SpacetimeCoupler
from catsim_core.spacetime.metric_presets import make_redshift_provider
from cat_ept_doubleslit.numerics.cfl_clock import CFLClock
from cat_ept_doubleslit.integration.meep_pyscf_bridge import (
    has_meep,
    has_pyscf,
    PySCFMaterialModel,
    build_epsilon_timeline,
    make_meep_medium_from_epsilon,
)


def _make_time_grid(
    *,
    t_final_s: float,
    n_hint: int,
    lambda_eff_fn,
    use_cfl_clock: bool,
    dx_m: float | None,
    a_max: float | None,
    cfl_max: float,
    alpha_scheme: float,
    dt_max: float | None,
    n_max: int,
) -> np.ndarray:
    """Generate a time grid.

    Default behavior (use_cfl_clock=True) reuses the repo's CFLClock step
    controller: enforce stability in coordinate time dt, then integrate
    tau_ent via lambda_eff.

    If dx_m is None, CFLClock falls back to the dissipation stability guard.
    """
    t_final = float(t_final_s)
    if t_final <= 0:
        raise ValueError("t_final_s must be > 0")

    # Baseline uniform step (for reproducibility / as a fallback)
    n_hint = max(int(n_hint), 2)
    dt_uniform = t_final / float(n_hint - 1)

    if not use_cfl_clock:
        return np.linspace(0.0, t_final, n_hint, dtype=float)

    clock = CFLClock(
        dx=float(dx_m) if dx_m is not None else None,
        a_max_default=float(a_max) if a_max is not None else None,
        cfl_max=float(cfl_max),
        alpha_scheme=float(alpha_scheme),
    )

    t_list: list[float] = [0.0]
    t = 0.0
    # Stop if we would exceed a hard cap; keep runs bounded.
    for _ in range(int(n_max)):
        if t >= t_final:
            break
        lam = float(lambda_eff_fn(t))
        # Suggest dt using CFL + dissipation guards, else fall back.
        dt_s = clock.suggest_dt(a_max=float(a_max) if (dx_m is not None and a_max is not None) else None, lambda_max=lam)
        dt = float(dt_s) if dt_s is not None else float(dt_uniform)
        if dt_max is not None:
            dt = min(dt, float(dt_max))
        # Never allow a zero/negative step.
        dt = max(dt, 1e-30)
        t_next = t + dt
        if t_next > t_final:
            t_next = t_final
        t_list.append(t_next)
        t = t_next
        if t >= t_final:
            break

    # Ensure we hit the final time.
    if t_list[-1] < t_final:
        t_list.append(t_final)

    return np.asarray(t_list, dtype=float)


def _write_status(out_dir: Path, status: str, details: dict) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "STATUS.md").write_text(
        f"# Phase 6.16 — MEEP↔PySCF Bridge\n\nStatus: **{status}**\n\n" + json.dumps(details, indent=2) + "\n",
        encoding="utf-8",
    )
    (out_dir / "summary.json").write_text(json.dumps(details, indent=2) + "\n", encoding="utf-8")
    # Deterministic provenance for offline/repro bundles.
    write_data_sources_json(out_dir / "data_sources.json", repo_root=repo_root)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str, required=True)
    ap.add_argument("--t_final_s", type=float, default=2e-12)  # 2 ps
    ap.add_argument("--n", type=int, default=400)
    ap.add_argument("--lambda_const", type=float, default=1.0e12)
    ap.add_argument("--efe_gain", type=float, default=0.0)
    ap.add_argument("--metric_preset", type=str, default="identity")
    ap.add_argument("--g_m_s2", type=float, default=9.81)
    ap.add_argument("--z0_m", type=float, default=0.0)
    ap.add_argument("--z_m", type=float, default=0.0)
    ap.add_argument("--c_m_s", type=float, default=299792458.0)
    # CFLClock reuse (default ON)
    ap.add_argument("--use_cfl_clock", type=int, default=1)
    ap.add_argument("--dx_m", type=float, default=0.0)
    ap.add_argument("--a_max", type=float, default=3.0e8)
    ap.add_argument("--cfl_max", type=float, default=0.9)
    ap.add_argument("--alpha_scheme", type=float, default=1.0)
    ap.add_argument("--dt_max", type=float, default=0.0)
    ap.add_argument("--n_max", type=int, default=5000)
    args = ap.parse_args()

    out_dir = Path(args.out)

    # Coupler provides lambda_eff(t) (optionally metric/efe-modulated).
    # Default redshift provider is identity unless a metric preset is enabled.
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
        efe_gain=float(args.efe_gain),
    )

    dx_m = None if float(args.dx_m) <= 0.0 else float(args.dx_m)
    a_max = None if float(args.a_max) <= 0.0 else float(args.a_max)
    dt_max = None if float(args.dt_max) <= 0.0 else float(args.dt_max)
    t_s = _make_time_grid(
        t_final_s=float(args.t_final_s),
        n_hint=int(args.n),
        lambda_eff_fn=coupler.lambda_eff,
        use_cfl_clock=bool(int(args.use_cfl_clock)),
        dx_m=dx_m,
        a_max=a_max,
        cfl_max=float(args.cfl_max),
        alpha_scheme=float(args.alpha_scheme),
        dt_max=dt_max,
        n_max=int(args.n_max),
    )
    tau, lam, eps_t = build_epsilon_timeline(
        t_s=t_s,
        lambda_eff_fn=coupler.lambda_eff,
        model=PySCFMaterialModel(),
        alpha_proxy=None,
    )

    # Export contract CSV
    csv_path = out_dir / "epsilon_timeline.csv"
    out_dir.mkdir(parents=True, exist_ok=True)
    with csv_path.open("w", encoding="utf-8") as f:
        f.write("t_s,tau_ent_s,lambda_eff_s_inv,epsilon\n")
        for tt, ta, la, ee in zip(t_s, tau, lam, eps_t):
            f.write(f"{tt:.18e},{ta:.18e},{la:.18e},{ee:.18e}\n")

    meep_ok = False
    medium_repr = None
    if has_meep():
        try:
            med = make_meep_medium_from_epsilon(float(eps_t[0]))
            medium_repr = repr(med)
            meep_ok = True
        except Exception as e:
            medium_repr = f"meep_available_but_failed: {e}"

    status = "PASS"
    if (not has_meep()) or (not has_pyscf()):
        status = "SKIP"

    details = {
        "phase": "6.16",
        "status": status,
        "has_meep": bool(has_meep()),
        "has_pyscf": bool(has_pyscf()),
        "produced": [str(csv_path.name), "summary.json", "STATUS.md"],
        "meep_medium_created": bool(meep_ok),
        "meep_medium_repr": medium_repr,
        "n_hint": int(args.n),
        "n": int(t_s.size),
        "t_final_s": float(args.t_final_s),
        "lambda_const": float(args.lambda_const),
        "efe_gain": float(args.efe_gain),
        "metric_preset": str(args.metric_preset),
        "metric_kwargs": {"g_m_s2": float(args.g_m_s2), "z0_m": float(args.z0_m), "z_m": float(args.z_m), "c_m_s": float(args.c_m_s)},
        "use_cfl_clock": bool(int(args.use_cfl_clock)),
        "dx_m": dx_m,
        "a_max": a_max,
        "cfl_max": float(args.cfl_max),
        "alpha_scheme": float(args.alpha_scheme),
        "dt_max": dt_max,
        "n_max": int(args.n_max),
    }
    _write_status(out_dir, status, details)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
