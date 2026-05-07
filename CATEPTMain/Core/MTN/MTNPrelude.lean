import CATEPTPluginDomainCore.MTN.MTNPrelude

/-!
# MTNPrelude — re-export shim
Authoritative source: `CATEPTPluginDomainCore.MTN.MTNPrelude` in sibling repo
[`jagg-ix/catept-domain-core`](https://github.com/jagg-ix/catept-domain-core).
-/

set_option autoImplicit false

namespace CATEPTMain.Core.MTN

export CATEPTPluginDomainCore.MTN (
  kronecker_assoc
  kronecker_det
  kronecker_one_left
  kronecker_one_right
  kronecker_smul_left
  kronecker_trace
  kronecker_transpose
)

end CATEPTMain.Core.MTN
