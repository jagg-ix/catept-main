import CATEPTMain.Quantum.QUANTUM.QuantumPrelude
import CATEPTPluginDomainQuantum.QuantumGates

/-!
# QuantumGates — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.QuantumGates`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.QuantumGates` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum (
  gateCNOT
  gateCZ
  gateComm
  gateH
  gateS
  gateSWAP
  gateT
  gateX
  gateZ
  heisenberg_uncertainty
  ket0
  ket1
  ketMinus
  ketPhiMinus
  ketPhiPlus
  ketPlus
  ketPsiMinus
  ketPsiPlus
  no_cloning_pure
  robertson_position_momentum
)

end CATEPTMain.Quantum.QUANTUM
