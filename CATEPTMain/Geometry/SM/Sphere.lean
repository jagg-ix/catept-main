import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTMain.Geometry.SM.Topological_Manifold
import CATEPTMain.Geometry.SM.Differentiable_Manifold
import CATEPTMain.Geometry.SM.Partition_Of_Unity
import CATEPTMain.Geometry.SM.Tangent_Space
import CATEPTMain.Geometry.SM.Cotangent_Space
import CATEPTMain.Geometry.SM.Product_Manifold
import CATEPTPluginDomainGeometry.SM.Sphere

/-!
# Sphere — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Sphere

export CATEPTPluginDomainGeometry.SM.Sphere (
  nSphere
  s1_circle_diff
  sphere_compact
  sphere_connected
  stereoProj
)

end CATEPTMain.Geometry.SM.Sphere
