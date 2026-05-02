/-
  T-T Phase 1: Time-integrated heat-semigroup ↔ entropic-proper-time.

  Composes T-S (`heatMode a t = exp(-(2 a) · t)`) with Mathlib's
  improper-integral library to read off the **integral identity**

      ∫_{0}^{∞}  heatMode a t  dt   =   τ(a)            (= 1/(2 a))

  for `a > 0`. Combined with T-S's pointwise initial-decay identity
  (`∂_t heatMode a |_{t=0} = -1/τ(a)`), this gives the two complementary
  semigroup readings of the entropic proper time:

      τ(a)  is the inverse heat-decay rate at t=0       (T-S)
      τ(a)  is the total time-integral of the heat mode (T-T, this file)

  The latter is the standard Laplace-transform reading of the propagator
  as the time-integral of the semigroup against a unit source: a
  Gaussian mode of action coefficient `a` has entropic proper time
  equal to its heat-semigroup `L¹` norm on `[0, ∞)`.

  One honest theorem:

    * `heatMode_integral_eq_entropicProperTime`
        ∫ t in Ioi 0, heatMode a t  =  τ(a),  for `a > 0`.

  Proof sketch: change of variable `u := (2 a) · t` reduces to the
  Mathlib lemma `integral_exp_neg_Ioi_zero : ∫ Ioi 0, exp(-x) = 1`.
-/

import CATEPTMain.Integration.HeatSemigroupEntropicTime
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Integral.IntegralEqImproper

set_option autoImplicit false

namespace CATEPTMain.Integration.HeatIntegralEntropicTime

open CATEPTMain.Integration.PropagatorEntropicTime
open CATEPTMain.Integration.HeatSemigroupEntropicTime
open MeasureTheory Set

noncomputable section

/-- **Time-integrated heat-semigroup equals entropic proper time**
    (T-T Phase 1).

    For a Gaussian mode of action coefficient `a > 0`, the time-integral
    of `heatMode a t = exp(-(2 a) · t)` over the positive ray equals the
    entropic-proper-time scale `τ(a) = 1/(2 a)` of that mode:

        ∫ t in Ioi 0,  heatMode a t  dt   =   τ(a).

    Proof: change of variable `u := (2 a) · t` via
    `integral_comp_mul_left_Ioi`, then `integral_exp_neg_Ioi_zero`. -/
theorem heatMode_integral_eq_entropicProperTime (a : ℝ) (ha : 0 < a) :
    (∫ t in Ioi (0 : ℝ), heatMode a t) = entropicProperTime a := by
  have h2a : (0 : ℝ) < 2 * a := by positivity
  have h2a_ne : (2 * a) ≠ 0 := ne_of_gt h2a
  -- Step 1: rewrite the integrand pointwise as exp(-((2 a) · t)).
  have hfun : ∀ t : ℝ, heatMode a t = Real.exp (-((2 * a) * t)) := by
    intro t; simp [heatMode, neg_mul]
  -- Step 2: apply change of variables u := (2 a) · t.
  have hchange :
      (∫ t in Ioi (0 : ℝ), Real.exp (-((2 * a) * t)))
        = (2 * a)⁻¹ • ∫ x in Ioi (0 : ℝ), Real.exp (-x) := by
    have := integral_comp_mul_left_Ioi (fun y : ℝ => Real.exp (-y)) (0 : ℝ) h2a
    simpa using this
  -- Step 3: combine and evaluate.
  calc (∫ t in Ioi (0 : ℝ), heatMode a t)
      = ∫ t in Ioi (0 : ℝ), Real.exp (-((2 * a) * t)) := by
            simp_rw [hfun]
    _ = (2 * a)⁻¹ • ∫ x in Ioi (0 : ℝ), Real.exp (-x) := hchange
    _ = (2 * a)⁻¹ * 1 := by rw [integral_exp_neg_Ioi_zero]; rfl
    _ = entropicProperTime a := by
            simp [entropicProperTime, one_div, mul_one]

end

end CATEPTMain.Integration.HeatIntegralEntropicTime
