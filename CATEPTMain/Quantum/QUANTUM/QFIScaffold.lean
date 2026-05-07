import CATEPTMain.Quantum.QUANTUM.DensityMatrix
import CATEPTPluginDomainQuantum.QUANTUM.QFIScaffold

/-!
# QFIScaffold — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.QFIScaffold`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.QFIScaffold` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum.QUANTUM (
  cramer_rao_scalar
  qfi
  qfi_family
)

end CATEPTMain.Quantum.QUANTUM
