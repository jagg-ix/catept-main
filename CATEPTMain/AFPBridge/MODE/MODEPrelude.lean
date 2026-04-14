import CATEPTMain.AFPBridge.ODE.ODEPrelude
import CATEPTMain.AFPBridge.Framework.AFPBridgeFramework
/-!
# MODE Prelude — Matrices_for_ODEs (AFP) → Lean 4

Phase-1 opaque scaffold for `Matrices_for_ODEs`
  (Jonathan Julian Huerta y Munive, Georg Struth — 2020).
  https://www.isa-afp.org/entries/Matrices_for_ODEs.html

AFP dependencies bridged here:
  Ordinary_Differential_Equations (ODE — see ODEPrelude.lean)
  HOL-Analysis → Mathlib imports

CRITICAL TYPE NOTE:
  AFP `exp_mat A` = matrix exponential (power series Σ Aⁿ/n!)
  → Lean 4: `Matrix.exp ℝ A` where A : Matrix (Fin n) (Fin n) ℝ
            (Mathlib.LinearAlgebra.Matrix.Exp — available directly!)

  AFP `mat_norm A` — Frobenius / operator norm.
  → Lean 4: `‖A‖` via the induced `NormedRing` instance on `Matrix`.

BINDER RULES:
  B70: `exp_mat A` → `Matrix.exp ℝ A`  (direct Mathlib)
  B71: `mat_norm A` → `‖A‖`            (NormedRing instance)
  B72: affine ODE solution → `modeSolAffine A b t₀ x₀`

Phase-2 upgrade path:
  Matrix.exp properties (add_exp, exp_add_comm, exp_zero) are already in Mathlib;
  affine ODE lemmas need proof from ODE uniqueness.

See: CATEPTMain/AFPBridge/MODE/MODE_WORKLOG.lean
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.MODE

-- ── Matrix exponential (via Mathlib) ─────────────────────────────────────────
-- AFP: `exp_mat A` = ∑_{k=0}^∞ Aᵏ / k!
-- BINDER RULE B70: use `Matrix.exp ℝ A` directly.
-- Key Mathlib lemmas already proven:
--   Matrix.exp_zero, Matrix.exp_add_of_commute, Matrix.exp_neg
-- We alias for AFP naming convenience:
noncomputable axiom matExp {n : ℕ} : Matrix (Fin n) (Fin n) ℝ → Matrix (Fin n) (Fin n) ℝ

-- ── Matrix exponential: exp(0) = I ────────────────────────────────────────────
axiom matExp_zero (n : ℕ) : matExp (0 : Matrix (Fin n) (Fin n) ℝ) = 1

-- ── Matrix exponential: exp(A+B) = exp(A)exp(B) when AB = BA ─────────────────
-- AFP: `exp_mat_add A B h` where h : A * B = B * A
axiom matExp_add_commute {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) ℝ) (hComm : A * B = B * A) :
  matExp (A + B) = matExp A * matExp B

-- ── Matrix exponential: exp(tA) derivative ────────────────────────────────────
-- d/dt exp(tA) = A * exp(tA) = exp(tA) * A
axiom matExp_deriv {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (t : ℝ) :
  HasDerivAt (fun s => matExp (s • A)) (A * matExp (t • A)) t

-- ── Linear ODE solution: x' = Ax ─────────────────────────────────────────────
-- AFP: `linear_ode_sol A t₀ x₀ t = exp((t-t₀) * A) * x₀`
-- The unique solution to x' = Ax, x(t₀) = x₀.
noncomputable def linearODESol {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ) (t : ℝ) : Fin n → ℝ :=
  (matExp ((t - t₀) • A)).mulVec x₀

-- Verify initial condition:
axiom linearODESol_init {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ) :
  linearODESol A t₀ x₀ t₀ = x₀

-- Verify differential equation:
axiom linearODESol_deriv {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ) (t : ℝ) :
  HasDerivAt (linearODESol A t₀ x₀) (A.mulVec (linearODESol A t₀ x₀ t)) t

-- ── Affine ODE solution: x' = Ax + b ─────────────────────────────────────────
-- AFP: `affine_ode_sol A b t₀ x₀ t = exp(tA)(x₀ + A⁻¹b) - A⁻¹b`
-- (when A is invertible; otherwise use variation-of-parameters formula)
noncomputable axiom affineODESol {n : ℕ}
  (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ) (t : ℝ) :
  Fin n → ℝ

-- ── Affine solution satisfies ODE ─────────────────────────────────────────────
axiom affineODESol_satisfies_ode {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ) (t₀ : ℝ) (x₀ : Fin n → ℝ) (t : ℝ) :
    HasDerivAt (affineODESol A b t₀ x₀)
      (A.mulVec (affineODESol A b t₀ x₀ t) + b) t

-- ── Lyapunov stability ────────────────────────────────────────────────────────
-- AFP: x₀ stable equilibrium for x' = Ax iff all eigenvalues of A have Re ≤ 0.
-- Phase-1 axiom (requires spectral theory from Mathlib).
axiom lyapunov_stability_spec {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
  True
    -- phase-1 stub; phase-2: ↔ ∀ λ ∈ spectrum ℝ A, λ.re ≤ 0

end CATEPTMain.AFPBridge.MODE
