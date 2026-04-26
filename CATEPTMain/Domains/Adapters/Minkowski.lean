import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.GR.Domain

/-!
# Minkowski Adapter — `TemporalFramework` instance for vacuum GR

Minkowski spacetime is the canonical **vacuum-reference** CAT/EPT
framework: the entropic clock is identically zero (no irreversibility in
the vacuum).

This adapter implements the kernel-tier `TemporalFramework` contract but
intentionally does NOT implement `LiveTemporalFramework` — the dynamics
are trivial by construction. That distinction is part of the contract's
honest taxonomy.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

/-- Minkowski as a vacuum-tier `TemporalFramework`. -/
def minkowski : TemporalFramework where
  Config := Fin 4 → ℝ
  clock := fun _ => 0
  clock_nonneg := fun _ => le_refl 0
  witness := fun _ => 0

/-- The Minkowski adapter's spine consistency follows from the universal
    coherence theorem — no per-domain proof needed. -/
theorem minkowski_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      minkowski.toCATEPTSlot :=
  minkowski.coherence_spine

end CATEPTMain.Temporal.Adapter
