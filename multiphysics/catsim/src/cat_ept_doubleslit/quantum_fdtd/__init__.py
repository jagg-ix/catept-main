"""Quantum 1D TDSE utilities (FDTD baseline + QuTiP/Kwant optional backends).

This implements the refactor described in the uploaded markdown (23.md):
- Keep an explicit finite-difference TDSE solver as a baseline.
- Add a QuTiP driver for propagation + expectation values.
- Add a Kwant driver for step-potential scattering.

All optional backends are soft-imported.
"""

from .potentials import free_potential, step_potential, linear_potential, parabolic_potential
from .initial_states import gaussian_plane_wave
from .observables import compute_observables
from .fdtd import fdtd_tdse

__all__ = [
    "free_potential",
    "step_potential",
    "linear_potential",
    "parabolic_potential",
    "gaussian_plane_wave",
    "compute_observables",
    "fdtd_tdse",
]
