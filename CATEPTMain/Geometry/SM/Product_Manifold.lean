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
import CATEPTPluginDomainGeometry.SM.Product_Manifold

/-!
# Product_Manifold — re-export shim
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.SM.Product_Manifold

export CATEPTPluginDomainGeometry.SM.Product_Manifold (
  productModel
  smooth_fst
  smooth_prod_mk
  smooth_snd
  tangent_product_iso
)

end CATEPTMain.Geometry.SM.Product_Manifold
