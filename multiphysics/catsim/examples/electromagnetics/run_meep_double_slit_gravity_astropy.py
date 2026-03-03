"""Meep double-slit with metric redshift using Astropy unit transforms.

This example shows the *integration points* needed so the electromagnetics
backend (Meep) can interact with the repo's gravity/metric tooling:

* A `MetricField` from `cat_ept_doubleslit.metrics.redshift`
* A `MeepToPhysicalMap` mapping simulation units to SI
* Entropic stepping where tau is the driver and dt is derived via lambda_eff

The numeric values here are illustrative; adjust to your experiment.
"""

from __future__ import annotations


def main() -> None:
    from cat_ept_doubleslit.electromagnetics.meep_backend import (
        has_meep,
        build_basic_2d_double_slit,
        MeepRunConfig,
        run_meep_with_entropic_clock,
    )
    from cat_ept_doubleslit.metrics.redshift import schwarzschild_metric
    from cat_ept_doubleslit.astro.transforms import MeepToPhysicalMap, has_astropy

    if not has_meep():
        raise SystemExit("Meep is not installed. Install pymeep (conda-forge recommended) and retry.")

    # Optional: use astropy to define unit conversions cleanly.
    if has_astropy():
        import astropy.units as u

        length_unit_m = (1.0 * u.micron).to_value(u.m)
        time_unit_s = (1.0 * u.fs).to_value(u.s)
    else:
        # Fallback: plain floats
        length_unit_m = 1e-6
        time_unit_s = 1e-15

    # Build a weak-field Schwarzschild metric (example: Earth mass).
    earth_mass_kg = 5.972e24
    metric = schwarzschild_metric(earth_mass_kg)

    # Map Meep coordinates to SI for metric evaluation.
    map_to_si = MeepToPhysicalMap(length_unit_m=length_unit_m, time_unit_s=time_unit_s)

    sim = build_basic_2d_double_slit(resolution=20)

    # Example lambda(t): constant entropic rate in Meep time units.
    # In a real setup, this can be derived from an auxiliary model.
    lambda_fn = lambda t: 0.1

    cfg = MeepRunConfig(
        resolution=20,
        use_entropic_time=True,
        dtau=0.05,
        t_final=5.0,
        tau_final=2.0,
        # Choose the point where the metric is sampled (in Meep units).
        metric_ref_point=(0.0, 0.0, 0.0),
        length_unit_m=length_unit_m,
        time_unit_s=time_unit_s,
        verbose=False,
    )

    out = run_meep_with_entropic_clock(
        sim,
        lambda_fn=lambda_fn,
        config=cfg,
        metric=metric,
        map_to_si=map_to_si,
    )

    print(f"Final t (Meep units): {out['t'][-1]:.6g}")
    print(f"Final tau (Meep units): {out['tau'][-1]:.6g}")
    print(f"Final lambda_eff: {out['lambda_eff'][-1]:.6g}")


if __name__ == "__main__":
    main()
