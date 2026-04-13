import Mathlib

/-!
# Batch 20260408 Theoremization - Row 18 (Regularized Entropy Minimization)

A scalar theoremized core for the row-18 Schwarzschild/regularization obligations.
This isolates the algebraic heart of the minimization argument in a fully
checkable Lean form.
-/

set_option autoImplicit false

namespace NavierStokesClean.AFPBridge.Spacetime.Theoremized.Batch20260408.B18

noncomputable section

/-- Regularized minimizer candidate for
`J(φ)=χ(φ-b)^2 + lam·φ^2` with `χ>0, lam≥0`. -/
def phiStar (χ lam b : ℝ) : ℝ := (χ / (χ + lam)) * b

/-- Regularized objective. -/
def J (χ lam b φ : ℝ) : ℝ := χ * (φ - b) ^ 2 + lam * φ ^ 2

/-- First-order optimality equation for `phiStar`. -/
theorem optimality_equation_id
    (χ lam b : ℝ) (hχ : 0 < χ) (hlam : 0 ≤ lam) :
    χ * (phiStar χ lam b - b) + lam * phiStar χ lam b = 0 := by
  have hden_ne : χ + lam ≠ 0 := by linarith
  unfold phiStar
  field_simp [hden_ne]
  ring

/-- Completed-square decomposition for `J`. -/
theorem J_complete_square
    (χ lam b φ : ℝ) (hden : χ + lam ≠ 0) :
    J χ lam b φ =
      (χ + lam) * (φ - phiStar χ lam b) ^ 2 + (χ * lam / (χ + lam)) * b ^ 2 := by
  unfold J phiStar
  field_simp [hden]
  ring

/-- Uniqueness of minimizer for strictly positive `χ` and nonnegative `lam`. -/
theorem unique_minimizer_id
    (χ lam b φ : ℝ) (hχ : 0 < χ) (hlam : 0 ≤ lam)
    (hmin : J χ lam b φ = J χ lam b (phiStar χ lam b)) :
    φ = phiStar χ lam b := by
  have hden_ne : χ + lam ≠ 0 := by linarith
  have hsqform : J χ lam b φ =
      (χ + lam) * (φ - phiStar χ lam b) ^ 2 + (χ * lam / (χ + lam)) * b ^ 2 := by
    exact J_complete_square χ lam b φ hden_ne
  have hsqformStar : J χ lam b (phiStar χ lam b) =
      (χ + lam) * (phiStar χ lam b - phiStar χ lam b) ^ 2 + (χ * lam / (χ + lam)) * b ^ 2 := by
    exact J_complete_square χ lam b (phiStar χ lam b) hden_ne
  rw [hsqform, hsqformStar] at hmin
  have hpos : 0 < χ + lam := by linarith
  have hsq0 : (φ - phiStar χ lam b) ^ 2 = 0 := by
    nlinarith [hmin]
  have hdiff0 : φ - phiStar χ lam b = 0 := by
    exact sq_eq_zero_iff.mp hsq0
  linarith

/-- Entropy-production style scalar quantity from row-18 formula. -/
def sigma (χ lam b : ℝ) : ℝ := χ * (lam / (χ + lam)) ^ 2 * b ^ 2

theorem sigma_closed_form (χ lam b : ℝ) :
    sigma χ lam b = χ * (lam / (χ + lam)) ^ 2 * b ^ 2 := by
  rfl

theorem sigma_nonneg (χ lam b : ℝ) (hχ : 0 ≤ χ) :
    0 ≤ sigma χ lam b := by
  unfold sigma
  positivity

theorem sigma_vanishes_at_zero_lambda (χ b : ℝ) :
    sigma χ 0 b = 0 := by
  unfold sigma
  ring

/-- Positive transfer coefficient model inspired by row-18 `chiFromBetaI`. -/
def chiFromBetaI (betaInf N : ℝ) : ℝ := betaInf / (N + 1)

theorem chiFromBetaI_pos
    (betaInf N : ℝ)
    (hβ : 0 < betaInf) (hN : -1 < N) :
    0 < chiFromBetaI betaInf N := by
  unfold chiFromBetaI
  exact div_pos hβ (by linarith)

end

end NavierStokesClean.AFPBridge.Spacetime.Theoremized.Batch20260408.B18
