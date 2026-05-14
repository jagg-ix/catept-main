/-
# Tests — Full FRW CurvedDirect from the smooth route
-/

import CATEPTMain.Certification.RelativityGRSmoothFRWCurvedDirect

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRSmoothFRWCurvedDirect

open CATEPTMain.Certification.RelativityGR

#check @frwCertifiedCurvedGRData_from_smooth_of_raw
#check @frwCurvedGRDirectCertificate_from_smooth_of_raw

end CATEPTMain.Certification.Tests.GRSmoothFRWCurvedDirect

end
