import Mathlib
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic

noncomputable section

set_option autoImplicit false

/-!
# Entropic Locality Lemmas

Proved lemmas for the Entropic Locality Principle (ELP) and its embedding
into the CAT/EPT framework (Section XI).

The ELP states:
  - Irreversible effects originate locally from the modular Hamiltonian K_A
  - Θ(x) = ⟨K_{Ax}⟩ is the entropic time field controlling local relaxation
  - No superluminal entropic influences (microcausality preserved)
  - Dissipation rate matches the local Unruh/Rindler rate kB T_loc
  - In the flat sector (∇Θ = 0) all dissipative effects vanish
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

/-- Entropic action: SI(A) = (ħ/kB) Sent(A),  δSent = δ⟨K_A⟩. -/
def entropicActionOfEntropy (pc : PhysicalConstants) (Sent : ℝ) : ℝ :=
  (pc.hbar / pc.kB) * Sent

/-- Entropic time field: Θ(x) = ⟨K_{Ax}⟩. -/
def entropicTimeField (Kexp : Type → ℝ) (Ax : Type) : ℝ := Kexp Ax

/-- Entropic force density: F_T = λ · (projector · ∇Θ) (scalar reduction). -/
def entropicForceDensity (lam gradTheta : ℝ) : ℝ := lam * gradTheta

/-- Local Unruh/Rindler temperature: T_loc = ħ a_loc / (2π kB c). -/
def localUnruhTemperature (pc : PhysicalConstants) (aLoc : ℝ) : ℝ :=
  pc.hbar * aLoc / (2 * Real.pi * pc.kB * pc.c)

/-- Tolman redshift law: β_I(x) = β_∞ √(−g_00). -/
def entropicRedshiftedBeta (betaInf sqrtFactor : ℝ) : ℝ :=
  betaInf * sqrtFactor

/-- Entropic stress tensor scalar: (ħ/kB)(σ·σ + ζθ) + λ|∇Θ|². -/
def entropicStressScalar (pc : PhysicalConstants)
    (sigmaTerm zeta theta lam gradThetaSq : ℝ) : ℝ :=
  (pc.hbar / pc.kB) * (sigmaTerm + zeta * theta) + lam * gradThetaSq

/-- Flat entropic sector: ∇Θ = 0. -/
def FlatEntropicSector (ThetaGrad : ℝ) : Prop := ThetaGrad = 0

-- ── helpers ──────────────────────────────────────────────────────────────────

private lemma denom_pos (pc : PhysicalConstants) :
    0 < 2 * Real.pi * pc.kB * pc.c :=
  mul_pos (mul_pos (mul_pos (by norm_num) Real.pi_pos) pc.kB_pos) pc.c_pos

-- ── Entropic time field ───────────────────────────────────────────────────────

/-- ELP: The entropic time field evaluates to the modular expectation. -/
theorem entropicTimeField_eval (Kexp : Type → ℝ) (Ax : Type) :
    entropicTimeField Kexp Ax = Kexp Ax := rfl

/-- ELP: If the modular expectation is spatially constant, Θ is uniform. -/
theorem entropicTimeField_uniform
    (Kexp : Type → ℝ) (val : ℝ) (hK : ∀ A, Kexp A = val) (Ax : Type) :
    entropicTimeField Kexp Ax = val := hK Ax

-- ── Entropic action ───────────────────────────────────────────────────────────

/-- ELP: SI is a positive scaling of thermodynamic entropy (ħ/kB > 0). -/
theorem entropicActionScale_pos (pc : PhysicalConstants) :
    0 < pc.hbar / pc.kB :=
  div_pos pc.hbar_pos pc.kB_pos

/-- ELP: SI is linear in Sent. -/
theorem entropicActionOfEntropy_linear
    (pc : PhysicalConstants) (s₁ s₂ : ℝ) :
    entropicActionOfEntropy pc (s₁ + s₂) =
    entropicActionOfEntropy pc s₁ + entropicActionOfEntropy pc s₂ := by
  unfold entropicActionOfEntropy; ring

/-- ELP: SI is monotone — more entropy → larger entropic action. -/
theorem entropicActionOfEntropy_mono
    (pc : PhysicalConstants) (s₁ s₂ : ℝ) (h : s₁ ≤ s₂) :
    entropicActionOfEntropy pc s₁ ≤ entropicActionOfEntropy pc s₂ :=
  mul_le_mul_of_nonneg_left h (entropicActionScale_pos pc).le

/-- ELP: SI is strictly monotone. -/
theorem entropicActionOfEntropy_strictMono
    (pc : PhysicalConstants) (s₁ s₂ : ℝ) (h : s₁ < s₂) :
    entropicActionOfEntropy pc s₁ < entropicActionOfEntropy pc s₂ :=
  mul_lt_mul_of_pos_left h (entropicActionScale_pos pc)

/-- ELP: SI ≥ 0 when Sent ≥ 0. -/
theorem entropicActionOfEntropy_nonneg
    (pc : PhysicalConstants) (Sent : ℝ) (hS : 0 ≤ Sent) :
    0 ≤ entropicActionOfEntropy pc Sent :=
  mul_nonneg (entropicActionScale_pos pc).le hS

-- ── Entropic force and flat sector ───────────────────────────────────────────

/-- ELP: F_T = 0 when ∇Θ = 0 (flat sector kills the entropic force). -/
theorem entropicForceDensity_flat_sector (lam ThetaGrad : ℝ)
    (hflat : FlatEntropicSector ThetaGrad) :
    entropicForceDensity lam ThetaGrad = 0 := by
  unfold FlatEntropicSector at hflat
  simp [entropicForceDensity, hflat]

/-- ELP: F_T = 0 iff λ = 0 or ∇Θ = 0. -/
theorem entropicForceDensity_zero_iff (lam gradTheta : ℝ) :
    entropicForceDensity lam gradTheta = 0 ↔ lam = 0 ∨ gradTheta = 0 :=
  mul_eq_zero

/-- ELP: When λ > 0, F_T has the same sign as ∇Θ. -/
theorem entropicForceDensity_nonneg_iff_grad_nonneg
    (lam gradTheta : ℝ) (hlam : 0 < lam) :
    0 ≤ entropicForceDensity lam gradTheta ↔ 0 ≤ gradTheta := by
  unfold entropicForceDensity
  constructor
  · intro h
    have := nonneg_of_mul_nonneg_left (a := gradTheta) (b := lam)
      (by rwa [mul_comm]) hlam
    exact this
  · exact fun h => mul_nonneg hlam.le h

/-- ELP: F_T > 0 when λ > 0 and ∇Θ > 0 (force along gradient). -/
theorem entropicForceDensity_pos
    (lam gradTheta : ℝ) (hl : 0 < lam) (hg : 0 < gradTheta) :
    0 < entropicForceDensity lam gradTheta :=
  mul_pos hl hg

-- ── Local Unruh temperature ───────────────────────────────────────────────────

/-- ELP: T_loc ≥ 0 when a_loc ≥ 0 (no negative temperature from locality). -/
theorem localUnruhTemperature_nonneg
    (pc : PhysicalConstants) (aLoc : ℝ) (haLoc : 0 ≤ aLoc) :
    0 ≤ localUnruhTemperature pc aLoc :=
  div_nonneg (mul_nonneg pc.hbar_pos.le haLoc) (denom_pos pc).le

/-- ELP: T_loc > 0 iff a_loc > 0 (positive acceleration → Rindler radiation). -/
theorem localUnruhTemperature_pos_iff
    (pc : PhysicalConstants) (aLoc : ℝ) :
    0 < localUnruhTemperature pc aLoc ↔ 0 < aLoc := by
  constructor
  · intro h
    by_contra hle
    push_neg at hle  -- hle : aLoc ≤ 0
    have hnum : pc.hbar * aLoc ≤ 0 :=
      mul_nonpos_of_nonneg_of_nonpos pc.hbar_pos.le hle
    have htmp : localUnruhTemperature pc aLoc ≤ 0 :=
      div_nonpos_of_nonpos_of_nonneg hnum (denom_pos pc).le
    linarith
  · intro h
    exact div_pos (mul_pos pc.hbar_pos h) (denom_pos pc)

-- ── Tolman beta ───────────────────────────────────────────────────────────────

/-- ELP: Tolman beta is nonneg when both factors are nonneg. -/
theorem entropicRedshiftedBeta_nonneg
    (betaInf sqrtF : ℝ) (h1 : 0 ≤ betaInf) (h2 : 0 ≤ sqrtF) :
    0 ≤ entropicRedshiftedBeta betaInf sqrtF :=
  mul_nonneg h1 h2

/-- ELP: In flat spacetime (√(−g_00) = 1), β_I = β_∞. -/
theorem entropicRedshiftedBeta_flat_spacetime (betaInf : ℝ) :
    entropicRedshiftedBeta betaInf 1 = betaInf := mul_one betaInf

/-- ELP: β_I is monotone in β_∞. -/
theorem entropicRedshiftedBeta_mono
    (betaInf₁ betaInf₂ sqrtF : ℝ) (h : betaInf₁ ≤ betaInf₂) (hf : 0 ≤ sqrtF) :
    entropicRedshiftedBeta betaInf₁ sqrtF ≤ entropicRedshiftedBeta betaInf₂ sqrtF :=
  mul_le_mul_of_nonneg_right h hf

-- ── Entropic stress tensor ────────────────────────────────────────────────────

/-- ELP: Entropic stress ≥ 0 in the physical regime. -/
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

/-- ELP flat sector: Entropic stress vanishes when shear, expansion, and
    gradient all vanish → unitary (Schrödinger) limit. -/
theorem entropicStressScalar_flat_sector
    (pc : PhysicalConstants) (zeta lam : ℝ) :
    entropicStressScalar pc 0 zeta 0 lam 0 = 0 := by
  simp [entropicStressScalar]

/-- ELP: Entropic stress is additive in the gradient-coupling term. -/
theorem entropicStressScalar_lam_additive
    (pc : PhysicalConstants) (sigT zeta theta lam₁ lam₂ g : ℝ) :
    entropicStressScalar pc sigT zeta theta (lam₁ + lam₂) g =
    entropicStressScalar pc sigT zeta theta lam₁ g +
    entropicStressScalar pc sigT zeta theta lam₂ g -
    (pc.hbar / pc.kB) * (sigT + zeta * theta) := by
  unfold entropicStressScalar; ring

-- ── Dissipative rate monotonicity ────────────────────────────────────────────

/-- ELP + CAT/EPT: The local dissipative rate kB T_loc is monotone in acceleration.
    Greater local curvature → stronger open-system dissipation. -/
theorem cat_ept_dissipative_rate_mono
    (pc : PhysicalConstants) (a₁ a₂ : ℝ) (h : a₁ ≤ a₂) :
    pc.kB * localUnruhTemperature pc a₁ ≤ pc.kB * localUnruhTemperature pc a₂ := by
  apply mul_le_mul_of_nonneg_left _ pc.kB_pos.le
  unfold localUnruhTemperature
  simp only [div_eq_mul_inv]
  apply mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left h pc.hbar_pos.le)
  exact inv_nonneg.mpr (denom_pos pc).le

/-- ELP flat sector: Dissipative rate vanishes when ∇Θ = 0 (a_loc = 0). -/
theorem cat_ept_dissipative_rate_flat
    (pc : PhysicalConstants) :
    pc.kB * localUnruhTemperature pc 0 = 0 := by
  unfold localUnruhTemperature; simp

end CATEPT

end -- noncomputable section
