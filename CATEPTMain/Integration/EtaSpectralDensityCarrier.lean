import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# EtaSpectralDensityCarrier — QuAPI / Blip / Spectral-Density Carriers

This file is a **contract landing pad** consolidating the Tier-1 content of
QuantumDynamics.jl's path-integral subsystem (Makri-style influence-functional
methods) into the CAT/EPT spine.  Specifically:

* `EtaCoefficients.jl` — η coefficients factored as `Re η + i Im η`.
* `QuAPI.jl` — quasi-adiabatic propagator path-integral weights.
* `Blip.jl` — blip-decomposition damping bound.
* `Environment/SpectralDensities.jl` — bath kernel `J(ω)` parameter family.
* `pathintegral.jl` — top-level path-integral abstraction.

## Bridge to existing CAT/EPT structure

The Makri η-coefficient is the **discretized version of the CAT/EPT complex
action** `S = S_R + i S_I` (per slice), with the well-known factorization

  weight(Δs, sbar) = exp[−Δs (Re η · Δs + 2i · Im η · sbar)]
                   = exp(−Δs² · Re η)            -- damping (CAT/EPT S_I/ℏ)
                   × exp(−2i · Δs · sbar · Im η)  -- oscillation (CAT/EPT S_R/ℏ).

The damping magnitude `|weight| = exp(−Δs² · Re η)` discretises catept-core's
`eq054_damping_magnitude` and the **blip-suppression** bound discretises
`eq057_coercivity_implies_convergence`.

Spectral-density positivity `J(ω) ≥ 0` is the *physical origin* of
`Re η ≥ 0`, which in turn is the discrete coercivity hypothesis.

## Honest scope

* This is **not** a derivation of the QuAPI integral relation
  `η = (1/2π) ∫ J(ω) g(ω, β, dt) dω` — that integral is left as an
  abstract `origin_witness` field of the spectral-density-to-η carrier.
* It is a structural carrier exposing the **damping-magnitude bound**,
  **blip suppression**, and the **complex-action identification** as
  `Prop`-level / kernel-only deliverables.
* Pattern matches `WDWRQMUncertaintyContracts`, `NonHermitianQuantumCAT`,
  `CATEPTMeasureTheorem`, and other recently-shipped CAT/EPT carriers.

## What this module ships

* `SpectralDensity` — `J : ℝ → ℝ` with `J ≥ 0` (carrier for Ohmic /
  Drude-Lorentz / discrete-oscillator instances).
* `EtaKernel` — discretised `(Re η, Im η)` with `Re η ≥ 0`.
* `InfluenceFunctionalWeight` — single time-slice `(η, Δs, sbar)`.
* `dampingMagnitude` — `|weight| = exp(−Δs² · Re η)`.
* `dampingMagnitude_le_one` — universal damping bound.
* `dampingMagnitude_monotone_in_Δs_sq` — discrete coercivity:
  larger `Δs²` ⟹ stronger damping.
* `IdentifyEtaWithComplexAction` — bridge connecting `(Re η, Im η)`
  to CAT/EPT's `(S_I, S_R)` per slice.
* `EtaFromSpectralDensity` — bridge connecting `(J, β, dt)` to `η`,
  with the integral relation as an abstract `origin_witness`.
* `eta_spectral_density_carrier_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EtaSpectralDensityCarrier

-- ============================================================================
-- 1. Spectral density carrier (bath kernel J(ω) ≥ 0)
-- ============================================================================

/-- **Spectral density.**

The bath kernel `J : ℝ → ℝ` that determines the influence-functional
coefficients.  Non-negativity `J ≥ 0` is the physical-positivity
constraint (no negative coupling at any frequency); it propagates to
the discrete coercivity `Re η ≥ 0`.

Concrete instances (Ohmic, Drude-Lorentz, discrete oscillators) are
left as consumer-supplied refinements; this carrier exposes only the
generic positivity guarantee. -/
structure SpectralDensity where
  /-- The spectral-density function `J(ω)`. -/
  J             : ℝ → ℝ
  /-- Physical positivity. -/
  J_nonneg      : ∀ ω, 0 ≤ J ω

namespace SpectralDensity

/-- Trivial existence: zero spectral density. -/
theorem exists_trivial : ∃ _ : SpectralDensity, True :=
  ⟨{ J := fun _ => 0, J_nonneg := fun _ => le_refl 0 }, trivial⟩

end SpectralDensity

-- ============================================================================
-- 2. Discretised η-coefficient (per slice)
-- ============================================================================

/-- **Eta-coefficient kernel.**

The discretised influence-functional kernel at one temporal lag, packaged
as a real / imaginary pair:

* `reEta : ℝ` — dissipative (damping) part, **non-negative** (the
  discrete coercivity hypothesis).
* `imEta : ℝ` — conservative (oscillatory) part, sign-unconstrained.

Maps to `EtaCoefficients.EtaCoeffs.{η00, ηmm, η0m, ηmn, η0e}` in
QuantumDynamics.jl; we expose only one slice. -/
structure EtaKernel where
  /-- Real part — dissipative kernel. -/
  reEta         : ℝ
  /-- Imaginary part — oscillatory kernel. -/
  imEta         : ℝ
  /-- Discrete coercivity: `Re η ≥ 0`. -/
  reEta_nonneg  : 0 ≤ reEta

namespace EtaKernel

/-- Trivial existence: zero kernel. -/
theorem exists_trivial : ∃ _ : EtaKernel, True :=
  ⟨{ reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }, trivial⟩

end EtaKernel

-- ============================================================================
-- 3. Single-slice influence-functional weight
-- ============================================================================

/-- **Influence-functional weight at a single forward-backward slice.**

Carries `(η, Δs, sbar)` where:

* `Δs : ℝ` is the forward-minus-backward state difference (the
  "blip" coordinate when nonzero, "sojourn" when zero),
* `sbar : ℝ` is the forward-plus-backward midpoint,
* `η : EtaKernel` provides the discretised `Re η`/`Im η`.

The complex weight (in the original formalism) is

  exp[−Δs (Re η · Δs + 2i · Im η · sbar)],

with magnitude `|weight| = exp(−Δs² · Re η)`. -/
structure InfluenceFunctionalWeight where
  /-- The η-coefficient kernel. -/
  η             : EtaKernel
  /-- Forward-minus-backward state difference. -/
  Δs            : ℝ
  /-- Forward-plus-backward midpoint. -/
  sbar          : ℝ

namespace InfluenceFunctionalWeight

variable (w : InfluenceFunctionalWeight)

/-- **Damping magnitude** `|weight| = exp(−Δs² · Re η)`. -/
def dampingMagnitude : ℝ := Real.exp (-(w.Δs ^ 2 * w.η.reEta))

/-- The damping magnitude is strictly positive. -/
theorem dampingMagnitude_pos : 0 < w.dampingMagnitude :=
  Real.exp_pos _

/-- **Universal damping bound:** `|weight| ≤ 1`.

Discrete analogue of catept-core's `eq054_damping_magnitude`.  Follows
from `Δs² ≥ 0` and `Re η ≥ 0`. -/
theorem dampingMagnitude_le_one : w.dampingMagnitude ≤ 1 := by
  unfold dampingMagnitude
  apply Real.exp_le_one_iff.mpr
  have h_sq : 0 ≤ w.Δs ^ 2 := sq_nonneg _
  have h_re : 0 ≤ w.η.reEta := w.η.reEta_nonneg
  have h_prod : 0 ≤ w.Δs ^ 2 * w.η.reEta := mul_nonneg h_sq h_re
  linarith

/-- **Blip-suppression / coercivity bound:** larger `Δs²` ⟹ stronger
damping.

If two weights share the same kernel `η` but differ only in `Δs`, the
one with larger `Δs²` has smaller damping magnitude.  This is the
discretised version of catept-core's
`eq057_coercivity_implies_convergence`: more action ⟹ more
suppression. -/
theorem dampingMagnitude_monotone_in_Δs_sq
    (η : EtaKernel) (Δs₁ Δs₂ sbar₁ sbar₂ : ℝ)
    (h : Δs₁ ^ 2 ≤ Δs₂ ^ 2) :
    (mk η Δs₂ sbar₂).dampingMagnitude
      ≤ (mk η Δs₁ sbar₁).dampingMagnitude := by
  unfold dampingMagnitude
  apply Real.exp_le_exp.mpr
  have h_re : 0 ≤ η.reEta := η.reEta_nonneg
  have hbound : Δs₁ ^ 2 * η.reEta ≤ Δs₂ ^ 2 * η.reEta :=
    mul_le_mul_of_nonneg_right h h_re
  linarith

/-- The damping magnitude at zero `Δs` (a "sojourn" rather than a blip)
is exactly `1`. -/
theorem dampingMagnitude_at_zero_Δs (η : EtaKernel) (sbar : ℝ) :
    (mk η 0 sbar).dampingMagnitude = 1 := by
  unfold dampingMagnitude
  simp [Real.exp_zero]

/-- Trivial existence: trivial weight. -/
theorem exists_trivial : ∃ _ : InfluenceFunctionalWeight, True :=
  ⟨{ η    := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
   , Δs   := 0
   , sbar := 0 }, trivial⟩

end InfluenceFunctionalWeight

-- ============================================================================
-- 4. Bridge: η ↔ CAT/EPT (S_R, S_I) per slice
-- ============================================================================

/-- **Bridge contract: η-coefficient ↔ CAT/EPT complex action per slice.**

The Makri η-coefficient packages a single time-slice's contribution to
the discretised influence functional.  CAT/EPT writes the same
contribution as `S_R + i S_I` per slice, with the damping factor
`exp(−S_I/ℏ)` and oscillatory factor `exp(i S_R / ℏ)`.

The identification at the carrier level:

* `S_I (= ℏ · Re η · Δs²)` — non-negative damping action contribution.
* `S_R (= 2 ℏ · Im η · Δs · sbar)` — oscillatory phase contribution.

Pattern matches `IdentifyEntropicProperTimeWithImaginaryAction` and the
`Identify…` family across PRs #85–#88. -/
structure IdentifyEtaWithComplexAction where
  /-- Discretised η-coefficient. -/
  η             : EtaKernel
  /-- Forward-backward slice data. -/
  Δs            : ℝ
  /-- Midpoint coordinate. -/
  sbar          : ℝ
  /-- Planck constant. -/
  ℏ             : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos         : 0 < ℏ
  /-- CAT/EPT real action `S_R`. -/
  S_R           : ℝ
  /-- CAT/EPT imaginary action `S_I`. -/
  S_I           : ℝ
  /-- Identification of `S_I` with the Makri damping kernel. -/
  S_I_eq        : S_I = ℏ * η.reEta * Δs ^ 2
  /-- Identification of `S_R` with the Makri oscillatory kernel. -/
  S_R_eq        : S_R = 2 * ℏ * η.imEta * Δs * sbar

namespace IdentifyEtaWithComplexAction

variable (B : IdentifyEtaWithComplexAction)

/-- Under the identification, `S_I ≥ 0`.  Combines `ℏ > 0`,
`Re η ≥ 0`, and `Δs² ≥ 0`. -/
theorem S_I_nonneg : 0 ≤ B.S_I := by
  rw [B.S_I_eq]
  have h_ℏ : 0 ≤ B.ℏ := le_of_lt B.ℏ_pos
  have h_re : 0 ≤ B.η.reEta := B.η.reEta_nonneg
  have h_sq : 0 ≤ B.Δs ^ 2 := sq_nonneg _
  have hp1 : 0 ≤ B.ℏ * B.η.reEta := mul_nonneg h_ℏ h_re
  exact mul_nonneg hp1 h_sq

/-- Under the identification, the discretised CAT/EPT damping factor
`exp(−S_I/ℏ)` equals the Makri damping magnitude exactly. -/
theorem catept_damping_eq_eta_damping :
    Real.exp (- B.S_I / B.ℏ)
      = (InfluenceFunctionalWeight.mk B.η B.Δs B.sbar).dampingMagnitude := by
  unfold InfluenceFunctionalWeight.dampingMagnitude
  rw [B.S_I_eq]
  congr 1
  have hℏ : B.ℏ ≠ 0 := ne_of_gt B.ℏ_pos
  field_simp

/-- Trivial existence: zero everything. -/
theorem exists_trivial : ∃ _ : IdentifyEtaWithComplexAction, True :=
  ⟨{ η     := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
   , Δs    := 0
   , sbar  := 0
   , ℏ     := 1
   , ℏ_pos := by norm_num
   , S_R   := 0
   , S_I   := 0
   , S_I_eq := by ring
   , S_R_eq := by ring }, trivial⟩

end IdentifyEtaWithComplexAction

-- ============================================================================
-- 5. Bridge: spectral density (J, β, dt) ↔ η-coefficient
-- ============================================================================

/-- **Bridge contract: spectral density ↔ η-coefficient.**

The Makri integral relation

  η = (1/2π) ∫ J(ω) · (1/ω²) · 2/(1 − e^{−ω β}) · f(ω, dt) dω

is the standard QuAPI formula relating bath kernel `J(ω)`, inverse
temperature `β`, and timestep `dt` to the discretised influence-
functional kernel.  We carry only the structural triple `(J, β, dt)`
and an opaque `origin_witness : Prop` field; consumers wishing to
prove the integral relation supply it as the witness body. -/
structure EtaFromSpectralDensity where
  /-- The bath spectral density. -/
  spectralDensity : SpectralDensity
  /-- Inverse temperature `β > 0`. -/
  β               : ℝ
  /-- Strict positivity of `β`. -/
  β_pos           : 0 < β
  /-- Timestep `dt > 0`. -/
  dt              : ℝ
  /-- Strict positivity of `dt`. -/
  dt_pos          : 0 < dt
  /-- The resulting η-kernel. -/
  η               : EtaKernel
  /-- Carrier-level witness that `η` originated from `(J, β, dt)`
  via the QuAPI integral.  Phase-2 supplies the proof. -/
  origin_witness  : Prop

namespace EtaFromSpectralDensity

/-- Trivial existence: zero spectral density, β = 1, dt = 1, zero η. -/
theorem exists_trivial : ∃ _ : EtaFromSpectralDensity, True :=
  ⟨{ spectralDensity := { J := fun _ => 0, J_nonneg := fun _ => le_refl 0 }
   , β               := 1
   , β_pos           := by norm_num
   , dt              := 1
   , dt_pos          := by norm_num
   , η               := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
   , origin_witness  := True }, trivial⟩

end EtaFromSpectralDensity

-- ============================================================================
-- 6. Capstone bundle
-- ============================================================================

/-- **QuAPI / Blip / spectral-density carrier bundle.**

All structural deliverables for the Tier-1 content of QuantumDynamics.jl
hold simultaneously:

* A spectral density exists (zero-J instance).
* An η-coefficient kernel exists (zero kernel).
* An influence-functional weight exists (trivial slice).
* The η ↔ CAT/EPT complex-action bridge admits a trivial instance.
* The spectral-density ↔ η bridge admits a trivial instance.

Phase-2 refinements substitute concrete `(Ohmic, Drude-Lorentz, …)`
spectral-density formulas, instantiate the QuAPI integral relation as
a real theorem, and close the η-kernel via the trapezoid quadrature
used by `EtaCoefficients.calculate_η`. -/
theorem eta_spectral_density_carrier_bundle :
    (∃ _ : SpectralDensity, True)
    ∧ (∃ _ : EtaKernel, True)
    ∧ (∃ _ : InfluenceFunctionalWeight, True)
    ∧ (∃ _ : IdentifyEtaWithComplexAction, True)
    ∧ (∃ _ : EtaFromSpectralDensity, True) :=
  ⟨SpectralDensity.exists_trivial,
   EtaKernel.exists_trivial,
   InfluenceFunctionalWeight.exists_trivial,
   IdentifyEtaWithComplexAction.exists_trivial,
   EtaFromSpectralDensity.exists_trivial⟩

end CATEPTMain.Integration.EtaSpectralDensityCarrier

end
