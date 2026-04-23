import CATEPTMain.NoFTL.WorldView

/-!
# AxSelfMinus — Self-observation Axiom

The worldline of an observer is a subset of the time axis in their own
worldview: if observer `m` sees itself at point `p`, then `p` lies on the
time axis.

Isabelle: `class AxSelfMinus = WorldView + assumes AxSelfMinus`.
-/

set_option autoImplicit false

namespace NoFTL.AxSelfMinus

open NoFTL.Points NoFTL.WorldView

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable {B : Type*} [WorldViewRel B Q]

/-- `axSelfMinus m p` asserts: if `m` sees itself at `p`, then `p` is on the
    time axis (spatial coordinates are zero). -/
def axSelfMinus (m : B) (p : Point Q) : Prop :=
  WorldViewRel.W m m p → onTimeAxis p

/-- AxSelfMinus: for every observer `m` and point `p`, `axSelfMinus m p` holds. -/
class AxSelfMinus (B : Type*) (Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
    [WorldViewRel B Q] where
  axSelfMinus : ∀ (m : B) (p : Point Q), NoFTL.AxSelfMinus.axSelfMinus m p

end NoFTL.AxSelfMinus
