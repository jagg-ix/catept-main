import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 238

Entropic-geodesic extension scaffold adapted from
`0058_part_10_extensions_entropic_geodesic.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G238

noncomputable section

def properTimeWeight (τ : ℝ) : ℝ := Real.exp (-τ)

def geodesicCost (v : ℝ) : ℝ := v ^ 2

def entropicGeodesicCost (τ v : ℝ) : ℝ := properTimeWeight τ * geodesicCost v

theorem properTimeWeight_pos (τ : ℝ) : 0 < properTimeWeight τ := by
  unfold properTimeWeight
  exact Real.exp_pos _

theorem geodesicCost_nonneg (v : ℝ) : 0 ≤ geodesicCost v := by
  unfold geodesicCost
  nlinarith

theorem entropicGeodesicCost_nonneg (τ v : ℝ) : 0 ≤ entropicGeodesicCost τ v := by
  unfold entropicGeodesicCost
  exact mul_nonneg (properTimeWeight_pos τ).le (geodesicCost_nonneg v)

theorem entropicGeodesicCost_antitone_in_tau
    {τ1 τ2 v : ℝ} (hτ : τ1 ≤ τ2) :
    entropicGeodesicCost τ2 v ≤ entropicGeodesicCost τ1 v := by
  unfold entropicGeodesicCost properTimeWeight
  have hexp : Real.exp (-τ2) ≤ Real.exp (-τ1) := by
    apply Real.exp_le_exp.mpr
    linarith
  exact mul_le_mul_of_nonneg_right hexp (geodesicCost_nonneg v)

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G238
