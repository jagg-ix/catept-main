# catept-main/submission/ — External-facing formal NS package

## What's here

[`NavierStokes_Route6_Submission/`](NavierStokes_Route6_Submission/) — a
**self-contained Lean 4 formalization** proving `PreciseGapStatement`
(quantitative BKM bound ⇒ global regularity) for 3D incompressible
Navier–Stokes on the unit periodic torus, via Route 6 of the entropic
proper time framework.

Also: [`NavierStokes_Route6_Submission.tar.gz`](NavierStokes_Route6_Submission.tar.gz)
— tarball of the same, for distribution.

## Provenance

Copied verbatim (2026-04-22) from the upstream authoring repo at

  `../navier-stokes-project-clean-translator/submission/NavierStokes_Route6_Submission/`

because that sibling directory is on the user's delete/move queue. This
copy preserves the submission's audit trail and reviewer-facing structure.

## Self-contained

The submission has **its own lakefile**, its own `lean-toolchain`
(currently `leanprover/lean4:v4.29.0-rc3`), and a minimal external
dependency (only Mathlib). It builds independently of catept-main's
main tree — you can build it standalone with

```bash
cd submission/NavierStokes_Route6_Submission/lean4
lake update && lake build
```

This is deliberate: a submission package should be reviewable in
isolation, without pulling in the full catept-main dep graph.

## Main result

File: [`lean4/NavierStokes/NumericalBoundCertificate.lean:150`](NavierStokes_Route6_Submission/lean4/NavierStokes/NumericalBoundCertificate.lean)

```lean
theorem unit_torus_route6_closed : PreciseGapStatement :=
  quantitative_route6_pipeline
```

36 Lean files, 251 theorems, 211 axioms, 0 sorry, 0 warnings.

## Conditional on (explicitly)

Per [`README.md`](NavierStokes_Route6_Submission/README.md) and
[`AXIOM_AUDIT.md`](NavierStokes_Route6_Submission/AXIOM_AUDIT.md):

1. **Physical identification**: `ℏ = 2ν` (Constantin-Iyer 2008, published)
2. **Numerical computation**: `S_∞(7.60) < λ_1` — Wolfram-verified
   with 77 000× margin (see `wolfram/eq_238_trace_cameron_competition.wl`)
3. **~200 standard PDE axioms** (Sobolev embeddings, BKM criterion,
   Galerkin theory, Leray-Hopf existence, etc.)

**Critical path = 14 axioms** for Route 6; the rest are ancillary or
SUPERSEDED.

## Not the Millennium Problem

The submission's README is explicit:

> **This is NOT an unconditional proof of the Millennium Problem.**
> It is a formalized conditional result.

The classification scheme in `AXIOM_AUDIT.md` uses explicit labels
(STD-PDE, PUBLISHED, PHYS-ID, WOLFRAM, OPEN, SUPERSEDED) so any
reviewer can see exactly what is assumed and what is proved.

## Relation to catept-main's own NS content

- `catept-main/NavierStokes/` (258 Lean files) contains the broader
  development snapshot: BKM variants, Galerkin infrastructure,
  enstrophy bridges, and `NSCKNPartialRegularityBridge.lean`.

- `catept-main/NavierStokesClean/Millennium/` contains an alternative
  (earlier?) Millennium closure via `MillenniumClosure.lean`
  (`pgs_implies_fefferman_b` axiom + `NSC_P33_Bridge.lean` with
  6 analytic-NS axioms).

- **The Route 6 submission here is the submission-packaged variant** —
  curated, audited, documented for external review.

If these three sources diverge in the future, treat **this submission
directory as the immutable reviewer-facing artifact** and cross-check
against the broader `NavierStokes/` tree for internal consistency.
