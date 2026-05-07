/-
  T-L Phase 1 (= T-K Phase 2 promoted): full sourced Gaussian integral
  evaluation.

  This is the capstone of T-F (algebraic completion-of-the-square),
  T-K Phase 1 (shifted Gaussian integral), and Mathlib's `integral_gaussian`:

      ∫ℝ  exp(-(a·x² - b·x)) dx  =  √(π/a) · exp(b²/(4a))                (*)

  Derivation in three honest moves:

    1. Algebra (T-F Phase 1 `gaussianCompletion`):
            a·x² - b·x  =  a·(x - b/(2a))² - b²/(4a)
       ⇒  -(a·x² - b·x) = -a·(x - b/(2a))² + b²/(4a)
       ⇒   exp(...)     = exp(b²/(4a)) · exp(-a·(x - b/(2a))²)

    2. Linearity (Mathlib `MeasureTheory.integral_const_mul`):
            ∫ exp(b²/(4a)) · exp(-a·(x-shift)²) dx
              = exp(b²/(4a)) · ∫ exp(-a·(x-shift)²) dx

    3. Shifted Gaussian (T-K Phase 1 `integral_gaussian_shifted`):
            ∫ exp(-a·(x-shift)²) dx  =  √(π/a).

  Phase 1 ships two honest, kernel-only theorems:

    * `integral_sourced_gaussian`              the identity (*) verbatim
    * `integral_sourced_gaussian_zero_source`  b = 0 reduction (residual = 1)
-/
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import CATEPTMain.Integration.GaussianCompletion
import CATEPTMain.Integration.ShiftedGaussianIntegral

set_option autoImplicit false

namespace CATEPTMain.Integration.SourcedGaussianIntegral

open MeasureTheory Real
open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.Integration.ShiftedGaussianIntegral

noncomputable section

/-- Pointwise rewrite: for `a ≠ 0`, applying T-F Phase 1's
    `gaussianCompletion` inside `Real.exp` factors the sourced
    Gaussian density as a constant times a shifted Gaussian density. -/
theorem exp_sourced_eq_const_mul_shifted
    (a b : ℝ) (ha : a ≠ 0) (x : ℝ) :
    Real.exp (-(a * x ^ 2 - b * x))
      = Real.exp (completionResidual a b)
          * Real.exp (-a * (x - completionShift a b) ^ 2) := by
  have hcomp := gaussianCompletion a b x ha
  -- a·x² - b·x = a·(x - shift)² - residual
  -- ⇒ -(a·x² - b·x) = residual + (-a·(x - shift)²)
  have hrw :
      -(a * x ^ 2 - b * x)
        = completionResidual a b + (-a * (x - completionShift a b) ^ 2) := by
    have : a * x ^ 2 - b * x
            = a * (x - completionShift a b) ^ 2 - completionResidual a b := hcomp
    linarith
  rw [hrw, Real.exp_add]

/-- **Sourced Gaussian integral evaluation** (T-L Phase 1).
    For `a ≠ 0`,
        ∫ℝ exp(-(a·x² - b·x)) dx = exp(b²/(4a)) · √(π/a).

    Composition of T-F Phase 1 (algebraic completion of the square),
    T-K Phase 1 (shifted Gaussian integral), and Mathlib's
    `integral_const_mul`. -/
theorem integral_sourced_gaussian (a b : ℝ) (ha : a ≠ 0) :
    ∫ x : ℝ, Real.exp (-(a * x ^ 2 - b * x))
      = Real.exp (completionResidual a b) * Real.sqrt (Real.pi / a) := by
  -- Step 1: rewrite the integrand pointwise as a constant times a shifted Gaussian.
  have hpt : (fun x : ℝ => Real.exp (-(a * x ^ 2 - b * x)))
              = (fun x : ℝ =>
                  Real.exp (completionResidual a b)
                    * Real.exp (-a * (x - completionShift a b) ^ 2)) := by
    funext x
    exact exp_sourced_eq_const_mul_shifted a b ha x
  rw [hpt]
  -- Step 2: pull out the constant.
  rw [MeasureTheory.integral_const_mul]
  -- Step 3: evaluate the shifted Gaussian via T-K Phase 1.
  rw [integral_gaussian_shifted a (completionShift a b)]

/-- **Zero-source reduction**: when `b = 0`, the residual `b²/(4a)`
    vanishes and (*) collapses to the bare Mathlib evaluation
    `∫ exp(-a·x²) dx = √(π/a)`. -/
theorem integral_sourced_gaussian_zero_source (a : ℝ) (ha : a ≠ 0) :
    ∫ x : ℝ, Real.exp (-(a * x ^ 2 - (0 : ℝ) * x))
      = Real.sqrt (Real.pi / a) := by
  have h := integral_sourced_gaussian a 0 ha
  unfold completionResidual at h
  simp at h
  convert h using 2
  ring

end

end CATEPTMain.Integration.SourcedGaussianIntegral
