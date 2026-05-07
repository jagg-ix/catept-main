import CATEPTMain.CATEPT.CATEPT.CATEPTPrelude
import CATEPTMain.CATEPT.CATEPT.LorentzianPathIntegralBridge
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

set_option autoImplicit false

/-!
# Operator-theoretic foundation for CAT/EPT evolution

This module records the operator-layer objects behind the Lorentzian and
Euclidean CAT/EPT path integrals, using the scalar proxy definitions that
match the existing CAT/EPT complex-action conventions.
-/

namespace CATEPTMain.Integration.OperatorPathIntegralFoundation

noncomputable section

open CATEPTMain.CATEPT.CATEPT

/-- Lorentzian CAT/EPT generator A_L = -(i/hbar) H_R - (1/hbar) H_I. -/
def lorentzianGenerator (H : ComplexHamiltonian) (hbar : ℝ) : ℂ :=
  (-(H.H_I / hbar) : ℂ) + (-(H.H_R / hbar) : ℂ) * Complex.I

/-- Euclidean CAT/EPT generator A_E = -(H_R + H_I)/hbar. -/
def euclideanGenerator (H : ComplexHamiltonian) (hbar : ℝ) : ℝ :=
  -(H.H_R + H.H_I) / hbar

/-- Lorentzian evolution from the generator: U_L(t) = exp(t A_L). -/
def lorentzianEvolution (H : ComplexHamiltonian) (t hbar : ℝ) : ℂ :=
  Complex.exp (t * lorentzianGenerator H hbar)

/-- Lorentzian evolution equals the CAT/EPT Lorentzian propagator. -/
theorem lorentzianEvolution_eq_propagator
    (H : ComplexHamiltonian) (t hbar : ℝ) :
    lorentzianEvolution H t hbar = lorentzianPropagator H t hbar := by
  unfold lorentzianEvolution lorentzianGenerator lorentzianPropagator
  unfold lorentzianKernel
  congr 1
  push_cast
  ring

/-- Dissipativity: the real part of A_L is non-positive when H_I >= 0. -/
theorem lorentzianGenerator_re_nonpos
    (H : ComplexHamiltonian) (hbar : ℝ) (hh : 0 < hbar) :
    (lorentzianGenerator H hbar).re ≤ 0 := by
  unfold lorentzianGenerator
  simp [Complex.add_re, Complex.mul_re, Complex.I_re, Complex.I_im]
  have hdiv : 0 ≤ H.H_I / hbar :=
    div_nonneg H.H_I_nonneg (le_of_lt hh)
  linarith

/-- Contraction bound for Lorentzian evolution. -/
theorem lorentzianEvolution_norm_le_one
    (H : ComplexHamiltonian) (t hbar : ℝ)
    (ht : 0 ≤ t) (hh : 0 < hbar) :
    ‖lorentzianEvolution H t hbar‖ ≤ 1 := by
  rw [lorentzianEvolution_eq_propagator]
  exact lorentzianPropagator_norm_le_one H t hbar ht hh

/-- Unitary limit: if H_I = 0 then the Lorentzian evolution has unit norm. -/
theorem lorentzianEvolution_norm_one_of_HI_zero
    (H : ComplexHamiltonian) (t hbar : ℝ) (hI : H.H_I = 0) :
    ‖lorentzianEvolution H t hbar‖ = 1 := by
  rw [lorentzianEvolution_eq_propagator, lorentzianPropagator_norm_is_damping]
  simp [hI]

end

end CATEPTMain.Integration.OperatorPathIntegralFoundation
