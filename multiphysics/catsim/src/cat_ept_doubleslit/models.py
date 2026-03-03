"""Double-slit interference model (Fraunhofer regime) with optional decoherence.

Model summary:
- Angle: theta(x) = arctan(x / L)
- Single-slit envelope: sinc^2( pi a sin(theta) / lambda )
- Interference phase: delta(x) = 2 pi d sin(theta) / lambda
- Visibility factor V multiplies the cosine term.

Intensity (normalized):
  I(x) = envelope(x) * (1 + V * cos(delta(x))) / 2

Decoherence choices:
- standard: V = V0 * exp(-gamma * T / 2)
- entropic: V = V0 * exp(-tau_ent / 2) with tau_ent = lambda_ent * T

This matches the paper-style form V = V0 exp(-lambda T / 2) if you identify tau_ent = lambda T.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Literal, Optional, Tuple

import numpy as np

from .constants import C_LIGHT
from .entropic_time import tau_entropic


Mode = Literal["standard", "entropic"]


def default_flight_time(screen_dist_m: float) -> float:
    """Conservative photon time-of-flight estimate: T ~ L/c."""
    if screen_dist_m <= 0:
        raise ValueError("screen_dist_m must be > 0")
    return float(screen_dist_m / C_LIGHT)


def _sinc(x: np.ndarray) -> np.ndarray:
    # np.sinc is sin(pi x)/(pi x). We want sin(x)/x.
    out = np.ones_like(x, dtype=float)
    mask = x != 0
    out[mask] = np.sin(x[mask]) / x[mask]
    return out


def visibility_factor(
    V0: float,
    T: float,
    mode: Mode,
    gamma_s_inv: float = 0.0,
    lambda_ent_s_inv: float = 0.0,
) -> float:
    """Compute visibility factor V.

    Parameters are validated to avoid unphysical values.
    """
    if not (0.0 <= V0 <= 1.0):
        raise ValueError("V0 must be in [0, 1]")
    if T < 0:
        raise ValueError("T must be non-negative")

    if mode == "standard":
        if gamma_s_inv < 0:
            raise ValueError("gamma_s_inv must be non-negative")
        return float(V0 * np.exp(-gamma_s_inv * T / 2.0))

    if mode == "entropic":
        if lambda_ent_s_inv < 0:
            raise ValueError("lambda_ent_s_inv must be non-negative")
        tau = tau_entropic(T=T, lambda_ent=lambda_ent_s_inv)
        return float(V0 * np.exp(-tau / 2.0))

    raise ValueError(f"Unknown mode: {mode}")


def double_slit_intensity(
    x_m: np.ndarray,
    wavelength_m: float,
    slit_sep_m: float,
    slit_width_m: float,
    screen_dist_m: float,
    visibility0: float = 1.0,
    mode: Mode = "standard",
    flight_time_s: Optional[float] = None,
    gamma_s_inv: float = 0.0,
    lambda_ent_s_inv: float = 0.0,
) -> Tuple[np.ndarray, float]:
    """Compute normalized intensity pattern I(x) and visibility used.

    Returns
    -------
    (I, V)
    """
    x = np.asarray(x_m, dtype=float)

    if wavelength_m <= 0:
        raise ValueError("wavelength_m must be > 0")
    if slit_sep_m <= 0:
        raise ValueError("slit_sep_m must be > 0")
    if slit_width_m <= 0:
        raise ValueError("slit_width_m must be > 0")
    if screen_dist_m <= 0:
        raise ValueError("screen_dist_m must be > 0")

    T = default_flight_time(screen_dist_m) if flight_time_s is None else float(flight_time_s)

    theta = np.arctan2(x, screen_dist_m)
    s = np.sin(theta)

    beta = np.pi * slit_width_m * s / wavelength_m
    envelope = _sinc(beta) ** 2

    delta = 2.0 * np.pi * slit_sep_m * s / wavelength_m

    V = visibility_factor(
        V0=float(visibility0),
        T=T,
        mode=mode,
        gamma_s_inv=float(gamma_s_inv),
        lambda_ent_s_inv=float(lambda_ent_s_inv),
    )

    I = envelope * (1.0 + V * np.cos(delta)) / 2.0
    # numerical safety
    I = np.clip(I, 0.0, None)

    return I, V


# ---------------------------
# Temporal double-slit model
# ---------------------------

def temporal_double_slit_spectrum(
    f_hz: np.ndarray,
    separation_s: float,
    slit_rise_s: float,
    visibility0: float = 1.0,
    mode: Literal["standard", "entropic"] = "standard",
    gamma_s_inv: float | None = None,
    lambda_ent_s_inv: float | None = None,
    *,
    lambda0_s_inv: float = 1.0e15,
) -> tuple[np.ndarray, float]:
    """Temporal double-slit (time diffraction): spectrum intensity vs frequency.

    Model: two identical Gaussian time windows ("time slits") separated by Δt.

        g(t) = exp(-t^2/(2σ^2)) + exp(-(t-Δt)^2/(2σ^2)),  σ = slit_rise_s

    Analytic Fourier transform yields:
        |G(ω)|^2 ∝ exp(-σ^2 ω^2) * [2 + 2 V cos(ω Δt)]

    where V is a coherence/visibility factor. This captures the two key statements in
    Tirole et al. (Nature Physics 2023):
      - the separation Δt sets the oscillation period in the spectrum
      - the decay of fringe visibility encodes the "shape" (here Gaussian width σ)

    Returns (spectrum, V_effective).
    """
    f_hz = np.asarray(f_hz, dtype=float)
    if separation_s <= 0:
        raise ValueError("separation_s must be > 0")
    if slit_rise_s <= 0:
        raise ValueError("slit_rise_s must be > 0")

    omega = 2.0 * np.pi * f_hz
    # Envelope from Gaussian slit (|W(ω)|^2)
    envelope = np.exp(-(slit_rise_s ** 2) * (omega ** 2))

    # Effective visibility factor
    if mode == "standard":
        if gamma_s_inv is None:
            gamma_s_inv = 0.0
        V = float(visibility0) * float(np.exp(-gamma_s_inv * separation_s / 2.0))
    elif mode == "entropic":
        if lambda_ent_s_inv is None:
            lambda_ent_s_inv = 0.0
        # CAT/EPT hook:
        # We keep the same monotone damping ansatz (set by the imaginary action weight),
        # but reparameterize the *phase* using an entropic proper-time factor.
        #
        # A minimal, numerically-stable choice is a bounded "openness" factor
        #   g(λ) = 1 / (1 + λ/λ0)
        # which is consistent with the idea that strong entropy-production slows
        # coherent phase accumulation relative to coordinate time.
        #
        # λ0 is a reference rate (can be tied to CFL-style step constraints elsewhere).
        V = float(visibility0) * float(np.exp(-lambda_ent_s_inv * separation_s / 2.0))
        g = 1.0 / (1.0 + float(lambda_ent_s_inv) / float(lambda0_s_inv))
        separation_s = float(separation_s) * float(g)
    else:
        raise ValueError("mode must be 'standard' or 'entropic'")

    spectrum = envelope * (1.0 + V * np.cos(omega * separation_s))
    spectrum = np.clip(spectrum, 0.0, None)
    return spectrum, V
