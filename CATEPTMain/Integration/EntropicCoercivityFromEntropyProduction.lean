import CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-!
# T-FF P27d — Entropy Production → EntropicActionCoercive

**Honest content**: a structure-builder that *derives* the abstract
`EntropicActionCoercive` certificate from the canonical entropy-production
imaginary action

  `S_I[Φ] = Σ[Φ]` (the thermodynamic entropy-production rate)

modulo an *Onsager positive-definiteness* hypothesis on the
thermodynamic-force kernel and a Poincaré-style spectral-gap hypothesis
on the UV subspace.  The derived coercivity constant is the explicit
physical scale

  `C = L_min · k_UV²`

where `L_min > 0` is a lower bound on the smallest eigenvalue of the
Onsager kinetic-coefficient matrix `L = (L_ij)`.

This is the fourth sub-task of the P27 umbrella (physics-to-structure
derivation of `EntropicActionCoercive` from CAT/EPT primitives) and the
*thermodynamic / second-law* incarnation of viscous-dissipation coercivity
(P27a).  Same Poincaré bound + multiplication by physical scale, but the
scale is now an Onsager-spectrum lower bound rather than a viscosity.

## Onsager structure (background)

For diffusive irreversible systems near equilibrium, the entropy-production
rate has the quadratic form

  `Σ[Φ] = X · L · X` (= `X_i · L_ij · X_j` summation convention),

where `X = (X_1, ..., X_n)` are *thermodynamic forces* (gradients of
intensive parameters: temperature, chemical potential, …) and `L = (L_ij)`
is the **Onsager matrix** — symmetric (Onsager reciprocal relations) and
positive-semidefinite (entropy production is non-negative).  For
*coercivity* we need `L` positive-DEFINITE with smallest eigenvalue
bounded below by some `L_min > 0`; this gives

  `Σ[Φ] = X^T L X ≥ L_min · ‖X‖²`.

Combined with `‖X‖² = forceNormSq Φ` and a Poincaré-style spectral-gap
(thermodynamic forces are spatial gradients of `Φ`; high-frequency modes
have force-norm bounded below in terms of UV-norm), we obtain the
coercivity bound `Σ[Φ] ≥ L_min · k_UV² · ‖Φ‖²_UV`.

## What is honestly proven

* `EntropyProductionData Φ` (structure): packages the four physical
  inputs — Onsager spectrum floor `L_min > 0`, UV spectral floor
  `k_UV² > 0`, entropy-production functional `entropyProd : Φ → ℝ`,
  thermodynamic-force-norm-squared functional `forceNormSq : Φ → ℝ`,
  UV-norm-squared `uvNormSq : Φ → ℝ` — plus two inequalities:
  the **Onsager bound** `L_min · forceNormSq φ ≤ entropyProd φ` and the
  **spectral-gap** `k_UV² · uvNormSq φ ≤ forceNormSq φ`.
* `forceNormSq_nonneg` (theorem): inherited from spectral gap +
  uvNormSq nonneg.
* `entropy_prod_nonneg` (theorem): the entropy-production rate is
  non-negative pointwise — recovers the second law of thermodynamics
  *and* the Phase-14 positivity hypothesis as a consequence of P27d.
* `entropy_prod_coercivity` (theorem, **HEADLINE**):
  `S_I[Φ] = Σ[Φ] ≥ L_min · k_UV² · ‖Φ‖²_UV`.
* `entropy_production_to_coercivity`: the structure-builder
  `EntropyProductionData Φ → EntropicActionCoercive` with
  `C := L_min · k_UV²`.
* `entropy_C_eq` (theorem): the produced certificate's constant is
  exactly `L_min · k_UV²` (definitional).
* `entropy_C_via_noether_decay` (theorem): when `L_min ≥ γ` for some
  CAT-decay-rate `γ > 0` — the natural scale supplied by the T100
  noether-EPT layer (`cat_decay_implies_invariant_constant`) — the
  derived coercivity constant is bounded below by `γ · k_UV²`.

## Honest scope

Both hypotheses (Onsager positive-definiteness `L_min > 0`, spectral
gap on UV subspace) are taken as structural inputs.  Onsager
positive-definiteness goes back to the kinetic-coefficient matrix
spectrum, which for ideal-gas-like systems can be derived from
microscopic detailed balance (the `qft.kms_condition` AssumptionId in
the registry would supply this).  For non-ideal systems
positive-definiteness is itself a regularity assumption.  The spectral
gap follows from `λ_k ≥ |k|²` for UV modes on `T³` (`pde.weyl_law`).
P27d's contribution is the implication
`(L_min, spectral-gap, Onsager-bound) ⟶ EntropicActionCoercive`.

## Connection to the T100 noether-EPT layer

The CAT/EPT exponential-decay law `E'(t) = -(γ/ℏ)·E(t)` from
`cat_decay_implies_invariant_constant` packages the dissipation rate
`γ > 0` as a *single number*.  In the entropy-production formulation
with quadratic Onsager structure, the smallest Onsager eigenvalue
`L_min` plays the same physical role: a uniform lower bound on the
dissipation strength.  The specialisation `L_min ≥ γ` therefore gives a
direct bridge to the existing T100 layer.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction

open CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-- **Physics-side input** for the entropy-production derivation:
Onsager spectrum floor `L_min > 0`, UV spectral floor `k_UV² > 0`,
entropy-production functional `entropyProd : Φ → ℝ`, force-norm-squared
`forceNormSq : Φ → ℝ`, UV-norm-squared `uvNormSq : Φ → ℝ`, plus two
inequalities:
  * **Onsager bound**: `L_min · forceNormSq φ ≤ entropyProd φ` (since
    the Onsager matrix is positive-definite with smallest eigenvalue
    `≥ L_min`);
  * **Poincaré-style spectral-gap**: `k_UV² · uvNormSq φ ≤ forceNormSq φ`
    on the UV subspace. -/
structure EntropyProductionData (Φ : Type) where
  /-- Lower bound on the smallest eigenvalue of the Onsager kinetic
      matrix.  Onsager positive-definiteness guarantees `L_min > 0` for
      ideal diffusive systems. -/
  L_min : ℝ
  L_min_pos : 0 < L_min
  /-- Lower bound on the squared frequency of UV modes
      (`k_UV² ≤ λ_k` for `k ∈ UV`). -/
  k_UV_sq : ℝ
  k_UV_sq_pos : 0 < k_UV_sq
  /-- The entropy-production rate functional `Σ[Φ]`. -/
  entropyProd : Φ → ℝ
  /-- Squared L² norm of the thermodynamic forces `‖X‖²`.  For diffusive
      systems the forces are spatial gradients, so `forceNormSq = ∫|∇Φ|²`
      and reduces to P27a's gradient norm-squared. -/
  forceNormSq : Φ → ℝ
  /-- Squared UV-norm seminorm `‖Φ‖²_UV`. -/
  uvNormSq : Φ → ℝ
  /-- Pointwise non-negativity of the UV-norm-squared. -/
  uvNormSq_nonneg : ∀ φ, 0 ≤ uvNormSq φ
  /-- **Onsager bound**: positive-definiteness of the Onsager matrix
      gives `L_min · ‖X‖² ≤ X^T L X = Σ[Φ]`. -/
  onsager_bound : ∀ φ, L_min * forceNormSq φ ≤ entropyProd φ
  /-- **Poincaré-style spectral-gap hypothesis** on the UV subspace. -/
  spectral_gap : ∀ φ, k_UV_sq * uvNormSq φ ≤ forceNormSq φ

namespace EntropyProductionData

variable {Φ : Type} (data : EntropyProductionData Φ)

/-- The thermodynamic-force-norm-squared inherits non-negativity from
the spectral gap + UV-norm-squared nonneg. -/
theorem forceNormSq_nonneg (φ : Φ) : 0 ≤ data.forceNormSq φ := by
  have h₁ : 0 ≤ data.k_UV_sq * data.uvNormSq φ :=
    mul_nonneg data.k_UV_sq_pos.le (data.uvNormSq_nonneg φ)
  exact h₁.trans (data.spectral_gap φ)

/-- The entropy-production rate is non-negative pointwise.  Encodes the
*second law of thermodynamics* AND recovers the Phase-14 positivity
hypothesis as a consequence of P27d. -/
theorem entropy_prod_nonneg (φ : Φ) : 0 ≤ data.entropyProd φ := by
  have h₁ : 0 ≤ data.L_min * data.forceNormSq φ :=
    mul_nonneg data.L_min_pos.le (data.forceNormSq_nonneg φ)
  exact h₁.trans (data.onsager_bound φ)

/-- **HEADLINE derivation**: the entropy-production rate satisfies the
coercivity bound `S_I[Φ] = Σ[Φ] ≥ C · ‖Φ‖²_UV` with the explicit
physical constant `C = L_min · k_UV²`.

Proof: chain the spectral gap and the Onsager bound by linear
arithmetic. -/
theorem entropy_prod_coercivity (φ : Φ) :
    data.L_min * data.k_UV_sq * data.uvNormSq φ ≤ data.entropyProd φ := by
  have h_gap : data.k_UV_sq * data.uvNormSq φ ≤ data.forceNormSq φ :=
    data.spectral_gap φ
  have h_L : 0 ≤ data.L_min := data.L_min_pos.le
  calc data.L_min * data.k_UV_sq * data.uvNormSq φ
      = data.L_min * (data.k_UV_sq * data.uvNormSq φ) := by ring
    _ ≤ data.L_min * data.forceNormSq φ := mul_le_mul_of_nonneg_left h_gap h_L
    _ ≤ data.entropyProd φ := data.onsager_bound φ

end EntropyProductionData

/-- **Structure-builder**: entropy-production physics produces an
`EntropicActionCoercive` certificate with the explicit constant
`C = L_min · k_UV² > 0`.  Fourth sub-task of the P27 umbrella. -/
def entropy_production_to_coercivity {Φ : Type}
    (data : EntropyProductionData Φ) : EntropicActionCoercive where
  C := data.L_min * data.k_UV_sq
  C_pos := mul_pos data.L_min_pos data.k_UV_sq_pos

/-- The produced certificate's constant is exactly `L_min · k_UV²`. -/
theorem entropy_C_eq {Φ : Type} (data : EntropyProductionData Φ) :
    (entropy_production_to_coercivity data).C = data.L_min * data.k_UV_sq :=
  rfl

/-- **T100 noether-decay specialisation**: when the Onsager spectrum
floor satisfies `L_min ≥ γ` for some CAT-decay-rate `γ > 0` (the natural
scale supplied by the noether-EPT layer
`cat_decay_implies_invariant_constant`), the derived coercivity constant
is bounded below by `γ · k_UV²`.

The CAT exponential-decay law `E'(t) = -(γ/ℏ)·E(t)` packages the
dissipation rate as a single number `γ`; in the Onsager quadratic-form
formulation `L_min` plays the same role.  The specialisation gives a
direct bridge between the T100 noether-EPT layer and the entropy-
production formulation. -/
theorem entropy_C_via_noether_decay {Φ : Type}
    (data : EntropyProductionData Φ) (γ : ℝ) (_hγ_pos : 0 < γ)
    (h_L : γ ≤ data.L_min) :
    γ * data.k_UV_sq ≤ (entropy_production_to_coercivity data).C := by
  rw [entropy_C_eq]
  exact mul_le_mul_of_nonneg_right h_L data.k_UV_sq_pos.le

end CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction
