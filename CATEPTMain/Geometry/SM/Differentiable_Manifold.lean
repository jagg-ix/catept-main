import CATEPTMain.Geometry.SM.SMPrelude
import CATEPTMain.Geometry.SM.Analysis_More
import CATEPTMain.Geometry.SM.Smooth
import CATEPTMain.Geometry.SM.Bump_Function
import CATEPTMain.Geometry.SM.Chart
import CATEPTMain.Geometry.SM.Topological_Manifold
import CATEPTPluginDomainGeometry.SM.Differentiable_Manifold

/-!
# Differentiable_Manifold — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Differentiable_Manifold

export CATEPTPluginDomainGeometry.SM.Differentiable_Manifold (
  IsImmersion
  IsSubmersion
  diffeomorphism_homeomorphism
  smooth_continuous
)

end CATEPTMain.Geometry.SM.Differentiable_Manifold
