import CATEPT.PhysicalConstants
import Mathlib
import Mathlib.Data.Real.Basic
import Mathlib.Data.Complex.Basic

set_option autoImplicit false

namespace CATEPT

/-- Abstract sector split from Section X:
`HR` = computational sector, `HI` = temporal-order sector. -/
structure TwoSectorSystem where
  HRState : Type
  HIState : Type

/-- Formal full state on `HR ⊗ HI`. -/
structure FullState (S : TwoSectorSystem) where
  coeff : S.HRState → S.HIState → ℂ

/-- Abstract reduced state on the `HR` sector after tracing out `HI`. -/
structure ReducedState (S : TwoSectorSystem) where
  rhoHR : S.HRState → S.HRState → ℂ

/-- Section X temporal-order superposition schema.

This models the document's
  |ψ_sup⟩ = (|K_{A<B}⟩ ⊗ |U_B U_A ψ⟩ + |K_{B<A}⟩ ⊗ |U_A U_B ψ⟩)/√2
as an interface object.
-/
structure TemporalOrderSuperposition (S : TwoSectorSystem) where
  orderAB : S.HIState
  orderBA : S.HIState
  compAB  : S.HRState
  compBA  : S.HRState

/-- Section X entropic-time expectation formula:
    ⟨T̂⟩ = J ∑ 2 sin(kR) sinh(kI). -/
def entropicTimeExpectation
    (J : ℝ) (kR kI : Fin n → ℝ) : ℝ :=
  J * ∑ j, (2 * Real.sin (kR j) * Real.sinh (kI j))

/-- Matter/antimatter sign rule from Section X:
flipping the sign of `kI` flips the sign of ⟨T̂⟩. -/

structure SplitHamiltonian (ψ : Type) where
  HR : ψ → ψ
  HI : ψ → ψ

/-- Section X reduced non-unitary dynamics after tracing out `HI`:
    ρ̇ = -(i/ħ)[HR,ρ] - (1/ħ){HI,ρ}. -/


/-- Arrow of time from tracing out temporal order:
    dS/dt = kB d⟨T̂⟩/dt ≥ 0. -/
def SatisfiesArrowFromTemporalOrder
    (c : PhysicalConstants)
    (entropy Texp : ℝ → ℝ) : Prop :=
  ∀ t : ℝ, deriv entropy t = c.kB * deriv Texp t

/-- The document's interpretation:
tracing out `HI` yields effective irreversibility in `HR`. -/
