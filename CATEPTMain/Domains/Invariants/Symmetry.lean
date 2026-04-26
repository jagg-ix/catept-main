import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Core.Assumptions

/-!
# SymmetryInvariant — Clock Invariance under a Non-Trivial Transformation

T66c invariant slot. The doc's "Symmetry Constraint" claims gauge + diffeo
invariance using the trivial scheme `gaugeInvariant eq U := eq = eq`. We
keep the equational content **non-trivial**: the symmetry transformation
must commute with the framework's clock.

This is a real claim (not a tautology): if `clock (sigma x) = clock x` for
all `x`, then the entropic time density is invariant under `sigma`. For
example: the kinetic clock `‖v‖²/(2T)` is invariant under reflection
`v ↦ -v`.
-/

set_option autoImplicit false

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId

namespace CATEPTMain.Temporal

/-- Clock-invariance contract for a `TemporalFramework` under a chosen
    symmetry transformation. -/
structure SymmetryInvariant (T : TemporalFramework) where
  /-- The symmetry transformation acting on the configuration. -/
  sigma : T.Config → T.Config
  /-- The clock is invariant under the symmetry. -/
  clock_invariant : ∀ x, T.clock (sigma x) = T.clock x

/-- A `SymmetryInvariant` certifies the named CATEPT physical assumption. -/
theorem SymmetryInvariant.is_assumption {T : TemporalFramework}
    (S : SymmetryInvariant T) :
    CATEPTAssumption symmetryClockInvariance
      (∀ x, T.clock (S.sigma x) = T.clock x) :=
  S.clock_invariant

/-- Vacuum-tier symmetry: identity is always a symmetry. Useful default
    for adapters that haven't yet identified a non-trivial symmetry of
    their clock. (Anti-vacuity caveat: this witness is a trivial symmetry;
    a real adapter SHOULD provide a genuine non-identity sigma.) -/
def TemporalFramework.identitySymmetry (T : TemporalFramework) :
    SymmetryInvariant T where
  sigma := id
  clock_invariant := fun _ => rfl

end CATEPTMain.Temporal
