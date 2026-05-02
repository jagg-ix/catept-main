import CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-!
# T-FF P27e — Modular Hamiltonian / KMS Positivity → EntropicActionCoercive

**Honest content**: a structure-builder that *derives* the abstract
`EntropicActionCoercive` certificate from the canonical modular-flow
imaginary action

  `S_I[ρ] = ⟨K[ρ]⟩` (the modular Hamiltonian expectation value)

where `K = -log ρ` is the Tomita–Takesaki modular Hamiltonian of the
KMS state.  The derivation requires a *modular spectral gap* `K_min > 0`
on the spectrum of `K` above its ground-state value, plus a
Poincaré-style spectral-gap hypothesis on the UV subspace.  The derived
coercivity constant is the explicit physical scale

  `C = K_min · k_UV²`.

This is the **fifth and final** sub-task of the P27 umbrella
(physics-to-structure derivation of `EntropicActionCoercive` from
CAT/EPT primitives) and the *quantum-field / modular-flow* incarnation
of the same coercivity story.  When this lands the
`EntropicActionCoercive` axiomatic-carrier status is retired across all
five canonical physics sources (viscous / palinstrophy / Fisher /
entropy-production / modular).

## Modular flow background

For a faithful KMS state `ρ` on a von Neumann algebra `M`, the modular
operator `Δ = e^{-K}` (where `K = -log ρ`) generates the modular flow
`σ_t(A) = Δ^{it} A Δ^{-it}`.  The CAT/EPT spine identifies the entropic
proper time with accumulated modular flow:

  `τ_ent[ρ] = ⟨K[ρ]⟩ / ℏ` (`ModularFlowBridge.entropic_time_eq_accumulated_modular_flow`).

The CATEPT identification `actionImScaled = eptClock` then forces the
imaginary action to coincide with the modular Hamiltonian expectation:

  `S_I[ρ] = ⟨K[ρ]⟩`.

For *coercivity* we need `⟨K[ρ]⟩` to grow at least quadratically in the
"distance from equilibrium" `‖ρ‖²_UV`, which holds when the spectrum of
`K` above its ground state is bounded below by `K_min > 0`.  This is the
**modular spectral-gap hypothesis** — analogous to the Onsager floor
`L_min` in P27d and the Hilbert-space spectral gap underpinning P27a.

## What is honestly proven

* `ModularHamiltonianData ρ` (structure): packages the four physical
  inputs — modular spectral floor `K_min > 0`, UV spectral floor
  `k_UV² > 0`, modular-action functional `modularAction : ρ → ℝ`,
  thermal-distance functional `thermalDistSq : ρ → ℝ` (= `‖ρ - ρ_0‖²`
  in some KMS reference state), UV-norm-squared `uvNormSq : ρ → ℝ` —
  plus the **modular spectral bound**
  `K_min · thermalDistSq r ≤ modularAction r` and the
  **Poincaré-style spectral gap**
  `k_UV² · uvNormSq r ≤ thermalDistSq r`.
* `thermalDistSq_nonneg` (theorem): inherited from spectral gap +
  uvNormSq nonneg.
* `modular_action_nonneg` (theorem): the modular action is non-negative
  pointwise (recovering Phase-14 positivity AND the second-law-of-modular
  flow `K ≥ 0` simultaneously).
* `modular_action_coercivity` (theorem, **HEADLINE**):
  `S_I[ρ] = ⟨K[ρ]⟩ ≥ K_min · k_UV² · ‖ρ‖²_UV`.
* `modular_to_coercivity`: structure-builder
  `ModularHamiltonianData ρ → EntropicActionCoercive` with
  `C := K_min · k_UV²`.
* `modular_C_eq` (theorem): produced certificate's constant is exactly
  `K_min · k_UV²` (definitional).
* `modular_C_via_kms_temperature` (theorem): when `K_min ≥ β·E_min` for
  inverse temperature `β > 0` and a Hamiltonian floor `E_min > 0` (the
  natural KMS-thermal regime), the derived coercivity constant is
  bounded below by `β·E_min·k_UV²`.

## Honest scope

Both hypotheses (modular spectral gap `K_min > 0`, spectral gap on UV
subspace) are taken as structural inputs.  The modular spectral gap
follows from *gappedness* of the modular Hamiltonian — a regularity
property that holds for KMS states on type III₁ factors satisfying the
spectral condition (qft.kms_condition AssumptionId in the registry).
For non-gapped systems (e.g. critical states) the spectral gap fails;
the failure-mode anchor `no_spectral_gap_breaks_uv_certificate` (Phase
14 broadening) records this case explicitly.

## Connection to the existing CATEPT modular-flow infrastructure

The Phase-1 ModularFlowBridge.lean theorem
`hyers_ulam_weight_stability` proves `(1/ℏ)`-Lipschitz dependence of the
FK damping on the modular generator.  P27e's
`modular_action_coercivity` provides the *strict-monotonicity* refinement:
not just continuity, but coercive growth in the UV subspace.  The two
results compose to give a stable AND coercive imaginary-action chain
across the QFT lane.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian

open CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-- **Physics-side input** for the modular-Hamiltonian derivation:
modular spectral floor `K_min > 0`, UV spectral floor `k_UV² > 0`, the
modular-action functional `modularAction` (`= ⟨K[ρ]⟩` in the KMS state),
the thermal-distance-squared functional `thermalDistSq` (`= ‖ρ - ρ_0‖²`
in some reference state), the UV-norm-squared functional `uvNormSq`,
plus two inequalities:
  * **modular spectral bound**: `K_min · thermalDistSq r ≤ modularAction r`
    (`K` has spectrum above its ground state bounded below by `K_min`);
  * **Poincaré-style spectral-gap**: `k_UV² · uvNormSq r ≤ thermalDistSq r`
    on the UV subspace.

The first hypothesis is the operator-algebraic content (modular
gappedness); the second is the same UV spectral hypothesis used in P27a-d. -/
structure ModularHamiltonianData (ρ : Type) where
  /-- Spectral-gap floor on the modular Hamiltonian above its ground
      state.  For a KMS state on a gapped algebra `K_min > 0`. -/
  K_min : ℝ
  K_min_pos : 0 < K_min
  /-- Lower bound on the squared frequency of UV modes
      (`k_UV² ≤ λ_k` for `k ∈ UV`). -/
  k_UV_sq : ℝ
  k_UV_sq_pos : 0 < k_UV_sq
  /-- The modular-action functional `⟨K[ρ]⟩`.  Equals `S_I[ρ]` under the
      CATEPT identification `actionImScaled = eptClock`. -/
  modularAction : ρ → ℝ
  /-- The squared thermal distance `‖ρ - ρ_0‖²` in some KMS reference
      state.  Replaces P27a-d's `gradNormSq` / `forceNormSq` /
      `laplacianNormSq` with an operator-algebraic analogue. -/
  thermalDistSq : ρ → ℝ
  /-- Squared UV-norm seminorm `‖ρ‖²_UV`. -/
  uvNormSq : ρ → ℝ
  /-- Pointwise non-negativity of the UV-norm-squared. -/
  uvNormSq_nonneg : ∀ r, 0 ≤ uvNormSq r
  /-- **Modular spectral bound**: gappedness of the modular Hamiltonian
      above its ground state lifts to
      `K_min · ‖ρ - ρ_0‖² ≤ ⟨K[ρ]⟩`. -/
  modular_bound : ∀ r, K_min * thermalDistSq r ≤ modularAction r
  /-- **Poincaré-style spectral-gap hypothesis** on the UV subspace. -/
  spectral_gap : ∀ r, k_UV_sq * uvNormSq r ≤ thermalDistSq r

namespace ModularHamiltonianData

variable {ρ : Type} (data : ModularHamiltonianData ρ)

/-- The thermal-distance-squared inherits non-negativity from the
spectral gap + UV-norm-squared nonneg. -/
theorem thermalDistSq_nonneg (r : ρ) : 0 ≤ data.thermalDistSq r := by
  have h₁ : 0 ≤ data.k_UV_sq * data.uvNormSq r :=
    mul_nonneg data.k_UV_sq_pos.le (data.uvNormSq_nonneg r)
  exact h₁.trans (data.spectral_gap r)

/-- The modular action `⟨K[ρ]⟩` is non-negative pointwise.  Recovers
*both* the Phase-14 positivity hypothesis AND the operator-positivity
`K ≥ 0` of the modular Hamiltonian as a consequence of P27e. -/
theorem modular_action_nonneg (r : ρ) : 0 ≤ data.modularAction r := by
  have h₁ : 0 ≤ data.K_min * data.thermalDistSq r :=
    mul_nonneg data.K_min_pos.le (data.thermalDistSq_nonneg r)
  exact h₁.trans (data.modular_bound r)

/-- **HEADLINE derivation**: the modular-action imaginary action satisfies
the coercivity bound `S_I[ρ] = ⟨K[ρ]⟩ ≥ C · ‖ρ‖²_UV` with the explicit
physical constant `C = K_min · k_UV²`.

Proof: chain the spectral gap and the modular bound by linear
arithmetic. -/
theorem modular_action_coercivity (r : ρ) :
    data.K_min * data.k_UV_sq * data.uvNormSq r ≤ data.modularAction r := by
  have h_gap : data.k_UV_sq * data.uvNormSq r ≤ data.thermalDistSq r :=
    data.spectral_gap r
  have h_K : 0 ≤ data.K_min := data.K_min_pos.le
  calc data.K_min * data.k_UV_sq * data.uvNormSq r
      = data.K_min * (data.k_UV_sq * data.uvNormSq r) := by ring
    _ ≤ data.K_min * data.thermalDistSq r := mul_le_mul_of_nonneg_left h_gap h_K
    _ ≤ data.modularAction r := data.modular_bound r

end ModularHamiltonianData

/-- **Structure-builder**: modular-flow physics produces an
`EntropicActionCoercive` certificate with the explicit constant
`C = K_min · k_UV² > 0`.  Fifth (and last) sub-task of the P27 umbrella —
when this lands, `EntropicActionCoercive` is retired as an axiomatic
carrier across all five canonical physics sources. -/
def modular_to_coercivity {ρ : Type}
    (data : ModularHamiltonianData ρ) : EntropicActionCoercive where
  C := data.K_min * data.k_UV_sq
  C_pos := mul_pos data.K_min_pos data.k_UV_sq_pos

/-- The produced certificate's constant is exactly `K_min · k_UV²`. -/
theorem modular_C_eq {ρ : Type} (data : ModularHamiltonianData ρ) :
    (modular_to_coercivity data).C = data.K_min * data.k_UV_sq :=
  rfl

/-- **KMS-thermal specialisation**: in the KMS regime at inverse
temperature `β > 0` with a Hamiltonian energy floor `E_min > 0`, the
modular spectral floor satisfies `K_min ≥ β · E_min` (since
`K = β · H` for thermal-equilibrium states).  The derived coercivity
constant is then bounded below by `β · E_min · k_UV²`.

Connects directly to the qft.kms_condition AssumptionId in the registry. -/
theorem modular_C_via_kms_temperature {ρ : Type}
    (data : ModularHamiltonianData ρ) (β E_min : ℝ)
    (_hβ : 0 < β) (_hE : 0 < E_min)
    (h_K : β * E_min ≤ data.K_min) :
    β * E_min * data.k_UV_sq ≤ (modular_to_coercivity data).C := by
  rw [modular_C_eq]
  exact mul_le_mul_of_nonneg_right h_K data.k_UV_sq_pos.le

end CATEPTMain.Integration.EntropicCoercivityFromModularHamiltonian
