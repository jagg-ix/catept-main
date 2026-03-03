"""Simple 1D potentials (in eV) for TDSE demos.

Mirrors the potential helpers suggested in 23.md: free, step, linear, parabolic.
All functions return arrays in eV.
"""

from __future__ import annotations

import numpy as np


def free_potential(Nx: int) -> np.ndarray:
    """U(x)=0 in eV."""
    return np.zeros(int(Nx), dtype=float)


def step_potential(x: np.ndarray, U0_eV: float, L: float, x0: float | None = None) -> np.ndarray:
    """Step barrier starting at x0 (default L/2)."""
    if x0 is None:
        x0 = L / 2.0
    U = np.zeros_like(x, dtype=float)
    U[x >= x0] = float(U0_eV)
    return U


def linear_potential(x: np.ndarray, U0_eV: float, L: float) -> np.ndarray:
    """Linear ramp from U0 at x=0 down to 0 at x=L (matches 23.md)."""
    return -(float(U0_eV) / float(L)) * x + float(U0_eV)


def parabolic_potential(x: np.ndarray, U0_eV: float, L: float) -> np.ndarray:
    """Parabolic barrier/well with zero at x=0 and x=L (matches 23.md form)."""
    U0 = float(U0_eV)
    a = 4.0 * abs(U0) / (float(L) ** 2)
    b = -4.0 * abs(U0) / float(L)
    return a * x**2 + b * x
