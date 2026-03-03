"""Shared observables for 1D TDSE demos.

Goal: a single validation layer so FDTD arrays and QuTiP states can be compared,
as suggested in 23.md.

Conventions:
- x grid in meters
- potential U in eV
- psi is normalized in L2 with dx
"""

from __future__ import annotations

import numpy as np

try:
    import qutip as qt

    QUTIP_AVAILABLE = True
except Exception:
    QUTIP_AVAILABLE = False
    qt = None  # type: ignore

HBAR = 1.054571817e-34
M_E = 9.1093837015e-31
E_CHARGE = 1.602176634e-19


def _as_numpy_psi(psi) -> np.ndarray:
    """Accept either a complex ndarray or a QuTiP Qobj ket."""
    if isinstance(psi, np.ndarray):
        return psi.astype(complex, copy=False)
    if QUTIP_AVAILABLE and isinstance(psi, qt.Qobj):
        arr = np.asarray(psi.full()).reshape(-1)
        return arr.astype(complex, copy=False)
    raise TypeError("psi must be numpy array or qutip.Qobj")


def _normalize_if_needed(psi: np.ndarray, dx: float) -> np.ndarray:
    norm = np.sqrt(np.sum(np.abs(psi) ** 2) * dx)
    if norm == 0:
        raise ValueError("Wavefunction has zero norm")
    # tolerate small drift
    if abs(norm - 1.0) > 1e-3:
        psi = psi / norm
    return psi


def expectation_x(psi, x: np.ndarray) -> float:
    psi_np = _as_numpy_psi(psi)
    dx = float(x[1] - x[0])
    psi_np = _normalize_if_needed(psi_np, dx)
    return float(np.sum(np.conj(psi_np) * x * psi_np).real * dx)


def expectation_p(psi, x: np.ndarray) -> float:
    """⟨p⟩ using a centered difference for ∂ψ/∂x."""
    psi_np = _as_numpy_psi(psi)
    dx = float(x[1] - x[0])
    psi_np = _normalize_if_needed(psi_np, dx)

    dpsi = np.zeros_like(psi_np)
    dpsi[1:-1] = (psi_np[2:] - psi_np[:-2]) / (2.0 * dx)
    integrand = np.conj(psi_np) * (-1j * HBAR) * dpsi
    return float(np.sum(integrand).real * dx)


def expectation_energy(psi, U_eV: np.ndarray, x: np.ndarray, m: float = M_E) -> float:
    """⟨H⟩ = ⟨T⟩ + ⟨U⟩.

    Uses a second derivative for kinetic term.
    """
    psi_np = _as_numpy_psi(psi)
    dx = float(x[1] - x[0])
    psi_np = _normalize_if_needed(psi_np, dx)

    # second derivative
    d2psi = np.zeros_like(psi_np)
    d2psi[1:-1] = (psi_np[2:] - 2.0 * psi_np[1:-1] + psi_np[:-2]) / (dx**2)

    Tpsi = -(HBAR**2) / (2.0 * float(m)) * d2psi
    Upsi = (U_eV.astype(float) * E_CHARGE) * psi_np
    Hpsi = Tpsi + Upsi
    E = np.sum(np.conj(psi_np) * Hpsi).real * dx
    return float(E)


def compute_observables(psi, U_eV: np.ndarray, x: np.ndarray, m: float = M_E) -> dict:
    """Compute a small set of comparable observables."""
    return {
        "x_expect_m": expectation_x(psi, x),
        "p_expect_kg_m_s": expectation_p(psi, x),
        "E_expect_J": expectation_energy(psi, U_eV, x, m=m),
    }
