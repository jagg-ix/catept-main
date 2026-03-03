"""Kerr observer models for time-dilation / redshift factors.

This module extends the repo's current Kerr support (which provides g_tt only for a conservative static redshift)
by adding observer-dependent dtau/dt factors in Boyer–Lindquist coordinates.

We keep this separated from CAT/EPT equations: it only provides GR kinematics.

Supported observer modes
------------------------
- static: u^phi = 0 (requires g_tt < 0; fails in ergosphere)
- zamo: Zero Angular Momentum Observer (locally non-rotating frame)
- circular_prograde: equatorial circular geodesic (prograde)
- circular_retrograde: equatorial circular geodesic (retrograde)

Returned quantity
-----------------
dtau_dt = sqrt( - (g_tt + 2 g_tphi Ω + g_phiphi Ω^2) )

where Ω = dφ/dt for the chosen observer model.

Notes
-----
- This is intended for *time-dilation factors* used by higher-level adapters (SGI, ringdown, etc.).
- It uses standard Kerr BL metric components in geometric units (G=c=1), with parameters:
    M_geo = GM/c^2 (meters)
    a_len = a_star * M_geo (meters)

- We compute r, θ, φ from Cartesian x=(x,y,z) unless θ override is provided upstream.
"""

from __future__ import annotations
from dataclasses import dataclass
import math
import numpy as np
from typing import Literal

G_SI = 6.67430e-11
C_SI = 299792458.0

ObserverMode = Literal["static", "zamo", "circular_prograde", "circular_retrograde"]

@dataclass(frozen=True)
class KerrParams:
    mass_kg: float
    a_star: float = 0.0
    theta_rad: float | None = None  # optional fixed latitude

def _to_bl(x: np.ndarray, theta_override: float | None) -> tuple[float, float, float]:
    r = float(np.linalg.norm(x))
    if r <= 0:
        raise ValueError("Kerr BL coords undefined at r=0")
    if theta_override is None:
        cos_th = float(x[2] / r)
        cos_th = max(-1.0, min(1.0, cos_th))
        th = float(math.acos(cos_th))
    else:
        th = float(theta_override)
    ph = float(math.atan2(float(x[1]), float(x[0])))
    return r, th, ph

def _kerr_components(mass_kg: float, a_star: float, r: float, th: float) -> tuple[float,float,float,float,float]:
    """Return (M_geo, a_len, g_tt, g_tphi, g_phiphi) at (r,th)."""
    M_geo = (G_SI * float(mass_kg)) / (C_SI**2)
    a_star = float(a_star)
    if a_star < 0.0:
        raise ValueError("a_star must be >=0")
    a = a_star * M_geo

    sin_th = math.sin(th)
    cos_th = math.cos(th)
    Sigma = r*r + a*a*cos_th*cos_th
    if Sigma <= 0:
        raise ValueError("Invalid Kerr Sigma")
    _Delta = r*r - 2.0*M_geo*r + a*a  # kept for completeness, not used below

    # Metric components (signature - + + +):
    g_tt = -(1.0 - (2.0*M_geo*r)/Sigma)
    g_tphi = -(2.0*M_geo*a*r*sin_th*sin_th)/Sigma
    g_phiphi = (sin_th*sin_th) * ( (r*r + a*a) + (2.0*M_geo*a*a*r*sin_th*sin_th)/Sigma )
    return M_geo, a, g_tt, g_tphi, g_phiphi

def omega_zamo(g_tphi: float, g_phiphi: float) -> float:
    if g_phiphi == 0.0:
        raise ValueError("g_phiphi=0")
    return float(-g_tphi / g_phiphi)

def omega_circular_equatorial(M_geo: float, a_len: float, r: float, prograde: bool) -> float:
    """Equatorial circular geodesic angular velocity Ω (geometric units).

    Ω_± = ± sqrt(M) / (r^(3/2) ± a*sqrt(M))
    """
    if r <= 0:
        raise ValueError("r must be >0")
    sqrtM = math.sqrt(M_geo)
    r32 = r**1.5
    if prograde:
        denom = (r32 + a_len*sqrtM)
        return float(sqrtM / denom)
    else:
        denom = (r32 - a_len*sqrtM)
        return float(-sqrtM / denom)

def dtau_dt_at_x(params: KerrParams, x: np.ndarray, mode: ObserverMode) -> float:
    r, th, _ph = _to_bl(np.asarray(x, dtype=float), params.theta_rad)
    M_geo, a_len, g_tt, g_tphi, g_phiphi = _kerr_components(params.mass_kg, params.a_star, r, th)

    if mode == "static":
        if g_tt >= 0.0:
            raise ValueError("static observer undefined where g_tt >= 0 (ergosphere)")
        return float(math.sqrt(-g_tt))

    if mode == "zamo":
        Om = omega_zamo(g_tphi, g_phiphi)
    elif mode == "circular_prograde":
        Om = omega_circular_equatorial(M_geo, a_len, r, prograde=True)
    elif mode == "circular_retrograde":
        Om = omega_circular_equatorial(M_geo, a_len, r, prograde=False)
    else:
        raise ValueError(f"unknown observer mode: {mode}")

    arg = -(g_tt + 2.0*g_tphi*Om + g_phiphi*Om*Om)
    if arg <= 0.0:
        raise ValueError("dtau/dt undefined (arg<=0); check parameters/region")
    return float(math.sqrt(arg))
