import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 186

Sound-speed/Unruh-temperature scaffold extracted from
`0012_4_._sound_speed_at_unruh_temperature.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G186

noncomputable section

open Real

def R : ℝ := 8.314
def M : ℝ := 0.029
def kB : ℝ := 1.380649e-23
def ħ : ℝ := 1.054571817e-34
def c : ℝ := 299792458

def gamma (T : ℝ) : ℝ :=
  1.4 - 0.0001 * (T - 300)

def vs (T : ℝ) : ℝ :=
  Real.sqrt (gamma T * R * T / M)

def dτds (T : ℝ) : ℝ := kB * T

def TUnruh (a : ℝ) : ℝ :=
  ħ * a / (2 * Real.pi * c * kB)

def vsUnruh (a : ℝ) : ℝ :=
  let TU := TUnruh a
  Real.sqrt (gamma TU * R * TU / M)

theorem gamma_300 : gamma 300 = 1.4 := by
  norm_num [gamma]

theorem dτds_zero : dτds 0 = 0 := by
  norm_num [dτds]

theorem dτds_nonneg {T : ℝ} (hT : 0 ≤ T) : 0 ≤ dτds T := by
  unfold dτds
  have hkB : 0 < kB := by norm_num [kB]
  nlinarith

theorem TUnruh_zero : TUnruh 0 = 0 := by
  norm_num [TUnruh]

theorem vs_nonneg (T : ℝ) : 0 ≤ vs T := by
  unfold vs
  positivity

theorem vsUnruh_nonneg (a : ℝ) : 0 ≤ vsUnruh a := by
  unfold vsUnruh
  positivity

theorem vsUnruh_eq_vs_of_TUnruh (a : ℝ) :
    vsUnruh a = vs (TUnruh a) := by
  unfold vsUnruh vs
  rfl

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G186
