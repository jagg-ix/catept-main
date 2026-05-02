/-
  T-O Phase 1: Free-energy / log-ratio identity for Z[J]/Z[0].

  Composes T-N (Z[J]/Z[0] = exp(residual)) with `Real.log_exp` to
  obtain the "free-energy difference" form:

      Scalar 1D:
          log( Z[J] / Z[0] )  =  b² / (4 a)
                               =  completionResidual a b.

      Diagonal multimode:
          log( Z[J] / Z[0] )  =  ∑ᵢ  bᵢ² / (4 aᵢ)
                               =  ∑ᵢ  completionResidual aᵢ bᵢ.

  In QFT-language this is the connected free-energy generator W[J]
  (= log Z[J]) restricted to the kinetic Gaussian sector with no
  source at b = 0 baseline; its value at b is the "shift" induced
  by switching on the source. Two honest kernel-only theorems.
-/
import CATEPTMain.Integration.SourcedGaussianIntegral
import CATEPTMain.Integration.MultiModeSourcedGaussian
import CATEPTMain.Integration.ZJRatio

set_option autoImplicit false

namespace CATEPTMain.Integration.LogZJRatio

open MeasureTheory Real
open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.Integration.ZJRatio

noncomputable section

/-- **Scalar log-ratio (free-energy form)** (T-O Phase 1, 1D).

    For `0 < a`,
        log ( ( ∫ exp(-(a x² - b x)) dx ) / ( ∫ exp(-(a x² - 0·x)) dx ) )
            =  completionResidual a b
            =  b² / (4 a).

    Direct corollary of T-N (`Z_ratio_scalar`) followed by `Real.log_exp`. -/
theorem log_Z_ratio_scalar (a b : ℝ) (ha : 0 < a) :
    Real.log
        ((∫ x : ℝ, Real.exp (-(a * x ^ 2 - b * x)))
          / (∫ x : ℝ, Real.exp (-(a * x ^ 2 - (0 : ℝ) * x))))
      = completionResidual a b := by
  rw [Z_ratio_scalar a b ha, Real.log_exp]

/-- **Diagonal multimode log-ratio (free-energy form)** (T-O Phase 1, n-mode).

    For a finite index type `ι` with every `0 < aᵢ`,
        log ( ( ∫ exp(-(Σ aᵢ xᵢ² - bᵢ xᵢ)) dx )
              / ( ∫ exp(-(Σ aᵢ xᵢ² - 0·xᵢ)) dx ) )
            =  ∑ᵢ completionResidual aᵢ bᵢ
            =  ∑ᵢ bᵢ² / (4 aᵢ).

    Direct corollary of T-N (`Z_ratio_multimode`) followed by
    `Real.log_prod` and per-mode `Real.log_exp`.  The product is
    strictly positive (each factor is `exp _ > 0`), so `log_prod`
    applies. -/
theorem log_Z_ratio_multimode
    {ι : Type*} [Fintype ι] (a b : ι → ℝ) (ha : ∀ i, 0 < a i) :
    Real.log
        ((∫ x : ι → ℝ,
              Real.exp (-(∑ i, (a i * (x i) ^ 2 - b i * x i))))
            / (∫ x : ι → ℝ,
                Real.exp (-(∑ i, (a i * (x i) ^ 2 - (0 : ℝ) * x i)))))
      = ∑ i, completionResidual (a i) (b i) := by
  rw [Z_ratio_multimode a b ha]
  -- Goal: log (∏ i, exp (residual a_i b_i)) = ∑ i, residual a_i b_i
  -- Use: log_prod (positive factors) + log_exp pointwise.
  rw [← Real.exp_sum]
  exact Real.log_exp _

end

end CATEPTMain.Integration.LogZJRatio
