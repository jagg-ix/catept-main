/-!
# Gibbs Measure Integration Bridge

Provides an abstract integration contract for the `gibbsmeasure-inspect` package
against CATEPT's measure-theory bridges.

**Source:** `file:///…/gibbsmeasure-inspect`
**Toolchain status:** `legacy_port_required` — package targets Lean 4 v4.22.0;
  requires porting effort to v4.29.0.

## CATEPT leverage points

* **CPM bridge** (`AFPBridge/CPM`): `GibbsMeasure.KolmogorovExtension4` provides
  the Kolmogorov extension theorem (consistent family of finite-dimensional
  marginals → infinite-product measure). This directly supplies the missing
  dependency flagged in `CPM_WORKLOG` (the infinite-product / coproduct measure
  construction). `Coproduct_Measure.lean` axiomatises σ-additivity; `GibbsMeasure`
  gives the constructive Kolmogorov proof.

* **Conditional expectations** (`GibbsMeasure.Mathlib.Probability.Kernel.Condexp`):
  Conditional expectations w.r.t. sub-σ-algebras underpin the Gibbs-DLR
  specification. CATEPT's `CPM.Theories.Lemmas_Coproduct_Measure` uses the
  same conditional-expectation uniqueness lemma.

* **Gibbs–DLR specification**: A Gibbs measure satisfies the DLR conditions
  (Dobrushin–Lanford–Ruelle): local conditional distributions equal Gibbs
  weights. This is the lattice-field counterpart of CATEPT's path-integral
  Euclidean measure, bridging `pphi2`'s OS axioms to lattice approximations.

## Key modules in `gibbsmeasure-inspect` leveraged
* `GibbsMeasure.KolmogorovExtension4.ProductMeasure` — Kolmogorov extension.
* `GibbsMeasure.Mathlib.Probability.Kernel.Condexp` — conditional expectations.
* `GibbsMeasure.Mathlib.MeasureTheory.Measure.GiryMonad` — Giry monad (prob. kernels).
* `GibbsMeasure.Mathlib.MeasureTheory.Function.ConditionalExpectation.Unique` — uniqueness.

## Phase status
Phase-1: abstract witness; bridge theorem trivially proved.
Phase-2 work item: port `KolmogorovExtension4.ProductMeasure` to v4.29.0,
then use it to prove `CPM.Theories.Coproduct_Measure.copr_sigma_additive`
without phase-1 axiom.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GibbsMeasure

/-- Abstract capability witness for the `gibbsmeasure` package. -/
structure GibbsMeasureWitness where
  /-- Kolmogorov extension theorem: consistent marginals → σ-additive product measure. -/
  kolmogorovExtensionAvailable : Prop
  /-- Conditional expectations w.r.t. sub-σ-algebras formalised. -/
  conditionalExpectationAvailable : Prop
  /-- Giry monad (probability kernels, stochastic maps) available. -/
  giryMonadAvailable : Prop
  /-- Gibbs–DLR specification: local conditional distributions are Gibbsian. -/
  gibbsDLRAvailable : Prop
  /-- Existence of Gibbs measures for finite-range interactions. -/
  gibbsMeasureExistsAvailable : Prop

/-- Integration contract: CATEPT's CPM and pphi2 bridges obtain Kolmogorov
    extension and DLR results once a `GibbsMeasureWitness` is supplied. -/
def GibbsMeasureIntegrationContract (w : GibbsMeasureWitness) : Prop :=
  w.kolmogorovExtensionAvailable ∧ w.conditionalExpectationAvailable ∧
  w.giryMonadAvailable ∧ w.gibbsDLRAvailable ∧ w.gibbsMeasureExistsAvailable

theorem gibbsMeasure_integration_contract
    (w : GibbsMeasureWitness)
    (hK  : w.kolmogorovExtensionAvailable)
    (hCE : w.conditionalExpectationAvailable)
    (hGM : w.giryMonadAvailable)
    (hDL : w.gibbsDLRAvailable)
    (hEx : w.gibbsMeasureExistsAvailable) :
    GibbsMeasureIntegrationContract w :=
  ⟨hK, hCE, hGM, hDL, hEx⟩

end CATEPTMain.Integration.GibbsMeasure
