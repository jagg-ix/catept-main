/-
# Tests — FRW stress conservation derived from the smooth route

Smoke `#check`s for the FRW smooth-route stress-conservation module.
-/

import CATEPTMain.Certification.RelativityGRSmoothFRWDerivedStress

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSmoothFRWDerivedStress

open CATEPTMain.Certification.RelativityGR

#check @frw_hasStressConservation_from_smooth_of_raw
#check @frwDerivedEFETarget_from_smooth_of_raw

end CATEPTMain.Certification.Tests.GRSmoothFRWDerivedStress

end
