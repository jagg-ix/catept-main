import CATEPTMain.NoFTL.Proposition1
import CATEPTMain.NoFTL.Proposition2
import CATEPTMain.NoFTL.AxEventMinus

/-!
# Proposition 3 — Full Cone Mapping Under Worldview Transformation

Combines Propositions 1 and 2 with AxEventMinus to show that if `m`
sees `k` at `x`, then there exist an affine approximation `A` and a
point `y` such that: `wvt m k x y`, `A` approximates `wvt m k` at `x`,
the image of `coneSet m x` under `A` is contained in `coneSet k y`,
and `coneSet k y = regularConeSet y`.

Isabelle: `class Proposition3 = Proposition1 + Proposition2 + AxEventMinus`.
-/

set_option autoImplicit false

namespace NoFTL.Proposition3

open NoFTL.Points NoFTL.Functions NoFTL.Affine
open NoFTL.WorldView NoFTL.WorldLine NoFTL.Cones

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxDiff.AxDiff B Q] [NoFTL.AxSelfMinus.AxSelfMinus B Q]
variable [NoFTL.AxLightMinus B Q] [NoFTL.AxEventMinus.AxEventMinus B Q]

/-- Proposition 3: if `m` sees `k` at `x`, the worldview transformation
    maps cones to regular cones. -/
theorem lemProposition3 (m k : B) (x : Point Q)
    (hmk : WorldViewRel.W m k x) :
    ∃ A : Point Q → Point Q, ∃ y : Point Q,
      wvtFunc (Q := Q) m k x y ∧
      affineApprox A (wvtFunc (Q := Q) m k) x ∧
      applyToSet (asFunc A) (coneSet m x) ⊆ coneSet k y ∧
      coneSet k y = regularConeSet y := by
  sorry -- phase2: uses Prop1 + Prop2 + AxEventMinus (77 lines in Isabelle)

end NoFTL.Proposition3
