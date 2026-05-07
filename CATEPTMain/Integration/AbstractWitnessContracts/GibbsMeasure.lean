import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# CATEPT Plugin — Gibbs-Measure Integration Bridge

Sibling repo of `jagg-ix/catept-main`. Provides an abstract integration
contract for the upstream `gibbsmeasure-inspect` package against
CATEPT's measure-theory bridges.

**Toolchain status:** the upstream `gibbsmeasure-inspect` package
targets Lean 4 v4.22.0; the catept workspace is on v4.29.0. The
witness is toolchain-independent so this sibling holds the integration
contract stable across the version gap. Phase-2 work item: port
`KolmogorovExtension4.ProductMeasure` to v4.29.0 and replace the
abstract `kolmogorovExtensionAvailable` field with a direct import.

## CATEPT leverage points

* **CPM bridge** (`AFPBridge/CPM`): `GibbsMeasure.KolmogorovExtension4`
  supplies the Kolmogorov extension theorem for the infinite-product /
  coproduct measure construction.
* **Conditional expectations**
  (`GibbsMeasure.Mathlib.Probability.Kernel.Condexp`): underpins the
  Gibbs-DLR specification.
* **Gibbs-DLR specification**: a Gibbs measure satisfies the DLR
  conditions (Dobrushin-Lanford-Ruelle); lattice-field counterpart of
  CATEPT's path-integral Euclidean measure.

## Re-import contract

```lean
import CATEPTPluginGibbsMeasure.IntegrationBridge

open CATEPTPluginGibbsMeasure (
  GibbsMeasureWitness GibbsMeasureIntegrationContract
  gibbsMeasure_integration_contract)
```
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTPluginGibbsMeasure

/-! ## Concrete Boltzmann weight content

Concrete proven content for the canonical Gibbs-measure ingredient:
the **Boltzmann weight** `w_β(E) = exp(−β · E)`.  Kernel-clean theorems
on positivity, monotonicity in `E`, and behaviour under `β → 0`.

Used by CATEPT's CPM bridge (path-integral Euclidean measure on
infinite-product spaces) and the modular-flow KMS lane
(detailed-balance ↔ Boltzmann-weight ratio). -/

/-- **Boltzmann weight** at inverse temperature `β` and energy `E`:
`w_β(E) = exp(−β · E)`. -/
def boltzmannWeight (β E : ℝ) : ℝ := Real.exp (-(β * E))

/-- **Proven:** the Boltzmann weight is **strictly positive**. -/
theorem proved_boltzmannWeight_pos (β E : ℝ) : 0 < boltzmannWeight β E := by
  unfold boltzmannWeight
  exact Real.exp_pos _

/-- **Proven:** at zero energy, the Boltzmann weight is `1`. -/
theorem proved_boltzmannWeight_at_zero_energy (β : ℝ) :
    boltzmannWeight β 0 = 1 := by
  unfold boltzmannWeight
  simp

/-- **Proven:** at infinite temperature (`β = 0`), all energies are
equally likely (weight = 1 everywhere). -/
theorem proved_boltzmannWeight_at_infinite_temperature (E : ℝ) :
    boltzmannWeight 0 E = 1 := by
  unfold boltzmannWeight
  simp

/-- **Proven:** at fixed positive `β > 0`, the Boltzmann weight is
**monotone decreasing in `E`** — higher-energy states are exponentially
suppressed. -/
theorem proved_boltzmannWeight_monotone_decreasing
    {β : ℝ} (hβ : 0 < β) {E₁ E₂ : ℝ} (h : E₁ ≤ E₂) :
    boltzmannWeight β E₂ ≤ boltzmannWeight β E₁ := by
  unfold boltzmannWeight
  apply Real.exp_le_exp.mpr
  nlinarith

/-! ## Witness contract (preserved) -/

/-- Abstract capability witness for the `gibbsmeasure` package. -/
structure GibbsMeasureWitness where
  /-- Kolmogorov extension theorem: consistent marginals → σ-additive product measure. -/
  kolmogorovExtensionAvailable : Prop
  /-- Conditional expectations w.r.t. sub-σ-algebras formalised. -/
  conditionalExpectationAvailable : Prop
  /-- Giry monad (probability kernels, stochastic maps) available. -/
  giryMonadAvailable : Prop
  /-- Gibbs-DLR specification: local conditional distributions are Gibbsian. -/
  gibbsDLRAvailable : Prop
  /-- Existence of Gibbs measures for finite-range interactions. -/
  gibbsMeasureExistsAvailable : Prop

/-- Integration contract: CATEPT's CPM and pphi2 bridges obtain
    Kolmogorov extension and DLR results once a `GibbsMeasureWitness`
    is supplied. -/
def GibbsMeasureIntegrationContract (w : GibbsMeasureWitness) : Prop :=
  w.kolmogorovExtensionAvailable ∧ w.conditionalExpectationAvailable ∧
  w.giryMonadAvailable ∧ w.gibbsDLRAvailable ∧ w.gibbsMeasureExistsAvailable

/-- Phase-1 bridge theorem (term-mode, structurally trivial). -/
theorem gibbsMeasure_integration_contract
    (w : GibbsMeasureWitness)
    (hK  : w.kolmogorovExtensionAvailable)
    (hCE : w.conditionalExpectationAvailable)
    (hGM : w.giryMonadAvailable)
    (hDL : w.gibbsDLRAvailable)
    (hEx : w.gibbsMeasureExistsAvailable) :
    GibbsMeasureIntegrationContract w :=
  ⟨hK, hCE, hGM, hDL, hEx⟩

end CATEPTPluginGibbsMeasure

end
