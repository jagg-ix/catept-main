import CATEPTMain.Geometry.QUAT.QUATPrelude
import CATEPTPluginDomainQuat.Unit_Quaternions

/-!
# Unit_Quaternions — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quat` (T62a). Authoritative
source lives at `CATEPTPluginDomainQuat.Unit_Quaternions`. This shim
re-exports under the original namespace `CATEPTMain.Geometry.QUAT.Unit_Quaternions`.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.QUAT.Unit_Quaternions

export CATEPTPluginDomainQuat.Unit_Quaternions (
  fromAngleAxis
  fromAngleAxis_unit
  quatRotate
  quatRotate_neg
  quatRotate_norm
  quatRotate_pure
  unitQuat_mul
)

end CATEPTMain.Geometry.QUAT.Unit_Quaternions
