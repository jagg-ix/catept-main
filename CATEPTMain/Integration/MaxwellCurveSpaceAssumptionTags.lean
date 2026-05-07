import CATEPTMain.Core.Assumptions
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge

/-!
# Maxwell-CurveSpace plugin OS-witness fields tagged with registry ids (T88)

The `catept-plugin-maxwell-curvespace-pphi2` plugin's
`Pphi2IntegrationWitness` carries the Osterwalder-Schrader
reconstruction package as `Prop` fields. Three of those Props match
existing `AssumptionId` entries in the registry — currently dead per
`docs/architecture/ASSUMPTIONS.md`:

  * `osterwalderSchraderOS0` (`qft.os.os0_analyticity`)
       ↔ `Pphi2IntegrationWitness.os0Analyticity`
  * `reflectionPositivity`   (`qft.os.reflection_positivity`)
       ↔ `Pphi2IntegrationWitness.os3ReflectionPositivity`
  * `bargmannHallWightman`   (`qft.os.bargmann_hall_wightman`)
       ↔ `Pphi2IntegrationWitness.hasReconstruction`

This file wraps the field accesses with `CATEPTAssumption` tags so
the registry's grep audit picks them up. Effect: `gen_assumptions_md.py`
sees three previously-dead ids move to the referenced list.

Pattern: when a caller supplies an actual proof of e.g.
`os3ReflectionPositivity`, the wrap below records that proof as the
substrate-side discharge of `AssumptionId.reflectionPositivity` —
greppable from source for the multi-helper audit.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open CATEPTMain.Integration (Pphi2IntegrationWitness)

/-- Tag the plugin's OS0 analyticity field with the registry id
    `osterwalderSchraderOS0`. The wrap is the identity proof: given
    a proof of the OS0 Prop, that same proof discharges the registered
    assumption. -/
theorem os0_analyticity_tag (w : Pphi2IntegrationWitness)
    (h : w.os0Analyticity) :
    CATEPTAssumption osterwalderSchraderOS0 w.os0Analyticity :=
  h

/-- Tag the plugin's OS3 reflection-positivity field with the registry
    id `reflectionPositivity`. -/
theorem reflection_positivity_tag (w : Pphi2IntegrationWitness)
    (h : w.os3ReflectionPositivity) :
    CATEPTAssumption reflectionPositivity w.os3ReflectionPositivity :=
  h

/-- Tag the plugin's `hasReconstruction` field with the registry id
    `bargmannHallWightman`. The Bargmann-Hall-Wightman envelope-of-
    holomorphy theorem is precisely the reconstruction step that
    promotes Schwinger functions to Wightman distributions, so the
    plugin's `hasReconstruction` Prop is the substrate-side discharge
    of the existing registry id. -/
theorem has_reconstruction_tag (w : Pphi2IntegrationWitness)
    (h : w.hasReconstruction) :
    CATEPTAssumption bargmannHallWightman w.hasReconstruction :=
  h

end CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags
