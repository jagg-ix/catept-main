import CATEPTMain.Quantum.QUANTUM.QFIToolbox
import CATEPTMain.Quantum.QUANTUM.PhysicsHamiltonians
import CATEPTPluginDomainQuantum.QFIMeasurements

/-!
# QFIMeasurements — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.QFIMeasurements`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.QFIMeasurements` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum (
  averageMagnetization
  localMagnetization
  localMagnetization_real
  neelState_af_order
  neelState_fm_order_zero
  orderParameterAF
  orderParameterFM
  partialTransposeQFI
  phaseShiftGenerator
  phaseShiftGenerator_hermitian
  phaseShiftZ
  phaseShiftZ_eq_halfTotalSz
  stateQFIManual
  stateQFIManual_ge
  tensorSum
  tensorSum_hermitian
  tensorSum_trace
)

end CATEPTMain.Quantum.QUANTUM
