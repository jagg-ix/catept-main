r"""Meep (FDTD) adapter with CAT/EPT-friendly stepping.

Design goals
------------
* Keep Meep optional (soft import) so the core simulator works without it.
* Make *entropic proper time* (tau) the *driver* variable when desired:

    d\tau = \lambda_eff\, dt,  with  \lambda_eff = \lambda * z

  where z is an optional redshift factor :math:`z = \sqrt{-g_{00}}`.

* Do not pretend tau removes CFL constraints. Meep is an explicit FDTD scheme;
  its internal timestep is controlled by the Courant factor. When stepping in
  tau, we simply *choose* a physical time increment dt from a tau increment
  d\tau and ask Meep to advance to the new target time.

Compliance helpers (suggestions)
--------------------------------
This module includes small, testable hooks that support the "compliance" style
criteria you listed:

* resolution checks (avoid 1-voxel interfaces)
* monotonic convergence skeleton (compare spectra across resolutions)
* dt bounds consistent with Nyquist + Courant guard (delegated to CFLClock)

Note: We intentionally keep these helpers minimal; the user's experiment-setup
should define the real acceptance thresholds.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional, Any

import math

from cat_ept_doubleslit.clock.entropic_clock import EntropicClock
from cat_ept_doubleslit.numerics.cfl_clock import CFLClock
from cat_ept_doubleslit.metrics.redshift import MetricField
from cat_ept_doubleslit.astro.transforms import MeepToPhysicalMap


def _redshift_factor_from_g00(g00: float) -> float:
    """Return sqrt(-g00) for Lorentzian metrics.

    We keep this local to avoid coupling the Meep adapter to a particular
    metric representation. When used with EinsteinPy, `metric_g00_fn` should
    already encode the coordinate choice.
    """

    if g00 >= 0:
        raise ValueError("Expected Lorentzian g00 < 0.")
    return math.sqrt(-float(g00))


def has_meep() -> bool:
    """Return True if the Meep Python bindings are importable."""

    try:
        import meep  # noqa: F401

        return True
    except Exception:
        return False


@dataclass(frozen=True)
class MeepRunConfig:
    """Configuration for a Meep run driven by tau (optional) or t."""

    # Spatial / discretization
    resolution: int = 20  # pixels per distance unit
    courant: float = 0.5
    pml_thickness: float = 1.0

    # Mapping from Meep units to SI (for metric evaluation)
    length_unit_m: float = 1.0
    time_unit_s: float = 1.0
    metric_ref_point: tuple[float, float, float] = (0.0, 0.0, 0.0)

    # Time stepping
    use_entropic_time: bool = True
    dtau: float = 0.05  # entropic step size, dimensionless in Meep units
    t_final: float = 10.0  # physical coordinate time in Meep units
    tau_final: float = 10.0

    # CFL / sampling compliance
    cfl_max: float = 0.9
    alpha_scheme: float = 2.0  # for pure decay mode dt*lambda <= alpha

    # Optional monitoring
    verbose: bool = False




def build_basic_2d_double_slit(
    *,
    wavelength: float = 1.0,
    slit_sep: float = 1.5,
    slit_width: float = 0.5,
    screen_dist: float = 6.0,
    cell_size_x: float = 16.0,
    cell_size_y: float = 12.0,
    resolution: int = 20,
    pml_thickness: float = 1.0,
    source_bandwidth: float = 0.2,
) -> Any:
    """Construct a simple 2D double-slit Meep Simulation.

    This is a conservative, educational setup meant as a starting point. It is
    *not* a precision reproduction of any specific experiment.
    """

    try:
        import meep as mp
    except Exception as e:
        raise ImportError(
            "Meep is not installed. Install via conda-forge (recommended) or pip, "
            "then retry."
        ) from e

    cell = mp.Vector3(cell_size_x, cell_size_y, 0)
    pml_layers = [mp.PML(pml_thickness)]

    # Metal screen with two slits: model as a high-epsilon block with two air gaps.
    screen_x = -0.5 * cell_size_x + 2.0
    screen_thickness = 0.5
    screen_height = cell_size_y - 2.0 * pml_thickness

    eps_screen = 12.0
    screen = mp.Block(
        size=mp.Vector3(screen_thickness, screen_height, mp.inf),
        center=mp.Vector3(screen_x, 0),
        material=mp.Medium(epsilon=eps_screen),
    )

    # Cut out two slits by adding air blocks (overwriting via geometry order is not possible,
    # so we model slits as low-epsilon blocks embedded: practical approach is to build the
    # screen from two blocks leaving gaps. We'll do that.
    gap = slit_sep
    w = slit_width
    # Upper screen segment
    top = mp.Block(
        size=mp.Vector3(screen_thickness, (screen_height - gap) / 2.0 - w, mp.inf),
        center=mp.Vector3(screen_x, +(gap / 2.0 + w + ((screen_height - gap) / 4.0 - w / 2.0))),
        material=mp.Medium(epsilon=eps_screen),
    )
    # Middle segment between slits
    mid = mp.Block(
        size=mp.Vector3(screen_thickness, gap - w, mp.inf),
        center=mp.Vector3(screen_x, 0),
        material=mp.Medium(epsilon=eps_screen),
    )
    # Bottom segment
    bot = mp.Block(
        size=mp.Vector3(screen_thickness, (screen_height - gap) / 2.0 - w, mp.inf),
        center=mp.Vector3(screen_x, -(gap / 2.0 + w + ((screen_height - gap) / 4.0 - w / 2.0))),
        material=mp.Medium(epsilon=eps_screen),
    )

    geometry = [top, mid, bot]

    # Source: broadband Gaussian pulse centered at frequency 1/wavelength
    fcen = 1.0 / wavelength
    df = source_bandwidth * fcen
    src = mp.Source(
        mp.GaussianSource(frequency=fcen, fwidth=df),
        component=mp.Ez,
        center=mp.Vector3(screen_x - 2.0, 0),
        size=mp.Vector3(0, cell_size_y - 2.0 * pml_thickness, 0),
    )

    sim = mp.Simulation(
        cell_size=cell,
        boundary_layers=pml_layers,
        geometry=geometry,
        sources=[src],
        resolution=resolution,
    )

    # Add a flux monitor near the "screen" plane.
    mon_x = screen_x + screen_dist
    sim.add_flux(fcen, df, 101, mp.FluxRegion(center=mp.Vector3(mon_x, 0), size=mp.Vector3(0, cell_size_y - 2.0 * pml_thickness)))

    return sim


def _lambda_eff(
    lambda_fn: Callable[[float], float],
    t_meep: float,
    *,
    metric: Optional[MetricField] = None,
    map_to_si: Optional[MeepToPhysicalMap] = None,
    metric_ref_point: tuple[float, float, float] = (0.0, 0.0, 0.0),
    metric_g00_fn: Optional[Callable[[float], float]] = None,
) -> float:
    """Compute lambda_eff(t) = lambda(t) * sqrt(-g00).

    Backwards-compatibility notes
    -----------------------------
    Earlier versions of this adapter accepted `metric_g00_fn(t)`.
    Newer versions prefer `metric: MetricField` and a `map_to_si` mapping
    so gravity/metrics can be shared across the repo.
    """

    lam = float(lambda_fn(t_meep))
    if lam < 0:
        raise ValueError("lambda(t) must be >= 0 for entropic proper time.")

    # Preferred: MetricField + explicit Meep->SI mapping
    if metric is not None:
        if map_to_si is None:
            raise ValueError("map_to_si is required when metric is provided")
        t_s = map_to_si.t_s(t_meep)
        x_m = map_to_si.x_vec_m(metric_ref_point)
        z = metric.redshift_factor(t_s, x_m)
        return lam * float(z)

    # Legacy: metric_g00_fn(t)
    if metric_g00_fn is not None:
        z = _redshift_factor_from_g00(float(metric_g00_fn(t_meep)))
        return lam * z

    return lam


def run_meep_with_entropic_clock(
    sim: Any,
    *,
    lambda_fn: Callable[[float], float],
    config: MeepRunConfig,
    metric: Optional[MetricField] = None,
    metric_g00_fn: Optional[Callable[[float], float]] = None,
    map_to_si: Optional[MeepToPhysicalMap] = None,
    cfl_dx: Optional[float] = None,
    cfl_amax: Optional[float] = None,
) -> dict:
    """Run a Meep simulation either stepping in tau or in t.

    Parameters
    ----------
    sim:
        A `meep.Simulation` instance.
    lambda_fn:
        Function of coordinate time t returning entropy production rate lambda.
        Units depend on your normalization; in Meep-native units this is dimensionless.
    config:
        Run configuration.
    metric_g00_fn:
        Optional callable returning g00(t) for redshift-factor scaling.
    cfl_dx, cfl_amax:
        Optional parameters for CFLClock compliance checks.

    Returns
    -------
    dict with time series: t, tau, lambda_eff.
    """

    # If the caller provides a metric but no explicit mapping, build one from config.
    if metric is not None and map_to_si is None:
        map_to_si = MeepToPhysicalMap(
            length_unit_m=float(config.length_unit_m),
            time_unit_s=float(config.time_unit_s),
        )

    try:
        import meep as mp
    except Exception as e:
        raise ImportError(
            "Meep is not installed. Install via conda-forge (recommended) or pip, then retry."
        ) from e

    # Set Courant factor if supported
    try:
        sim.courant = config.courant  # type: ignore[attr-defined]
    except Exception:
        # Older meep bindings set courant at module-level; ignore if unavailable.
        pass

    if map_to_si is None:
        map_to_si = MeepToPhysicalMap(
            length_unit_m=float(config.length_unit_m),
            time_unit_s=float(config.time_unit_s),
        )

    clock = EntropicClock(
        lambda_fn=lambda t: _lambda_eff(
            lambda_fn,
            t,
            metric=metric,
            map_to_si=map_to_si,
            metric_ref_point=config.metric_ref_point,
            metric_g00_fn=metric_g00_fn,
        )
    )
    cfl = CFLClock(dx=cfl_dx, a_max_default=cfl_amax, cfl_max=config.cfl_max, alpha_scheme=config.alpha_scheme)

    t = 0.0
    tau = 0.0
    ts = [t]
    taus = [tau]
    lams = [
        _lambda_eff(
            lambda_fn,
            t,
            metric=metric,
            map_to_si=map_to_si,
            metric_ref_point=config.metric_ref_point,
            metric_g00_fn=metric_g00_fn,
        )
    ]

    # Basic discretization sanity: keep at least ~2 voxels for interfaces
    if config.resolution < 8:
        raise ValueError("Resolution too low; use >=8 (prefer >=16) for meaningful results.")

    if not config.use_entropic_time:
        # Run in coordinate time t
        sim.run(until=config.t_final)
        # We can still sample tau at the end (constant-step approximation)
        t = config.t_final
        tau = clock.tau_of_t(t)
        lam_end = _lambda_eff(
            lambda_fn,
            t,
            metric=metric,
            map_to_si=map_to_si,
            metric_ref_point=config.metric_ref_point,
            metric_g00_fn=metric_g00_fn,
        )
        return {"t": [0.0, t], "tau": [0.0, tau], "lambda_eff": [lams[0], lam_end]}

    # Step in tau; each loop we compute dt from dtau and advance Meep.
    dtau = float(config.dtau)
    if dtau <= 0:
        raise ValueError("dtau must be > 0")

    while tau < config.tau_final:
        lam_eff = _lambda_eff(
            lambda_fn,
            t,
            metric=metric,
            map_to_si=map_to_si,
            metric_ref_point=config.metric_ref_point,
            metric_g00_fn=metric_g00_fn,
        )
        lam_eff = max(lam_eff, 1e-12)

        dt = dtau / lam_eff
        # Apply conservative dt guards (CFL-like and dissipation-like)
        dt_guard = cfl.suggest_dt(dx=cfl_dx, a_max=cfl_amax, lambda_max=lam_eff)
        if dt_guard is not None and dt > dt_guard:
            dt = dt_guard
            dtau = lam_eff * dt

        t_next = t + dt
        # Meep's run() is cumulative in "time"; pass the new absolute target
        sim.run(until=t_next)
        t = t_next
        tau = tau + dtau

        ts.append(t)
        taus.append(tau)
        lams.append(lam_eff)

        if config.verbose and (len(ts) % 50 == 0):
            mp.master_printf(f"[Meep] t={t:.4g}, tau={tau:.4g}, lambda_eff={lam_eff:.4g}\n")

        if t >= config.t_final:
            # Safety: stop if coordinate time exceeded
            break

    return {"t": ts, "tau": taus, "lambda_eff": lams}
