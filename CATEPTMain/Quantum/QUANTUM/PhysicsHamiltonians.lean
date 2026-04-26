import CATEPTMain.Quantum.QUANTUM.JordanWigner
import CATEPTMain.Quantum.QUANTUM.DensityMatrix
import CATEPTPluginDomainQuantum.PhysicsHamiltonians

/-!
# PhysicsHamiltonians — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.PhysicsHamiltonians`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.PhysicsHamiltonians` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum (
  evolveState
  evolveState_norm_preserved
  heisenbergXX
  heisenbergXXZ_commutes_totalSz
  heisenbergXXZ_hermitian
  ket_DownUp
  ket_UpDown
  neelState
  neelState_unit
  spinX
  spinY
  spinZ
  timeEvolution
  timeEvolution_group
  timeEvolution_unitary
  xxModel
  xx_model_jordan_wigner
)

end CATEPTMain.Quantum.QUANTUM
