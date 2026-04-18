# i-PI entropic patch integration

- `entropic_drivers.py` is the **i-PI socket-driver side** (runs as the force provider).
- The `ipi/` subtree mirrors new modules added to i-PI by your patch.

In production, those `ipi/*` modules should live inside an i-PI checkout.
Here they’re included for provenance and to make it easy to re-apply the patch.

## Step-size guard suggestions (CFL + dissipation)

The driver layer in this repo integrates the `cat_ept_doubleslit.numerics.cfl_clock.CFLClock`
controller. i-PI chooses the actual coordinate-time step `dt` on the **server** side,
but a driver can expose *recommended* bounds via the `extras` ...

When the driver returns per-atom `extras["lambda"]`, it will also add:

- `dt_suggest`: recommended upper bound for coordinate-time step (seconds)
- `dtau_suggest`: corresponding entropic-time step (dimensionless here, since `lambda` is `s^-1`)
- `lambda_max`: max lambda seen across atoms (`s^-1`)
- `courant`: Courant number `a*dt/dx` if `dx` and `a` were supplied to the driver (otherwise NaN)
- `alpha_scheme`: scheme stability radius used for the dissipation guard

You can provide CFL metadata when starting a driver:

```python
SGIDriver(..., cfl_dx_m=1e-3, cfl_amax_m_s=299792458.0, cfl_max=0.9)
```

If `cfl_dx_m` and `cfl_amax_m_s` are omitted, the driver still provides the
dissipation-only guard `dt <= alpha_scheme/lambda_max`.
