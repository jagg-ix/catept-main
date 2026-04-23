import CATEPTMain.NoFTL.WorldLine
import CATEPTMain.NoFTL.TangentLines

/-!
# AxLightMinus — Light Signal Axiom

Asserts that if an observer sends out a light signal, then the speed of
the light signal is 1 according to the observer, and it is possible to
send out a light signal in any direction.

Isabelle: `class AxLightMinus = WorldLine + TangentLines`.
-/

set_option autoImplicit false
set_option linter.dupNamespace false

namespace NoFTL

open NoFTL.Points NoFTL.WorldView NoFTL.WorldLine NoFTL.TangentLines

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [WorldViewRel B Q] [BodySorts B]

/-- `axLightMinus m p`: if observer `m` sees itself at `p`, then for
    every line `l` and every velocity `v ∈ lineVelocity l`, a photon `ph`
    with `tangentLine l (wline m ph) p` exists iff `sNorm2 v = 1`. -/
def axLightMinus (m : B) (p : Point Q) : Prop :=
  WorldViewRel.W m m p →
    ∀ l, ∀ v ∈ lineVelocity l,
      (∃ ph, Ph ph ∧ tangentLine l (wline (Q := Q) m ph) p) ↔ sNorm2 v = 1

/-- AxLightMinus axiom class. -/
class AxLightMinus (B Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
    [WorldViewRel B Q] [BodySorts B] where
  axLightMinusAx : ∀ (m : B) (p : Point Q), NoFTL.axLightMinus m p

end NoFTL
