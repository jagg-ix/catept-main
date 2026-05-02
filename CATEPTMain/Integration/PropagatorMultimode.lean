/-
  T-Q Phase 1: Diagonal multimode propagator and quadratic-form identity.

  Lifts T-P (scalar two-point connected propagator) to the diagonal
  multimode case via two compositions:

      Per-slot diagonal propagator (T-P specialised):
          ∂²_b ( completionResidual (a i) b )  |_{b=0}  =  1 / (2 a i)

      Quadratic-form / Hessian reading of T-O multimode W[b]:
          2 · W[b]  =  ∑ᵢ  bᵢ · bᵢ / (2 aᵢ)
                    =  bᵀ · G · b      where G_{ij} = δ_{ij}/(2 aᵢ)

  The first is a direct corollary of T-P's `propagator_scalar` reused
  pointwise. The second is a pure algebraic rewrite of T-O multimode's
  W[b] = ∑ᵢ bᵢ² / (4 aᵢ); it exposes the diagonal propagator as the
  bilinear form of the connected two-point function — the canonical
  matrix-kernel reading from QFT generating-functional calculus.

  Off-diagonal components vanish definitionally (`if i = j then ...`),
  so the multimode propagator is literally `δᵢⱼ / (2 aᵢ)`.
-/
import CATEPTMain.Integration.PropagatorScalar
import CATEPTMain.Integration.LogZJRatio

set_option autoImplicit false

namespace CATEPTMain.Integration.PropagatorMultimode

open CATEPTMain.Integration.GaussianCompletion
open CATEPTMain.Integration.PropagatorScalar

noncomputable section

/-- The diagonal multimode propagator kernel `G_{ij} = δ_{ij} / (2 aᵢ)`.

    Off-diagonal entries vanish by definition; on the diagonal we read
    off the inverse kinetic operator per mode. -/
def propagatorKernel {ι : Type*} [DecidableEq ι] (a : ι → ℝ) (i j : ι) : ℝ :=
  if i = j then 1 / (2 * a i) else 0

/-- **Per-slot diagonal propagator** (T-Q Phase 1).

    For each mode `i`, the second derivative of the per-slot generating
    functional `b ↦ completionResidual (a i) b` at the origin equals
    `1 / (2 a i)` — the inverse kinetic operator at slot `i`. Direct
    corollary of `propagator_scalar` specialised to `a := a i`. -/
theorem propagator_diagonal {ι : Type*} (a : ι → ℝ) (i : ι) :
    deriv (fun b =>
      deriv (fun b' => completionResidual (a i) b') b) 0
      = 1 / (2 * a i) :=
  propagator_scalar (a i)

/-- **Propagator quadratic-form identity** (T-Q Phase 1, multimode
    reading).

    The connected free-energy `W[b] = ∑ᵢ bᵢ² / (4 aᵢ)` (T-O multimode)
    rewrites as

        2 · W[b]  =  ∑ᵢ bᵢ · ((G · b) ᵢ)

    where `(G · b) ᵢ = ∑ⱼ G ᵢⱼ · bⱼ = bᵢ / (2 aᵢ)` because `G` is
    diagonal. Exposes `propagatorKernel` as the kernel of the connected
    two-point function on the diagonal sector. -/
theorem W_eq_propagator_quadratic_form
    {ι : Type*} [Fintype ι] [DecidableEq ι] (a b : ι → ℝ) :
    2 * (∑ i, completionResidual (a i) (b i))
      = ∑ i, b i * (∑ j, propagatorKernel a i j * b j) := by
  -- Both sides simplify to ∑ i, b i ^ 2 / (2 * a i).
  -- LHS unfolds via completionResidual; RHS via the diagonal kernel
  -- (Finset.sum_ite_eq picks out the j = i term).
  classical
  -- Reduce to a per-mode equality, then pick out the j = i term from the
  -- inner sum via `Finset.sum_eq_single`.
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl ?_
  intro i _
  rw [Finset.sum_eq_single i (fun j _ hji => by
        simp [propagatorKernel, (Ne.symm hji)]) (by simp)]
  -- Goal: 2 * completionResidual (a i) (b i)
  --       = b i * (propagatorKernel a i i * b i)
  simp [completionResidual, propagatorKernel]
  ring

end

end CATEPTMain.Integration.PropagatorMultimode
