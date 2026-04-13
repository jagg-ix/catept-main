# Porting Lanes

This file tracks the repositories that are integrated into this hub but not yet direct Lean 4.29 dependencies.

## Bridge or upgrade required

- lean-quantuminfo-inspect
  - Target: bump from 4.28.0 to 4.29.0 and re-pin compatible mathlib revision.
- brownian-motion-inspect
  - Target: move from 4.28.0-rc1 to stable 4.29.0 lane.
- kolmogorov-complexity-lean-inspect
  - Target: replace 4.29.0-rc8 with 4.29.0 stable and update any API deltas.

## Legacy port required

- ThermodynamicsLean-inspect
  - Current: 4.24.0-rc1
  - Target: staged migration through 4.28.0 to 4.29.0.
- carleson-inspect
  - Current: 4.15.0
  - Target: multi-step port with syntax and mathlib namespace updates.
- gibbsmeasure-inspect
  - Current: 4.22.0
  - Target: direct upgrade to 4.29.0 if API usage is narrow, else staged path.
- hopf-lean-4.26-port
  - Current: 4.26.0
  - Target: re-pin and adjust transitive dependencies for 4.29.0 compatibility.
