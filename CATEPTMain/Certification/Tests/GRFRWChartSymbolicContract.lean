/-
Surface test for the FRW chart / symbolic-divergence named contracts.
-/

import CATEPTMain.Certification.RelativityGRFRWChartSymbolicContract

set_option autoImplicit false

namespace CATEPTMain.Certification.Tests.GRFRWChartSymbolicContract

open CATEPTMain.Certification.RelativityGR

#check @FRWChartCompatible
#check @FRWSymbolicDivergenceSimplifies
#check @smoothFRW_represents_gravitasFRW_of_raw_named

end CATEPTMain.Certification.Tests.GRFRWChartSymbolicContract
