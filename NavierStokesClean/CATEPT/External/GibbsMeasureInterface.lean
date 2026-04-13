import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.ENNReal.Basic
import Mathlib.Analysis.SpecialFunctions.Exp

/-!
# CATEPT External Interface: GibbsMeasure Layer

Opt-in contract layer for leveraging Gibbs-specification formalization results
without importing the external `GibbsMeasure` repository directly.

Reference alignment points in the external project include:
- `GibbsMeasure/Specification.lean`
- `GibbsMeasure/KolmogorovExtension4/ProductMeasure.lean`
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- Certificate exposing a DLR/Gibbs-specification contract surface usable by
CAT/EPT theorem bridges. -/
structure GibbsMeasureCertificate where
  Site : Type*
  Config : Type*
  specificationKernelWeight : Finset Site → Config → Config → ENNReal
  specificationKernelWeight_nonneg :
    ∀ Λ : Finset Site, ∀ η ξ : Config, 0 ≤ specificationKernelWeight Λ η ξ
  energy : Config → ℝ
  inverseTemperature : ℝ
  gibbsWeight : Config → ℝ
  partitionFunction : ℝ
  partitionFunction_pos : 0 < partitionFunction
  gibbsWeight_nonneg : ∀ ξ : Config, 0 ≤ gibbsWeight ξ
  gibbsWeight_formula :
    ∀ ξ : Config, gibbsWeight ξ = Real.exp (-inverseTemperature * energy ξ)
  normalizedDensity : Config → ℝ
  normalizedDensity_def :
    ∀ ξ : Config, normalizedDensity ξ = gibbsWeight ξ / partitionFunction
  normalizedDensity_nonneg : ∀ ξ : Config, 0 ≤ normalizedDensity ξ
  specificationKernel_dominatedByGibbsWeight :
    ∀ Λ : Finset Site, ∀ η ξ : Config,
      specificationKernelWeight Λ η ξ ≤ ENNReal.ofReal (gibbsWeight ξ)
  hasSpecification : Prop
  specificationConsistent : Prop
  specificationProper : Prop
  specificationMarkov : Prop
  hasConditionalExpectationCharacterization : Prop
  gibbsMeasureExists : Prop
  productMeasureIsGibbs : Prop
  hasModifierCalculus : Prop
  hasSpecification_holds : hasSpecification
  specificationConsistent_holds : specificationConsistent
  specificationProper_holds : specificationProper
  specificationMarkov_holds : specificationMarkov
  hasConditionalExpectationCharacterization_holds :
    hasConditionalExpectationCharacterization
  gibbsMeasureExists_holds : gibbsMeasureExists
  productMeasureIsGibbs_holds : productMeasureIsGibbs
  hasModifierCalculus_holds : hasModifierCalculus

theorem GibbsMeasureCertificate.has_specification
    (w : GibbsMeasureCertificate) : w.hasSpecification :=
  w.hasSpecification_holds

theorem GibbsMeasureCertificate.consistent_specification
    (w : GibbsMeasureCertificate) : w.specificationConsistent :=
  w.specificationConsistent_holds

theorem GibbsMeasureCertificate.proper_specification
    (w : GibbsMeasureCertificate) : w.specificationProper :=
  w.specificationProper_holds

theorem GibbsMeasureCertificate.markov_specification
    (w : GibbsMeasureCertificate) : w.specificationMarkov :=
  w.specificationMarkov_holds

theorem GibbsMeasureCertificate.has_condExp_characterization
    (w : GibbsMeasureCertificate) :
    w.hasConditionalExpectationCharacterization :=
  w.hasConditionalExpectationCharacterization_holds

theorem GibbsMeasureCertificate.gibbs_measure_exists
    (w : GibbsMeasureCertificate) : w.gibbsMeasureExists :=
  w.gibbsMeasureExists_holds

theorem GibbsMeasureCertificate.product_measure_is_gibbs
    (w : GibbsMeasureCertificate) : w.productMeasureIsGibbs :=
  w.productMeasureIsGibbs_holds

theorem GibbsMeasureCertificate.has_modifier_calculus
    (w : GibbsMeasureCertificate) : w.hasModifierCalculus :=
  w.hasModifierCalculus_holds

theorem GibbsMeasureCertificate.kernel_weight_nonneg
    (w : GibbsMeasureCertificate)
    (Λ : Finset w.Site) (η ξ : w.Config) :
    0 ≤ w.specificationKernelWeight Λ η ξ :=
  w.specificationKernelWeight_nonneg Λ η ξ

theorem GibbsMeasureCertificate.gibbs_weight_formula_eq
    (w : GibbsMeasureCertificate) (ξ : w.Config) :
    w.gibbsWeight ξ = Real.exp (-w.inverseTemperature * w.energy ξ) :=
  w.gibbsWeight_formula ξ

theorem GibbsMeasureCertificate.gibbs_weight_pos
    (w : GibbsMeasureCertificate) (ξ : w.Config) :
    0 < w.gibbsWeight ξ := by
  rw [w.gibbs_weight_formula_eq ξ]
  exact Real.exp_pos _

theorem GibbsMeasureCertificate.normalized_density_eq
    (w : GibbsMeasureCertificate) (ξ : w.Config) :
    w.normalizedDensity ξ = w.gibbsWeight ξ / w.partitionFunction :=
  w.normalizedDensity_def ξ

theorem GibbsMeasureCertificate.partitionFunction_positive
    (w : GibbsMeasureCertificate) : 0 < w.partitionFunction :=
  w.partitionFunction_pos

theorem GibbsMeasureCertificate.kernel_dominated_by_gibbsWeight
    (w : GibbsMeasureCertificate)
    (Λ : Finset w.Site) (η ξ : w.Config) :
    w.specificationKernelWeight Λ η ξ ≤ ENNReal.ofReal (w.gibbsWeight ξ) :=
  w.specificationKernel_dominatedByGibbsWeight Λ η ξ

theorem GibbsMeasureCertificate.dlr_bundle
    (w : GibbsMeasureCertificate) :
    w.hasSpecification ∧ w.specificationConsistent ∧ w.specificationProper ∧
      w.specificationMarkov ∧ w.hasConditionalExpectationCharacterization := by
  exact ⟨w.has_specification, w.consistent_specification, w.proper_specification,
    w.markov_specification, w.has_condExp_characterization⟩

theorem GibbsMeasureCertificate.quantitative_bundle
    (w : GibbsMeasureCertificate) :
    (∀ ξ : w.Config, w.gibbsWeight ξ = Real.exp (-w.inverseTemperature * w.energy ξ)) ∧
    0 < w.partitionFunction ∧
    (∀ ξ : w.Config, w.normalizedDensity ξ = w.gibbsWeight ξ / w.partitionFunction) := by
  exact ⟨w.gibbs_weight_formula_eq, w.partitionFunction_positive, w.normalized_density_eq⟩

end

end NavierStokesClean.CATEPT.External
