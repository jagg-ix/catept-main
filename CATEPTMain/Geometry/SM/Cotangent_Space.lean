import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTMain.Geometry.SM.Topological_Manifold
import CATEPTMain.Geometry.SM.Differentiable_Manifold
import CATEPTMain.Geometry.SM.Partition_Of_Unity
import CATEPTMain.Geometry.SM.Tangent_Space
import CATEPTPluginDomainGeometry.SM.Cotangent_Space

/-!
# Cotangent_Space — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Cotangent_Space

export CATEPTPluginDomainGeometry.SM.Cotangent_Space (
  pullbackOneForm
  pullback_differential
  smoothDiff_add
  smoothDifferential
)

end CATEPTMain.Geometry.SM.Cotangent_Space
