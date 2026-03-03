"""Particle transport: creation, materials, Monte Carlo stepping.

Provides the core data structures and transport engine.  Cross sections
are delegated to :mod:`qutip_geant4_bridge.cross_sections`.

Source
------
Consolidated from ``geant4_catept_adapter.py`` (Particle, Material,
Geant4Adapter.transport_particle, material database).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List, Optional, Sequence

import numpy as np

from .cross_sections import total_photon_cross_section, compton_scatter

# Physical constants
C = 2.997_924_58e8      # m/s
BARN_TO_CM2 = 1e-24     # cm^2/barn
N_A = 6.022_140_76e23   # Avogadro's number
PC_TO_CM = 3.085_677_6e18  # cm/pc


@dataclass
class Particle:
    """Particle state.

    Parameters
    ----------
    particle_type : str
        ``'gamma'``, ``'electron'``, ``'positron'``, ``'proton'``,
        ``'neutron'``, ``'alpha'``.
    energy : float
        Kinetic energy (MeV).
    position : ndarray, shape (3,)
        Position (m).
    direction : ndarray, shape (3,)
        Unit direction vector.
    time : float
        Time (s).
    weight : float
        Importance sampling weight.
    """

    particle_type: str
    energy: float
    position: np.ndarray
    direction: np.ndarray
    time: float = 0.0
    weight: float = 1.0


@dataclass(frozen=True)
class Material:
    """Material properties.

    Parameters
    ----------
    name : str
        Human-readable name.
    Z : float
        Effective atomic number.
    A : float
        Effective mass number.
    density : float
        Density (g/cm^3).
    I_mean : float
        Mean excitation energy (eV).
    """

    name: str
    Z: float
    A: float
    density: float
    I_mean: float


class MaterialDatabase:
    """Built-in material database.

    Examples
    --------
    >>> db = MaterialDatabase()
    >>> si = db["silicon"]
    >>> si.Z
    14.0
    """

    _MATERIALS: Dict[str, Material] = {
        "vacuum": Material("Vacuum", 0, 0, 0, 0),
        "ISM": Material("ISM (H)", 1, 1, 1e-24, 19.2),
        "air": Material("Air", 7.3, 14.4, 1.2e-3, 85.7),
        "water": Material("Water", 7.42, 11.9, 1.0, 75.0),
        "silicon": Material("Silicon", 14, 28, 2.33, 173),
        "lead": Material("Lead", 82, 207, 11.35, 823),
        "scintillator": Material("NaI", 32, 64, 3.67, 452),
        "superconductor": Material("Nb", 41, 93, 8.57, 417),
    }

    def __getitem__(self, name: str) -> Material:
        return self._MATERIALS[name]

    def __contains__(self, name: str) -> bool:
        return name in self._MATERIALS

    def list_materials(self) -> List[str]:
        """Return list of available material names."""
        return list(self._MATERIALS.keys())

    def add(self, key: str, material: Material) -> None:
        """Register a custom material."""
        self._MATERIALS[key] = material


def create_particle(
    particle_type: str,
    energy: float,
    position: Sequence[float],
    direction: Optional[Sequence[float]] = None,
) -> Particle:
    """Create a particle with optional random direction.

    Parameters
    ----------
    particle_type : str
        Particle species.
    energy : float
        Kinetic energy (MeV).
    position : sequence of float
        ``[x, y, z]`` in metres.
    direction : sequence of float, optional
        Unit direction.  Random isotropic if ``None``.

    Returns
    -------
    Particle

    Examples
    --------
    >>> p = create_particle("gamma", 1.0, [0, 0, 0])
    >>> p.particle_type
    'gamma'
    """
    pos = np.asarray(position, dtype=float)

    if direction is None:
        cos_theta = np.random.uniform(-1, 1)
        sin_theta = np.sqrt(1 - cos_theta**2)
        phi = np.random.uniform(0, 2 * np.pi)
        d = np.array([sin_theta * np.cos(phi), sin_theta * np.sin(phi), cos_theta])
    else:
        d = np.asarray(direction, dtype=float)
        d = d / np.linalg.norm(d)

    return Particle(
        particle_type=particle_type,
        energy=energy,
        position=pos,
        direction=d,
        time=0.0,
    )


@dataclass
class TransportResult:
    """Result of particle transport.

    Attributes
    ----------
    transmission : float
        Transmitted fraction.
    lambda_mfp : float
        Mean free path (cm).
    final_particle : Particle or None
    energies : list of float
        Energy at each step.
    n_steps : int
    """

    transmission: float
    lambda_mfp: float
    final_particle: Optional[Particle]
    energies: List[float]
    n_steps: int


def transport_particle(
    particle: Particle,
    material: Material,
    distance_cm: float,
    *,
    max_steps: int = 1000,
    rng: Optional[np.random.Generator] = None,
) -> TransportResult:
    """Monte Carlo transport of a particle through material.

    Parameters
    ----------
    particle : Particle
        Initial particle.
    material : Material
        Target material.
    distance_cm : float
        Path length (cm).
    max_steps : int
        Maximum interaction steps.
    rng : numpy.random.Generator, optional
        Random number generator.

    Returns
    -------
    TransportResult

    Examples
    --------
    >>> db = MaterialDatabase()
    >>> p = create_particle("gamma", 1.0, [0, 0, 0], [0, 0, 1])
    >>> res = transport_particle(p, db["water"], 10.0)
    >>> res.n_steps >= 0
    True
    """
    if rng is None:
        rng = np.random.default_rng()

    if material.density == 0:
        return TransportResult(
            transmission=1.0,
            lambda_mfp=float("inf"),
            final_particle=particle,
            energies=[particle.energy],
            n_steps=0,
        )

    # Number density
    n_atoms = material.density * N_A / material.A

    energies = [particle.energy]
    current = particle
    traveled = 0.0

    for _ in range(max_steps):
        if current is None or current.energy < 1e-6:
            break

        if current.particle_type == "gamma":
            sigma_barn = total_photon_cross_section(current.energy, material)
            sigma_cm2 = sigma_barn * BARN_TO_CM2
        else:
            sigma_cm2 = 1e-24  # placeholder for charged particles

        lambda_mfp = 1.0 / (n_atoms * sigma_cm2) if sigma_cm2 > 0 else 1e30

        s = -lambda_mfp * np.log(rng.random())

        if traveled + s > distance_cm:
            traveled = distance_cm
            break

        traveled += s
        current.position += current.direction * s / 100  # cm -> m

        if current.particle_type == "gamma":
            E_new, theta = compton_scatter(current.energy)
            if E_new < 1e-6:
                current = None
                break
            current.energy = E_new
            # Rotate direction (simplified — deflect by theta in xz plane)
            cos_t, sin_t = np.cos(theta), np.sin(theta)
            d = current.direction
            current.direction = np.array([
                d[0] * cos_t + d[2] * sin_t,
                d[1],
                -d[0] * sin_t + d[2] * cos_t,
            ])

        if current is not None:
            energies.append(current.energy)

    # Approximate transmission
    if material.density > 0 and n_atoms > 0:
        sigma_barn_final = total_photon_cross_section(particle.energy, material) if particle.particle_type == "gamma" else 1.0
        sigma_cm2_final = sigma_barn_final * BARN_TO_CM2
        lambda_mfp_final = 1.0 / (n_atoms * sigma_cm2_final) if sigma_cm2_final > 0 else 1e30
        transmission = np.exp(-distance_cm / lambda_mfp_final)
    else:
        lambda_mfp_final = float("inf")
        transmission = 1.0

    return TransportResult(
        transmission=transmission,
        lambda_mfp=lambda_mfp_final,
        final_particle=current,
        energies=energies,
        n_steps=len(energies),
    )
