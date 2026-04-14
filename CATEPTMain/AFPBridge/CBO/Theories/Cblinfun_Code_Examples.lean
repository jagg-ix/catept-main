import CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code
/-!
# Cblinfun_Code_Examples — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Cblinfun_Code_Examples.thy` (Dominique Unruh — 2022)
Dependencies: Cblinfun_Code

Content: Worked examples of computing with bounded operators:
  - Pauli matrix operators
  - CNOT as a bounded operator
  - Operator composition examples
  - Trace computations

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code_Examples

open CATEPTMain.AFPBridge.CBO
open CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Matrix (opToMatrix)

-- ── Pauli X operator ──────────────────────────────────────────────────────────
-- σ_X = [[0,1],[1,0]]
noncomputable def pauliX_mat : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![0, 1], ![1, 0]]

-- ── Pauli Z operator ──────────────────────────────────────────────────────────
noncomputable def pauliZ_mat : Matrix (Fin 2) (Fin 2) ℂ :=
  ![![1, 0], ![0, -1]]

-- ── Hadamard operator ────────────────────────────────────────────────────────
-- Named inner matrix so matrix * (not Pi pointwise *) is used — hadamard-conjecture repo pattern
private noncomputable def hadamard_inner : Matrix (Fin 2) (Fin 2) ℂ := ![![1, 1], ![1, -1]]

noncomputable def hadamard_mat : Matrix (Fin 2) (Fin 2) ℂ :=
  (1 / Real.sqrt 2 : ℝ) • hadamard_inner

-- ── Operator product examples ─────────────────────────────────────────────────
-- σ_X² = I  (proved by component-wise matrix computation)
theorem pauliX_sq_eq_id :
    pauliX_mat * pauliX_mat = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [pauliX_mat, Matrix.mul_apply, Fin.sum_univ_two]

-- H² = I (Hadamard is self-inverse).
-- Key insight (from hadamard-conjecture repo):
--   inline ![![...]...] uses Pi.instMul (pointwise), named defs use Mul (Matrix n n α).
--   Solution: use a named inner matrix + norm_num [def, Matrix.mul_apply, Fin.sum_univ_two].
-- Note: push_cast triggers a Lean simproc PANIC on this goal; avoided via hMM + ofReal_div.
theorem hadamard_sq_eq_id :
    hadamard_mat * hadamard_mat = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  have hne : Real.sqrt 2 ≠ 0 := Real.sqrt_pos.mpr (by norm_num) |>.ne'
  -- Step 1: inner matrix self-product = 2·I (named def → correct Mul, not Pi.instMul)
  have hMM : hadamard_inner * hadamard_inner = (2 : ℝ) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
    ext i j; fin_cases i <;> fin_cases j <;>
      norm_num [hadamard_inner, Matrix.mul_apply, Fin.sum_univ_two, Matrix.smul_apply,
                Matrix.one_apply, RCLike.real_smul_eq_coe_mul]
  -- Step 2: factor the ℝ-scalar prefactor through the product
  simp only [hadamard_mat, Algebra.smul_mul_assoc, Algebra.mul_smul_comm, hMM]
  -- Step 3: collapse the ℝ-smul chain; prove scalar coefficient = 1 in ℝ, then one_smul.
  have hcoeff : (1 / Real.sqrt 2 : ℝ) * (1 / Real.sqrt 2 : ℝ) * 2 = 1 := by
    field_simp [hne]
    nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num)]
  simp only [smul_smul, ← mul_assoc, hcoeff, one_smul]

-- ── Trace computations ────────────────────────────────────────────────────────
-- Tr(σ_X) = 0
theorem tr_pauliX : pauliX_mat.trace = 0 := by
  simp [pauliX_mat, Matrix.trace, Fin.sum_univ_two]

-- Tr(I₂) = 2
theorem tr_identity_2 : (1 : Matrix (Fin 2) (Fin 2) ℂ).trace = 2 := by
  simp [Matrix.trace]

end CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code_Examples
