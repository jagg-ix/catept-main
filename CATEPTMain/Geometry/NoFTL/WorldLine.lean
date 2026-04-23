import CATEPTMain.Geometry.NoFTL.WorldView
import CATEPTMain.Geometry.NoFTL.Functions

/-!
# WorldLine — Observer Worldlines

Defines worldlines and proves basic lemmas about worldlines under
worldview transformations.

Isabelle: `class WorldLine = WorldView + Functions`.
-/

set_option autoImplicit false

namespace NoFTL.WorldLine

open NoFTL.Points NoFTL.WorldView NoFTL.Functions

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable {B : Type*} [WorldViewRel B Q]

/-- The worldline of body `k` as seen by observer `m`: the set of points
    where `m` sees `k`. -/
def wline (m k : B) : Set (Point Q) :=
  { p | WorldViewRel.W m k p }

/-- The image of a worldline under a worldview transformation is contained
    in the target observer's worldline. -/
theorem lemWorldLineUnderWVT (m k b : B) :
    applyToSet (wvtFunc (Q := Q) m k) (wline m b) ⊆ wline k b := by
  intro q hq
  simp only [applyToSet, wline, Set.mem_setOf_eq] at hq ⊢
  obtain ⟨p, hp, hpq⟩ := hq
  simp only [wvtFunc, wvt, Set.mem_setOf_eq] at hpq
  obtain ⟨_, hev⟩ := hpq
  have : b ∈ ev m p := hp
  rw [hev] at this
  exact this

-- lemFiniteLineVelocityUnique: deferred until lineVelocity/lineSlopeFinite
-- are ported from Points.thy (phase2)

end NoFTL.WorldLine
