import CATEPTMain.Quantum.QUANTUM.QuantumPrelude
import CATEPTMain.Quantum.QUANTUM.QuantumGates
import CATEPTMain.Quantum.QUANTUM.DensityMatrix
import CATEPTMain.Quantum.QUANTUM.QFIScaffold
import CATEPTMain.Quantum.QUANTUM.JordanWigner
import CATEPTMain.Quantum.QUANTUM.QFIToolbox
import CATEPTMain.Quantum.QUANTUM.PhysicsHamiltonians
import CATEPTMain.Quantum.QUANTUM.QFIMeasurements

/-!
# Quantum Port — Root Module

Re-export shim barrel for the QUANTUM domain bundle (T61).
The 9 modules below have moved to sibling repo
`jagg-ix/catept-domain-quantum` under namespace `CATEPTPluginDomainQuantum`.
This file re-imports the in-tree shims so existing
`import CATEPTMain.Quantum.QUANTUM.QuantumPort` statements still see all
9 modules in scope.
-/
