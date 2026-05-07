/-
  T-W Phase 1: Shifted heat-integral identity.

  Composes T-U (`heatMode a (s+t) = heatMode a s * heatMode a t`) with
  T-T (`∫ Ioi 0, heatMode a t = τ(a)`) to give the **shifted** heat-
  integral identity:

      ∫_{0}^{∞}  heatMode a (s + t)  dt    =    heatMode a s  ·  τ(a)
                                                       (for `a > 0`).

  Reading: starting the heat semigroup at "phase" `s` and integrating
  forward in `t` gives the original `τ(a)` discounted by the semigroup
  factor `heatMode a s = exp(-(2 a) s)`. This is the elementary
  Markov-property / time-shift identity for the diagonal OU mode and
  the bridge between T-T (s=0 case) and the W[J] generating
  functional with a delayed source.

  One honest theorem:

    * `heatMode_shifted_integral`
        a > 0  ==>  ∫ Ioi 0, heatMode a (s + t) dt
                       = heatMode a s * τ(a).

  Proof: rewrite the integrand pointwise via T-U, pull `heatMode a s`
  out as a constant scalar, apply T-T.
-/

import CATEPTMain.Integration.HeatIntegralEntropicTime
import CATEPTMain.Integration.HeatSemigroupLaw

set_option autoImplicit false

namespace CATEPTMain.Integration.ShiftedHeatIntegral

open CATEPTMain.Integration.PropagatorEntropicTime
open CATEPTMain.Integration.HeatSemigroupEntropicTime
open CATEPTMain.Integration.HeatIntegralEntropicTime
open CATEPTMain.Integration.HeatSemigroupLaw
open MeasureTheory Set

noncomputable section

/-- **Shifted heat-integral identity** (T-W Phase 1).

    For a Gaussian mode of action coefficient `a > 0` and a phase `s`,

        ∫ t in Ioi 0,  heatMode a (s + t)  dt   =   heatMode a s · τ(a).

    Combines T-U (composition law) with T-T (L¹ integral). At `s = 0`
    this reduces to T-T via `heatMode_zero`. -/
theorem heatMode_shifted_integral (a : ℝ) (ha : 0 < a) (s : ℝ) :
    (∫ t in Ioi (0 : ℝ), heatMode a (s + t))
      = heatMode a s * entropicProperTime a := by
  have hpoint : ∀ t : ℝ, heatMode a (s + t) = heatMode a s * heatMode a t :=
    fun t => heatMode_semigroup a s t
  calc (∫ t in Ioi (0 : ℝ), heatMode a (s + t))
      = ∫ t in Ioi (0 : ℝ), heatMode a s * heatMode a t := by
            simp_rw [hpoint]
    _ = heatMode a s * ∫ t in Ioi (0 : ℝ), heatMode a t := by
            rw [MeasureTheory.integral_const_mul]
    _ = heatMode a s * entropicProperTime a := by
            rw [heatMode_integral_eq_entropicProperTime a ha]

end

end CATEPTMain.Integration.ShiftedHeatIntegral
