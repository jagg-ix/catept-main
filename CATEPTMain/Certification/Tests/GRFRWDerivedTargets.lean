/-
# Tests — FRW derived-witness target shell

Smoke `#check`s for the new derived-witness FRW target shell.
-/

import CATEPTMain.Certification.RelativityGRFRWDerivedTargets

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRFRWDerivedTargets

open CATEPTMain.Certification.RelativityGR

#check FRWRawParameter
#check frwRawMetricFamily
#check FRWDerivedBianchiTarget
#check FRWDerivedEFETarget
#check frwParameter_of_derived_targets

end CATEPTMain.Certification.Tests.GRFRWDerivedTargets

end
