"""ENZ material dispersion and frequency-dependent decoherence.

Combines first-principles Drude permittivity from ``enz_dielectric.py``
(conservative, derived group velocity via n_g = Re(n) + omega dn/domega)
with the material database from ``enz_material_physics.py`` (ITO, AZO,
GZO material presets).

The new ``frequency_dependent_visibility`` function closes the spectral
asymmetry gap identified in Validation Target 6: the analytic Gaussian
model is symmetric by construction, but experiment shows red/blue
asymmetry from ENZ material dispersion.

Source
------
- ``enz_dielectric.py``: DrudeParams, eps_drude, group_velocity (first-principles)
- ``enz_material_physics.py``: ENZMaterial database, thermal decoherence
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Optional, Tuple

import numpy as np

# Physical constants
C = 299_792_458.0         # m/s
HBAR = 1.054_571_817e-34  # J s
K_B = 1.380_649e-23       # J/K


# ---------------------------------------------------------------------------
# Drude model (first-principles, from enz_dielectric.py)
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class DrudeParams:
    """Drude permittivity model parameters.

    Parameters
    ----------
    eps_inf : float
        High-frequency permittivity (dimensionless).
    omega_p : float
        Plasma frequency (rad/s).
    gamma : float
        Damping rate (rad/s).

    Notes
    -----
    The permittivity is:

        eps(omega) = eps_inf - omega_p^2 / (omega^2 + i gamma omega)

    Default values are typical ITO thin-film parameters.
    """

    eps_inf: float = 3.5
    omega_p: float = 2.5e15
    gamma: float = 1.0e14


# Presets
DRUDE_ITO = DrudeParams(eps_inf=3.5, omega_p=2.5e15, gamma=1.0e14)
DRUDE_AZO = DrudeParams(eps_inf=3.3, omega_p=2.3e15, gamma=1.2e14)
DRUDE_GZO = DrudeParams(eps_inf=3.4, omega_p=2.1e15, gamma=1.1e14)


def eps_drude(omega: np.ndarray, params: DrudeParams) -> np.ndarray:
    """Complex permittivity from the Drude model.

    Parameters
    ----------
    omega : ndarray
        Angular frequency (rad/s).
    params : DrudeParams
        Drude model parameters.

    Returns
    -------
    eps : ndarray (complex)
        Complex permittivity at each frequency.

    Examples
    --------
    >>> omega = np.array([2*np.pi*230e12])  # 230 THz
    >>> eps = eps_drude(omega, DRUDE_ITO)
    """
    omega = np.asarray(omega, dtype=float)
    denom = omega**2 + 1j * params.gamma * omega
    denom = np.where(np.abs(denom) < 1e-30, 1e-30 + 0j, denom)
    return params.eps_inf - params.omega_p**2 / denom


def refractive_index(eps: np.ndarray) -> np.ndarray:
    """Complex refractive index n = sqrt(eps) (principal branch).

    Parameters
    ----------
    eps : ndarray (complex)
        Complex permittivity.

    Returns
    -------
    n : ndarray (complex)
        Refractive index.
    """
    return np.sqrt(np.asarray(eps, dtype=complex))


def group_velocity_drude(
    omega: np.ndarray,
    params: DrudeParams,
    c: float = C,
) -> np.ndarray:
    """Group velocity from Drude dispersion (first-principles).

    Computes ``v_g = c / n_g`` where the group index is:

        n_g = Re(n) + omega * d(Re(n))/d(omega)

    Uses finite differences for the derivative.

    Parameters
    ----------
    omega : ndarray
        Angular frequency array (rad/s).
    params : DrudeParams
        Drude model parameters.
    c : float, optional
        Speed of light (m/s).

    Returns
    -------
    v_g : ndarray
        Group velocity (m/s).  ``nan`` where group index is near zero.

    Examples
    --------
    >>> omega = np.linspace(1e14, 5e15, 1000)
    >>> v_g = group_velocity_drude(omega, DRUDE_ITO)
    """
    omega = np.asarray(omega, dtype=float)
    eps = eps_drude(omega, params)
    n = refractive_index(eps)
    n_re = np.real(n)

    if omega.size < 2:
        n_g = np.where(np.abs(n_re) > 1e-12, n_re, np.nan)
        return c / n_g

    dn = np.gradient(n_re, omega, edge_order=1)
    n_g = n_re + omega * dn
    n_g = np.where(np.isfinite(n_g) & (np.abs(n_g) > 1e-12), n_g, np.nan)
    return c / n_g


def enz_frequency(params: DrudeParams) -> float:
    """Angular frequency where Re(eps) crosses zero.

    Parameters
    ----------
    params : DrudeParams
        Drude parameters.

    Returns
    -------
    omega_enz : float
        ENZ frequency (rad/s).
    """
    # Analytic approximation: Re(eps) = 0 when
    # eps_inf = omega_p^2 / omega^2 (ignoring damping)
    # => omega_enz = omega_p / sqrt(eps_inf)
    omega_approx = params.omega_p / np.sqrt(params.eps_inf)

    # Refine with a dense grid near the approximation
    omega_grid = np.linspace(omega_approx * 0.9, omega_approx * 1.1, 5000)
    re_eps = np.real(eps_drude(omega_grid, params))
    idx = np.argmin(np.abs(re_eps))
    return float(omega_grid[idx])


def enz_wavelength(params: DrudeParams) -> float:
    """Wavelength where Re(eps) crosses zero.

    Parameters
    ----------
    params : DrudeParams
        Drude parameters.

    Returns
    -------
    lambda_enz : float
        ENZ wavelength (metres).
    """
    return 2 * np.pi * C / enz_frequency(params)


# ---------------------------------------------------------------------------
# Thermal decoherence and ENZ enhancement
# ---------------------------------------------------------------------------

def thermal_decoherence_length(T: float = 300.0) -> float:
    """Thermal decoherence length.

    Parameters
    ----------
    T : float
        Temperature (kelvin).

    Returns
    -------
    l_th : float
        Thermal decoherence length (metres).
    """
    if T <= 0:
        return float("inf")
    return HBAR * C / (K_B * T)


def enhancement_factor(
    omega: np.ndarray,
    params: DrudeParams,
) -> np.ndarray:
    """Enhancement factor c / v_g at each frequency.

    Parameters
    ----------
    omega : ndarray
        Angular frequency (rad/s).
    params : DrudeParams
        Drude parameters.

    Returns
    -------
    eta : ndarray
        Enhancement factor (dimensionless).
    """
    v_g = group_velocity_drude(omega, params)
    return C / v_g


def enz_decoherence_rate(
    omega: np.ndarray,
    params: DrudeParams,
    T: float = 300.0,
) -> np.ndarray:
    """ENZ-enhanced decoherence rate.

    lambda_ENZ(omega) = lambda_thermal * (c / v_g(omega))

    Parameters
    ----------
    omega : ndarray
        Angular frequency (rad/s).
    params : DrudeParams
        Drude parameters.
    T : float
        Temperature (kelvin).

    Returns
    -------
    rate : ndarray
        Decoherence rate (1/s) at each frequency.
    """
    l_th = thermal_decoherence_length(T)
    lambda_thermal = C / l_th if l_th > 0 else 0.0
    eta = enhancement_factor(omega, params)
    return lambda_thermal * eta


# ---------------------------------------------------------------------------
# Frequency-dependent visibility (NEW — closes asymmetry gap)
# ---------------------------------------------------------------------------

def frequency_dependent_visibility(
    f_hz: np.ndarray,
    separation_s: float,
    params: DrudeParams = DRUDE_ITO,
    T: float = 300.0,
    visibility0: float = 1.0,
) -> np.ndarray:
    """Frequency-dependent fringe visibility with ENZ dispersion.

    The standard temporal double-slit model uses a scalar decoherence
    rate and produces symmetric spectra.  Real ENZ materials have
    frequency-dependent group velocity, making the decoherence rate
    (and thus visibility) frequency-dependent:

        V(f) = V0 * exp(-lambda_ENZ(f) * |S| / 2)

    where ``lambda_ENZ(f) = lambda_thermal * c / v_g(f)``.

    This produces the red/blue asymmetry observed in Tirole et al.
    (Nature Physics 2023) because ``v_g`` is much smaller on the red
    side of the ENZ point.

    Parameters
    ----------
    f_hz : ndarray
        Frequency array (Hz).
    separation_s : float
        Slit separation (seconds).
    params : DrudeParams
        ENZ material Drude parameters.
    T : float
        Temperature (kelvin).
    visibility0 : float
        Bare visibility (no decoherence).

    Returns
    -------
    V : ndarray
        Fringe visibility at each frequency.

    Examples
    --------
    >>> f = np.linspace(200e12, 260e12, 500)
    >>> V = frequency_dependent_visibility(f, 500e-15, DRUDE_ITO)
    >>> # V should be asymmetric around the ENZ frequency
    """
    f_hz = np.asarray(f_hz, dtype=float)
    omega = 2 * np.pi * f_hz

    rate = enz_decoherence_rate(omega, params, T=T)

    # Replace NaN rates (at ENZ singularity) with max finite rate
    finite_mask = np.isfinite(rate)
    if not np.all(finite_mask):
        max_rate = np.nanmax(rate[finite_mask]) if np.any(finite_mask) else 0.0
        rate = np.where(finite_mask, rate, max_rate)

    V = visibility0 * np.exp(-np.abs(rate) * abs(separation_s) / 2.0)
    return V


# ---------------------------------------------------------------------------
# Material scan utility
# ---------------------------------------------------------------------------

def wavelength_scan(
    params: DrudeParams,
    wavelength_range_nm: Tuple[float, float] = (800, 2000),
    n_points: int = 500,
    T: float = 300.0,
) -> Dict[str, np.ndarray]:
    """Scan material properties vs wavelength.

    Parameters
    ----------
    params : DrudeParams
        Drude parameters.
    wavelength_range_nm : tuple of float
        (min, max) wavelength in nanometres.
    n_points : int
        Number of wavelength points.
    T : float
        Temperature (kelvin).

    Returns
    -------
    dict
        Arrays keyed by property name.
    """
    wl_nm = np.linspace(wavelength_range_nm[0], wavelength_range_nm[1], n_points)
    omega = 2 * np.pi * C / (wl_nm * 1e-9)

    eps = eps_drude(omega, params)
    n = refractive_index(eps)
    v_g = group_velocity_drude(omega, params)

    return {
        "wavelength_nm": wl_nm,
        "omega_rad_s": omega,
        "epsilon_real": np.real(eps),
        "epsilon_imag": np.imag(eps),
        "n_real": np.real(n),
        "n_imag": np.imag(n),
        "group_velocity": v_g,
        "enhancement_factor": C / v_g,
        "lambda_enz": enz_decoherence_rate(omega, params, T=T),
    }
