import CATEPTMain.Core.Assumptions
import CATEPT.CATEPT.Foundations

/-!
# Foundations assumption tags (T98) — cross-library retrofit

Wraps two `CATEPT/CATEPT/Foundations.lean` theorems with the
registry's `hawkingTemperatureFormula` and `modularRateIdentification`
AssumptionIds. Both are dead per `docs/architecture/ASSUMPTIONS.md`
before this commit; T98 retires them by referencing the existing
proofs already in the CATEPT lib.

Pattern: T93 / T86 hypothesis-passing wrap. The wrap theorem returns
the same proof term carried by the underlying Foundations theorem,
labelled with the registry id. Cross-library import path follows the
existing precedent in `CATEPTMain/Integration/TheoryPluginHerglotzETH.lean`
which already imports from `CATEPT.*`.

## Wraps

  hawking_temperature_formula_tag
    Wraps `eq012_thermal_response : hawking_temperature ℏ κ c k_B = ℏ*κ/(2π·c·k_B)`
    with `AssumptionId.hawkingTemperatureFormula`.

  modular_rate_identification_tag
    Wraps `eq013_entropic_rate_formula : κ/(2π) = k_B*T/ℏ` (under the
    Hawking-temperature hypothesis) with `AssumptionId.modularRateIdentification`.

## Effect on the registry audit

  Before T98: dead = 10
  After T98:  dead = 8 (hawkingTemperatureFormula + modularRateIdentification
                        moved dead → referenced)
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.FoundationsAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open Real
open CATEPT (hawking_temperature eq012_thermal_response eq013_entropic_rate_formula)

/-- Tag the Hawking-temperature formula
    `hawking_temperature ℏ κ c k_B = ℏ κ / (2π c k_B)`
    with `AssumptionId.hawkingTemperatureFormula`. The proof is
    `eq012_thermal_response`, which is `rfl` since
    `hawking_temperature` is defined by exactly that expression. -/
theorem hawking_temperature_formula_tag
    (ℏ κ c k_B : ℝ) (hℏ : 0 < ℏ) (hκ : 0 < κ) (hc : 0 < c) (hkB : 0 < k_B) :
    CATEPTAssumption AssumptionId.hawkingTemperatureFormula
      (hawking_temperature ℏ κ c k_B = ℏ * κ / (2 * π * c * k_B)) :=
  eq012_thermal_response ℏ κ c k_B hℏ hκ hc hkB

/-- Tag the modular-rate identification `κ / (2π) = k_B T / ℏ` with
    `AssumptionId.modularRateIdentification`. The proof is
    `eq013_entropic_rate_formula`. The hypothesis
    `T = ℏ * κ / (2π * k_B)` is the Hawking-temperature relation. -/
theorem modular_rate_identification_tag
    (κ k_B T ℏ : ℝ) (hℏ : 0 < ℏ) (hkB : 0 < k_B)
    (h : T = ℏ * κ / (2 * π * k_B)) :
    CATEPTAssumption AssumptionId.modularRateIdentification
      (κ / (2 * π) = k_B * T / ℏ) :=
  eq013_entropic_rate_formula κ k_B T ℏ hℏ hkB h

end CATEPTMain.Integration.FoundationsAssumptionTags
