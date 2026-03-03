"""Electromagnetic cross sections and stopping power.

All functions are pure NumPy — no Geant4 binary required.

Cross sections are in **barns** (1 barn = 1e-24 cm^2).
Energies are in **MeV**.

Source
------
Consolidated from ``geant4_catept_adapter.py`` (Compton, pair
production, photoelectric, stopping power).
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Tuple

import numpy as np

if TYPE_CHECKING:
    from .transport import Material

# Electron rest mass (MeV)
M_E_MEV = 0.510_998_950

# Classical electron radius (cm)
R_E_CM = 2.817_940_3e-13

# Thomson cross section (barn)
SIGMA_THOMSON = 0.665_245_873


def compton_cross_section(E_gamma: float, Z: float) -> float:
    """Klein-Nishina Compton scattering cross section.

    Parameters
    ----------
    E_gamma : float
        Photon energy (MeV).
    Z : float
        Atomic number.

    Returns
    -------
    sigma : float
        Cross section per atom (barn).

    Examples
    --------
    >>> sigma = compton_cross_section(0.01, 14)
    >>> sigma > 0
    True
    >>> # At very low energy, approaches Thomson limit
    >>> sigma_low = compton_cross_section(1e-4, 1)
    >>> np.isclose(sigma_low, SIGMA_THOMSON, rtol=0.1)
    True
    """
    alpha = E_gamma / M_E_MEV

    if alpha < 0.01:
        return SIGMA_THOMSON * Z

    # Klein-Nishina total cross section per electron, then * Z
    a = alpha
    sigma_e = (
        SIGMA_THOMSON
        * 3.0
        / (4.0 * a**3)
        * (
            2.0 * a * (1.0 + a) / (1.0 + 2.0 * a)
            - np.log(1.0 + 2.0 * a)
        )
        + np.log(1.0 + 2.0 * a) / (2.0 * a)
        - (1.0 + 3.0 * a) / (1.0 + 2.0 * a) ** 2
    )
    # Simplified Klein-Nishina (the full formula above can go slightly
    # negative at extreme energies due to numerical issues; use the
    # standard compact form instead)
    sigma_kn = SIGMA_THOMSON * (1 + alpha) / alpha**3 * (
        2.0 * alpha * (1.0 + alpha) / (1.0 + 2.0 * alpha)
        - np.log(1.0 + 2.0 * alpha)
    )
    # Add the logarithmic term
    sigma_kn += SIGMA_THOMSON / (2.0 * alpha) * (
        np.log(1.0 + 2.0 * alpha)
        - 2.0 * alpha * (1.0 + 3.0 * alpha) / (1.0 + 2.0 * alpha) ** 2
    )

    return max(0.0, sigma_kn * Z)


def compton_scatter(E_gamma: float, theta: float | None = None) -> Tuple[float, float]:
    """Compute Compton-scattered photon energy.

    Parameters
    ----------
    E_gamma : float
        Incident photon energy (MeV).
    theta : float, optional
        Scattering angle (radians).  Random if ``None``.

    Returns
    -------
    E_prime : float
        Scattered photon energy (MeV).
    theta : float
        Scattering angle used.
    """
    alpha = E_gamma / M_E_MEV

    if theta is None:
        # Simplified: sample cos(theta) uniformly (not exact Klein-Nishina
        # angular distribution, but adequate for transport estimates)
        cos_theta = np.random.uniform(-1, 1)
        theta = np.arccos(cos_theta)
    else:
        cos_theta = np.cos(theta)

    E_prime = E_gamma / (1.0 + alpha * (1.0 - cos_theta))
    return E_prime, theta


def pair_production_cross_section(E_gamma: float, Z: float) -> float:
    """Pair production cross section (approximate).

    Threshold: ``E_gamma > 2 m_e c^2 = 1.022 MeV``.

    Parameters
    ----------
    E_gamma : float
        Photon energy (MeV).
    Z : float
        Atomic number.

    Returns
    -------
    sigma : float
        Cross section per atom (barn).

    Examples
    --------
    >>> pair_production_cross_section(0.5, 14)
    0.0
    >>> pair_production_cross_section(10.0, 82) > 0
    True
    """
    if E_gamma < 1.022:
        return 0.0

    # Bethe-Heitler approximation (high energy)
    sigma = 7.0 / 9.0 * Z**2 * np.log(E_gamma / M_E_MEV) * 1e-3
    return max(0.0, sigma)


def photoelectric_cross_section(E_gamma: float, Z: float) -> float:
    """Photoelectric absorption cross section (approximate).

    Parameters
    ----------
    E_gamma : float
        Photon energy (MeV).
    Z : float
        Atomic number.

    Returns
    -------
    sigma : float
        Cross section per atom (barn).

    Examples
    --------
    >>> photoelectric_cross_section(0.1, 82) > 0
    True
    """
    if E_gamma <= 0:
        return 0.0

    # Approximate Z^5 / E^3.5 scaling
    sigma = 10.0 * Z**5 / E_gamma**3.5 * 1e-3
    return max(0.0, sigma)


def total_photon_cross_section(E_gamma: float, material: "Material") -> float:
    """Total photon interaction cross section.

    Sum of Compton, pair production, and photoelectric.

    Parameters
    ----------
    E_gamma : float
        Photon energy (MeV).
    material : Material
        Target material.

    Returns
    -------
    sigma_total : float
        Total cross section per atom (barn).
    """
    Z = material.Z
    return (
        compton_cross_section(E_gamma, Z)
        + pair_production_cross_section(E_gamma, Z)
        + photoelectric_cross_section(E_gamma, Z)
    )


def bethe_bloch_stopping_power(
    E_kin: float,
    Z_proj: float,
    M_proj: float,
    material: "Material",
) -> float:
    """Bethe-Bloch electronic stopping power.

    Computes ``-dE/dx`` in MeV/cm for a charged particle.

    Parameters
    ----------
    E_kin : float
        Kinetic energy (MeV).
    Z_proj : float
        Projectile charge number.
    M_proj : float
        Projectile mass (MeV/c^2).
    material : Material
        Target material.

    Returns
    -------
    dEdx : float
        Stopping power (MeV/cm), positive.

    Examples
    --------
    >>> from qutip_geant4_bridge.transport import MaterialDatabase
    >>> db = MaterialDatabase()
    >>> dEdx = bethe_bloch_stopping_power(100, 1, 938.3, db["water"])
    >>> dEdx > 0
    True
    """
    if E_kin <= 0 or material.density == 0:
        return 0.0

    M_E = M_E_MEV  # electron mass in MeV
    I = material.I_mean * 1e-6  # eV -> MeV

    gamma = 1.0 + E_kin / M_proj
    beta2 = 1.0 - 1.0 / gamma**2
    if beta2 <= 0:
        return 0.0
    beta = np.sqrt(beta2)

    # Maximum energy transfer in single collision
    T_max = 2.0 * M_E * beta2 * gamma**2 / (
        1.0 + 2.0 * gamma * M_E / M_proj + (M_E / M_proj) ** 2
    )

    # Electron density (electrons/cm^3)
    n_e = material.Z * material.density * N_A / material.A

    # Bethe-Bloch formula (MeV/cm)
    K = 0.307_075  # MeV cm^2/mol
    N_A_local = 6.022e23

    ln_term = np.log(2.0 * M_E * beta2 * gamma**2 * T_max / I**2)
    dEdx = (
        K * Z_proj**2 * material.Z / material.A
        * material.density
        / beta2
        * (0.5 * ln_term - beta2)
    )

    return max(0.0, dEdx)


# Convenience constant for imports
N_A = 6.022_140_76e23
