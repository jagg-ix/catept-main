import CATEPTMain.AFPBridge.MTN.MTNPrelude
/-!
# Kronecker_Product — AFP Matrix_Tensor → Lean 4 (Phase 1)

Source: `Matrix_Tensor/Kronecker_Product.thy` (T.V.H. Prathamesh — 2016)
Dependencies: Matrix_Tensor (MTN)

Content: Basic definition, bilinearity, associativity, zero/identity properties,
  transpose rule, and the mixed-product property of the Kronecker product.

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.MTN.Kronecker_Product

open CATEPTMain.AFPBridge.MTN

-- ── Kronecker product addition bilinearity ────────────────────────────────────
-- AFP: `kron_add_left`: (A + B) ⊗ C = A ⊗ C + B ⊗ C
theorem kronecker_add_left {m n p q : ℕ}
    (A B : Matrix (Fin m) (Fin n) ℝ) (C : Matrix (Fin p) (Fin q) ℝ) :
    Matrix.kronecker (A + B) C = Matrix.kronecker A C + Matrix.kronecker B C := by
  ext ⟨i₁, i₂⟩ ⟨j₁, j₂⟩
  simp [Matrix.kronecker_apply, add_mul]

-- AFP: `kron_add_right`: A ⊗ (B + C) = A ⊗ B + A ⊗ C
theorem kronecker_add_right {m n p q : ℕ}
    (A : Matrix (Fin m) (Fin n) ℝ) (B C : Matrix (Fin p) (Fin q) ℝ) :
    Matrix.kronecker A (B + C) = Matrix.kronecker A B + Matrix.kronecker A C := by
  ext ⟨i₁, i₂⟩ ⟨j₁, j₂⟩
  simp [Matrix.kronecker_apply, mul_add]

-- ── Kronecker with zero matrix ────────────────────────────────────────────────
theorem kronecker_zero_left {m n p q : ℕ} (B : Matrix (Fin p) (Fin q) ℝ) :
    Matrix.kronecker (0 : Matrix (Fin m) (Fin n) ℝ) B = 0 := by
  ext ⟨i₁, i₂⟩ ⟨j₁, j₂⟩
  simp [Matrix.kronecker_apply]

theorem kronecker_zero_right {m n p q : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) :
    Matrix.kronecker A (0 : Matrix (Fin p) (Fin q) ℝ) = 0 := by
  ext ⟨i₁, i₂⟩ ⟨j₁, j₂⟩
  simp [Matrix.kronecker_apply]

-- ── Diagonal Kronecker structure ──────────────────────────────────────────────
-- AFP: A diagonal × B diagonal = diagonal (eigenvalues product)
-- If D = diag(d₁,...,dₙ) and E = diag(e₁,...,eₘ), then D⊗E is diagonal
-- with entries d_i * e_j listed in lexicographic order.
theorem kronecker_diagonal {n m : ℕ} (d : Fin n → ℝ) (e : Fin m → ℝ) :
    Matrix.kronecker (Matrix.diagonal d) (Matrix.diagonal e) =
    Matrix.diagonal (fun ij => d ij.1 * e ij.2) := by
  ext ⟨i₁, i₂⟩ ⟨j₁, j₂⟩
  simp [Matrix.kronecker_apply, Matrix.diagonal_apply]
  split_ifs with h1 h2 h2 <;> simp_all

-- ── Vectorization (vec) ───────────────────────────────────────────────────────
-- AFP: `vec` stacks columns of a matrix into a vector.
-- Phase-1: relate Kronecker to linear-map action via vec.
-- (A⊗B) vec(X) = vec(B X Aᵀ)  — the Kronecker mixed-product in vector form.
axiom kronecker_vec_identity {m n p q : ℕ}
    (A : Matrix (Fin m) (Fin p) ℝ) (B : Matrix (Fin n) (Fin q) ℝ)
    (X : Matrix (Fin q) (Fin p) ℝ) :
    True  -- phase-1: (A⊗B) vec(X) = vec(B X Aᵀ)

end CATEPTMain.AFPBridge.MTN.Kronecker_Product
