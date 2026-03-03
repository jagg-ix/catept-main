"""MEEP ↔ PySCF bridge (optional) with CAT/EPT timeline support.

Intent
------
This bridge is a repository-level interoperability layer (not a fork of MEEP
or PySCF). It lets us:

* compute a *quantum* material scalar using PySCF (e.g., a polarizability proxy)
* map it to an EM material parameter (epsilon) for MEEP
* apply CAT/EPT time reparameterization consistently using the repo's shared
  entropic-time contract:

    d tau_ent = lambda_eff(t) dt

The heavy lifting stays in the original libraries.

Backwards compatibility
----------------------
This module is safe-imported. If either MEEP or PySCF is not installed, the
bridge can still generate *deterministic placeholder outputs* and mark phases
as SKIP, preserving core repo functionality.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Callable, Any

import math
import numpy as np


def has_meep() -> bool:
    try:
        import meep  # noqa: F401

        return True
    except Exception:
        return False


def has_pyscf() -> bool:
    try:
        import pyscf  # noqa: F401

        return True
    except Exception:
        return False


@dataclass(frozen=True)
class PySCFMaterialModel:
    """Quantum-informed material scalar model.

    Parameters
    ----------
    epsilon0:
        Baseline permittivity used when quantum response is unavailable.
    alpha_scale:
        Scalar mapping factor from (dimensionless) polarizability proxy to
        epsilon increment.
    """

    epsilon0: float = 3.9
    alpha_scale: float = 1.0

    def epsilon_from_polarizability(self, alpha_proxy: float) -> float:
        return float(self.epsilon0 + self.alpha_scale * alpha_proxy)


def _pyscf_polarizability_proxy(*, basis: str = "sto-3g") -> float:
    """Compute a small static polarizability proxy using PySCF.

    Notes
    -----
    * We keep the molecule intentionally tiny so that running this is feasible
      in development/testing contexts.
    * This is NOT a calibrated ITO calculation; it is a placeholder that
      produces a stable scalar suitable for plumbing tests.
    """

    from pyscf import gto, scf

    # A very small oxide-like cluster (placeholder). The goal is a deterministic
    # response scalar, not chemical accuracy.
    mol = gto.M(
        atom="O 0 0 0; O 0 0 1.2",
        basis=basis,
        unit="Angstrom",
        verbose=0,
    )
    mf = scf.RHF(mol)
    mf.kernel()

    # Prefer the official polarizability module if present.
    try:
        from pyscf.prop.polarizability import rhf as rhf_polar

        pol = rhf_polar.Polarizability(mf).polarizability()
        # pol is a 3x3 tensor; take trace as a scalar proxy.
        return float(np.trace(np.array(pol)) / 3.0)
    except Exception:
        # Fallback: use the dipole moment magnitude as a very rough proxy.
        try:
            dip = np.array(mf.dip_moment(unit="Debye"), dtype=float)
            return float(np.linalg.norm(dip))
        except Exception:
            return 0.0


def build_epsilon_timeline(
    *,
    t_s: np.ndarray,
    lambda_eff_fn: Callable[[float], float],
    model: Optional[PySCFMaterialModel] = None,
    alpha_proxy: Optional[float] = None,
    redshift_factor_fn: Optional[Callable[[float], float]] = None,
    curved_spacetime_mode: bool = False,
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Return (tau_ent_s, lambda_eff, epsilon_t) over a provided time grid."""

    model = model or PySCFMaterialModel()
    if alpha_proxy is None:
        if has_pyscf():
            alpha_proxy = _pyscf_polarizability_proxy()
        else:
            alpha_proxy = 0.0

    lam = np.array([max(0.0, float(lambda_eff_fn(float(tt)))) for tt in t_s], dtype=float)
    # tau_ent(t) = ∫ lambda_eff dt
    tau = np.zeros_like(t_s, dtype=float)
    if len(t_s) >= 2:
        dt = np.diff(t_s)
        tau[1:] = np.cumsum(0.5 * (lam[:-1] + lam[1:]) * dt)

    # Map quantum scalar to epsilon and apply a conservative entropic damping
    # modifier as a *modeling knob* (not a physical claim):
    #     epsilon(t) = eps_base * exp(-tau_ent)
    base_eps = model.epsilon_from_polarizability(alpha_proxy)
    eps_t = base_eps * np.exp(-tau)

    # Optional curved-spacetime *effective medium* scaling.
    #
    # We do NOT modify MEEP's Maxwell solver; instead we expose a scalar hook
    # that can be driven by EinsteinPy-derived g00 (via SpacetimeCoupler's
    # redshift_factor a(t)=sqrt(-g00)). A conservative, dimensionless choice is
    # to scale epsilon by 1/a(t)^2, mirroring a time-dilation rescaling of
    # characteristic frequencies.
    if curved_spacetime_mode and (redshift_factor_fn is not None):
        a = np.array([max(1e-30, float(redshift_factor_fn(float(tt)))) for tt in t_s], dtype=float)
        eps_t = eps_t / (a ** 2)
    return tau, lam, eps_t


def make_meep_medium_from_epsilon(epsilon: float) -> Any:
    """Return a MEEP Medium (requires meep)."""

    import meep as mp

    return mp.Medium(epsilon=float(epsilon))
