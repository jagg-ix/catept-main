import CATEPTMain.CATEPT.Foundations
import CATEPTMain.CATEPT.PathIntegrals
import CATEPTMain.CATEPT.UnitsDimensionalAnalysis
import Mathlib

set_option autoImplicit false

namespace CATEPTMain.CATEPT

noncomputable section

/-- Real 4-potential carrier `A^μ` for core-safe EM bridge contracts. -/
abbrev FourPotential : Type := Fin 4 → ℝ

/-- Euclidean norm-square `Σ_μ (A^μ)^2`. -/
def potentialNormSq (A : FourPotential) : ℝ :=
  ∑ μ : Fin 4, (A μ) ^ 2

/-- Gaussian EM imaginary action `S_I^EM = ||A||^2 / (2 μ0)`. -/
def emImaginaryAction (mu0 : ℝ) (A : FourPotential) : ℝ :=
  potentialNormSq A / (2 * mu0)

theorem potentialNormSq_nonneg (A : FourPotential) :
    0 ≤ potentialNormSq A := by
  unfold potentialNormSq
  exact Finset.sum_nonneg (fun μ _ => sq_nonneg (A μ))

theorem emImaginaryAction_nonneg
    (mu0 : ℝ) (hmu0 : 0 < mu0) (A : FourPotential) :
    0 ≤ emImaginaryAction mu0 A := by
  unfold emImaginaryAction
  exact div_nonneg (potentialNormSq_nonneg A)
    (le_of_lt (mul_pos two_pos hmu0))

/-- Entropic time induced by the EM imaginary action. -/
def emEntropicTime (hbar mu0 : ℝ) (A : FourPotential) : ℝ :=
  entropic_time hbar (emImaginaryAction mu0 A)

theorem emEntropicTime_nonneg
    (hbar mu0 : ℝ)
    (hhbar : 0 < hbar)
    (hmu0 : 0 < mu0)
    (A : FourPotential) :
    0 ≤ emEntropicTime hbar mu0 A :=
  eq003_entropic_time_nonneg hbar (emImaginaryAction mu0 A) hhbar
    (emImaginaryAction_nonneg mu0 hmu0 A)

/-- EM damping weight in CAT/EPT form `exp(-S_I^EM/hbar)`. -/
def emDampingWeight (hbar mu0 : ℝ) (A : FourPotential) : ℝ :=
  path_integral_damping hbar (emImaginaryAction mu0 A)

theorem emDampingWeight_nonneg (hbar mu0 : ℝ) (A : FourPotential) :
    0 ≤ emDampingWeight hbar mu0 A := by
  unfold emDampingWeight path_integral_damping
  exact Real.exp_nonneg _

theorem emDampingWeight_le_one
    (hbar mu0 : ℝ)
    (hhbar : 0 < hbar)
    (hmu0 : 0 < mu0)
    (A : FourPotential) :
    emDampingWeight hbar mu0 A ≤ 1 := by
  unfold emDampingWeight path_integral_damping
  rw [Real.exp_le_one_iff]
  have hnonneg : 0 ≤ emImaginaryAction mu0 A :=
    emImaginaryAction_nonneg mu0 hmu0 A
  have hfrac : 0 ≤ emImaginaryAction mu0 A / hbar :=
    div_nonneg hnonneg hhbar.le
  have h : -(emImaginaryAction mu0 A) / hbar = -(emImaginaryAction mu0 A / hbar) := neg_div _ _; rw [h]; linarith

/-- EM weight as an FK/Gibbs damping with potential `S_I^EM`. -/
def emFeynmanKacWeight (mu0 beta : ℝ) (A : FourPotential) : ℝ :=
  feynman_kac_weight (fun x => emImaginaryAction mu0 x) beta A

theorem emFeynmanKacWeight_nonneg (mu0 beta : ℝ) (A : FourPotential) :
    0 ≤ emFeynmanKacWeight mu0 beta A := by
  unfold emFeynmanKacWeight feynman_kac_weight
  exact Real.exp_nonneg _

/-- Witness contract for EM integration into the core CAT/EPT lane. -/
structure ElectromagnetismCompatibilityWitness where
  faradayTensorAvailable : Prop
  maxwellEquationsAvailable : Prop
  gaugeInvarianceAvailable : Prop
  gaussianPathMeasureAvailable : Prop
  emActionNonnegative : Prop
  emClockCompatibility : Prop

def electromagnetismCompatibilityContract
    (w : ElectromagnetismCompatibilityWitness) : Prop :=
  w.faradayTensorAvailable ∧
    w.maxwellEquationsAvailable ∧
    w.gaugeInvarianceAvailable ∧
    w.gaussianPathMeasureAvailable ∧
    w.emActionNonnegative ∧
    w.emClockCompatibility

theorem electromagnetismCompatibility_contract_of_fields
    (w : ElectromagnetismCompatibilityWitness)
    (h1 : w.faradayTensorAvailable)
    (h2 : w.maxwellEquationsAvailable)
    (h3 : w.gaugeInvarianceAvailable)
    (h4 : w.gaussianPathMeasureAvailable)
    (h5 : w.emActionNonnegative)
    (h6 : w.emClockCompatibility) :
    electromagnetismCompatibilityContract w :=
  ⟨h1, h2, h3, h4, h5, h6⟩


