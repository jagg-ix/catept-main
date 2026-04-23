import CATEPTMain.Geometry.NoFTL.ObserverConeLemma
import CATEPTMain.Geometry.NoFTL.AffineConeLemma

/-!
# NoFTLGR — No Faster-Than-Light Observers in General Relativity

The main theorem of the AFP entry `No_FTL_observers_Gen_Rel`. It states:
if observer `m` encounters observer `k` (both present at the same spacetime
point `x`), then `k` is moving at sub-light speed relative to `m`. In other
words, no observer ever encounters another observer who appears to be moving
at or above lightspeed.

This is the crown theorem of the formalization, combining all axioms:
AxEField, AxSelfMinus, AxEventMinus, AxDiff, AxLightMinus, and
AxTriangleInequality.

Isabelle: `class NoFTLGR = ObserverConeLemma + AffineConeLemma`.
-/

set_option autoImplicit false

namespace NoFTL.NoFTLGR

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Affine NoFTL.Vectors
open NoFTL.WorldView NoFTL.WorldLine NoFTL.TangentLines NoFTL.Cones
open NoFTL.Classification

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]
variable [NoFTL.AxDiff.AxDiff B Q] [NoFTL.AxSelfMinus.AxSelfMinus B Q]
variable [NoFTL.AxLightMinus B Q] [NoFTL.AxEventMinus.AxEventMinus B Q]

/-- **No FTL Observers in General Relativity**: if observer `m` encounters
    observer `k` at spacetime point `x` (both see each other there), and `l`
    is a tangent line to `k`'s worldline as seen by `m` at `x`, with velocity
    `v`, then `l` has finite slope and `sNorm2 v < 1` — i.e., `k` is moving
    at sub-light speed relative to `m`. -/
theorem lemNoFTLGR (m k : B) (x : Point Q) (l : Set (Point Q)) (v : Space Q)
    (hx : x ∈ wline (Q := Q) m m ∧ x ∈ wline (Q := Q) m k)
    (htl : tl l m k x)
    (hv : v ∈ lineVelocity l)
    (hne : ∃ p, p ≠ x ∧ p ∈ l) :
    lineSlopeFinite l ∧ sNorm2 v < 1 := by
  sorry -- phase2: the crown theorem (489 lines in Isabelle)
  -- Proof outline:
  -- 1. Use AxEventMinus to get y = wvt(m,k)(x)
  -- 2. Use AxDiff to get affine approximation A
  -- 3. Show A maps l to l' = A(l)
  -- 4. Use lemTangentLines to show l' tangent to wline k k at y
  -- 5. Use lemSelfTangentIsTimeAxis: l' = timeAxis
  -- 6. Use lemProposition1 + lemConeOfObserved: coneSet k y = regularConeSet y
  -- 7. Use lemInsideRegularConeUnderAffInvertible: A preserves cone interior
  -- 8. Conclude: l has finite slope and sNorm2 v < 1

end NoFTL.NoFTLGR
