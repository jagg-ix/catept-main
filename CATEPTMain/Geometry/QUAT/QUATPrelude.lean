import CATEPTPluginDomainGeometry.QUAT.QUATPrelude

/-!
# QUATPrelude — re-export shim

Authoritative source: `CATEPTPluginDomainGeometry.QUAT.QUATPrelude` in
sibling repo [`jagg-ix/catept-domain-geometry`](https://github.com/jagg-ix/catept-domain-geometry).

This shim re-exports under the original `CATEPTMain.Geometry.QUAT` namespace
so existing imports compile unchanged after the QUAT bundle moved into the
geometry domain umbrella.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.QUAT

export CATEPTPluginDomainGeometry.QUAT (
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
