import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Sqrt
import NavierStokesClean.CATEPT.External.DimensionalEmbeddings
import NavierStokesClean.CATEPT.External.DSFLQGIntertwiners

namespace CATEPT.External.LQG

open Real CATEPT.External.Hyperunits

/--
  The Left-invariant vector fields J^i generating the su(2) Lie algebra.
  These operators correspond to the flux of the densitized triad in the
  canonical Hamiltonian formulation of full General Relativity.
-/
structure LeftInvariantOperator where
  /-- Matrix Index i ∈ {1, 2, 3} for the Pauli generator representation. -/
  generator_index : Fin 3
  /-- The classical flux integral of the triad across the 2-surface S. -/
  flux_value : ℝ

/--
  The quadratic Casimir operator J^2 = J_1^2 + J_2^2 + J_3^2.
  Its eigenvalues exactly correspond to the quantum Area Operator in LQG.
-/
noncomputable def casimirEigenvalue (j : SU2SpinRepresentation) : ℝ :=
  let j_val := (j.two_j : ℝ) / 2
  j_val * (j_val + 1)

/-- The area spectrum is exactly the Casimir spectrum multiplied by the LQG prefactor. -/
theorem areaEigenvalue_eq_prefactor_mul_sqrt_casimir
    (j : SU2SpinRepresentation) (gamma ell_P : ℝ) :
    areaEigenvalue j gamma ell_P =
      8 * Real.pi * gamma * (ell_P ^ 2) * Real.sqrt (casimirEigenvalue j) := by
  unfold areaEigenvalue casimirEigenvalue
  rfl

/-- Casimir eigenvalues are nonnegative for SU(2) spin labels. -/
theorem casimirEigenvalue_nonneg (j : SU2SpinRepresentation) :
    0 ≤ casimirEigenvalue j := by
  unfold casimirEigenvalue
  let j_val : ℝ := (j.two_j : ℝ) / 2
  have hj_nonneg : 0 ≤ j_val := by
    dsimp [j_val]
    exact div_nonneg (Nat.cast_nonneg j.two_j) (by norm_num)
  have hj_plus_one_nonneg : 0 ≤ j_val + 1 :=
    add_nonneg hj_nonneg (by norm_num)
  exact mul_nonneg hj_nonneg hj_plus_one_nonneg

/-- Casimir eigenvalue is strictly positive for strictly positive spin labels. -/
theorem casimirEigenvalue_pos_of_two_j_pos
    (j : SU2SpinRepresentation) (h : 0 < j.two_j) :
    0 < casimirEigenvalue j := by
  unfold casimirEigenvalue
  let j_val : ℝ := (j.two_j : ℝ) / 2
  have hj_pos : 0 < j_val := by
    dsimp [j_val]
    exact div_pos (Nat.cast_pos.mpr h) (by norm_num)
  have hj_plus_one_pos : 0 < j_val + 1 := by
    linarith
  exact mul_pos hj_pos hj_plus_one_pos

/-- Casimir eigenvalue vanishes for spin `j = 0`. -/
theorem casimirEigenvalue_eq_zero_of_two_j_eq_zero
    (j : SU2SpinRepresentation) (h : j.two_j = 0) :
    casimirEigenvalue j = 0 := by
  unfold casimirEigenvalue
  simp [h]

/-- Casimir vanishes exactly at spin label `2j = 0`. -/
theorem casimirEigenvalue_eq_zero_iff_two_j_eq_zero
    (j : SU2SpinRepresentation) :
    casimirEigenvalue j = 0 ↔ j.two_j = 0 := by
  constructor
  · intro hcas
    by_contra hne
    have htwoj_pos : 0 < j.two_j := Nat.pos_of_ne_zero hne
    have hcas_pos : 0 < casimirEigenvalue j :=
      casimirEigenvalue_pos_of_two_j_pos j htwoj_pos
    linarith
  · intro hz
    exact casimirEigenvalue_eq_zero_of_two_j_eq_zero j hz

/-- Casimir spectrum is monotone in the spin label `2j`. -/
theorem casimirEigenvalue_mono
    (j₁ j₂ : SU2SpinRepresentation)
    (h : j₁.two_j ≤ j₂.two_j) :
    casimirEigenvalue j₁ ≤ casimirEigenvalue j₂ := by
  unfold casimirEigenvalue
  let x : ℝ := (j₁.two_j : ℝ) / 2
  let y : ℝ := (j₂.two_j : ℝ) / 2
  have hx_nonneg : 0 ≤ x := by
    dsimp [x]
    exact div_nonneg (Nat.cast_nonneg j₁.two_j) (by norm_num)
  have hy_nonneg : 0 ≤ y := by
    dsimp [y]
    exact div_nonneg (Nat.cast_nonneg j₂.two_j) (by norm_num)
  have hxy : x ≤ y := by
    dsimp [x, y]
    exact div_le_div_of_nonneg_right (Nat.cast_le.mpr h) (by norm_num)
  nlinarith

/-- Compatibility: area nonnegativity follows from the embedding-side theorem. -/
theorem areaEigenvalue_nonneg_of_gamma_nonneg
    (j : SU2SpinRepresentation) (gamma ell_P : ℝ) (hgamma : 0 ≤ gamma) :
    0 ≤ areaEigenvalue j gamma ell_P :=
  CATEPT.External.Hyperunits.areaEigenvalue_nonneg j gamma ell_P hgamma

/-- Area eigenvalue vanishes when either the Immirzi parameter or Planck scale is zero. -/
theorem areaEigenvalue_eq_zero_of_gamma_eq_zero_or_ellP_eq_zero
    (j : SU2SpinRepresentation) (gamma ell_P : ℝ)
    (h : gamma = 0 ∨ ell_P = 0) :
    areaEigenvalue j gamma ell_P = 0 := by
  rcases h with hgamma | hellP
  · simpa [hgamma] using CATEPT.External.Hyperunits.areaEigenvalue_eq_zero_of_gamma_eq_zero j ell_P
  · simpa [hellP] using CATEPT.External.Hyperunits.areaEigenvalue_eq_zero_of_ellP_eq_zero j gamma

/--
  The Volume Operator \hat{V} in Loop Quantum Gravity.
  It acts specifically on the Intertwiner nodes of a Spin Network.
  Its discreteness confirms the fundamental granularity of 3D quantum space.
-/
noncomputable def volumeEigenvalue (node : IntertwinerSpace in_reps out_reps) (ell_P : ℝ) : ℝ :=
  -- A proportional map scaling the Planck length cubed by the invariant volume states
  (ell_P ^ 3) * Real.sqrt (node.invariant_dimension : ℝ)

/-- Volume eigenvalue is nonnegative for nonnegative Planck length scale. -/
theorem volumeEigenvalue_nonneg
    (node : IntertwinerSpace in_reps out_reps) (ell_P : ℝ) (hell_P : 0 ≤ ell_P) :
    0 ≤ volumeEigenvalue node ell_P := by
  unfold volumeEigenvalue
  have hpow_nonneg : 0 ≤ ell_P ^ 3 :=
    pow_nonneg hell_P 3
  have hsqrt_nonneg : 0 ≤ Real.sqrt (node.invariant_dimension : ℝ) :=
    Real.sqrt_nonneg _
  exact mul_nonneg hpow_nonneg hsqrt_nonneg

/-- Volume eigenvalue is strictly positive when both scale and invariant dimension are positive. -/
theorem volumeEigenvalue_pos_of_pos
    (node : IntertwinerSpace in_reps out_reps) (ell_P : ℝ)
    (hell_P : 0 < ell_P) (hnode : 0 < node.invariant_dimension) :
    0 < volumeEigenvalue node ell_P := by
  unfold volumeEigenvalue
  have hpow_pos : 0 < ell_P ^ 3 :=
    pow_pos hell_P 3
  have hsqrt_pos : 0 < Real.sqrt (node.invariant_dimension : ℝ) := by
    apply Real.sqrt_pos.mpr
    exact Nat.cast_pos.mpr hnode
  exact mul_pos hpow_pos hsqrt_pos

/-- Volume eigenvalue vanishes when Planck scale is zero. -/
theorem volumeEigenvalue_eq_zero_of_ellP_eq_zero
    (node : IntertwinerSpace in_reps out_reps) :
    volumeEigenvalue node 0 = 0 := by
  unfold volumeEigenvalue
  simp

/-- Volume eigenvalue vanishes when intertwiner invariant dimension is zero. -/
theorem volumeEigenvalue_eq_zero_of_invariant_dimension_eq_zero
    (node : IntertwinerSpace in_reps out_reps) (ell_P : ℝ)
    (hnode : node.invariant_dimension = 0) :
    volumeEigenvalue node ell_P = 0 := by
  unfold volumeEigenvalue
  simp [hnode]

/-- Nontrivial intertwiners with positive Planck scale give strictly positive volume. -/
theorem volumeEigenvalue_pos_of_nontrivial
    (node : IntertwinerSpace in_reps out_reps) (ell_P : ℝ)
    (hell_P : 0 < ell_P)
    (hnode : IntertwinerSpace.nontrivial node) :
    0 < volumeEigenvalue node ell_P :=
  volumeEigenvalue_pos_of_pos node ell_P hell_P hnode

end CATEPT.External.LQG
