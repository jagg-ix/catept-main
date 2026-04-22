import CATEPTMain.CATEPT.MuonGMinus2Bridge

set_option autoImplicit false

/-!
# Example 11: Muon g-2 from Entropic Backreaction

## What makes this unique to CAT/EPT

The muon anomalous magnetic moment a_μ = (g-2)/2 is one of the most
precisely measured quantities in physics. The Standard Model prediction
comes from QED, hadronic, and electroweak loops. The persistent ~4σ
tension with experiment motivates beyond-SM explanations.

In CAT/EPT, the imaginary action S_I induces a **gravitational
backreaction** on the muon loop:

  δa_μ = (G_eff ℏ / c⁵)^{1/2} · λ · f(ω_muon, θ_spin, φ̇)

where G_eff = k · α · ℏ · c / m² is the effective gravity from
entropic curvature. To first order, this reduces to δa_μ = k · α.

The Dyson-resummed form organizes all corrections:

  a_μ = (α/(2π)) / (1 - C'_QED - C'_had - C'_EW)

The CAT/EPT insight: the backreaction picture (from S_I ≥ 0) and the
Dyson resummation agree to first order — the entropic correction is
**not an ad hoc new-physics term** but emerges from the same complex
action structure that gives damping, Feynman-Kac weights, and
entropic time.

## Key results

1. Schwinger term α/(2π) > 0
2. Dyson resummation well-defined for |C'_tot| < 1
3. At C'_tot = 0: Dyson reduces to Schwinger
4. Entropic correction non-negative (from S_I ≥ 0)
5. Electron limit decouples the topological QED term
6. Larger entropic coupling → larger correction
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Schwinger term is positive for α > 0
example (α : ℝ) (hα : 0 < α) :
    0 < schwinger_term α :=
  schwinger_term_positive α hα

-- Dyson-resummed anomaly is positive
example (α C_tot : ℝ) (hα : 0 < α) (hC : C_tot < 1) :
    0 < dyson_resummed α C_tot :=
  dyson_resummed_positive α C_tot hα hC

-- At zero correction, Dyson reduces to Schwinger
example (α : ℝ) :
    dyson_resummed α 0 = schwinger_term α :=
  dyson_resummed_at_zero α

-- Schwinger term is linear (superposition of contributions)
example (α₁ α₂ : ℝ) :
    schwinger_term (α₁ + α₂) = schwinger_term α₁ + schwinger_term α₂ :=
  schwinger_term_linear α₁ α₂

-- Entropic backreaction correction is non-negative
example (k α : ℝ) (hk : 0 ≤ k) (hα : 0 ≤ α) :
    0 ≤ entropic_g2_correction k α :=
  entropic_g2_correction_nonneg k α hk hα

-- In the decoupled regime (k=0), the correction vanishes
example (α : ℝ) :
    entropic_g2_correction 0 α = 0 :=
  entropic_g2_correction_decoupled α

-- Larger entropic coupling → larger correction (monotonicity)
example (k₁ k₂ α : ℝ) (hα : 0 < α) (hk : k₁ < k₂) :
    entropic_g2_correction k₁ α < entropic_g2_correction k₂ α :=
  entropic_correction_monotone k₁ k₂ α hα hk

-- Electron limit: equal masses decouple QED sector (m ≠ 0)
example (α m κ_QED : ℝ) (hm : m ≠ 0) :
    qed_sector α m m κ_QED = 0 :=
  electron_limit_decouples α m κ_QED hm

-- Backreaction energy shift is non-negative
example (ℏ Γ_norm overlap : ℝ) (hh : 0 ≤ ℏ) (hΓ : 0 ≤ Γ_norm) (ho : 0 ≤ overlap) :
    0 ≤ backreaction_energy_shift ℏ Γ_norm overlap :=
  backreaction_energy_shift_nonneg ℏ Γ_norm overlap hh hΓ ho

-- Effective gravity is non-negative
example (k α ℏ c m : ℝ) (hk : 0 ≤ k) (hα : 0 ≤ α) (hh : 0 ≤ ℏ) (hc : 0 ≤ c) :
    0 ≤ G_eff k α ℏ c m :=
  G_eff_nonneg k α ℏ c m hk hα hh hc

end CATEPT.Examples
