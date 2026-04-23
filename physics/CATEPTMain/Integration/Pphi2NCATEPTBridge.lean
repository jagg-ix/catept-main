import Pphi2N
import Pphi2N.HSEquivalence.ContourShift
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

-- ── Spectral gap at large N ───────────────────────────────────────────────────

/-- The O(N) LSM spectral gap `conditionalGap` is strictly positive.
    This is the large-N analogue of Pphi2's `massGap_pos`. -/
theorem on_lsm_conditional_gap_pos
    {Λ : Type*} [Fintype Λ]
    (D : _root_.Pphi2N.SigmaConvexityData Λ) :
    0 < D.conditionalGap :=
  D.conditionalGap_pos

/-- For sufficiently large N, the σ-field fluctuations are controlled:
    `fluctuationBound_small_of_large_N` gives
    `D.fluctuationBound < D.sigma_star / 2` when `D.nThreshold ≤ D.N`.
    CATEPT leverage: the Landauer cost bound `suppressionFactor_bound` in
    `EntropicProperTimeCoreBridge` lifts to the large-N regime. -/
theorem on_lsm_fluctuation_controlled
    {Λ : Type*} [Fintype Λ]
    (D : _root_.Pphi2N.SigmaConvexityData Λ)
    (hN_large : D.nThreshold ≤ D.N) :
    D.fluctuationBound < D.sigma_star / 2 :=
  D.fluctuationBound_small_of_large_N hN_large

-- ── OS axioms at large N ──────────────────────────────────────────────────────

/-- The O(N) LSM torus UV limit satisfies OS0 (analyticity) for any LSM
    parameters. Extends the Pphi2CATEPTEPTBridge OS0 row to the large-N case. -/
def on_lsm_os0 := (_root_.Pphi2N.lsmTorusLimit_os0)

/-- The O(N) LSM torus UV limit satisfies OS1 (regularity). -/
def on_lsm_os1 := (_root_.Pphi2N.lsmTorusLimit_os1)

-- ── Hubbard-Stratonovich identity ─────────────────────────────────────────────

/-- The Hubbard-Stratonovich Fourier identity (complex form):
      ∫_ℝ exp(-λ(σ - a)²) · exp(2iσu) dσ = (π/λ)^(1/2) · exp(-u²/λ + 2iau)
    This is the Fourier mechanism behind the Jenčová α-divergence path integral
    transform in `AlphaDivergencePathIntegralBridge`. -/
def on_lsm_hs_identity := (_root_.Pphi2N.hs_identity_complex)

/-- Combined Hubbard-Stratonovich identity (real + complex legs):
    Used in the σ-measure construction and in the multi-site decoupling. -/
def on_lsm_hs_combined := (_root_.Pphi2N.hs_identity_combined)

-- ── Lefschetz contour / Wick rotation stability ───────────────────────────────

/-- Vertical contour shift theorem: the integral over a horizontal contour at
    Im(s) = y₁ equals the integral at Im(s) = y₂ for exponentially decaying f.
    CATEPT leverage: this justifies Wick rotation stability in the EPT path
    integral — rotating the time contour does not change the observable. -/
def on_lsm_contour_shift := (_root_.Pphi2N.vertical_contour_shift)

-- ── O(N) density transfer ─────────────────────────────────────────────────────

/-- General O(N) density transfer theorem: the interacting O(N) measure admits
    a density transfer from the Gaussian reference measure via the Boltzmann
    weight. CATEPT leverage: EPT dissipation integral `τ_ent = ∫₀ᵗ λ dt'`
    lifts to the O(N) setting via this density transfer. -/
theorem on_lsm_density_transfer
  {Ω : Type*} [MeasurableSpace Ω]
  (μ : MeasureTheory.Measure Ω) [MeasureTheory.IsProbabilityMeasure μ]
  (ρ : Ω → ℝ) (hρ_nn : ∀ ω, 0 ≤ ρ ω) (hρ_meas : Measurable ρ)
  (Z : ℝ) (hZ_pos : 0 < Z) (hZ_eq : ∫ ω, ρ ω ∂μ = Z)
  (F : Ω → ℝ) (hF_nn : ∀ ω, 0 ≤ F ω)
  (hF_meas : MeasureTheory.AEStronglyMeasurable F μ)
  (hF_sq_int : MeasureTheory.Integrable (fun ω => F ω ^ 2) μ)
  (K : ℝ) (hK_pos : 0 < K)
  (hρ_sq_int : MeasureTheory.Integrable (fun ω => ρ ω ^ 2) μ)
  (hK : ∫ ω, ρ ω ^ 2 ∂μ ≤ K) :
  ∫ ω, F ω ∂((ENNReal.ofReal Z)⁻¹ •
    μ.withDensity (fun ω => ENNReal.ofReal (ρ ω))) ≤
    (1 / Z) * K ^ (1 / 2 : ℝ) * (∫ ω, F ω ^ (2 : ℝ) ∂μ) ^ (1 / 2 : ℝ) :=
  _root_.Pphi2N.density_transfer_general μ ρ hρ_nn hρ_meas
  Z hZ_pos hZ_eq F hF_nn hF_meas hF_sq_int K hK_pos hρ_sq_int hK

end CATEPTMain.Integration.Pphi2N
