import CATEPTMain.NoFTL.Affine
import CATEPTMain.NoFTL.AxTriangleInequality

/-!
# Sublemma4 — Affine Approximation Implies Continuity

Shows that functions with affine approximations are continuous where
approximated: if `A` is an affine approximation to `f` at `x`, then `f`
is defined in a neighborhood of `x` and is continuous at `x`.

Isabelle: `class Sublemma4 = Affine + AxTriangleInequality`.
-/

set_option autoImplicit false

namespace NoFTL.Sublemma4

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Affine

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

/-- Sublemma 4: if `A` is an affine approximation to `f` at `x`, then
    `f` is defined near `x` and is continuous at `x`. -/
theorem sublemma4 (A : Point Q → Point Q) (f : Point Q → Point Q → Prop) (x : Point Q)
    (happrox : affineApprox A f x) :
    (∃ δ > 0, ∀ p, inBall p δ x → definedAt f p) ∧ cts f x := by
  sorry -- phase2: long delta-epsilon proof (140 lines in Isabelle)

end NoFTL.Sublemma4
