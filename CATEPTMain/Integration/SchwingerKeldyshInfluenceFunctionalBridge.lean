import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

set_option autoImplicit false

/-!
# Schwinger–Keldysh / Influence-Functional Bridge for CAT/EPT

Records the doubled-history influence-functional layer for open-system
CAT/EPT, with a non-negative imaginary influence action that supplies
entropic damping of off-diagonal histories.
-/

namespace CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge

noncomputable section

/-- Placeholder for a field/history type on the closed time path. -/
constant FieldHistory : Type

/-- Real action on a single history. -/
constant RealAction : FieldHistory → ℝ

/-- Influence action split into real and imaginary parts. -/
structure InfluenceAction where
  SIF_R : FieldHistory → FieldHistory → ℝ
  SIF_I : FieldHistory → FieldHistory → ℝ
  nonnegative_I : ∀ φp φm, 0 ≤ SIF_I φp φm

/-- Entropic proper time on doubled histories. -/
def tauEntSK (IF : InfluenceAction) (hbar : ℝ) (φp φm : FieldHistory) : ℝ :=
  IF.SIF_I φp φm / hbar

/-- Schwinger–Keldysh real-phase exponent (without i). -/
def skRealPhase (IF : InfluenceAction) (hbar : ℝ)
    (φp φm : FieldHistory) : ℝ :=
  (RealAction φp - RealAction φm + IF.SIF_R φp φm) / hbar

/-- Entropic damping factor for doubled histories. -/
def skDamping (IF : InfluenceAction) (hbar : ℝ) (φp φm : FieldHistory) : ℝ :=
  Real.exp (-(tauEntSK IF hbar φp φm))

/-- Damping is contractive for positive imaginary influence action. -/
theorem skDamping_le_one
    (IF : InfluenceAction) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (φp φm : FieldHistory) :
    skDamping IF hbar φp φm ≤ 1 := by
  unfold skDamping tauEntSK
  have hnonneg : 0 ≤ IF.SIF_I φp φm / hbar :=
    div_nonneg (IF.nonnegative_I φp φm) (le_of_lt hbar_pos)
  have hneg : -(IF.SIF_I φp φm / hbar) ≤ 0 := by
    linarith
  exact (Real.exp_le_one_iff).mpr hneg

/-- Diagonal histories have zero imaginary influence (structural hypothesis). -/
structure DiagonalInfluenceVanishing (IF : InfluenceAction) : Prop where
  diag_zero : ∀ φ, IF.SIF_I φ φ = 0

/-- Off-diagonal suppression: if SIF_I >= 0 and diag vanishes, then
    damping is 1 on diagonal histories. -/
theorem skDamping_diag_eq_one
    (IF : InfluenceAction) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (H : DiagonalInfluenceVanishing IF) (φ : FieldHistory) :
    skDamping IF hbar φ φ = 1 := by
  unfold skDamping tauEntSK
  rw [H.diag_zero φ]
  simp [hbar_pos.ne']

end

end CATEPTMain.Integration.SchwingerKeldyshInfluenceFunctionalBridge
