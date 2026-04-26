import CATEPTMain.Quantum.QUANTUM.QuantumPrelude
import CATEPTPluginDomainQuantum.DensityMatrix

/-!
# DensityMatrix — re-export shim

Extracted to sibling repo `jagg-ix/catept-domain-quantum` (T61, first
domain-bundle extraction). Authoritative source lives at
`CATEPTPluginDomainQuantum.DensityMatrix`. This shim re-exports every public
declaration under the original namespace `CATEPTMain.Quantum.QUANTUM` so
existing imports of `CATEPTMain.Quantum.QUANTUM.DensityMatrix` continue to compile.
-/

set_option autoImplicit false

namespace CATEPTMain.Quantum.QUANTUM

export CATEPTPluginDomainQuantum (
  DensityMatrix
  LiouvilleKet
  LiouvilleTrajectory
  densityMatrixEvolution_doubleSpace_mapping
  densityMatrixEvolution_doubleSpace_mapping_for
  doubleSpaceSchrodinger
  doubleSpaceSchrodinger_zero
  doubleSpaceSchrodinger_zero_for_any_generator
  ghzDM
  ghzVec
  modularWeight
  modularWeight_add_const
  modularWeight_relative_const_free
  partialTrace_hermitian
  partialTrace_linear
  partialTrace_product
  partialTranspose
  pureDM
  relativeModularWeight
  relativeModularWeight_add_const
  relativeModularWeight_add_generator
  relativeModularWeight_refl
  relativeModularWeight_swap
  zeroLiouvilleTrajectory
)

end CATEPTMain.Quantum.QUANTUM
