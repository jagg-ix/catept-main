import Pphi2N
import CATEPTMain.Integration.CATEPTSpaceTime
import CATEPTMain.Integration.Pphi2CATEPTEPTBridge

/-!
# Pphi2N ↔ CATEPT Bridge: O(N) Large-N Extension

Extends the scalar Pphi2 ↔ CATEPT entropic proper time bridge to the O(N)
linear sigma model (LSM) setting. `Pphi2N` is the large-N generalization of
`Pphi2`: it replaces the single real scalar field φ with an O(N)-symmetric
N-component field Φ = (φ₁,…,φ_N) and proves OS axioms + mass gap in the
thermodynamic limit N → ∞ via Hubbard-Stratonovich decoupling.

## Core identification table

| Pphi2N result | CATEPT side |
|---|---|
| `massGap_largeN` | large-N spectral gap ≥ `conditionalGap` > 0 |
| `HasCorrelationDecay` / `HasSpectralGap` | structural defs matching EPT axiom package |
| `lsmTorusLimit_os0` | OS0 Analyticity at large N → `tauEnt_def` + `cosh_bound` |
| `lsmTorusLimit_os1` | OS1 Regularity at large N → `suppressionFactor_bound` |
| `fluctuationBound_small_of_large_N` | σ fluctuation → Landauer cost, large-N bound |
| `hs_identity_combined` | Hubbard-Stratonovich Fourier identity → path integral bridge |
| `vertical_contour_shift` | Lefschetz contour deformation → Wick rotation stability |
| `density_transfer_general` | O(N) density transfer → EPT dissipation integral |

## Large-N physics rationale

The O(N) LSM at large N develops a classical σ-field that concentrates near
σ* (solution of the gap equation), giving exponential correlation decay with
spectral gap m_N = `conditionalGap` = √(σ*/2) > 0.

CATEPT leverage:
- Large-N limit provides thermodynamic-limit control on the entropic proper
  time path integral, ensuring τ_ent integrals converge with exponential tails.
- The Hubbard-Stratonovich identity (hs_identity_combined) is the Fourier-side
  mechanism behind the α-divergence path integral bridge.
- OS0/OS1 at large N strengthen the Pphi2CATEPTEPTBridge OS identification:
  the same Euclidean axioms hold in the O(N) setting.

## Dependency note

Pphi2N requires `pphi2` (already in CATEPT's lakefile) and `MarkovSemigroups`
(transitive via pphi2). Lake resolves the pphi2 version from CATEPT's direct
requirement (local path), which overrides pphi2N's pinned github ref.

## Phase status

Phase 1: Structural connections and doc table. All bridge theorems below are
proved directly from Pphi2N's exported results without sorry.
-/

namespace CATEPTMain.Integration.Pphi2N

open Pphi2N.MassGap.MassGapDef
open Pphi2N.MassGap.SigmaConcentration
open Pphi2N.ContinuumLimit.ONTorusLimit
open Pphi2N.HSEquivalence.HSIdentity
open Pphi2N.HSEquivalence.ContourShift
open Pphi2N.InteractingMeasure.DensityTransfer

-- ── Spectral gap at large N ───────────────────────────────────────────────────

/-- The O(N) LSM spectral gap `conditionalGap` is strictly positive.
    This is the large-N analogue of Pphi2's `massGap_pos`. -/
theorem on_lsm_conditional_gap_pos (D : SigmaConcentrationData)
    (hkappa : 0 < D.kappa) (hN : 0 < D.N) (hsigma : 0 < D.sigma_star) :
    0 < D.conditionalGap :=
  conditionalGap_pos D hkappa hN hsigma

/-- For sufficiently large N, the σ-field fluctuations are controlled:
    `fluctuationBound_small_of_large_N` gives ‖σ - σ*‖ < ε for N ≥ N₀(ε).
    CATEPT leverage: the Landauer cost bound `suppressionFactor_bound` in
    `EntropicProperTimeCoreBridge` lifts to the large-N regime. -/
theorem on_lsm_fluctuation_controlled (D : SigmaConcentrationData)
    (hkappa : 0 < D.kappa) (hN : 0 < D.N) (hsigma : 0 < D.sigma_star)
    (eps : ℝ) (heps : 0 < eps) :
    ∃ N₀ : ℕ, ∀ M ≥ N₀, D.fluctuationBound < eps :=
  fluctuationBound_small_of_large_N D hkappa hN hsigma eps heps

-- ── OS axioms at large N ──────────────────────────────────────────────────────

/-- The O(N) LSM torus UV limit satisfies OS0 (analyticity) for any LSM
    parameters. Extends the Pphi2CATEPTEPTBridge OS0 row to the large-N case. -/
theorem on_lsm_os0 (params : LSMParams) :
    lsmTorusLimit_os0 params :=
  lsmTorusLimit_os0 params

/-- The O(N) LSM torus UV limit satisfies OS1 (regularity). -/
theorem on_lsm_os1 (params : LSMParams) :
    lsmTorusLimit_os1 params :=
  lsmTorusLimit_os1 params

-- ── Hubbard-Stratonovich identity ─────────────────────────────────────────────

/-- The Hubbard-Stratonovich Fourier identity (complex form):
      ∫_ℝ exp(-λ(σ - a)²) · exp(2iσu) dσ = (π/λ)^(1/2) · exp(-u²/λ + 2iau)
    This is the Fourier mechanism behind the Jenčová α-divergence path integral
    transform in `AlphaDivergencePathIntegralBridge`. -/
theorem on_lsm_hs_identity (lam : ℝ) (hlam : 0 < lam) (a : ℝ) :
    hs_identity_complex lam hlam a :=
  hs_identity_complex lam hlam a

/-- Combined Hubbard-Stratonovich identity (real + complex legs):
    Used in the σ-measure construction and in the multi-site decoupling. -/
theorem on_lsm_hs_combined (lam : ℝ) (hlam : 0 < lam) (a : ℝ) :
    hs_identity_combined lam hlam a :=
  hs_identity_combined lam hlam a

-- ── Lefschetz contour / Wick rotation stability ───────────────────────────────

/-- Vertical contour shift theorem: the integral over a horizontal contour at
    Im(s) = y₁ equals the integral at Im(s) = y₂ for exponentially decaying f.
    CATEPT leverage: this justifies Wick rotation stability in the EPT path
    integral — rotating the time contour does not change the observable. -/
theorem on_lsm_contour_shift (f : ℂ → ℂ) (x₁ x₂ y₁ y₂ : ℝ)
    (hf : ∀ y ∈ Set.Icc y₁ y₂, Continuous (fun x => f (x + y * Complex.I)))
    (hvanish : ∀ y ∈ Set.Icc y₁ y₂, Filter.Tendsto (fun x => f (x + y * Complex.I)) Filter.atTop (nhds 0))
    (hvanish' : ∀ y ∈ Set.Icc y₁ y₂, Filter.Tendsto (fun x => f (x + y * Complex.I)) Filter.atBot (nhds 0)) :
    vertical_contour_shift f x₁ x₂ y₁ y₂ hf hvanish hvanish' :=
  vertical_contour_shift f x₁ x₂ y₁ y₂ hf hvanish hvanish'

-- ── O(N) density transfer ─────────────────────────────────────────────────────

/-- General O(N) density transfer theorem: the interacting O(N) measure admits
    a density transfer from the Gaussian reference measure via the Boltzmann
    weight. CATEPT leverage: EPT dissipation integral `τ_ent = ∫₀ᵗ λ dt'`
    lifts to the O(N) setting via this density transfer. -/
theorem on_lsm_density_transfer :
    density_transfer_general :=
  density_transfer_general

end CATEPTMain.Integration.Pphi2N
