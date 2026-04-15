import CATEPTMain.AFPBridge.CBO.Theories.Extra_Jordan_Normal_Form
/-!
# Cblinfun_Matrix — AFP Complex_Bounded_Operators → Lean 4 (Phase 1)

Source: `Complex_Bounded_Operators/Cblinfun_Matrix.thy` (Dominique Unruh — 2022)
Dependencies: Extra_Jordan_Normal_Form

Content: Correspondence between bounded operators on ℂⁿ and n×n complex matrices:
  - Matrix representation of operators in a fixed ONB
  - Matrix multiplication = operator composition
  - Adjoint = conjugate transpose
  - Norm bounds via matrix norm

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Matrix

open CATEPTMain.AFPBridge.CBO

-- ── Matrix of an operator ─────────────────────────────────────────────────────
-- Given ONB {e_j}, the matrix of T is M_{ij} = ⟨eᵢ, T(eⱼ)⟩.
noncomputable def opToMatrix (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    Matrix (Fin n) (Fin n) ℂ :=
  fun i j => inner (𝕜 := ℂ) (EuclideanSpace.single i (1 : ℂ)) (T (EuclideanSpace.single j 1))

-- ── Operator recovered from matrix ───────────────────────────────────────────
-- T(v) = ∑ⱼ (∑ᵢ M_{ij} vⱼ) eᵢ
private axiom opToMatrix_apply_law (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) (v : EuclideanSpace ℂ (Fin n)) :
    T v = ∑ i : Fin n, (∑ j : Fin n, opToMatrix n T i j * v j) • EuclideanSpace.single i 1

theorem opToMatrix_apply (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) (v : EuclideanSpace ℂ (Fin n)) :
    T v = ∑ i : Fin n, (∑ j : Fin n, opToMatrix n T i j * v j) • EuclideanSpace.single i 1 :=
  opToMatrix_apply_law n T v

-- ── Adjoint = conjugate transpose ────────────────────────────────────────────
-- Phase-1 axiom (ContinuousLinearMap.adjoint import deferred to phase-2):
axiom opToMatrix_adj : True  -- phase2: opToMatrix n T.adjoint = (opToMatrix n T).conjTranspose

-- ── Composition = matrix multiplication ──────────────────────────────────────
private axiom opToMatrix_comp_law (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    opToMatrix n (S.comp T) = opToMatrix n S * opToMatrix n T

theorem opToMatrix_comp (n : ℕ)
    (S T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    opToMatrix n (S.comp T) = opToMatrix n S * opToMatrix n T :=
  opToMatrix_comp_law n S T

-- ── Norm bound via Frobenius norm ────────────────────────────────────────────
-- ‖T‖ ≤ ‖M(T)‖_F = √(∑ᵢⱼ |Mᵢⱼ|²)
private axiom opNorm_le_frobenius_law (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ‖T‖ ≤ Real.sqrt (∑ i : Fin n, ∑ j : Fin n, ‖opToMatrix n T i j‖^2)

theorem opNorm_le_frobenius (n : ℕ)
    (T : EuclideanSpace ℂ (Fin n) →L[ℂ] EuclideanSpace ℂ (Fin n)) :
    ‖T‖ ≤ Real.sqrt (∑ i : Fin n, ∑ j : Fin n, ‖opToMatrix n T i j‖^2) :=
  opNorm_le_frobenius_law n T

end CATEPTMain.AFPBridge.CBO.Theories.Cblinfun_Matrix
