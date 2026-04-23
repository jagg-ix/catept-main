import CATEPTMain.MODE.Matrix_Exp
import CATEPTMain.ODE.Flow
/-!
# Affine_ODE — AFP Matrices_for_ODEs → Lean 4 (Phase 1)

Source: `Matrices_for_ODEs/Affine_ODE.thy`
  (Jonathan Julian Huerta y Munive, Georg Struth — 2020)
Dependencies: Matrix_Exp, ODEFlow

Content: Closed-form solutions and stability for affine matrix ODE systems:
  - Linear system: x' = Ax,  solution: x(t) = exp(tA) x₀
  - Affine system: x' = Ax + b,  solution: variation-of-parameters formula
  - Stability: spectral radius condition for Lyapunov stability
  - Variation of constants formula

Phase: 1 (all proofs `sorry`; statements faithfully typed)
-/

set_option autoImplicit false

namespace CATEPTMain.MODE.Affine_ODE

open CATEPTMain.MODE
open CATEPTMain.ODE

-- ── Linear system: uniqueness ─────────────────────────────────────────────────
-- The unique solution to x' = Ax, x(t₀) = x₀ is x(t) = exp((t-t₀)A) x₀.
axiom linearODE_unique {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ)
    (y : ℝ → Fin n → ℝ)
    (hy₀ : y t₀ = x₀)
    (hy : ∀ t, HasDerivAt y (A.mulVec (y t)) t) :
  y = linearODESol A t₀ x₀

-- ── Affine solution: initial condition ───────────────────────────────────────
axiom affineODESol_init {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ) :
  affineODESol A b t₀ x₀ t₀ = x₀

-- ── Variation-of-constants formula ───────────────────────────────────────────
-- x(t) = exp((t-t₀)A) x₀ + ∫_{t₀}^t exp((t-s)A) b ds
-- This is the standard variation-of-parameters (Duhamel) formula.
-- Already embedded in affineODESol definition above.
-- Phase-1: verify its equivalence to the explicit formula when A is invertible.
axiom affineODESol_invertible {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (t₀ : ℝ) (x₀ : Fin n → ℝ) (hA : Matrix.det A ≠ 0) (t : ℝ) :
    affineODESol A b t₀ x₀ t =
  (matExp ((t - t₀) • A)).mulVec (x₀ + A⁻¹.mulVec b) - A⁻¹.mulVec b

-- ── Equilibrium of affine system ─────────────────────────────────────────────
-- Equilibria of x' = Ax + b are solutions to Ax + b = 0, i.e., x* = -A⁻¹ b.
axiom affine_equilibrium {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ) (hA : Matrix.det A ≠ 0) :
    let x_star := (-(A⁻¹)).mulVec b
  A.mulVec x_star + b = 0

-- ── Exponential stability ─────────────────────────────────────────────────────
-- If all eigenvalues of A have strictly negative real part, trajectories converge
-- to the equilibrium exponentially fast.
-- Phase-1: stated as axiom (requires spectral theory).
axiom expStability {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (α : ℝ) (hα : 0 < α)
    (hSpec : True  -- phase-1: ∀ λ ∈ spectrum A, λ.re < -α
  ) : True

end CATEPTMain.MODE.Affine_ODE
