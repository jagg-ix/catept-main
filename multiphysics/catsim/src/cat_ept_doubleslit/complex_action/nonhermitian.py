"""Complex-action evolution helpers.

We keep this module intentionally conservative and implementation-oriented:

* Coordinate-time generator:

    i ħ d/dt |psi> = (H_R - i H_I) |psi>

  where H_R is Hermitian and H_I is positive semidefinite (for monotonic
  entropy production / norm decay).

* Entropic proper time reparameterization:

    tau_ent(t) = ∫ lambda(t) dt,   lambda >= 0
    d/dt = lambda d/dtau

  giving:

    i ħ d/dtau |psi> = (H_R - i H_I)/lambda |psi>

In code we implement:
  - a generic scalar lambda(t) interface,
  - rescaled generators for use by explicit integrators.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional, Protocol

import numpy as np


class LambdaFn(Protocol):
    def __call__(self, t_s: float, state: object | None = None) -> float:  # pragma: no cover
        ...


@dataclass(frozen=True)
class ComplexActionModel:
    """Defines how lambda and H_I are related.

This class is *not* a claim about microscopic uniqueness; it is a wiring point
for simulators.
    """

    lambda_fn: LambdaFn
    hbar: float = 1.054_571_817e-34

    def lambda_at(self, t_s: float, state: object | None = None) -> float:
        lam = float(self.lambda_fn(t_s, state))
        if lam < 0:
            raise ValueError(f"lambda must be >= 0, got {lam}")
        return lam

    def dtau_from_dt(self, t_s: float, dt_s: float, state: object | None = None) -> float:
        return self.lambda_at(t_s, state) * float(dt_s)

    def generator_tau(
        self,
        t_s: float,
        H_R: np.ndarray,
        H_I: np.ndarray,
        state: object | None = None,
        lambda_floor: float = 0.0,
    ) -> np.ndarray:
        """Return the effective generator G_tau for dpsi/dtau = G_tau psi.

For entropic-time stepping:

    dpsi/dtau = -(i/ħ) (H_R - i H_I)/lambda * psi

So:
    G_tau = -(i/ħ) * (H_R - i H_I) / lambda
         = -(i/ħ) * H_R/lambda  - (1/ħ) * H_I/lambda
        """

        lam = self.lambda_at(t_s, state)
        lam_eff = max(lam, float(lambda_floor))
        if lam_eff <= 0:
            raise ValueError("lambda must be > 0 for tau stepping (or set lambda_floor)")
        return (-1j / self.hbar) * (H_R - 1j * H_I) / lam_eff


def ensure_hermitian(M: np.ndarray, tol: float = 1e-10) -> None:
    if not np.allclose(M, M.conjugate().T, atol=tol, rtol=0):
        raise ValueError("Matrix expected Hermitian")


def ensure_psd(M: np.ndarray, tol: float = 1e-10) -> None:
    """Checks positive semidefinite via eigenvalues (small sizes only)."""
    ensure_hermitian(M, tol=tol)
    w = np.linalg.eigvalsh(M)
    if np.min(w) < -tol:
        raise ValueError(f"Matrix expected PSD, min eigenvalue={np.min(w)}")


def effective_generator_t(H_R: np.ndarray, H_I: np.ndarray, hbar: float) -> np.ndarray:
    """Return generator G for coordinate-time stepping: dpsi/dt = G psi.

From:
    i ħ d/dt |psi> = (H_R - i H_I) |psi>

We get:
    d/dt |psi> = -(i/ħ) (H_R - i H_I) |psi>
              = -(i/ħ) H_R |psi> - (1/ħ) H_I |psi>
    """
    return (-1j / float(hbar)) * (H_R - 1j * H_I)


def effective_generator_tau(
    H_R: np.ndarray, H_I: np.ndarray, hbar: float, lam: float
) -> np.ndarray:
    """Return generator G_tau for entropic-time stepping: dpsi/dtau = G_tau psi."""
    lam_eff = float(lam)
    if lam_eff <= 0:
        raise ValueError("lambda must be > 0 for tau stepping")
    return (-1j / float(hbar)) * (H_R - 1j * H_I) / lam_eff
