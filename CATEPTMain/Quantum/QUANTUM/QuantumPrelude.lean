import CATEPTPluginDomainQuantum.QuantumPrelude

/-!
# QuantumPrelude — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.QuantumPrelude`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.QuantumPrelude` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum (
  PureState
  QMat
  QSquare
  QVec
  adjoint
  anticomm
  comm
  expectVal
  isHermitian
  isPSD
  isUnitary
  partialTrace
  proj
  qTrace
  stdBasis
)

end CATEPTMain.Quantum.QUANTUM
