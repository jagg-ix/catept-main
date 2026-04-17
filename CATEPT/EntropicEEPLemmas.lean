import Mathlib
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

noncomputable section

set_option autoImplicit false

/-!
# Entropic EEP Lemmas

Proved lemmas for the Entropic Einstein Equivalence Principle (EEEP) and its
connection to the CAT/EPT framework (Sections X–XI).

The EEEP states: in every local inertial frame, the imaginary (dissipative)
sector is Rindler/Unruh-like, with local temperature T_loc = ħ a_loc/(2π kB c).
CAT/EPT identifies the imaginary Hamiltonian sector HI/ħ with kB T_loc.
-/

namespace CATEPT

/-- Physical constants (positive). -/
structure PhysicalConstants where
  hbar : ℝ
  kB   : ℝ
  c    : ℝ
  hbar_pos : 0 < hbar
  kB_pos   : 0 < kB
  c_pos    : 0 < c

/-- Section XI local Unruh/Rindler temperature: T_loc = ħ a_loc / (2π kB c). -/
def localUnruhTemperature (pc : PhysicalConstants) (aLoc : ℝ) : ℝ :=
  pc.hbar * aLoc / (2 * Real.pi * pc.kB * pc.c)

/-- Entropic action: SI(A) = (ħ/kB) Sent(A). -/
def entropicActionOfEntropy (pc : PhysicalConstants) (Sent : ℝ) : ℝ :=
  (pc.hbar / pc.kB) * Sent

/-- Entropic force density: F_T = λ · ∇Θ (scalar reduction). -/
def entropicForceDensity (lam gradTheta : ℝ) : ℝ :=
  lam * gradTheta

/-- Tolman/redshift law: β_I(x) = β_∞ √(−g_00). -/
def entropicRedshiftedBeta (betaInf sqrtFactor : ℝ) : ℝ :=
  betaInf * sqrtFactor

/-- Entropic stress tensor scalar: (ħ/kB)(σ·σ + ζθ) + λ|∇Θ|². -/
def entropicStressScalar (pc : PhysicalConstants)
    (sigmaTerm zeta theta lam gradThetaSq : ℝ) : ℝ :=
  (pc.hbar / pc.kB) * (sigmaTerm + zeta * theta) + lam * gradThetaSq

/-- Modular slope criterion: region A relaxes faster than B. -/
def modularSlopeCriterion (uA uB : ℝ) : Prop := uA > uB

-- ── helpers ──────────────────────────────────────────────────────────────────

private lemma denom_pos (pc : PhysicalConstants) :
    0 < 2 * Real.pi * pc.kB * pc.c :=
  mul_pos (mul_pos (mul_pos (by norm_num) Real.pi_pos) pc.kB_pos) pc.c_pos

-- ── Unruh temperature ────────────────────────────────────────────────────────

/-- EEEP: T_loc > 0 whenever local acceleration is positive. -/
theorem localUnruhTemperature_pos
    (pc : PhysicalConstants) (aLoc : ℝ) (haLoc : 0 < aLoc) :
    0 < localUnruhTemperature pc aLoc :=
  div_pos (mul_pos pc.hbar_pos haLoc) (denom_pos pc)

/-- EEEP: T_loc ≥ 0 whenever local acceleration is nonneg. -/
theorem localUnruhTemperature_nonneg
    (pc : PhysicalConstants) (aLoc : ℝ) (haLoc : 0 ≤ aLoc) :
    0 ≤ localUnruhTemperature pc aLoc :=
  div_nonneg (mul_nonneg pc.hbar_pos.le haLoc) (denom_pos pc).le

/-- EEEP: T_loc = 0 ↔ a_loc = 0 (inertial frame ↔ no Rindler radiation). -/
theorem localUnruhTemperature_zero_iff
    (pc : PhysicalConstants) (aLoc : ℝ) :
    localUnruhTemperature pc aLoc = 0 ↔ aLoc = 0 := by
  unfold localUnruhTemperature
  rw [div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · exact (mul_eq_zero.mp h).resolve_left pc.hbar_pos.ne'
    · exact absurd h (denom_pos pc).ne'
  · intro h; left; simp [h]

-- ── Entropic action ───────────────────────────────────────────────────────────

/-- EEEP: SI ≥ 0 when Sent ≥ 0. -/
theorem entropicActionOfEntropy_nonneg
    (pc : PhysicalConstants) (Sent : ℝ) (hS : 0 ≤ Sent) :
    0 ≤ entropicActionOfEntropy pc Sent :=
  mul_nonneg (div_nonneg pc.hbar_pos.le pc.kB_pos.le) hS

/-- EEEP: SI > 0 when Sent > 0. -/
theorem entropicActionOfEntropy_pos
    (pc : PhysicalConstants) (Sent : ℝ) (hS : 0 < Sent) :
    0 < entropicActionOfEntropy pc Sent :=
  mul_pos (div_pos pc.hbar_pos pc.kB_pos) hS

/-- EEEP: SI = 0 ↔ Sent = 0. -/
theorem entropicActionOfEntropy_zero_iff
    (pc : PhysicalConstants) (Sent : ℝ) :
    entropicActionOfEntropy pc Sent = 0 ↔ Sent = 0 := by
  unfold entropicActionOfEntropy
  constructor
  · intro h
    have hcoeff : pc.hbar / pc.kB ≠ 0 := (div_pos pc.hbar_pos pc.kB_pos).ne'
    exact (mul_eq_zero.mp h).resolve_left hcoeff
  · intro h; simp [h]

-- ── Entropic force ────────────────────────────────────────────────────────────

/-- EEEP: F_T = 0 ↔ λ = 0 ∨ ∇Θ = 0. -/
theorem entropicForceDensity_zero_iff (lam gradTheta : ℝ) :
    entropicForceDensity lam gradTheta = 0 ↔ lam = 0 ∨ gradTheta = 0 :=
  mul_eq_zero

/-- EEEP flat sector: F_T vanishes when ∇Θ = 0. -/
theorem entropicForceDensity_zero_of_flat_grad (lam : ℝ) :
    entropicForceDensity lam 0 = 0 := by simp [entropicForceDensity]

/-- EEEP: F_T > 0 iff λ and ∇Θ have the same positive/negative sign. -/
theorem entropicForceDensity_pos_iff (lam gradTheta : ℝ) :
    0 < entropicForceDensity lam gradTheta ↔
    (0 < lam ∧ 0 < gradTheta) ∨ (lam < 0 ∧ gradTheta < 0) := by
  unfold entropicForceDensity
  constructor
  · intro h
    rcases mul_pos_iff.mp h with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact Or.inl ⟨h1, h2⟩
    · exact Or.inr ⟨h1, h2⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact mul_pos h1 h2
    · exact mul_pos_of_neg_of_neg h1 h2

-- ── Tolman-redshifted beta ────────────────────────────────────────────────────

/-- EEEP: β_I(x) ≥ 0 when β_∞ ≥ 0 and √(−g_00) ≥ 0. -/
theorem entropicRedshiftedBeta_nonneg
    (betaInf sqrtF : ℝ) (h1 : 0 ≤ betaInf) (h2 : 0 ≤ sqrtF) :
    0 ≤ entropicRedshiftedBeta betaInf sqrtF :=
  mul_nonneg h1 h2

/-- EEEP: β_I(x) > 0 when β_∞ > 0 and √(−g_00) > 0. -/
theorem entropicRedshiftedBeta_pos
    (betaInf sqrtF : ℝ) (h1 : 0 < betaInf) (h2 : 0 < sqrtF) :
    0 < entropicRedshiftedBeta betaInf sqrtF :=
  mul_pos h1 h2

/-- EEEP: β_I(x) = 0 ↔ β_∞ = 0 or √(−g_00) = 0. -/
theorem entropicRedshiftedBeta_zero_iff (betaInf sqrtF : ℝ) :
    entropicRedshiftedBeta betaInf sqrtF = 0 ↔ betaInf = 0 ∨ sqrtF = 0 :=
  mul_eq_zero

-- ── Modular slope criterion ───────────────────────────────────────────────────

/-- EEEP: Modular slope criterion is asymmetric (strict). -/
theorem modularSlopeCriterion_asymm (uA uB : ℝ)
    (h : modularSlopeCriterion uA uB) : ¬ modularSlopeCriterion uB uA := by
  unfold modularSlopeCriterion at *; linarith

/-- EEEP: Modular slope criterion is transitive. -/
theorem modularSlopeCriterion_trans (uA uB uC : ℝ)
    (hAB : modularSlopeCriterion uA uB) (hBC : modularSlopeCriterion uB uC) :
    modularSlopeCriterion uA uC := by
  unfold modularSlopeCriterion at *; linarith

/-- EEEP: Modular slope criterion is irreflexive. -/
theorem modularSlopeCriterion_irrefl (u : ℝ) :
    ¬ modularSlopeCriterion u u := lt_irrefl u

-- ── CAT/EPT–EEEP rate matching ───────────────────────────────────────────────

/-- CAT/EPT–EEEP bridge: kB · T_loc = ħ a_loc / (2π c).
    Identifies the dissipative-sector rate with the Rindler imaginary-Hamiltonian rate.
    The kB factor in the Unruh formula and in the entropic action cancel. -/
theorem cat_ept_unruh_rate_formula
    (pc : PhysicalConstants) (aLoc : ℝ) :
    pc.kB * localUnruhTemperature pc aLoc =
    pc.hbar * aLoc / (2 * Real.pi * pc.c) := by
  unfold localUnruhTemperature
  have hkB : pc.kB ≠ 0 := pc.kB_pos.ne'
  have hc  : pc.c  ≠ 0 := pc.c_pos.ne'
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp

/-- CAT/EPT–EEEP: Rate vanishes in the flat/inertial sector (a_loc = 0). -/
theorem cat_ept_unruh_rate_zero_flat (pc : PhysicalConstants) :
    pc.kB * localUnruhTemperature pc 0 = 0 := by
  simp [cat_ept_unruh_rate_formula]

-- ── Entropic stress tensor ────────────────────────────────────────────────────

/-- EEEP: Entropic stress ≥ 0 in the physical regime. -/
theorem entropicStressScalar_nonneg
    (pc : PhysicalConstants)
    (sigmaTerm zeta theta lam gradThetaSq : ℝ)
    (hσ : 0 ≤ sigmaTerm) (hζ : 0 ≤ zeta) (hθ : 0 ≤ theta)
    (hl : 0 ≤ lam) (hg : 0 ≤ gradThetaSq) :
    0 ≤ entropicStressScalar pc sigmaTerm zeta theta lam gradThetaSq :=
  add_nonneg
    (mul_nonneg (div_nonneg pc.hbar_pos.le pc.kB_pos.le)
      (add_nonneg hσ (mul_nonneg hζ hθ)))
    (mul_nonneg hl hg)

/-- CAT/EPT flat sector: Stress tensor vanishes when shear, expansion,
    and gradient all vanish (pure inertial frame → no dissipation). -/
theorem entropicStressScalar_flat_sector
    (pc : PhysicalConstants) (zeta lam : ℝ) :
    entropicStressScalar pc 0 zeta 0 lam 0 = 0 := by
  simp [entropicStressScalar]

end CATEPT

end -- noncomputable section
