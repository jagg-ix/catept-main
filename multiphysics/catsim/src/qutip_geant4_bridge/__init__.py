"""Geant4 particle transport bridge for entropic dynamics.

Provides Monte Carlo particle transport, electromagnetic cross sections,
and radiation damage computation that connects to QuTiP quantum systems
through the CAT/EPT entropy production rate.

Modules
-------
- **transport**: Particle creation, material database, Monte Carlo stepping
- **cross_sections**: Compton, pair production, photoelectric, stopping power
- **radiation**: Radiation damage to qubits, radiation-induced decoherence
- **wasm**: WSM bridge configuration for browser-based Geant4

Requires
--------
``numpy`` for all modules.  ``qutip`` optional (soft-imported in radiation).
"""

from __future__ import annotations

__version__ = "0.1.0"

from .transport import Particle, Material, MaterialDatabase
from .cross_sections import (
    compton_cross_section,
    compton_scatter,
    pair_production_cross_section,
    photoelectric_cross_section,
    bethe_bloch_stopping_power,
    total_photon_cross_section,
)
from .radiation import (
    radiation_damage_qubit,
    compute_lambda_radiation,
    cosmic_ray_flux,
)

__all__ = [
    # transport
    "Particle",
    "Material",
    "MaterialDatabase",
    # cross_sections
    "compton_cross_section",
    "compton_scatter",
    "pair_production_cross_section",
    "photoelectric_cross_section",
    "bethe_bloch_stopping_power",
    "total_photon_cross_section",
    # radiation
    "radiation_damage_qubit",
    "compute_lambda_radiation",
    "cosmic_ray_flux",
]
