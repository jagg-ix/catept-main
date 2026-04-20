import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Sqrt
import Mathlib.Analysis.SpecialFunctions.Pow.Real

namespace CATEPT.External.Hyperunits

open Real

/-- The universal radical scaling factor (hyperunit) for an N-dimensional Euclidean metric space. -/
noncomputable def lambda_N (N : ℕ) : ℝ :=
  Real.sqrt (N : ℝ)

/-- The hyperunit scaling factor is always nonnegative. -/
theorem lambda_N_nonneg (N : ℕ) : 0 ≤ lambda_N N := by
  unfold lambda_N
  exact Real.sqrt_nonneg _

/-- Squaring the hyperunit recovers the underlying dimension index. -/
theorem lambda_N_sq (N : ℕ) : (lambda_N N) ^ 2 = (N : ℝ) := by
  simpa [lambda_N, pow_two] using Real.sq_sqrt (Nat.cast_nonneg N)

/-- The fractional scaling map embedding an M-dimensional measure space into an N-dimensional measure space.
    This provides the non-standard weight acting on L^p norms across dimensions. -/
noncomputable def dimensionalEmbedding (M N : ℕ) (L_M : ℝ) : ℝ :=
  (L_M ^ ((N : ℝ) / (M : ℝ))) * (lambda_N N) ^ (((N : ℝ) - (M : ℝ)) / 2)

/-- SU(2) Spin Representations for Loop Quantum Gravity (LQG).
    Replaces the non-standard C6/C9/C12 taxonomies with standard Spin-j labels
    from the Representation Theory of SU(2), encoding the quantized area eigenvalues. -/
structure SU2SpinRepresentation where
  /-- The spin quantum number j (stored as 2j to remain an integer). -/
  two_j : ℕ

/-- Evaluates the dimension of the SU(2) representation: dim(H_j) = 2j + 1. -/
def representationDimension (spin : SU2SpinRepresentation) : ℕ :=
  spin.two_j + 1

/-- Representation dimension is always positive. -/
theorem representationDimension_pos (spin : SU2SpinRepresentation) :
    0 < representationDimension spin := by
  unfold representationDimension
  exact Nat.succ_pos _

/-- Representation dimension is never zero. -/
theorem representationDimension_ne_zero (spin : SU2SpinRepresentation) :
    representationDimension spin ≠ 0 :=
  Nat.ne_of_gt (representationDimension_pos spin)

/-- Representation dimension is monotone in the spin label `2j`. -/
theorem representationDimension_mono
    (spin₁ spin₂ : SU2SpinRepresentation)
    (h : spin₁.two_j ≤ spin₂.two_j) :
    representationDimension spin₁ ≤ representationDimension spin₂ := by
  simpa [representationDimension] using Nat.succ_le_succ h

/-- Representation dimension is strictly monotone in the spin label `2j`. -/
theorem representationDimension_strict_mono
    (spin₁ spin₂ : SU2SpinRepresentation)
    (h : spin₁.two_j < spin₂.two_j) :
    representationDimension spin₁ < representationDimension spin₂ := by
  simpa [representationDimension] using Nat.succ_lt_succ h

/-- Every SU(2) representation has dimension at least 1. -/
theorem representationDimension_ge_one (spin : SU2SpinRepresentation) :
    1 ≤ representationDimension spin := by
  unfold representationDimension
  exact Nat.succ_le_succ (Nat.zero_le _)

/-- Zero spin label yields the trivial one-dimensional representation. -/
theorem representationDimension_eq_one_of_two_j_eq_zero
    (spin : SU2SpinRepresentation) (h : spin.two_j = 0) :
    representationDimension spin = 1 := by
  unfold representationDimension
  simp [h]

/-- Positive spin label yields representation dimension strictly greater than 1. -/
theorem representationDimension_gt_one_of_two_j_pos
    (spin : SU2SpinRepresentation) (h : 0 < spin.two_j) :
    1 < representationDimension spin := by
  unfold representationDimension
  simpa using Nat.succ_lt_succ h

/-- Evaluates the physical Area Operator eigenvalue for a given spin j.
    \hat{A} |j\rangle = 8 \pi \gamma \ell_P^2 \sqrt{j(j+1)} |j\rangle -/
noncomputable def areaEigenvalue (spin : SU2SpinRepresentation) (gamma ell_P : ℝ) : ℝ :=
  let j := (spin.two_j : ℝ) / 2
  8 * Real.pi * gamma * (ell_P ^ 2) * Real.sqrt (j * (j + 1))

/-- The LQG area eigenvalue is nonnegative for nonnegative Immirzi parameter. -/
theorem areaEigenvalue_nonneg
    (spin : SU2SpinRepresentation) (gamma ell_P : ℝ) (hgamma : 0 ≤ gamma) :
    0 ≤ areaEigenvalue spin gamma ell_P := by
  unfold areaEigenvalue
  let j : ℝ := (spin.two_j : ℝ) / 2
  have hj_nonneg : 0 ≤ j := by
    dsimp [j]
    exact div_nonneg (Nat.cast_nonneg spin.two_j) (by norm_num)
  have hj_plus_one_nonneg : 0 ≤ j + 1 :=
    add_nonneg hj_nonneg (by norm_num)
  have hpi_nonneg : 0 ≤ (8 : ℝ) * Real.pi :=
    mul_nonneg (by norm_num) (le_of_lt Real.pi_pos)
  have hellP_sq_nonneg : 0 ≤ ell_P ^ 2 := by
    simpa [pow_two] using sq_nonneg ell_P
  have hsqrt_nonneg : 0 ≤ Real.sqrt (j * (j + 1)) :=
    Real.sqrt_nonneg _
  exact
    mul_nonneg
      (mul_nonneg (mul_nonneg hpi_nonneg hgamma) hellP_sq_nonneg)
      hsqrt_nonneg

/-- Area eigenvalue vanishes when the Immirzi parameter is zero. -/
theorem areaEigenvalue_eq_zero_of_gamma_eq_zero
    (spin : SU2SpinRepresentation) (ell_P : ℝ) :
    areaEigenvalue spin 0 ell_P = 0 := by
  unfold areaEigenvalue
  ring

/-- Area eigenvalue vanishes when the Planck length scale is zero. -/
theorem areaEigenvalue_eq_zero_of_ellP_eq_zero
    (spin : SU2SpinRepresentation) (gamma : ℝ) :
    areaEigenvalue spin gamma 0 = 0 := by
  unfold areaEigenvalue
  ring

end CATEPT.External.Hyperunits
