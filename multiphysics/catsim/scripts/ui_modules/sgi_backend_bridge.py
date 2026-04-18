"""Backend bridge for SGI.

This is the ONLY place allowed to call extended backends already present in the repo
(e.g., CAT/EPT-enabled modules). This file must not re-derive or restate any CAT/EPT
equations; it only marshals data and dispatches to existing adapters.

Interfaces:
- run_gr_baseline(worldlines, context) -> dict
- run_extended_backend(worldlines, context) -> dict (best-effort)
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Any, Optional
import numpy as np

from .sgi_worldlines_gr import Worldline

c0 = 299792458.0
hbar = 1.054571817e-34

def run_gr_baseline(worldlines: Dict[str, Worldline], mass_kg: float) -> Dict[str, Any]:
    """Compute conservative baseline observables from SR proper-time kinematics.

    Note: this is *baseline* only; experiment-specific magnetic phases etc. can be added
    later. We intentionally keep this minimal.

    Output:
    - tau_plus_s, tau_minus_s (arrays)
    - d_tau_s (scalar final)
    - d_phi_rad (scalar final), using mc^2/hbar * d_tau
    """
    def proper_time(t, v):
        # dτ ≈ sqrt(1 - v^2/c^2) dt, integrated numerically
        beta2 = (v/c0)**2
        gamma_inv = np.sqrt(np.maximum(0.0, 1.0 - beta2))
        dt = np.diff(t)
        # mid-point
        gmid = 0.5*(gamma_inv[:-1] + gamma_inv[1:])
        return np.concatenate([[0.0], np.cumsum(gmid*dt)])

    a = worldlines["arm_plus"]
    b = worldlines["arm_minus"]
    tau_a = proper_time(a.t_s, a.v_m_per_s)
    tau_b = proper_time(b.t_s, b.v_m_per_s)
    d_tau = float(tau_a[-1] - tau_b[-1])
    d_phi = float((mass_kg * c0*c0 / hbar) * d_tau)

    d_tau_t = tau_a - tau_b
    d_phi_t = (mass_kg * c0*c0 / hbar) * d_tau_t

    return {
        "tau_plus_s": tau_a,
        "tau_minus_s": tau_b,
        "d_tau_final_s": d_tau,
        "d_phi_final_rad": d_phi,
        "d_phi_t_rad": d_phi_t,
        "t_s": a.t_s,
        "note": "GR baseline uses SR proper time only; extended physics must be provided by repo backends."
    }

def run_extended_backend(worldlines: Dict[str, Worldline], context: Dict[str, Any]) -> Dict[str, Any]:
    """Invoke extended backend (CAT/EPT etc.) using existing repo adapters.

    Best-effort strategy:
    - If a module exposes `compute_sgi_observables(worldlines, context)` use it.
    - Otherwise, return a stub indicating what is missing.

    This keeps SGI harness decoupled from backend evolution.
    """
    # Candidate import locations (may evolve)
    candidates = [
        "cat_ept_doubleslit.adapters.sgi_backend",
        "cat_ept_doubleslit.integration.sgi_backend",
        "cat_ept_doubleslit.sgi_backend",
    ]
    last_err: Optional[str] = None
    for modname in candidates:
        try:
            mod = __import__(modname, fromlist=["compute_sgi_observables"])
            fn = getattr(mod, "compute_sgi_observables", None)
            if callable(fn):
                return fn(worldlines=worldlines, context=context)
        except Exception as e:
            last_err = f"{modname}: {e}"
            continue

    return {
        "status": "not_available",
        "message": "No extended SGI backend adapter found. Add compute_sgi_observables(...) in an adapter module.",
        "candidates_tried": candidates,
        "last_error": last_err,
    }
