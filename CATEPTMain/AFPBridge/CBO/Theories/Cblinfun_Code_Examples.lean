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
noncomputable def hadamard_mat : Matrix (Fin 2) (Fin 2) ℂ :=
  (1 / Real.sqrt 2 : ℝ) • ![![1, 1], ![1, -1]]

-- ── Operator product examples ─────────────────────────────────────────────────
-- σ_X² = I
theorem pauliX_sq_eq_id :
    pauliX_mat * pauliX_mat = 1 := by
  sorry -- phase2_calc: fin_cases; norm_num on matrix entries

-- H² = I (Hadamard is self-inverse):
theorem hadamard_sq_eq_id :
    hadamard_mat * hadamard_mat = (1 / (Real.sqrt 2 : ℝ))^2 • (2 : ℝ) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  sorry -- phase2_calc: matrix multiplication + Real.sq_sqrt

-- ── Trace computations ────────────────────────────────────────────────────────
-- Tr(σ_X) = 0
theorem tr_pauliX : pauliX_mat.trace = 0 := by
  simp [pauliX_mat, Matrix.trace, Fin.sum_univ_two]

-- Tr(I₂) = 2
theorem tr_identity_2 : (1 : Matrix (Fin 2) (Fin 2) ℂ).trace = 2 := by
  simp [Matrix.trace, Fin.sum_univ_two]

end CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Code_Examples
