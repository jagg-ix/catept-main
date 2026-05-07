import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import CATEPTMain.CATEPT.CATEPT.LorentzianPathIntegralBridge

set_option autoImplicit false

/-!
# Proper-time resolvent and CAT/EPT damping

Schwinger proper time (sigma), Euclidean thermal time (tau_E), and
CAT/EPT entropic time (tau_ent) are kept as distinct carriers.
-/

namespace CATEPTMain.CATEPT_ProperTime.ProperTimeResolvent

noncomputable section

/-- Schwinger proper time parameter sigma. -/
structure SchwingerProperTime where
  sigma : ℝ

/-- Euclidean thermal time parameter tau_E. -/
structure EuclideanThermalTime where
  tauE : ℝ

/-- CAT/EPT entropic proper time tau_ent. -/
structure EntropicProperTime where
  tauEnt : ℝ

/-- Bundle to keep sigma, tau_E, and tau_ent distinct. -/
structure TimeSeparation where
  schwinger : SchwingerProperTime
  euclidean : EuclideanThermalTime
  entropic : EntropicProperTime

/-- Lorentzian operator data for proper-time resolvent. -/
structure ProperTimeLorentzianOperator where
  O_L : ℝ
  K_I : ℝ
  K_I_nonneg : 0 ≤ K_I

/-- Proper-time Lorentzian kernel with separate entropy damping and i-epsilon. -/
def properTimeLorentzianKernel (op : ProperTimeLorentzianOperator) (sigma epsilon : ℝ) : ℂ :=
  Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
    (Real.exp (-(sigma * op.K_I)) : ℂ) *
    (Real.exp (-(epsilon * sigma)) : ℂ)

/-- The kernel norm equals the product of entropy and i-epsilon damping. -/
theorem proper_time_lorentzian_damping
    (op : ProperTimeLorentzianOperator) (sigma epsilon : ℝ) :
    ‖properTimeLorentzianKernel op sigma epsilon‖ =
      Real.exp (-(sigma * op.K_I)) * Real.exp (-(epsilon * sigma)) := by
  unfold properTimeLorentzianKernel
  have hphase : ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I)‖ = 1 := by
    simpa using (Complex.norm_exp_ofReal_mul_I (sigma * op.O_L))
  have hreal1 : ‖(Real.exp (-(sigma * op.K_I)) : ℂ)‖ = Real.exp (-(sigma * op.K_I)) := by
    rw [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]
  have hreal2 : ‖(Real.exp (-(epsilon * sigma)) : ℂ)‖ = Real.exp (-(epsilon * sigma)) := by
    rw [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]
  have hstep1 :
      ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
          (Real.exp (-(sigma * op.K_I)) : ℂ) * (Real.exp (-(epsilon * sigma)) : ℂ)‖ =
        ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
            (Real.exp (-(sigma * op.K_I)) : ℂ)‖ *
          ‖(Real.exp (-(epsilon * sigma)) : ℂ)‖ :=
    (norm_mul _ _)
  have hstep2 :
      ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
          (Real.exp (-(sigma * op.K_I)) : ℂ)‖ =
        ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I)‖ *
        ‖(Real.exp (-(sigma * op.K_I)) : ℂ)‖ :=
    (norm_mul _ _)
  calc
    ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
        (Real.exp (-(sigma * op.K_I)) : ℂ) * (Real.exp (-(epsilon * sigma)) : ℂ)‖
        = ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
            (Real.exp (-(sigma * op.K_I)) : ℂ)‖ *
          ‖(Real.exp (-(epsilon * sigma)) : ℂ)‖ := by
          exact hstep1
    _ = ‖Complex.exp ((sigma * op.O_L : ℂ) * Complex.I)‖ *
        ‖(Real.exp (-(sigma * op.K_I)) : ℂ)‖ *
        ‖(Real.exp (-(epsilon * sigma)) : ℂ)‖ := by
          rw [hstep2]
    _ = Real.exp (-(sigma * op.K_I)) * Real.exp (-(epsilon * sigma)) := by
          rw [hphase, hreal1, hreal2]
          simp

/-- Contraction bound for the proper-time Lorentzian kernel. -/
theorem proper_time_lorentzian_contraction
    (op : ProperTimeLorentzianOperator) (sigma epsilon : ℝ)
    (hsigma : 0 ≤ sigma) (heps : 0 ≤ epsilon) :
    ‖properTimeLorentzianKernel op sigma epsilon‖ ≤ 1 := by
  have h1 : Real.exp (-(sigma * op.K_I)) ≤ 1 := by
    have hnonpos : -(sigma * op.K_I) ≤ 0 := by
      have hnonneg : 0 ≤ sigma * op.K_I := mul_nonneg hsigma op.K_I_nonneg
      linarith
    simpa [Real.exp_le_one_iff] using hnonpos
  have h2 : Real.exp (-(epsilon * sigma)) ≤ 1 := by
    have hnonpos : -(epsilon * sigma) ≤ 0 := by
      have hnonneg : 0 ≤ epsilon * sigma := mul_nonneg heps hsigma
      linarith
    simpa [Real.exp_le_one_iff] using hnonpos
  have hmul : Real.exp (-(sigma * op.K_I)) * Real.exp (-(epsilon * sigma)) ≤ 1 * 1 :=
    mul_le_mul h1 h2 (Real.exp_pos _).le (by norm_num)
  have hnorm := proper_time_lorentzian_damping op sigma epsilon
  rw [hnorm]
  simpa using hmul

/-- The i-epsilon factor supplements entropy damping, not replaces it. -/
theorem proper_time_epsilon_separate
    (op : ProperTimeLorentzianOperator) (sigma epsilon : ℝ) :
    properTimeLorentzianKernel op sigma epsilon =
      properTimeLorentzianKernel op sigma 0 * (Real.exp (-(epsilon * sigma)) : ℂ) := by
  unfold properTimeLorentzianKernel
  simp [mul_left_comm, mul_comm]

/-- Proper-time kernel expressed as a CAT/EPT Lorentzian weight (hbar = 1). -/
def properTimeLorentzianKernelViaCATEPT
    (op : ProperTimeLorentzianOperator) (sigma epsilon : ℝ) : ℂ :=
  CATEPTMain.CATEPT.CATEPT.lorentzianKernel
    (sigma * op.O_L) (sigma * op.K_I + epsilon * sigma) 1

/-- Proper-time kernel matches the CAT/EPT Lorentzian kernel with separate damping. -/
theorem proper_time_kernel_via_catept
    (op : ProperTimeLorentzianOperator) (sigma epsilon : ℝ) :
    properTimeLorentzianKernel op sigma epsilon =
      properTimeLorentzianKernelViaCATEPT op sigma epsilon := by
  unfold properTimeLorentzianKernelViaCATEPT
  have hsplitReal :
      Real.exp (-(sigma * op.K_I + epsilon * sigma)) =
        Real.exp (-(sigma * op.K_I)) * Real.exp (-(epsilon * sigma)) := by
    have h : -(sigma * op.K_I + epsilon * sigma) =
        -(sigma * op.K_I) + -(epsilon * sigma) := by ring
    simp [h, Real.exp_add]
  have hsplit :
      (Real.exp (-(sigma * op.K_I)) : ℂ) * (Real.exp (-(epsilon * sigma)) : ℂ) =
        (Real.exp (-(sigma * op.K_I + epsilon * sigma)) : ℂ) := by
    have h := congrArg (fun r : ℝ => (r : ℂ)) hsplitReal
    have h' : (Real.exp (-(sigma * op.K_I + epsilon * sigma)) : ℂ) =
        (Real.exp (-(sigma * op.K_I)) : ℂ) * (Real.exp (-(epsilon * sigma)) : ℂ) := by
      simpa [Complex.ofReal_mul] using h
    exact h'.symm
  calc
    properTimeLorentzianKernel op sigma epsilon =
        Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
          ((Real.exp (-(sigma * op.K_I)) : ℂ) * (Real.exp (-(epsilon * sigma)) : ℂ)) := by
        simp [properTimeLorentzianKernel, mul_assoc]
    _ = Complex.exp ((sigma * op.O_L : ℂ) * Complex.I) *
        (Real.exp (-(sigma * op.K_I + epsilon * sigma)) : ℂ) := by
        rw [hsplit]
    _ = properTimeLorentzianKernelViaCATEPT op sigma epsilon := by
        simp [properTimeLorentzianKernelViaCATEPT,
          CATEPTMain.CATEPT.CATEPT.lorentzianKernel_factorizes, mul_assoc]

end

end CATEPTMain.CATEPT_ProperTime.ProperTimeResolvent
