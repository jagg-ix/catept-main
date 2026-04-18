"""Closure solver for SGI harness (GR-only).

Goal:
- adjust selected pulse durations (or a scale factor) to minimize final closure
  errors: dz_final and dv_final.

We keep this as a lightweight numerical tuning utility. It is NOT a physics claim;
it is a convenience tool to find pulse timings that close the loop in the baseline model.

No CAT/EPT equations implemented here.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Dict, Optional, Callable
import numpy as np

from .sgi_experiment_spec import SGIConfig, Pulse, InitialState
from .sgi_worldlines_gr import simulate_1d, simulate_1d_shaped, closure_metrics

@dataclass(frozen=True)
class ClosureTarget:
    dz_m: float = 0.0
    dv_m_per_s: float = 0.0

@dataclass
class SolveResult:
    pulses: List[Pulse]
    metrics: Dict[str, float]
    history: List[Dict[str, float]]

def _objective(metrics: Dict[str, float], w_dz: float, w_dv: float):
    return w_dz*(metrics["dz_final_m"]**2) + w_dv*(metrics["dv_final_m_per_s"]**2)

def solve_by_scaling_last_pulse(
    cfg: SGIConfig,
    init: InitialState,
    dt_s: float,
    *,
    shape: str = "none",
    ramp_frac: float = 0.15,
    w_dz: float = 1.0,
    w_dv: float = 1.0,
    scale_min: float = 0.2,
    scale_max: float = 5.0,
    n_grid: int = 81,
) -> SolveResult:
    """Simple 1-parameter solver: scale the final pulse duration."""
    pulses = list(cfg.pulses or [])
    if len(pulses) < 1:
        raise ValueError("Need at least one pulse")
    base_last = pulses[-1]

    history=[]
    best=None
    for s in np.linspace(scale_min, scale_max, n_grid):
        pulses2 = pulses[:-1] + [Pulse(base_last.gradient_T_per_m, base_last.duration_s*float(s), base_last.label)]
        cfg2 = SGIConfig(axis=cfg.axis, gravity_m_per_s2=cfg.gravity_m_per_s2, mu_eff_J_per_T=cfg.mu_eff_J_per_T, mass_kg=cfg.mass_kg, pulses=pulses2)
        wl = simulate_1d_shaped(cfg2, init, dt_s=dt_s, shape=shape, ramp_frac=ramp_frac)
        met = closure_metrics(wl)
        obj = _objective(met, w_dz, w_dv)
        history.append({"scale": float(s), "obj": float(obj), **met})
        if best is None or obj < best[0]:
            best = (obj, pulses2, met)

    assert best is not None
    return SolveResult(pulses=best[1], metrics=best[2], history=history)

def solve_by_two_pulse_durations(
    cfg: SGIConfig,
    init: InitialState,
    dt_s: float,
    *,
    shape: str = "none",
    ramp_frac: float = 0.15,
    idx_a: int = -2,
    idx_b: int = -1,
    w_dz: float = 1.0,
    w_dv: float = 1.0,
    scale_min: float = 0.2,
    scale_max: float = 5.0,
    n_grid: int = 31,
) -> SolveResult:
    """Coarse 2D grid search over two selected pulse duration scales."""
    pulses = list(cfg.pulses or [])
    n=len(pulses)
    ia = idx_a if idx_a>=0 else n+idx_a
    ib = idx_b if idx_b>=0 else n+idx_b
    if not (0 <= ia < n and 0 <= ib < n and ia != ib):
        raise ValueError("Invalid indices")

    base_a = pulses[ia]
    base_b = pulses[ib]

    history=[]
    best=None
    scales = np.linspace(scale_min, scale_max, n_grid)
    for sa in scales:
        for sb in scales:
            pulses2 = pulses.copy()
            pulses2[ia] = Pulse(base_a.gradient_T_per_m, base_a.duration_s*float(sa), base_a.label)
            pulses2[ib] = Pulse(base_b.gradient_T_per_m, base_b.duration_s*float(sb), base_b.label)
            cfg2 = SGIConfig(axis=cfg.axis, gravity_m_per_s2=cfg.gravity_m_per_s2, mu_eff_J_per_T=cfg.mu_eff_J_per_T, mass_kg=cfg.mass_kg, pulses=pulses2)
            wl = simulate_1d_shaped(cfg2, init, dt_s=dt_s, shape=shape, ramp_frac=ramp_frac)
            met = closure_metrics(wl)
            obj = _objective(met, w_dz, w_dv)
            history.append({"scale_a": float(sa), "scale_b": float(sb), "obj": float(obj), **met})
            if best is None or obj < best[0]:
                best = (obj, pulses2, met)

    assert best is not None
    return SolveResult(pulses=best[1], metrics=best[2], history=history)
