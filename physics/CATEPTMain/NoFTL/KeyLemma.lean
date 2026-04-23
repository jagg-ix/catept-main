import CATEPTMain.NoFTL.Classification
import CATEPTMain.NoFTL.ReverseCauchySchwarz

/-!
# KeyLemma — Inside Regular Cone Implies Bounded Intersection

If `p` is inside the regular cone at `x`, then any line through `p`
(not through `x`) meets the cone in at most 2 points. This is the
key geometric lemma used in the affine cone lemma.

Isabelle: `class KeyLemma = Classification + ReverseCauchySchwarz`.
-/

set_option autoImplicit false

namespace NoFTL.KeyLemma

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Vectors
open NoFTL.Classification NoFTL.Cones NoFTL.TangentLines NoFTL.WorldView

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]

/-- If `p` is inside the regular cone at `x`, and `l` is a line through
    `p` with direction `D ≠ origin`, then `l ∩ regularConeSet x` has
    cardinality between 1 and 2 (inclusive). -/
theorem lemInsideRegularConeImplies (x p D : Point Q)
    (l : Set (Point Q))
    (hin : insideRegularCone x p)
    (hD : D ≠ origin)
    (hl : l = line p D) :
    0 < Set.ncard (l ∩ regularConeSet x) ∧
    Set.ncard (l ∩ regularConeSet x) ≤ 2 := by
  sorry -- phase2: long proof (300 lines in Isabelle)

end NoFTL.KeyLemma
