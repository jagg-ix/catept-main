import CATEPTMain.Quantum.IMD.IMDPrelude
import CATEPTPluginDomainQuantum.IMD.Complex_Vectors

/-!
# Complex_Vectors — re-export shim (sub-bundle `IMD`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.IMD.Complex_Vectors

export CATEPTPluginDomainQuantum.IMD.Complex_Vectors (
  cauchy_schwarz
  cpx_vec_length_geq_0
  cpx_vec_length_inner_prod
  cpx_vec_length_smul
  cpx_vec_zero_iff_length_zero
  inner_prod_add_right
  inner_prod_cnj
  inner_prod_expand
  inner_prod_is_linear
  inner_prod_is_sesquilinear
)

end CATEPTMain.Quantum.IMD.Complex_Vectors
