import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTMain.Geometry.SM.Topological_Manifold
import CATEPTMain.Geometry.SM.Differentiable_Manifold
import CATEPTPluginDomainGeometry.SM.Partition_Of_Unity

/-!
# Partition_Of_Unity — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Partition_Of_Unity

export CATEPTPluginDomainGeometry.SM.Partition_Of_Unity (
  smooth_extension
  smooth_glue
  smooth_partunity_exists
)

end CATEPTMain.Geometry.SM.Partition_Of_Unity
