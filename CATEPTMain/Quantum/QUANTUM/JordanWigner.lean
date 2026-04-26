import CATEPTMain.Quantum.QUANTUM.QuantumPrelude
import CATEPTPluginDomainQuantum.JordanWigner

/-!
# JordanWigner — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.JordanWigner`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.JordanWigner` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum (
  jw_annihilation_nilpotent
  jw_car_different
  jw_car_same
  jw_creation_nilpotent
  jw_number_idempotent
  jw_number_spectrum
  spinMinus
  spinPlus
)

end CATEPTMain.Quantum.QUANTUM
