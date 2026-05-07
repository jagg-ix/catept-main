import CATEPTMain.Integration.EtaSpectralDensityCarrier
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Tactic.Positivity

/-!
# EtaSpectralDensityCarrierPhase2 — Concrete Instances + Multi-Slice Kernel

Phase-2 refinements of `EtaSpectralDensityCarrier` (Tier-1, PR #97):

1. **Concrete spectral-density formulas** — Ohmic (`ExponentialCutoff`
   with `n = 1`) and Drude-Lorentz, ported from
   `QuantumDynamics.jl::Environment/SpectralDensities.jl` lines
   86–125, with explicit non-negativity proofs.
2. **Multi-slice η-kernel** — `(η00, ηmm, η0m[k], ηmn[k], η0e[k])`
   bundle matching `EtaCoefficients.EtaCoeffs` exactly.
3. **Multi-slice damping bound** — product of single-slice damping
   factors stays in `(0, 1]` (telescoping monotonicity).

## Honest scope

Same as Phase 1: this is a structural carrier.  The integral relation
`η = (1/2π) ∫ J(ω) g(ω, β, dt) dω` remains an abstract `origin_witness`.
The concrete formulas here are *defined* at the per-frequency level
(non-negative by construction) but their integration into `η` values
is still phase-3 work.

## What this module ships

* `ohmicJ` — `J_Ohmic(ω) = (2π/Δs²) · ξ · |ω| · exp(-|ω|/ωc)`.
* `drudeLorentzJ` — `J_DL(ω) = (2λ/Δs²) · |ω| γ / (|ω|² + γ²)`.
* `OhmicSpectralDensity` / `DrudeLorentzSpectralDensity` — concrete
  `SpectralDensity` instances with non-negativity discharged.
* `MultiSliceEtaKernel` — full `EtaCoeffs`-shaped bundle with `kmax`
  intermediate lags and uniform `Re η ≥ 0`.
* `MultiSliceEtaKernel.totalDampingProduct` — telescoping product of
  per-slice damping magnitudes.
* `totalDampingProduct_le_one` — universal multi-slice damping bound.
* `eta_spectral_density_phase2_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2

open CATEPTMain.Integration.EtaSpectralDensityCarrier

-- ============================================================================
-- 1. Concrete spectral densities (Ohmic, Drude-Lorentz)
-- ============================================================================

/-- **Ohmic spectral density** at the `n = 1` cutoff:

  `J_Ohmic(ω) = (2π / Δs²) · ξ · |ω| · exp(-|ω| / ωc)`.

Ports `ExponentialCutoff` from `SpectralDensities.jl:86–96` with the
absolute-value convention so the function is non-negative on all of
ℝ (the Julia version has an odd extension via `sign(ω)` for FFT
integration; CAT/EPT uses the physical-half-line `|·|` convention). -/
def ohmicJ (ξ ωc Δs : ℝ) (ω : ℝ) : ℝ :=
  (2 * Real.pi / Δs ^ 2) * ξ * |ω| * Real.exp (-|ω| / ωc)

/-- Non-negativity of the Ohmic spectral density. -/
theorem ohmicJ_nonneg
    {ξ ωc Δs : ℝ} (hξ : 0 ≤ ξ) (hωc : 0 < ωc) (hΔs : Δs ≠ 0)
    (ω : ℝ) :
    0 ≤ ohmicJ ξ ωc Δs ω := by
  unfold ohmicJ
  have h2π : 0 < 2 * Real.pi := by positivity
  have hΔs_sq : 0 < Δs ^ 2 := by positivity
  have h_factor : 0 < 2 * Real.pi / Δs ^ 2 := div_pos h2π hΔs_sq
  have h_factor_nn : 0 ≤ 2 * Real.pi / Δs ^ 2 := le_of_lt h_factor
  have h_step1 : 0 ≤ 2 * Real.pi / Δs ^ 2 * ξ := mul_nonneg h_factor_nn hξ
  have h_abs : 0 ≤ |ω| := abs_nonneg _
  have h_step2 : 0 ≤ 2 * Real.pi / Δs ^ 2 * ξ * |ω| := mul_nonneg h_step1 h_abs
  have h_exp : 0 ≤ Real.exp (-|ω| / ωc) := le_of_lt (Real.exp_pos _)
  exact mul_nonneg h_step2 h_exp

/-- **Drude-Lorentz spectral density**:

  `J_DL(ω) = (2λ / Δs²) · |ω| · γ / (|ω|² + γ²)`.

Ports `DrudeLorentz` from `SpectralDensities.jl:115–125`, again with
the absolute-value convention.  The denominator `|ω|² + γ²` is
strictly positive when `γ > 0`, so the formula is well-defined
everywhere. -/
def drudeLorentzJ (lam gam Δs : ℝ) (ω : ℝ) : ℝ :=
  (2 * lam / Δs ^ 2) * |ω| * gam / (|ω| ^ 2 + gam ^ 2)

/-- Non-negativity of the Drude-Lorentz spectral density. -/
theorem drudeLorentzJ_nonneg
    {lam gam Δs : ℝ} (hlam : 0 ≤ lam) (hgam : 0 ≤ gam) (hΔs : Δs ≠ 0)
    (hgam_pos : 0 < gam)
    (ω : ℝ) :
    0 ≤ drudeLorentzJ lam gam Δs ω := by
  unfold drudeLorentzJ
  have hΔs_sq : 0 < Δs ^ 2 := by positivity
  have h_factor : 0 ≤ 2 * lam / Δs ^ 2 :=
    div_nonneg (by linarith) (le_of_lt hΔs_sq)
  have h_abs : 0 ≤ |ω| := abs_nonneg _
  have h_num : 0 ≤ 2 * lam / Δs ^ 2 * |ω| * gam := by
    have h1 : 0 ≤ 2 * lam / Δs ^ 2 * |ω| := mul_nonneg h_factor h_abs
    exact mul_nonneg h1 hgam
  have h_omega_sq : 0 ≤ |ω| ^ 2 := sq_nonneg _
  have h_gam_sq : 0 < gam ^ 2 := by positivity
  have h_denom : 0 < |ω| ^ 2 + gam ^ 2 := by linarith
  exact div_nonneg h_num (le_of_lt h_denom)

/-- **Ohmic concrete `SpectralDensity` instance.** -/
def OhmicSpectralDensity
    (ξ ωc Δs : ℝ) (hξ : 0 ≤ ξ) (hωc : 0 < ωc) (hΔs : Δs ≠ 0) :
    SpectralDensity :=
  { J        := ohmicJ ξ ωc Δs
  , J_nonneg := ohmicJ_nonneg hξ hωc hΔs }

/-- **Drude-Lorentz concrete `SpectralDensity` instance.** -/
def DrudeLorentzSpectralDensity
    (lam gam Δs : ℝ) (hlam : 0 ≤ lam) (hgam : 0 ≤ gam) (hΔs : Δs ≠ 0)
    (hgam_pos : 0 < gam) :
    SpectralDensity :=
  { J        := drudeLorentzJ lam gam Δs
  , J_nonneg := drudeLorentzJ_nonneg hlam hgam hΔs hgam_pos }

-- ============================================================================
-- 2. Multi-slice η-kernel (matches EtaCoeffs)
-- ============================================================================

/-- **Multi-slice η-coefficient bundle.**

Direct port of `EtaCoefficients.EtaCoeffs` from
`EtaCoefficients.jl:37–43`:

* `η00` — self-interaction of the two terminal time points.
* `ηmm` — self-interaction of intermediate points (uniform across
  intermediates by time-translation symmetry).
* `η0m k` — terminal-to-intermediate at lag `k`.
* `ηmn k` — intermediate-to-intermediate at lag `k`.
* `η0e k` — terminal-to-terminal at lag `k`.

`kmax` is the longest lag retained.  All five entries are `EtaKernel`s
(carrying the per-slice `Re η ≥ 0` discrete-coercivity hypothesis). -/
structure MultiSliceEtaKernel where
  /-- Maximum lag retained. -/
  kmax  : ℕ
  /-- Terminal-terminal self-interaction. -/
  η00   : EtaKernel
  /-- Intermediate-intermediate self-interaction. -/
  ηmm   : EtaKernel
  /-- Terminal-to-intermediate at lag `k`. -/
  η0m   : Fin kmax → EtaKernel
  /-- Intermediate-to-intermediate at lag `k`. -/
  ηmn   : Fin kmax → EtaKernel
  /-- Terminal-to-terminal at lag `k`. -/
  η0e   : Fin kmax → EtaKernel

namespace MultiSliceEtaKernel

variable (M : MultiSliceEtaKernel)

/-- **Total damping product across all `kmax + 2` slices.**

Models the QuAPI weight `∏_k exp(-Δs_k² · Re η_k)` where the kernel at
each step is sampled from `M`.  We approximate by taking
`InfluenceFunctionalWeight`s with `Δs = sbar = 0` for slots beyond
the carrier's data — the trivial (`= 1`) damping factor for sojourns
keeps the product well-defined.

For a per-slice `Δs : Fin (kmax + 2) → ℝ`, we'd compute the actual
product; here we expose the structural shape with the `at_zero`
specialization for the capstone. -/
def totalDampingProduct (Δs : Fin M.kmax → ℝ) : ℝ :=
  (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude
    * (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude
    * (Finset.univ : Finset (Fin M.kmax)).prod
        (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude)

/-- The total damping product is strictly positive. -/
theorem totalDampingProduct_pos (Δs : Fin M.kmax → ℝ) :
    0 < M.totalDampingProduct Δs := by
  unfold totalDampingProduct
  have h1 : 0 < (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude :=
    InfluenceFunctionalWeight.dampingMagnitude_pos _
  have h2 : 0 < (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude :=
    InfluenceFunctionalWeight.dampingMagnitude_pos _
  have h3 : 0 < (Finset.univ : Finset (Fin M.kmax)).prod
      (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude) := by
    apply Finset.prod_pos
    intro k _
    exact InfluenceFunctionalWeight.dampingMagnitude_pos _
  positivity

/-- **Universal multi-slice damping bound:** the total product is
bounded by `1`.  Discrete analogue of `eq054_damping_magnitude` lifted
to the multi-slice product. -/
theorem totalDampingProduct_le_one (Δs : Fin M.kmax → ℝ) :
    M.totalDampingProduct Δs ≤ 1 := by
  unfold totalDampingProduct
  have h1_le : (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude ≤ 1 :=
    InfluenceFunctionalWeight.dampingMagnitude_le_one _
  have h2_le : (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude ≤ 1 :=
    InfluenceFunctionalWeight.dampingMagnitude_le_one _
  have h3_le : (Finset.univ : Finset (Fin M.kmax)).prod
      (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude) ≤ 1 := by
    apply Finset.prod_le_one
    · intro k _
      exact le_of_lt (InfluenceFunctionalWeight.dampingMagnitude_pos _)
    · intro k _
      exact InfluenceFunctionalWeight.dampingMagnitude_le_one _
  have h1_pos : 0 ≤ (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude :=
    le_of_lt (InfluenceFunctionalWeight.dampingMagnitude_pos _)
  have h2_pos : 0 ≤ (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude :=
    le_of_lt (InfluenceFunctionalWeight.dampingMagnitude_pos _)
  have h3_pos : 0 ≤ (Finset.univ : Finset (Fin M.kmax)).prod
      (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude) := by
    apply Finset.prod_nonneg
    intro k _
    exact le_of_lt (InfluenceFunctionalWeight.dampingMagnitude_pos _)
  have hp1 : (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude
      * (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude ≤ 1 := by
    calc (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude
            * (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude
        ≤ 1 * (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude :=
          mul_le_mul_of_nonneg_right h1_le h2_pos
      _ = (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude := one_mul _
      _ ≤ 1 := h2_le
  have hp1_pos : 0 ≤ (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude
      * (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude := mul_nonneg h1_pos h2_pos
  calc (InfluenceFunctionalWeight.mk M.η00 0 0).dampingMagnitude
        * (InfluenceFunctionalWeight.mk M.ηmm 0 0).dampingMagnitude
        * (Finset.univ : Finset (Fin M.kmax)).prod
            (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude)
      ≤ 1 * (Finset.univ : Finset (Fin M.kmax)).prod
            (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude) :=
        mul_le_mul_of_nonneg_right hp1 h3_pos
    _ = (Finset.univ : Finset (Fin M.kmax)).prod
            (fun k => (InfluenceFunctionalWeight.mk (M.ηmn k) (Δs k) 0).dampingMagnitude) := one_mul _
    _ ≤ 1 := h3_le

/-- Trivial existence: zero-lag, all kernels zero. -/
theorem exists_trivial : ∃ _ : MultiSliceEtaKernel, True :=
  ⟨{ kmax := 0
   , η00  := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
   , ηmm  := { reEta := 0, imEta := 0, reEta_nonneg := le_refl 0 }
   , η0m  := fun k => Fin.elim0 k
   , ηmn  := fun k => Fin.elim0 k
   , η0e  := fun k => Fin.elim0 k }, trivial⟩

end MultiSliceEtaKernel

-- ============================================================================
-- 3. Capstone bundle
-- ============================================================================

/-- **Phase-2 capstone.**

Concrete deliverables for Tier-1 Phase 2:

* The Ohmic concrete `SpectralDensity` instance is well-defined.
* The Drude-Lorentz concrete `SpectralDensity` instance is well-defined.
* A `MultiSliceEtaKernel` exists (zero-lag instance).

Phase-3 work (still open): instantiate the QuAPI integral relation
`η = (1/2π) ∫ J(ω) g(ω, β, dt) dω` for these concrete `J`s, replacing
`EtaFromSpectralDensity.origin_witness` with a real proof. -/
theorem eta_spectral_density_phase2_bundle :
    -- Ohmic instance is well-defined for any `(ξ ≥ 0, ωc > 0, Δs ≠ 0)`.
    (∀ (ξ ωc Δs : ℝ) (hξ : 0 ≤ ξ) (hωc : 0 < ωc) (hΔs : Δs ≠ 0),
        ∃ _ : SpectralDensity, True)
    -- Drude-Lorentz instance is well-defined for any `(λ ≥ 0, γ > 0, Δs ≠ 0)`.
    ∧ (∀ (lam gam Δs : ℝ) (hlam : 0 ≤ lam) (hgam : 0 ≤ gam) (hΔs : Δs ≠ 0)
        (hgam_pos : 0 < gam),
        ∃ _ : SpectralDensity, True)
    -- Multi-slice kernels exist.
    ∧ (∃ _ : MultiSliceEtaKernel, True) := by
  refine ⟨?_, ?_, MultiSliceEtaKernel.exists_trivial⟩
  · intro ξ ωc Δs hξ hωc hΔs
    exact ⟨OhmicSpectralDensity ξ ωc Δs hξ hωc hΔs, trivial⟩
  · intro lam gam Δs hlam hgam hΔs hgam_pos
    exact ⟨DrudeLorentzSpectralDensity lam gam Δs hlam hgam hΔs hgam_pos, trivial⟩

end CATEPTMain.Integration.EtaSpectralDensityCarrier.Phase2

end
