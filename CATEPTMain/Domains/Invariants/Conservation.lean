import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Core.Assumptions
import Mathlib.Algebra.BigOperators.Group.Finset.Defs

/-!
# ConservationInvariant — Divergence-Free Stress-Energy Contract

T66a invariant slot. Wraps the "∇·T = 0" content from the doc's "Conservation
Constraint" item.

The structure here keeps the contract scalar-valued so the slot remains
reusable across very different physics (Minkowski-vacuum stress-energy is
identically zero; VML stress-energy carries Lyapunov decrease; EM stress-
energy obeys the Maxwell stress tensor's divergence law). Discrete
divergence is encoded as a finite sum that the adapter must bring to
zero. Adapters with a continuum stress tensor would refine `divergence` to
a derivative-and-integral form when more Mathlib infrastructure is wired in.

This is an **opt-in** invariant: a `TemporalFramework` may or may not
provide a witness; the unified validator records the coverage.
-/

set_option autoImplicit false

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId

namespace CATEPTMain.Temporal

/-- Divergence-free stress-energy contract for a `TemporalFramework`. -/
structure ConservationInvariant (T : TemporalFramework) where
  /-- Discrete stress-energy "components" indexed by `(μ, ν) : Fin 4 × Fin 4`,
      attached to each configuration. Real-valued for kernel-cleanness. -/
  stressEnergy : T.Config → Fin 4 → Fin 4 → ℝ
  /-- Discrete divergence of the stress-energy at a configuration along a
      free index `ν`: `∑_μ stressEnergy(cfg, μ, ν)`.

      Concrete domains (e.g. continuum field theories) refine this to an
      actual `∂_μ T^{μν}` once the smooth-section infrastructure is available;
      at the spine level we only need the algebraic vanishing. -/
  divergence : T.Config → Fin 4 → ℝ :=
    fun cfg ν => ∑ μ : Fin 4, stressEnergy cfg μ ν
  /-- The conservation law: divergence vanishes identically. -/
  divergence_free : ∀ (cfg : T.Config) (ν : Fin 4), divergence cfg ν = 0

/-- A `ConservationInvariant` certifies the named CATEPT physical assumption. -/
theorem ConservationInvariant.is_assumption {T : TemporalFramework}
    (C : ConservationInvariant T) :
    CATEPTAssumption conservationStressEnergy
      (∀ (cfg : T.Config) (ν : Fin 4), C.divergence cfg ν = 0) :=
  C.divergence_free

/-- Vacuum-tier conservation: any framework can claim a trivial vacuum
    stress-energy that is identically zero, hence trivially divergence-free.
    Adapters with non-trivial physics override this with their own stress-
    energy and prove the conservation law as content. -/
def TemporalFramework.vacuumConservation (T : TemporalFramework) :
    ConservationInvariant T where
  stressEnergy := fun _ _ _ => 0
  divergence_free := by
    intro cfg ν
    simp [ConservationInvariant.divergence]

end CATEPTMain.Temporal
