import CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function0
import CATEPTPluginDomainQuantum.CBO.Complex_Bounded_Linear_Function

/-!
# Complex_Bounded_Linear_Function — re-export shim (sub-bundle `CBO`)
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function

export CATEPTPluginDomainQuantum.CBO.Complex_Bounded_Linear_Function (
  cboPolarAbs
  cboPolarU
  normal_specRadius_eq_norm
  polarDecomp_spec
  rankOne_unit_projector_bridge
  specRadius
  specRadius_le_norm
  spectrum_nonempty
)

end CATEPTMain.Quantum.CBO.Complex_Bounded_Linear_Function
