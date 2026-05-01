/-
  T-K Phase 1: Shifted Gaussian integral — first analytic evaluation.

  This is the first ladder rung that actually *evaluates* a Gaussian
  integral over ℝ, leveraging Mathlib's `integral_gaussian`
  (`∫ exp(-b·x²) = √(π/b)`) plus the translation-invariance lemma
  `integral_sub_right_eq_self` to absorb the saddle shift `b/(2a)`
  produced by T-F Phase 1's completion-of-the-square.

  Phase 1 ships two honest, kernel-only theorems:

    (1) `integral_gaussian_shifted`
          ∫ exp(-a · (x - c)²) dx = √(π/a)         (any real shift c)
    (2) `integral_gaussian_at_completionShift`
          ∫ exp(-a · (x - completionShift a b)²) dx = √(π/a)
        (the shift is exactly the saddle of `a·x² - b·x`).

  Together with T-F Phase 1's algebraic identity, this is one
  `gaussianCompletion`-rewrite away from the full sourced evaluation
  ∫ exp(-(a·x² - b·x)) dx = √(π/a) · exp(b²/(4a)) — Phase 2 lifts the
  remaining `exp(b²/(4a))` constant out via `Real.exp_add` and
  `MeasureTheory.integral_const_mul`.
-/
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.MeasureTheory.Group.Measure
import CATEPTMain.Integration.GaussianCompletion

set_option autoImplicit false

namespace CATEPTMain.Integration.ShiftedGaussianIntegral

open MeasureTheory Real
open CATEPTMain.Integration.GaussianCompletion

noncomputable section

/-- Shifted Gaussian integral: for any real shift `c`,
    `∫ exp(-a · (x - c)²) dx = √(π/a)`.

    Pure translation invariance of Lebesgue measure on ℝ composed with
    Mathlib's `integral_gaussian`: shifting the integration variable by
    a constant leaves the integral unchanged. -/
theorem integral_gaussian_shifted (a c : ℝ) :
    ∫ x : ℝ, Real.exp (-a * (x - c) ^ 2) = Real.sqrt (Real.pi / a) := by
  have h := integral_sub_right_eq_self
    (μ := (volume : Measure ℝ))
    (fun x : ℝ => Real.exp (-a * x ^ 2)) c
  simpa using h.trans (integral_gaussian a)

/-- Specialisation at the saddle shift produced by T-F Phase 1's
    completion-of-the-square: with `c = completionShift a b = b/(2a)`,
    the shifted Gaussian still integrates to `√(π/a)`. This is the
    direct bridge to T-F Phase 1: any sourced quadratic `a·x² - b·x`
    becomes `a · (x - b/(2a))² - b²/(4a)`, and the `(x - b/(2a))²`
    piece integrates to exactly this value. -/
theorem integral_gaussian_at_completionShift (a b : ℝ) :
    ∫ x : ℝ, Real.exp (-a * (x - completionShift a b) ^ 2)
      = Real.sqrt (Real.pi / a) :=
  integral_gaussian_shifted a (completionShift a b)

end

end CATEPTMain.Integration.ShiftedGaussianIntegral
