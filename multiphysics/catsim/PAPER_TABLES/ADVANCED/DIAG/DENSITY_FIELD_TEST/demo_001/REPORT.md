# Density-field placement-aware test (v10.42)

This diagnostic validates that spatial bath-density multipliers `s(x)` track **scene placement** (top_right, bottom_left, etc.)
instead of assuming regions are centered at the origin.

## What was tested

- Scene region: 0.02 m × 0.02 m, centered at (0,0)
- Matter region:
  - placement: `top_right` → center at (0.01, 0.01)
  - radius: 0.003 m
  - energy-density knob: 10.0 (unit is whatever you treat `J/m^3` as in the scene knob; here it's a scalar driver)
- Black-hole region:
  - placement: `bottom_left` → center at (-0.01, -0.01)
  - radius: 0.002 m
  - density knob: same as matter by default

A diagonal trajectory `x(t)` sweeps from (-0.012,-0.012) to (+0.012,+0.012).

## Outputs

- `scale_path_and_rates.csv`:
  - `scale` column is `s(x(t))`
  - bath rates are derived from `gamma_base(t)` scaled by `scale`, then split into (dephasing, relax, excite)
- `summary.json`:
  - `scale_stats` and the resulting QuTiP (or fallback) interferometer output

## Expected behavior (pass/fail)

**PASS if:**
- `scale` takes the baseline value 1.0 outside the placed spheres, and jumps to `1 + rho/rho_ref = 11.0` inside:
  - near (-0.01,-0.01) early in the trajectory (BH sphere)
  - near (+0.01,+0.01) late in the trajectory (matter sphere)

**Observed:**
- `scale min/max/mean`: 1.0 / 11.0 / 3.9
- `scale == 11` occurs near:
  - (-0.0114,-0.0114) … consistent with BH sphere centered at (-0.01,-0.01) radius 0.002
  - (+0.0120,+0.0120) … consistent with matter sphere centered at (+0.01,+0.01) radius 0.003

So the placement-aware scaling is **working**.

## Note about QuTiP

In this environment, the QuTiP call fell back to the analytic fallback backend (QuTiP not available), so this run validates:
- the **data plumbing** (scale field, scale-path, rate construction)
- not the numerical GKLS integration.

To validate QuTiP numerics, run the same script in an environment with `qutip` installed.
