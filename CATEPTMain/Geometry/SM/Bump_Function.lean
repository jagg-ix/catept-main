import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTPluginDomainGeometry.SM.Bump_Function

/-!
# Bump_Function — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Bump_Function

export CATEPTPluginDomainGeometry.SM.Bump_Function (
  smooth_bump_manifold
  smooth_bump_sum_partunity
  smooth_urysohn
)

end CATEPTMain.Geometry.SM.Bump_Function
