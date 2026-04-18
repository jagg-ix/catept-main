"""Thermodynamic bath models for dephasing scaling.

Model:
  gamma_eff = gamma_base * (rho / rho_ref)**alpha

This module is intentionally simple; it provides reproducible scaling knobs rather than
deriving new physical equations in the harness.
"""
from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, Optional

@dataclass(frozen=True)
class BathPreset:
    name: str
    density_kg_m3: float
    description: str

_PRESETS: Dict[str, BathPreset] = {
    "vacuum": BathPreset("vacuum", 1e-9, "Ultra-high vacuum (illustrative)."),
    "air": BathPreset("air", 1.225, "Air at STP (approx)."),
    "helium": BathPreset("helium", 0.1786, "Helium at STP (approx)."),
    "nitrogen": BathPreset("nitrogen", 1.2506, "Nitrogen at STP (approx)."),
    "ultracold_gas": BathPreset("ultracold_gas", 1e-12, "Dilute ultracold gas (illustrative)."),
    "solid": BathPreset("solid", 1000.0, "Generic condensed matter density (order-of-mag)."),
}

def list_presets() -> Dict[str, BathPreset]:
    return dict(_PRESETS)

def get_preset(name: str) -> Optional[BathPreset]:
    return _PRESETS.get(str(name).lower().strip())

def scale_gamma(*, gamma_base: float, rho: float, rho_ref: float = 1.225, alpha: float = 1.0) -> float:
    if rho_ref <= 0:
        return float(gamma_base)
    rho = max(float(rho), 0.0)
    return float(gamma_base * (rho / float(rho_ref)) ** float(alpha))
