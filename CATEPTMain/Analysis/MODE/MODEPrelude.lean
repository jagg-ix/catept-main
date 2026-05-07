import CATEPTMain.Analysis.ODE.ODEPrelude
import CATEPTPluginDomainAnalysis.MODE.MODEPrelude

/-!
# MODEPrelude — re-export shim (sub-bundle `MODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.MODE

export CATEPTPluginDomainAnalysis.MODE (
  affineODESol
  affineODESol_satisfies_ode
  linearODESol
  linearODESol_deriv
  linearODESol_init
  lyapunov_stability_spec
  matExp
  matExp_add_commute
  matExp_deriv
  matExp_zero
)

end CATEPTMain.Analysis.MODE
