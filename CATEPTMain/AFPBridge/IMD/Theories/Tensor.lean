import CATEPTMain.AFPBridge.IMD.Theories.Quantum
/-!
# Tensor — AFP Isabelle_Marries_Dirac → Lean 4 (Phase 1)

Source: `Isabelle_Marries_Dirac/Tensor.thy` (Bordg, Lachnitt, He — 2020)
Dependencies: Quantum, Matrix_Tensor

Content: Tensor (Kronecker) product of complex matrices and state vectors.
  Associativity, distributivity over addition and scalar multiplication,
  dimension formulas, interaction with dagger and matrix multiplication.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.IMD.Theories.Tensor

open CATEPTMain.AFPBridge.IMD

-- ── Tensor product dimensions ──────────────────────────────────────────────────
-- AFP: `dim_row (A ⊗ B) = dim_row A * dim_row B`

theorem tensorMat_dimRow_eq (A B : QMat) :
    dimRow (tensorMat A B) = dimRow A * dimRow B :=
  tensorMat_dimRow A B

theorem tensorMat_dimCol_eq (A B : QMat) :
    dimCol (tensorMat A B) = dimCol A * dimCol B :=
  tensorMat_dimCol A B

-- ── Tensor product associativity ───────────────────────────────────────────────
-- AFP: `tensor_mat_assoc A B C` — (A⊗B)⊗C = A⊗(B⊗C)

theorem tensorMat_assoc (A B C : QMat) :
    tensorMat (tensorMat A B) C = tensorMat A (tensorMat B C) :=
  tensorMat_assoc_law A B C

-- ── Tensor product distributivity ─────────────────────────────────────────────

-- AFP: `tensor_mat_distr_left A B C` — A⊗(B+C) = A⊗B + A⊗C
theorem tensorMat_distrib_right (A B C : QMat)
    (hAR : dimRow A > 0) (hAC : dimCol A > 0)
    (hBR : dimRow B = dimRow C) (hBC : dimCol B = dimCol C) :
    tensorMat A (matAdd B C) = matAdd (tensorMat A B) (tensorMat A C) :=
  tensorMat_distrib_right_law A B C

-- AFP: `tensor_mat_distr_right` — (A+B)⊗C = A⊗C + B⊗C
theorem tensorMat_distrib_left (A B C : QMat)
    (hCR : dimRow C > 0) (hCC : dimCol C > 0)
    (hAR : dimRow A = dimRow B) (hAC : dimCol A = dimCol B) :
    tensorMat (matAdd A B) C = matAdd (tensorMat A C) (tensorMat B C) :=
  tensorMat_distrib_left_law A B C

-- ── Scalar interaction ─────────────────────────────────────────────────────────
-- AFP: `tensor_mat_scalar c A B` — (c·A)⊗B = c·(A⊗B)
theorem tensorMat_smul_left (c : ℂ) (A B : QMat) :
    tensorMat (smulMat c A) B = smulMat c (tensorMat A B) :=
  tensorMat_smul_left_law c A B

-- ── Tensor product vs. matrix multiplication ──────────────────────────────────
-- AFP: `mixed_product A B C D` — (A⊗B)*(C⊗D) = (A*C)⊗(B*D)
-- (mixed product property of Kronecker product)

theorem tensorMat_mixed_product (A B C D : QMat)
    (hAC : dimCol A = dimRow C) (hBD : dimCol B = dimRow D) :
    matMul (tensorMat A B) (tensorMat C D) =
    tensorMat (matMul A C) (matMul B D) :=
  tensorMat_mixed_product_law A B C D

-- ── Dagger and tensor ──────────────────────────────────────────────────────────
-- AFP: `tensor_mat_dagger A B` — (A⊗B)† = A†⊗B†
theorem tensorMat_dagger (A B : QMat) :
    dagger (tensorMat A B) = tensorMat (dagger A) (dagger B) :=
  tensorMat_dagger_law A B

-- ── Tensor product of unitary matrices is unitary ─────────────────────────────
-- AFP: `tensor_mat_unitary A B` — if A and B are unitary then A⊗B is unitary
theorem tensorMat_unitary (A B : QMat)
    (hA : unitaryMat A) (hB : unitaryMat B) :
    unitaryMat (tensorMat A B) :=
  tensorMat_unitary_law A B hA hB

-- ── Index formula for Kronecker product ───────────────────────────────────────
-- AFP: `tensor_mat_index A B i j` — explicit index formula
theorem tensorMat_index (A B : QMat) (i j : ℕ)
    (hi : i < dimRow A * dimRow B) (hj : j < dimCol A * dimCol B) :
    indexMat (tensorMat A B) i j =
    indexMat A (i / dimRow B) (j / dimCol B) *
    indexMat B (i % dimRow B) (j % dimCol B) :=
  tensorMat_index_law A B i j

-- ── Tensor product of quantum states ─────────────────────────────────────────
-- AFP: `tensor_state v w` — tensor product of normalized states is normalized-
-- (from Quantum.lean's tensorVec_state)

end CATEPTMain.AFPBridge.IMD.Theories.Tensor
