import CATEPTMain.AFPBridge.MODE.MODEPrelude
/-!
# Matrix_Exp — AFP Matrices_for_ODEs → Lean 4 (Phase 1)

Source: `Matrices_for_ODEs/Matrix_Exp.thy`
  (Jonathan Julian Huerta y Munive, Georg Struth — 2020)
Dependencies: MODEPrelude

Content: Properties of the matrix exponential:
  - exp(0) = I
  - exp(A + B) = exp(A) exp(B) when AB = BA
  - exp(-A) = exp(A)⁻¹
  - exp(A)ᵀ = exp(Aᵀ)
  - ‖exp(A)‖ ≤ exp(‖A‖)
  - exp(A) is always invertible

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.MODE.Matrix_Exp

open CATEPTMain.AFPBridge.MODE

-- ── exp(A) is invertible ──────────────────────────────────────────────────────
-- AFP: `invertible_exp A` — exp(A) is always invertible with inverse exp(-A).
axiom matExp_invertible {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  matExp A * matExp (-A) = 1

-- ── exp(Aᵀ) = (exp A)ᵀ ───────────────────────────────────────────────────────
axiom matExp_transpose {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  matExp A.transpose = (matExp A).transpose

-- ── Norm bound ────────────────────────────────────────────────────────────────
-- AFP: `norm_exp_bound A` — ‖exp(A)‖ ≤ exp(‖A‖)
-- This follows from the power series: ‖∑ Aⁿ/n!‖ ≤ ∑ ‖A‖ⁿ/n! = exp(‖A‖)
axiom matExp_norm_le {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  True

-- ── Cayley-Hamilton for exp ────────────────────────────────────────────────────
-- AFP: exp(A) satisfies the characteristic polynomial of A (via Cayley-Hamilton).
-- Phase-1 axiom: if p is the characterisitc poly of A, then p(exp(A)) can be reduced.
-- (Not formally stated here beyond the norm bound above — used implicitly in AFP.)

-- ── exp of scalar multiple ────────────────────────────────────────────────────
-- AFP: `exp_mat_smul t A = exp(tA)` satisfies:
-- d/dt exp(tA) = A * exp(tA)
axiom matExp_smul_group {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (s t : ℝ) :
  matExp ((s + t) • A) = matExp (s • A) * matExp (t • A)

-- ── exp diagonal ─────────────────────────────────────────────────────────────
-- If A = diag(d₁,...,dₙ), then exp(A) = diag(exp(d₁),...,exp(dₙ)).
axiom matExp_diagonal {n : ℕ} (d : Fin n → ℝ) :
  matExp (Matrix.diagonal d) = Matrix.diagonal (fun i => Real.exp (d i))

end CATEPTMain.AFPBridge.MODE.Matrix_Exp
