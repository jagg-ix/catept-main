from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Callable, Dict, Optional, Tuple, Literal

from ..metrics.redshift import MetricField

import numpy as np


def _fwhm_to_sigma(fwhm_s: float) -> float:
    """Convert amplitude-envelope FWHM to Gaussian sigma."""
    return fwhm_s / (2.0 * np.sqrt(2.0 * np.log(2.0)))


def gaussian_field_envelope(t_s: np.ndarray, fwhm_s: float) -> np.ndarray:
    """Gaussian *field amplitude* envelope (not intensity)."""
    sigma = _fwhm_to_sigma(float(fwhm_s))
    return np.exp(-0.5 * (t_s / sigma) ** 2)


def probe_field(t_s: np.ndarray, f0_hz: float, fwhm_field_s: float, t0_s: float = 0.0) -> np.ndarray:
    """Complex probe field: Gaussian envelope times analytic carrier.

    Use the standard positive-frequency convention exp(+i 2π f0 t) so that
    "blue" (positive detuning) and "red" (negative detuning) map consistently
    when analyzing the one-sided spectrum.
    """
    env = gaussian_field_envelope(t_s - float(t0_s), fwhm_field_s)
    return env * np.exp(1j * 2.0 * np.pi * float(f0_hz) * (t_s - float(t0_s)))


def f_ss(t_s: np.ndarray, alpha_inv_s: float, beta_inv_s: float) -> np.ndarray:
    r"""Single-slit aperture model used in the paper's supplement.

    The supplement models a single slit as

        f_ss(t) = 1/(1 + e^{-α t}) * 1/(1 + e^{β t}),  with α>0, β>0.

    α sets the leading-edge rise; β sets the trailing-edge decay.
    """
    a = float(alpha_inv_s)
    b = float(beta_inv_s)
    # Numerically-stable logistic factors.
    # Large |a t| and |b t| can overflow exp(); clamp arguments.
    x1 = np.clip(-a * t_s, -700.0, 700.0)
    x2 = np.clip(b * t_s, -700.0, 700.0)
    return (1.0 / (1.0 + np.exp(x1))) * (1.0 / (1.0 + np.exp(x2)))


def double_slit_reflection(
    t_s: np.ndarray,
    separation_s: float,
    alpha_inv_s: float,
    beta_inv_s: float,
    A: float,
    B: float,
    C: float,
) -> np.ndarray:
    """Amplitude reflection coefficient r(t) for a double time slit."""
    S = float(separation_s)
    return A * f_ss(t_s - S / 2.0, alpha_inv_s, beta_inv_s) + B * f_ss(t_s + S / 2.0, alpha_inv_s, beta_inv_s) + C


def apply_phase_evolution(r_amp: np.ndarray, phase_fn: Optional[Callable[[np.ndarray], np.ndarray]], t_s: np.ndarray) -> np.ndarray:
    """Optionally turn amplitude reflection into complex r(t)=|r(t)| exp(i φ(t))."""
    if phase_fn is None:
        return r_amp.astype(complex)
    phi = phase_fn(t_s)
    return r_amp.astype(complex) * np.exp(1j * phi)


def phase_poly(t_s: np.ndarray, phi0: float = 0.0, phi1_rad_per_s: float = 0.0, phi2_rad_per_s2: float = 0.0) -> np.ndarray:
    """A minimal, conservative phase model.

    This is intended to capture *time refraction*-style spectral asymmetry with the smallest
    number of degrees of freedom:

        φ(t) = φ0 + φ1 t + 1/2 φ2 t^2.

    Notes:
    - φ1 acts like a carrier-frequency shift.
    - φ2 acts like a chirp.
    """
    t = t_s.astype(float)
    return float(phi0) + float(phi1_rad_per_s) * t + 0.5 * float(phi2_rad_per_s2) * t * t


def phase_tanh_step(
    t_s: np.ndarray,
    phi0: float = 0.0,
    dphi: float = 0.0,
    t_center_s: float = 0.0,
    width_s: float = 100e-15,
) -> np.ndarray:
    """Smooth phase step: φ(t)=φ0 + (dφ/2)(1+tanh((t-t0)/w)).

    Useful when you want a bounded, monotone phase change during the pump-induced modulation.
    """
    w = max(float(width_s), 1e-30)
    return float(phi0) + 0.5 * float(dphi) * (1.0 + np.tanh((t_s - float(t_center_s)) / w))


def fft_spectrum(t_s: np.ndarray, field_t: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Return (freq_hz, |F|^2) using an FFT with proper frequency axis."""
    dt = float(t_s[1] - t_s[0])
    # Use fftshift so zero frequency is centered.
    F = np.fft.fftshift(np.fft.fft(np.fft.ifftshift(field_t))) * dt
    f = np.fft.fftshift(np.fft.fftfreq(len(t_s), d=dt))
    return f, np.abs(F) ** 2


def fft_field(t_s: np.ndarray, field_t: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Return (freq_hz, F) where F is the complex Fourier amplitude.

    This is used when we need to compose intensity from coherent and
    partially-coherent contributions in frequency space.
    """
    dt = float(t_s[1] - t_s[0])
    F = np.fft.fftshift(np.fft.fft(np.fft.ifftshift(field_t))) * dt
    f = np.fft.fftshift(np.fft.fftfreq(len(t_s), d=dt))
    return f, F


def bandpass_normalize(freq_hz: np.ndarray, intensity: np.ndarray, f_center_hz: float, half_width_hz: float) -> Tuple[np.ndarray, np.ndarray]:
    """Extract a frequency band around f_center and normalize by max in-band."""
    f = np.asarray(freq_hz)
    I = np.asarray(intensity)
    mask = (f >= float(f_center_hz) - float(half_width_hz)) & (f <= float(f_center_hz) + float(half_width_hz))
    if not np.any(mask):
        return f.copy(), (I / (np.max(I) + 1e-300)).copy()
    fb = f[mask]
    Ib = I[mask]
    Ib = Ib / (np.max(Ib) + 1e-300)
    return fb, Ib


def _cumtrapz(y: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Cumulative trapezoid integral with y[0] integrated to 0."""
    dx = np.diff(x)
    out = np.zeros_like(y, dtype=float)
    out[1:] = np.cumsum(0.5 * (y[1:] + y[:-1]) * dx)
    return out


@dataclass
class TimeDoubleSlitConfig:
    # Probe
    f0_hz: float = 230.2e12
    probe_fwhm_field_s: float = 794e-15  # field envelope FWHM
    probe_t0_s: float = 0.0

    # Slits
    separation_s: float = 800e-15
    alpha_inv_s: float = 0.5e15  # 1/(2 fs)
    beta_inv_s: float = (1.0 / 400e-15)  # 1/(400 fs)
    A: float = 0.5
    B: float = 0.5
    C: float = 0.0

    # Window and discretization
    t_window_s: float = 6e-12  # total window length
    dt_s: float = 0.2e-15      # time resolution

    # Optional: phase model for time refraction (paper notes this drives asymmetry)
    phase_fn: Optional[Callable[[np.ndarray], np.ndarray]] = None

    # Optional GR hook: use sqrt(-g00) to redshift entropic rates (paper: sqrt(-g00)).
    # If None, treated as Minkowski (factor 1).
    metric: Optional[MetricField] = None
    metric_x_vec_m: Tuple[float, float, float] = (0.0, 0.0, 0.0)

    # CAT/EPT toggles
    use_cat_ept: bool = False
    # How CAT/EPT enters the observable.
    # - "coherence": apply entropic decoherence ONLY to the two-slit cross term
    #   I = |F1|^2 + |F2|^2 + 2 g(S) Re(F1 F2*) + background terms
    #   with g(S)=exp(-lambda_ent * S). This matches the paper-style visibility factorization.
    # - "amplitude": apply a complex-action amplitude weight exp(-gamma * tau_ent(t)) to the
    #   full outgoing field. Useful as a software-stable alternative, but not the default
    #   for paper-facing comparisons.
    cat_mode: Literal["coherence", "amplitude"] = "coherence"

    lambda0_inv_s: float = 0.0
    lambda_kappa: float = 0.0
    lambda_floor_inv_s: float = 0.0
    # Constant entropic rate used for g(S)=exp(-lambda_ent * S).
    # If <=0, inferred conservatively from lambda(t) statistics.
    lambda_ent_inv_s: float = 0.0
    # Optional extra damping strength for amplitude-mode.
    gamma_entropic: float = 0.0

    # Optional: allow deriving slit edges from observed time-domain rise/decay.
    # If alpha_inv_s or beta_inv_s are set <= 0, these can be used to infer them.
    rise_10_90_s: float = 0.0
    decay_tau_s: float = 0.0


def alpha_from_rise_10_90(rise_s: float) -> float:
    """Approximate α from a 10–90% rise time for a logistic edge.

    For logistic L(t)=1/(1+exp(-α t)), the 10–90% transition width is
      Δt_10-90 ≈ 2 ln(9)/α ≈ 4.394/α.
    """
    r = float(rise_s)
    if r <= 0:
        raise ValueError("rise_s must be > 0")
    return 2.0 * np.log(9.0) / r


def beta_from_decay_tau(decay_s: float) -> float:
    """Conservative mapping from decay time constant to β.

    The paper's f_ss trailing edge uses a logistic-like factor 1/(1+exp(β t)).
    We map a characteristic decay time τ to β ≈ 1/τ.
    """
    d = float(decay_s)
    if d <= 0:
        raise ValueError("decay_s must be > 0")
    return 1.0 / d


def infer_lambda_entropic(lam_t: np.ndarray, lam0: float) -> float:
    """Infer a conservative constant λ_ent from a time-localized λ(t).

    Rationale:
    - We want a single λ_ent that drives g(S)=exp(-λ_ent S) (paper-style).
    - λ(t) is a software proxy computed from reflection dynamics; it may have outliers.
    - We therefore use a robust statistic (median) and enforce a CFL-style bound.

    Returns a nonnegative float.
    """
    lam0 = float(lam0)
    if lam_t is None:
        return max(lam0, 0.0)
    x = np.asarray(lam_t, dtype=float)
    x = x[np.isfinite(x)]
    if x.size == 0:
        return max(lam0, 0.0)
    est = float(np.median(x))
    est = max(est, 0.0)
    if lam0 > 0:
        est = min(est, lam0)
    return est


def compute_lambda_from_reflection(t_s: np.ndarray, r_t: np.ndarray, lambda0: float, kappa: float, floor: float) -> np.ndarray:
    """A conservative, software-friendly λ(t) proxy.

    The experiment paper's baseline diffraction model does not introduce λ(t). For
    "CAT/EPT-on" comparisons we need a *toggleable* λ(t) that is:

    * nonnegative,
    * localized near the modulation (where the system is driven far from equilibrium),
    * stable numerically.

    We use |d/dt log(1 + |r(t)|)| as a bounded proxy for a 'rate' tied to the slit edges.
    """
    dt = float(t_s[1] - t_s[0])
    mag = np.abs(r_t)
    proxy = np.abs(np.gradient(np.log1p(mag), dt))
    lam = float(lambda0) + float(kappa) * proxy
    lam = np.maximum(lam, float(floor))
    return lam


def simulate_time_double_slit(cfg: TimeDoubleSlitConfig) -> dict:
    """Run the time-double-slit spectral diffraction model.

    Returns a dict with time arrays, reflection coefficient, λ(t) (if enabled), and spectrum.
    """
    N = int(np.round(cfg.t_window_s / cfg.dt_s))
    if N % 2 == 1:
        N += 1
    t = (np.arange(N) - N / 2) * float(cfg.dt_s)

    # Optional: infer slit-edge rates from measured rise/decay if requested.
    alpha = float(cfg.alpha_inv_s)
    beta = float(cfg.beta_inv_s)
    if alpha <= 0.0 and float(cfg.rise_10_90_s) > 0.0:
        alpha = float(alpha_from_rise_10_90(cfg.rise_10_90_s))
    if beta <= 0.0 and float(cfg.decay_tau_s) > 0.0:
        beta = float(beta_from_decay_tau(cfg.decay_tau_s))

    # Build components explicitly so we can apply CAT/EPT decoherence to the
    # two-slit cross term only (paper-facing mode).
    r1_amp = float(cfg.A) * f_ss(t - float(cfg.separation_s) / 2.0, alpha, beta)
    r2_amp = float(cfg.B) * f_ss(t + float(cfg.separation_s) / 2.0, alpha, beta)
    rC_amp = float(cfg.C) * np.ones_like(t, dtype=float)

    r1 = apply_phase_evolution(r1_amp, cfg.phase_fn, t)
    r2 = apply_phase_evolution(r2_amp, cfg.phase_fn, t)
    rC = apply_phase_evolution(rC_amp, cfg.phase_fn, t)

    r = r1 + r2 + rC

    E = probe_field(t, f0_hz=cfg.f0_hz, fwhm_field_s=cfg.probe_fwhm_field_s, t0_s=cfg.probe_t0_s)

    # Baseline model: spectrum from Fourier transform of r(t)*E_probe(t)
    field_out = r * E

    lam_t = None
    tau_t = None
    if cfg.use_cat_ept:
        # If the user did not provide a reference rate, infer one from the
        # simulation's time-step constraint (CFL/Nyquist-style safety).
        from ..entropic_time import lambda0_from_cfl_time_step

        lam0 = float(cfg.lambda0_inv_s)
        if lam0 <= 0.0:
            lam0 = lambda0_from_cfl_time_step(cfg.dt_s)

        lam_t = compute_lambda_from_reflection(
            t_s=t,
            r_t=r,
            lambda0=lam0,
            kappa=cfg.lambda_kappa,
            floor=cfg.lambda_floor_inv_s,
        )
        # Optional metric redshift: λ -> λ * sqrt(-g00).
        if cfg.metric is not None:
            z = float(cfg.metric.redshift_factor(0.0, np.asarray(cfg.metric_x_vec_m, dtype=float)))
            lam_t = lam_t * z
            lam0 = lam0 * z

        tau_t = _cumtrapz(lam_t, t)

        if cfg.cat_mode == "amplitude":
            # Complex-action amplitude weight (software-stable, but not paper-default).
            # gamma=0 reduces exactly to baseline.
            field_out = field_out * np.exp(-float(cfg.gamma_entropic) * tau_t)

        elif cfg.cat_mode == "coherence":
            # Paper-facing CAT/EPT entry point:
            # apply entropic decoherence ONLY to the two-slit cross term.
            # g(S)=exp(-lambda_ent * S).
            lam_ent = float(cfg.lambda_ent_inv_s)
            if lam_ent <= 0.0:
                # Conservative inference: robust statistic + CFL-style ceiling.
                lam_ent = infer_lambda_entropic(lam_t, lam0)
            else:
                lam_ent = max(lam_ent, 0.0)
                if lam0 > 0:
                    lam_ent = min(lam_ent, lam0)

            # Apply metric redshift to the entropic rate if a metric is provided.
            if cfg.metric is not None:
                z = cfg.metric.redshift_factor(0.0, np.asarray(cfg.metric_x_vec_m, dtype=float))
                lam_ent = float(lam_ent) * float(z)

            gS = float(np.exp(-lam_ent * float(cfg.separation_s)))

            # Compose intensity in frequency domain.
            f, F1 = fft_field(t, r1 * E)
            _, F2 = fft_field(t, r2 * E)
            _, FC = fft_field(t, rC * E)

            I = (np.abs(F1) ** 2) + (np.abs(F2) ** 2) + (np.abs(FC) ** 2)
            I += 2.0 * gS * np.real(F1 * np.conj(F2))
            # Keep background interference coherent (conservative):
            I += 2.0 * np.real(F1 * np.conj(FC))
            I += 2.0 * np.real(F2 * np.conj(FC))

            I = np.clip(I, 0.0, None)
            return {
                "t_s": t,
                "r_t": r,
                "E_probe_t": E,
                "lambda_t": lam_t,
                "tau_ent_t": tau_t,
                "freq_hz": f,
                "intensity": I,
                "lambda0_inv_s": lam0,
                "lambda_ent_inv_s": lam_ent,
                "gS": gS,
                "alpha_inv_s": alpha,
                "beta_inv_s": beta,
            }

        else:
            raise ValueError("cat_mode must be 'coherence' or 'amplitude'")

    f, I = fft_spectrum(t, field_out)

    return {
        "t_s": t,
        "r_t": r,
        "E_probe_t": E,
        "lambda_t": lam_t,
        "tau_ent_t": tau_t,
        "freq_hz": f,
        "intensity": I,
        "alpha_inv_s": alpha,
        "beta_inv_s": beta,
    }


def simulate_time_double_slit_band(cfg: TimeDoubleSlitConfig, half_width_hz: float = 15e12) -> Dict[str, Any]:
    """Convenience wrapper: run full sim and return a normalized spectrum in a band around f0."""
    out = simulate_time_double_slit(cfg)
    fb, Ib = bandpass_normalize(out["freq_hz"], out["intensity"], cfg.f0_hz, half_width_hz)
    out["freq_hz_band"] = fb
    out["intensity_band"] = Ib
    return out
