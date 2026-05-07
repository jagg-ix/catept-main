import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTPluginDomainGeometry.SM.Analysis_More

/-!
# Analysis_More — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Analysis_More

export CATEPTPluginDomainGeometry.SM.Analysis_More (
  inverse_function
  locallyLipschitz_cont
  smooth_bump_exists
)

end CATEPTMain.Geometry.SM.Analysis_More
