import CATEPTMain.Analysis.ODE.Picard_Lindelof
import CATEPTPluginDomainAnalysis.ODE.Flow

/-!
# Flow — re-export shim (sub-bundle `ODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.ODE.Flow

export CATEPTPluginDomainAnalysis.ODE.Flow (
  IsFlowInvariant
  OmegaLimit
  equilibrium_invariant
  odeFlow_injective
  odeFlow_inv
  odeFlow_smooth
  omegaLimit_closed_invariant
)

end CATEPTMain.Analysis.ODE.Flow
