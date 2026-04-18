"""SGI quantum readout adapter using the complex-action path-integral layer."""
from __future__ import annotations

from typing import Dict, Any
import numpy as np

from catsim_quantum.channel_presets import resolve_gamma_phi
from catsim_quantum.bath_models import scale_gamma, get_preset as get_bath_preset
from catsim_core.qg.phase_path_integral import PhasePIConfig, estimate_visibility


def predict_visibility_from_phase(*, phi_final_rad: float, T_s: float, context: Dict[str, Any], t_s=None, dOmega=None) -> Dict[str, Any]:
    # Resolve dephasing rate (base)
    gamma_base = resolve_gamma_phi(gamma_phi=context.get("gamma_phi"), channel_preset=context.get("channel_preset"))

    # Bath-density scaling (same rule as QuTiP adapter)
    rho = context.get("bath_density")
    if rho is None and context.get("bath_preset"):
        bp = get_bath_preset(context.get("bath_preset"))
        if bp:
            rho = bp.density_kg_m3
    if rho is not None:
        gamma_phi = scale_gamma(gamma_base=float(gamma_base), rho=float(rho), rho_ref=float(context.get("bath_rho_ref", 1.225)), alpha=float(context.get("bath_alpha", 1.0)))
    else:
        gamma_phi = float(gamma_base)

    # Time grid
    if t_s is None or dOmega is None:
        # conservative fallback: constant rate over [0,T]
        tt = np.linspace(0.0, float(T_s), 256)
        domega = np.full_like(tt, float(phi_final_rad) / float(T_s) if float(T_s) > 0 else 0.0)
    else:
        tt = np.asarray(t_s, dtype=float)
        domega = np.asarray(dOmega, dtype=float)

    # Optional stochastic phase diffusion driven by bath density
    # (kept simple: diffusion ∝ gamma_phi; can be refined later).
    phase_diff = float(context.get("phase_diffusion", 0.0))
    if phase_diff <= 0.0:
        phase_diff = 0.25 * float(gamma_phi)  # low default

    cfg = PhasePIConfig(
        n_paths=int(context.get("pi_n_paths", 4000)),
        seed=int(context.get("pi_seed", 0)),
        phase_diffusion=float(phase_diff),
    )
    res = estimate_visibility(t_s=tt, domega=domega, gamma_phi_s_inv=float(gamma_phi), cfg=cfg)

    return {
        "visibility_pred": float(res["visibility"]),
        "gamma_phi_s_inv": float(gamma_phi),
        "gamma_int": float(res["gamma_int"]),
        "phase_diffusion": float(res["phase_diffusion"]),
        "phi_mean": float(res["phi_mean"]),
        "phi_std": float(res["phi_std"]),
        "n_paths": int(res["n_paths"]),
        "backend": "path_integral",
    }
