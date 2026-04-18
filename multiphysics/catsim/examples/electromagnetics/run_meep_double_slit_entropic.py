"""Meep double-slit demo with entropic proper time stepping.

This example is intentionally small and conservative:
* builds a simple 2D double-slit geometry
* advances the simulation using a fixed entropic step dτ
* converts each dτ into a coordinate dt via dt = dτ/λ_eff

It is meant to validate the *software* integration (time mapping, hooks,
imports), not to serve as a definitive optical reproduction.
"""

from __future__ import annotations

from cat_ept_doubleslit.electromagnetics.meep_backend import (
    MeepRunConfig,
    build_basic_2d_double_slit,
    run_meep_with_entropic_clock,
    has_meep,
)


def main() -> None:
    if not has_meep():
        raise SystemExit(
            "Meep is not installed. Install pymeep (conda-forge recommended) and retry."
        )

    # Constant lambda for demonstration
    lambda0 = 0.5
    lambda_fn = lambda t: lambda0

    sim = build_basic_2d_double_slit(
        wavelength=1.0,
        slit_sep=1.5,
        slit_width=0.5,
        resolution=20,
        pml_thickness=1.0,
    )

    cfg = MeepRunConfig(
        resolution=20,
        courant=0.5,
        use_entropic_time=True,
        dtau=0.05,
        tau_final=5.0,
        t_final=20.0,
        verbose=True,
    )

    out = run_meep_with_entropic_clock(sim, lambda_fn=lambda_fn, config=cfg)
    print("Done.")
    print(f"t_end={out['t'][-1]:.6g}  tau_end={out['tau'][-1]:.6g}  lambda_eff_end={out['lambda_eff'][-1]:.6g}")


if __name__ == "__main__":
    main()
