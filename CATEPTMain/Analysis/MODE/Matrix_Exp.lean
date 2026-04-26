import CATEPTMain.Analysis.MODE.MODEPrelude
import CATEPTPluginDomainAnalysis.MODE.Matrix_Exp

/-!
# Matrix_Exp — re-export shim (sub-bundle `MODE`)
-/

set_option autoImplicit false

namespace CATEPTMain.Analysis.MODE.Matrix_Exp

export CATEPTPluginDomainAnalysis.MODE.Matrix_Exp (
  matExp_diagonal
  matExp_invertible
  matExp_norm_le
  matExp_smul_group
  matExp_transpose
)

end CATEPTMain.Analysis.MODE.Matrix_Exp
