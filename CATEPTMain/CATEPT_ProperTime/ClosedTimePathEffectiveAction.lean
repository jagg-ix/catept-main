import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp

set_option autoImplicit false

/-!
# Closed-time-path effective action (CTP/SK) for CAT/EPT

Carrier-level encoding of real-time finite-temperature effective actions with
field doubling. The entropy functional is carried as an influence functional
on the CTP contour.
-/

namespace CATEPTMain.CATEPT_ProperTime.ClosedTimePathEffectiveAction

noncomputable section

/-- Two-branch field data on a closed-time-path contour. -/
structure CTPField (α : Type*) where
  plus : α
  minus : α

/-- Influence functional with real and imaginary parts. -/
structure InfluenceFunctional (α : Type*) where
  S_R : CTPField α → ℝ
  S_I : CTPField α → ℝ
  S_I_nonneg : ∀ phi, 0 ≤ S_I phi

/-- CTP weight: oscillatory real action with CAT/EPT damping. -/
def ctpWeight {α : Type*} (IF : InfluenceFunctional α) (hbar : ℝ) (phi : CTPField α) : ℂ :=
  Complex.exp (((IF.S_R phi) / hbar : ℂ) * Complex.I) *
    (Real.exp (-(IF.S_I phi / hbar)) : ℂ)

/-- Norm of the CTP weight equals the CAT/EPT damping factor. -/
theorem ctp_weight_norm_is_damping
    {α : Type*} (IF : InfluenceFunctional α) (hbar : ℝ) (phi : CTPField α) :
    ‖ctpWeight IF hbar phi‖ = Real.exp (-(IF.S_I phi / hbar)) := by
  unfold ctpWeight
  have hphase : ‖Complex.exp (((IF.S_R phi) / hbar : ℂ) * Complex.I)‖ = 1 := by
    simpa using (Complex.norm_exp_ofReal_mul_I ((IF.S_R phi) / hbar))
  have hreal : ‖(Real.exp (-(IF.S_I phi / hbar)) : ℂ)‖ =
      Real.exp (-(IF.S_I phi / hbar)) := by
    rw [Complex.norm_real, Real.norm_of_nonneg (Real.exp_pos _).le]
  calc
    ‖Complex.exp (((IF.S_R phi) / hbar : ℂ) * Complex.I) *
        (Real.exp (-(IF.S_I phi / hbar)) : ℂ)‖
        = ‖Complex.exp (((IF.S_R phi) / hbar : ℂ) * Complex.I)‖ *
          ‖(Real.exp (-(IF.S_I phi / hbar)) : ℂ)‖ := by
              exact (norm_mul _ _)
            _ = Real.exp (-(IF.S_I phi / hbar)) := by
              rw [hphase, hreal]
              simp

/-- Abstract finite-temperature CTP effective action carrier. -/
structure CTPEffectiveActionCarrier (α : Type*) where
  IF : InfluenceFunctional α
  hbar : ℝ
  action : ℂ
  representation : ∃ phi : CTPField α, action = ctpWeight IF hbar phi

end

end CATEPTMain.CATEPT_ProperTime.ClosedTimePathEffectiveAction
