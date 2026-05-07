/-
  T-J Phase 1: Diagonal multivariate Gaussian completion-of-the-square.

  Lifts T-F Phase 1 (`CATEPTMain.Integration.GaussianCompletion`) from
  the scalar identity
        a·x²  -  b·x  =  a·(x − b/(2a))²  -  b²/(4a)
  to its `Finset.sum` analogue over an arbitrary finite index type
  `ι` of independent modes
        ∑ᵢ (aᵢ·xᵢ²  −  bᵢ·xᵢ)
              =  ∑ᵢ aᵢ·(xᵢ − bᵢ/(2aᵢ))²
                  −  ∑ᵢ bᵢ²/(4aᵢ).

  This is the diagonal multivariate completion: every quadratic form
  with diagonal Hessian decouples into a product of independent
  scalar Gaussians, and completion-of-the-square distributes over the
  index sum.  It is the algebraic engine of every n-mode Gaussian
  path integral whose kinetic operator has been diagonalised — the
  FEYNCALC `euclideanDenominator k m = ∑ kμ² + m²` from the
  `catept-domain-gauge` sibling is a paradigmatic instance.

  Phase 1 ships three honest, kernel-only identities:

    (1) `gaussianCompletion_diag`
        the vector lift of `gaussianCompletion`, hypothesising that
        every diagonal coefficient is non-zero.

    (2) `gaussianCompletion_diag_zero_source`
        the `b ≡ 0` reduction: with no source, the completion
        recovers the bare diagonal quadratic with zero shift and
        zero residual.

    (3) `gaussianCompletion_diag_recovers_euclideanDenominator`
        the FEYNCALC bridge: the `b ≡ 0`, `aᵢ ≡ 1` instance of the
        diagonal completion sum equals the FEYNCALC Euclidean
        propagator denominator's kinetic part `∑ kμ²` (with mass
        offset added separately).

  Phase 2 (deferred): non-diagonal matrix completion `xᵀAx − Jᵀx` with
  full Cholesky / spectral diagonalisation, sourced n-dim
  Z[J]/Z[0] = exp(½ Jᵀ A⁻¹ J), waiting on T-F Phase 2 +
  Mathlib's `MeasureTheory.integral_gaussian` and the
  `Matrix.spectralTheorem` for symmetric positive-definite matrices.
-/
import CATEPTMain.Integration.GaussianCompletion
import CATEPTMain.GaugeTheory.FEYNCALC.SpinorPropagator
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

set_option autoImplicit false

namespace CATEPTMain.Integration.MultiModeGaussianCompletion

open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.GaugeTheory.FEYNCALC

noncomputable section

variable {ι : Type*}

/-- **Diagonal multivariate completion-of-the-square** (T-J Phase 1).

    For a finite index type `ι`, diagonal coefficients `a, b : ι → ℝ`
    with every `aᵢ ≠ 0`, and arbitrary `x : ι → ℝ`,
        ∑ᵢ (aᵢ·xᵢ² − bᵢ·xᵢ)
            = ∑ᵢ (aᵢ·(xᵢ − bᵢ/(2aᵢ))² − bᵢ²/(4aᵢ)).

    Vector lift of T-F Phase 1's `gaussianCompletion`. -/
theorem gaussianCompletion_diag
    [Fintype ι] (a b x : ι → ℝ) (ha : ∀ i, a i ≠ 0) :
    ∑ i, (a i * (x i) ^ 2 - b i * x i)
      = ∑ i, (a i * (x i - completionShift (a i) (b i)) ^ 2
                  - completionResidual (a i) (b i)) := by
  refine Finset.sum_congr rfl (fun i _ => ?_)
  exact gaussianCompletion (a i) (b i) (x i) (ha i)

/-- **Zero-source reduction** of the diagonal completion.

    Every shift collapses to zero and every residual collapses to zero
    when `b ≡ 0`, recovering the bare diagonal quadratic
    `∑ᵢ aᵢ·xᵢ²`.  Vector lift of `gaussianCompletion_zero_source`. -/
theorem gaussianCompletion_diag_zero_source
    [Fintype ι] (a x : ι → ℝ) :
    ∑ i, (a i * (x i) ^ 2 - (0 : ℝ) * x i)
      = ∑ i, (a i * (x i - completionShift (a i) 0) ^ 2
                  - completionResidual (a i) 0) := by
  refine Finset.sum_congr rfl (fun i _ => ?_)
  exact gaussianCompletion_zero_source (a i) (x i)

/-- **FEYNCALC bridge** (T-J ↔ FEYNCALC).

    The `aᵢ ≡ 1`, `bᵢ ≡ 0` instance of the diagonal completion sum
    coincides with the kinetic part of FEYNCALC's
    `euclideanDenominator k m = (∑ μ kμ²) + m²` from the
    `catept-domain-gauge` sibling.  Concretely:

        ∑ μ : FCIdx, (1 · kμ² − 0 · kμ)
              =  euclideanDenominator k 0,

    i.e. the bare massless Euclidean kinetic form of a free scalar
    mode is the trivial-coefficient diagonal completion sum.

    This proves that T-J's algebraic substrate is the exact form
    consumed by FEYNCALC's already-proved
    `propagator_as_catept_laplace`. -/
theorem gaussianCompletion_diag_recovers_euclideanDenominator
    (k : FCIdx → ℝ) :
    ∑ μ : FCIdx, ((1 : ℝ) * (k μ) ^ 2 - (0 : ℝ) * k μ)
      = euclideanDenominator k 0 := by
  unfold euclideanDenominator
  simp [pow_two]

end

end CATEPTMain.Integration.MultiModeGaussianCompletion
