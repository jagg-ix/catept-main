import Mathlib.Data.Int.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Sqrt
import CATEPT.Foundations

set_option autoImplicit false

namespace CATEPT

noncomputable section

/-! # Bell/CHSH and Bohm Core Abstractions

Core-safe abstractions extracted from richer Bell/CHSH/Bohm integration lanes.
This file intentionally avoids heavy matrix/circuit dependencies while keeping
reusable theorem contracts for downstream bridges.
-/

/-- Deterministic CHSH assignment with binary outcomes in `{+1, -1}`. -/
structure CHSHDeterministicAssignment where
  a : Int
  aPrime : Int
  b : Int
  bPrime : Int
  ha : a = 1 ∨ a = -1
  haPrime : aPrime = 1 ∨ aPrime = -1
  hb : b = 1 ∨ b = -1
  hbPrime : bPrime = 1 ∨ bPrime = -1

/-- Classical CHSH polynomial in deterministic hidden-variable form. -/
def classicalCHSHValue (x : CHSHDeterministicAssignment) : Int :=
  x.a * x.b + x.a * x.bPrime + x.aPrime * x.b - x.aPrime * x.bPrime

/-- Classical Bell/CHSH inequality `|S| <= 2` for deterministic `+-1` outcomes. -/
theorem classicalCHSH_bound (x : CHSHDeterministicAssignment) :
    |classicalCHSHValue x| <= 2 := by
  rcases x.ha with hA | hA <;>
  rcases x.haPrime with hAP | hAP <;>
  rcases x.hb with hB | hB <;>
  rcases x.hbPrime with hBP | hBP
  all_goals
    simp [classicalCHSHValue, hA, hAP, hB, hBP]

/-- Tsirelson witness value `2 * sqrt 2`. -/
def tsirelsonWitness : Real :=
  2 * Real.sqrt 2

theorem classical_bound_le_two : (2 : Real) <= tsirelsonWitness := by
  unfold tsirelsonWitness
  have hsqrt : 1 <= Real.sqrt 2 := by
    have h : (1 : Real)^2 <= 2 := by norm_num
    have hs := Real.sq_sqrt (show (0 : Real) <= 2 by norm_num)
    nlinarith [h, hs, Real.sqrt_nonneg 2]
  nlinarith

theorem classical_bound_lt_tsirelson : (2 : Real) < tsirelsonWitness := by
  unfold tsirelsonWitness
  have hsqrt2 : (Real.sqrt 2) ^ 2 = 2 := by
    have h : (0 : Real) <= 2 := by norm_num
    simpa [sq] using Real.sq_sqrt h
  have hpos : 0 < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)
  nlinarith [hsqrt2, hpos]

/-- Bell-rate proxy used in entropic-time bridges. -/
def bellRateFromEntropicRate (entropicRate : Real) : Real :=
  Real.exp entropicRate - 1

theorem bellRate_rearranged (entropicRate : Real) :
    bellRateFromEntropicRate entropicRate + 1 = Real.exp entropicRate := by
  unfold bellRateFromEntropicRate
  ring

/-- Minimal Bohm pilot-wave state for core-level bridge contracts. -/
structure BohmPilotState where
  amplitude : Real
  amplitude_nonneg : 0 <= amplitude
  phase : Real
  mass : Real
  mass_pos : 0 < mass
  hbar : Real
  hbar_pos : 0 < hbar

/-- Bohm/Madelung density `rho = R^2`. -/
def bohmDensity (s : BohmPilotState) : Real :=
  s.amplitude ^ 2

/-- Guidance-velocity proxy `v = S / (m * hbar)`. -/
def bohmGuidanceVelocity (s : BohmPilotState) : Real :=
  s.phase / (s.mass * s.hbar)

/-- Quantum-potential prefactor `-(hbar^2)/(2m)`. -/
def bohmQuantumPotentialScale (s : BohmPilotState) : Real :=
  -(s.hbar ^ 2) / (2 * s.mass)

theorem bohmDensity_nonneg (s : BohmPilotState) :
    0 <= bohmDensity s := by
  unfold bohmDensity
  positivity

theorem bohmGuidance_denom_pos (s : BohmPilotState) :
    0 < s.mass * s.hbar :=
  mul_pos s.mass_pos s.hbar_pos

theorem bohmQuantumPotentialScale_neg (s : BohmPilotState) :
    bohmQuantumPotentialScale s < 0 := by
  unfold bohmQuantumPotentialScale
  apply div_neg_of_neg_of_pos
  · nlinarith [sq_pos_of_pos s.hbar_pos]
  · exact mul_pos two_pos s.mass_pos

/-- Entropic-time specialization for Bohm bridges. -/
def bohmEntropicTime (hbar S_I : Real) : Real :=
  entropic_time hbar S_I

theorem bohmEntropicTime_eq (hbar S_I : Real) :
    bohmEntropicTime hbar S_I = S_I / hbar := rfl

theorem bohmEntropicTime_nonneg
    (hbar S_I : Real) (hh : 0 < hbar) (hS : 0 <= S_I) :
    0 <= bohmEntropicTime hbar S_I :=
  eq003_entropic_time_nonneg hbar S_I hh hS

/-- Core contract packaging Bell/CHSH and Bohm compatibility obligations. -/
structure BellBohmCompatibilityWitness where
  classicalCHSHBoundAvailable : Prop
  tsirelsonWitnessAvailable : Prop
  bohmGuidanceWellPosed : Prop
  bohmEntropicTimeAvailable : Prop
  noSignalingStructural : Prop

def bellBohmCompatibilityContract (w : BellBohmCompatibilityWitness) : Prop :=
  w.classicalCHSHBoundAvailable ∧
    w.tsirelsonWitnessAvailable ∧
    w.bohmGuidanceWellPosed ∧
    w.bohmEntropicTimeAvailable ∧
    w.noSignalingStructural

theorem bellBohmCompatibility_contract_of_fields
    (w : BellBohmCompatibilityWitness)
    (h1 : w.classicalCHSHBoundAvailable)
    (h2 : w.tsirelsonWitnessAvailable)
    (h3 : w.bohmGuidanceWellPosed)
    (h4 : w.bohmEntropicTimeAvailable)
    (h5 : w.noSignalingStructural) :
    bellBohmCompatibilityContract w :=
  ⟨h1, h2, h3, h4, h5⟩

end

end CATEPT
