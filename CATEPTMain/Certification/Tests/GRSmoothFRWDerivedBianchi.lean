/-
# Tests — FRW contracted-Bianchi derived from the smooth route

Smoke `#check`s for the smooth-route FRW derived-Bianchi module.
-/

import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedBianchi

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSmoothFRWDerivedBianchi

open CATEPTMain.Certification.RelativityGR

#check smoothFRWFamilyRaw
#check frwLeviCivitaConnectionRaw
#check frwConnectionRaw_isLeviCivita
#check SmoothFRWRepresentsGravitasFRW
#check @smoothFRW_represents_gravitasFRW_of_raw
#check frw_hasContractedBianchi_from_smooth
#check frwDerivedBianchiTarget_from_smooth

end CATEPTMain.Certification.Tests.GRSmoothFRWDerivedBianchi

end
