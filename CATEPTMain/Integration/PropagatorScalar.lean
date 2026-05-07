/-
  T-P Phase 1: Two-point connected propagator in the scalar Gaussian sector.

  Composes T-O (`log Z[J]/Z[0] = b² / (4 a)` in 1D) with elementary
  Mathlib calculus to extract the standard QFT generating-functional
  identities

      one-point function:     ∂_b W[J] |_{b=0}        =  0
      connected propagator:   ∂²_b W[J] |_{b=0}       =  1 / (2 a)

  where `W[J] := log Z[J]/Z[0] = completionResidual a b = b² / (4 a)`.

  These are the canonical "physics readings" of the generator: the
  source dual at `b=0` is the field expectation, which vanishes
  because the action is even, and the second derivative is the
  inverse kinetic operator (the propagator G = (2a)⁻¹). They follow
  from `HasDerivAt` on `b ↦ b² / (4 a)` and `b ↦ b / (2 a)`; positivity
  of `a` is only used to make the quotient well-formed.
-/
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import CATEPTMain.Integration.GaussianCompletion

set_option autoImplicit false

namespace CATEPTMain.Integration.PropagatorScalar

open CATEPTMain.Integration.GaussianCompletion

noncomputable section

/-- First derivative of the scalar completion residual.

    `d/db (b² / (4 a)) = b / (2 a)`. Algebraic identity
    (no positivity hypothesis needed; the equality
    `2 b / (4 a) = b / (2 a)` is a field identity that `ring`
    discharges, treating `a` as a free variable). -/
theorem hasDerivAt_residual (a b : ℝ) :
    HasDerivAt (fun b => completionResidual a b) (b / (2 * a)) b := by
  have hpow : HasDerivAt (fun b : ℝ => b ^ 2)
      ((2 : ℕ) * b ^ ((2 : ℕ) - 1) * 1) b :=
    (hasDerivAt_id b).pow 2
  have hdiv : HasDerivAt (fun b : ℝ => b ^ 2 / (4 * a))
      ((2 : ℕ) * b ^ ((2 : ℕ) - 1) * 1 / (4 * a)) b :=
    hpow.div_const (4 * a)
  -- Repackage the derivative value `2*b/(4*a)` as `b/(2*a)` and
  -- the function as `completionResidual a`.
  have hfun : (fun b : ℝ => b ^ 2 / (4 * a))
      = fun b => completionResidual a b := by
    funext b; simp [completionResidual]
  have hval :
      (2 : ℕ) * b ^ ((2 : ℕ) - 1) * 1 / (4 * a) = b / (2 * a) := by
    push_cast
    ring
  rw [← hfun, ← hval]
  exact hdiv

/-- Second derivative (i.e. the connected propagator):
    `d/db (b / (2 a)) = 1 / (2 a)`. -/
theorem hasDerivAt_propagator (a b : ℝ) :
    HasDerivAt (fun b => b / (2 * a)) (1 / (2 * a)) b := by
  have hid : HasDerivAt (fun b : ℝ => b) 1 b := hasDerivAt_id' b
  exact hid.div_const (2 * a)

/-- **One-point function vanishes at zero source** (T-P Phase 1).

    `∂_b W[J] |_{b=0} = 0`, where `W[J] = b² / (4 a)`. -/
theorem one_point_scalar (a : ℝ) :
    deriv (fun b => completionResidual a b) 0 = 0 := by
  have h := (hasDerivAt_residual a 0).deriv
  rw [h]; simp

/-- **Connected propagator** (T-P Phase 1, scalar 1D).

    `∂²_b W[J] |_{b=0} = 1 / (2 a)`, the inverse kinetic operator
    of the Gaussian action `a x²` (one-mode case). -/
theorem propagator_scalar (a : ℝ) :
    deriv (fun b => deriv (fun b' => completionResidual a b') b) 0
      = 1 / (2 * a) := by
  -- First, replace the inner derivative function by its closed form.
  have hinner :
      (fun b => deriv (fun b' => completionResidual a b') b)
        = fun b => b / (2 * a) := by
    funext b
    exact (hasDerivAt_residual a b).deriv
  rw [hinner]
  exact (hasDerivAt_propagator a 0).deriv

end

end CATEPTMain.Integration.PropagatorScalar
