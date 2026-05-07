import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTMain.Geometry.SM.Topological_Manifold
import CATEPTMain.Geometry.SM.Differentiable_Manifold
import CATEPTMain.Geometry.SM.Partition_Of_Unity
import CATEPTPluginDomainGeometry.SM.Tangent_Space

/-!
# Tangent_Space — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Tangent_Space

export CATEPTPluginDomainGeometry.SM.Tangent_Space (
  IsSmoothVectorField
  mfderiv_comp_chain
  mfderiv_id_thm
  tangentBundle_proj_smooth
)

end CATEPTMain.Geometry.SM.Tangent_Space
