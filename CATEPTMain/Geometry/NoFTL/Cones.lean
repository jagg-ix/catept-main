import CATEPTMain.Geometry.NoFTL.WorldLine
import CATEPTMain.Geometry.NoFTL.TangentLines

/-!
# Cones — Lightcones and Regular Cones

Defines (light)cones, regular cones, and their set-valued forms.
The cone of a body at a point comprises the set of points that lie on
tangent lines of photons emitted by the body at that point.

Isabelle: `class Cones = WorldLine + TangentLines`.
-/

set_option autoImplicit false

namespace NoFTL.Cones

open NoFTL.Points NoFTL.WorldView NoFTL.WorldLine NoFTL.TangentLines

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [WorldViewRel B Q] [BodySorts B]

/-- `tl l m b x` means `l` is a tangent line to the worldline of `b`
    as seen by `m`, at the point `x`. -/
def tl (l : Set (Point Q)) (m b : B) (x : Point Q) : Prop :=
  tangentLine l (wline (Q := Q) m b) x

/-- `cone m x p` means `p` lies on the cone of observer `m` at point `x`:
    there exists a line through both `x` and `p` that is tangent to some
    photon's worldline at `x`. -/
def cone (m : B) (x p : Point Q) : Prop :=
  ∃ l, onLine p l ∧ onLine x l ∧ ∃ ph, Ph ph ∧ tl l m ph x

/-- `regularCone x p` means `p` lies on the regular cone at `x`:
    there exists a line through both `x` and `p` with unit-speed velocity. -/
def regularCone (x p : Point Q) : Prop :=
  ∃ l, onLine p l ∧ onLine x l ∧ ∃ v ∈ lineVelocity l, sNorm2 v = 1

/-- The set of all points on the cone of `m` at `x`. -/
def coneSet (m : B) (x : Point Q) : Set (Point Q) :=
  { p | cone m x p }

/-- The set of all points on the regular cone at `x`. -/
def regularConeSet (x : Point Q) : Set (Point Q) :=
  { p | regularCone x p }

end NoFTL.Cones
