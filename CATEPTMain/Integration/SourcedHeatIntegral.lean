/-
  T-V Phase 1: Sourced heat-integral identity.

  Wraps T-T (`∫ Ioi 0, heatMode a t = τ(a)`) with two small honest
  ingredients that connect the heat-semigroup track to the W[J]
  generating-functional / sourced-Gaussian track:

    * `heatMode_pos`           : 0 < heatMode a t (no positivity on `a`).
    * `heatMode_integral_smul_source`
                               : for `a > 0`, `J : ℝ`,
                                 ∫ Ioi 0, J · heatMode a t  =  J · τ(a).

  The first records that the heat mode is everywhere strictly positive,
  so it is a legitimate integration kernel against any real source `J`.
  The second is the linear-in-source reading of T-T: the *sourced* time
  integral of the heat mode equals the source times the entropic proper
  time, i.e. the propagator absorbs a constant source by exactly the
  scale `τ(a)`. This is the elementary 0-dimensional shadow of

      ∫_{0}^{∞}  J(t) · S_t  dt    =    J · G        (constant J)

  appearing under the W[J] expansion of a Gaussian mode.

  Pure pull-out of a real scalar from a Mathlib `MeasureTheory.integral`;
  no new analytic content beyond T-T.
-/

import CATEPTMain.Integration.HeatIntegralEntropicTime

set_option autoImplicit false

namespace CATEPTMain.Integration.SourcedHeatIntegral

open CATEPTMain.Integration.PropagatorEntropicTime
open CATEPTMain.Integration.HeatSemigroupEntropicTime
open CATEPTMain.Integration.HeatIntegralEntropicTime
open MeasureTheory Set

noncomputable section

/-- **Heat-mode positivity** (T-V Phase 1).

    `heatMode a t = exp(-(2 a) · t) > 0` for all real `a, t`. This is
    immediate from `Real.exp_pos`; it does *not* require `0 < a`. -/
theorem heatMode_pos (a t : ℝ) : 0 < heatMode a t := by
  unfold heatMode
  exact Real.exp_pos _

/-- **Sourced heat-integral identity** (T-V Phase 1).

    For a Gaussian mode of action coefficient `a > 0` and a constant
    real source `J`, the time-integral of the *sourced* heat mode over
    the positive ray equals the source times the entropic proper time:

        ∫ t in Ioi 0,  J · heatMode a t  dt   =   J · τ(a).

    This is the linear-in-source reading of T-T; pulling `J` out of
    the integral and applying `heatMode_integral_eq_entropicProperTime`. -/
theorem heatMode_integral_smul_source (a : ℝ) (ha : 0 < a) (J : ℝ) :
    (∫ t in Ioi (0 : ℝ), J * heatMode a t)
      = J * entropicProperTime a := by
  rw [MeasureTheory.integral_const_mul,
      heatMode_integral_eq_entropicProperTime a ha]

end

end CATEPTMain.Integration.SourcedHeatIntegral
