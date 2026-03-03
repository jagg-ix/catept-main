"""SGI quantum readout adapter (QuTiP path-qubit)."""
from __future__ import annotations
from typing import Dict, Any
from catsim_quantum.channel_presets import resolve_gamma_phi
from catsim_quantum.bath_models import scale_gamma, get_preset as get_bath_preset
from catsim_quantum.qutip_interferometer import simulate_visibility_constant, simulate_visibility_timegrid
import numpy as np



def _timegrid_multi_bath(*, t_s: np.ndarray, dOmega: np.ndarray, context: dict, x_path_m: np.ndarray | None) -> dict:
    """Multi-bath timegrid readout using catsim_quantum.qutip_interferometer.

    Uses repo modules (bath_models + density_field). Does not re-derive CAT/EPT equations.
    """
    from catsim_quantum.qutip_interferometer import simulate_visibility_timegrid_multi
    from catsim_core.thermo.bath_models import BathRateKnobs, rates_from_base_gamma

    g0 = context.get("gamma_phi")
    gamma_base = np.full_like(t_s, float(g0) if g0 is not None else 1.0)

    bknobs = BathRateKnobs(
        density_scale=float(context.get("bath_density_scale", 1.0)),
        dephasing_frac=float(context.get("bath_dephasing_frac", 1.0)),
        relax_frac=float(context.get("bath_relax_frac", 0.0)),
        excite_frac=float(context.get("bath_excite_frac", 0.0)),
    )
    model = str(context.get("bath_model", "dephasing_only"))

    scale_path = None
    if str(context.get("bath_density_field", "constant")) == "scene" and x_path_m is not None:
        from catsim_core.thermo.density_field import DensityScaleKnobs, scale_field_from_scene, scale_path_from_field
        dknobs = DensityScaleKnobs(
            rho_ref=float(context.get("bath_rho_ref", 1.0)),
            background=float(context.get("bath_density_background", 1.0)),
            bh_rho=(float(context["bath_bh_rho"]) if context.get("bath_bh_rho") is not None else None),
        )
        sf = scale_field_from_scene(context, dknobs)
        scale_path = scale_path_from_field(np.asarray(x_path_m, dtype=float), sf)

    rates = rates_from_base_gamma(np.asarray(t_s, float), np.asarray(gamma_base, float), bknobs, model=model, scale_path=scale_path)
    res = simulate_visibility_timegrid_multi(np.asarray(t_s, float), np.asarray(dOmega, float), rates)
    out = {"visibility_pred": float(res.visibility), "backend": str(res.backend), "gamma_int": float(res.gamma_int), "channels": res.extra.get("channels")}
    if scale_path is not None:
        out["scale_stats"] = {"min": float(np.min(scale_path)), "max": float(np.max(scale_path)), "mean": float(np.mean(scale_path))}
    return out

def predict_visibility_from_phase(*, phi_final_rad: float, T_s: float, context: Dict[str, Any], t_s=None, dOmega=None, x_path_m=None) -> Dict[str, Any]:
    gamma_base = resolve_gamma_phi(gamma_phi=context.get("gamma_phi"), channel_preset=context.get("channel_preset"))
    mode = str(context.get("quantum_mode", "constant"))
    if mode == "timegrid" and t_s is not None and dOmega is not None and any(k in context for k in ("bath_model","bath_dephasing_frac","bath_relax_frac","bath_excite_frac","bath_density_field")):
        return _timegrid_multi_bath(t_s=np.asarray(t_s, float), dOmega=np.asarray(dOmega, float), context=context, x_path_m=x_path_m)
    # Optional bath-density scaling
    rho = context.get("bath_density")
    if rho is None and context.get("bath_preset"):
        bp = get_bath_preset(context.get("bath_preset"))
        if bp:
            rho = bp.density_kg_m3
    if rho is not None:
        gamma_phi = scale_gamma(gamma_base=float(gamma_base), rho=float(rho), rho_ref=float(context.get("bath_rho_ref", 1.225)), alpha=float(context.get("bath_alpha", 1.0)))
    else:
        gamma_phi = float(gamma_base)
    mode = str(context.get("quantum_mode","constant"))
    if mode == "timegrid" and t_s is not None and dOmega is not None:
        tt = np.asarray(t_s, dtype=float)
        domega = np.asarray(dOmega, dtype=float)
        gamma_arr = np.full_like(tt, float(gamma_phi), dtype=float)
        res = simulate_visibility_timegrid(tt, domega, gamma_arr)
    else:
        res = simulate_visibility_constant(T=float(T_s), phi_final_rad=float(phi_final_rad), gamma_phi_s_inv=float(gamma_phi))
    return {
        "visibility_pred": float(res.visibility),
        "phi_final_rad": float(res.phi_final_rad),
        "gamma_phi_s_inv": float(gamma_phi),
        "gamma_int": float(res.gamma_int),
        "backend": res.backend,
        "extra": res.extra,
    }
