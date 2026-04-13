import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 120

Flux-governor damping layer extracted from
`0140_uqg_schwarzschild_fluxgovernor.lean.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G120

noncomputable section

structure FluxGovernor where
  lam : ℝ
  lam_pos : 0 < lam
  χ_eff : ℝ
  χ_eff_pos : 0 < χ_eff

/-- Band power proxy from projected norm. -/
def bandPower (projNorm : ℝ) : ℝ :=
  projNorm ^ 2

/-- QNM damping bound from governor regularization and mode energy. -/
def qnmDampingBound (gov : FluxGovernor) (E_mode projNormSq : ℝ) : ℝ :=
  (gov.lam / (4 * E_mode)) * projNormSq

theorem bandPower_nonneg (projNorm : ℝ) : 0 ≤ bandPower projNorm := by
  unfold bandPower
  positivity

theorem qnmDampingBound_nonneg
    (gov : FluxGovernor) (E_mode projNormSq : ℝ)
    (hE : 0 < E_mode)
    (hp : 0 ≤ projNormSq) :
    0 ≤ qnmDampingBound gov E_mode projNormSq := by
  have hcoef : 0 ≤ gov.lam / (4 * E_mode) := by
    have hden : 0 < 4 * E_mode := by nlinarith
    exact div_nonneg (le_of_lt gov.lam_pos) (le_of_lt hden)
  have : 0 ≤ qnmDampingBound gov E_mode projNormSq := by
    unfold qnmDampingBound
    exact mul_nonneg hcoef hp
  exact this

theorem qnmDampingBound_mono_projNormSq
    (gov : FluxGovernor) (E_mode p₁ p₂ : ℝ)
    (hE : 0 < E_mode)
    (hmono : p₁ ≤ p₂) :
    qnmDampingBound gov E_mode p₁ ≤ qnmDampingBound gov E_mode p₂ := by
  unfold qnmDampingBound
  have hcoef : 0 ≤ gov.lam / (4 * E_mode) := by
    have hden : 0 < 4 * E_mode := by nlinarith
    exact div_nonneg (le_of_lt gov.lam_pos) (le_of_lt hden)
  exact mul_le_mul_of_nonneg_left hmono hcoef

theorem qnmDampingBound_zero_proj
    (gov : FluxGovernor) (E_mode : ℝ) :
    qnmDampingBound gov E_mode 0 = 0 := by
  unfold qnmDampingBound
  simp

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G120
