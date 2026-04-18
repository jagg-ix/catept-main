"""REBOUND + CAT/EPT entropic time demo.

This example demonstrates:
- REBOUND evolving an N-body system in coordinate time t
- catsim tracking entropic proper time tau_ent alongside t

Run:
    pip install -e '.[rebound]'
    PYTHONPATH=src python examples/astro/run_rebound_entropic_orbit.py

Optional:
    pip install -e '.[astropy]'
    (then the script prints a couple of values with units)
"""

from __future__ import annotations

import math

import numpy as np

from cat_ept_doubleslit.integration.rebound_backend import ReboundRunConfig, run_rebound_with_entropic_clock


def main():
    import rebound

    sim = rebound.Simulation()
    sim.units = ("AU", "yr", "Msun")
    sim.integrator = "whfast"

    # Sun + Jupiter-like planet
    sim.add(m=1.0)
    sim.add(m=1e-3, a=1.0, e=0.05)
    sim.move_to_com()

    # A toy lambda model: constant openness / entropy-production rate
    lambda0 = 0.2  # 1/s in SI; here we just treat it as a dimensionful scalar used for tau tracking

    def lambda_fn(t_s: float, _state=None) -> float:
        return lambda0

    # Integrate for 10 "years" in the chosen units. We use a numeric mapping here:
    # - REBOUND's internal time is in years due to units, but our adapter assumes seconds.
    # For the demo we interpret REBOUND time as seconds-like. For real use, wrap with Astropy.
    # We'll run a short time to keep it fast.

    cfg = ReboundRunConfig(t0_s=0.0, t_end_s=10.0, dt_s=0.01, record_every=10)
    out = run_rebound_with_entropic_clock(sim, lambda_fn=lambda_fn, config=cfg)

    t = out["t_s"]
    tau = out["tau_ent"]

    print("Recorded steps:", len(t))
    print("t_end:", t[-1])
    print("tau_end:", tau[-1])

    # Basic sanity: with constant lambda, tau ~= lambda * t
    err = np.max(np.abs(tau - lambda0 * t))
    print("max |tau - lambda*t|:", err)

    # Optional: show with units if Astropy installed
    try:
        from cat_ept_doubleslit.astro.astropy_bridge import has_astropy

        if has_astropy():
            from astropy import units as u

            print("tau_end (Quantity):", (tau[-1] * u.s))
    except Exception:
        pass


if __name__ == "__main__":
    main()
