"""REBOUND integration (optional).

REBOUND is a high-performance N-body integrator. We treat it as a coordinate-time
solver and *annotate* the trajectory with entropic proper time (CAT/EPT):

    d tau_ent = lambda(t, state) dt.

Numerics note
-------------
Using tau_ent as the stepping variable does not remove stability constraints.
For REBOUND's symplectic integrators the dominant stability limit is typically set
by orbital timescales, not a PDE CFL condition. However, if you couple in a
CAT/EPT dissipation rate lambda, it's still useful to impose a conservative guard

    dt <= alpha_scheme / lambda_max

for explicit coupling terms, and to track tau_ent consistently.

This module provides an adapter that:
- runs a REBOUND simulation in coordinate time
- computes tau_ent alongside t
- optionally adds a simple dissipative acceleration proportional to velocity
  (a placeholder interface for imaginary-action / openness effects)
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Dict, List, Optional, Tuple

import numpy as np

from cat_ept_doubleslit.clock.entropic_clock import EntropicClock


def has_rebound() -> bool:
    try:  # pragma: no cover
        import rebound  # noqa: F401

        return True
    except Exception:
        return False


LambdaFn = Callable[[float, object | None], float]


@dataclass
class ReboundRunConfig:
    t0_s: float = 0.0
    t_end_s: float = 1.0
    dt_s: float = 1e-3
    max_steps: int = 2_000_000
    record_every: int = 1
    # Optional stability guard for lambda-coupled explicit terms
    alpha_scheme: float = 2.0
    # Optional: cap dt by dt <= alpha_scheme/lambda_max
    enforce_lambda_guard: bool = True


def _velocity_damping_forces(sim, gamma_s: float) -> None:
    """Add a simple velocity-proportional drag.

    This is intentionally conservative: it is not claimed to be a unique physical
    CAT/EPT force law. It's a placeholder hook for users who want to explore
    imaginary-action induced damping in classical dynamics.

    a_i = -gamma v_i
    """

    if gamma_s <= 0:
        return

    ps = sim.particles
    for i in range(1, sim.N):  # leave central mass untouched by default
        p = ps[i]
        p.ax += -gamma_s * p.vx
        p.ay += -gamma_s * p.vy
        p.az += -gamma_s * p.vz


def run_rebound_with_entropic_clock(
    sim,
    *,
    lambda_fn: LambdaFn,
    config: ReboundRunConfig,
    damping_gamma_fn: Optional[Callable[[float, object | None], float]] = None,
) -> Dict[str, np.ndarray]:
    """Run a REBOUND simulation and record t and tau_ent.

    Parameters
    ----------
    sim:
        A rebound.Simulation instance (already configured: particles, units, integrator).
    lambda_fn:
        lambda(t, state) >= 0 in 1/s.
    config:
        Run parameters.
    damping_gamma_fn:
        Optional gamma(t, state) used in a velocity-damping hook.

    Returns
    -------
    dict with keys:
        t_s, tau_ent, x, y, z, vx, vy, vz (arrays)

    Notes
    -----
    - REBOUND advances in coordinate time.
    - tau_ent is accumulated as tau += lambda(t)*dt.
    - If enforce_lambda_guard, dt is reduced when lambda is large.
    """

    if not has_rebound():
        raise RuntimeError("REBOUND not installed. Install with: pip install -e '.[rebound]'")

    clock = EntropicClock(lambda_fn=lambda_fn, lambda_floor=0.0)

    t = float(config.t0_s)
    tau = 0.0

    # Pre-allocate dynamic lists
    ts: List[float] = []
    taus: List[float] = []
    xs: List[float] = []
    ys: List[float] = []
    zs: List[float] = []
    vxs: List[float] = []
    vys: List[float] = []
    vzs: List[float] = []

    def record():
        ps = sim.particles
        # Record particle 1 (first non-central) by convention
        if sim.N < 2:
            raise ValueError("Simulation must have at least 2 particles")
        p = ps[1]
        ts.append(t)
        taus.append(tau)
        xs.append(p.x)
        ys.append(p.y)
        zs.append(p.z)
        vxs.append(p.vx)
        vys.append(p.vy)
        vzs.append(p.vz)

    # Set the initial sim time
    sim.t = t
    record()

    steps = 0
    while t < config.t_end_s:
        if steps >= config.max_steps:
            raise RuntimeError("Exceeded max_steps")

        dt = float(config.dt_s)

        # Conservative guard when lambda is large
        if config.enforce_lambda_guard:
            lam = clock.lambda_at(t)
            if lam > 0:
                dt = min(dt, config.alpha_scheme / lam)

        # Optional dissipative forces (velocity damping)
        if damping_gamma_fn is not None:
            gamma = float(damping_gamma_fn(t, None))
            sim.additional_forces = lambda rsim: _velocity_damping_forces(rsim, gamma)

        t_next = min(t + dt, config.t_end_s)
        sim.integrate(t_next)

        # Update t, tau
        dt_eff = t_next - t
        tau += clock.dtau_from_dt(t, dt_eff)
        t = t_next
        steps += 1

        if steps % config.record_every == 0 or t >= config.t_end_s:
            record()

    return {
        "t_s": np.asarray(ts, dtype=float),
        "tau_ent": np.asarray(taus, dtype=float),
        "x": np.asarray(xs, dtype=float),
        "y": np.asarray(ys, dtype=float),
        "z": np.asarray(zs, dtype=float),
        "vx": np.asarray(vxs, dtype=float),
        "vy": np.asarray(vys, dtype=float),
        "vz": np.asarray(vzs, dtype=float),
    }
