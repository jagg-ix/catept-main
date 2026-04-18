"""GR/SR baseline worldline generator for SGI (no CAT/EPT equations).

Scope:
- 1D classical trajectories for two arms (spin up / spin down) in a prescribed
  magnetic gradient pulse schedule.
- Constant gravity.
- Outputs trajectories suitable for phase/visibility backends.

No CAT/EPT math is implemented here.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Tuple
import numpy as np

from .sgi_experiment_spec import SGIConfig, InitialState

c0 = 299792458.0

@dataclass(frozen=True)
class Worldline:
    t_s: np.ndarray
    z_m: np.ndarray
    v_m_per_s: np.ndarray
    a_m_per_s2: np.ndarray

def _build_pulse_table(cfg: SGIConfig):
    pulses = cfg.pulses or []
    # returns list of (t_start, t_end, grad)
    out=[]
    t=0.0
    for p in pulses:
        out.append((t, t+float(p.duration_s), float(p.gradient_T_per_m), p.label))
        t += float(p.duration_s)
    return out, t

def simulate_1d(cfg: SGIConfig, init: InitialState, dt_s: float) -> Dict[str, Worldline]:
    """Simulate two arms under +/- mu_eff*grad/m + gravity.

    We integrate using simple velocity-Verlet. This is adequate for the harness
    and keeps dependencies minimal.
    """
    dt = float(dt_s)
    if dt <= 0:
        raise ValueError("dt_s must be > 0")

    pulse_table, T = _build_pulse_table(cfg)
    n = int(np.ceil(T/dt)) + 1
    t = np.linspace(0.0, T, n)

    def grad_at(time_s: float) -> float:
        for t0, t1, g, _ in pulse_table:
            if t0 <= time_s < t1:
                return g
        return 0.0

    def run(sign: float) -> Worldline:
        z = np.zeros(n); v = np.zeros(n); a = np.zeros(n)
        z[0] = float(init.z0_m); v[0] = float(init.v0_m_per_s)

        # initial accel
        g = grad_at(t[0])
        a[0] = (-cfg.gravity_m_per_s2) + (sign * cfg.mu_eff_J_per_T * g / cfg.mass_kg)

        for i in range(1, n):
            # position update
            z[i] = z[i-1] + v[i-1]*dt + 0.5*a[i-1]*dt*dt

            # compute new accel
            g_i = grad_at(t[i])
            a_i = (-cfg.gravity_m_per_s2) + (sign * cfg.mu_eff_J_per_T * g_i / cfg.mass_kg)

            # velocity update
            v[i] = v[i-1] + 0.5*(a[i-1] + a_i)*dt
            a[i] = a_i

        return Worldline(t_s=t, z_m=z, v_m_per_s=v, a_m_per_s2=a)

    return {
        "arm_plus": run(+1.0),
        "arm_minus": run(-1.0),
    }

def closure_metrics(worldlines: Dict[str, Worldline]) -> Dict[str, float]:
    """How well do the arms close at the final time? (position & velocity)"""
    a = worldlines["arm_plus"]
    b = worldlines["arm_minus"]
    dz = float(a.z_m[-1] - b.z_m[-1])
    dv = float(a.v_m_per_s[-1] - b.v_m_per_s[-1])
    return {"dz_final_m": dz, "dv_final_m_per_s": dv}


def simulate_1d_shaped(cfg: SGIConfig, init: InitialState, dt_s: float, *, shape: str = "none", ramp_frac: float = 0.15) -> Dict[str, Worldline]:
    """Simulate with shaped gradient edges.

    shape:
      - 'none' : piecewise-constant gradients (default)
      - 'tanh' : smooth ramps at pulse boundaries using tanh transitions

    ramp_frac:
      fraction of each pulse duration used for each ramp edge (clamped).
    """
    dt = float(dt_s)
    pulse_table, T = _build_pulse_table(cfg)
    n = int(np.ceil(T/dt)) + 1
    t = np.linspace(0.0, T, n)

    if shape == "none":
        return simulate_1d(cfg, init, dt_s=dt_s)

    if shape != "tanh":
        raise ValueError(f"unknown shape {shape}")

    # Build a continuous gradient function with tanh ramps
    def grad_at(time_s: float) -> float:
        g_total = 0.0
        for t0, t1, g, _lbl in pulse_table:
            dur = max(1e-12, (t1 - t0))
            rf = float(np.clip(ramp_frac, 0.01, 0.49))
            tr = rf * dur
            # smooth window ~1 inside [t0,t1], 0 outside
            # w = 0.5*(tanh((t-t0)/tr) - tanh((t-t1)/tr))
            w = 0.5*(np.tanh((time_s - t0)/tr) - np.tanh((time_s - t1)/tr))
            g_total += g * w
        return float(g_total)

    def run(sign: float) -> Worldline:
        z = np.zeros(n); v = np.zeros(n); a = np.zeros(n)
        z[0] = float(init.z0_m); v[0] = float(init.v0_m_per_s)
        g0 = grad_at(t[0])
        a[0] = (-cfg.gravity_m_per_s2) + (sign * cfg.mu_eff_J_per_T * g0 / cfg.mass_kg)
        for i in range(1, n):
            z[i] = z[i-1] + v[i-1]*dt + 0.5*a[i-1]*dt*dt
            gi = grad_at(t[i])
            ai = (-cfg.gravity_m_per_s2) + (sign * cfg.mu_eff_J_per_T * gi / cfg.mass_kg)
            v[i] = v[i-1] + 0.5*(a[i-1] + ai)*dt
            a[i] = ai
        return Worldline(t_s=t, z_m=z, v_m_per_s=v, a_m_per_s2=a)

    return {"arm_plus": run(+1.0), "arm_minus": run(-1.0)}
