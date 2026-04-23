import CATEPTMain.CATEPT.Foundations

set_option autoImplicit false

/-!
# Muon g-2 and Entropic Backreaction Bridge

## Physics background

The anomalous magnetic moment of the muon a_μ = (g-2)/2 receives:
- QED leading order (Schwinger): α/(2π)
- Higher-order QED, hadronic, and electroweak corrections
- In CAT/EPT: an entropic backreaction correction from S_I

The Dyson-resummed form organizes these as:

  a_μ = (α/(2π)) / (1 - C'_tot)

where C'_tot = C'_QED + C'_had + C'_EW collects sector corrections.

The CAT/EPT insight: the imaginary action S_I induces a gravitational
backreaction on the muon loop, producing a correction δa_μ = k·α where
k encodes the entropic coupling strength. This backreaction picture
aligns with the Dyson-resummed form to first order in C'_tot.

## Key results

1. Schwinger term α/(2π) > 0
2. Dyson resummation is well-defined when |C'_tot| < 1
3. Entropic correction is non-negative (from S_I ≥ 0)
4. Sector decomposition: total = QED + hadronic + EW
5. Electron limit decouples the topological term
-/

noncomputable section

namespace CATEPTMain.CATEPT

/-! ## Schwinger Leading-Order Term -/

/-- Schwinger's leading-order QED correction: a_μ^(1) = α/(2π). -/
def schwinger_term (α : ℝ) : ℝ := α / (2 * Real.pi)

theorem schwinger_term_positive (α : ℝ) (hα : 0 < α) :
    0 < schwinger_term α := by
  unfold schwinger_term
  exact div_pos hα (mul_pos two_pos Real.pi_pos)

theorem schwinger_term_nonneg (α : ℝ) (hα : 0 ≤ α) :
    0 ≤ schwinger_term α := by
  unfold schwinger_term
  exact div_nonneg hα (le_of_lt (mul_pos two_pos Real.pi_pos))

/-- Schwinger term scales linearly with α. -/
theorem schwinger_term_linear (α₁ α₂ : ℝ) :
    schwinger_term (α₁ + α₂) = schwinger_term α₁ + schwinger_term α₂ := by
  unfold schwinger_term; ring

/-! ## Dyson-Resummed Anomalous Magnetic Moment -/

/-- Dyson denominator: 1 - C'_tot. -/
def dyson_denominator (C_tot : ℝ) : ℝ := 1 - C_tot

theorem dyson_denominator_pos (C_tot : ℝ) (h : C_tot < 1) :
    0 < dyson_denominator C_tot := by
  unfold dyson_denominator; linarith

/-- Dyson-resummed anomaly: a_μ = (α/(2π)) / (1 - C'_tot). -/
def dyson_resummed (α C_tot : ℝ) : ℝ :=
  schwinger_term α / dyson_denominator C_tot

theorem dyson_resummed_positive (α C_tot : ℝ) (hα : 0 < α) (hC : C_tot < 1) :
    0 < dyson_resummed α C_tot := by
  unfold dyson_resummed
  exact div_pos (schwinger_term_positive α hα) (dyson_denominator_pos C_tot hC)

/-- When C'_tot = 0, Dyson resummation reduces to the Schwinger term. -/
theorem dyson_resummed_at_zero (α : ℝ) :
    dyson_resummed α 0 = schwinger_term α := by
  unfold dyson_resummed dyson_denominator
  simp

/-! ## Sector Decomposition -/

/-- QED sector correction: κ_QED (α/π)² (1 - m_e/m_μ). -/
def qed_sector (α m_e m_μ κ_QED : ℝ) : ℝ :=
  κ_QED * (α / Real.pi) ^ 2 * (1 - m_e / m_μ)

/-- Hadronic sector: C'_had = (2π/α) a_had. -/
def hadronic_sector (α a_had : ℝ) : ℝ :=
  (2 * Real.pi / α) * a_had

/-- Electroweak sector (slot). -/
def ew_sector (c_EW : ℝ) : ℝ := c_EW

/-- Total sector correction. -/
def total_sector (α m_e m_μ κ_QED a_had c_EW : ℝ) : ℝ :=
  qed_sector α m_e m_μ κ_QED + hadronic_sector α a_had + ew_sector c_EW

/-- Electron limit: when m_e = m_μ (with m > 0), the QED sector vanishes. -/
theorem electron_limit_decouples (α m κ_QED : ℝ) (hm : m ≠ 0) :
    qed_sector α m m κ_QED = 0 := by
  unfold qed_sector; simp [div_self hm]

/-! ## Entropic Backreaction Correction -/

/-- Entropic correction to g-2: δa_μ = k · α, where k encodes
    the backreaction strength from S_I. -/
def entropic_g2_correction (k α : ℝ) : ℝ := k * α

theorem entropic_g2_correction_nonneg (k α : ℝ)
    (hk : 0 ≤ k) (hα : 0 ≤ α) :
    0 ≤ entropic_g2_correction k α :=
  mul_nonneg hk hα

/-- The correction vanishes when the backreaction coupling k = 0
    (decoupled regime). -/
theorem entropic_g2_correction_decoupled (α : ℝ) :
    entropic_g2_correction 0 α = 0 := by
  unfold entropic_g2_correction; ring

/-- Monotonicity: larger entropic coupling → larger correction. -/
theorem entropic_correction_monotone (k₁ k₂ α : ℝ)
    (hα : 0 < α) (hk : k₁ < k₂) :
    entropic_g2_correction k₁ α < entropic_g2_correction k₂ α := by
  unfold entropic_g2_correction
  exact mul_lt_mul_of_pos_right hk hα

/-! ## Backreaction from Effective Gravity -/

/-- Effective gravitational coupling: G_eff = k · α · ℏ · c / m².
    In CAT/EPT, the entropic S_I produces an effective gravitational
    backreaction on the muon loop at this scale. -/
def G_eff (k α ℏ c m : ℝ) : ℝ := k * α * ℏ * c / m ^ 2

theorem G_eff_nonneg (k α ℏ c m : ℝ)
    (hk : 0 ≤ k) (hα : 0 ≤ α) (hh : 0 ≤ ℏ) (hc : 0 ≤ c) :
    0 ≤ G_eff k α ℏ c m := by
  unfold G_eff
  apply div_nonneg
  · exact mul_nonneg (mul_nonneg (mul_nonneg hk hα) hh) hc
  · exact sq_nonneg m

/-- Energy shift from backreaction: ΔE = ℏ · Γ_norm · overlap,
    where Γ_norm is the spin-connection norm. -/
def backreaction_energy_shift (ℏ Γ_norm overlap : ℝ) : ℝ :=
  ℏ * Γ_norm * overlap

theorem backreaction_energy_shift_nonneg (ℏ Γ_norm overlap : ℝ)
    (hh : 0 ≤ ℏ) (hΓ : 0 ≤ Γ_norm) (ho : 0 ≤ overlap) :
    0 ≤ backreaction_energy_shift ℏ Γ_norm overlap :=
  mul_nonneg (mul_nonneg hh hΓ) ho

/-- Anomalous magnetic moment from energy shift: a_μ = ΔE / (μ_B · B). -/
def a_mu_from_shift (ΔE μ_B B : ℝ) : ℝ := ΔE / (μ_B * B)

theorem a_mu_from_shift_nonneg (ΔE μ_B B : ℝ)
    (hΔE : 0 ≤ ΔE) (hμ : 0 < μ_B) (hB : 0 < B) :
    0 ≤ a_mu_from_shift ΔE μ_B B :=
  div_nonneg hΔE (le_of_lt (mul_pos hμ hB))

end CATEPTMain.CATEPT
