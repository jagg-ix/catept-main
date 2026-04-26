import CATEPTPluginDomainAnalysis.ODE.ODEPrelude

/-!
# ODEPrelude — re-export shim (sub-bundle `ODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.ODE

export CATEPTPluginDomainAnalysis.ODE (
  IsEquilibrium
  IsLocallyLipschitz
  ODEFlowType
  ODESolType
  equilibrium_fixed
  odeFlow
  odeFlow_deriv
  odeFlow_semigroup
  odeFlow_zero
  ode_solution_exists
  ode_unique
)

end CATEPTMain.Analysis.ODE
