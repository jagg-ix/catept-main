import CATEPTPluginDomainGauge.FEYNCALC.SpinorPropagator
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import Mathlib.MeasureTheory.Measure.Lebesgue.Basic
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.MeasureTheory.Integral.Pi

set_option autoImplicit false

open Real Complex MeasureTheory
open NavierStokesClean.CATEPT

namespace CATEPTMain.GaugeTheory.FEYNCALC

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
  have hmeas : (euclideanDiracCurvedModel m hbar hh).geom.volumeMeasure =
      MeasureTheory.Measure.pi (fun (_ : FCIdx) => MeasureTheory.volume) := by
    rw [euclideanDiracCurvedModel_measure_eq_lebesgue]
    simp only [euclideanDiracCurvedModel, euclideanFlatGeom]
  rw [hmeas]
  simp_rw [euclideanDiracCurvedModel_damping_eq]
  simp_rw [euclideanDenominator]
  have factored : ∀ k : FCIdx → ℝ,
      Real.exp (-(((∑ μ : FCIdx, k μ ^ 2) + m ^ 2))) =
      Real.exp (-m ^ 2) * ∏ μ : FCIdx, Real.exp (-(k μ) ^ 2) := by
    intro k
    rw [show -(((∑ μ : FCIdx, k μ ^ 2) + m ^ 2)) =
        (-m ^ 2) + (-(∑ μ : FCIdx, k μ ^ 2)) by linarith,
      ← Finset.sum_neg_distrib (f := fun μ => k μ ^ 2),
      Real.exp_add, ← Real.exp_sum]
  simp_rw [factored]
  have h1 : MeasureTheory.Integrable (fun x : ℝ => Real.exp (-x ^ 2)) MeasureTheory.volume := by
    have := integrable_exp_neg_mul_sq (b := 1) (by norm_num : (0:ℝ) < 1)
    simpa [neg_mul, one_mul] using this
  have hprod : MeasureTheory.Integrable
      (fun (x : FCIdx → ℝ) => ∏ μ : FCIdx, Real.exp (-x μ ^ 2))
      (MeasureTheory.Measure.pi fun (_ : FCIdx) => MeasureTheory.volume) :=
    MeasureTheory.Integrable.fintype_prod (fun _ => h1)
  exact hprod.const_mul _

end CATEPTMain.GaugeTheory.FEYNCALC
