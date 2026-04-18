from __future__ import annotations

from dataclasses import dataclass
from typing import Optional

import numpy as np

from .types import OpticsRunResult


def _rect(x: np.ndarray, w: float) -> np.ndarray:
    return (np.abs(x) <= 0.5 * w).astype(float)


@dataclass
class NumpyFraunhoferEngine:
    """Reference Fraunhofer diffraction for a 1D rectangular aperture.

    This is intentionally simple and dependency-free. It provides a stable baseline
    for comparing optional third-party optics libraries.
    """

    name: str = "numpy"

    def run_rect_aperture(
        self,
        *,
        aperture_width_m: float,
        wavelength_m: float,
        z_m: float,
        n_x: int = 2048,
        x_span_m: Optional[float] = None,
    ) -> OpticsRunResult:
        if aperture_width_m <= 0 or wavelength_m <= 0 or z_m <= 0:
            raise ValueError("aperture_width_m, wavelength_m, z_m must be > 0")

        # Observation plane x-grid
        span = float(x_span_m) if x_span_m is not None else 50.0 * wavelength_m * z_m / aperture_width_m
        x = np.linspace(-0.5 * span, 0.5 * span, int(n_x), dtype=float)

        # Fraunhofer: field proportional to FT of aperture evaluated at spatial frequency fx = x/(lambda z)
        fx = x / (wavelength_m * z_m)
        # Continuous FT of rect is w*sinc(w*fx)
        E = aperture_width_m * np.sinc(aperture_width_m * fx)  # np.sinc uses sin(pi x)/(pi x)
        I = np.abs(E) ** 2
        meta = {
            "model": "fraunhofer_1d_rect",
            "aperture_width_m": float(aperture_width_m),
            "wavelength_m": float(wavelength_m),
            "z_m": float(z_m),
            "n_x": int(n_x),
            "x_span_m": float(span),
        }
        return OpticsRunResult(x_m=x, E=E.astype(complex), I=I.astype(float), meta=meta)
