"""Initial states for 1D TDSE demos."""

from __future__ import annotations

import numpy as np


def gaussian_plane_wave(x: np.ndarray, xc: float, s: float, lam: float) -> np.ndarray:
    """Gaussian-modulated plane wave, normalized on the grid.

    Matches the definition in 23.md.

    Args:
        x: position grid (m)
        xc: center position (m)
        s: envelope sigma (m)
        lam: de Broglie wavelength (m)

    Returns:
        psi: complex wavefunction (L2-normalized with dx)
    """
    k = 2.0 * np.pi / float(lam)
    env = np.exp(-0.5 * ((x - xc) / float(s)) ** 2)
    psi = env * np.exp(1j * k * (x - xc))

    dx = float(x[1] - x[0])
    norm = np.sqrt(np.sum(np.abs(psi) ** 2) * dx)
    if norm == 0:
        raise ValueError("Zero norm initial state")
    return psi / norm
