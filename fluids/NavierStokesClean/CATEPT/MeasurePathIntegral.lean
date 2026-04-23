import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.MeasureTheory.Function.SpecialFunctions.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import NavierStokesClean.Core.DiscreteIntegral

/-!
# CAT/EPT Measure-Theoretic Path Integral Core

This module upgrades the CAT/EPT path-integral layer to a true `MeasureTheory`
object:

- measurable state space `α` with reference measure `μ`
- measurable complex action split `S = S_R + i S_I`
- complex path weight `exp(i*S_R/ℏ - S_I/ℏ)` as a measurable integrand
- partition functional and observable expectations as Bochner integrals over `ℂ`
- finite-dimensional approximation interface with DCT convergence theorem

The existing `DiscreteKernel.discreteIntegral` stays available as a certified
finite-dimensional quadrature object.
-/

set_option autoImplicit false

open MeasureTheory Complex Filter
open scoped Topology

namespace NavierStokesClean.CATEPT

noncomputable section

/-- Measurable CAT/EPT path-integral model on state space `α`. -/
structure MeasurePathIntegralModel (α : Type*) [MeasurableSpace α] where
  μ : Measure α
  hbar : ℝ
  hbar_pos : 0 < hbar
  actionRe : α → ℝ
  actionIm : α → ℝ
  measurable_actionRe : Measurable actionRe
  measurable_actionIm : Measurable actionIm
  actionIm_nonneg : ∀ x, 0 ≤ actionIm x

namespace MeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (m : MeasurePathIntegralModel α)

/-- Scaled real action `S_R / ℏ`. -/
def actionReScaled (x : α) : ℝ := m.actionRe x / m.hbar

/-- Scaled imaginary action `S_I / ℏ`. -/
def actionImScaled (x : α) : ℝ := m.actionIm x / m.hbar

/-- Oscillatory phase factor `exp(i*S_R/ℏ)`. -/
def phase (x : α) : ℂ :=
  Complex.exp (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)

/-- Damping factor `exp(-S_I/ℏ)` on the real side. -/
def damping (x : α) : ℝ :=
  Real.exp (-(m.actionImScaled x))

/-- Full complex CAT/EPT path weight `exp(i*S_R/ℏ - S_I/ℏ)`. -/
def weight (x : α) : ℂ :=
  Complex.exp
    ((-(m.actionImScaled x) : ℂ) +
      (((m.actionReScaled x : ℝ) : ℂ) * Complex.I))

theorem measurable_phase : Measurable m.phase := by
  unfold phase
  have hReReal : Measurable m.actionReScaled := by
    unfold actionReScaled
    exact m.measurable_actionRe.div_const m.hbar
  have hRe : Measurable (fun x => ((m.actionReScaled x : ℝ) : ℂ)) :=
    Complex.measurable_ofReal.comp hReReal
  exact Complex.measurable_exp.comp (hRe.mul_const Complex.I)

theorem measurable_damping : Measurable m.damping := by
  unfold damping
  have hImReal : Measurable m.actionImScaled := by
    unfold actionImScaled
    exact m.measurable_actionIm.div_const m.hbar
  exact Real.measurable_exp.comp hImReal.neg

theorem measurable_weight : Measurable m.weight := by
  unfold weight
  have hImReal : Measurable m.actionImScaled := by
    unfold actionImScaled
    exact m.measurable_actionIm.div_const m.hbar
  have hReReal : Measurable m.actionReScaled := by
    unfold actionReScaled
    exact m.measurable_actionRe.div_const m.hbar
  have hRe : Measurable (fun x => -((m.actionImScaled x : ℝ) : ℂ)) :=
    (Complex.measurable_ofReal.comp hImReal).neg
  have hIm : Measurable (fun x => ((m.actionReScaled x : ℝ) : ℂ) * Complex.I) :=
    (Complex.measurable_ofReal.comp hReReal).mul_const Complex.I
  exact Complex.measurable_exp.comp (hRe.add hIm)

theorem norm_weight_eq_damping (x : α) :
    ‖m.weight x‖ = m.damping x := by
  unfold weight damping
  rw [Complex.norm_exp]
  simp

/-- CAT/EPT damping controls the path weight norm: `‖weight‖ ≤ 1`. -/
theorem norm_weight_le_one (x : α) : ‖m.weight x‖ ≤ 1 := by
  rw [m.norm_weight_eq_damping]
  calc
    Real.exp (-(m.actionImScaled x))
      ≤ Real.exp 0 := by
        apply Real.exp_le_exp.mpr
        exact neg_nonpos.mpr
          (div_nonneg (m.actionIm_nonneg x) (le_of_lt m.hbar_pos))
    _ = 1 := by simp

/-- Under a finite reference measure, the CAT/EPT path weight is integrable. -/
theorem integrable_weight_of_isFiniteMeasure [IsFiniteMeasure m.μ] :
    Integrable m.weight m.μ := by
  refine Integrable.mono' (integrable_const (μ := m.μ) (1 : ℝ))
    m.measurable_weight.aestronglyMeasurable ?_
  exact Filter.Eventually.of_forall m.norm_weight_le_one

/-- Under a finite reference measure, the damping profile is integrable. -/
theorem integrable_damping_of_isFiniteMeasure [IsFiniteMeasure m.μ] :
    Integrable m.damping m.μ := by
  refine Integrable.mono' (integrable_const (μ := m.μ) (1 : ℝ))
    m.measurable_damping.aestronglyMeasurable ?_
  refine Filter.Eventually.of_forall ?_
  intro x
  have hnonneg : 0 ≤ m.damping x := by
    unfold damping
    exact le_of_lt (Real.exp_pos _)
  calc
    ‖m.damping x‖ = m.damping x := by rw [Real.norm_eq_abs, abs_of_nonneg hnonneg]
    _ ≤ 1 := by simpa [m.norm_weight_eq_damping x] using (m.norm_weight_le_one x)

/-- Partition functional `Z = ∫ exp(i*S_R/ℏ - S_I/ℏ) dμ`. -/
def partition : ℂ :=
  ∫ x, m.weight x ∂m.μ

/-- Unnormalized observable expectation `⟪O⟫ = ∫ weight * O dμ`. -/
def unnormalizedExpectation (O : α → ℂ) : ℂ :=
  ∫ x, m.weight x * O x ∂m.μ

/-- Normalized expectation `E[O] = ⟪O⟫ / Z` (when `Z ≠ 0`). -/
def normalizedExpectation (O : α → ℂ) : ℂ :=
  m.unnormalizedExpectation O / m.partition

/-- Finite-measure a priori bound on the partition functional. -/
theorem norm_partition_le_measure_univ_toReal [IsFiniteMeasure m.μ] :
    ‖m.partition‖ ≤ (m.μ Set.univ).toReal := by
  unfold partition
  have hnorm_int : Integrable (fun x => ‖m.weight x‖) m.μ :=
    (m.integrable_weight_of_isFiniteMeasure.norm)
  have hconst_int : Integrable (fun _x : α => (1 : ℝ)) m.μ :=
    integrable_const 1
  calc
    ‖∫ x, m.weight x ∂m.μ‖ ≤ ∫ x, ‖m.weight x‖ ∂m.μ := by
      exact norm_integral_le_integral_norm (f := fun x => m.weight x)
    _ ≤ ∫ _x, (1 : ℝ) ∂m.μ := by
      refine integral_mono_ae hnorm_int hconst_int ?_
      exact Filter.Eventually.of_forall m.norm_weight_le_one
    _ = (m.μ Set.univ).toReal := by
      simp [Measure.real_def]

/-- Bounded observables are integrable against CAT/EPT weight on finite reference measure. -/
theorem integrable_weight_mul_of_bound [IsFiniteMeasure m.μ] (O : α → ℂ)
    (hO_meas : AEStronglyMeasurable O m.μ)
    {C : ℝ} (hO_bound : ∀ᵐ x ∂m.μ, ‖O x‖ ≤ C) :
    Integrable (fun x => m.weight x * O x) m.μ := by
  refine Integrable.mono' (integrable_const (μ := m.μ) C)
    ((m.measurable_weight.aestronglyMeasurable).mul hO_meas) ?_
  filter_upwards [Filter.Eventually.of_forall m.norm_weight_le_one, hO_bound] with x hxW hxO
  have hmul :
      ‖m.weight x‖ * ‖O x‖ ≤ ‖O x‖ := by
    calc
      ‖m.weight x‖ * ‖O x‖ ≤ 1 * ‖O x‖ :=
        mul_le_mul_of_nonneg_right hxW (norm_nonneg (O x))
      _ = ‖O x‖ := by simp
  calc
    ‖m.weight x * O x‖ = ‖m.weight x‖ * ‖O x‖ := by simp
    _ ≤ ‖O x‖ := hmul
    _ ≤ C := hxO

/-- On finite reference measure, bounded observables admit a well-defined unnormalized expectation. -/
theorem unnormalizedExpectation_integrable_of_bound [IsFiniteMeasure m.μ] (O : α → ℂ)
    (hO_meas : AEStronglyMeasurable O m.μ)
    {C : ℝ} (hO_bound : ∀ᵐ x ∂m.μ, ‖O x‖ ≤ C) :
    Integrable (fun x => m.weight x * O x) m.μ :=
  m.integrable_weight_mul_of_bound O hO_meas hO_bound

/-- Algebraic normalization identity (`Z ≠ 0`): `E[O] * Z = ⟪O⟫`. -/
theorem normalizedExpectation_mul_partition (O : α → ℂ) (hZ : m.partition ≠ 0) :
    m.normalizedExpectation O * m.partition = m.unnormalizedExpectation O := by
  unfold normalizedExpectation
  field_simp [hZ]

theorem unnormalizedExpectation_add (O1 O2 : α → ℂ)
    (h1 : Integrable (fun x => m.weight x * O1 x) m.μ)
    (h2 : Integrable (fun x => m.weight x * O2 x) m.μ) :
    m.unnormalizedExpectation (fun x => O1 x + O2 x) =
      m.unnormalizedExpectation O1 + m.unnormalizedExpectation O2 := by
  unfold unnormalizedExpectation
  calc
    ∫ x, m.weight x * (O1 x + O2 x) ∂m.μ
      = ∫ x, (m.weight x * O1 x) + (m.weight x * O2 x) ∂m.μ := by
          congr with x
          simp [mul_add]
    _ = (∫ x, m.weight x * O1 x ∂m.μ) + (∫ x, m.weight x * O2 x ∂m.μ) :=
          integral_add h1 h2

theorem unnormalizedExpectation_const_mul (c : ℂ) (O : α → ℂ) :
    m.unnormalizedExpectation (fun x => c * O x) =
      c * m.unnormalizedExpectation O := by
  unfold unnormalizedExpectation
  calc
    ∫ x, m.weight x * (c * O x) ∂m.μ
      = ∫ x, c * (m.weight x * O x) ∂m.μ := by
          congr with x
          simp [mul_assoc, mul_comm]
    _ = c * ∫ x, m.weight x * O x ∂m.μ := by
          simpa using integral_const_mul c (fun x => m.weight x * O x)

/-! ## QFT observables and generating functional -/

/-- Source-coupled CAT/EPT weight `weight * exp(J)`. -/
def sourceCoupledWeight (J : α → ℂ) (x : α) : ℂ :=
  m.weight x * Complex.exp (J x)

/-- Source-coupled partition functional `Z[J]`. -/
def sourceCoupledPartition (J : α → ℂ) : ℂ :=
  ∫ x, m.sourceCoupledWeight J x ∂m.μ

/-- Source-coupled unnormalized expectation `⟪O⟫_J`. -/
def sourceCoupledUnnormalizedExpectation (J O : α → ℂ) : ℂ :=
  ∫ x, m.sourceCoupledWeight J x * O x ∂m.μ

/-- Source-coupled normalized expectation `E_J[O]`. -/
def sourceCoupledExpectation (J O : α → ℂ) : ℂ :=
  m.sourceCoupledUnnormalizedExpectation J O / m.sourceCoupledPartition J

/-- Connected generating functional `W[J] = log Z[J]`. -/
def connectedGeneratingFunctional (J : α → ℂ) : ℂ :=
  Complex.log (m.sourceCoupledPartition J)

/-- Compatibility at zero source: `Z[0] = Z`. -/
theorem sourceCoupledPartition_zero :
    m.sourceCoupledPartition (fun _ => (0 : ℂ)) = m.partition := by
  unfold sourceCoupledPartition sourceCoupledWeight partition
  congr with x
  simp

/-- Compatibility at zero source: source-coupled expectation reduces to base expectation. -/
theorem sourceCoupledExpectation_zero (O : α → ℂ) :
    m.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = m.normalizedExpectation O := by
  unfold sourceCoupledExpectation normalizedExpectation
  rw [m.sourceCoupledPartition_zero]
  unfold sourceCoupledUnnormalizedExpectation unnormalizedExpectation sourceCoupledWeight
  simp

/-- Source-coupled partition is an unnormalized expectation of `exp(J)`. -/
theorem sourceCoupledPartition_eq_unnormalizedExpectation_exp (J : α → ℂ) :
    m.sourceCoupledPartition J =
      m.unnormalizedExpectation (fun x => Complex.exp (J x)) := by
  rfl

/-- `n`-point observable as product of insertions over `Fin n`. -/
def nPointObservable (n : ℕ) (obs : Fin n → α → ℂ) : α → ℂ :=
  fun x => ∏ i : Fin n, obs i x

/-- `n`-point correlation as normalized CAT/EPT expectation. -/
def nPointCorrelation (n : ℕ) (obs : Fin n → α → ℂ) : ℂ :=
  m.normalizedExpectation (nPointObservable n obs)

/-- One-point function. -/
def onePointCorrelation (O : α → ℂ) : ℂ :=
  m.nPointCorrelation 1 (fun _ => O)

/-- Two-point function. -/
def twoPointCorrelation (O1 O2 : α → ℂ) : ℂ :=
  m.nPointCorrelation 2 (fun i => if (i : ℕ) = 0 then O1 else O2)

/-- At zero source, connected generating functional matches `log Z`. -/
theorem connectedGeneratingFunctional_zero :
    m.connectedGeneratingFunctional (fun _ => (0 : ℂ)) = Complex.log m.partition := by
  unfold connectedGeneratingFunctional
  rw [m.sourceCoupledPartition_zero]

/-- Finite-dimensional approximation data for dominated-convergence passage. -/
structure FiniteDimApproximation where
  approx : ℕ → α → ℂ
  limit : α → ℂ
  bound : α → ℝ
  approx_aestronglyMeasurable : ∀ n, AEStronglyMeasurable (approx n) m.μ
  bound_integrable : Integrable bound m.μ
  dominated : ∀ n, ∀ᵐ x ∂m.μ, ‖m.weight x * approx n x‖ ≤ bound x
  pointwise_tendsto :
    ∀ᵐ x ∂m.μ, Tendsto (fun n => m.weight x * approx n x) atTop (𝓝 (m.weight x * limit x))

/-- Dominated-convergence transfer for CAT/EPT finite-dimensional approximants. -/
theorem finiteDimApproximation_tendsto (A : m.FiniteDimApproximation) :
    Tendsto (fun n => m.unnormalizedExpectation (A.approx n)) atTop
      (𝓝 (m.unnormalizedExpectation A.limit)) := by
  unfold unnormalizedExpectation
  exact MeasureTheory.tendsto_integral_of_dominated_convergence A.bound
    (fun n => (m.measurable_weight.aestronglyMeasurable.mul (A.approx_aestronglyMeasurable n)))
    A.bound_integrable A.dominated A.pointwise_tendsto

end MeasurePathIntegralModel

/-! ## Discrete-kernel compatibility anchor -/

open NavierStokesClean.DiscreteKernel

/-- The existing Rat discrete kernel is a finite quadrature sum (left Riemann form). -/
theorem discreteKernel_quadrature_form (f : Rat → Rat) (T : Rat) :
    discreteIntegral f T =
      (Finset.range (diSteps T)).sum (fun i => f ((i : Rat) * diH) * diH) := rfl

/-! ## Paper (v3.5.12) equation label aliases (WP-MTPI-01) -/

section PaperAliases

variable {α : Type*} [MeasurableSpace α]

/-- paper4_eq_01: CAT/EPT partition functional Z = ∫ exp(iS_R/ℏ − S_I/ℏ) dμ. -/
theorem paper4_eq_01 (m : MeasurePathIntegralModel α) :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

/-- paper4_eq_02: Path weight satisfies damping bound ‖w(x)‖ ≤ 1. -/
theorem paper4_eq_02 (m : MeasurePathIntegralModel α) (x : α) :
    ‖m.weight x‖ ≤ 1 := m.norm_weight_le_one x

/-- paper4_eq_03: On finite reference measure, the path weight is integrable. -/
theorem paper4_eq_03 (m : MeasurePathIntegralModel α) [IsFiniteMeasure m.μ] :
    Integrable m.weight m.μ := m.integrable_weight_of_isFiniteMeasure

/-- paper4_eq_04: A priori partition bound ‖Z‖ ≤ μ(Ω). -/
theorem paper4_eq_04 (m : MeasurePathIntegralModel α) [IsFiniteMeasure m.μ] :
    ‖m.partition‖ ≤ (m.μ Set.univ).toReal :=
  m.norm_partition_le_measure_univ_toReal

/-- paper4_eq_05: Unnormalized expectation ⟪O⟫ = ∫ weight · O dμ. -/
theorem paper4_eq_05 (m : MeasurePathIntegralModel α) (O : α → ℂ) :
    m.unnormalizedExpectation O = ∫ x, m.weight x * O x ∂m.μ := rfl

/-- paper4_eq_06: Normalized expectation E[O] = ⟪O⟫ / Z. -/
theorem paper4_eq_06 (m : MeasurePathIntegralModel α) (O : α → ℂ) :
    m.normalizedExpectation O = m.unnormalizedExpectation O / m.partition := rfl

/-- paper4_eq_07: Source-coupled partition Z[J] = ⟪exp(J)⟫. -/
theorem paper4_eq_07 (m : MeasurePathIntegralModel α) (J : α → ℂ) :
    m.sourceCoupledPartition J =
      m.unnormalizedExpectation (fun x => Complex.exp (J x)) :=
  m.sourceCoupledPartition_eq_unnormalizedExpectation_exp J

/-- paper4_eq_08: Connected generating functional W[J] = log Z[J]. -/
theorem paper4_eq_08 (m : MeasurePathIntegralModel α) (J : α → ℂ) :
    m.connectedGeneratingFunctional J = Complex.log (m.sourceCoupledPartition J) := rfl

/-- paper4_eq_09: Zero-source identity Z[0] = Z. -/
theorem paper4_eq_09 (m : MeasurePathIntegralModel α) :
    m.sourceCoupledPartition (fun _ => (0 : ℂ)) = m.partition :=
  m.sourceCoupledPartition_zero

/-- paper4_eq_10: Zero-source expectation E_{J=0}[O] = E[O]. -/
theorem paper4_eq_10 (m : MeasurePathIntegralModel α) (O : α → ℂ) :
    m.sourceCoupledExpectation (fun _ => (0 : ℂ)) O = m.normalizedExpectation O :=
  m.sourceCoupledExpectation_zero O

/-- paper4_eq_11: n-point correlation via normalized expectation of product observable. -/
theorem paper4_eq_11 (m : MeasurePathIntegralModel α) (n : ℕ) (obs : Fin n → α → ℂ) :
    m.nPointCorrelation n obs =
      m.normalizedExpectation (MeasurePathIntegralModel.nPointObservable n obs) := rfl

/-- paper4_eq_12: Finite-dimensional approximants converge to exact PI by DCT. -/
theorem paper4_eq_12 (m : MeasurePathIntegralModel α) (A : m.FiniteDimApproximation) :
    Filter.Tendsto (fun n => m.unnormalizedExpectation (A.approx n)) Filter.atTop
      (nhds (m.unnormalizedExpectation A.limit)) :=
  m.finiteDimApproximation_tendsto A

end PaperAliases

/-! ## 0D Gaussian anchor (WP-0DG-01) -/

/-- 0D Gaussian model: single-point state space with trivial (zero) action.
    The 0D path integral Z₀ = ∫_pt exp(0) formalizes the vacuum (no-field) sector. -/
def gaussian0DModel (hbar : ℝ) (hbar_pos : 0 < hbar) :
    MeasurePathIntegralModel Unit :=
  { μ               := Measure.count
    hbar            := hbar
    hbar_pos        := hbar_pos
    actionRe        := fun _ => 0
    actionIm        := fun _ => 0
    measurable_actionRe := measurable_const
    measurable_actionIm := measurable_const
    actionIm_nonneg := fun _ => le_refl 0 }

/-- The 0D Gaussian path weight equals 1 (trivial action → no damping, no phase). -/
theorem gaussian0DModel_weight_eq_one (hbar : ℝ) (hbar_pos : 0 < hbar) (x : Unit) :
    (gaussian0DModel hbar hbar_pos).weight x = 1 := by
  simp [gaussian0DModel, MeasurePathIntegralModel.weight,
        MeasurePathIntegralModel.actionReScaled, MeasurePathIntegralModel.actionImScaled,
        zero_div]

/-- paper4_eq_0D_gauss: 0D Gaussian weight saturates the unit bound (‖w‖ = 1). -/
theorem paper4_eq_0D_gauss_weight_saturates (hbar : ℝ) (hbar_pos : 0 < hbar) (x : Unit) :
    ‖(gaussian0DModel hbar hbar_pos).weight x‖ = 1 := by
  rw [gaussian0DModel_weight_eq_one hbar hbar_pos x]; simp

/-! ## Discrete heat-kernel anchor (WP-HTKER-01) -/

/-- Discrete n-mode heat-kernel model with Euclidean action S_I(k) = λ(k) · t.
    The path weight w(k) = exp(−λ(k) · t / ℏ) models the finite-mode lattice
    approximation to the 4D heat kernel K(0, 0; t) = Tr[exp(−tΔ)]. -/
def heatKernelModel (n : ℕ) (eigenvalue : Fin n → ℝ)
    (eigenvalue_nonneg : ∀ k, 0 ≤ eigenvalue k)
    (t : ℝ) (ht : 0 < t)
    (hbar : ℝ) (hbar_pos : 0 < hbar) :
    MeasurePathIntegralModel (Fin n) :=
  { μ               := Measure.count
    hbar            := hbar
    hbar_pos        := hbar_pos
    actionRe        := fun _ => 0
    actionIm        := fun k => eigenvalue k * t
    measurable_actionRe := measurable_const
    measurable_actionIm := (measurable_of_finite eigenvalue).mul_const t
    actionIm_nonneg := fun k => mul_nonneg (eigenvalue_nonneg k) (le_of_lt ht) }

/-- Heat-kernel path weight satisfies the damping bound ‖w(k)‖ ≤ 1 for all modes. -/
theorem heatKernelModel_weight_le_one (n : ℕ) (eigenvalue : Fin n → ℝ)
    (eigenvalue_nonneg : ∀ k, 0 ≤ eigenvalue k)
    (t : ℝ) (ht : 0 < t) (hbar : ℝ) (hbar_pos : 0 < hbar) (k : Fin n) :
    ‖(heatKernelModel n eigenvalue eigenvalue_nonneg t ht hbar hbar_pos).weight k‖ ≤ 1 :=
  (heatKernelModel n eigenvalue eigenvalue_nonneg t ht hbar hbar_pos).norm_weight_le_one k

/-- paper4_eq_4D_heatkernel: Heat-kernel weight is damped for every mode. -/
theorem paper4_eq_4D_heatkernel_weight_bound (n : ℕ) (eigenvalue : Fin n → ℝ)
    (eigenvalue_nonneg : ∀ k, 0 ≤ eigenvalue k)
    (t : ℝ) (ht : 0 < t) (hbar : ℝ) (hbar_pos : 0 < hbar) (k : Fin n) :
    ‖(heatKernelModel n eigenvalue eigenvalue_nonneg t ht hbar hbar_pos).weight k‖ ≤ 1 :=
  heatKernelModel_weight_le_one n eigenvalue eigenvalue_nonneg t ht hbar hbar_pos k

/-- Initial unresolved EqBlock tranche routed to the measure path-integral layer
from the Weyl/Dirac extraction index. -/
structure WeylMeasurePathIntegralUnresolvedWitness where
  formalMeasureProduct : Prop
  alphaDivergenceLocalizationRule : Prop
  amplitudeMeasurePathForm : Prop
  catWeightedAmplitudeForm : Prop
  quantumActionDensityDefinition : Prop
  quantumPotentialStressChain : Prop
  eq47_formal_measure_product : formalMeasureProduct
  eq53_alpha_divergence_localization_rule : alphaDivergenceLocalizationRule
  eq54_amplitude_measure_path_form : amplitudeMeasurePathForm
  eq56_cat_weighted_amplitude_form : catWeightedAmplitudeForm
  eq106_quantum_action_density_definition : quantumActionDensityDefinition
  eq114_quantum_potential_stress_chain : quantumPotentialStressChain

namespace WeylMeasurePathIntegralUnresolvedWitness

theorem weyl_eqblock_47_measure_path_integral_layer
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) :
    m.partition = ∫ x, m.weight x ∂m.μ := by
  rfl

theorem weyl_eqblock_53_measure_path_integral_layer
    (W : WeylMeasurePathIntegralUnresolvedWitness) :
    W.alphaDivergenceLocalizationRule := by
  exact W.eq53_alpha_divergence_localization_rule

theorem weyl_eqblock_54_measure_path_integral_layer
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := by
  rfl

theorem weyl_eqblock_56_measure_path_integral_layer
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (x : α) :
    ‖m.weight x‖ = m.damping x := by
  simpa using m.norm_weight_eq_damping x

theorem weyl_eqblock_106_measure_path_integral_layer
    (W : WeylMeasurePathIntegralUnresolvedWitness) :
    W.quantumActionDensityDefinition := by
  exact W.eq106_quantum_action_density_definition
theorem weyl_eqblock_114_measure_path_integral_layer
    (W : WeylMeasurePathIntegralUnresolvedWitness) :
    W.quantumPotentialStressChain := by
  exact W.eq114_quantum_potential_stress_chain

end WeylMeasurePathIntegralUnresolvedWitness

/-- Asymptotic-charge unresolved bridge rows routed to the measure-layer file
from the extraction index. -/
structure WeylAsymptoticChargeWitness where
  futureNullInfinityCharge : Prop
  pastNullInfinityCharge : Prop
  eq148_future_null_infinity_charge : futureNullInfinityCharge
  eq149_past_null_infinity_charge : pastNullInfinityCharge

namespace WeylAsymptoticChargeWitness

variable (W : WeylAsymptoticChargeWitness)

theorem weyl_eqblock_148_measure_path_integral_layer : W.futureNullInfinityCharge := by
  exact W.eq148_future_null_infinity_charge
theorem weyl_eqblock_149_measure_path_integral_layer : W.pastNullInfinityCharge := by
  exact W.eq149_past_null_infinity_charge

end WeylAsymptoticChargeWitness

/-- Detailed asymptotic/horizon charge identities routed to the measure-layer
target in the unresolved extraction index. -/
structure WeylAsymptoticChargeDetailWitness where
  futureNullInfinityChargeDecomposition : Prop
  horizonChargeDefinition : Prop
  horizonChargeDecomposition : Prop
  vacuumSoftHairExcitation : Prop
  horizonSoftHairExcitation : Prop
  horizonFluxHarmonicProjection : Prop
  futurePastChargePairRepeat : Prop
  horizonChargeDefinitionRepeat : Prop
  eq151_future_null_infinity_charge_decomposition : futureNullInfinityChargeDecomposition
  eq153_horizon_charge_definition : horizonChargeDefinition
  eq154_horizon_charge_decomposition : horizonChargeDecomposition
  eq156_vacuum_soft_hair_excitation : vacuumSoftHairExcitation
  eq157_horizon_soft_hair_excitation : horizonSoftHairExcitation
  eq162_horizon_flux_harmonic_projection : horizonFluxHarmonicProjection
  eq163_future_past_charge_pair_repeat : futurePastChargePairRepeat
  eq165_horizon_charge_definition_repeat : horizonChargeDefinitionRepeat

namespace WeylAsymptoticChargeDetailWitness

variable (W : WeylAsymptoticChargeDetailWitness)

theorem weyl_eqblock_151_measure_path_integral_layer : W.futureNullInfinityChargeDecomposition := by
  exact W.eq151_future_null_infinity_charge_decomposition
theorem weyl_eqblock_153_measure_path_integral_layer : W.horizonChargeDefinition := by
  exact W.eq153_horizon_charge_definition
theorem weyl_eqblock_154_measure_path_integral_layer : W.horizonChargeDecomposition := by
  exact W.eq154_horizon_charge_decomposition
theorem weyl_eqblock_156_measure_path_integral_layer : W.vacuumSoftHairExcitation := by
  exact W.eq156_vacuum_soft_hair_excitation
theorem weyl_eqblock_157_measure_path_integral_layer : W.horizonSoftHairExcitation := by
  exact W.eq157_horizon_soft_hair_excitation
theorem weyl_eqblock_162_measure_path_integral_layer : W.horizonFluxHarmonicProjection := by
  exact W.eq162_horizon_flux_harmonic_projection
theorem weyl_eqblock_163_measure_path_integral_layer : W.futurePastChargePairRepeat := by
  exact W.eq163_future_past_charge_pair_repeat
theorem weyl_eqblock_165_measure_path_integral_layer : W.horizonChargeDefinitionRepeat := by
  exact W.eq165_horizon_charge_definition_repeat

end WeylAsymptoticChargeDetailWitness

/-- Single-row carryover from the unresolved index routed to the measure-layer
file in the 168..187 cluster. -/
structure WeylHarmonicFluxWitness where
  horizonFluxHarmonicProjectionRepeat : Prop
  eq169_horizon_flux_harmonic_projection_repeat : horizonFluxHarmonicProjectionRepeat

namespace WeylHarmonicFluxWitness

variable (W : WeylHarmonicFluxWitness)

theorem weyl_eqblock_169_measure_path_integral_layer : W.horizonFluxHarmonicProjectionRepeat := by
  exact W.eq169_horizon_flux_harmonic_projection_repeat

end WeylHarmonicFluxWitness

/-- Energy-measure and action-energy relation rows routed to the measure-layer
target in the unresolved index. -/
structure WeylEnergyMeasureWitness where
  energyMeasureDefinition : Prop
  realActionEnergyIntegralAsymptotic : Prop
  realActionEnergyIntegralDefinition : Prop
  eq220_energy_measure_definition : energyMeasureDefinition
  eq223_real_action_energy_integral_asymptotic : realActionEnergyIntegralAsymptotic
  eq228_real_action_energy_integral_definition : realActionEnergyIntegralDefinition

namespace WeylEnergyMeasureWitness

variable (W : WeylEnergyMeasureWitness)

theorem weyl_eqblock_220_measure_path_integral_layer : W.energyMeasureDefinition := by
  exact W.eq220_energy_measure_definition
theorem weyl_eqblock_223_measure_path_integral_layer : W.realActionEnergyIntegralAsymptotic := by
  exact W.eq223_real_action_energy_integral_asymptotic
theorem weyl_eqblock_228_measure_path_integral_layer : W.realActionEnergyIntegralDefinition := by
  exact W.eq228_real_action_energy_integral_definition

end WeylEnergyMeasureWitness

/-- Branch-local action split rows routed to the measure-layer target in the
unresolved extraction index. -/
structure WeylBranchActionSplitWitness where
  complexActionEnergyInformationSplit : Prop
  branchwiseActionSplit : Prop
  eq232_complex_action_energy_information_split : complexActionEnergyInformationSplit
  eq247_branchwise_action_split : branchwiseActionSplit

namespace WeylBranchActionSplitWitness

variable (W : WeylBranchActionSplitWitness)

theorem weyl_eqblock_232_measure_path_integral_layer : W.complexActionEnergyInformationSplit := by
  exact W.eq232_complex_action_energy_information_split
theorem weyl_eqblock_247_measure_path_integral_layer : W.branchwiseActionSplit := by
  exact W.eq247_branchwise_action_split

end WeylBranchActionSplitWitness

/-- Branch-amplitude rows routed to the measure-layer target in the unresolved
index (EqBlocks 252, 264, 282). -/
structure WeylBranchAmplitudeWitness where
  globalStateSuperpositionWithEntropicWeight : Prop
  branchActionSplitRepeat : Prop
  branchWavefunctionAmplitudeForm : Prop
  eq252_global_state_superposition_with_entropic_weight : globalStateSuperpositionWithEntropicWeight
  eq264_branch_action_split_repeat : branchActionSplitRepeat
  eq282_branch_wavefunction_amplitude_form : branchWavefunctionAmplitudeForm

namespace WeylBranchAmplitudeWitness

variable (W : WeylBranchAmplitudeWitness)

theorem weyl_eqblock_252_measure_path_integral_layer : W.globalStateSuperpositionWithEntropicWeight := by
  exact W.eq252_global_state_superposition_with_entropic_weight
theorem weyl_eqblock_264_measure_path_integral_layer : W.branchActionSplitRepeat := by
  exact W.eq264_branch_action_split_repeat
theorem weyl_eqblock_282_measure_path_integral_layer : W.branchWavefunctionAmplitudeForm := by
  exact W.eq282_branch_wavefunction_amplitude_form

end WeylBranchAmplitudeWitness

/-- Hopf-invariant charge row routed to measure-layer target in unresolved
index. -/
structure WeylHopfChargeWitness where
  hopfInvariantChargeFormula : Prop
  eq531_hopf_invariant_charge_formula : hopfInvariantChargeFormula

namespace WeylHopfChargeWitness

variable (W : WeylHopfChargeWitness)

theorem weyl_eqblock_531_measure_path_integral_layer : W.hopfInvariantChargeFormula := by
  exact W.eq531_hopf_invariant_charge_formula

end WeylHopfChargeWitness

end

end NavierStokesClean.CATEPT
