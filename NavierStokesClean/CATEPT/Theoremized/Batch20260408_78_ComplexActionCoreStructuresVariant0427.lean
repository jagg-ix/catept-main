import Mathlib
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_77_ComplexActionCoreStructures0410

/-!
# Batch 20260408 Theoremization - CATEPT Row 78 (ComplexAction Core Structures Variant 0427)

Row-78 keeps the same TDSE layout as row-77 but uses an explicit
inner-product symmetry field for `H_R`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B78

noncomputable section

/-- Row-78 generator variant with explicit inner-product symmetry axiom. -/
structure row78GeneratorSymm (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] where
  H_R : H →L[ℂ] H
  SigmaOp : H →L[ℂ] H
  hbar : ℝ
  hbar_pos : 0 < hbar
  H_R_symmetric : ∀ x y : H, inner (H_R x) y = inner x (H_R y)
  Sigma_accretive : ∀ ψ : H, 0 ≤ (inner ψ (SigmaOp ψ)).re

/-- Row-78 TDSE variant. -/
def row78TDSE
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row78GeneratorSymm H) (ψ : ℝ → H) : Prop :=
  ∀ t : ℝ,
    deriv ψ t
      = -(Complex.I / (G.hbar : ℂ)) • (G.H_R (ψ t))
        - ((1 : ℂ) / (G.hbar : ℂ)) • (G.SigmaOp (ψ t))

/-- Symmetry field specializes at `x = y`. -/
theorem row78_symmetry_diagonal
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row78GeneratorSymm H) (x : H) :
    inner (G.H_R x) x = inner x (G.H_R x) :=
  G.H_R_symmetric x x

/-- Row-78 TDSE also reduces when dissipative branch vanishes. -/
theorem row78_tdse_reduces_when_sigma_zero
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row78GeneratorSymm H) (ψ : ℝ → H)
    (hTDSE : row78TDSE G ψ)
    (hSigma : ∀ t : ℝ, G.SigmaOp (ψ t) = 0) :
    ∀ t : ℝ, deriv ψ t = -(Complex.I / (G.hbar : ℂ)) • (G.H_R (ψ t)) := by
  intro t
  simpa [row78TDSE, hSigma t] using hTDSE t

/-- Row-78 compatibility check against row-77 TDSE shape. -/
theorem row78_tdse_shape_matches_row77
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G78 : row78GeneratorSymm H)
    (G77 : NavierStokesClean.CATEPT.Theoremized.Batch20260408.B77.row77Generator H)
    (ψ : ℝ → H)
    (hEqH : G78.H_R = G77.H_R)
    (hEqS : G78.SigmaOp = G77.SigmaOp)
    (hEqh : G78.hbar = G77.hbar)
    (h78 : row78TDSE G78 ψ) :
    NavierStokesClean.CATEPT.Theoremized.Batch20260408.B77.row77TDSE G77 ψ := by
  intro t
  subst hEqH
  subst hEqS
  subst hEqh
  simpa [NavierStokesClean.CATEPT.Theoremized.Batch20260408.B77.row77TDSE, row78TDSE] using h78 t

/-- Combined row-78 variant witness package. -/
theorem row78_core_structures_variant_bundle
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row78GeneratorSymm H) (ψ : ℝ → H)
    (hTDSE : row78TDSE G ψ)
    (hSigma : ∀ t : ℝ, G.SigmaOp (ψ t) = 0)
    (x : H) :
    inner (G.H_R x) x = inner x (G.H_R x) ∧
      (∀ t : ℝ, deriv ψ t = -(Complex.I / (G.hbar : ℂ)) • (G.H_R (ψ t))) := by
  exact ⟨row78_symmetry_diagonal G x,
    row78_tdse_reduces_when_sigma_zero G ψ hTDSE hSigma⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B78
