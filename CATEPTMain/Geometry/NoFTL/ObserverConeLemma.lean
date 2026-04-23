import CATEPTMain.Geometry.NoFTL.Proposition3

/-!
# ObserverConeLemma — Observed Cone Equals Regular Cone

If `A` is an affine approximation to `wvt m k` at `x` and `m` sees `k`
at `x`, then the cone of `k` at `A(x)` equals the regular cone at `A(x)`.

Isabelle: `class ObserverConeLemma = Proposition3`.
-/

set_option autoImplicit false

namespace NoFTL.ObserverConeLemma

open NoFTL.Points NoFTL.Functions NoFTL.Affine
open NoFTL.WorldView NoFTL.Cones

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxDiff.AxDiff B Q] [NoFTL.AxSelfMinus.AxSelfMinus B Q]
variable [NoFTL.AxLightMinus B Q] [NoFTL.AxEventMinus.AxEventMinus B Q]

/-- If `A` approximates `wvt m k` at `x` and `m` sees `k` at `x`,
    then `coneSet k (A x) = regularConeSet (A x)`. -/
theorem lemConeOfObserved (m k : B) (x : Point Q)
    (A : Point Q → Point Q)
    (haff : affineApprox A (wvtFunc (Q := Q) m k) x)
    (hmk : WorldViewRel.W m k x) :
    coneSet k (A x) = regularConeSet (A x) := by
  sorry -- phase2: uses Proposition3 (52 lines in Isabelle)

end NoFTL.ObserverConeLemma
