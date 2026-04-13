import Mathlib.MeasureTheory.Measure.WithDensity
import NavierStokesClean.CATEPT.MeasurePathIntegral

/-!
# CAT/EPT Curved-Spacetime Measure Path Integral

This module starts the curved-spacetime extension of the CAT/EPT measure-theory
path-integral layer by adding:

- a geometric datum with base measure and volume density
- a curved reference measure `dμ_g := ρ_g dμ`
- a curved model that reduces to `MeasurePathIntegralModel`
- flat-limit compatibility lemmas (`ρ_g = 1`).
-/

set_option autoImplicit false

open MeasureTheory

namespace NavierStokesClean.CATEPT

noncomputable section

/-- Geometric measure datum for curved-spacetime integration. -/
structure CurvedSpacetimeDatum (α : Type*) [MeasurableSpace α] where
  baseMeasure : Measure α
  volumeDensity : α → ℝ
  measurable_volumeDensity : Measurable volumeDensity
  volumeDensity_nonneg : ∀ x, 0 ≤ volumeDensity x

namespace CurvedSpacetimeDatum

variable {α : Type*} [MeasurableSpace α] (g : CurvedSpacetimeDatum α)

/-- Curved reference measure `dμ_g = ρ_g dμ` encoded as `withDensity`. -/
def volumeMeasure : Measure α :=
  g.baseMeasure.withDensity (fun x => ENNReal.ofReal (g.volumeDensity x))

/-- `μ_g` is absolutely continuous with respect to the base measure. -/
theorem volumeMeasure_absolutelyContinuous :
    g.volumeMeasure ≪ g.baseMeasure := by
  simpa [volumeMeasure] using
    (withDensity_absolutelyContinuous g.baseMeasure
      (fun x => ENNReal.ofReal (g.volumeDensity x)))

/-- Flat limit (`ρ_g = 1`) recovers the base measure. -/
theorem volumeMeasure_eq_base_of_density_one
    (hρ : g.volumeDensity = fun _ => (1 : ℝ)) :
    g.volumeMeasure = g.baseMeasure := by
  simpa [volumeMeasure, hρ] using (withDensity_one (μ := g.baseMeasure))

end CurvedSpacetimeDatum

/-- Curved-spacetime CAT/EPT model with measure-theory semantics. -/
structure CurvedMeasurePathIntegralModel (α : Type*) [MeasurableSpace α] where
  geom : CurvedSpacetimeDatum α
  hbar : ℝ
  hbar_pos : 0 < hbar
  actionRe : α → ℝ
  actionIm : α → ℝ
  measurable_actionRe : Measurable actionRe
  measurable_actionIm : Measurable actionIm
  actionIm_nonneg : ∀ x, 0 ≤ actionIm x

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (c : CurvedMeasurePathIntegralModel α)

/-- Forgetful map into the existing CAT/EPT MTPI core. -/
def toMeasurePathIntegralModel : MeasurePathIntegralModel α :=
  { μ := c.geom.volumeMeasure
    hbar := c.hbar
    hbar_pos := c.hbar_pos
    actionRe := c.actionRe
    actionIm := c.actionIm
    measurable_actionRe := c.measurable_actionRe
    measurable_actionIm := c.measurable_actionIm
    actionIm_nonneg := c.actionIm_nonneg }

/-- Curved partition functional `Z_g`. -/
def partition : ℂ := (c.toMeasurePathIntegralModel).partition

/-- Curved unnormalized expectation `⟪O⟫_g`. -/
def unnormalizedExpectation (O : α → ℂ) : ℂ :=
  (c.toMeasurePathIntegralModel).unnormalizedExpectation O

/-- Curved normalized expectation `E_g[O]`. -/
def normalizedExpectation (O : α → ℂ) : ℂ :=
  (c.toMeasurePathIntegralModel).normalizedExpectation O

/-- Curved source-coupled partition `Z_g[J]`. -/
def sourceCoupledPartition (J : α → ℂ) : ℂ :=
  (c.toMeasurePathIntegralModel).sourceCoupledPartition J

/-- Curved source-coupled unnormalized expectation `⟪O⟫_{g,J}`. -/
def sourceCoupledUnnormalizedExpectation (J O : α → ℂ) : ℂ :=
  (c.toMeasurePathIntegralModel).sourceCoupledUnnormalizedExpectation J O

/-- Curved source-coupled normalized expectation `E_{g,J}[O]`. -/
def sourceCoupledExpectation (J O : α → ℂ) : ℂ :=
  (c.toMeasurePathIntegralModel).sourceCoupledExpectation J O

/-- Curved connected generating functional `W_g[J] = log Z_g[J]`. -/
def connectedGeneratingFunctional (J : α → ℂ) : ℂ :=
  (c.toMeasurePathIntegralModel).connectedGeneratingFunctional J

/-- Curved `n`-point correlation wrapper. -/
def nPointCorrelation (n : ℕ) (obs : Fin n → α → ℂ) : ℂ :=
  c.normalizedExpectation (MeasurePathIntegralModel.nPointObservable n obs)

/-- Curved one-point correlation wrapper. -/
def onePointCorrelation (O : α → ℂ) : ℂ :=
  c.nPointCorrelation 1 (fun _ => O)

/-- Curved two-point correlation wrapper. -/
def twoPointCorrelation (O1 O2 : α → ℂ) : ℂ :=
  c.nPointCorrelation 2 (fun i => if (i : ℕ) = 0 then O1 else O2)

/-- Zero-source compatibility in curved model. -/
theorem sourceCoupledPartition_zero :
    c.sourceCoupledPartition (fun _ => (0 : ℂ)) = c.partition := by
  unfold sourceCoupledPartition partition
  simpa using (c.toMeasurePathIntegralModel.sourceCoupledPartition_zero)

/-- Zero-source expectation compatibility in curved model. -/
theorem sourceCoupledExpectation_zero (O : α → ℂ) :
    c.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = c.normalizedExpectation O := by
  unfold sourceCoupledExpectation normalizedExpectation
  simpa using (c.toMeasurePathIntegralModel.sourceCoupledExpectation_zero O)

/-- Zero-source connected generating functional compatibility in curved model. -/
theorem connectedGeneratingFunctional_zero :
    c.connectedGeneratingFunctional (fun _ => (0 : ℂ)) = Complex.log c.partition := by
  unfold connectedGeneratingFunctional partition
  simpa using (c.toMeasurePathIntegralModel.connectedGeneratingFunctional_zero)

/-- Flat limit (`ρ_g = 1`) gives the base measure in the reduced model. -/
theorem toMeasurePathIntegralModel_measure_eq_base_of_density_one
    (hρ : c.geom.volumeDensity = fun _ => (1 : ℝ)) :
    (c.toMeasurePathIntegralModel).μ = c.geom.baseMeasure := by
  simpa [toMeasurePathIntegralModel] using
    (c.geom.volumeMeasure_eq_base_of_density_one hρ)

/-- Flat limit (`ρ_g = 1`) rewrites the curved partition over the base measure. -/
theorem partition_eq_base_integral_of_density_one
    (hρ : c.geom.volumeDensity = fun _ => (1 : ℝ)) :
    c.partition = ∫ x, (c.toMeasurePathIntegralModel).weight x ∂c.geom.baseMeasure := by
  unfold partition toMeasurePathIntegralModel
  rw [c.geom.volumeMeasure_eq_base_of_density_one hρ]
  simp [MeasurePathIntegralModel.partition]

/-- Flat limit (`ρ_g = 1`) rewrites `Z_g[J]` over the base measure. -/
theorem sourceCoupledPartition_eq_base_integral_of_density_one
    (J : α → ℂ) (hρ : c.geom.volumeDensity = fun _ => (1 : ℝ)) :
    c.sourceCoupledPartition J =
      ∫ x, (c.toMeasurePathIntegralModel).sourceCoupledWeight J x ∂c.geom.baseMeasure := by
  unfold sourceCoupledPartition toMeasurePathIntegralModel
  rw [c.geom.volumeMeasure_eq_base_of_density_one hρ]
  simp [MeasurePathIntegralModel.sourceCoupledPartition]

/-- Flat limit (`ρ_g = 1`) rewrites `W_g[J]` as base-measure log-partition. -/
theorem connectedGeneratingFunctional_eq_base_log_of_density_one
    (J : α → ℂ) (hρ : c.geom.volumeDensity = fun _ => (1 : ℝ)) :
    c.connectedGeneratingFunctional J =
      Complex.log (∫ x, (c.toMeasurePathIntegralModel).sourceCoupledWeight J x
        ∂c.geom.baseMeasure) := by
  unfold connectedGeneratingFunctional
  simp [MeasurePathIntegralModel.connectedGeneratingFunctional,
    MeasurePathIntegralModel.sourceCoupledPartition,
    toMeasurePathIntegralModel,
    c.geom.volumeMeasure_eq_base_of_density_one hρ]

/-- Curved partition rewritten over the base measure via `withDensity`. -/
theorem partition_eq_base_integral_toReal_density_smul :
    c.partition =
      ∫ x, ((ENNReal.ofReal (c.geom.volumeDensity x)).toReal : ℝ) •
        (c.toMeasurePathIntegralModel).weight x ∂c.geom.baseMeasure := by
  unfold partition toMeasurePathIntegralModel CurvedSpacetimeDatum.volumeMeasure
  simpa using
    (integral_withDensity_eq_integral_toReal_smul
      (μ := c.geom.baseMeasure)
      (f := fun x => ENNReal.ofReal (c.geom.volumeDensity x))
      (f_meas := c.geom.measurable_volumeDensity.ennreal_ofReal)
      (hf_lt_top := Filter.Eventually.of_forall (fun _ => by simp))
      (g := fun x => (c.toMeasurePathIntegralModel).weight x))

/-- Curved source-coupled partition rewritten over the base measure via `withDensity`. -/
theorem sourceCoupledPartition_eq_base_integral_toReal_density_smul (J : α → ℂ) :
    c.sourceCoupledPartition J =
      ∫ x, ((ENNReal.ofReal (c.geom.volumeDensity x)).toReal : ℝ) •
        (c.toMeasurePathIntegralModel).sourceCoupledWeight J x ∂c.geom.baseMeasure := by
  unfold sourceCoupledPartition toMeasurePathIntegralModel CurvedSpacetimeDatum.volumeMeasure
  simpa using
    (integral_withDensity_eq_integral_toReal_smul
      (μ := c.geom.baseMeasure)
      (f := fun x => ENNReal.ofReal (c.geom.volumeDensity x))
      (f_meas := c.geom.measurable_volumeDensity.ennreal_ofReal)
      (hf_lt_top := Filter.Eventually.of_forall (fun _ => by simp))
      (g := fun x => (c.toMeasurePathIntegralModel).sourceCoupledWeight J x))

/-- Since `ρ_g ≥ 0`, the `toReal ∘ ofReal` density factor simplifies to `ρ_g`. -/
theorem density_toReal_ofReal_eq (x : α) :
    ((ENNReal.ofReal (c.geom.volumeDensity x)).toReal : ℝ) = c.geom.volumeDensity x :=
  ENNReal.toReal_ofReal (c.geom.volumeDensity_nonneg x)

/-- Curved partition over base measure with explicit real density factor `ρ_g`. -/
theorem partition_eq_base_integral_density_smul :
    c.partition =
      ∫ x, c.geom.volumeDensity x • (c.toMeasurePathIntegralModel).weight x ∂c.geom.baseMeasure := by
  rw [c.partition_eq_base_integral_toReal_density_smul]
  congr with x
  simp [c.density_toReal_ofReal_eq x]

/-- Curved source-coupled partition over base measure with explicit real density factor `ρ_g`. -/
theorem sourceCoupledPartition_eq_base_integral_density_smul (J : α → ℂ) :
    c.sourceCoupledPartition J =
      ∫ x, c.geom.volumeDensity x •
        (c.toMeasurePathIntegralModel).sourceCoupledWeight J x ∂c.geom.baseMeasure := by
  rw [c.sourceCoupledPartition_eq_base_integral_toReal_density_smul J]
  congr with x
  simp [c.density_toReal_ofReal_eq x]

/-! ### Covariant operator contracts (curved-space upgrade path) -/

/-- Curved-space operator contract bundle for QFT couplings. -/
structure CurvedOperatorStack (α : Type*) [MeasurableSpace α] where
  scalarCurvature : α → ℝ
  measurable_scalarCurvature : Measurable scalarCurvature
  gaugePotential : α → ℂ
  measurable_gaugePotential : Measurable gaugePotential

/-- Imaginary-action coupling to scalar curvature (`S_I + ξ R`). -/
def curvatureCoupledActionIm (ops : CurvedOperatorStack α) (ξ : ℝ) (x : α) : ℝ :=
  c.actionIm x + ξ * ops.scalarCurvature x

theorem measurable_curvatureCoupledActionIm (ops : CurvedOperatorStack α) (ξ : ℝ) :
    Measurable (curvatureCoupledActionIm (c := c) ops ξ) := by
  unfold curvatureCoupledActionIm
  exact c.measurable_actionIm.add ((measurable_const.mul ops.measurable_scalarCurvature))

theorem curvatureCoupledActionIm_nonneg_of_lower_bound
    (ops : CurvedOperatorStack α) (ξ : ℝ)
    (h_lower : ∀ x, -(ξ * ops.scalarCurvature x) ≤ c.actionIm x) :
    ∀ x, 0 ≤ curvatureCoupledActionIm (c := c) ops ξ x := by
  intro x
  unfold curvatureCoupledActionIm
  linarith [h_lower x]

/-- Curvature-coupled curved model (same geometry, modified imaginary action). -/
def toCurvatureCoupledModel (ops : CurvedOperatorStack α) (ξ : ℝ)
    (h_nonneg : ∀ x, 0 ≤ curvatureCoupledActionIm (c := c) ops ξ x) :
    CurvedMeasurePathIntegralModel α :=
  { geom := c.geom
    hbar := c.hbar
    hbar_pos := c.hbar_pos
    actionRe := c.actionRe
    actionIm := curvatureCoupledActionIm (c := c) ops ξ
    measurable_actionRe := c.measurable_actionRe
    measurable_actionIm := measurable_curvatureCoupledActionIm (c := c) ops ξ
    actionIm_nonneg := h_nonneg }

theorem toCurvatureCoupledModel_geom
    (ops : CurvedOperatorStack α) (ξ : ℝ)
    (h_nonneg : ∀ x, 0 ≤ curvatureCoupledActionIm (c := c) ops ξ x) :
    (toCurvatureCoupledModel (c := c) ops ξ h_nonneg).geom = c.geom := rfl

/-- Gauge-shifted source `J + A` for curved gauge coupling. -/
def gaugeShiftedSource (ops : CurvedOperatorStack α) (J : α → ℂ) : α → ℂ :=
  fun x => J x + ops.gaugePotential x

theorem measurable_gaugeShiftedSource (ops : CurvedOperatorStack α)
    (J : α → ℂ) (hJ : Measurable J) :
    Measurable (gaugeShiftedSource ops J) :=
  hJ.add ops.measurable_gaugePotential

/-- Gauge-coupled curved partition `Z_g[J + A]`. -/
def gaugeCoupledPartition (ops : CurvedOperatorStack α) (J : α → ℂ) : ℂ :=
  c.sourceCoupledPartition (gaugeShiftedSource ops J)

/-- If gauge potential vanishes, gauge-coupled partition reduces to the usual source partition. -/
theorem gaugeCoupledPartition_eq_sourceCoupled_of_zeroGauge
    (ops : CurvedOperatorStack α) (J : α → ℂ)
    (hA : ops.gaugePotential = fun _ => (0 : ℂ)) :
    gaugeCoupledPartition (c := c) ops J = c.sourceCoupledPartition J := by
  unfold gaugeCoupledPartition gaugeShiftedSource
  simp [hA]

end CurvedMeasurePathIntegralModel

/-! ## Paper (v3.5.12) curved-spacetime equation label aliases (WP-CSTPI-01) -/

section CurvedPaperAliases

variable {α : Type*} [MeasurableSpace α]

/-- paper4_eq_C01: Curved reference measure dμ_g = ρ_g dμ via withDensity. -/
theorem paper4_eq_C01 (g : CurvedSpacetimeDatum α) :
    g.volumeMeasure = g.baseMeasure.withDensity
      (fun x => ENNReal.ofReal (g.volumeDensity x)) := rfl

/-- paper4_eq_C02: Curved measure is absolutely continuous w.r.t. base measure. -/
theorem paper4_eq_C02 (g : CurvedSpacetimeDatum α) :
    g.volumeMeasure ≪ g.baseMeasure :=
  g.volumeMeasure_absolutelyContinuous

/-- paper4_eq_C03: Flat limit ρ_g = 1 recovers the base measure. -/
theorem paper4_eq_C03 (g : CurvedSpacetimeDatum α) (hρ : g.volumeDensity = fun _ => (1 : ℝ)) :
    g.volumeMeasure = g.baseMeasure :=
  g.volumeMeasure_eq_base_of_density_one hρ

/-- paper4_eq_C04: Curved partition Z_g with explicit density factor ρ_g. -/
theorem paper4_eq_C04 (c : CurvedMeasurePathIntegralModel α) :
    c.partition =
      ∫ x, c.geom.volumeDensity x • (c.toMeasurePathIntegralModel).weight x
        ∂c.geom.baseMeasure :=
  c.partition_eq_base_integral_density_smul

/-- paper4_eq_C05: Source partition Z_g[J] with explicit density factor ρ_g. -/
theorem paper4_eq_C05 (c : CurvedMeasurePathIntegralModel α) (J : α → ℂ) :
    c.sourceCoupledPartition J =
      ∫ x, c.geom.volumeDensity x •
        (c.toMeasurePathIntegralModel).sourceCoupledWeight J x
        ∂c.geom.baseMeasure :=
  c.sourceCoupledPartition_eq_base_integral_density_smul J

/-- paper4_eq_C06: Flat-limit curved partition equals base-measure integral. -/
theorem paper4_eq_C06 (c : CurvedMeasurePathIntegralModel α)
    (hρ : c.geom.volumeDensity = fun _ => (1 : ℝ)) :
    c.partition =
      ∫ x, (c.toMeasurePathIntegralModel).weight x ∂c.geom.baseMeasure :=
  c.partition_eq_base_integral_of_density_one hρ

/-- paper4_eq_C07: Curved connected generating functional W_g[J] = log Z_g[J]. -/
theorem paper4_eq_C07 (c : CurvedMeasurePathIntegralModel α) (J : α → ℂ) :
    c.connectedGeneratingFunctional J = Complex.log (c.sourceCoupledPartition J) := rfl

/-- paper4_eq_C08: Curved zero-source identity Z_g[0] = Z_g. -/
theorem paper4_eq_C08 (c : CurvedMeasurePathIntegralModel α) :
    c.sourceCoupledPartition (fun _ => (0 : ℂ)) = c.partition :=
  c.sourceCoupledPartition_zero

/-- paper4_eq_C09: Curved zero-source expectation E_{g,J=0}[O] = E_g[O]. -/
theorem paper4_eq_C09 (c : CurvedMeasurePathIntegralModel α) (O : α → ℂ) :
    c.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = c.normalizedExpectation O :=
  c.sourceCoupledExpectation_zero O

/-- paper4_eq_C10: Curvature coupling preserves geometry (same geom datum). -/
theorem paper4_eq_C10 (c : CurvedMeasurePathIntegralModel α)
    (ops : CurvedMeasurePathIntegralModel.CurvedOperatorStack α) (ξ : ℝ)
    (h_nonneg : ∀ x,
      0 ≤ CurvedMeasurePathIntegralModel.curvatureCoupledActionIm (c := c) ops ξ x) :
    (CurvedMeasurePathIntegralModel.toCurvatureCoupledModel (c := c) ops ξ h_nonneg).geom =
      c.geom :=
  CurvedMeasurePathIntegralModel.toCurvatureCoupledModel_geom (c := c) ops ξ h_nonneg

/-- paper4_eq_C11: Zero gauge reduces gauge-coupled partition to source partition. -/
theorem paper4_eq_C11 (c : CurvedMeasurePathIntegralModel α)
    (ops : CurvedMeasurePathIntegralModel.CurvedOperatorStack α) (J : α → ℂ)
    (hA : ops.gaugePotential = fun _ => (0 : ℂ)) :
    CurvedMeasurePathIntegralModel.gaugeCoupledPartition (c := c) ops J =
      c.sourceCoupledPartition J :=
  CurvedMeasurePathIntegralModel.gaugeCoupledPartition_eq_sourceCoupled_of_zeroGauge
    (c := c) ops J hA

end CurvedPaperAliases

end

end NavierStokesClean.CATEPT
