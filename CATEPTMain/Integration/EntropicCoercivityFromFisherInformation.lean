import CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-!
# T-FF P27c — Fisher Information → EntropicActionCoercive

**Honest content**: a structure-builder that *derives* the abstract
`EntropicActionCoercive` certificate from the canonical Fisher-information
imaginary action

  `S_I[Φ] = I(p) = ∫ |∇log p|² · p`,

modulo a positive-density lower bound (`p(x) ≥ p_min > 0`) and a
Poincaré-style spectral-gap hypothesis on the UV subspace
(`k_UV² · ‖Φ‖²_UV ≤ ∫ |∇Φ|²` where `Φ = log p`).  The derived coercivity
constant is the explicit physical scale

  `C = p_min · k_UV²`.

This is the third sub-task of the P27 umbrella (physics-to-structure
derivation of `EntropicActionCoercive` from CAT/EPT primitives) and the
*quantum-information / log-density* incarnation of viscous-dissipation
coercivity (P27a) — same Poincaré bound applied in log-density
coordinates `Φ = log p`, with the density floor `p_min` playing the role
that viscosity `ν` played in P27a.

## What is honestly proven

* `FisherInformationData Φ` (structure): packages the seven physical
  inputs — density floor `p_min > 0`, spectral floor `k_UV² > 0`,
  Fisher functional `fisherInfo : Φ → ℝ`, gradient norm-squared
  `gradNormSq`, UV norm-squared `uvNormSq` — plus the density bound
  `p_min · gradNormSq φ ≤ fisherInfo φ` and the Poincaré-style spectral
  gap `k_UV² · uvNormSq φ ≤ gradNormSq φ`.
* `gradNormSq_nonneg` (theorem): inherited from spectral gap +
  uvNormSq nonneg (same as P27a).
* `fisher_info_nonneg` (theorem): the Fisher functional is non-negative
  pointwise, derived from the density bound + gradient nonneg.
* `fisher_info_coercivity` (theorem, **HEADLINE**):
  `C · ‖Φ‖²_UV ≤ I(p)` with the explicit constant `C = p_min · k_UV²`.
* `fisher_information_to_coercivity`: structure-builder
  `FisherInformationData Φ → EntropicActionCoercive` with
  `C := p_min · k_UV²` and `C_pos := mul_pos p_min_pos k_UV_sq_pos`.
* `fisher_C_eq` (theorem): produced certificate's constant is exactly
  `p_min · k_UV²` (definitional).
* `fisher_C_via_log_sobolev` (theorem): when `p_min ≥ exp(-Λ)` for some
  log-density-bound `Λ ≥ 0` (Gross / log-Sobolev regime), the derived
  coercivity constant is bounded below by `exp(-Λ) · k_UV²`.

## Honest scope

Both hypotheses (density lower bound `p_min > 0`, spectral gap on UV
subspace) are taken as structural inputs.  The density bound is
ineliminable for unbounded log-densities (the integrand `exp(Φ)` is not
uniformly bounded below over an arbitrary state space); on a bounded
domain it follows from regularity.  The spectral gap on the UV subspace
follows from `λ_k ≥ |k|²` for UV modes on `T³` (the `pde.weyl_law`
AssumptionId in the registry).  P27c's contribution is the implication
`(p_min, spectral-gap, density-bound) ⟶ EntropicActionCoercive`.

## Connection to the QM ⟷ NS lane

P27c is the *quantum-information / log-density* incarnation of P27a's
viscous coercivity.  In the QM lane Fisher information is the natural
"action density" — it bridges the QM observable `vonNeumannEntropy` via
the de Bruijn identity and the heat-equation chain
(`d/dt H(p_t) = -I(p_t)/2`).  In the NS lane it appears via the
log-density formulation of the Madelung representation.  This module
exposes both readings via the *same* `EntropicActionCoercive`
certificate, with the density floor `p_min` carrying the regularity
content that distinguishes the two physics interpretations.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicCoercivityFromFisherInformation

open CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-- **Physics-side input** for the Fisher-information derivation:
density lower bound `p_min > 0`, UV-mode spectral floor `k_UV² > 0`, the
Fisher functional `fisherInfo` (the imaginary action `I(p) = ∫ |∇log p|²·p`
in log-density coordinates), the gradient norm-squared functional
`gradNormSq`, the UV norm-squared functional `uvNormSq`, plus two
inequalities:
  * **density bound**: `p_min · gradNormSq φ ≤ fisherInfo φ` (because
    `p ≥ p_min` pointwise);
  * **Poincaré-style spectral-gap**: `k_UV² · uvNormSq φ ≤ gradNormSq φ`
    on the UV subspace.

On a bounded domain with regular density these follow from physics; here
both are taken as structural hypotheses. -/
structure FisherInformationData (Φ : Type) where
  /-- Lower bound on the probability density `p ≥ p_min`. -/
  p_min : ℝ
  p_min_pos : 0 < p_min
  /-- Lower bound on the squared frequency of UV modes
      (`k_UV² ≤ λ_k` for `k ∈ UV`). -/
  k_UV_sq : ℝ
  k_UV_sq_pos : 0 < k_UV_sq
  /-- The Fisher functional `I(p) = ∫ |∇log p|²·p`, evaluated as a
      function of the log-density `Φ = log p`. -/
  fisherInfo : Φ → ℝ
  /-- The squared L² gradient norm `∫ |∇Φ|² = ∫ |∇log p|²`. -/
  gradNormSq : Φ → ℝ
  /-- The squared UV-norm seminorm `‖Φ‖²_UV` (a high-mode restriction). -/
  uvNormSq : Φ → ℝ
  /-- Pointwise non-negativity of the UV-norm-squared. -/
  uvNormSq_nonneg : ∀ φ, 0 ≤ uvNormSq φ
  /-- **Density bound**: `p ≥ p_min` pointwise lifts to
      `p_min · ∫|∇Φ|² ≤ ∫|∇Φ|²·p = I(p)`. -/
  density_bound : ∀ φ, p_min * gradNormSq φ ≤ fisherInfo φ
  /-- **Poincaré-style spectral-gap hypothesis** on the UV subspace. -/
  spectral_gap : ∀ φ, k_UV_sq * uvNormSq φ ≤ gradNormSq φ

namespace FisherInformationData

variable {Φ : Type} (data : FisherInformationData Φ)

/-- The gradient norm-squared inherits non-negativity from the spectral
gap + UV-norm-squared nonneg (parallel to P27a `gradNormSq_nonneg`). -/
theorem gradNormSq_nonneg (φ : Φ) : 0 ≤ data.gradNormSq φ := by
  have h₁ : 0 ≤ data.k_UV_sq * data.uvNormSq φ :=
    mul_nonneg data.k_UV_sq_pos.le (data.uvNormSq_nonneg φ)
  exact h₁.trans (data.spectral_gap φ)

/-- The Fisher functional is pointwise non-negative.  Recovers the
Phase-14 positivity hypothesis as a *consequence* of the density
bound + gradient nonneg, rather than as a separate carrier. -/
theorem fisher_info_nonneg (φ : Φ) : 0 ≤ data.fisherInfo φ := by
  have h₁ : 0 ≤ data.p_min * data.gradNormSq φ :=
    mul_nonneg data.p_min_pos.le (data.gradNormSq_nonneg φ)
  exact h₁.trans (data.density_bound φ)

/-- **HEADLINE derivation**: the Fisher-information imaginary action
satisfies the coercivity bound `S_I[Φ] ≥ C · ‖Φ‖²_UV` with the explicit
physical constant `C = p_min · k_UV²`.

Proof: chain the spectral gap and the density bound by linear arithmetic.
  `p_min · k_UV² · uvNormSq φ
   ≤ p_min · gradNormSq φ`        (multiply spectral_gap by p_min ≥ 0)
   `≤ fisherInfo φ`                (density bound). -/
theorem fisher_info_coercivity (φ : Φ) :
    data.p_min * data.k_UV_sq * data.uvNormSq φ ≤ data.fisherInfo φ := by
  have h_gap : data.k_UV_sq * data.uvNormSq φ ≤ data.gradNormSq φ :=
    data.spectral_gap φ
  have h_p : 0 ≤ data.p_min := data.p_min_pos.le
  calc data.p_min * data.k_UV_sq * data.uvNormSq φ
      = data.p_min * (data.k_UV_sq * data.uvNormSq φ) := by ring
    _ ≤ data.p_min * data.gradNormSq φ := mul_le_mul_of_nonneg_left h_gap h_p
    _ ≤ data.fisherInfo φ := data.density_bound φ

end FisherInformationData

/-- **Structure-builder**: Fisher-information physics produces an
`EntropicActionCoercive` certificate with the explicit constant
`C = p_min · k_UV² > 0`.  Third sub-task of the P27 umbrella. -/
def fisher_information_to_coercivity {Φ : Type}
    (data : FisherInformationData Φ) : EntropicActionCoercive where
  C := data.p_min * data.k_UV_sq
  C_pos := mul_pos data.p_min_pos data.k_UV_sq_pos

/-- The produced certificate's constant is exactly `p_min · k_UV²`. -/
theorem fisher_C_eq {Φ : Type} (data : FisherInformationData Φ) :
    (fisher_information_to_coercivity data).C = data.p_min * data.k_UV_sq :=
  rfl

/-- **Log-Sobolev / Gross specialisation**: when the density floor
satisfies `p_min ≥ exp(-Λ)` for some log-density-bound `Λ ≥ 0`, the
derived coercivity constant is bounded below by `exp(-Λ) · k_UV²`.
Connects to the Gross-LSI infrastructure in
`catept-plugin-gaussian-field-lsi`. -/
theorem fisher_C_via_log_sobolev {Φ : Type}
    (data : FisherInformationData Φ) (Λ : ℝ) (_hΛ : 0 ≤ Λ)
    (hp : Real.exp (-Λ) ≤ data.p_min) :
    Real.exp (-Λ) * data.k_UV_sq ≤ (fisher_information_to_coercivity data).C := by
  rw [fisher_C_eq]
  exact mul_le_mul_of_nonneg_right hp data.k_UV_sq_pos.le

end CATEPTMain.Integration.EntropicCoercivityFromFisherInformation
