"""Entropic dynamics result container.

Extends the QuTiP ``Result`` pattern with entropy production tracking.
All solvers in this package return an ``EntropicResult`` populated with
time-resolved von Neumann entropy, entropy production rate, and
entropic proper time.

The container is intentionally a plain class (not a dataclass) to match
QuTiP conventions and allow mutable population during solver runs.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

import numpy as np


class EntropicResult:
    """Solver result with entropic proper-time tracking.

    Parameters
    ----------
    times : array_like
        Coordinate (lab) time array, shape ``(N,)``.
    states : list of object
        List of density matrices or kets at each time step.
    expect : dict of str -> ndarray
        Expectation-value traces keyed by operator name.
    entropy : ndarray or None
        Von Neumann entropy ``S(t)`` at each time step.
    lambda_ent : ndarray or None
        Entropy production rate ``lambda(t) = (1/k_B) dS/dt``.
    tau_ent : ndarray or None
        Accumulated entropic proper time ``tau(t) = int lambda dt``.
    stats : dict
        Solver statistics (solver name, wall time, etc.).

    Examples
    --------
    >>> res = entropic_mesolve(H, rho0, tlist, c_ops)
    >>> res.times       # coordinate time
    >>> res.entropy     # S(t)
    >>> res.lambda_ent  # lambda(t)
    >>> res.tau_ent     # tau_ent(t)
    """

    def __init__(
        self,
        times: np.ndarray,
        states: Optional[List[Any]] = None,
        expect: Optional[Dict[str, np.ndarray]] = None,
        entropy: Optional[np.ndarray] = None,
        lambda_ent: Optional[np.ndarray] = None,
        tau_ent: Optional[np.ndarray] = None,
        stats: Optional[Dict[str, Any]] = None,
    ):
        self.times = np.asarray(times, dtype=float)
        self.states = states if states is not None else []
        self.expect = expect if expect is not None else {}
        self.entropy = entropy
        self.lambda_ent = lambda_ent
        self.tau_ent = tau_ent
        self.stats = stats if stats is not None else {}

    @property
    def num_times(self) -> int:
        """Number of time steps."""
        return len(self.times)

    def __repr__(self) -> str:
        parts = [f"EntropicResult(num_times={self.num_times}"]
        if self.entropy is not None:
            parts.append(f"entropy=[{self.entropy[0]:.4g}..{self.entropy[-1]:.4g}]")
        if self.tau_ent is not None:
            parts.append(f"tau_ent_final={self.tau_ent[-1]:.4g}")
        parts_str = ", ".join(parts) + ")"
        return parts_str
