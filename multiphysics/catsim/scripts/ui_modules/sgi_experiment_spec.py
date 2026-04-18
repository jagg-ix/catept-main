"""SGI experiment spec (no CAT/EPT equations).

This module defines the *experiment harness* schema:
- pulse schedules (magnetic gradient vs time)
- initial conditions
- what artifacts a run should export

All extended physics (CAT/EPT or other) must be invoked via adapters in
`sgi_backend_bridge.py`. This file must remain purely declarative / structural.
"""

from __future__ import annotations
from dataclasses import dataclass, asdict
from typing import List, Literal, Optional, Dict, Any

Axis = Literal["x", "y", "z"]

@dataclass(frozen=True)
class Pulse:
    """A constant-gradient interval.

    gradient_T_per_m:
        dB/dz in Tesla per meter (signed).
    duration_s:
        interval duration.
    """
    gradient_T_per_m: float
    duration_s: float
    label: str = ""

@dataclass(frozen=True)
class SGIConfig:
    """Minimal SGI configuration.

    We model 1D motion along `axis` (default z). The spin-dependent force is
    applied as +/- mu_eff * gradient, where mu_eff is an effective magnetic
    moment supplied by the user/config.

    gravity_m_per_s2:
        constant acceleration along +axis (z) direction. For typical lab
        vertical axis, set +9.80665 and orient coordinates accordingly.
    """
    axis: Axis = "z"
    gravity_m_per_s2: float = 9.80665
    mu_eff_J_per_T: float = 9.2740100783e-24  # Bohr magneton default
    mass_kg: float = 1.0e-26  # placeholder; user sets for atom/electron effective mass
    pulses: List[Pulse] = None

@dataclass(frozen=True)
class InitialState:
    z0_m: float = 0.0
    v0_m_per_s: float = 0.0

@dataclass(frozen=True)
class RunRequest:
    config: SGIConfig
    init: InitialState
    dt_s: float = 1e-6
    t0_s: float = 0.0
    tag: str = "sgi_run"

def to_jsonable(obj: Any) -> Dict[str, Any]:
    if hasattr(obj, "__dataclass_fields__"):
        d = asdict(obj)
        return d
    raise TypeError(f"Unsupported type: {type(obj)}")


# -------- Templates (experiment convenience) --------

def template_split_mirror_recombine(
    grad_T_per_m: float,
    t_split_s: float,
    t_mirror_s: float,
    t_recombine_s: float,
    *,
    sign_pattern: str = "+-+",
) -> List[Pulse]:
    """Classic 3-pulse SGI template: split, mirror, recombine.

    sign_pattern default '+-+':
      +grad for split, -grad for mirror, +grad for recombine

    This is a convenient harness template; the actual experiment may use
    more segments and shaped pulses.
    """
    if len(sign_pattern) != 3 or any(c not in "+-" for c in sign_pattern):
        raise ValueError("sign_pattern must be length-3 over '+-'")
    s = [1.0 if c == "+" else -1.0 for c in sign_pattern]
    return [
        Pulse(gradient_T_per_m=s[0]*grad_T_per_m, duration_s=t_split_s, label="split"),
        Pulse(gradient_T_per_m=s[1]*grad_T_per_m, duration_s=t_mirror_s, label="mirror"),
        Pulse(gradient_T_per_m=s[2]*grad_T_per_m, duration_s=t_recombine_s, label="recombine"),
    ]


def template_four_pulse_close(
    grad_T_per_m: float,
    t1_s: float,
    t2_s: float,
    t3_s: float,
    t4_s: float,
    *,
    signs: str = "+--+",
) -> List[Pulse]:
    """4-pulse template often used to help closure tuning.

    signs default '+--+' (user-adjustable).
    """
    if len(signs) != 4 or any(c not in "+-" for c in signs):
        raise ValueError("signs must be length-4 over '+-'")
    s = [1.0 if c == "+" else -1.0 for c in signs]
    return [
        Pulse(gradient_T_per_m=s[0]*grad_T_per_m, duration_s=t1_s, label="p1"),
        Pulse(gradient_T_per_m=s[1]*grad_T_per_m, duration_s=t2_s, label="p2"),
        Pulse(gradient_T_per_m=s[2]*grad_T_per_m, duration_s=t3_s, label="p3"),
        Pulse(gradient_T_per_m=s[3]*grad_T_per_m, duration_s=t4_s, label="p4"),
    ]


def pulses_from_string(pulses: str) -> List[Pulse]:
    """Parse 'g:d,g:d,...' into Pulse list."""
    out=[]
    for item in pulses.split(","):
        item=item.strip()
        if not item:
            continue
        g_s, d_s = item.split(":")
        out.append(Pulse(gradient_T_per_m=float(g_s), duration_s=float(d_s), label=item))
    return out


def pulses_to_string(pulses: List[Pulse]) -> str:
    return ",".join([f"{p.gradient_T_per_m}:{p.duration_s}" for p in pulses])

