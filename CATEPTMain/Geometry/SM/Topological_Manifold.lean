import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTPluginDomainGeometry.SM.Topological_Manifold

/-!
# Topological_Manifold — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Topological_Manifold

export CATEPTPluginDomainGeometry.SM.Topological_Manifold (
  IsTopoManifold
  manifold_locally_compact
  manifold_paracompact
  smooth_structure_exists
)

end CATEPTMain.Geometry.SM.Topological_Manifold
