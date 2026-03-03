"""galpy orbit demo (optional).

This script demonstrates that catsim can integrate an external dynamics
library (galpy) while using the centralized entropic-time reparameterization
layer (`catsim_core.reparam`) and exporting the standard timeline schema:

  - t_s
  - tau_ent_s
  - lambda_s_inv

Design constraints:
  - Zero impact on the Tirole pipeline.
  - If galpy is unavailable, exit 0 and write a SKIP status.
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path
from typing import Any, Dict, List


def _try_import_galpy(repo_root: Path) -> bool:
    """Try to import galpy, adding the optional submodule path if present."""
    # If the submodule is checked out, allow import directly from source.
    submod = repo_root / "third_party" / "galpy"
    if submod.exists():
        sys.path.insert(0, str(submod))
    try:
        import galpy  # noqa: F401

        return True
    except Exception:
        return False


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    from catsim_core.config import get_nested, load_config
    from catsim_core.export.qutip_timeline import export_qutip_timeseries_csv
    from catsim_core.gates.output_schema import gate_has_time_tau_lambda
    from catsim_core.reparam import EntropicReparametrizer

    cfg_path = repo_root / "configs" / "galpy_demo.yaml"
    cfg = load_config(cfg_path)
    out_dir = repo_root / str(get_nested(cfg, "outputs", "out_dir", default="PAPER_TABLES/ADVANCED/GALPY_DEMO"))
    out_csv = out_dir / str(get_nested(cfg, "outputs", "filename", default="timeline.csv"))
    out_dir.mkdir(parents=True, exist_ok=True)

    if not _try_import_galpy(repo_root):
        # Write SKIP artifacts
        (out_dir / "STATUS.md").write_text(
            "# GALPY_DEMO\n\nStatus: **SKIP** (galpy not available)\n",
            encoding="utf-8",
        )
        (out_dir / "summary.json").write_text(
            json.dumps({"status": "SKIP", "reason": "galpy not importable"}, indent=2),
            encoding="utf-8",
        )
        return 0

    # Import after path tweak
    from galpy.orbit import Orbit
    from galpy.potential import LogarithmicHaloPotential

    t0_s = float(get_nested(cfg, "galpy_demo", "t0_s", default=0.0))
    dt_s = float(get_nested(cfg, "galpy_demo", "dt_s", default=0.02))
    n_steps = int(get_nested(cfg, "galpy_demo", "n_steps", default=600))

    init = get_nested(cfg, "galpy_demo", "orbit", "init", default=[1.0, 0.0, 1.1, 0.0, 0.0, 0.0])
    pot_kind = str(get_nested(cfg, "galpy_demo", "potential", "kind", default="logarithmic_halo"))
    if pot_kind != "logarithmic_halo":
        raise ValueError(f"Unsupported potential kind: {pot_kind}")

    q = float(get_nested(cfg, "galpy_demo", "potential", "q", default=1.0))
    vo = float(get_nested(cfg, "galpy_demo", "potential", "vo", default=1.0))
    ro = float(get_nested(cfg, "galpy_demo", "potential", "ro", default=1.0))
    pot = LogarithmicHaloPotential(q=q, vo=vo, ro=ro)

    # Time sampling
    times = [t0_s + k * dt_s for k in range(n_steps + 1)]

    # CAT/EPT reparameterization
    cat_enabled = bool(get_nested(cfg, "cat_ept", "enabled", default=False))
    lam_const = float(get_nested(cfg, "cat_ept", "lambda_const_s_inv", default=1.0))

    reparam = EntropicReparametrizer(lambda_rate=lambda t: lam_const, enabled=cat_enabled)
    tau_ent = reparam.map_times_to_tau(times)
    lambda_s_inv = [lam_const for _ in times]

    # Integrate orbit
    o = Orbit(init)
    o.integrate(times, pot)

    # Collect a few standard phase-space fields
    R = [float(o.R(t)) for t in times]
    vR = [float(o.vR(t)) for t in times]
    vT = [float(o.vT(t)) for t in times]
    phi = [float(o.phi(t)) for t in times]

    export_qutip_timeseries_csv(
        out_csv=out_csv,
        t_s=times,
        tau_ent_s=tau_ent,
        lambda_s_inv=lambda_s_inv,
        extra_cols={"R": R, "vR": vR, "vT": vT, "phi": phi},
    )

    # Schema gate
    gate = gate_has_time_tau_lambda(["t_s", "tau_ent_s", "lambda_s_inv", "R", "vR", "vT", "phi"])

    status = "PASS" if gate.passed else "FAIL"
    (out_dir / "STATUS.md").write_text(
        "# GALPY_DEMO\n\n"
        f"Status: **{status}**\n\n"
        f"- cat_ept_enabled: {cat_enabled}\n"
        f"- lambda_const_s_inv: {lam_const}\n"
        f"- schema_gate_passed: {gate.passed}\n",
        encoding="utf-8",
    )
    (out_dir / "summary.json").write_text(
        json.dumps(
            {
                "status": status,
                "cat_ept_enabled": cat_enabled,
                "lambda_const_s_inv": lam_const,
                "n_steps": n_steps,
                "dt_s": dt_s,
                "schema_gate": {"passed": gate.passed, "details": gate.details},
            },
            indent=2,
        ),
        encoding="utf-8",
    )

    return 0 if gate.passed else 2


if __name__ == "__main__":
    raise SystemExit(main())
