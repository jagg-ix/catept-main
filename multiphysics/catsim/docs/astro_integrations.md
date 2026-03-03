# Astrophysics integrations: Astropy + REBOUND

## Design position

- Coordinate time `t` is a *derived* variable when you choose to integrate in entropic proper time `tau_ent`.
- CFL-like stability constraints still constrain coordinate-time steps for explicit hyperbolic solvers; for orbital N-body (REBOUND), the dominant step constraints are typically orbital timescales and integrator accuracy, but you may still impose a conservative guard when coupling explicit CAT/EPT dissipation.

## Astropy

Use Astropy for:
- units (`astropy.units`)
- constants (`astropy.constants`)
- coordinate frames and time scales (`astropy.coordinates`, `astropy.time`)

The core solvers remain float-based; `cat_ept_doubleslit.astro.astropy_bridge` provides boundary adapters.

## REBOUND

Use REBOUND as a coordinate-time dynamics engine and track entropic proper time alongside it:

`run_rebound_with_entropic_clock(sim, lambda_fn=..., config=...)`

For entropic stepping you typically:
1) choose/compute a coordinate-time `dt` (from integrator accuracy)
2) accumulate `d tau = lambda * dt`

