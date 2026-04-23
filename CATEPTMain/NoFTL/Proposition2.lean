import CATEPTMain.NoFTL.TangentLineLemma

/-!
# Proposition 2 — Cone Image Under Worldview Transformation

If `A` is an affine approximation to `wvt m k` at `x`, then the image
of the cone of `m` at `x` under `A` is contained in the cone of `k`
at `A(x)`.

Isabelle: `class Proposition2 = TangentLineLemma`.
-/

set_option autoImplicit false

namespace NoFTL.Proposition2

open NoFTL.Points NoFTL.Functions NoFTL.Affine
open NoFTL.WorldView NoFTL.Cones

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxDiff.AxDiff B Q] [NoFTL.AxSelfMinus.AxSelfMinus B Q]

/-- Proposition 2: if `A` approximates `wvt m k` at `x`, then the image
    of `coneSet m x` under `A` is contained in `coneSet k (A x)`. -/
theorem lemProposition2 (m k : B) (x : Point Q) (A : Point Q → Point Q)
    (haff : affineApprox A (wvtFunc (Q := Q) m k) x) :
    applyToSet (asFunc A) (coneSet m x) ⊆ coneSet k (A x) := by
  sorry -- phase2: uses lemTangentLines (90 lines in Isabelle)

end NoFTL.Proposition2
