import CATEPTMain.Analysis.MODE.Matrix_Exp
import CATEPTMain.Analysis.ODE.Flow
import CATEPTPluginDomainAnalysis.MODE.Affine_ODE

/-!
# Affine_ODE — re-export shim (sub-bundle `MODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.MODE.Affine_ODE

export CATEPTPluginDomainAnalysis.MODE.Affine_ODE (
  affineODESol_init
  affineODESol_invertible
  affine_equilibrium
  expStability
  linearODE_unique
)

end CATEPTMain.Analysis.MODE.Affine_ODE
