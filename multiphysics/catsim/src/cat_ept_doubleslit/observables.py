"""Observable extraction utilities for the temporal double-slit experiment.

Phase 2 deliverable (see project roadmap): provide explicit, testable routines
to extract experimentally-relevant observables from spectra and time-domain
traces stored in the SQLite database produced by the XLSX->tidy->SQLite
pipeline.

These functions are intentionally lightweight and avoid optional dependencies
like SciPy. They are robust enough for automated gating/benchmarking and can be
refined later.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Optional, Tuple

import numpy as np


@dataclass(frozen=True)
class SpectralObservables:
    """Key observables extracted from a temporal double-slit spectrum."""

    slit_separation_fs: float
    fringe_spacing_THz: float
    visibility_paper: float
    visibility_robust: float
    asymmetry_fraction: float
    high_detuning_power_fraction: float
    band_THz: float
    carrier_THz: float


@dataclass(frozen=True)
class TimeDomainObservables:
    """Key observables extracted from a time-domain reflectivity trace."""

    slit_separation_fs: float
    rise_10_90_fs: float
    decay_tau_fs: float
    peak_delay_fs: float


def _sorted_xy(x: np.ndarray, y: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    idx = np.argsort(x)
    return x[idx], y[idx]


def _detrend_linear(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Remove best-fit line from y(x) to reduce envelope bias in fringe detection."""
    if x.size < 2:
        return y
    A = np.vstack([x, np.ones_like(x)]).T
    coef, *_ = np.linalg.lstsq(A, y, rcond=None)
    trend = A @ coef
    return y - trend


def extract_fringe_spacing_THz(
    detuning_THz: np.ndarray,
    intensity: np.ndarray,
    band_THz: float,
    min_spacing_THz: float = 0.1,
    max_spacing_THz: float = 20.0,
) -> float:
    """Estimate fringe spacing (THz) from a spectrum.

    Uses FFT on detrended, uniformly-resampled intensity in the chosen detuning
    band. Returns the dominant spacing in THz.
    """

    d, I = _sorted_xy(detuning_THz, intensity)
    mask = np.isfinite(d) & np.isfinite(I) & (np.abs(d) <= band_THz)
    d, I = d[mask], I[mask]
    if d.size < 16:
        return float("nan")

    # Uniform resample.
    n = int(max(256, 2 ** int(np.ceil(np.log2(d.size)))))
    d_u = np.linspace(d.min(), d.max(), n)
    I_u = np.interp(d_u, d, I)
    I_u = _detrend_linear(d_u, I_u)
    I_u = I_u - np.mean(I_u)

    # FFT: peaks correspond to oscillations in detuning domain.
    F = np.fft.rfft(I_u)
    P = np.abs(F) ** 2
    freqs = np.fft.rfftfreq(n, d=(d_u[1] - d_u[0]))  # cycles per THz

    # Convert spacing bounds to frequency bounds.
    fmin = 1.0 / max_spacing_THz
    fmax = 1.0 / max(min_spacing_THz, 1e-9)
    band_mask = (freqs >= fmin) & (freqs <= fmax)
    if not np.any(band_mask):
        return float("nan")

    k = np.argmax(P[band_mask])
    f0 = freqs[band_mask][k]
    if f0 <= 0:
        return float("nan")
    return float(1.0 / f0)


def _find_local_extrema(y: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Return indices of local maxima and minima using sign changes."""
    if y.size < 3:
        return np.array([], dtype=int), np.array([], dtype=int)
    dy = np.diff(y)
    s = np.sign(dy)
    # Replace zeros with nearest nonzero to avoid flat regions.
    for i in range(1, s.size):
        if s[i] == 0:
            s[i] = s[i - 1]
    ds = np.diff(s)
    max_idx = np.where(ds < 0)[0] + 1
    min_idx = np.where(ds > 0)[0] + 1
    return max_idx, min_idx


def extract_visibility_paper(
    detuning_THz: np.ndarray,
    intensity: np.ndarray,
    band_THz: float,
) -> float:
    """Paper-style visibility: median fringe contrast from local max/min pairs."""
    d, I = _sorted_xy(detuning_THz, intensity)
    mask = np.isfinite(d) & np.isfinite(I) & (np.abs(d) <= band_THz)
    d, I = d[mask], I[mask]
    if d.size < 16:
        return float("nan")

    # Smooth mildly by uniform resampling.
    n = int(max(256, 2 ** int(np.ceil(np.log2(d.size)))))
    d_u = np.linspace(d.min(), d.max(), n)
    I_u = np.interp(d_u, d, I)
    I_u = I_u - np.min(I_u)

    max_idx, min_idx = _find_local_extrema(I_u)
    if max_idx.size == 0 or min_idx.size == 0:
        return float("nan")

    # Pair extrema in order: for each maximum, find nearest minimum between it and next max.
    contrasts = []
    for i, m in enumerate(max_idx[:-1]):
        m2 = max_idx[i + 1]
        mins_between = min_idx[(min_idx > m) & (min_idx < m2)]
        if mins_between.size == 0:
            continue
        mn = mins_between[np.argmin(np.abs(mins_between - (m + m2) / 2))]
        Imax = float(I_u[m])
        Imin = float(I_u[mn])
        denom = Imax + Imin
        if denom <= 0:
            continue
        contrasts.append((Imax - Imin) / denom)
    if not contrasts:
        return float("nan")
    return float(np.median(contrasts))


def extract_visibility_robust(
    detuning_THz: np.ndarray,
    intensity: np.ndarray,
    band_THz: float,
    lo_q: float = 10.0,
    hi_q: float = 90.0,
) -> float:
    """Robust visibility proxy using percentile-based peak/trough."""
    d, I = _sorted_xy(detuning_THz, intensity)
    mask = np.isfinite(d) & np.isfinite(I) & (np.abs(d) <= band_THz)
    I = I[mask]
    if I.size < 16:
        return float("nan")
    Ihi = float(np.percentile(I, hi_q))
    Ilo = float(np.percentile(I, lo_q))
    denom = Ihi + Ilo
    if denom <= 0:
        return float("nan")
    return float((Ihi - Ilo) / denom)


def extract_asymmetry_fraction(
    detuning_THz: np.ndarray,
    intensity: np.ndarray,
    band_THz: float,
) -> float:
    """Asymmetry fraction: (blue-red)/(blue+red) within a detuning band.

    Negative => red side dominates.
    """
    d, I = _sorted_xy(detuning_THz, intensity)
    mask = np.isfinite(d) & np.isfinite(I) & (np.abs(d) <= band_THz)
    d, I = d[mask], I[mask]
    if d.size < 8:
        return float("nan")
    red = float(np.trapezoid(I[d < 0], d[d < 0])) if np.any(d < 0) else 0.0
    blue = float(np.trapezoid(I[d > 0], d[d > 0])) if np.any(d > 0) else 0.0
    denom = blue + red
    if denom <= 0:
        return float("nan")
    return float((blue - red) / denom)


def extract_high_detuning_power_fraction(
    detuning_THz: np.ndarray,
    intensity: np.ndarray,
    band_THz: float,
    threshold_THz: float = 8.0,
) -> float:
    """Fraction of power at |detuning| >= threshold within |detuning|<=band."""
    d, I = _sorted_xy(detuning_THz, intensity)
    mask = np.isfinite(d) & np.isfinite(I) & (np.abs(d) <= band_THz)
    d, I = d[mask], I[mask]
    if d.size < 8:
        return float("nan")
    # Integrate over the full band. When integrating over the tails we must not
    # use a single trapz() over ...
    tot = float(np.trapezoid(I, d))
    if tot <= 0:
        return float("nan")
    # Integrate tails separately to avoid trapezoid "bridging" across the gap.
    m_red = d <= -abs(threshold_THz)
    m_blue = d >= abs(threshold_THz)
    high = 0.0
    if np.any(m_red):
        high += float(np.trapezoid(I[m_red], d[m_red]))
    if np.any(m_blue):
        high += float(np.trapezoid(I[m_blue], d[m_blue]))
    return float(high / tot)


def extract_time_domain_rise_decay(
    delay_fs: np.ndarray,
    reflectivity: np.ndarray,
    smooth_window: int = 9,
) -> Tuple[float, float, float]:
    """Extract (rise_10_90_fs, decay_tau_fs, peak_delay_fs) from a trace."""
    t, r = _sorted_xy(delay_fs, reflectivity)
    mask = np.isfinite(t) & np.isfinite(r)
    t, r = t[mask], r[mask]
    if t.size < 20:
        return float("nan"), float("nan"), float("nan")

    # Smooth with moving average.
    w = int(max(3, smooth_window))
    if w % 2 == 0:
        w += 1
    kernel = np.ones(w) / w
    rs = np.convolve(r, kernel, mode="same")

    # Normalize between baseline and peak.
    peak_idx = int(np.argmax(rs))
    peak_t = float(t[peak_idx])
    baseline = float(np.percentile(rs[: max(5, peak_idx)], 10))
    peak = float(rs[peak_idx])
    amp = peak - baseline
    if amp <= 0:
        return float("nan"), float("nan"), peak_t
    y = (rs - baseline) / amp

    # Rise 10->90 prior to peak.
    pre = slice(0, peak_idx + 1)
    tpre = t[pre]
    ypre = y[pre]
    try:
        t10 = float(np.interp(0.1, ypre, tpre))
        t90 = float(np.interp(0.9, ypre, tpre))
        rise = max(0.0, t90 - t10)
    except Exception:
        rise = float("nan")

    # Exponential decay after peak: fit log(y) ~ -t/tau.
    post = slice(peak_idx, t.size)
    tpost = t[post] - t[peak_idx]
    ypost = y[post]
    m = (ypost > 0.05) & (tpost > 0)
    if np.count_nonzero(m) < 8:
        tau = float("nan")
    else:
        X = tpost[m]
        Y = np.log(ypost[m])
        A = np.vstack([X, np.ones_like(X)]).T
        slope, intercept = np.linalg.lstsq(A, Y, rcond=None)[0]
        tau = float(-1.0 / slope) if slope < 0 else float("nan")

    return float(rise), float(tau), peak_t


def build_spectral_observables(
    slit_separation_fs: float,
    frequency_THz: np.ndarray,
    intensity: np.ndarray,
    carrier_THz: float,
    band_THz: float = 10.0,
    high_detuning_threshold_THz: float = 8.0,
) -> SpectralObservables:
    detuning = frequency_THz - carrier_THz
    fringe = extract_fringe_spacing_THz(detuning, intensity, band_THz=band_THz)
    vis_p = extract_visibility_paper(detuning, intensity, band_THz=band_THz)
    vis_r = extract_visibility_robust(detuning, intensity, band_THz=band_THz)
    asym = extract_asymmetry_fraction(detuning, intensity, band_THz=band_THz)
    hi = extract_high_detuning_power_fraction(
        detuning, intensity, band_THz=band_THz, threshold_THz=high_detuning_threshold_THz
    )
    return SpectralObservables(
        slit_separation_fs=float(slit_separation_fs),
        fringe_spacing_THz=float(fringe),
        visibility_paper=float(vis_p),
        visibility_robust=float(vis_r),
        asymmetry_fraction=float(asym),
        high_detuning_power_fraction=float(hi),
        band_THz=float(band_THz),
        carrier_THz=float(carrier_THz),
    )


def build_time_domain_observables(
    slit_separation_fs: float,
    delay_fs: np.ndarray,
    reflectivity: np.ndarray,
) -> TimeDomainObservables:
    rise, tau, peak_t = extract_time_domain_rise_decay(delay_fs, reflectivity)
    return TimeDomainObservables(
        slit_separation_fs=float(slit_separation_fs),
        rise_10_90_fs=float(rise),
        decay_tau_fs=float(tau),
        peak_delay_fs=float(peak_t),
    )
