/-
  T-U Phase 1: Heat-semigroup multiplicative composition law.

  Closes out the elementary semigroup readings of the entropic
  proper time `τ(a) = 1/(2 a)` from T-R/T-S/T-T:

    * T-S    inverse decay rate at t=0   (∂_t heatMode a |_{t=0} = -1/τ)
    * T-T    total time-integral L¹      (∫₀^∞ heatMode a t dt   =  τ )
    * T-U    semigroup composition law   (this rung)

      heatMode a (s + t)   =   heatMode a s  ·  heatMode a t

  i.e. the Gaussian-mode heat semigroup `S_t := e^{-(2 a) t}` satisfies
  `S_{s+t} = S_s · S_t`. Together with `heatMode a 0 = 1` (T-S
  normalisation) this is the abelian one-parameter-group structure on
  the diagonal of the OU/heat semigroup spectral decomposition.

  One honest theorem:

    * `heatMode_semigroup`
        heatMode a (s + t) = heatMode a s * heatMode a t.

  Pure Real.exp identity; positivity-free.
-/

import CATEPTMain.Integration.HeatSemigroupEntropicTime

set_option autoImplicit false

namespace CATEPTMain.Integration.HeatSemigroupLaw

open CATEPTMain.Integration.HeatSemigroupEntropicTime

noncomputable section

/-- **Heat-semigroup composition law** (T-U Phase 1).

    For all `a, s, t : ℝ`,

        heatMode a (s + t)  =  heatMode a s  ·  heatMode a t.

    Together with `heatMode_zero` (T-S Phase 1), this is the
    one-parameter abelian semigroup structure on the diagonal mode
    `S_t = e^{-(2 a) t}` of the harmonic-oscillator / OU heat
    semigroup. Positivity-free: holds for all real `a`. -/
theorem heatMode_semigroup (a s t : ℝ) :
    heatMode a (s + t) = heatMode a s * heatMode a t := by
  unfold heatMode
  rw [show (-(2 * a) * (s + t)) = (-(2 * a) * s) + (-(2 * a) * t) by ring,
      Real.exp_add]

end

end CATEPTMain.Integration.HeatSemigroupLaw
