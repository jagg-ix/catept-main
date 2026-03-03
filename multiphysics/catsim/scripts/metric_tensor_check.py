"""Check Paper3 tensor models + correspondence gates.

This script is intended to be lightweight and runnable without EinsteinPy.

It verifies, for Minkowski metric:
  * constant phi => S_{μν} = 0 and Λ_{μν} = 0 for all supported Λ modes
  * constant phi => C = 0 and curvature(Gamma) == curvature(Gamma~)
  * linear phi => provides diagnostics for (∇^μ Λ_{μν}) residuals per mode

We do NOT claim any Λ mode is the unique physical choice; the point is to make
the choices explicit and gated.
"""

from __future__ import annotations

import json
from pathlib import Path

import sympy as sp

from catsim_core.config import get_nested, load_config
from catsim_core.metric.curvature import ricci_tensor_from_connection
from catsim_core.metric.entropic_connection import EntropicConnectionModel, entropic_christoffels
from catsim_core.metric.entropic_tensors import (
    christoffel_symbols,
    covariant_divergence_cov2,
    entropic_stress_tensor,
    imaginary_curvature_tensor,
    inverse_metric,
)
from catsim_core.metric.gates_metric_limits import gate_connection_curvature_equivalence, gate_tensor_equilibrium


def _max_abs(m: sp.Matrix) -> float:
    return float(max(abs(complex(sp.N(v))) for v in list(m)))


def main() -> int:
    cfg_path = Path("configs/paper3_tensors.yaml")
    cfg = load_config(cfg_path) if cfg_path.exists() else {}

    lam_mode = get_nested(cfg, "lambda_tensor", "mode", default="trace_adjusted")
    lam_alpha = float(get_nested(cfg, "lambda_tensor", "alpha", default=0.25))
    tol = float(get_nested(cfg, "gates", "tol", default=1e-12))

    ent_time_enabled = bool(get_nested(cfg, "entropic_time", "enabled", default=False))
    lam_const = float(get_nested(cfg, "entropic_time", "lambda_const_s_inv", default=1.0))

    outdir = Path("PAPER_TABLES/ADVANCED/GEOMETRIC_TENSORS")
    outdir.mkdir(parents=True, exist_ok=True)

    t, x, y, z = sp.symbols("t x y z", real=True)
    tau = sp.symbols("tau", real=True)

    # Base coordinates/metric
    coords = (t, x, y, z)
    g = sp.diag(-1, 1, 1, 1)

    # Optional demo: allow entropic time coordinate in tensor evaluation by
    # reparameterizing the time coordinate for constant lambda: d tau = lambda dt.
    # For Minkowski this rescales g_tt -> g_tau_tau = -1/lambda^2.
    if ent_time_enabled:
        coords = (tau, x, y, z)
        g = sp.diag(-1 / (lam_const**2), 1, 1, 1)
    g_inv = inverse_metric(g)
    Gamma = christoffel_symbols(g, coords)

    # Supported Λ modes: run all, but highlight the configured mode.
    lambda_modes = ["hessian", "trace_adjusted", "einstein_like", "trace_adjusted_weighted"]

    # --- constant phi: correspondence gates should pass for all supported modes
    phi0 = sp.Integer(2)
    S0 = entropic_stress_tensor(phi0, g, coords)
    constant_phi_gates = {}
    for mode in lambda_modes:
        if mode == "trace_adjusted_weighted":
            Lam0 = imaginary_curvature_tensor(phi0, g, coords, mode=mode, alpha=lam_alpha)
        else:
            Lam0 = imaginary_curvature_tensor(phi0, g, coords, mode=mode)
        gate = gate_tensor_equilibrium(S=S0, Lambda=Lam0, tol=tol)
        constant_phi_gates[mode] = {"passed": bool(gate.passed), **gate.details}

    # --- connection-curvature equivalence: constant phi => C=0 => Ricci match
    grad0 = [sp.diff(phi0, c) for c in coords]
    C0 = EntropicConnectionModel(mode="non_metricity").c_tensor(g=g, g_inv=g_inv, grad_phi_cov=grad0)
    Gamma_tilde0 = entropic_christoffels(Gamma=Gamma, C=C0)
    Ric0 = ricci_tensor_from_connection(Gamma=Gamma, coords=coords)
    RicT0 = ricci_tensor_from_connection(Gamma=Gamma_tilde0, coords=coords)
    gate_conn0 = gate_connection_curvature_equivalence(Ricci_base=Ric0, Ricci_tilde=RicT0, tol=tol)

    # --- linear phi diagnostics (sanity: not equilibrium)
    phi1 = x
    S1 = entropic_stress_tensor(phi1, g, coords)
    linear_phi = {"max_abs_S": _max_abs(S1)}
    for mode in lambda_modes:
        if mode == "trace_adjusted_weighted":
            Lam1 = imaginary_curvature_tensor(phi1, g, coords, mode=mode, alpha=lam_alpha)
        else:
            Lam1 = imaginary_curvature_tensor(phi1, g, coords, mode=mode)
        div = covariant_divergence_cov2(Lam1, g=g, coords=coords, Gamma=Gamma)
        linear_phi[f"max_abs_Lambda_{mode}"] = _max_abs(Lam1)
        linear_phi[f"max_abs_divLambda_{mode}"] = _max_abs(div)

    summary = {
        "config": {
            "paper3_tensors_config": str(cfg_path) if cfg_path.exists() else None,
            "lambda_mode_preference": lam_mode,
            "lambda_alpha": lam_alpha,
            "tensors_entropic_time_enabled": ent_time_enabled,
            "lambda_const_s_inv": lam_const if ent_time_enabled else None,
            "tol": tol,
        },
        "constant_phi_gates": constant_phi_gates,
        "connection_equilibrium_gate": {"passed": bool(gate_conn0.passed), **gate_conn0.details},
        "linear_phi_diagnostics": linear_phi,
    }
    (outdir / "summary.json").write_text(json.dumps(summary, indent=2), encoding="utf-8")

    status_lines = [
        "# GEOMETRIC_TENSORS STATUS",
        f"preferred_lambda_mode: {lam_mode}",
        f"entropic_time_enabled: {ent_time_enabled}",
        f"connection_equilibrium_pass: {gate_conn0.passed}",
    ]
    for mode in lambda_modes:
        status_lines.append(f"constant_phi_gate_{mode}_pass: {constant_phi_gates[mode]['passed']}")
    (outdir / "STATUS.md").write_text("\n".join(status_lines) + "\n", encoding="utf-8")

    all_const_ok = all(v["passed"] for v in constant_phi_gates.values())
    return 0 if (all_const_ok and gate_conn0.passed) else 2


if __name__ == "__main__":
    raise SystemExit(main())
