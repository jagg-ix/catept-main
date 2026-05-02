import CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-!
# T-FF P27a — Viscous Dissipation → EntropicActionCoercive

**Honest content**: a structure-builder that *derives* the abstract
`EntropicActionCoercive` certificate from the canonical viscous-dissipation
imaginary action

  `S_I[Φ] = ν · ∫ |∇Φ|²`,

modulo a Poincaré-style spectral-gap hypothesis on the UV subspace
(`k_UV² · ‖Φ‖²_UV ≤ ∫ |∇Φ|²`).  The derived coercivity constant is the
explicit physical scale

  `C = ν · k_UV²`.

This is the first sub-task of the P27 umbrella (physics-to-structure
derivation of `EntropicActionCoercive` from CAT/EPT primitives).  Before
this commit, `EntropicActionCoercive` was an axiomatic carrier — consumers
that supplied it got the UV certificate downstream, but the carrier itself
was not derived from a primitive Lagrangian.  P27a closes that gap for the
viscous-dissipation source.

## What is honestly proven

* `ViscousDissipationData Φ` (structure): packages the four physical
  inputs — viscosity `ν > 0`, spectral floor `k_UV² > 0`, gradient
  norm-squared `gradNormSq : Φ → ℝ`, UV norm-squared `uvNormSq : Φ → ℝ` —
  plus the Poincaré-style spectral-gap hypothesis
  `k_UV² · uvNormSq φ ≤ gradNormSq φ` and `0 ≤ uvNormSq φ`.
* `viscousActionIm`: the imaginary action `ν · gradNormSq φ`.
* `viscous_action_coercivity` (theorem): `viscousActionIm data φ ≥
  ν · k_UV² · uvNormSq φ` for every `φ`.  Pure linear arithmetic from the
  spectral-gap hypothesis.
* `viscous_action_im_nonneg` (theorem): the imaginary action is
  point-wise non-negative — recovers the Phase-14 positivity hypothesis
  as a *consequence* of P27a (rather than a separate carrier).
* `viscous_dissipation_to_coercivity`: the structure-builder
  `ViscousDissipationData Φ → EntropicActionCoercive` with
  `C := ν · k_UV²` and `C_pos := mul_pos ν_pos k_UV_sq_pos`.
* `viscous_dissipation_C_eq` (theorem): the produced certificate's
  constant is exactly `ν · k_UV²` (definitional).

## Honest scope

The Poincaré-style spectral-gap inequality on the UV subspace
(`k_UV² · ‖Φ‖²_UV ≤ ∫ |∇Φ|²`) is taken as a structural hypothesis.  On
the 3-torus it follows from the Stokes/Laplacian eigenvalue lower bound
`λ_k ≥ |k|²` for `k ∈ UV`; deriving that bound from primitive geometry is
its own task (the `pde.weyl_law` AssumptionId in the registry).  P27a's
contribution is the derivation `(ν, spectral-gap) ⟶ EntropicActionCoercive`
— the rest of the chain is delegated to P28 (analysis-side tail) and to
the existing `physical_uv_convergence_certificate` capstone.

## Connection to the Constantin–Iyer identification ℏ = 2ν

When `ν = ℏ/2` (Constantin–Iyer / Route 6), the derived coercivity constant
becomes `C = (ℏ/2) · k_UV²`, i.e. `C ∝ ℏ`.  The UV suppression strength is
proportional to Planck's constant — the entropic-time scale at which
quantum corrections take over.  Recorded here as `viscous_C_via_constantin_iyer`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation

open CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-- **Physics-side input** for the viscous-dissipation derivation:
viscosity `ν > 0`, UV-mode spectral floor `k_UV² > 0`, the gradient
norm-squared functional `gradNormSq` and the UV norm-squared functional
`uvNormSq`, plus the Poincaré-style spectral-gap hypothesis
`k_UV² · uvNormSq φ ≤ gradNormSq φ`.

On the 3-torus the spectral-gap hypothesis follows from the
Stokes/Laplacian eigenvalue lower bound `λ_k ≥ |k|²` for UV modes; here
we take it as a structural hypothesis from physics. -/
structure ViscousDissipationData (Φ : Type) where
  /-- Kinematic viscosity. -/
  ν : ℝ
  ν_pos : 0 < ν
  /-- Lower bound on the squared frequency of UV modes
      (`k_UV² ≤ λ_k` for `k ∈ UV`). -/
  k_UV_sq : ℝ
  k_UV_sq_pos : 0 < k_UV_sq
  /-- The squared L² gradient norm `∫ |∇Φ|²`. -/
  gradNormSq : Φ → ℝ
  /-- The squared UV-norm seminorm `‖Φ‖²_UV` (a high-mode restriction). -/
  uvNormSq : Φ → ℝ
  /-- Pointwise non-negativity of the UV-norm-squared. -/
  uvNormSq_nonneg : ∀ φ, 0 ≤ uvNormSq φ
  /-- **Poincaré-style spectral-gap hypothesis** on the UV subspace:
      `k_UV² · uvNormSq φ ≤ gradNormSq φ` for every field configuration. -/
  spectral_gap : ∀ φ, k_UV_sq * uvNormSq φ ≤ gradNormSq φ

namespace ViscousDissipationData

variable {Φ : Type} (data : ViscousDissipationData Φ)

/-- The viscous-dissipation imaginary action `S_I[Φ] = ν · ∫ |∇Φ|²`. -/
def viscousActionIm (φ : Φ) : ℝ := data.ν * data.gradNormSq φ

/-- The gradient norm-squared inherits non-negativity from the
spectral-gap hypothesis applied at the level of the UV norm.  Formally:
`0 ≤ k_UV² · 0 ≤ k_UV² · uvNormSq φ ≤ gradNormSq φ` once we know `0 ≤
uvNormSq φ`.  The cleaner statement (positivity of the UV norm forces
positivity of the gradient norm) is recorded so downstream consumers
have it for free. -/
theorem gradNormSq_nonneg (φ : Φ) : 0 ≤ data.gradNormSq φ := by
  have h₁ : 0 ≤ data.k_UV_sq * data.uvNormSq φ :=
    mul_nonneg data.k_UV_sq_pos.le (data.uvNormSq_nonneg φ)
  exact h₁.trans (data.spectral_gap φ)

/-- **HEADLINE derivation**: the viscous-dissipation imaginary action
satisfies the coercivity bound `S_I[Φ] ≥ C · ‖Φ‖²_UV` with the explicit
physical constant `C = ν · k_UV²`. -/
theorem viscous_action_coercivity (φ : Φ) :
    data.ν * data.k_UV_sq * data.uvNormSq φ ≤ data.viscousActionIm φ := by
  unfold viscousActionIm
  have h_gap : data.k_UV_sq * data.uvNormSq φ ≤ data.gradNormSq φ :=
    data.spectral_gap φ
  have h_ν : 0 ≤ data.ν := data.ν_pos.le
  calc data.ν * data.k_UV_sq * data.uvNormSq φ
      = data.ν * (data.k_UV_sq * data.uvNormSq φ) := by ring
    _ ≤ data.ν * data.gradNormSq φ := mul_le_mul_of_nonneg_left h_gap h_ν

/-- The viscous-dissipation imaginary action is non-negative.  Recovers
the Phase-14 positivity hypothesis as a *consequence* of P27a, rather than
as a separate carrier. -/
theorem viscous_action_im_nonneg (φ : Φ) : 0 ≤ data.viscousActionIm φ := by
  unfold viscousActionIm
  exact mul_nonneg data.ν_pos.le (data.gradNormSq_nonneg φ)

end ViscousDissipationData

/-- **Structure-builder**: viscous-dissipation physics produces an
`EntropicActionCoercive` certificate with the explicit constant
`C = ν · k_UV² > 0`.  This retires the axiomatic-carrier status of
`EntropicActionCoercive` for the viscous-dissipation source — first
sub-task of the P27 umbrella. -/
def viscous_dissipation_to_coercivity {Φ : Type}
    (data : ViscousDissipationData Φ) : EntropicActionCoercive where
  C := data.ν * data.k_UV_sq
  C_pos := mul_pos data.ν_pos data.k_UV_sq_pos

/-- The produced certificate's constant is exactly `ν · k_UV²`. -/
theorem viscous_dissipation_C_eq {Φ : Type}
    (data : ViscousDissipationData Φ) :
    (viscous_dissipation_to_coercivity data).C = data.ν * data.k_UV_sq :=
  rfl

/-- **Constantin–Iyer specialisation**: when `ν = ℏ/2` (the Route-6 NS
identification), the derived coercivity constant becomes `(ℏ/2) · k_UV²`.
The UV suppression strength is proportional to Planck's constant. -/
theorem viscous_C_via_constantin_iyer {Φ : Type}
    (data : ViscousDissipationData Φ) (hbar : ℝ) (h_eq : data.ν = hbar / 2) :
    (viscous_dissipation_to_coercivity data).C = hbar / 2 * data.k_UV_sq := by
  rw [viscous_dissipation_C_eq, h_eq]

end CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation
