import CATEPTMain.CATEPT.CATEPT.LorentzianPathIntegralBridge
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Data.Nat.Interval
import Mathlib.Tactic.Linarith

set_option autoImplicit false

/-!
# Lorentzian Trotter–Kato / Chernoff layer (time-sliced construction)

Records the time-sliced Lorentzian product structure that underlies the
CAT/EPT real-time path integral.
-/

namespace CATEPTMain.Integration.LorentzianTrotterKatoBridge

noncomputable section

open CATEPTMain.CATEPT.CATEPT
open BigOperators

/-- Time-dependent Hamiltonian proxy. -/
structure TimeDependentHamiltonian where
  H_R : ℝ → ℝ
  H_I : ℝ → ℝ
  H_I_nonneg : ∀ t, 0 ≤ H_I t

/-- Slice a time-dependent Hamiltonian at time t. -/
def sliceHamiltonian (H : TimeDependentHamiltonian) (t : ℝ) : ComplexHamiltonian where
  H_R := H.H_R t
  H_I := H.H_I t
  H_I_nonneg := H.H_I_nonneg t

/-- Discrete time at step k out of n+1 slices. -/
def timeAtStep (t : ℝ) (n k : ℕ) : ℝ :=
  (k : ℝ) / (n + 1) * t

/-- Time-dependent Lorentzian Trotter step. -/
def lorentzianTrotterStep_td
    (H : TimeDependentHamiltonian) (t hbar dt : ℝ) : ℂ :=
  Complex.exp ((-(dt * H.H_R t) / hbar : ℂ) * Complex.I) *
    (Real.exp (-(dt * H.H_I t / hbar)) : ℂ)

/-- Norm bound for a time-dependent Trotter step. -/
theorem lorentzianTrotterStep_td_norm_le_one
    (H : TimeDependentHamiltonian) (t hbar dt : ℝ)
    (hdt : 0 ≤ dt) (hh : 0 < hbar) :
    ‖lorentzianTrotterStep_td H t hbar dt‖ ≤ 1 := by
  unfold lorentzianTrotterStep_td
  rw [norm_mul]
  have hphase : ‖Complex.exp ((-(dt * H.H_R t) / hbar : ℂ) * Complex.I)‖ = 1 :=
    Complex.norm_exp_ofReal_mul_I _
  rw [hphase, one_mul]
  have hnorm : ‖(Real.exp (-(dt * H.H_I t / hbar)) : ℂ)‖ =
      Real.exp (-(dt * H.H_I t / hbar)) := by
    simp [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]
  rw [hnorm]
  have hI : 0 ≤ H.H_I t := H.H_I_nonneg t
  have hdiv : 0 ≤ dt * H.H_I t / hbar :=
    div_nonneg (mul_nonneg hdt hI) (le_of_lt hh)
  have hneg : -(dt * H.H_I t / hbar) ≤ 0 := by
    linarith
  exact (Real.exp_le_one_iff).mpr hneg

/-- N-step Lorentzian Trotter product with time-dependent generator. -/
def lorentzianTrotterProduct_td
    (H : TimeDependentHamiltonian) (t hbar : ℝ) (n : ℕ) : ℂ :=
  let steps : ℝ := (n + 1)
  let dt : ℝ := t / steps
  (Finset.range (n + 1)).prod (fun k =>
    lorentzianTrotterStep_td H (timeAtStep t n k) hbar dt)

end

end CATEPTMain.Integration.LorentzianTrotterKatoBridge
