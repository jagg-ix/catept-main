import Physlib.SpaceAndTime.Space.Derivatives.Curl
import NavierStokesClean.Core.Types

/-!
# PhysLean Bridge: ∇ ⬝ (∇ × f) = 0

Phase 3 of the NavierStokesClean program.

## What this file provides

A **fully proved** (0 new axioms) concrete statement of the Bianchi identity
for 3-dimensional vector fields, sourced directly from PhysLean:

  `ns_div_curl_zero : ∀ (f : Space → EuclideanSpace ℝ (Fin 3)), ContDiff ℝ 2 f → ∇ ⬝ (∇ × f) = 0`

This replaces the Phase 0 vacuous stub `axiom div_curl_eq_zero : ∀ _ : NSField, True`.

## Mathematical content

The identity ∇ ⬝ (∇ × f) = 0 is the vector identity "divergence of curl is zero".
In fluid mechanics it encodes:

  * **Helmholtz decomposition**: any velocity field u = ∇φ + ∇ × A
    satisfies ∇ ⬝ (∇ × A) = 0, so the curl part is automatically divergence-free.
  * **Vorticity incompressibility**: ω = ∇ × u implies ∇ ⬝ ω = 0 for any C² field u.
  * **Bianchi identity analogue**: same algebraic structure as ∇ ⬝ B = 0 in Maxwell.

## Phase 5 target

When `NSField` is upgraded from `ℝ × ℝ` to `Space → EuclideanSpace ℝ (Fin 3)`,
the abstract `SatisfiesNSPDE` constraint will reference `ns_div_curl_zero` directly
to discharge the divergence-free condition from the Phase 0 axiom `DivergenceFree`.

## Zero new axioms — proved by PhysLean.
-/

set_option autoImplicit false

namespace NavierStokesClean.PhysLeanBridge

open Space

/-- **Divergence of curl is zero** — proved by PhysLean, 0 new axioms.

    For any C² vector field f : Space → EuclideanSpace ℝ (Fin 3),
    the divergence of its curl vanishes everywhere:  ∇ ⬝ (∇ × f) = 0.

    Source: `PhysLean.SpaceAndTime.Space.Derivatives.Curl.div_of_curl_eq_zero`
    (PhysLean, Josuat-Vergès et al., formally verified in Lean 4 / Mathlib).

    **Epistemic**: `.verified` — direct PhysLean theorem, no new axioms. -/
theorem ns_div_curl_zero (f : Space → EuclideanSpace ℝ (Fin 3)) (hf : ContDiff ℝ 2 f) :
    ∇ ⬝ (∇ × f) = 0 :=
  div_of_curl_eq_zero f hf

/-- **Vorticity is divergence-free** — corollary for velocity fields.

    If u : Space → EuclideanSpace ℝ (Fin 3) is a C² velocity field,
    its vorticity ω = ∇ × u satisfies ∇ ⬝ ω = 0.

    This is the key incompressibility constraint on the vorticity field
    in the Navier-Stokes equations. -/
theorem ns_vorticity_div_free (u : Space → EuclideanSpace ℝ (Fin 3)) (hu : ContDiff ℝ 2 u) :
    ∇ ⬝ (∇ × u) = 0 :=
  ns_div_curl_zero u hu

/-- **Curl of a curl identity** (∇ × (∇ × f) = ∇(∇⊙f) − Δf) — proved by PhysLean.

    Used in the vorticity formulation of Navier-Stokes:
      ∂ₜω + (u·∇)ω = ν·Δω + (ω·∇)u
    where Δω = ∇(∇⊙ω) − ∇×(∇×ω) (since ∇⊙ω = 0 by ns_div_curl_zero).

    Source: `PhysLean.SpaceAndTime.Space.Derivatives.Curl.curl_of_curl`.
    Here `Δ` is `laplacianVec` (vector Laplacian). -/
theorem ns_curl_of_curl (f : Space → EuclideanSpace ℝ (Fin 3)) (hf : ContDiff ℝ 2 f) :
    ∇ × (∇ × f) = ∇ (∇ ⬝ f) - Δ f :=
  curl_of_curl f hf

end NavierStokesClean.PhysLeanBridge
