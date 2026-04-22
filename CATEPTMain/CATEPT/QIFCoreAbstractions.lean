import Mathlib

set_option autoImplicit false

namespace CATEPT

namespace QIF

noncomputable section

/-- Discrete integral kernel used throughout QIF bridge proofs. -/
def discreteIntegral (f : ℕ → ℝ) (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) f

theorem discreteIntegral_nonneg
    (f : ℕ → ℝ) (N : ℕ) (h : ∀ i ≤ N, 0 ≤ f i) :
    0 ≤ discreteIntegral f N := by
  unfold discreteIntegral
  refine Finset.sum_nonneg ?_
  intro i hi
  exact h i (Nat.lt_succ_iff.mp (Finset.mem_range.mp hi))

theorem discreteIntegral_mono
    (f g : ℕ → ℝ) (N : ℕ)
    (h : ∀ i ≤ N, f i ≤ g i) :
    discreteIntegral f N ≤ discreteIntegral g N := by
  unfold discreteIntegral
  refine Finset.sum_le_sum ?_
  intro i hi
  exact h i (Nat.lt_succ_iff.mp (Finset.mem_range.mp hi))

theorem discreteIntegral_add
    (f g : ℕ → ℝ) (N : ℕ) :
    discreteIntegral (fun i => f i + g i) N =
      discreteIntegral f N + discreteIntegral g N := by
  unfold discreteIntegral
  exact Finset.sum_add_distrib

/-- Entropic proper time written as a scaled integrated intensity. -/
def entropicProperTime (nu hbar omegaIntegral : ℝ) : ℝ :=
  (nu / hbar) * omegaIntegral

theorem entropicProperTime_nonneg
    (nu hbar omegaIntegral : ℝ)
    (hnu : 0 ≤ nu) (hhbar : 0 < hbar) (homega : 0 ≤ omegaIntegral) :
    0 ≤ entropicProperTime nu hbar omegaIntegral := by
  unfold entropicProperTime
  exact mul_nonneg (div_nonneg hnu (le_of_lt hhbar)) homega

theorem entropicProperTime_mono
    (nu hbar ω₁ ω₂ : ℝ)
    (hnu : 0 ≤ nu) (hhbar : 0 < hbar) (hω : ω₁ ≤ ω₂) :
    entropicProperTime nu hbar ω₁ ≤ entropicProperTime nu hbar ω₂ := by
  unfold entropicProperTime
  exact mul_le_mul_of_nonneg_left hω (div_nonneg hnu (le_of_lt hhbar))

/-- Explicit QIF slack used in uniform decomposition proofs. -/
def qifExplicitSlack (E0 hbar xiBound Cdelta : ℝ) : ℝ :=
  Cdelta * (E0 / hbar + xiBound)

/-- Canonical entropic palinstrophy budget denominator form. -/
def qifPalinstrophyBoundEntropic (Omega0 delta K hbar nu : ℝ) : ℝ :=
  (Omega0 + 2 * (hbar / nu) * K) /
    (2 * hbar - 2 * (hbar / nu) * delta)

theorem qifPalDenomPos
    (delta hbar nu : ℝ)
    (hhbar : 0 < hbar) (hnu : 0 < nu) (hdeltaLt : delta < nu) :
    0 < 2 * hbar - 2 * (hbar / nu) * delta := by
  have hfrac_lt : delta / nu < 1 := by
    exact (div_lt_one hnu).2 hdeltaLt
  have hfactor : 0 < 1 - delta / nu := sub_pos.mpr hfrac_lt
  have hrewrite :
      2 * hbar - 2 * (hbar / nu) * delta = 2 * hbar * (1 - delta / nu) := by
    ring
  rw [hrewrite]
  have h2h : 0 < 2 * hbar := mul_pos (by norm_num) hhbar
  exact mul_pos h2h hfactor

/-- Absorption functional appearing in geometric-sufficiency bridges. -/
def classicalAbsorptionFunctional (δ a : ℝ) : ℝ :=
  δ + (27 / (256 * δ ^ 3)) * a

theorem qif_functional_ring_identity (δ a : ℝ) :
    classicalAbsorptionFunctional δ a = δ + (27 / (256 * δ ^ 3)) * a := by
  rfl

/-- Generic normalized geometry coefficient: geometric energy over amplitude. -/
def qifNormalizedGeomCoefficient (holonomyEnergy omegaScale : ℝ) : ℝ :=
  holonomyEnergy / omegaScale

theorem qif_normalized_geom_le_of_bound
    (holonomyEnergy omegaScale k : ℝ)
    (hω : 0 < omegaScale)
    (hhol : holonomyEnergy ≤ k * omegaScale) :
    qifNormalizedGeomCoefficient holonomyEnergy omegaScale ≤ k := by
  unfold qifNormalizedGeomCoefficient
  exact (div_le_iff₀ hω).2 hhol

/-- Generic uniform budget family used by QIF packaging lemmas. -/
def qifUniformPalBound (delta Cdelta E0 tauEnt : ℝ) : ℝ :=
  delta * tauEnt + Cdelta * E0

/-- Canonical-form theorem schema from `(delta,Cdelta)`-independence assumptions. -/
theorem qifUniformPalBound_canonical_form
    (B : ℝ → ℝ → ℝ → ℝ → ℝ) (nu : ℝ)
    (d1 d2 C1 C2 E0 τ : ℝ)
    (hd1 : 0 < d1) (hd1Lt : d1 < nu)
    (hd2 : 0 < d2) (hd2Lt : d2 < nu)
    (hC1 : 0 < C1) (hC2 : 0 < C2)
    (hCind : ∀ d C E t, 0 < C → B d C E t = B d 1 E t)
    (hDind : ∀ d E t, 0 < d → d < nu → B d 1 E t = B (nu / 4) 1 E t) :
    B d1 C1 E0 τ = B d2 C2 E0 τ := by
  calc
    B d1 C1 E0 τ = B d1 1 E0 τ := hCind d1 C1 E0 τ hC1
    _ = B (nu / 4) 1 E0 τ := hDind d1 E0 τ hd1 hd1Lt
    _ = B d2 1 E0 τ := (hDind d2 E0 τ hd2 hd2Lt).symm
    _ = B d2 C2 E0 τ := (hCind d2 C2 E0 τ hC2).symm

/-- Worst-case packaging corollary from canonical-form assumptions. -/
theorem qif_uniform_pal_bound_worst_case_proved
    (B : ℝ → ℝ → ℝ → ℝ → ℝ) (nu : ℝ)
    (d C E0 τ : ℝ)
    (hd : 0 < d) (hdLt : d < nu) (hC : 0 < C)
    (hCind : ∀ d' C' E t, 0 < C' → B d' C' E t = B d' 1 E t)
    (hDind : ∀ d' E t, 0 < d' → d' < nu → B d' 1 E t = B (nu / 4) 1 E t) :
    B d C E0 τ ≤ B (nu / 4) 1 E0 τ := by
  have hEq : B d C E0 τ = B (nu / 4) 1 E0 τ := by
    calc
      B d C E0 τ = B d 1 E0 τ := hCind d C E0 τ hC
      _ = B (nu / 4) 1 E0 τ := hDind d E0 τ hd hdLt
  exact hEq.le

end

end QIF

end CATEPT
