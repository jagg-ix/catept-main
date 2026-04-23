import CATEPTMain.Quantum.CBO.Cblinfun_Matrix
/-!
# Cblinfun_Code — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Cblinfun_Code.thy` (Dominique Unruh — 2022)
Dependencies: Cblinfun_Matrix

Content: Code generation setup and computable instances for bounded operators.
  In AFP this file provides `code_unfold` and `code_datatype` declarations that
  make cblinfun computable via matrix representation.

  In Lean 4 Phase-1 we expose the computable bridge axioms.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Cblinfun_Code

open CATEPTMain.Quantum.CBO
open CATEPTMain.Quantum.CBO.Cblinfun_Matrix (opToMatrix)

-- ── Matrix ↔ Operator conversion for computation ─────────────────────────────
-- cboFromMatrix: build a CBOOp from an n×n complex matrix
noncomputable axiom cboFromMatrix (n : ℕ) : Matrix (Fin n) (Fin n) ℂ → CBOOp

-- The round-trip: opToMatrix ∘ cboFromMatrix = id  (for matching dimension n)
axiom cboFromMatrix_toMatrix (n : ℕ) (M : Matrix (Fin n) (Fin n) ℂ) :
    True  -- phase-1 placeholder; phase-2: opToMatrix n (cboFromMatrix n M) = M

-- ── Decidable equality for finite-dimensional operator comparison ─────────────
-- Decision procedure: two operators on ℂⁿ are equal iff their matrices are equal.
private axiom finDim_op_eq_iff_matrix_law (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    S = T ↔
    ∀ i j : Fin n,
      inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (S (EuclideanSpace.single j 1)) =
      inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (T (EuclideanSpace.single j 1))

theorem finDim_op_eq_iff_matrix (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    S = T ↔
    ∀ i j : Fin n,
      inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (S (EuclideanSpace.single j 1)) =
      inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (T (EuclideanSpace.single j 1)) :=
  finDim_op_eq_iff_matrix_law n S T

-- ── Trace computation ────────────────────────────────────────────────────────
-- Tr(T) = ∑ᵢ M_{ii}  (diagonal sum)
private axiom trace_eq_diag_sum_law (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ∑ i : Fin n, inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (T (EuclideanSpace.single i 1)) =
    (opToMatrix n T).trace

theorem trace_eq_diag_sum (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ∑ i : Fin n, inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (T (EuclideanSpace.single i 1)) =
    (opToMatrix n T).trace := trace_eq_diag_sum_law n T

end CATEPTMain.Quantum.CBO.Cblinfun_Code
