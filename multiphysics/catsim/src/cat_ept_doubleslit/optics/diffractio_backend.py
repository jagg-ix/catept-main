from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import numpy as np

from .types import OpticsRunResult


def check_available() -> bool:
    try:
        import diffractio  # noqa: F401
        return True
    except Exception:
        return False


@dataclass
class DiffractioEngine:
    """Optional backend wrapper for diffractio.

    This adapter intentionally implements only a small, portable surface area.
    If the dependency is missing, construction will raise ImportError; callers should
    use the registry which handles availability.
    """

    name: str = "diffractio"

    def __post_init__(self) -> None:
        if not check_available():
            raise ImportError("diffractio is not available")

    def run_rect_aperture(
        self,
        *,
        aperture_width_m: float,
        wavelength_m: float,
        z_m: float,
        n_x: int = 2048,
        x_span_m: Optional[float] = None,
    ) -> OpticsRunResult:
        # Fallback: for now, use a numerically identical reference model.
        # Future iterations can replace this with native calls while keeping the contract stable.
        from .numpy_backend import NumpyFraunhoferEngine

        ref = NumpyFraunhoferEngine()
        out = ref.run_rect_aperture(
            aperture_width_m=aperture_width_m,
            wavelength_m=wavelength_m,
            z_m=z_m,
            n_x=n_x,
            x_span_m=x_span_m,
        )
        out.meta["backend"] = "diffractio"
        out.meta["note"] = "native integration TODO; using reference model"
        return out
