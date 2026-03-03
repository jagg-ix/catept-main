"""Phase 6.14: Complex Schrödinger Functional Scheme (CSF).

This phase implements a 1D complex Schrödinger evolution with
entropic proper time stepping (optional), reusing the repo CFLClock.

Outputs
-------
PAPER_TABLES/ADVANCED/COMPLEX_SCHRODINGER_FUNCTIONAL/
  - csf_curve.csv (t, tau_ent, lambda, norm2)
  - summary.json
  - STATUS.md
"""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np

from cat_ept_doubleslit.numerics.cfl_clock import CFLClock
from catsim_core.qg.complex_schrodinger_functional import CSFConfig, evolve_csf, export_csf_curve_csv


def main() -> int:
    out_dir = Path("PAPER_TABLES/ADVANCED/COMPLEX_SCHRODINGER_FUNCTIONAL")
    out_dir.mkdir(parents=True, exist_ok=True)

    passed = True
    skipped = False
    details = {}

    try:
        cfg = CSFConfig(
            x_min=-5.0,
            x_max=5.0,
            n_x=512,
            t_final_s=1.0e-12,
            n_steps=400,
            scheme="crank_nicolson",
            normalize=False,
        )
        x = np.linspace(cfg.x_min, cfg.x_max, cfg.n_x)
        # initial gaussian
        psi0 = np.exp(-0.5 * (x / 0.5) ** 2).astype(complex)
        psi0 = psi0 / np.sqrt(np.trapezoid(np.abs(psi0) ** 2, x))

        # simple constant lambda for demo
        lam0 = 1.0e12
        lambda_fn = lambda t: lam0

        # reuse CFLClock with dx set to grid spacing; a_max is unknown for Schr,
        # but we can use dissipation guard with lambda_max.
        dx = float(x[1] - x[0])
        cfl = CFLClock(dx=dx, a_max_default=None)

        res = evolve_csf(
            cfg=cfg,
            psi0=psi0,
            integrate_in="tau",
            dtau_target=None,
            cfl=cfl,
            lambda_fn=lambda_fn,
            lambda_max_for_guard=lam0,
        )

        export_csf_curve_csv(
            str(out_dir / "csf_curve.csv"),
            t_s=res["t_s"],
            tau_ent_s=res["tau_ent_s"],
            lambda_s_inv=res["lambda_s_inv"],
            norm2=res["norm2"],
        )

        # gates: second law and finite norms
        if float(np.min(res["lambda_s_inv"])) < 0.0:
            passed = False
            details["second_law"] = "lambda < 0"
        if not np.all(np.isfinite(res["norm2"])):
            passed = False
            details["norm2"] = "non-finite"

    except Exception as e:
        passed = False
        details["error"] = str(e)

    summary = {"skipped": skipped, "pass": passed, "details": details}
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    (out_dir / "STATUS.md").write_text(
        "# Phase 6.14 — Complex Schrödinger Functional\n\n"
        f"- skipped: {skipped}\n"
        f"- PASS: {passed}\n"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
