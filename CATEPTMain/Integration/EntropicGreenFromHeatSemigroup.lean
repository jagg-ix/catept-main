import CATEPTMain.Integration.HeatSemigroupEntropicTime
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Integral.IntegralEqImproper

/-!
# Entropic Green Function from the Heat Semigroup (Step 4)

Step 4 of the user's Green-function-bridge ladder:

> Connect heat semigroup to Green/covariance.  Use the gaussian-field
> model: Green function as `∫₀^∞ heat kernel dt`.  This should become
> the CAT/EPT "Green = integrated entropic heat semigroup" bridge.

This module ships the **headline identity** at the spectral / Gaussian-
mode level.  For a Gaussian mode of action coefficient `a > 0`, the
heat-semigroup mode `heatMode a t = exp(-(2 a) · t)` integrates over
`t ∈ (0, ∞)` to the entropic proper time:

  `∫₀^∞ exp(-(2 a) · t) dt = 1 / (2 a) = τ(a) = G(a)`.

The integral is a *Green function* in the cylinder-model sense: the
covariance / static propagator obtained by integrating the heat
semigroup over all positive times.  The catept identification

  `Green = covariance = entropicProperTime`

is therefore a proved theorem, not a structural placeholder.

## What is honestly proven

* `heatMode_integral_Ioi_eq_inv_two_mul`: the explicit value
  `∫₀^∞ heatMode a t dt = 1 / (2 a)` for `a > 0`.

* `green_function_eq_entropicProperTime` (★ HEADLINE ★):
  `∫₀^∞ heatMode a t dt = entropicProperTime a` for `a > 0`.

  This is the CAT/EPT version of the gaussian-field cylinder Green-
  function identity: the integral of the heat semigroup over positive
  times equals the entropic proper time (the static propagator).

## Honest scope

* **Spectral / single-mode** only.  Lifting to a Gaussian field on a
  cylinder or torus (full operator-valued Green function as in
  `gaussian-field/Cylinder/GreenFunction.lean`) requires a separate
  Bochner-integral / spectral-decomposition step; that's a Phase-2
  task.

* **Real-valued** only.  The heat mode is real `(2 a) > 0`; the
  complex case (oscillatory phase) factorises through
  `MeasurePathIntegralModel`'s damping side and the rigorous complex
  FK theorem (`RigorousComplexFeynmanKac`), both already shipped.

## Architectural fit

```text
HeatSemigroupEntropicTime.heatMode (a t) = exp(-(2 a) t)
                  ↓ integrate over t ∈ (0, ∞)
THIS MODULE: ∫₀^∞ heatMode a t dt = 1/(2 a) = τ(a)
                  ↓
PropagatorEntropicTime.entropicProperTime a = 1/(2 a) ← Gaussian propagator
                  ↓
EntropicGreenFunctionBridge.EntropicResolventScaling ← clock-rescaled Green
                  ↓
RigorousComplexFeynmanKac / no-counterterm chain
```

This module supplies the **single-mode** instance of "Green = integrated
entropic heat semigroup", closing step 4 of the user's ladder.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicGreenFromHeatSemigroup

open CATEPTMain.Integration.HeatSemigroupEntropicTime
open CATEPTMain.Integration.PropagatorEntropicTime
open MeasureTheory

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Explicit Green-function value
-- ═══════════════════════════════════════════════════════════════════════

/-- **Heat-mode integral over (0, ∞) is `1/(2 a)`** (for `a > 0`).

The integral of the heat-semigroup mode `exp(-(2 a) · t)` over `t ∈ (0, ∞)`
is the standard exponential integral `1/c` with `c = 2 a > 0`. -/
theorem heatMode_integral_Ioi_eq_inv_two_mul (a : ℝ) (ha : 0 < a) :
    ∫ t in Set.Ioi (0 : ℝ), heatMode a t = 1 / (2 * a) := by
  unfold heatMode
  -- Mathlib's `integral_exp_mul_Ioi`: ∫ x in Ioi c, exp(b·x) = -exp(b·c)/b for b < 0.
  -- Here b = -(2 a) < 0, c = 0.  So ∫ = -exp(0)/-(2 a) = 1/(2 a).
  have hb : (-(2 * a) : ℝ) < 0 := by linarith
  have h := integral_exp_mul_Ioi (a := -(2 * a)) hb 0
  -- h : ∫ x in Ioi 0, exp(-(2*a)*x) = -exp(-(2*a)*0)/-(2*a)
  simp only [mul_zero, neg_zero, Real.exp_zero] at h
  -- h : ∫ x in Ioi 0, exp(-(2*a)*x) = -1/-(2*a)
  rw [h]
  -- Goal: -1/-(2*a) = 1/(2 a)
  have hane : (2 * a : ℝ) ≠ 0 := by positivity
  field_simp

-- ═══════════════════════════════════════════════════════════════════════
-- Headline: Green function = entropic proper time
-- ═══════════════════════════════════════════════════════════════════════

/-- ★ **HEADLINE** ★

**Green function = entropic proper time.**  For a Gaussian mode of
action coefficient `a > 0`, the integrated heat-semigroup mode equals
the entropic proper time:

  `∫₀^∞ heatMode a t dt = entropicProperTime a`.

This is the CAT/EPT version of the gaussian-field cylinder Green-
function identity at the single-mode level.  The integrated heat
semigroup *is* the Green function (= covariance = static propagator),
and that Green function *is* the entropic proper time `τ(a)`.

Combining with `propagator_eq_entropicProperTime` (T-R Phase 1) gives
the full chain:

  `Green = ∫₀^∞ heat semigroup = entropicProperTime = staticPropagator`. -/
theorem green_function_eq_entropicProperTime (a : ℝ) (ha : 0 < a) :
    ∫ t in Set.Ioi (0 : ℝ), heatMode a t = entropicProperTime a := by
  rw [heatMode_integral_Ioi_eq_inv_two_mul a ha]
  rfl

end

end CATEPTMain.Integration.EntropicGreenFromHeatSemigroup
