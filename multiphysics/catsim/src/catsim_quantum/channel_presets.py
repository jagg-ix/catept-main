"""Quantum channel preset registry (dephasing rates etc)."""
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Optional

@dataclass(frozen=True)
class ChannelPreset:
    name: str
    gamma_phi_s_inv: float
    description: str

_PRESETS: Dict[str, ChannelPreset] = {
    "off": ChannelPreset("off", 0.0, "No dephasing (unitary)."),
    "demo_low": ChannelPreset("demo_low", 1e-3, "Very small dephasing (1e-3 s^-1)."),
    "demo_med": ChannelPreset("demo_med", 1.0, "Moderate dephasing (1 s^-1)."),
    "demo_high": ChannelPreset("demo_high", 1e3, "Large dephasing (1e3 s^-1)."),
}

def list_presets() -> Dict[str, ChannelPreset]:
    return dict(_PRESETS)

def get_preset(name: str) -> Optional[ChannelPreset]:
    return _PRESETS.get(str(name).lower().strip())

def resolve_gamma_phi(*, gamma_phi: float | None, channel_preset: str | None) -> float:
    if gamma_phi is not None:
        return float(gamma_phi)
    if channel_preset:
        p = get_preset(channel_preset)
        if p:
            return float(p.gamma_phi_s_inv)
    return 0.0
