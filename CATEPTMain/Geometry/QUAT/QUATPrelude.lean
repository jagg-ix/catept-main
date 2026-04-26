import CATEPTPluginDomainQuat.QUATPrelude

/-!
# QUATPrelude — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quat` (T62a, second
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuat.QUATPrelude`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Geometry.QUAT` so
existing imports of `CATEPTMain.Geometry.QUAT.QUATPrelude` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.QUAT

export CATEPTPluginDomainQuat (
  IsUnitQuat
  isUnitQuat_iff_normSq
  quatI
  quatI_mul_J
  quatImI
  quatImJ
  quatImK
  quatJ
  quatJ_mul_K
  quatK
  quatK_mul_I
  quatRe
  quatVec
  quat_conj_def
  quat_normSq_eq_mul_conj
  unitQuat_inv_eq_conj
)

end CATEPTMain.Geometry.QUAT
