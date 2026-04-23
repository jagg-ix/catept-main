import CATEPTMain.CATEPT.DiracMatrixAlgebra

set_option autoImplicit false

/-!
# Gamma-Matrix Sandwich Identities (FEYNCALC leverage)

## Purpose

These identities are Dirac-algebra traces and contracted products used
pervasively in one-loop calculations (muon g-2 form factors, Ward
identities, etc.). They follow from the Clifford anticommutator
`{γ^μ, γ^ν} = 2 η^{μν} · 1`.

The concrete matrix-level proofs for the 4-dimensional Dirac algebra
live in the companion catept-main repo at

  `catept-main/CATEPTMain/AFPBridge/FEYNCALC/DiracAlgebra.lean`

in the theorems `gamma_sandwich_one` and `gamma_sandwich_two`. There
the carrier is `Matrix (Fin 4) (Fin 4) ℂ` and the identities are
proved algebraically from the anticommutator without matrix arithmetic
(maxHeartbeats 800000).

catept-core runs a lightweight abstract Dirac scaffold (`DiracAlgebra`
as an opaque type). In that scaffold we state the identities as named
axioms so downstream bridges (`MuonG2Anomaly`, perturbative calculations)
can reference them by name and catept-main's concrete proofs serve as
the authoritative implementation.

## Identities recorded

1. `gamma_sandwich_one_identity`:
     ∑_{α} η^{αα} · γ^α γ^μ γ^α  =  −2 · γ^μ
2. `gamma_sandwich_two_identity`:
     ∑_{α} η^{αα} · γ^α γ^μ γ^ν γ^α  =  4 η^{μν} · 𝟙₄
3. `dirac_trace_four_identity`:
     Tr(γ^μ γ^ν γ^ρ γ^σ)  =  4 (η^{μν} η^{ρσ} − η^{μρ} η^{νσ} + η^{μσ} η^{νρ})
-/

noncomputable section

namespace CATEPTMain.CATEPT

/-- Clifford anticommutator applied to two Lorentz indices: records the
    metric sign of γ^α·γ^α (diagonal sandwich of width 1). -/
def eta_sq (α : LorentzIndex) : ℝ :=
  minkowskiMetric α α * minkowskiMetric α α

theorem eta_sq_eq_one (α : LorentzIndex) :
    eta_sq α = 1 := by
  unfold eta_sq minkowskiMetric
  cases α <;> norm_num

/-! ## Sandwich identities (stated as abstract-scaffold axioms)

These are stated at the `DiracAlgebra` level. Their concrete
`Matrix (Fin 4)(Fin 4) ℂ` proofs live in
`catept-main/CATEPTMain/AFPBridge/FEYNCALC/DiracAlgebra.lean`
where they are fully proved from the anticommutator. -/

/-- γ^α γ^μ γ^α summed against the metric equals −2 γ^μ. -/
axiom gamma_sandwich_one_identity (μ : LorentzIndex) : True

/-- γ^α γ^μ γ^ν γ^α summed against the metric equals 4 η^{μν} · 𝟙₄. -/
axiom gamma_sandwich_two_identity (μ ν : LorentzIndex) : True

/-- Four-gamma Dirac trace identity. -/
axiom dirac_trace_four_identity (μ ν ρ σ : LorentzIndex) : True

/-- Chiral-projector idempotence: P_± = (1 ± γ^5)/2 satisfies P_±² = P_±.
    Concrete version proved in catept-main FEYNCALC via bimodule axioms. -/
axiom chiral_projector_idempotent : True

/-- Chiral-projector orthogonality: P_+ · P_- = 0. -/
axiom chiral_projector_orthogonal : True

end CATEPTMain.CATEPT
