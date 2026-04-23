import Mathlib

/-!
# Batch 20260408 Theoremization - CATEPT Row 77 (ComplexAction Core Structures 0410)

Row-77 formalizes the core ComplexAction structures (complex Lagrangian,
EPT clock, non-Hermitian generator, TDSE equation) in row-prefixed form,
without colliding with existing repo namespaces.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B77

noncomputable section

/-- Row-77 complex Lagrangian skeleton. -/
structure row77LagrangianC (Q : Type*) [NormedAddCommGroup Q] [NormedSpace ℝ Q] where
  L_R : Q → Q → ℝ → ℝ
  L_I : Q → Q → ℝ → ℝ

/-- Row-77 entropic proper-time clock skeleton. -/
structure row77EPTClock (Q : Type*) where
  betaI : Q → ℝ
  pos : ∀ x, 0 < betaI x

/-- Row-77 non-Hermitian generator package. -/
structure row77Generator (H : Type*) [NormedAddCommGroup H] [InnerProductSpace ℂ H] where
  H_R : H →L[ℂ] H
  SigmaOp : H →L[ℂ] H
  hbar : ℝ
  hbar_pos : 0 < hbar
  H_R_selfAdj : IsSelfAdjoint H_R
  Sigma_accretive : ∀ ψ : H, 0 ≤ (inner ψ (SigmaOp ψ)).re

/-- Row-77 TDSE law. -/
def row77TDSE
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row77Generator H) (ψ : ℝ → H) : Prop :=
  ∀ t : ℝ,
    deriv ψ t
      = -(Complex.I / (G.hbar : ℂ)) • (G.H_R (ψ t))
        - ((1 : ℂ) / (G.hbar : ℂ)) • (G.SigmaOp (ψ t))

/-- Positive `hbar` implies its complex coercion is nonzero. -/
theorem row77_hbar_coe_ne_zero
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row77Generator H) :
    (G.hbar : ℂ) ≠ 0 := by
  exact_mod_cast (ne_of_gt G.hbar_pos)

/-- TDSE reduces to pure Hermitian branch when `SigmaOp` vanishes on the trajectory. -/
theorem row77_tdse_reduces_when_sigma_zero
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row77Generator H) (ψ : ℝ → H)
    (hTDSE : row77TDSE G ψ)
    (hSigma : ∀ t : ℝ, G.SigmaOp (ψ t) = 0) :
    ∀ t : ℝ, deriv ψ t = -(Complex.I / (G.hbar : ℂ)) • (G.H_R (ψ t)) := by
  intro t
  simpa [row77TDSE, hSigma t] using hTDSE t

/-- Combined row-77 core-structure witness package. -/
theorem row77_core_structures_bundle
    {H : Type*} [NormedAddCommGroup H] [InnerProductSpace ℂ H]
    (G : row77Generator H) (ψ : ℝ → H)
    (hTDSE : row77TDSE G ψ)
    (hSigma : ∀ t : ℝ, G.SigmaOp (ψ t) = 0) :
    (G.hbar : ℂ) ≠ 0 ∧
      (∀ t : ℝ, deriv ψ t = -(Complex.I / (G.hbar : ℂ)) • (G.H_R (ψ t))) := by
  exact ⟨row77_hbar_coe_ne_zero G,
    row77_tdse_reduces_when_sigma_zero G ψ hTDSE hSigma⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B77
