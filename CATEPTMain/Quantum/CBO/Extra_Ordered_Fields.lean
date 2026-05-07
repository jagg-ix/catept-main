import CATEPTMain.Quantum.CBO.Extra_Vector_Spaces
import CATEPTPluginDomainQuantum.CBO.Extra_Ordered_Fields

/-!
# Extra_Ordered_Fields — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Extra_Ordered_Fields

export CATEPTPluginDomainQuantum.CBO.Extra_Ordered_Fields (
  NNReal_sSup_le
  archimedean_lt_inv
  cboNorm_apply_le
  mono_conv_operator
)

end CATEPTMain.Quantum.CBO.Extra_Ordered_Fields
