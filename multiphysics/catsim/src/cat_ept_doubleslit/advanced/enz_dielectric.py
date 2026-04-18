"""ENZ dielectric utilities (ADVANCED / proxy).

These routines support Phase 6.1's **diagnostic** check: whether a geometric
proposal \(\lambda(\omega) \propto 1/|v_g(\omega)|\) can be made *consistent*
with the Phase 5 fitted scalar \(\lambda_{ent}\) when calibrated at a chosen
carrier frequency.

Parameter provenance (traceability)
----------------------------------
The Drude parameters used here **must be treated as configuration**, not as
ground truth. Defaults in :class:`DrudeParams` are only placeholders so the
pipeline runs out of the box. For publishable runs, set parameters in
``configs/enz_ito.yaml`` using the exact values cited in your manuscript/SI.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Iterable

import numpy as np


@dataclass(frozen=True)
class DrudeParams:
    """Simple Drude permittivity model.

    eps(ω) = eps_inf - ωp^2 / (ω^2 + i γ ω)

    Units:
      - ω, ωp, γ in rad/s
      - eps_inf dimensionless
    """

    eps_inf: float = 3.5
    omega_p: float = 2.5e15
    gamma: float = 1.0e14


def eps_drude(omega: np.ndarray, p: DrudeParams) -> np.ndarray:
    omega = np.asarray(omega, dtype=float)
    # Avoid division by zero at omega=0
    denom = omega**2 + 1j * p.gamma * omega
    denom = np.where(np.abs(denom) < 1e-30, 1e-30 + 0j, denom)
    return p.eps_inf - (p.omega_p**2) / denom


def n_from_eps(eps: np.ndarray) -> np.ndarray:
    """Principal branch refractive index from permittivity."""
    return np.sqrt(eps)


def group_velocity(
    omega: np.ndarray,
    eps: np.ndarray,
    c: float = 299_792_458.0,
) -> np.ndarray:
    """Compute group velocity via finite-difference group index.

    We use n_g = Re(n) + ω d Re(n)/dω.
    This is a conservative, numerically stable proxy adequate for consistency tests.
    """
    omega = np.asarray(omega, dtype=float)
    n = n_from_eps(eps)
    n_re = np.real(n)

    # If we only have one frequency point, fall back to phase velocity proxy.
    # This is sufficient for carrier calibration in Phase 6.1.
    if omega.size < 2:
        n_g = np.where(np.abs(n_re) > 1e-12, n_re, np.nan)
        return c / n_g

    # Finite difference derivative of Re(n) w.r.t omega
    dn = np.gradient(n_re, omega, edge_order=1)
    n_g = n_re + omega * dn
    # Guard against nonphysical or near-zero group index
    n_g = np.where(np.isfinite(n_g) & (np.abs(n_g) > 1e-12), n_g, np.nan)
    vg = c / n_g
    return vg


def omega_grid_from_THz(freq_THz: Iterable[float]) -> np.ndarray:
    f = np.asarray(list(freq_THz), dtype=float) * 1e12
    return 2 * math.pi * f


def load_eps_table(csv_path: str) -> tuple[np.ndarray, np.ndarray]:
    """Load complex permittivity ε(ω) from a CSV.

    Expected columns (case-insensitive):
      - freq_THz
      - eps_real
      - eps_imag

    Returns:
      omega_rad_s, eps_complex
    """
    import pandas as pd
    df = pd.read_csv(csv_path)
    cols = {c.lower(): c for c in df.columns}
    for req in ('freq_thz','eps_real','eps_imag'):
        if req not in cols:
            raise ValueError(f"Missing column '{req}' in {csv_path}. Found: {list(df.columns)}")
    freq_THz = df[cols['freq_thz']].to_numpy(dtype=float)
    eps_re = df[cols['eps_real']].to_numpy(dtype=float)
    eps_im = df[cols['eps_imag']].to_numpy(dtype=float)
    omega = omega_grid_from_THz(freq_THz)
    eps = eps_re + 1j*eps_im
    return omega, eps
