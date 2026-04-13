import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 192

Fano-resonance protocol scaffold adapted from
`0116_implementation_for_fanoresonanceprot.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G192

noncomputable section

structure FanoProtocol where
  q : ℝ
  gamma : ℝ
  gamma_pos : 0 < gamma

def reducedDetuning (P : FanoProtocol) (ω ω0 : ℝ) : ℝ :=
  (ω - ω0) / P.gamma

def fanoIntensity (P : FanoProtocol) (ω ω0 : ℝ) : ℝ :=
  let ε := reducedDetuning P ω ω0
  ((P.q + ε) ^ 2) / (1 + ε ^ 2)

theorem denominator_pos (P : FanoProtocol) (ω ω0 : ℝ) :
    0 < 1 + (reducedDetuning P ω ω0) ^ 2 := by
  have hsq : 0 ≤ (reducedDetuning P ω ω0) ^ 2 := sq_nonneg _
  linarith

theorem fanoIntensity_nonneg (P : FanoProtocol) (ω ω0 : ℝ) :
    0 ≤ fanoIntensity P ω ω0 := by
  unfold fanoIntensity
  set ε : ℝ := reducedDetuning P ω ω0
  have hnum : 0 ≤ (P.q + ε) ^ 2 := sq_nonneg _
  have hden : 0 ≤ 1 + ε ^ 2 := by
    nlinarith [sq_nonneg ε]
  exact div_nonneg hnum hden

theorem reducedDetuning_zero_at_resonance (P : FanoProtocol) (ω0 : ℝ) :
    reducedDetuning P ω0 ω0 = 0 := by
  unfold reducedDetuning
  ring

theorem fanoIntensity_at_resonance (P : FanoProtocol) (ω0 : ℝ) :
    fanoIntensity P ω0 ω0 = P.q ^ 2 := by
  unfold fanoIntensity
  simp [reducedDetuning_zero_at_resonance]

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G192
