"""SGI backend adapter for CAT/EPT-enabled observables.

This adapter is intentionally thin: it does not re-derive CAT/EPT equations.
It uses existing repo modules for:
- Entropic clock integration (lambda(t,x))
- Optional metric redshift factor sqrt(-g00)

Entry point required by `scripts/ui_modules/sgi_backend_bridge.run_extended_backend`:
    compute_sgi_observables(worldlines: Dict[str, Worldline], context: Dict[str,Any]) -> Dict[str,Any]
"""

from __future__ import annotations

from typing import Dict, Any
import numpy as np

from cat_ept_doubleslit.metrics.redshift import minkowski_metric, schwarzschild_metric, kerr_metric, MetricField
from cat_ept_doubleslit.metrics.kerr_observers import KerrParams, dtau_dt_at_x
from catsim_core.spacetime.scene import shift_xyz_by_scene
from scripts.ui_modules.sgi_worldlines_gr import Worldline  # type: ignore

C0 = 299_792_458.0
HBAR = 1.054571817e-34

def _metric_from_context(ctx: Dict[str, Any]) -> MetricField:
    mode = str(ctx.get("metric_mode", "minkowski")).lower()
    if mode == "schwarzschild":
        m = float(ctx.get("metric_mass_kg", 5.972e24))  # Earth mass default
        return schwarzschild_metric(mass_kg=m)
    if mode == "kerr":
        m = float(ctx.get("metric_mass_kg", 5.972e24))
        a_star = float(ctx.get("metric_a_star", 0.0))
        theta_rad = ctx.get("metric_theta_rad", None)
        return kerr_metric(mass_kg=m, a_star=a_star, theta_rad=theta_rad)
    
        m = float(ctx.get("metric_mass_kg", 5.972e24))  # Earth mass default
        return schwarzschild_metric(mass_kg=m)
    return minkowski_metric()

def _lambda0_from_context(ctx: Dict[str, Any]) -> float:
    # allow multiple naming conventions
    for k in ["lambda0", "lambda_const", "lambda_s_inv", "lambda_rate"]:
        if k in ctx and ctx[k] is not None:
            return float(ctx[k])
    return float(ctx.get("lambda0", 0.0))

def _integrate_tau_ent(t: np.ndarray, z: np.ndarray, *, lam0: float, metric: MetricField) -> np.ndarray:
    # integrate dtau_ent = lam_eff(t,x) dt, where lam_eff = lam0 * redshift_factor(t,x)
    # Note: This uses existing MetricField.redshift_factor implementation and does not re-derive it.
    t = np.asarray(t, dtype=float)
    z = np.asarray(z, dtype=float)
    dt = np.diff(t)
    # midpoints
    tmid = 0.5*(t[:-1] + t[1:])
    zmid = 0.5*(z[:-1] + z[1:])
    lam_eff = np.empty_like(tmid)
    for i,(ti,zi) in enumerate(zip(tmid, zmid)):
        fac = metric.redshift_factor(float(ti), np.array([0.0, 0.0, float(zi)]))
        lam_eff[i] = lam0 * fac
    dtau = lam_eff * dt
    return np.concatenate([[0.0], np.cumsum(dtau)])

def compute_sgi_observables(*, worldlines: Dict[str, Worldline], context: Dict[str, Any]) -> Dict[str, Any]:
    """Compute CAT/EPT-style observables for SGI runs using repo helpers."""
    a = worldlines["arm_plus"]
    b = worldlines["arm_minus"]
    metric = _metric_from_context(context)
    lam0 = _lambda0_from_context(context)

    tau_ent_a = _integrate_tau_ent(a.t_s, a.z_m, lam0=lam0, metric=metric)
    tau_ent_b = _integrate_tau_ent(b.t_s, b.z_m, lam0=lam0, metric=metric)

    d_tau_ent = float(tau_ent_a[-1] - tau_ent_b[-1])

    # Phase proxy uses same conversion as baseline runner; this adapter provides dtau_ent only.
    mass_kg = float(context.get("mass_kg", 1.0e-26))
    d_phi = float((mass_kg * C0*C0 / HBAR) * d_tau_ent)

    return {
        "status": "ok",
        "tau_ent_plus": tau_ent_a,
        "tau_ent_minus": tau_ent_b,
        "d_tau_ent_final": d_tau_ent,
        "d_phi_final_rad": d_phi,
        "lambda0": lam0,
        "metric_mode": str(context.get("metric_mode", "minkowski")),
        "note": "Entropic observables computed via repo MetricField + lambda0; no equations re-derived here."
    }
