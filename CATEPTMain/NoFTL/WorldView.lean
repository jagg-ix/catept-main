import CATEPTMain.NoFTL.Points

/-!
# WorldView — Worldview Transformations

Defines the worldview relation `W : B → B → Point Q → Prop` ("m sees b at p")
and the worldview transformation `wvt`. This is the foundation for all
GenRel axioms.

Isabelle: `class WorldView = Points + fixes W`.
-/

set_option autoImplicit false

namespace NoFTL.WorldView

open NoFTL.Points

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

/-- The worldview relation, parameterized by a body type `B`.
    `W m b p` means "observer m sees body b at spacetime point p". -/
class WorldViewRel (B : Type*) (Q : Type*) [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q] where
  W : B → B → Point Q → Prop

variable {B : Type*} [WorldViewRel B Q]

/-- The event at point `p` according to observer `h`: the set of bodies seen there. -/
def ev (h : B) (x : Point Q) : Set B :=
  { b | WorldViewRel.W h b x }

/-- The worldview transformation: `wvt m k p` is the set of points `q` such that
    `m` sees some body at `p` and `ev m p = ev k q`. -/
def wvt (m k : B) (p : Point Q) : Set (Point Q) :=
  { q | (∃ b, WorldViewRel.W m b p) ∧ ev m p = ev k q }

/-- The worldview transformation as a relation. -/
def wvtFunc (m k : B) : Point Q → Point Q → Prop :=
  fun p q => q ∈ wvt m k p

/-- Image of a line under a worldview transformation. -/
def wvtLine (m k : B) (l l' : Set (Point Q)) : Prop :=
  ∃ p q p' q', wvtFunc m k p p' ∧ wvtFunc m k q q' ∧
    l = lineJoining p q ∧ l' = lineJoining p' q'

end NoFTL.WorldView
