/-
# Tests — FRW matter-model derivation of `EinsteinEquationHolds`

Smoke `#check`s for the FRW matter-model module.
-/

import CATEPTMain.Certification.RelativityGRFRWMatterModel

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRFRWMatterModel

open CATEPTMain.Certification.RelativityGR

#check @FRWMatterModel
#check @frw_einsteinEquationHolds_from_raw
#check @frwDerivedEFETarget_from_matter

end CATEPTMain.Certification.Tests.GRFRWMatterModel

end
