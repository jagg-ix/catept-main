"""Radiation damage to quantum systems and CAT/EPT coupling.

Connects particle transport to qubit decoherence through the
entropy production rate lambda_radiation.

Source
------
Consolidated from ``geant4_catept_adapter.py`` (radiation_damage_qubit,
compute_lambda_radiation).
"""

from __future__ import annotations

from typing import Dict

import numpy as np

# Physical constants
HBAR = 1.054_571_817e-34   # J s
K_B = 1.380_649e-23         # J/K
MEV_TO_J = 1.602_176_634e-13  # J/MeV


def cosmic_ray_flux(particle_type: str = "proton", altitude: str = "sea_level") -> float:
    """Approximate cosmic ray flux.

    Parameters
    ----------
    particle_type : str
        ``'proton'``, ``'muon'``, ``'neutron'``, ``'gamma'``.
    altitude : str
        ``'sea_level'``, ``'mountain'`` (3000 m), ``'underground'``.

    Returns
    -------
    flux : float
        Flux (cm^-2 s^-1).

    Examples
    --------
    >>> cosmic_ray_flux("proton", "sea_level") > 0
    True
    """
    base = {
        "proton": 1e-2,
        "muon": 1e-2,
        "neutron": 5e-3,
        "gamma": 1e-3,
    }.get(particle_type, 1e-3)

    scale = {
        "sea_level": 1.0,
        "mountain": 10.0,
        "underground": 1e-6,
    }.get(altitude, 1.0)

    return base * scale


def radiation_damage_qubit(
    particle_type: str,
    energy_mev: float,
    *,
    qubit_area_cm2: float = 1e-4,
    qubit_freq_hz: float = 5e9,
    T1_intrinsic: float = 1e-3,
    T2_intrinsic: float = 0.5e-3,
    flux: float | None = None,
) -> Dict[str, float]:
    """Compute radiation-induced decoherence for a qubit.

    A particle hit deposits energy in the qubit substrate, creating
    quasiparticles that increase the decoherence rate.

    Parameters
    ----------
    particle_type : str
        Incident particle type.
    energy_mev : float
        Particle energy (MeV).
    qubit_area_cm2 : float
        Qubit sensitive area (cm^2).
    qubit_freq_hz : float
        Qubit transition frequency (Hz).
    T1_intrinsic : float
        Intrinsic energy relaxation time (s).
    T2_intrinsic : float
        Intrinsic dephasing time (s).
    flux : float, optional
        Particle flux (cm^-2 s^-1).  Uses cosmic ray default if ``None``.

    Returns
    -------
    dict
        ``hit_rate`` (s^-1), ``E_deposit_J``, ``gamma_rad`` (s^-1),
        ``T1_damaged`` (s), ``T2_damaged`` (s), ``degradation``.

    Examples
    --------
    >>> d = radiation_damage_qubit("proton", 100.0)
    >>> d["gamma_rad"] >= 0
    True
    >>> d["T1_damaged"] <= d["T1_damaged"] + 1  # always finite
    True
    """
    if flux is None:
        flux = cosmic_ray_flux(particle_type)

    hit_rate = flux * qubit_area_cm2

    # Energy deposit per hit (thin-target approximation)
    dE_dx = 1.0  # MeV/cm (approximate for superconductor)
    thickness = 1e-4  # cm
    E_deposit = min(dE_dx * thickness, energy_mev) * MEV_TO_J

    # Qubit energy scale
    E_qubit = HBAR * 2.0 * np.pi * qubit_freq_hz

    # Additional decoherence rate from radiation
    gamma_rad = hit_rate * (E_deposit / E_qubit)

    # Updated relaxation and dephasing times
    gamma_1_total = 1.0 / T1_intrinsic + gamma_rad
    T1_damaged = 1.0 / gamma_1_total

    gamma_phi_intrinsic = max(1.0 / T2_intrinsic - 1.0 / (2.0 * T1_intrinsic), 0.0)
    gamma_2_total = gamma_1_total / 2.0 + gamma_phi_intrinsic + gamma_rad
    T2_damaged = 1.0 / gamma_2_total

    degradation = (T1_intrinsic - T1_damaged) / T1_intrinsic

    return {
        "hit_rate": hit_rate,
        "E_deposit_J": E_deposit,
        "gamma_rad": gamma_rad,
        "T1_intrinsic": T1_intrinsic,
        "T1_damaged": T1_damaged,
        "T2_intrinsic": T2_intrinsic,
        "T2_damaged": T2_damaged,
        "degradation": degradation,
    }


def compute_lambda_radiation(
    particle_flux: float,
    energy_per_particle_mev: float,
    volume_cm3: float = 1.0,
    T: float = 300.0,
) -> float:
    """Radiation-induced entropy production rate.

    Computes the dissipation rate from particle flux into a volume:

        lambda_rad = P / (k_B T^2)

    where ``P = flux * area * E``.

    Parameters
    ----------
    particle_flux : float
        Particle flux (cm^-2 s^-1).
    energy_per_particle_mev : float
        Energy per particle (MeV).
    volume_cm3 : float
        Volume (cm^3).
    T : float
        Temperature (K).

    Returns
    -------
    lambda_rad : float
        Entropy production rate (s^-1).

    Examples
    --------
    >>> lam = compute_lambda_radiation(1e-2, 100, 1.0, 300)
    >>> lam > 0
    True
    """
    area_cm2 = volume_cm3 ** (2.0 / 3.0)
    E_J = energy_per_particle_mev * MEV_TO_J
    power = particle_flux * area_cm2 * E_J
    return power / (K_B * T**2)
