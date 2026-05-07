import CATEPTMain.Geometry.OCT.OCTPrelude
import CATEPTMain.Geometry.OCT.Octonion_Algebra
import CATEPTPluginDomainGeometry.OCT.Norm_Octonions

/-!
# Norm_Octonions — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.OCT.Norm_Octonions

export CATEPTPluginDomainGeometry.OCT.Norm_Octonions (
  octInner
  octInner_add_left
  octInner_comm
  octInner_self_eq_normSq
  octInv
  octNorm_sq_eq_inner
  oct_cauchy_schwarz
  oct_mul_inv
  oct_norm_triangle
  oct_rank_8
)

end CATEPTMain.Geometry.OCT.Norm_Octonions
