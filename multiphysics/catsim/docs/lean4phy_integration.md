# Lean4 / PhysLean integration

catsim is primarily a Python simulation repository; however, some CAT/EPT claims
benefit from machine-checked formalization (e.g., properties of the entropic
proper time mapping and CFL reparameterization constraints).

This repo carries an **optional** Lean project under `./lean` (CatsimLean). It
is intended to interoperate with PhysLean (HEPLean) while remaining fully
toggleable: if Lean tooling is absent, catsim continues to run normally.

## What is formalized today (v9.9)

- `CatsimLean.EntropicTime`: defines `tauEnt λ t0 t1` as an interval integral and
  provides a conservative monotonicity skeleton.
- `CatsimLean.CFL`: expresses the shape of the coordinate-time CFL bound and a
  derived bound for an entropic step `Δτ = λ̄ Δt`.

## How it connects to Python

Phase 6.22 (`scripts/phase6_22_lean_verify.py`) exports `lean_verification_spec.json`
with a compact schema mirroring the repository's entropic time contract:

- `t_s`
- `tau_ent_s`
- `lambda_eff_s_inv`

The script then runs `lake build` in `./lean` if Lean tooling is detected.

## Quick start

```bash
cd lean
lake update
lake build
```

Then run:

```bash
make phase6  # includes Phase 6.22
```

## Next formalization targets

1. Replace `sorry` in `tauEnt_monotone_right` with the appropriate Mathlib lemma
   on additivity of interval integrals.
2. Formalize the entropic CFL reuse claim used by the Python stepper:
   if `λ_min ≤ λ̄` then `Δτ ≤ λ̄ Δx/c` implies `Δt ≤ Δx/(c λ_min)`.
3. Add a bridge that can ingest a tensor timeline exported from `OGRePy` and prove
   simple identities (e.g., equilibrium limit: `∇ϕ = 0` => imaginary residual vanishes).
