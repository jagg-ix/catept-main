import CATEPTMain.Integration.StringWorldsheetTemporalBridge
import CATEPTMain.Integration.KMSModularParameterBridge

/-!
# String Effective QFT ↔ CAT/EPT Spine — Capstone (Interface Level)

Capstone of the string-CAT/EPT plan recorded in
[`docs/architecture/string-catept-spine.md`](../../docs/architecture/string-catept-spine.md).

This module is **deliberately interface-level only**.  It declares
the seven Prop fields that a string-effective-QFT instance must
provide to plug into the catept temporal-framework spine, and a
single capstone theorem that consumes a populated witness and
returns the conjunction of those fields.

No external string-theory imports.  Concrete content (Polyakov
action, Weyl variation, Virasoro relations, Riemann-surface moduli,
RT entropy, …) lives in upstream string-theory packages and is
deferred to dedicated bridge modules per the plan in the docs.

## Why interface-level first

The advisor's recommendation:

> Their job should be interface-level first, not heavy imports.

Concretely:

1. The full chain string-effective-QFT → CAT/EPT spine has
   substantial content (worldsheet action, Weyl/beta, VOA/Virasoro,
   AdS/CFT) much of which lives in upstream packages we either
   already depend on (`StringAlgebraVOA`) or do not yet pin
   (`PhysicsLogic.StringTheory`).
2. An interface module gives downstream consumers a clean place to
   plug in concrete witnesses without forcing this module to import
   heavy upstream content.
3. Phase-2 work substitutes concrete Props (and Prop proofs)
   without changing this module's signature.

## What is honestly proven

* `StringEffectiveQFTCATEPTWitness` (carrier struct) bundling 7
  load-bearing Props (advisor's exact list):
    - `hasWorldsheetAction`
    - `hasComplexAction`
    - `actionIm_nonneg`
    - `hasWeylBetaSystem`
    - `betaToSpacetimeEOM`
    - `hasCFTModularData`
    - `couplesToTemporalFramework`

* `string_effective_qft_on_catept_spine` (capstone theorem):
  takes the witness and returns the conjunction of all seven
  fields plus the worldsheet-`τ` separation note from
  `StringWorldsheetTemporalBridge`.  This is the audit anchor:
  any consumer wanting to claim "string effective QFT couples to
  the CAT/EPT spine" must populate the witness.

## Honest scope (CRUCIAL)

* **No new physics derivations.**  Each Prop is a structural
  placeholder; concrete content is the consumer's responsibility.
* **No identification of worldsheet `τ` with `τ_ent`** by default.
  The capstone explicitly carries the
  `worldsheet_tau_separate_from_entropic_proper_time` note (from
  `StringWorldsheetTemporalBridge`) so the layer separation stays
  visible in the audit chain.
* **No `PhysicsLogic` sibling pin added.**  See
  `string-catept-spine.md` for the deferred Weyl/beta retrofit
  that needs that pin.
* **No claim that the witness is ever inhabited under upstream
  Phase-1 placeholders.**  Concrete instances supply their own
  Prop proofs.

## Architectural fit

```text
string upstream:  Polyakov / VOA / RT / Backgrounds...
        ↓ (per-layer bridges, deferred)
StringEffectiveQFTCATEPTWitness  (this module — interface-level)
        ↓ string_effective_qft_on_catept_spine
catept spine (TemporalFramework, MeasurePathIntegralModel, …)
```
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.StringEffectiveQFTSpineBridge

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- Interface-level witness carrier
-- ═══════════════════════════════════════════════════════════════════════

/-- **String-effective-QFT ↔ CAT/EPT-spine witness (interface).**

Seven Prop fields the consumer must supply to claim the string
effective-QFT-side instance couples to the catept temporal spine.

Each field is structural: concrete content (Polyakov action, Weyl
variation, Virasoro relations, …) is supplied by Phase-2 per-layer
bridge modules.  The advisor's exact field list is preserved
verbatim. -/
structure StringEffectiveQFTCATEPTWitness where
  /-- The string-side instance has a worldsheet action functional. -/
  hasWorldsheetAction : Prop
  /-- The action splits as `S = S_R + i S_I` (complex action). -/
  hasComplexAction : Prop
  /-- The imaginary part is pointwise non-negative
      (`S_I ≥ 0`, the catept-physics shape). -/
  actionIm_nonneg : Prop
  /-- The instance carries a Weyl / beta-function system
      (e.g. `WeylInvariantBackground`, `SigmaModelBetaData`). -/
  hasWeylBetaSystem : Prop
  /-- Beta vanishing implies effective spacetime equations of motion
      (`SpacetimeEffectiveEOMData` shape). -/
  betaToSpacetimeEOM : Prop
  /-- The instance carries CFT / VOA / modular data
      (Virasoro, central charge, conformal weights, primary states). -/
  hasCFTModularData : Prop
  /-- The instance couples to the catept `TemporalFramework`
      (e.g. via `MeasurePathIntegralModel` whose `actionIm` matches
      the string-side `S_I`). -/
  couplesToTemporalFramework : Prop

namespace StringEffectiveQFTCATEPTWitness

/-- **Capstone bundle.**  Given a populated string-effective-QFT
witness, the conjunction of all seven witness fields holds — plus
the worldsheet-`τ` separation note documenting that
`τ_ws ≠ τ_ent` by default. -/
theorem string_effective_qft_on_catept_spine
    (w : StringEffectiveQFTCATEPTWitness)
    (h_ws : w.hasWorldsheetAction)
    (h_complex : w.hasComplexAction)
    (h_imnn : w.actionIm_nonneg)
    (h_weyl : w.hasWeylBetaSystem)
    (h_eom : w.betaToSpacetimeEOM)
    (h_cft : w.hasCFTModularData)
    (h_couple : w.couplesToTemporalFramework) :
    w.hasWorldsheetAction ∧
    w.hasComplexAction ∧
    w.actionIm_nonneg ∧
    w.hasWeylBetaSystem ∧
    w.betaToSpacetimeEOM ∧
    w.hasCFTModularData ∧
    w.couplesToTemporalFramework ∧
    -- Layer separation: worldsheet τ ≠ τ_ent by default
    (∃ (tau_ws tauEnt : ℝ → ℝ) (s : ℝ), tauEnt s ≠ tau_ws s) :=
  ⟨h_ws, h_complex, h_imnn, h_weyl, h_eom, h_cft, h_couple,
   StringWorldsheetTemporalBridge.worldsheet_tau_separate_from_entropic_proper_time⟩

end StringEffectiveQFTCATEPTWitness

end

end CATEPTMain.Integration.StringEffectiveQFTSpineBridge
