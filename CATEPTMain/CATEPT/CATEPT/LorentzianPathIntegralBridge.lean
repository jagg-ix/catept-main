import CATEPTMain.CATEPT.CATEPT.CATEPTPrelude
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

noncomputable section

/-- Lorentzian CAT/EPT kernel for a complex action. -/
def lorentzianKernel (S_R S_I hbar : ℝ) : ℂ :=
  Complex.exp (((S_R / hbar : ℂ) * Complex.I) - (S_I / hbar : ℂ))

/-- Lorentzian kernel factorizes into phase times damping. -/
theorem lorentzianKernel_factorizes (S_R S_I hbar : ℝ) :
    lorentzianKernel S_R S_I hbar =
      Complex.exp ((S_R / hbar : ℂ) * Complex.I) *
      (Real.exp (-(S_I / hbar)) : ℂ) := by
  unfold lorentzianKernel
  have hreal : (Real.exp (-(S_I / hbar)) : ℂ) =
      Complex.exp (-(S_I / hbar : ℂ)) := by
    simp [Complex.ofReal_exp, Complex.ofReal_neg]
  rw [hreal, sub_eq_add_neg, Complex.exp_add]

/-- Norm of the Lorentzian kernel equals the damping factor. -/
theorem lorentzianKernel_norm_is_damping (S_R S_I hbar : ℝ) :
    ‖lorentzianKernel S_R S_I hbar‖ = Real.exp (-(S_I / hbar)) := by
  rw [lorentzianKernel_factorizes, norm_mul]
  have hphase : ‖Complex.exp ((S_R / hbar : ℂ) * Complex.I)‖ = 1 :=
    Complex.norm_exp_ofReal_mul_I _
  rw [hphase, one_mul]
  rw [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]

/-- Alias: Lorentzian weight for a measure path integral model. -/
def lorentzianWeight {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) : α → ℂ :=
  m.weight

/-- The Lorentzian weight has norm equal to the damping factor. -/
theorem lorentzianWeight_norm_is_damping
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (x : α) :
    ‖lorentzianWeight m x‖ = Real.exp (-(m.actionImScaled x)) :=
  m.weight_norm_is_damping x

/-- Lorentzian propagator for a non-Hermitian Hamiltonian H_R - i H_I. -/
def lorentzianPropagator (H : ComplexHamiltonian) (t hbar : ℝ) : ℂ :=
  lorentzianKernel (-(t * H.H_R)) (t * H.H_I) hbar

/-- Norm of the Lorentzian propagator equals the damping factor. -/
theorem lorentzianPropagator_norm_is_damping
    (H : ComplexHamiltonian) (t hbar : ℝ) :
    ‖lorentzianPropagator H t hbar‖ = Real.exp (-(t * H.H_I / hbar)) := by
  unfold lorentzianPropagator
  -- S_I = t * H_I in the Hamiltonian evolution slice
  simpa [lorentzianKernel_norm_is_damping, mul_div_assoc] using
    (lorentzianKernel_norm_is_damping (S_R := -(t * H.H_R))
      (S_I := t * H.H_I) (hbar := hbar))

/-- Damping bound for forward-time evolution. -/
theorem lorentzianPropagator_norm_le_one
    (H : ComplexHamiltonian) (t hbar : ℝ)
    (ht : 0 ≤ t) (hh : 0 < hbar) :
    ‖lorentzianPropagator H t hbar‖ ≤ 1 := by
  rw [lorentzianPropagator_norm_is_damping]
  have hI : 0 ≤ H.H_I := H.H_I_nonneg
  have hnonpos : -(t * H.H_I / hbar) ≤ 0 := by
    have hnum : 0 ≤ t * H.H_I := mul_nonneg ht hI
    have hdiv : 0 ≤ t * H.H_I / hbar :=
      div_nonneg hnum (le_of_lt hh)
    linarith
  simpa [Real.exp_le_one_iff] using hnonpos

/-- Trotter step for the Lorentzian evolution (formal splitting). -/
def lorentzianTrotterStep (H : ComplexHamiltonian) (dt hbar : ℝ) : ℂ :=
  Complex.exp ((-(dt * H.H_R) / hbar : ℂ) * Complex.I) *
    (Real.exp (-(dt * H.H_I / hbar)) : ℂ)

/-- Discrete Trotter product with `n+1` steps (avoids division by zero). -/
def lorentzianTrotterProduct (H : ComplexHamiltonian) (t hbar : ℝ) (n : ℕ) : ℂ :=
  let steps : ℝ := (n + 1)
  let dt : ℝ := t / steps
  (lorentzianTrotterStep H dt hbar) ^ (n + 1)

end

end CATEPTMain.CATEPT.CATEPT
