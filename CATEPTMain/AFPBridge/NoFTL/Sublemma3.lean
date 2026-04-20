import CATEPTMain.AFPBridge.NoFTL.WorldLine
import CATEPTMain.AFPBridge.NoFTL.AxTriangleInequality
import CATEPTMain.AFPBridge.NoFTL.TangentLines

/-!
# Sublemma3 — Tangent Line Approximation

Establishes how closely tangent lines approximate worldlines: if `p` is a
unit-norm point on a tangent line `l` to a worldline `wl` at the origin,
then for any `ε > 0` there exists `δ > 0` such that every `y ∈ wl` within
`δ` of the origin has `(1/‖y‖)·y` or `(-1/‖y‖)·y` within `ε` of `p`.

Isabelle: `class Sublemma3 = WorldLine + AxTriangleInequality + TangentLines`.
-/

set_option autoImplicit false

namespace NoFTL.Sublemma3

open NoFTL.Points NoFTL.Sorts NoFTL.Norms NoFTL.Functions
open NoFTL.WorldView NoFTL.WorldLine NoFTL.TangentLines

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q]

/-- Sublemma 3 (origin version): if `p` is on a tangent line `l` to `wl` at
    the origin and `norm2 p = 1`, then nearby points on `wl` (normalized)
    cluster near `±p`. -/
theorem sublemma3 (p : Point Q) (l wl : Set (Point Q))
    (hp : onLine p l) (hnorm : norm2 p = 1)
    (htl : tangentLine l wl origin) :
    ∀ ε > 0, ∃ δ > 0, ∀ y : Point Q, ∀ ny : Q,
      (inBall y δ origin ∧ y ≠ origin ∧ y ∈ wl ∧ norm y = ny) →
        (inBall ((1/ny) ⊗ y) ε p ∨ inBall ((-1/ny) ⊗ y) ε p) := by
  sorry -- phase2: long proof (300 lines in Isabelle)

/-- Sublemma 3 (translated version): generalization based at `x`
    instead of origin. -/
theorem sublemma3Translation (p x : Point Q) (l wl : Set (Point Q))
    (hp : onLine p l) (hnorm : norm2 (p ⊖ x) = 1)
    (htl : tangentLine l wl x) :
    ∀ ε > 0, ∃ δ > 0, ∀ y : Point Q, ∀ nyx : Q,
      (inBall y δ x ∧ y ≠ x ∧ y ∈ wl ∧ norm (y ⊖ x) = nyx) →
        (inBall ((1/nyx) ⊗ (y ⊖ x)) ε (p ⊖ x) ∨
         inBall ((-1/nyx) ⊗ (y ⊖ x)) ε (p ⊖ x)) := by
  sorry -- phase2: uses sublemma3 + translation argument

end NoFTL.Sublemma3
