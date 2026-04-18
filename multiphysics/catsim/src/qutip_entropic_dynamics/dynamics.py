"""Core Markovian solvers wrapping QuTiP mesolve/sesolve.

All solvers return :class:`~qutip_entropic_dynamics.result.EntropicResult`
with automatically computed entropy, lambda, and tau_ent traces.

Source
------
Production-quality code from ``qutip_backend.py`` (6 functions), upgraded
to populate ``EntropicResult`` with entropy tracking.

Requires
--------
``qutip`` (soft-imported at call time).
"""

from __future__ import annotations

import time as _time
from typing import Callable, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .entropy import entropy_vn, entropy_production_rate
from .reparameterize import tau_from_lambda
from .result import EntropicResult


def _require_qutip():
    """Soft-import QuTiP, raising a clear error if absent."""
    try:
        import qutip as qt  # type: ignore
    except ImportError as e:
        raise ImportError(
            "QuTiP is required for dynamics solvers.  "
            "Install with:  pip install qutip"
        ) from e
    return qt


def _entropy_from_states(states, k_B: float = 1.0) -> Tuple[np.ndarray, ...]:
    """Extract S, lambda, tau from a list of QuTiP states."""
    rho_list = []
    for s in states:
        if s.isket:
            rho_list.append(s.full() @ s.full().conj().T)
        else:
            rho_list.append(np.asarray(s.full(), dtype=complex))
    rho_arr = np.array(rho_list, dtype=complex)
    S = np.array([entropy_vn(r) for r in rho_arr], dtype=float)
    return S, rho_arr


def entropic_mesolve(
    H,
    rho0,
    tlist: np.ndarray,
    c_ops: Sequence = (),
    e_ops: Optional[Dict[str, object]] = None,
    *,
    k_B: float = 1.0,
    options: object = None,
) -> EntropicResult:
    """Lindblad master equation with entropy tracking.

    Wraps ``qutip.mesolve`` and automatically computes von Neumann
    entropy ``S(t)``, entropy production rate ``lambda(t)``, and
    entropic proper time ``tau_ent(t)`` from the resulting states.

    Parameters
    ----------
    H : Qobj or list
        System Hamiltonian (or time-dependent list).
    rho0 : Qobj
        Initial density matrix.
    tlist : array_like
        Time points for the evolution.
    c_ops : sequence of Qobj
        Lindblad collapse operators.
    e_ops : dict of str -> Qobj, optional
        Expectation-value operators.
    k_B : float, optional
        Boltzmann constant (set to 1.0 for natural units).
    options : qutip.Options, optional
        Solver options forwarded to ``mesolve``.

    Returns
    -------
    EntropicResult
        Result with ``times``, ``states``, ``expect``, ``entropy``,
        ``lambda_ent``, ``tau_ent``, and ``stats``.

    Examples
    --------
    >>> import qutip as qt
    >>> H = qt.sigmaz()
    >>> rho0 = qt.ket2dm(qt.basis(2, 0))
    >>> c_ops = [0.1 * qt.sigmam()]
    >>> res = entropic_mesolve(H, rho0, np.linspace(0, 10, 100), c_ops)
    >>> res.entropy  # von Neumann entropy trace
    """
    qt = _require_qutip()
    t0 = _time.monotonic()
    tlist = np.asarray(tlist, dtype=float)

    # Build e_ops list for QuTiP
    e_ops_list = list(e_ops.values()) if e_ops else []
    e_ops_keys = list(e_ops.keys()) if e_ops else []

    kwargs = {"c_ops": list(c_ops), "e_ops": e_ops_list}
    if options is not None:
        kwargs["options"] = options

    res = qt.mesolve(H, rho0, tlist, **kwargs)

    # Extract expectation values
    expect = {}
    for i, k in enumerate(e_ops_keys):
        expect[k] = np.asarray(res.expect[i], dtype=float)

    # Compute entropy traces from states
    S, _ = _entropy_from_states(res.states, k_B=k_B)
    lam = entropy_production_rate(S, tlist, k_B=k_B)
    tau = tau_from_lambda(tlist, lam)

    return EntropicResult(
        times=tlist,
        states=list(res.states),
        expect=expect,
        entropy=S,
        lambda_ent=lam,
        tau_ent=tau,
        stats={"solver": "mesolve", "wall_time_s": _time.monotonic() - t0},
    )


def entropic_sesolve(
    H,
    psi0,
    tlist: np.ndarray,
    e_ops: Optional[Dict[str, object]] = None,
    *,
    k_B: float = 1.0,
    options: object = None,
) -> EntropicResult:
    """Schrodinger equation with entropy tracking.

    For pure-state evolution the von Neumann entropy remains zero.
    This function is useful for consistency checks and as a baseline.

    Parameters
    ----------
    H : Qobj or list
        Hamiltonian.
    psi0 : Qobj
        Initial ket.
    tlist : array_like
        Time points.
    e_ops : dict of str -> Qobj, optional
        Expectation-value operators.
    k_B : float, optional
        Boltzmann constant.
    options : qutip.Options, optional
        Solver options.

    Returns
    -------
    EntropicResult
    """
    qt = _require_qutip()
    t0 = _time.monotonic()
    tlist = np.asarray(tlist, dtype=float)

    e_ops_list = list(e_ops.values()) if e_ops else []
    e_ops_keys = list(e_ops.keys()) if e_ops else []

    kwargs = {"e_ops": e_ops_list}
    if options is not None:
        kwargs["options"] = options

    res = qt.sesolve(H, psi0, tlist, **kwargs)

    expect = {}
    for i, k in enumerate(e_ops_keys):
        expect[k] = np.asarray(res.expect[i], dtype=float)

    S, _ = _entropy_from_states(res.states, k_B=k_B)
    lam = entropy_production_rate(S, tlist, k_B=k_B)
    tau = tau_from_lambda(tlist, lam)

    return EntropicResult(
        times=tlist,
        states=list(res.states),
        expect=expect,
        entropy=S,
        lambda_ent=lam,
        tau_ent=tau,
        stats={"solver": "sesolve", "wall_time_s": _time.monotonic() - t0},
    )


def evolve_complex_action(
    H_R,
    J,
    psi0,
    tlist: np.ndarray,
    lambda_fn: Callable[[float], float],
    *,
    hbar: float = 1.054_571_817e-34,
    k_B: float = 1.0,
    normalize_output: bool = False,
    e_ops: Optional[Dict[str, object]] = None,
) -> EntropicResult:
    """Evolve with time-dependent complex action (CAT/EPT).

    Implements:

        i hbar d|psi>/dt = (H_R - i hbar lambda(t) J) |psi>

    where *J* is a Hermitian operator representing the dissipative
    channel and ``lambda(t)`` is the entropy production rate.

    Parameters
    ----------
    H_R : Qobj or ndarray
        Real (Hermitian) part of the Hamiltonian.
    J : Qobj or ndarray
        Dissipative channel operator (Hermitian).
    psi0 : Qobj or ndarray
        Initial state ket.
    tlist : array_like
        Time points (seconds).
    lambda_fn : callable
        ``lambda_fn(t) -> float``, the entropy production rate at time *t*.
    hbar : float, optional
        Reduced Planck constant.
    k_B : float, optional
        Boltzmann constant.
    normalize_output : bool, optional
        Whether to normalise states at each step.
    e_ops : dict of str -> Qobj, optional
        Expectation-value operators.

    Returns
    -------
    EntropicResult
        Result with ``lambda_ent`` and ``tau_ent`` computed from
        ``lambda_fn`` evaluated on *tlist*.

    Examples
    --------
    >>> H_R = qt.sigmaz()
    >>> J = qt.sigmam().dag() * qt.sigmam()
    >>> psi0 = qt.basis(2, 0)
    >>> res = evolve_complex_action(H_R, J, psi0,
    ...     np.linspace(0, 1e-9, 100), lambda t: 1e6)
    """
    qt = _require_qutip()
    t0_wall = _time.monotonic()
    tlist = np.asarray(tlist, dtype=float)

    # Ensure Qobj
    if not hasattr(H_R, "dag"):
        H_R = qt.Qobj(np.asarray(H_R, dtype=complex))
    if not hasattr(J, "dag"):
        J = qt.Qobj(np.asarray(J, dtype=complex))
    if not hasattr(psi0, "dag"):
        psi0 = qt.Qobj(np.asarray(psi0, dtype=complex))

    H_Rq = H_R / hbar

    def lam_coeff(t, **kw):
        return float(lambda_fn(float(t)))

    H = [H_Rq, [-1j * J, lam_coeff]]

    e_ops_list = list(e_ops.values()) if e_ops else []
    e_ops_keys = list(e_ops.keys()) if e_ops else []

    res = qt.sesolve(H, psi0, tlist, e_ops=e_ops_list)

    expect = {}
    for i, k in enumerate(e_ops_keys):
        expect[k] = np.asarray(res.expect[i], dtype=float)

    # Lambda and tau from the provided profile
    lam_vals = np.array([float(lambda_fn(float(t))) for t in tlist], dtype=float)
    tau = tau_from_lambda(tlist, lam_vals)

    # Entropy from states
    S, _ = _entropy_from_states(res.states, k_B=k_B)

    return EntropicResult(
        times=tlist,
        states=list(res.states),
        expect=expect,
        entropy=S,
        lambda_ent=lam_vals,
        tau_ent=tau,
        stats={
            "solver": "sesolve_complex_action",
            "wall_time_s": _time.monotonic() - t0_wall,
        },
    )


def evolve_in_tau(
    H_R,
    J,
    psi0,
    tlist: np.ndarray,
    lambda_fn: Callable[[float], float],
    *,
    hbar: float = 1.054_571_817e-34,
    k_B: float = 1.0,
    normalize_output: bool = False,
    e_ops: Optional[Dict[str, object]] = None,
) -> EntropicResult:
    """Evolve in entropic proper time tau.

    Uses the reparameterization ``d(tau) = lambda(t) dt`` to transform
    the generator into tau-coordinates:

        i hbar d|psi>/d(tau) = (H_R / lambda(t(tau)) - i hbar J) |psi>

    Parameters
    ----------
    H_R : Qobj or ndarray
        Hermitian Hamiltonian.
    J : Qobj or ndarray
        Dissipative channel operator.
    psi0 : Qobj or ndarray
        Initial state ket.
    tlist : array_like
        Coordinate-time grid (seconds).
    lambda_fn : callable
        ``lambda_fn(t) -> float``.
    hbar : float, optional
        Reduced Planck constant.
    k_B : float, optional
        Boltzmann constant.
    normalize_output : bool, optional
        Normalise at each step.
    e_ops : dict of str -> Qobj, optional
        Expectation-value operators.

    Returns
    -------
    EntropicResult
        ``times`` contains the *tau* grid (not coordinate time).
    """
    qt = _require_qutip()
    t0_wall = _time.monotonic()
    tlist = np.asarray(tlist, dtype=float)

    if not hasattr(H_R, "dag"):
        H_R = qt.Qobj(np.asarray(H_R, dtype=complex))
    if not hasattr(J, "dag"):
        J = qt.Qobj(np.asarray(J, dtype=complex))
    if not hasattr(psi0, "dag"):
        psi0 = qt.Qobj(np.asarray(psi0, dtype=complex))

    # Evaluate lambda on coordinate-time grid
    lam_t = np.array([float(lambda_fn(float(t))) for t in tlist], dtype=float)
    if np.any(lam_t <= 0):
        raise ValueError("lambda_fn must be > 0 for tau evolution")

    tau_t = tau_from_lambda(tlist, lam_t)

    # Build tau -> 1/lambda interpolation
    inv_lam = 1.0 / lam_t

    def inv_lambda_of_tau(tau, **kw):
        return float(np.interp(float(tau), tau_t, inv_lam))

    H_Rq = H_R / hbar
    H = [[H_Rq, inv_lambda_of_tau], -1j * J]

    e_ops_list = list(e_ops.values()) if e_ops else []
    e_ops_keys = list(e_ops.keys()) if e_ops else []

    res = qt.sesolve(H, psi0, tau_t, e_ops=e_ops_list)

    expect = {}
    for i, k in enumerate(e_ops_keys):
        expect[k] = np.asarray(res.expect[i], dtype=float)

    S, _ = _entropy_from_states(res.states, k_B=k_B)

    return EntropicResult(
        times=tau_t,
        states=list(res.states),
        expect=expect,
        entropy=S,
        lambda_ent=lam_t,
        tau_ent=tau_t,
        stats={
            "solver": "sesolve_tau",
            "wall_time_s": _time.monotonic() - t0_wall,
        },
    )
