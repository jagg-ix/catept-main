import CATEPTMain.Geometry.OCT.OCTPrelude
import CATEPTPluginDomainGeometry.OCT.Octonion_Algebra

/-!
# Octonion_Algebra — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.OCT.Octonion_Algebra

export CATEPTPluginDomainGeometry.OCT.Octonion_Algebra (
  flexible
  left_alternative
  moufang_middle
  moufang_right
  oct_basis_mul_spec
  oct_e1_mul_e2_eq_e3
  oct_not_assoc
  right_alternative
)

end CATEPTMain.Geometry.OCT.Octonion_Algebra
