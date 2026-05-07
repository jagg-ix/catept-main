import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

set_option autoImplicit false

/-!
# Heat-kernel determinants and CAT/EPT entropy shift

Encodes the proper-time determinant formula and a Wick equivalence carrier
between Lorentzian resolvents and Euclidean heat-kernel operators.
-/

namespace CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant

noncomputable section

/-- Euclidean heat-kernel operator data O_E with entropy operator K_I >= 0. -/
structure HeatKernelOperator where
  O_E : ℝ
  K_I : ℝ
  K_I_nonneg : 0 ≤ K_I

/-- Heat-kernel weight with CAT/EPT entropy shift. -/
def heatKernelWeight (op : HeatKernelOperator) (sigma : ℝ) : ℝ :=
  Real.exp (-(sigma * (op.O_E + op.K_I)))

/-- Heat-kernel weight without entropy shift. -/
def heatKernelWeightNoEntropy (op : HeatKernelOperator) (sigma : ℝ) : ℝ :=
  Real.exp (-(sigma * op.O_E))

/-- Entropy shift increases damping in the heat-kernel weight. -/
theorem heat_kernel_entropy_shift
    (op : HeatKernelOperator) (sigma : ℝ) (hsigma : 0 ≤ sigma) :
    heatKernelWeight op sigma ≤ heatKernelWeightNoEntropy op sigma := by
  unfold heatKernelWeight heatKernelWeightNoEntropy
  have hsplit : -(sigma * (op.O_E + op.K_I)) =
      -(sigma * op.O_E) + -(sigma * op.K_I) := by ring
  rw [hsplit, Real.exp_add]
  have hle : Real.exp (-(sigma * op.K_I)) ≤ 1 := by
    have hnonpos : -(sigma * op.K_I) ≤ 0 := by
      have hnonneg : 0 ≤ sigma * op.K_I := mul_nonneg hsigma op.K_I_nonneg
      linarith
    simpa [Real.exp_le_one_iff] using hnonpos
  have hpos : 0 ≤ Real.exp (-(sigma * op.O_E)) := (Real.exp_pos _).le
  calc
    Real.exp (-(sigma * op.O_E)) * Real.exp (-(sigma * op.K_I))
        ≤ Real.exp (-(sigma * op.O_E)) * 1 := by
          exact mul_le_mul_of_nonneg_left hle hpos
    _ = Real.exp (-(sigma * op.O_E)) := by simp

/-- Abstract heat-kernel trace. -/
axiom heatKernelTrace : HeatKernelOperator → ℝ → ℝ

/-- Abstract proper-time determinant integral. -/
axiom properTimeDeterminantIntegral : (ℝ → ℝ) → ℝ

/-- Euclidean effective action from a heat-kernel determinant.

`sign = 1` (bosons), `sign = -1` (fermions).
-/
def heatKernelEffectiveAction (op : HeatKernelOperator) (sign : ℝ) : ℝ :=
  (sign / 2) *
    properTimeDeterminantIntegral (fun sigma => heatKernelTrace op sigma / sigma)

/-- Proper-time CAT/EPT Wick equivalence carrier. -/
structure ProperTimeWickEquivalence where
  O_L : ℝ
  O_E : ℝ
  K_I_L : ℝ
  K_I_E : ℝ
  K_I_E_nonneg : 0 ≤ K_I_E
  wick_relation : ∀ sigma : ℝ,
    Complex.exp ((sigma * O_L : ℂ) * Complex.I) * (Real.exp (-(sigma * K_I_L)) : ℂ) =
      (Real.exp (-(sigma * (O_E + K_I_E))) : ℂ)

end

end CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant
