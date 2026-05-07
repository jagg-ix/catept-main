/-
  T-S Phase 1: Heat-semigroup ↔ entropic-proper-time identification.

  Composes the entropic-proper-time scale `τ(a) = 1/(2 a)` from T-R
  with elementary Mathlib calculus on `Real.exp` to read off the
  semigroup interpretation of `τ`:

      heatMode_a (t)           :=  exp ( -(2 a) · t )

      heatMode_a (0)            =  1                  -- normalised at t=0
      ∂_t heatMode_a |_{t=0}    =  -(2 a)             -- bare decay rate
                              =  - 1 / τ(a)         -- equivalently

  Physically: a Gaussian mode with action coefficient `a` (and hence
  connected propagator `G = τ(a) = 1/(2 a)`) decays under the heat
  semigroup `e^{-2 a t}` with characteristic time `τ(a)`. The entropic
  proper time is therefore the **inverse heat-semigroup decay rate at
  t = 0**, identifying the static propagator side (T-P/T-Q) with the
  semigroup-evolution side (this file) and yielding the t → 0
  localisation: the Gaussian mode is concentrated at its initial
  amplitude and decays at rate `1/τ(a)`.

  Two honest theorems:

    * `heatMode_zero`        : initial value 1
    * `heatMode_decay_rate`  : ∂_t heatMode_a |_{t=0} = - 1/τ(a)

  Positivity `0 < a` is used only in `heatMode_decay_rate` to invert
  `τ(a)` cleanly. The pure-derivative identity is positivity-free.
-/

import CATEPTMain.Integration.PropagatorEntropicTime
import Mathlib.Analysis.SpecialFunctions.Exp

set_option autoImplicit false

namespace CATEPTMain.Integration.HeatSemigroupEntropicTime

open CATEPTMain.Integration.PropagatorEntropicTime

noncomputable section

/-- **Heat-semigroup mode**.

    For a Gaussian mode of action coefficient `a`, the (one-dimensional)
    heat-semigroup evolution of a unit amplitude is

        heatMode a t  :=  exp ( -(2 a) · t ).

    This is the diagonal in the spectral decomposition of the
    Ornstein–Uhlenbeck / harmonic-oscillator heat semigroup with
    relaxation rate `2 a` (the kinetic coefficient that shows up in
    the action `S = a x²`). At `t = 0` the mode has amplitude `1`;
    its initial decay rate is `-(2 a) = -1/τ(a)`. -/
def heatMode (a t : ℝ) : ℝ := Real.exp (-(2 * a) * t)

/-- **Initial-value normalisation** (T-S Phase 1).

    `heatMode a 0 = 1`. Trivial; recorded to make the t=0 localisation
    explicit in the public surface. -/
theorem heatMode_zero (a : ℝ) : heatMode a 0 = 1 := by
  simp [heatMode]

/-- **Pointwise derivative of the heat mode** (kernel computation).

    `d/dt exp(-(2 a) t) = -(2 a) · exp(-(2 a) t)`. Positivity-free:
    holds for all `a : ℝ`. -/
theorem heatMode_hasDerivAt (a t : ℝ) :
    HasDerivAt (heatMode a) (-(2 * a) * Real.exp (-(2 * a) * t)) t := by
  -- Inner: t ↦ -(2a) · t has derivative -(2a)
  have h1 : HasDerivAt (fun t : ℝ => -(2 * a) * t) (-(2 * a)) t := by
    simpa using (hasDerivAt_id t).const_mul (-(2 * a))
  -- Outer: exp ∘ inner
  have h2 := (Real.hasDerivAt_exp (-(2 * a) * t)).comp t h1
  -- Mathlib gives us derivative `Real.exp (-(2*a)*t) * -(2*a)`; reorder to canonical form.
  have hreord :
      Real.exp (-(2 * a) * t) * -(2 * a) = -(2 * a) * Real.exp (-(2 * a) * t) := by
    ring
  rw [hreord] at h2
  exact h2

/-- **Heat-semigroup decay rate equals inverse entropic proper time**
    (T-S Phase 1, main).

    For a Gaussian mode of action coefficient `a > 0`,

        ∂_t heatMode a |_{t=0}  =  - 1 / τ(a)

    where `τ(a) = 1/(2 a)` is the entropic proper time from T-R. This
    identifies the connected propagator (static side, T-P/T-Q) with the
    inverse heat-semigroup decay rate (dynamic side, this file). -/
theorem heatMode_decay_rate (a : ℝ) (ha : 0 < a) :
    HasDerivAt (heatMode a) (- 1 / entropicProperTime a) 0 := by
  have h := heatMode_hasDerivAt a 0
  -- Simplify the derivative value at t = 0: -(2a) · exp(0) = -(2a).
  have hval : -(2 * a) * Real.exp (-(2 * a) * 0) = -(2 * a) := by
    simp
  rw [hval] at h
  -- Show -(2 a) = - 1 / τ(a) and rewrite.
  have hane : (2 * a) ≠ 0 := by positivity
  have hrhs : - 1 / entropicProperTime a = -(2 * a) := by
    unfold entropicProperTime
    field_simp
  rw [hrhs]
  exact h

end

end CATEPTMain.Integration.HeatSemigroupEntropicTime
