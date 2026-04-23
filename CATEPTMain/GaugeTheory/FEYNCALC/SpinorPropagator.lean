import CATEPTMain.GaugeTheory.FEYNCALC.DiracAlgebra
import CATEPTMain.GaugeTheory.FEYNCALC.DiracTrace
import CATEPTMain.GaugeTheory.FEYNCALC.LorentzAlgebra
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.Tactic
/-!
# Spinor Propagator — Dirac Propagator as FCEnd, CATEPT Weight Bridge

Defines the Dirac propagator in momentum space as an `FCEnd`-valued function,
and identifies the `+iε` Feynman prescription with the CATEPT imaginary action
`S_I`. This bridges FEYNCALC algebra and the CATEPT complex path integral framework.

The **curved spacetime extension** uses `CurvedMeasurePathIntegralModel` from
`NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral`, which carries both the
measure-theoretic path integral AND the geometric datum `ρ_g dμ`. For the flat
Euclidean limit, `volumeDensity = 1` recovers the standard Gaussian model.

## The Dirac Propagator

In momentum space (Euclidean signature ++++, mass m):

  S_E(k, m) = (k̸ + m · 1₄) / (k² + m²)

where k² = k₁² + k₂² + k₃² + k₄² (Euclidean) and k̸ = kᵢ γᵢ.

## CAT/EPT Identification: `+iε` = `S_I`

The `+iε` Feynman prescription corresponds to:
  actionIm(k) = k₁² + k₂² + k₃² + k₄² + m²  (= euclideanDenominator k m)
  damping(k)  = exp(−actionIm(k)/ħ)

**Schwinger parametrization**:
  G_E(k) = 1/(k²+m²) = ∫₀^∞ exp(−(k²+m²)t) dt

This is the Laplace transform of the CATEPT damping over proper time t ∈ [0,∞).

**Curved spacetime**: replacing `dμ` with `dμ_g = ρ_g dμ` (√|g| factor) gives
the propagator in a curved Euclidean background. The flat limit ρ_g = 1 recovers
the standard free Dirac propagator.

## Theorem status

| Name                              | Status | Notes                                           |
|-----------------------------------|--------|-------------------------------------------------|
| `spinorTrace_pSlash`              | proved | Tr(p̸) = 0 via TR-1 linearity                   |
| `diracPropNumerator_trace`        | proved | Tr(p̸ + m) = 4m via TR-0 + TR-1                |
| `euclideanActionIm_nonneg`        | proved | k² + m² ≥ 0 (always)                            |
| `euclideanActionIm_measurable`    | proved | k ↦ ‖k‖² + m² is measurable                    |
| `euclideanDiracCurvedModel`       | def    | Free Dirac field as CurvedMeasurePathIntegralModel|
| `euclideanDiracDamping_integrable`| sorry  | Gaussian ∈ L¹(ℝ⁴) (standard but technical)     |
| `schwinger_parametrization`       | proved | 1/(k²+m²) = ∫₀^∞ exp(−(k²+m²)t) dt            |
| `propagator_as_catept_laplace`    | proved | G_E(k) = FK Laplace transform of damping        |
-/

set_option autoImplicit false

open Real Complex MeasureTheory
open NavierStokesClean.CATEPT

namespace CATEPTMain.GaugeTheory.FEYNCALC

-- ── Spinor trace of a slash ───────────────────────────────────────────────────

/-- `Tr(p̸) = 0`: the spinor trace of any Feynman slash vanishes. -/
theorem spinorTrace_pSlash (p : FCIdx → ℝ) : spinorTrace (pSlash p) = 0 := by
  unfold pSlash
  rw [spinorTrace_add, spinorTrace_add, spinorTrace_add,
      spinorTrace_smul, spinorTrace_smul, spinorTrace_smul, spinorTrace_smul,
      spinorTrace_gamma_zero, spinorTrace_gamma_zero,
      spinorTrace_gamma_zero, spinorTrace_gamma_zero]
  ring

/-- `Tr(m · 1₄) = 4m`: trace of a scalar multiple of the identity. -/
theorem spinorTrace_scalar_one (m : ℝ) :
    spinorTrace (smulEnd (m : ℂ) oneEnd) = 4 * (m : ℂ) := by
  rw [spinorTrace_smul, spinorTrace_one]; ring

-- ── Dirac propagator numerator ────────────────────────────────────────────────

/-- The numerator of the Dirac propagator: `N(p, m) = p̸ + m · 1₄`. -/
noncomputable def diracPropagatorNumerator (p : FCIdx → ℝ) (m : ℝ) : FCEnd :=
  pSlash p + smulEnd (m : ℂ) oneEnd

/-- `Tr(p̸ + m) = 4m`. -/
theorem diracPropNumerator_trace (p : FCIdx → ℝ) (m : ℝ) :
    spinorTrace (diracPropagatorNumerator p m) = 4 * (m : ℂ) := by
  unfold diracPropagatorNumerator
  rw [spinorTrace_add, spinorTrace_pSlash, spinorTrace_scalar_one]
  ring

/-- Euclidean propagator denominator: `k² + m²`. -/
noncomputable def euclideanDenominator (k : FCIdx → ℝ) (m : ℝ) : ℝ :=
  (∑ μ : FCIdx, (k μ) ^ 2) + m ^ 2

theorem euclideanDenominator_nonneg (k : FCIdx → ℝ) (m : ℝ) :
    0 ≤ euclideanDenominator k m := by
  unfold euclideanDenominator; positivity

theorem euclideanDenominator_pos_of_pos_mass (k : FCIdx → ℝ) (m : ℝ) (hm : 0 < m) :
    0 < euclideanDenominator k m := by
  unfold euclideanDenominator
  have hm2 : 0 < m ^ 2 := by positivity
  have hsum : 0 ≤ ∑ μ : FCIdx, (k μ) ^ 2 := by positivity
  linarith

-- ── Euclidean Dirac field CATEPT model (curved spacetime) ─────────────────────
--
-- State space: FCIdx → ℝ ≅ ℝ⁴  (Euclidean 4-momentum)
-- Base measure: Lebesgue on ℝ⁴; volumeDensity = 1 (flat, ρ_g = 1)
-- actionRe  = 0   (Euclidean: no oscillatory phase)
-- actionIm k = ((∑ μ, (k μ)²) + m²) · ħ  = euclideanDenominator k m · ħ

/-- Euclidean actionIm: `S_I(k) = (k₁² + k₂² + k₃² + k₄² + m²) · ħ`. -/
noncomputable def euclideanActionIm (k : FCIdx → ℝ) (m hbar : ℝ) : ℝ :=
  euclideanDenominator k m * hbar

theorem euclideanActionIm_nonneg (k : FCIdx → ℝ) (m hbar : ℝ) (hh : 0 < hbar) :
    0 ≤ euclideanActionIm k m hbar := by
  unfold euclideanActionIm
  exact mul_nonneg (euclideanDenominator_nonneg k m) hh.le

theorem euclideanActionIm_measurable (m hbar : ℝ) :
    Measurable (fun k : FCIdx → ℝ => euclideanActionIm k m hbar) := by
  unfold euclideanActionIm euclideanDenominator
  apply Measurable.mul_const
  apply Measurable.add
  · apply Finset.measurable_sum
    intro μ _
    exact (measurable_pi_apply μ).pow_const 2
  · exact measurable_const

/-- Geometric datum for the flat Euclidean Dirac model: Lebesgue measure, ρ_g = 1. -/
noncomputable def euclideanFlatGeom : CurvedSpacetimeDatum (FCIdx → ℝ) where
  baseMeasure         := MeasureTheory.Measure.pi (fun _ => MeasureTheory.volume)
  volumeDensity       := fun _ => 1
  measurable_volumeDensity := measurable_const
  volumeDensity_nonneg    := fun _ => zero_le_one

/-- The free Euclidean Dirac field as a `CurvedMeasurePathIntegralModel`.
    Geometry: flat Minkowski (ρ_g = 1, base = Lebesgue on ℝ⁴).
    Action: S_I(k) = (k² + m²) · ħ, S_R = 0 (Euclidean). -/
noncomputable def euclideanDiracCurvedModel (m hbar : ℝ) (hh : 0 < hbar) :
    CurvedMeasurePathIntegralModel (FCIdx → ℝ) where
  geom                := euclideanFlatGeom
  hbar                := hbar
  hbar_pos            := hh
  actionRe            := fun _ => 0
  actionIm            := fun k => euclideanActionIm k m hbar
  measurable_actionRe := measurable_const
  measurable_actionIm := euclideanActionIm_measurable m hbar
  actionIm_nonneg     := fun k => euclideanActionIm_nonneg k m hbar hh

/-- The flat model reduces to Lebesgue integration (ρ_g = 1). -/
theorem euclideanDiracCurvedModel_measure_eq_lebesgue (m hbar : ℝ) (hh : 0 < hbar) :
    (euclideanDiracCurvedModel m hbar hh).geom.volumeMeasure =
    (euclideanDiracCurvedModel m hbar hh).geom.baseMeasure := by
  apply CurvedSpacetimeDatum.volumeMeasure_eq_base_of_density_one
  simp [euclideanDiracCurvedModel, euclideanFlatGeom]

/-- Damping factor = exp(−(k²+m²)). -/
theorem euclideanDiracCurvedModel_damping_eq (m hbar : ℝ) (hh : 0 < hbar)
    (k : FCIdx → ℝ) :
    (euclideanDiracCurvedModel m hbar hh).toMeasurePathIntegralModel.damping k =
    Real.exp (-(euclideanDenominator k m)) := by
  simp only [CurvedMeasurePathIntegralModel.toMeasurePathIntegralModel,
             MeasurePathIntegralModel.damping, MeasurePathIntegralModel.actionImScaled,
             euclideanDiracCurvedModel, euclideanActionIm]
  congr 1
  field_simp

/-- The Euclidean Dirac damping is integrable on ℝ⁴ (Gaussian integral).
    Proof: rewrite as exp(-m²) · ∏_μ exp(-(k_μ)²), then use
    `Integrable.fintype_prod` from MeasureTheory.Integral.Pi and
    `integrable_exp_neg_mul_sq` for each 1D Gaussian factor. -/
theorem euclideanDiracDamping_integrable (m hbar : ℝ) (hh : 0 < hbar) :
    MeasureTheory.Integrable
      (fun k => (euclideanDiracCurvedModel m hbar hh).toMeasurePathIntegralModel.damping k)
      (euclideanDiracCurvedModel m hbar hh).geom.volumeMeasure := by
  -- Step 1: rewrite volumeMeasure to Measure.pi (product Lebesgue on ℝ⁴)
  have hmeas : (euclideanDiracCurvedModel m hbar hh).geom.volumeMeasure =
      MeasureTheory.Measure.pi (fun (_ : FCIdx) => MeasureTheory.volume) := by
    rw [euclideanDiracCurvedModel_measure_eq_lebesgue]
    simp only [euclideanDiracCurvedModel, euclideanFlatGeom]
  rw [hmeas]
  -- Step 2: rewrite damping explicitly as exp(-euclideanDenominator k m)
  simp_rw [euclideanDiracCurvedModel_damping_eq]
  -- Step 3: unfold euclideanDenominator to Σ_μ (k μ)² + m²
  simp_rw [euclideanDenominator]
  -- Step 4: factor as exp(-m²) · Π_μ exp(-(k μ)²)
  have factored : ∀ k : FCIdx → ℝ,
      Real.exp (-(((∑ μ : FCIdx, k μ ^ 2) + m ^ 2))) =
      Real.exp (-m ^ 2) * ∏ μ : FCIdx, Real.exp (-(k μ) ^ 2) := by
    intro k
    rw [show -(((∑ μ : FCIdx, k μ ^ 2) + m ^ 2)) =
        (-m ^ 2) + (-(∑ μ : FCIdx, k μ ^ 2)) by linarith,
      ← Finset.sum_neg_distrib (f := fun μ => k μ ^ 2),
      Real.exp_add, ← Real.exp_sum]
  simp_rw [factored]
  -- Step 5: each 1D factor exp(-(k μ)²) is integrable
  have h1 : MeasureTheory.Integrable (fun x : ℝ => Real.exp (-x ^ 2)) MeasureTheory.volume := by
    have := integrable_exp_neg_mul_sq (b := 1) (by norm_num : (0:ℝ) < 1)
    simpa [neg_mul, one_mul] using this
  -- Step 6: const factor × product of 1D Gaussians; provide f explicitly
  have hprod : MeasureTheory.Integrable
      (fun (x : FCIdx → ℝ) => ∏ μ : FCIdx, Real.exp (-x μ ^ 2))
      (MeasureTheory.Measure.pi fun (_ : FCIdx) => MeasureTheory.volume) :=
    MeasureTheory.Integrable.fintype_prod (fun _ => h1)
  exact hprod.const_mul _

-- ── Schwinger parametrization ─────────────────────────────────────────────────

/-- **Schwinger parametrization**: `1/a = ∫₀^∞ exp(−at) dt` for `a > 0`.
    Uses `integral_exp_mul_Ioi` with coefficient `−a < 0`. -/
theorem schwinger_parametrization (a : ℝ) (ha : 0 < a) :
    ∫ t in Set.Ioi (0 : ℝ), Real.exp (-a * t) = 1 / a := by
  rw [integral_exp_mul_Ioi (by linarith : -a < 0) 0]
  simp only [mul_zero, Real.exp_zero]
  ring

/-- **Curved Schwinger identity**: the Euclidean propagator equals the Laplace
    transform of the CATEPT damping. In curved spacetime, the Schwinger proper-time
    integral acquires a ρ_g weight when integrated against `dμ_g`.

      G_E(k) = 1/(k²+m²) = ∫₀^∞ exp(−(k²+m²)·t) dt

    Curved extension: replace `exp(−(k²+m²)·t)` with `ρ_g(k) · exp(−(k²+m²)·t)`
    in `dμ` (flat limit ρ_g=1 recovers the flat result). -/
theorem propagator_as_catept_laplace (k : FCIdx → ℝ) (m : ℝ) (hm : 0 < m) :
    1 / euclideanDenominator k m =
    ∫ t in Set.Ioi (0 : ℝ), Real.exp (-(euclideanDenominator k m) * t) := by
  rw [schwinger_parametrization _ (euclideanDenominator_pos_of_pos_mass k m hm)]

end CATEPTMain.GaugeTheory.FEYNCALC
