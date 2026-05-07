import CATEPTMain.Quantum.QUANTUM.DensityMatrix
import CATEPTMain.Quantum.QUANTUM.QFIScaffold
import CATEPTPluginDomainQuantum.QUANTUM.QFIToolbox

/-!
# QFIToolbox — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.QFIToolbox`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.QFIToolbox` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum.QUANTUM (
  bipartiteEntanglementEntropy
  bipartiteEntanglementEntropy_nonneg
  boundQFI
  boundQFI_k1
  boundQFI_kL
  collectiveSpin
  ghz_bipartite_entropy
  mpeFromQFI
  qfi_entanglement_detection
  rhoQFI_spectral_formula
  stateQFI
  stateQFI_nonneg
  traceDistance
  traceDistance_bounded
  traceDistance_symm
  traceNorm
  vonNeumannEntropy
  vonNeumannEntropy_le_log
  vonNeumannEntropy_nonneg
  vonNeumannEntropy_pure
)

end CATEPTMain.Quantum.QUANTUM
