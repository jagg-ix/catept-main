"""Hawking radiation, Unruh effect, and black hole thermodynamics.

Pure NumPy functions for black hole quantum effects.  No QuTiP
or EinsteinPy dependency.

Source
------
Consolidated from ``einsteinpy_qutip_extension.py`` (Hawking/Unruh)
and ``geant4_catept_adapter.py`` (radiation damage rates).
"""

from __future__ import annotations

import numpy as np

# Physical constants (SI)
HBAR = 1.054_571_817e-34   # J s
C = 2.997_924_58e8          # m/s
G = 6.674_30e-11            # m^3 kg^-1 s^-2
K_B = 1.380_649e-23         # J/K
M_SUN = 1.989e30            # kg
SIGMA_SB = 5.670_374_419e-8  # W m^-2 K^-4


def hawking_temperature(M: float, *, natural_units: bool = False) -> float:
    """Hawking temperature of a Schwarzschild black hole.

    SI: ``T_H = hbar c^3 / (8 pi G M k_B)``
    Natural: ``T_H = 1 / (8 pi M)``

    Parameters
    ----------
    M : float
        Black hole mass.  In SI (kg) or natural units.
    natural_units : bool
        If ``True``, use natural units (hbar = c = G = k_B = 1).

    Returns
    -------
    T_H : float
        Hawking temperature (K or natural).

    Examples
    --------
    >>> T = hawking_temperature(1.0, natural_units=True)
    >>> np.isclose(T, 1 / (8 * np.pi))
    True
    >>> T_si = hawking_temperature(M_SUN)
    >>> T_si < 1e-6  # ~6e-8 K for solar mass
    True
    """
    if natural_units:
        return 1.0 / (8.0 * np.pi * M)

    return HBAR * C**3 / (8.0 * np.pi * G * M * K_B)


def unruh_temperature(a: float, *, natural_units: bool = False) -> float:
    """Unruh temperature for a uniformly accelerated observer.

    SI: ``T_U = hbar a / (2 pi c k_B)``
    Natural: ``T_U = a / (2 pi)``

    Parameters
    ----------
    a : float
        Proper acceleration (m/s^2 or natural).
    natural_units : bool
        If ``True``, use natural units.

    Returns
    -------
    T_U : float
        Unruh temperature.

    Examples
    --------
    >>> T = unruh_temperature(1.0, natural_units=True)
    >>> np.isclose(T, 1 / (2 * np.pi))
    True
    """
    if natural_units:
        return a / (2.0 * np.pi)

    return HBAR * a / (2.0 * np.pi * C * K_B)


def thermal_occupation(omega: float, T: float, *, natural_units: bool = False) -> float:
    """Bose-Einstein thermal occupation number.

    ``n(omega) = 1 / (exp(hbar omega / k_B T) - 1)``

    Parameters
    ----------
    omega : float
        Mode frequency (rad/s or natural).
    T : float
        Temperature (K or natural).
    natural_units : bool
        If ``True``, use natural units.

    Returns
    -------
    n : float
        Occupation number.

    Examples
    --------
    >>> thermal_occupation(1.0, 0.0)
    0.0
    >>> n = thermal_occupation(1.0, 10.0, natural_units=True)
    >>> n > 0
    True
    """
    if T == 0:
        return 0.0

    if natural_units:
        x = omega / T
    else:
        x = HBAR * omega / (K_B * T)

    if x > 500:
        return 0.0

    return 1.0 / (np.exp(x) - 1.0)


def schwarzschild_redshift(M: float, r: float) -> float:
    """Gravitational redshift factor for Schwarzschild geometry.

    ``a(r) = sqrt(1 - r_s / r)`` where ``r_s = 2GM/c^2``.

    Parameters
    ----------
    M : float
        Mass (kg).
    r : float
        Radial coordinate (m).  Must be > r_s.

    Returns
    -------
    a : float
        Redshift factor (0, 1].

    Examples
    --------
    >>> a = schwarzschild_redshift(M_SUN, 1e10)
    >>> 0 < a <= 1
    True
    """
    r_s = 2.0 * G * M / C**2
    val = 1.0 - r_s / r
    if val <= 0:
        return 0.0
    return np.sqrt(val)


def isco_radius(M: float) -> float:
    """Innermost stable circular orbit for Schwarzschild.

    ``r_isco = 6 G M / c^2 = 3 r_s``

    Parameters
    ----------
    M : float
        Mass (kg).

    Returns
    -------
    r_isco : float
        ISCO radius (m).

    Examples
    --------
    >>> r = isco_radius(M_SUN)
    >>> r > 0
    True
    """
    return 6.0 * G * M / C**2


def hawking_entropy_rate(M: float) -> float:
    """Entropy production rate from Hawking radiation.

    Uses Stefan-Boltzmann luminosity of a black hole:
        L = sigma T_H^4 * A_H
    where A_H = 16 pi (GM/c^2)^2 is the horizon area.

    The entropy production rate:
        dS/dt = L / T_H

    Parameters
    ----------
    M : float
        Black hole mass (kg).

    Returns
    -------
    dS_dt : float
        Entropy production rate (W/K = J/(s K)).

    Examples
    --------
    >>> rate = hawking_entropy_rate(M_SUN)
    >>> rate > 0
    True
    """
    T_H = hawking_temperature(M)
    r_s = 2.0 * G * M / C**2
    A_H = 4.0 * np.pi * r_s**2
    L = SIGMA_SB * T_H**4 * A_H
    return L / T_H if T_H > 0 else 0.0


def bekenstein_hawking_entropy(M: float) -> float:
    """Bekenstein-Hawking entropy of a Schwarzschild black hole.

    ``S_BH = A / (4 l_P^2)`` where ``l_P = sqrt(hbar G / c^3)``.

    Parameters
    ----------
    M : float
        Mass (kg).

    Returns
    -------
    S : float
        Entropy (dimensionless, in Planck units).

    Examples
    --------
    >>> S = bekenstein_hawking_entropy(M_SUN)
    >>> S > 1e70
    True
    """
    r_s = 2.0 * G * M / C**2
    A = 4.0 * np.pi * r_s**2
    l_P_sq = HBAR * G / C**3
    return A / (4.0 * l_P_sq)
