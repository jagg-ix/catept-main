import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTPluginDomainGeometry.SM.Chart

/-!
# Chart — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Chart

export CATEPTPluginDomainGeometry.SM.Chart (
  chartAt_transition_smooth
  chart_nhd
  two_charts_partunity
)

end CATEPTMain.Geometry.SM.Chart
