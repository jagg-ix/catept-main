import CATEPTPluginDomainMtn.MTNPrelude

/-!
# MTNPrelude — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-mtn` (T62c, third
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainMtn.MTNPrelude`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Core.MTN` so existing
imports of `CATEPTMain.Core.MTN.MTNPrelude` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Core.MTN

export CATEPTPluginDomainMtn (
  kronecker_assoc
  kronecker_det
  kronecker_one_left
  kronecker_one_right
  kronecker_smul_left
  kronecker_trace
  kronecker_transpose
)

end CATEPTMain.Core.MTN
