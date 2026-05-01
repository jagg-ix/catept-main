/-
  T-I Phase 1: Schwinger source-shift bridge — leveraging FEYNCALC.

  This rung links the algebraic completion-of-the-square engine
  (`CATEPTMain.Integration.GaussianCompletion`, T-F Phase 1) with the
  scalar Schwinger / Laplace identity already proved inside the
  FeynCalc port living in the `catept-domain-gauge` sibling
  (`CATEPTMain.GaugeTheory.FEYNCALC.schwinger_parametrization`).

  The Schwinger trick is the second pillar of every Gaussian path
  integral: it rewrites a positive denominator as a Laplace transform,
  trading an algebraic inverse for an exponential proper-time
  integral.  Combined with completion of the square, it turns a
  source-shifted quadratic
        a·x²  -  b·x  +  b²/(4a)        =        a·(x − b/(2a))²
  into a one-dimensional Laplace integral with manifestly positive
  exponent — the Euclidean propagator at fixed external mode.

  Phase 1 ships three honest, kernel-only theorems:

    (1) `shiftedQuadratic_eq_completed`
        the algebraic identity `a·(x − b/(2a))² = a·x² − b·x + b²/(4a)`
        for `a ≠ 0`, recovered from `gaussianCompletion`.

    (2) `shiftedQuadratic_pos`
        positivity of the completed square away from the saddle,
        for `a > 0` and `x ≠ b/(2a)`.

    (3) `schwinger_for_shiftedQuadratic`
        the Schwinger / Laplace representation
            1 / (a·(x − b/(2a))²)
              = ∫_{(0,∞)} exp(−a·(x − b/(2a))² · t) dt
        obtained by feeding the completed-square positivity into
        FEYNCALC's `schwinger_parametrization`.

  Phase 2 (deferred): n-dimensional matrix Schwinger trick
        1 / det(A) = ∫_{(0,∞)^n} exp(−⟨k, A k⟩) dⁿk · const,
  source-coupled generating-functional reduction
        Z[J] / Z[0] = exp(½ Jᵀ A⁻¹ J)
  via Gaussian functional integration (waits for T-F Phase 2 +
  Mathlib's `MeasureTheory.integral_gaussian`).
-/
import CATEPTMain.Integration.GaussianCompletion
import CATEPTMain.GaugeTheory.FEYNCALC.SpinorPropagator
import Mathlib.MeasureTheory.Integral.Bochner.Set

set_option autoImplicit false

namespace CATEPTMain.Integration.SchwingerSourceShift

open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.GaugeTheory.FEYNCALC

noncomputable section

/-- The *completed-square quadratic* `a·(x − b/(2a))²`.

    This is the manifestly non-negative form of the source-shifted
    free-mode action that drives Schwinger parametrization. -/
def shiftedQuadratic (a b x : ℝ) : ℝ :=
  a * (x - completionShift a b) ^ 2

/-- **Algebraic identity**: the completed-square quadratic equals the
    canonical source-shifted form `a·x² − b·x + b²/(4a)` whenever
    `a ≠ 0`.

    This is the algebraic restatement of `gaussianCompletion` solved
    for the completed-square left-hand side. -/
theorem shiftedQuadratic_eq_completed
    (a b x : ℝ) (ha : a ≠ 0) :
    shiftedQuadratic a b x
      = a * x ^ 2 - b * x + completionResidual a b := by
  unfold shiftedQuadratic
  have h := gaussianCompletion a b x ha
  -- h : a * x^2 - b*x = a * (x - completionShift a b)^2 - completionResidual a b
  linarith

/-- **Positivity**: away from the saddle `x = b/(2a)`, the
    completed-square quadratic is strictly positive whenever `a > 0`. -/
theorem shiftedQuadratic_pos
    (a b x : ℝ) (ha : 0 < a) (hx : x ≠ completionShift a b) :
    0 < shiftedQuadratic a b x := by
  unfold shiftedQuadratic
  have hsq : 0 < (x - completionShift a b) ^ 2 := by
    have hne : x - completionShift a b ≠ 0 := sub_ne_zero.mpr hx
    positivity
  exact mul_pos ha hsq

/-- **Schwinger / Laplace representation of the completed-square
    propagator**: combining `shiftedQuadratic_pos` with the scalar
    Schwinger identity `∫₀^∞ e^{−α t} dt = 1/α` (proved in the
    FEYNCALC port as `schwinger_parametrization`), we obtain

        1 / (a·(x − b/(2a))²)
          = ∫_{(0,∞)} exp(−a·(x − b/(2a))² · t) dt

    valid for `a > 0` and `x` not at the saddle. -/
theorem schwinger_for_shiftedQuadratic
    (a b x : ℝ) (ha : 0 < a) (hx : x ≠ completionShift a b) :
    ∫ t in Set.Ioi (0 : ℝ),
        Real.exp (-(shiftedQuadratic a b x) * t)
      = 1 / shiftedQuadratic a b x :=
  schwinger_parametrization (shiftedQuadratic a b x)
    (shiftedQuadratic_pos a b x ha hx)

end

end CATEPTMain.Integration.SchwingerSourceShift
