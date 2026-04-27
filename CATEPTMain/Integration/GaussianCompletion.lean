/-
  T-F Phase 1: Gaussian completion-of-the-square — algebraic engine.

  The single most-used identity in Gaussian path-integration:
        a·x²  -  b·x  =  a·(x  -  b/(2a))²  -  b²/(4a).

  Every Gaussian functional integral, every Z[J] source-coupling
  evaluation, every Mehler kernel manipulation, and every saddle-point
  expansion ultimately reduces to this one purely algebraic move:
  shift the integration variable by b/(2a) and absorb the linear term
  into a quadratic remainder b²/(4a).

  Phase 1 ships three honest, kernel-only identities:

    (1) the completion identity itself,
    (2) the b = 0 reduction (no source ⇒ no remainder),
    (3) the shift law: under x ↦ x + b/(2a) the linear term vanishes.

  Phase 2 (deferred): ∫_ℝ exp(-(a·x² - b·x)) dx = √(π/a) · exp(b²/(4a))
  with the actual Gaussian-integral lemma from Mathlib's
  `Mathlib.Analysis.SpecialFunctions.Gaussian`, plus the n-dimensional
  matrix version  exp(½ J^T A^{-1} J) · √(det(2π A^{-1})).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

set_option autoImplicit false

namespace CATEPTMain.Integration.GaussianCompletion

noncomputable section

/-- The completion-of-the-square shift: for a quadratic-plus-linear
    `a·x² - b·x`, the unique value that kills the linear term is
    `b/(2a)`. -/
def completionShift (a b : ℝ) : ℝ := b / (2 * a)

/-- The constant residual after completing the square: `b²/(4a)`. -/
def completionResidual (a b : ℝ) : ℝ := b ^ 2 / (4 * a)

/-- Completion-of-the-square: for `a ≠ 0`,
    `a·x² - b·x = a·(x - b/(2a))² - b²/(4a)`.

    Algebraic engine of every Gaussian path integral. -/
theorem gaussianCompletion
    (a b x : ℝ) (_ha : a ≠ 0) :
    a * x ^ 2 - b * x
      = a * (x - completionShift a b) ^ 2 - completionResidual a b := by
  unfold completionShift completionResidual
  field_simp
  ring

/-- No source ⇒ no remainder: when `b = 0`, completing the square
    recovers the bare quadratic `a·x²` with zero shift and zero
    residual. -/
theorem gaussianCompletion_zero_source (a x : ℝ) :
    a * x ^ 2 - (0 : ℝ) * x
      = a * (x - completionShift a 0) ^ 2 - completionResidual a 0 := by
  unfold completionShift completionResidual
  ring

/-- Shift law: substituting `x ↦ y + b/(2a)` into the quadratic-plus-linear
    expression `a·x² - b·x` yields `a·y² - b²/(4a)` — i.e. the linear term
    vanishes and the quadratic gains the residual `-b²/(4a)`.
    This is the exact algebraic move performed inside every Gaussian
    integral when shifting the integration variable. -/
theorem gaussianCompletion_shift_eliminates_linear
    (a b y : ℝ) (_ha : a ≠ 0) :
    a * (y + completionShift a b) ^ 2 - b * (y + completionShift a b)
      = a * y ^ 2 - completionResidual a b := by
  unfold completionShift completionResidual
  field_simp
  ring

end

end CATEPTMain.Integration.GaussianCompletion
