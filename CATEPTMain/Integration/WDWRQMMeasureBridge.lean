import Mathlib.MeasureTheory.Measure.WithDensity
import CATEPTMain.CATEPT.CATEPT.ModularFlowKucharCoreAbstractions

/-!
# WDWRQMMeasureBridge — Observer-Relative Measures for WDW/RQM Integration

This module is a **small contract landing pad** for the reusable (non-framing)
core in:

`(private intake doc)`

The artifact's most reusable contribution is measure-theoretic:

* a base configuration measure `μ` on a configuration space `Ω`
* an observer/process relative measure `μ_obs`
* the Radon–Nikodym derivative / density `ρ = dμ_obs/dμ` (accessibility weight)

This file formalizes that pattern using Mathlib's `Measure.withDensity`.

Honest scope:

* We DO NOT formalize Wheeler–DeWitt operators here (those already exist as
  contract objects in `ModularFlowKucharCoreAbstractions` / `QuantumGravity`).
* We DO NOT assume the original "virtual universe" metaphor.
* We only provide the measure-level objects needed to *connect* relational
  state descriptions to existing WDW + relational-clock witnesses.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.WDWRQMMeasureBridge

open MeasureTheory

-- ============================================================================
-- 1. Base measure + observer density
-- ============================================================================

/-!
The artifact uses a real-valued density `ρ(ω) ∈ [0,1]`.  To reuse Mathlib's
`Measure.withDensity` we package the real density, then define an ENNReal
density via `ENNReal.ofReal`.
-/

structure BaseMeasureModel (Ω : Type*) [MeasurableSpace Ω] where
  μ : Measure Ω

structure AccessibilityDensity (Ω : Type*) [MeasurableSpace Ω] where
  /-- Real-valued accessibility / coherence weight. -/
  ρ : Ω → ℝ
  measurable_ρ : Measurable ρ
  ρ_nonneg : ∀ ω, 0 ≤ ρ ω
  ρ_le_one : ∀ ω, ρ ω ≤ 1

namespace AccessibilityDensity

variable {Ω : Type*} [MeasurableSpace Ω]

/-- The ENNReal density used by `withDensity`. -/
def rhoENN (a : AccessibilityDensity Ω) : Ω → ENNReal :=
  fun ω => ENNReal.ofReal (a.ρ ω)

theorem measurable_rhoENN (a : AccessibilityDensity Ω) : Measurable (rhoENN a) :=
  ENNReal.measurable_ofReal.comp a.measurable_ρ

theorem rhoENN_le_one (a : AccessibilityDensity Ω) : ∀ ω, rhoENN a ω ≤ 1 := by
  intro ω
  -- `ofReal x ≤ ofReal y` when `x ≤ y`, and `ofReal 1 = 1`.
  simpa [rhoENN] using (ENNReal.ofReal_le_ofReal (a.ρ_le_one ω))

/-- The induced observer-relative measure `μ_obs = μ.withDensity ρ`. -/
def inducedMeasure (a : AccessibilityDensity Ω) (b : BaseMeasureModel Ω) : Measure Ω :=
  b.μ.withDensity (rhoENN a)

theorem inducedMeasure_absolutelyContinuous
    (a : AccessibilityDensity Ω) (b : BaseMeasureModel Ω) :
    inducedMeasure a b ≪ b.μ := by
  simpa [inducedMeasure] using
    (MeasureTheory.withDensity_absolutelyContinuous b.μ (rhoENN a))

end AccessibilityDensity

-- ============================================================================
-- 2. Canonical density builder: exp(-cost) in (0,1]
-- ============================================================================

structure NonnegCost (Ω : Type*) [MeasurableSpace Ω] where
  cost : Ω → ℝ
  measurable_cost : Measurable cost
  cost_nonneg : ∀ ω, 0 ≤ cost ω

namespace NonnegCost

variable {Ω : Type*} [MeasurableSpace Ω] (c : NonnegCost Ω)

/-- Real density from a nonnegative cost: `ρ = exp(-cost)`. -/
def expNegDensity : Ω → ℝ := fun ω => Real.exp (-(c.cost ω))

theorem expNegDensity_measurable : Measurable c.expNegDensity :=
  Real.measurable_exp.comp (measurable_neg.comp c.measurable_cost)

theorem expNegDensity_nonneg (ω : Ω) : 0 ≤ c.expNegDensity ω :=
  (Real.exp_pos _).le

theorem expNegDensity_le_one (ω : Ω) : c.expNegDensity ω ≤ 1 := by
  -- `exp x ≤ 1 ↔ x ≤ 0`.
  have : -(c.cost ω) ≤ 0 := by linarith [c.cost_nonneg ω]
  simpa [expNegDensity] using (Real.exp_le_one_iff.mpr this)

/-- Package `exp(-cost)` as an accessibility density in the artifact sense. -/
def toAccessibilityDensity : AccessibilityDensity Ω where
  ρ := c.expNegDensity
  measurable_ρ := c.expNegDensity_measurable
  ρ_nonneg := c.expNegDensity_nonneg
  ρ_le_one := c.expNegDensity_le_one

end NonnegCost

-- ============================================================================
-- 3. Hook: using observer-measure states as WDW "State" parameters
-- ============================================================================

/-!
`ModularFlowKucharCoreAbstractions` defines `RelationalWDWResolutionWitness State`.
This file does not build a full witness, but it provides a canonical `State`
carrier for "observer-relative" models:

  `State := (μ, ρ)`

so other modules can instantiate the WDW + relational-clock witnesses on a
measure-theoretic state space (matching the artifact's RQM intent).
-/

abbrev ObserverMeasureState (Ω : Type*) [MeasurableSpace Ω] : Type _ :=
  BaseMeasureModel Ω × AccessibilityDensity Ω

end CATEPTMain.Integration.WDWRQMMeasureBridge
