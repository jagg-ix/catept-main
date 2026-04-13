import Mathlib
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_77_ComplexActionCoreStructures0410

/-!
# Batch 20260408 Theoremization - CATEPT Row 79 (ComplexAction Core Structures Fixed 0467)

Row-79 packages the fixed self-adjoint + Euclidean-propagator variant and
anchors its core identities.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B79

noncomputable section

/-- Row-79 generator package (fixed-version style). -/
structure row79Generator (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] where
  H_R : H →L[ℂ] H
  SigmaOp : H →L[ℂ] H
  hbar : ℝ
  hbar_pos : 0 < hbar
  H_R_selfAdj : IsSelfAdjoint H_R
  Sigma_accretive : ∀ ψ : H, 0 ≤ (inner ψ (SigmaOp ψ)).re

/-- Row-79 Euclidean generator wrapper with positivity of `H_R` form. -/
structure row79EucGenerator (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] where
  toGenerator : row79Generator H
  H_R_pos : ∀ ψ : H, 0 ≤ (inner ψ (toGenerator.H_R ψ)).re

/-- Row-79 Euclidean propagator package. -/
structure row79EuclideanPropagator
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row79EucGenerator H) where
  U : ℝ → (H →L[ℂ] H)
  U_zero_id : U 0 = ContinuousLinearMap.id ℂ H
  diff : ∀ v : H, Differentiable ℝ (fun τ => (U τ) v)
  eucEqn : ∀ v : H, ∀ τ : ℝ,
    deriv (fun s => (U s) v) τ
      = -((1 : ℂ) / (G.toGenerator.hbar : ℂ))
          • ((G.toGenerator.H_R + G.toGenerator.SigmaOp) ((U τ) v))

/-- Positive `hbar` implies nonzero complex denominator. -/
theorem row79_hbar_coe_ne_zero
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row79Generator H) :
    (G.hbar : ℂ) ≠ 0 := by
  exact_mod_cast (ne_of_gt G.hbar_pos)

/-- Euclidean equation specialized at `τ = 0`. -/
theorem row79_eucEq_at_zero
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row79EucGenerator H)
    (P : row79EuclideanPropagator G)
    (v : H) :
    deriv (fun s => (P.U s) v) 0
      = -((1 : ℂ) / (G.toGenerator.hbar : ℂ))
          • ((G.toGenerator.H_R + G.toGenerator.SigmaOp) ((P.U 0) v)) := by
  simpa using P.eucEqn v 0

/-- At zero time the propagator equals identity. -/
theorem row79_apply_U_zero
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row79EucGenerator H)
    (P : row79EuclideanPropagator G)
    (v : H) :
    (P.U 0) v = v := by
  simpa [P.U_zero_id] using congrArg (fun T => T v) P.U_zero_id

/-- Combined row-79 fixed-version witness package. -/
theorem row79_fixed_bundle
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row79EucGenerator H)
    (P : row79EuclideanPropagator G)
    (v : H) :
    (G.toGenerator.hbar : ℂ) ≠ 0 ∧
      (P.U 0) v = v ∧
      deriv (fun s => (P.U s) v) 0
        = -((1 : ℂ) / (G.toGenerator.hbar : ℂ))
            • ((G.toGenerator.H_R + G.toGenerator.SigmaOp) ((P.U 0) v)) := by
  exact ⟨row79_hbar_coe_ne_zero G.toGenerator,
    row79_apply_U_zero G P v,
    row79_eucEq_at_zero G P v⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B79
