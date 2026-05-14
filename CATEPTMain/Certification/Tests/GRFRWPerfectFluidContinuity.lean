/-
Surface test for the FRW perfect-fluid + continuity named contracts.
-/

import CATEPTMain.Certification.RelativityGRFRWPerfectFluidContinuity

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRFRWPerfectFluidContinuity

open CATEPTMain.Certification.RelativityGR

#check @FRWPerfectFluidStress
#check @FRWContinuityEquation
#check @frwMatterModel_of_perfectFluidContinuity

end CATEPTMain.Certification.Tests.GRFRWPerfectFluidContinuity
