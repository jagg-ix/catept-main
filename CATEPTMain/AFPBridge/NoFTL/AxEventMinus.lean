import CATEPTMain.AFPBridge.NoFTL.WorldView

/-!
# AxEventMinus — Event-observation Axiom

An observer encounters the events in which they are observed: if `m` sees
`k` at `p`, then there exists a point `q` such that `ev m p = ev k q`.

Isabelle: `class AxEventMinus = WorldView + assumes AxEventMinus`.
-/

set_option autoImplicit false

namespace NoFTL.AxEventMinus

open NoFTL.Points NoFTL.WorldView

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable {B : Type*} [WorldViewRel B Q]

/-- `axEventMinus m k p` asserts: if `m` sees `k` at `p`, then there exists `q`
    such that every body `b` is seen by `m` at `p` iff it is seen by `k` at `q`. -/
def axEventMinus (m k : B) (p : Point Q) : Prop :=
  WorldViewRel.W m k p → ∃ q : Point Q, ∀ b, (WorldViewRel.W m b p ↔ WorldViewRel.W k b q)

/-- AxEventMinus: for all observers `m`, `k` and all points `p`,
    `axEventMinus m k p` holds. -/
class AxEventMinus (B : Type*) (Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
    [WorldViewRel B Q] where
  axEventMinus : ∀ (m k : B) (p : Point Q), NoFTL.AxEventMinus.axEventMinus m k p

end NoFTL.AxEventMinus
