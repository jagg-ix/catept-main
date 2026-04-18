# CFL + entropic proper time in software

We use an entropic clock `tau` with `d tau / d t = lambda` (lambda >= 0).

For explicit schemes, CFL-type constraints still apply in coordinate time `t`.
Reparameterizing changes *step selection*, not causality: choose a stable `dt`
from CFL (and optional dissipation stability), then map to `d_tau = lambda_eff * dt`.

This repo provides `cat_ept_doubleslit.numerics.cfl_clock` to implement this mapping.
