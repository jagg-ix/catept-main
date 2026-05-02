/-
  T-N Phase 1: Z[J] / Z[0] ratio identity (scalar and diagonal multimode).

  Capstone-conceptual rung that exposes the source-coupling factor of
  the path-integral generating functional in isolation:

      Scalar (1D):
          Z[J] / Z[0]  =  exp(b² / (4a)),                              (*)

      Diagonal multimode:
          Z[J] / Z[0]  =  ∏ᵢ exp(bᵢ² / (4 aᵢ)).                        (**)

  Where Z[J] := ∫ exp(-(Σ aᵢ xᵢ² - bᵢ xᵢ)) dx (and the scalar instance
  is the single-mode case).  Both `Z[J]` and `Z[0]` are honest kernel
  theorems by T-L Phase 1 (`integral_sourced_gaussian`) and T-M Phase 1
  (`integral_sourced_gaussian_multimode`); T-N divides the two,
  cancelling the kinetic determinant √(π/a) (resp. ∏√(π/aᵢ)) and
  isolating the source-coupling factor.

  Phase 1 ships two honest, kernel-only theorems:

    * `Z_ratio_scalar`     Z[b] / Z[0] = exp(b²/(4a))      (a > 0)
    * `Z_ratio_multimode`  Z[b] / Z[0] = ∏ exp(bᵢ²/(4aᵢ))  (∀ i, 0 < aᵢ)
-/
import CATEPTMain.Integration.SourcedGaussianIntegral
import CATEPTMain.Integration.MultiModeSourcedGaussian

set_option autoImplicit false

namespace CATEPTMain.Integration.ZJRatio

open MeasureTheory Real
open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.Integration.SourcedGaussianIntegral
open CATEPTMain.Integration.MultiModeSourcedGaussian

noncomputable section

/-- **Scalar Z[J]/Z[0] ratio** (T-N Phase 1, 1D).

    For `0 < a`,
        ( ∫ℝ exp(-(a·x² - b·x)) dx ) / ( ∫ℝ exp(-(a·x² - 0·x)) dx )
            =  exp(b²/(4a))
            =  exp(completionResidual a b).

    Direct corollary of T-L Phase 1: numerator is
    `exp(residual) · √(π/a)` and denominator is `√(π/a)` (since
    `completionResidual a 0 = 0` ⇒ `exp 0 = 1`); for `0 < a` we have
    `√(π/a) > 0`, hence the ratio is well-defined and equals
    `exp(residual)`. -/
theorem Z_ratio_scalar (a b : ℝ) (ha : 0 < a) :
    (∫ x : ℝ, Real.exp (-(a * x ^ 2 - b * x)))
        / (∫ x : ℝ, Real.exp (-(a * x ^ 2 - (0 : ℝ) * x)))
      = Real.exp (completionResidual a b) := by
  have ha' : a ≠ 0 := ne_of_gt ha
  have hπa : 0 < Real.pi / a := div_pos Real.pi_pos ha
  have hsqrt_pos : 0 < Real.sqrt (Real.pi / a) := Real.sqrt_pos.mpr hπa
  have hsqrt_ne : Real.sqrt (Real.pi / a) ≠ 0 := ne_of_gt hsqrt_pos
  rw [integral_sourced_gaussian a b ha',
      integral_sourced_gaussian_zero_source a ha']
  field_simp

/-- **Diagonal multimode Z[J]/Z[0] ratio** (T-N Phase 1, n-mode).

    For a finite index type `ι` with every `0 < aᵢ`,
        ( ∫_{ℝ^ι} exp(-(Σ aᵢ xᵢ² - bᵢ xᵢ)) dx )
              / ( ∫_{ℝ^ι} exp(-(Σ aᵢ xᵢ² - 0 · xᵢ)) dx )
              =  ∏ᵢ exp(bᵢ² / (4 aᵢ))
              =  ∏ᵢ exp(completionResidual aᵢ bᵢ).

    Direct corollary of T-M Phase 1, dividing
    `∏ᵢ exp(residual_i) · √(π/aᵢ)` by `∏ᵢ √(π/aᵢ)`. -/
theorem Z_ratio_multimode
    {ι : Type*} [Fintype ι] (a b : ι → ℝ) (ha : ∀ i, 0 < a i) :
    (∫ x : ι → ℝ,
        Real.exp (-(∑ i, (a i * (x i) ^ 2 - b i * x i))))
        / (∫ x : ι → ℝ,
            Real.exp (-(∑ i, (a i * (x i) ^ 2 - (0 : ℝ) * x i))))
      = ∏ i, Real.exp (completionResidual (a i) (b i)) := by
  have ha' : ∀ i, a i ≠ 0 := fun i => ne_of_gt (ha i)
  rw [integral_sourced_gaussian_multimode a b ha',
      integral_sourced_gaussian_multimode_zero_source a ha']
  -- LHS = (∏ exp(res i) * √(π/aᵢ)) / ∏ √(π/aᵢ)
  -- Split numerator product into product of exp's times product of sqrt's,
  -- then cancel the sqrt product (positive ⇒ nonzero).
  rw [Finset.prod_mul_distrib]
  have hsqrt_pos : 0 < ∏ i, Real.sqrt (Real.pi / a i) :=
    Finset.prod_pos (fun i _ => Real.sqrt_pos.mpr (div_pos Real.pi_pos (ha i)))
  have hsqrt_ne : (∏ i, Real.sqrt (Real.pi / a i)) ≠ 0 := ne_of_gt hsqrt_pos
  field_simp

end

end CATEPTMain.Integration.ZJRatio
