import CATEPT.PhysicalConstants
import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.Calculus.Deriv.Basic

noncomputable section

set_option autoImplicit false

namespace CATEPT

open Complex
open Real

structure DampedOscillatorParams where
  m : ℝ
  k : ℝ
  gamma : ℝ
  m_pos : 0 < m
  gamma_nonneg : 0 ≤ gamma

def mechanicalEnergy (p : DampedOscillatorParams) (x v : ℝ) : ℝ :=
  (p.m / 2) * v^2 + (p.k / 2) * x^2

structure OscillatorJet where
  x : ℝ
  v : ℝ
  a : ℝ

def JetSatisfiesDampedEquation (p : DampedOscillatorParams) (J : OscillatorJet) : Prop :=
  p.m * J.a + p.k * J.x = - p.gamma * J.v

def mechanicalEnergyDerivAtJet (p : DampedOscillatorParams) (J : OscillatorJet) : ℝ :=
  p.m * J.v * J.a + p.k * J.x * J.v

theorem jet_dampedEquation_implies_energyBalance
    (p : DampedOscillatorParams) (J : OscillatorJet)
    (hJ : JetSatisfiesDampedEquation p J) :
    mechanicalEnergyDerivAtJet p J = - p.gamma * J.v^2 := by
  unfold mechanicalEnergyDerivAtJet
  unfold JetSatisfiesDampedEquation at hJ
  calc
    p.m * J.v * J.a + p.k * J.x * J.v = (p.m * J.a + p.k * J.x) * J.v := by ring
    _ = (- p.gamma * J.v) * J.v := by rw [hJ]
    _ = - p.gamma * J.v^2 := by ring

end CATEPT
