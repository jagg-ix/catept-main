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
import CATEPTMain.Geometry.SM.Sphere
import CATEPTPluginDomainGeometry.SM.Projective_Space

/-!
# Projective_Space — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Projective_Space

export CATEPTPluginDomainGeometry.SM.Projective_Space (
  RealProjective
  affineChart
  instTopologicalSpaceRealProjective
  rp1_eq_s1
  rp_eq_sphere_antipodal
  rpn_compact
  rpn_connected
)

end CATEPTMain.Geometry.SM.Projective_Space
