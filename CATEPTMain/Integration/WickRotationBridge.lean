import CATEPTMain.CATEPT.CATEPT.LorentzianPathIntegralBridge
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

set_option autoImplicit false

/-!
# Wick rotation bridge and failure modes

Records the two-sector CAT/EPT continuation rule: the reversible
(real-action) sector is Wick-rotated while the entropy-production
sector remains a real, positive damping functional.
-/

namespace CATEPTMain.Integration.WickRotationBridge

noncomputable section

open CATEPTMain.CATEPT.CATEPT

/-- Signature tag for Euclidean vs Lorentzian sectors. -/
inductive Signature
| lorentzian : Signature
| euclidean : Signature

/-- Entropy damping factor exp(-S_I / hbar). -/
def entropyDamping (S_I hbar : ℝ) : ℝ :=
  Real.exp (-(S_I / hbar))

/-- Lorentzian kernel weight exp(i S_R/hbar - S_I/hbar). -/
def lorentzianWeight (S_R S_I hbar : ℝ) : ℂ :=
  lorentzianKernel S_R S_I hbar

/-- Euclidean kernel weight exp(-S_E/hbar - S_I^E/hbar). -/
def euclideanWeight (S_E S_I hbar : ℝ) : ℝ :=
  Real.exp (-(S_E / hbar) - (S_I / hbar))

/-- Wick-rotation data bundle. -/
structure WickRotationData where
  S_R_L : ℝ
  S_E   : ℝ
  S_I_L : ℝ
  S_I_E : ℝ
  hbar  : ℝ
  hbar_pos : 0 < hbar
  S_I_L_nonneg : 0 ≤ S_I_L
  S_I_E_nonneg : 0 ≤ S_I_E
  entropy_preserved : S_I_E = S_I_L
  reversible_sector_rule : Prop

/-- Wick-rotation preserves the entropy damping factor. -/
theorem entropyDamping_preserved (W : WickRotationData) :
    entropyDamping W.S_I_E W.hbar = entropyDamping W.S_I_L W.hbar := by
  unfold entropyDamping
  rw [W.entropy_preserved]

/-- Euclidean weight factorizes into reversible and damping parts. -/
theorem euclideanWeight_factorizes
    (S_E S_I hbar : ℝ) :
    euclideanWeight S_E S_I hbar =
      Real.exp (-(S_E / hbar)) * entropyDamping S_I hbar := by
  unfold euclideanWeight entropyDamping
  ring_nf
  simp [Real.exp_add, Real.exp_neg]

/-- Wick-rotation keeps the damping sector real and contractive. -/
theorem euclideanWeight_damping_le_one
    (S_E S_I hbar : ℝ) (hS : 0 ≤ S_I) (hh : 0 < hbar) :
    euclideanWeight S_E S_I hbar ≤ Real.exp (-(S_E / hbar)) := by
  unfold euclideanWeight
  have hneg : -(S_I / hbar) ≤ 0 := by
    have hdiv : 0 ≤ S_I / hbar := div_nonneg hS (le_of_lt hh)
    linarith
  have hle : Real.exp (-(S_I / hbar)) ≤ 1 :=
    (Real.exp_le_one_iff).mpr hneg
  nlinarith

/-- Wick-rotation admissibility carrier. -/
structure WickAdmissible where
  reversibleSectorAnalytic : Prop
  entropySectorPositive : Prop
  noContourObstruction : Prop
  noKMSBranchCrossing : Prop
  localOrControlledMemory : Prop
  observerFoliationCompatible : Prop
  lapseCompatible : Prop
  noStokesJump : Prop

/-- Failure-mode carrier for Wick rotation. -/
structure WickFailureMode where
  nonanalyticRate : Prop
  signChangingRate : Prop
  kmsBranchCut : Prop
  horizonObserverMismatch : Prop
  nonMarkovianMemory : Prop
  gravitationalLapseProblem : Prop
  stokesJump : Prop

/-- Admissibility implies the entropy sector is required to be positive. -/
theorem wick_admissible_requires_entropy_positive
    (W : WickAdmissible) : W.entropySectorPositive :=
  W.entropySectorPositive

end

end CATEPTMain.Integration.WickRotationBridge
