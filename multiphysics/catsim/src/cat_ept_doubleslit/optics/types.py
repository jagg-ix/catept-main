from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Optional, Protocol

import numpy as np


@dataclass
class OpticsRunResult:
    x_m: np.ndarray
    E: np.ndarray
    I: np.ndarray
    meta: Dict[str, Any]


class OpticsEngine(Protocol):
    """Minimal optics engine interface."""

    name: str

    def run_rect_aperture(
        self,
        *,
        aperture_width_m: float,
        wavelength_m: float,
        z_m: float,
        n_x: int = 2048,
        x_span_m: Optional[float] = None,
    ) -> OpticsRunResult:
        ...
