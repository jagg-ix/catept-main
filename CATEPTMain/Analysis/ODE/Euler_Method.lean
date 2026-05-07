import CATEPTMain.Analysis.ODE.Flow
import CATEPTPluginDomainAnalysis.ODE.Euler_Method

/-!
# Euler_Method — re-export shim (sub-bundle `ODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.ODE.Euler_Method

export CATEPTPluginDomainAnalysis.ODE.Euler_Method (
  eulerStep
  eulerTraj
  euler_converges
  euler_global_error
  euler_local_error
)

end CATEPTMain.Analysis.ODE.Euler_Method
