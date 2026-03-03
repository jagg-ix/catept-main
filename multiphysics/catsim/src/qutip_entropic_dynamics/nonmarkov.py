"""Non-Markovian dynamics via OQuPy TEMPO.

Provides a thin wrapper around OQuPy's process-tensor (TEMPO) solver
that returns :class:`~qutip_entropic_dynamics.result.EntropicResult`.

OQuPy is an optional dependency.  Functions raise ``ImportError`` with
a clear message if it is not installed.

Source
------
``oqupy_backend.py`` (clean, minimal, 118 lines).
"""

from __future__ import annotations

import time as _time
from typing import Any, Optional

import numpy as np

from .entropy import entropy_trace
from .result import EntropicResult


def _require_oqupy():
    """Soft-import OQuPy."""
    try:
        import oqupy  # type: ignore
    except ImportError as e:
        raise ImportError(
            "OQuPy is required for non-Markovian solvers.  "
            "Install with:  pip install oqupy"
        ) from e
    return oqupy


def entropic_tempo(
    H_sys: np.ndarray,
    rho0: np.ndarray,
    tlist: np.ndarray,
    coupling_op: np.ndarray,
    bath: Any,
    tempo_params: Any,
    *,
    k_B: float = 1.380_649e-23,
) -> EntropicResult:
    """Run a TEMPO simulation and return entropic-time traces.

    Parameters
    ----------
    H_sys : ndarray, shape (d, d)
        System Hamiltonian matrix.
    rho0 : ndarray, shape (d, d)
        Initial density matrix.
    tlist : ndarray, shape (N,)
        Time array (seconds).
    coupling_op : ndarray, shape (d, d)
        System operator coupling to the bath.
    bath : oqupy.Bath
        OQuPy bath object describing the environment.
    tempo_params : oqupy.TempoParameters
        TEMPO algorithm parameters (dt, dkmax, epsrel).
    k_B : float, optional
        Boltzmann constant.

    Returns
    -------
    EntropicResult
        Result with ``entropy``, ``lambda_ent``, ``tau_ent`` computed
        from the reduced density matrices via the TEMPO solver.

    Examples
    --------
    >>> import oqupy
    >>> bath = oqupy.Bath(...)
    >>> params = oqupy.TempoParameters(dt=0.1, dkmax=20, epsrel=1e-6)
    >>> res = entropic_tempo(H, rho0, t, sigma_z, bath, params)
    """
    oqupy = _require_oqupy()
    t0_wall = _time.monotonic()
    tlist = np.asarray(tlist, dtype=float)

    system = oqupy.System(oqupy.operators.from_matrix(H_sys))
    initial_state = oqupy.operators.from_matrix(rho0)
    coup = oqupy.operators.from_matrix(coupling_op)

    tempo = oqupy.Tempo(
        system=system,
        bath=bath,
        initial_state=initial_state,
        parameters=tempo_params,
        coupling_operator=coup,
    )
    dyn = tempo.compute_dynamics()

    # Extract density matrices (OQuPy version-agnostic)
    if hasattr(dyn, "states"):
        rho_list = dyn.states
    elif hasattr(dyn, "rho_t"):
        rho_list = dyn.rho_t
    else:
        raise TypeError(
            "Cannot extract rho(t) from OQuPy Dynamics object. "
            "Check your OQuPy version."
        )

    rho_t = np.asarray([np.asarray(r) for r in rho_list], dtype=complex)
    S, lam, tau = entropy_trace(tlist, rho_t, k_B=k_B)

    return EntropicResult(
        times=tlist,
        states=list(rho_list),
        expect={},
        entropy=S,
        lambda_ent=lam,
        tau_ent=tau,
        stats={
            "solver": "tempo",
            "wall_time_s": _time.monotonic() - t0_wall,
        },
    )
