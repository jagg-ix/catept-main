import CATEPTMain.Geometry.NoFTL.KeyLemma
import CATEPTMain.Geometry.NoFTL.TangentLineLemma
import CATEPTMain.Geometry.NoFTL.Cardinalities

/-!
# AffineConeLemma — Affine Invertible Maps Preserve Cone Interior

Shows that affine invertible maps preserve the inside of regular cones.
If `A` is affine invertible and `p` is inside the regular cone at `x`,
then `A(p)` is inside the regular cone at `A(x)`.

Isabelle: `class AffineConeLemma = KeyLemma + TangentLineLemma + Cardinalities`.
-/

set_option autoImplicit false

namespace NoFTL.AffineConeLemma

open NoFTL.Points NoFTL.Functions NoFTL.Affine
open NoFTL.Classification NoFTL.Cones NoFTL.WorldView

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxDiff.AxDiff B Q] [NoFTL.AxSelfMinus.AxSelfMinus B Q]

/-- The inverse of an affine invertible map is also affine invertible. -/
theorem lemInverseOfAffInvertibleIsAffInvertible
    (A A' : Point Q → Point Q)
    (hA : affInvertible A)
    (hinv : ∀ x y, A x = y ↔ A' y = x) :
    affInvertible A' := by
  sorry -- phase2

/-- An affine invertible map preserves the inside of a regular cone,
    provided it maps the cone set correctly. -/
theorem lemInsideRegularConeUnderAffInvertible
    (A : Point Q → Point Q) (x p : Point Q)
    (hA : affInvertible A)
    (hin : insideRegularCone x p)
    (hcone : regularConeSet (A x) = applyToSet (asFunc A) (regularConeSet x)) :
    insideRegularCone (A x) (A p) := by
  sorry -- phase2: uses KeyLemma + Cardinalities (335 lines in Isabelle)

end NoFTL.AffineConeLemma
