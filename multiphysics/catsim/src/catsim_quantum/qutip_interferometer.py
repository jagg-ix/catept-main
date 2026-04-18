"""Minimal QuTiP-based path-qubit interferometer model with fallback."""
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Any
import numpy as np
import math

@dataclass(frozen=True)
class InterferometerResult:
    visibility: float
    phi_final_rad: float
    gamma_int: float
    backend: str
    extra: Dict[str, Any]

def _fallback_visibility(phi_final: float, gamma_int: float) -> float:
    return float(math.exp(-2.0*gamma_int) * 0.5*(1.0 + math.cos(phi_final)))

def simulate_visibility_timegrid(t: np.ndarray, dOmega: np.ndarray, gamma_phi: np.ndarray) -> InterferometerResult:
    t = np.asarray(t, dtype=float)
    dOmega = np.asarray(dOmega, dtype=float)
    gamma_phi = np.asarray(gamma_phi, dtype=float)
    if t.ndim != 1 or dOmega.shape != t.shape or gamma_phi.shape != t.shape:
        raise ValueError("t, dOmega, gamma_phi must be 1D arrays with same shape")

    dt = np.diff(t)
    domega_mid = 0.5*(dOmega[:-1] + dOmega[1:])
    gamma_mid = 0.5*(gamma_phi[:-1] + gamma_phi[1:])
    phi_final = float(np.sum(domega_mid * dt))
    gamma_int = float(np.sum(gamma_mid * dt))

    try:
        import qutip as qt  # type: ignore
        sigz = qt.sigmaz()
        tt = t.copy()
        domega = dOmega.copy()
        gamma = gamma_phi.copy()

        def domega_of_t(ti, args=None):
            return float(np.interp(ti, tt, domega))

        def gamma_of_t(ti, args=None):
            return float(np.interp(ti, tt, gamma))

        H = [0.5*sigz, domega_of_t]
        c_ops = [[sigz, lambda ti, args=None: math.sqrt(max(gamma_of_t(ti), 0.0))]]

        psi0 = (qt.basis(2,0) + qt.basis(2,1)).unit()
        rho0 = psi0.proj()

        res = qt.mesolve(H, rho0, tt, c_ops=c_ops, e_ops=[])
        rhoT = res.states[-1]
        coh = rhoT.full()[0,1]
        vis = float(2.0*abs(coh))
        return InterferometerResult(visibility=vis, phi_final_rad=phi_final, gamma_int=gamma_int, backend="qutip", extra={"rhoT": rhoT.full().tolist()})
    except Exception as e:
        vis = _fallback_visibility(phi_final, gamma_int)
        return InterferometerResult(visibility=vis, phi_final_rad=phi_final, gamma_int=gamma_int, backend="fallback", extra={"error": str(e)})

def simulate_visibility_constant(*, T: float, phi_final_rad: float, gamma_phi_s_inv: float) -> InterferometerResult:
    gamma_int = float(max(gamma_phi_s_inv, 0.0) * max(T, 0.0))
    vis = _fallback_visibility(float(phi_final_rad), gamma_int)
    return InterferometerResult(visibility=vis, phi_final_rad=float(phi_final_rad), gamma_int=gamma_int, backend="fallback", extra={"mode":"constant"})


def simulate_visibility_timegrid_multi(t: np.ndarray, dOmega: np.ndarray, rates: Dict[str, np.ndarray]) -> InterferometerResult:
    """Time-grid QuTiP interferometer with multiple bath channels.

    Parameters
    ----------
    t: (N,) seconds
    dOmega: (N,) rad/s phase-rate
    rates: dict of (N,) arrays, expected keys (any subset):
      - "dephasing": gamma_z(t) (1/s) applied via sigmaz
      - "relax": gamma_down(t) (1/s) applied via sigminus
      - "excite": gamma_up(t) (1/s) applied via sigplus

    Notes
    -----
    This is intentionally a *generic wiring* layer: upstream code decides how to map
    thermodynamic bath density models into rates.
    """
    t = np.asarray(t, dtype=float)
    dOmega = np.asarray(dOmega, dtype=float)
    if t.ndim != 1 or dOmega.shape != t.shape:
        raise ValueError("t and dOmega must be 1D arrays with same shape")

    # Integrals for reporting only
    dt = np.diff(t)
    domega_mid = 0.5*(dOmega[:-1] + dOmega[1:])
    phi_final = float(np.sum(domega_mid * dt))

    # Choose a representative "gamma_int" for metadata: integral of dephasing if present else sum of all
    gamma_int = 0.0
    if "dephasing" in rates:
        g = np.asarray(rates["dephasing"], dtype=float)
        if g.shape != t.shape: raise ValueError("rates['dephasing'] must align with t")
        gamma_mid = 0.5*(g[:-1] + g[1:])
        gamma_int = float(np.sum(gamma_mid * dt))
    else:
        for k,v in rates.items():
            vv = np.asarray(v, dtype=float)
            if vv.shape != t.shape: raise ValueError(f"rates['{k}'] must align with t")
            gamma_mid = 0.5*(vv[:-1] + vv[1:])
            gamma_int += float(np.sum(gamma_mid * dt))

    try:
        import qutip as qt  # type: ignore
        sigz = qt.sigmaz()
        sigm = qt.sigmam()
        sigp = qt.sigmap()

        tt = t.copy()
        domega = dOmega.copy()

        def domega_of_t(ti, args=None):
            return float(np.interp(ti, tt, domega))

        H = [0.5*sigz, domega_of_t]

        # Build collapse operators
        c_ops = []
        if "dephasing" in rates:
            g = np.maximum(np.asarray(rates["dephasing"], dtype=float), 0.0)
            def gz_of_t(ti, args=None):
                return float(np.interp(ti, tt, g))
            c_ops.append([sigz, lambda ti, args=None: math.sqrt(max(gz_of_t(ti), 0.0))])

        if "relax" in rates:
            g = np.maximum(np.asarray(rates["relax"], dtype=float), 0.0)
            def gd_of_t(ti, args=None):
                return float(np.interp(ti, tt, g))
            c_ops.append([sigm, lambda ti, args=None: math.sqrt(max(gd_of_t(ti), 0.0))])

        if "excite" in rates:
            g = np.maximum(np.asarray(rates["excite"], dtype=float), 0.0)
            def gu_of_t(ti, args=None):
                return float(np.interp(ti, tt, g))
            c_ops.append([sigp, lambda ti, args=None: math.sqrt(max(gu_of_t(ti), 0.0))])

        # initial superposition
        psi0 = (qt.basis(2,0) + qt.basis(2,1)).unit()
        rho0 = psi0.proj()

        res = qt.mesolve(H, rho0, tt, c_ops=c_ops, e_ops=[])
        rhoT = res.states[-1]
        coh = rhoT.full()[0,1]
        vis = float(2.0*abs(coh))
        return InterferometerResult(visibility=vis, phi_final_rad=phi_final, gamma_int=gamma_int, backend="qutip_multi",
                                   extra={"rhoT": rhoT.full().tolist(), "channels": list(rates.keys())})
    except Exception as e:
        # fallback uses dephasing-equivalent gamma_int
        vis = _fallback_visibility(phi_final, gamma_int)
        return InterferometerResult(visibility=vis, phi_final_rad=phi_final, gamma_int=gamma_int, backend="fallback_multi",
                                   extra={"error": str(e), "channels": list(rates.keys())})
