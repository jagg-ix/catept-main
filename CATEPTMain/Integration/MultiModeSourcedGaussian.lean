/-
  T-M Phase 1: Diagonal multimode sourced Gaussian integral evaluation
  (multivariate Z[J] in 1D-per-mode form).

  Lifts T-L Phase 1 (`CATEPTMain.Integration.SourcedGaussianIntegral`)
  from the scalar identity
        ∫ℝ exp(-(a·x² - b·x)) dx  =  exp(b²/(4a)) · √(π/a)
  to its `Finset.prod` analogue over an arbitrary finite index type
  `ι` of independent (diagonal) modes:

        ∫_{ℝ^ι}  exp(-(∑ᵢ (aᵢ·xᵢ² - bᵢ·xᵢ))) dx
              =  ∏ᵢ  exp(bᵢ²/(4aᵢ)) · √(π/aᵢ).

  This is the diagonal multivariate generating functional Z[J] of an
  n-mode free scalar QFT whose kinetic operator has been diagonalised:
  every mode contributes its own scalar shifted-Gaussian factor, and
  the joint Z[J] is the `Finset.prod` of those factors.

  Derivation in three honest moves:

    1. Algebra (`Real.exp_sum`):
            exp(-(∑ᵢ fᵢ xᵢ))  =  ∏ᵢ exp(-fᵢ xᵢ).

    2. Fubini (Mathlib `integral_fintype_prod_volume_eq_prod`):
            ∫_{ℝ^ι}  ∏ᵢ gᵢ(xᵢ) dx  =  ∏ᵢ ∫ℝ gᵢ.

    3. Per-mode evaluation (T-L Phase 1 `integral_sourced_gaussian`):
            ∫ℝ exp(-(aᵢ·y² - bᵢ·y)) dy
              =  exp(completionResidual aᵢ bᵢ) · √(π/aᵢ).

  Phase 1 ships two honest, kernel-only theorems:

    * `integral_sourced_gaussian_multimode`     the identity above
    * `integral_sourced_gaussian_multimode_zero_source`
                                                  bᵢ ≡ 0 reduction
-/
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import CATEPTMain.Integration.GaussianCompletion
import CATEPTMain.Integration.SourcedGaussianIntegral

set_option autoImplicit false

namespace CATEPTMain.Integration.MultiModeSourcedGaussian

open MeasureTheory Real
open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.Integration.SourcedGaussianIntegral

noncomputable section

variable {ι : Type*}

/-- **Multimode sourced Gaussian integral evaluation** (T-M Phase 1).

    For a finite index type `ι` and diagonal coefficients
    `a, b : ι → ℝ` with every `aᵢ ≠ 0`,

        ∫_{ℝ^ι}  exp(-(∑ᵢ (aᵢ·xᵢ² - bᵢ·xᵢ))) dx
              =  ∏ᵢ exp(bᵢ²/(4aᵢ)) · √(π/aᵢ).

    Composition of `Real.exp_sum`, Mathlib's
    `integral_fintype_prod_volume_eq_prod`, and T-L Phase 1's
    `integral_sourced_gaussian`. -/
theorem integral_sourced_gaussian_multimode
    [Fintype ι] (a b : ι → ℝ) (ha : ∀ i, a i ≠ 0) :
    ∫ x : ι → ℝ,
        Real.exp (-(∑ i, (a i * (x i) ^ 2 - b i * x i)))
      = ∏ i,
          Real.exp (completionResidual (a i) (b i))
            * Real.sqrt (Real.pi / a i) := by
  -- Step 1: rewrite the integrand pointwise as a product of per-mode exponentials.
  have hpt :
      (fun x : ι → ℝ =>
          Real.exp (-(∑ i, (a i * (x i) ^ 2 - b i * x i))))
        = (fun x : ι → ℝ =>
            ∏ i, Real.exp (-(a i * (x i) ^ 2 - b i * x i))) := by
    funext x
    have hneg : -(∑ i, (a i * (x i) ^ 2 - b i * x i))
                = ∑ i, -(a i * (x i) ^ 2 - b i * x i) := by
      rw [Finset.sum_neg_distrib]
    rw [hneg]
    exact Real.exp_sum Finset.univ
            (fun i => -(a i * (x i) ^ 2 - b i * x i))
  rw [hpt]
  -- Step 2: Fubini / product-measure evaluation.
  rw [integral_fintype_prod_volume_eq_prod
        (fun i (y : ℝ) => Real.exp (-(a i * y ^ 2 - b i * y)))]
  -- Step 3: per-mode T-L sourced Gaussian evaluation.
  refine Finset.prod_congr rfl (fun i _ => ?_)
  exact integral_sourced_gaussian (a i) (b i) (ha i)

/-- **Zero-source reduction**: with `b ≡ 0`, every residual factor
    vanishes (`exp 0 = 1`) and the multimode integral collapses to the
    bare multimode Gaussian `∏ᵢ √(π/aᵢ)`. -/
theorem integral_sourced_gaussian_multimode_zero_source
    [Fintype ι] (a : ι → ℝ) (ha : ∀ i, a i ≠ 0) :
    ∫ x : ι → ℝ,
        Real.exp (-(∑ i, (a i * (x i) ^ 2 - (0 : ℝ) * x i)))
      = ∏ i, Real.sqrt (Real.pi / a i) := by
  have h := integral_sourced_gaussian_multimode a (fun _ => 0) ha
  -- Simplify completionResidual a 0 = 0 inside the product.
  have hres : ∀ i, completionResidual (a i) 0 = 0 := by
    intro i; unfold completionResidual; ring
  have hfact : (fun i =>
                  Real.exp (completionResidual (a i) 0)
                    * Real.sqrt (Real.pi / a i))
                = fun i => Real.sqrt (Real.pi / a i) := by
    funext i; rw [hres i, Real.exp_zero, one_mul]
  rw [hfact] at h
  exact h

end

end CATEPTMain.Integration.MultiModeSourcedGaussian
