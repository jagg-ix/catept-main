/-
Surface test for the FRW CurvedDirect-from-models constructor.
-/

import CATEPTMain.Certification.RelativityGRFRWCurvedDirectFromModels

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRFRWCurvedDirectFromModels

open CATEPTMain.Certification.RelativityGR

#check @frwCertifiedCurvedGRData_from_models
#check @frwCurvedGRDirectCertificate_from_models

end CATEPTMain.Certification.Tests.GRFRWCurvedDirectFromModels
