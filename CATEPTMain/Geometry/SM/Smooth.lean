import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTPluginDomainGeometry.SM.Smooth

/-!
# Smooth — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Smooth

export CATEPTPluginDomainGeometry.SM.Smooth (
  smooth_comp
  smooth_const
  smooth_id
  smooth_iff_smooth_on_open_cover
)

end CATEPTMain.Geometry.SM.Smooth
