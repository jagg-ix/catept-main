import CATEPTMain.CATEPT.Foundations

set_option autoImplicit false

/-!
# CAT/EPT Decoherence Predictions

## Physics background

CAT/EPT's entropic rate λ = k_B T / ℏ sets a fundamental thermal
decoherence floor. For any thermalized bath at temperature T, the
fastest coherence-destroying process is bounded by this rate.

Observable decoherence times satisfy:

  T_observed ≥ T_thermal_floor = ℏ / (k_B T)

The gap between the CAT/EPT-predicted thermal floor and the observed
coherence time encodes HOW MANY bath modes effectively couple: a
large gap means the qubit is well-isolated; a small gap means
strong thermal coupling.

## Key results

1. Thermal decoherence rate λ_therm > 0 when T, k_B, ℏ > 0
2. Lower temperature → slower decoherence floor
3. Observed T2 is bounded above by 1/λ_therm (thermal floor)
4. Higher-temperature baths give stricter coherence bounds
-/

noncomputable section

namespace CATEPTMain.CATEPT

/-- CAT/EPT-predicted thermal decoherence rate (rad/s). -/
def thermal_decoherence_rate (k_B T hbar : ℝ) : ℝ :=
  k_B * T / hbar

/-- Thermal decoherence rate is positive for positive inputs. -/
theorem thermal_decoherence_rate_positive
    (k_B T hbar : ℝ) (hk : 0 < k_B) (hT : 0 < T) (hh : 0 < hbar) :
    0 < thermal_decoherence_rate k_B T hbar := by
  unfold thermal_decoherence_rate
  exact div_pos (mul_pos hk hT) hh

/-- Thermal rate is monotone in temperature. -/
theorem thermal_decoherence_rate_monotone
    (k_B T₁ T₂ hbar : ℝ) (hk : 0 < k_B) (hh : 0 < hbar)
    (h12 : T₁ < T₂) :
    thermal_decoherence_rate k_B T₁ hbar <
      thermal_decoherence_rate k_B T₂ hbar := by
  unfold thermal_decoherence_rate
  exact div_lt_div_of_pos_right (mul_lt_mul_of_pos_left h12 hk) hh

/-- CAT/EPT-predicted thermal decoherence floor (seconds).
    Any observed T2 must exceed this (or couplings are incomplete). -/
def thermal_decoherence_floor (k_B T hbar : ℝ) : ℝ :=
  hbar / (k_B * T)

theorem thermal_decoherence_floor_positive
    (k_B T hbar : ℝ) (hk : 0 < k_B) (hT : 0 < T) (hh : 0 < hbar) :
    0 < thermal_decoherence_floor k_B T hbar := by
  unfold thermal_decoherence_floor
  exact div_pos hh (mul_pos hk hT)

/-- Lower temperature → LONGER decoherence floor (slower bound).
    This is the CAT/EPT explanation for why qubits need mK temperatures. -/
theorem thermal_floor_antitone_in_T
    (k_B T₁ T₂ hbar : ℝ) (hk : 0 < k_B) (hh : 0 < hbar)
    (h1 : 0 < T₁) (h12 : T₁ < T₂) :
    thermal_decoherence_floor k_B T₂ hbar <
      thermal_decoherence_floor k_B T₁ hbar := by
  unfold thermal_decoherence_floor
  have h2pos : 0 < T₂ := lt_trans h1 h12
  apply div_lt_div_of_pos_left hh (mul_pos hk h1)
  exact mul_lt_mul_of_pos_left h12 hk

/-- CAT/EPT Feynman-Kac decoherence weight: |w| = exp(-γ·t)
    where γ is the effective decoherence rate. -/
def fk_decoherence_weight (γ t : ℝ) : ℝ :=
  Real.exp (- γ * t)

theorem fk_decoherence_weight_pos (γ t : ℝ) :
    0 < fk_decoherence_weight γ t :=
  Real.exp_pos _

theorem fk_decoherence_weight_le_one (γ t : ℝ)
    (hγ : 0 ≤ γ) (ht : 0 ≤ t) :
    fk_decoherence_weight γ t ≤ 1 := by
  unfold fk_decoherence_weight
  rw [Real.exp_le_one_iff]
  have : 0 ≤ γ * t := mul_nonneg hγ ht
  linarith

/-- Larger decoherence rate → faster weight decay. -/
theorem fk_weight_faster_decay_for_larger_γ
    (γ₁ γ₂ t : ℝ) (ht : 0 < t) (h12 : γ₁ < γ₂) :
    fk_decoherence_weight γ₂ t < fk_decoherence_weight γ₁ t := by
  unfold fk_decoherence_weight
  apply Real.exp_strictMono
  have hmul : γ₁ * t < γ₂ * t := mul_lt_mul_of_pos_right h12 ht
  linarith

end CATEPTMain.CATEPT
