import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Core.Assumptions

/-!
# ReductionInvariant — Classical-Limit Contract

T66b invariant slot. Wraps the "Reduction Constraint" item from the doc:
the framework's classical limit must reproduce a documented classical
target.

Stated purely in terms of a real-valued projection so the contract is
kernel-clean (no QFT machinery pulled in). Concrete physics (EM, kinetic,
gauge) refine `classicalProjection` to the documented expansion target.
-/

set_option autoImplicit false

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId

namespace CATEPTMain.Temporal

/-- Classical-limit contract for a `TemporalFramework`. -/
structure ReductionInvariant (T : TemporalFramework) where
  /-- The classical-limit projection of the configuration. -/
  classicalProjection : T.Config → ℝ
  /-- The documented classical target (e.g. an Einstein-Hilbert + Maxwell
      action density at the configuration). -/
  target : T.Config → ℝ
  /-- The reduction equality: pointwise the projection equals the target. -/
  reduces_classically : ∀ x, classicalProjection x = target x

/-- A `ReductionInvariant` certifies the named CATEPT physical assumption. -/
theorem ReductionInvariant.is_assumption {T : TemporalFramework}
    (R : ReductionInvariant T) :
    CATEPTAssumption reductionToClassical
      (∀ x, R.classicalProjection x = R.target x) :=
  R.reduces_classically

/-- Vacuum-tier reduction: any framework can claim a trivial reduction
    where projection and target are both the zero functional. Adapters with
    non-trivial dynamics override with their actual classical limit. -/
def TemporalFramework.vacuumReduction (T : TemporalFramework) :
    ReductionInvariant T where
  classicalProjection := fun _ => 0
  target := fun _ => 0
  reduces_classically := fun _ => rfl

end CATEPTMain.Temporal
