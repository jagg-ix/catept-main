import CATEPTMain.Core.Assumptions
import CATEPTMain.Domains.SuperiorMethod

/-!
# Superior-Method assumption tags (T93, Group B retrofit)

Wraps the Superior-Method slot's structural data with the registry's
existing `complexActionStructure` AssumptionId (currently dead per
`docs/architecture/ASSUMPTIONS.md`).

The registered description for `complexActionStructure` is
"Complex action χ = S_R + i S_I with S_I ≥ 0". The Superior-Method
slot exposes both the real part `actionRe` and the imaginary part
`actionFn` (the spine's clock-discharging action), with
`actionFn_nonneg` providing the `S_I ≥ 0` half. T93 retrofits this
direct structural correspondence.
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.SuperiorMethodAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open CATEPTMain.Domains (SuperiorMethodSlot)

/-- Tag the Superior-Method slot's `actionFn_nonneg` field with the
    registry id `complexActionStructure`. The `S_I ≥ 0` half of the
    "Complex action χ = S_R + i S_I with S_I ≥ 0" claim is exactly
    `s.actionFn_nonneg`. The real part `S_R` is `s.actionRe`, present
    structurally on the slot. -/
theorem complexActionStructure_tag (s : SuperiorMethodSlot) (x : s.ConfigSpaceTy) :
    CATEPTAssumption complexActionStructure (0 ≤ s.actionFn x) :=
  s.actionFn_nonneg x

end CATEPTMain.Domains.SuperiorMethodAssumptionTags
