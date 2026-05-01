/-
# NHQM Port — Non-Hermitian Quantum Mechanics (Phase 1)

AFP bridge for the Non-Hermitian Fermi-Dirac persistent current theory:
  Shen, Lu, Lado, Trif, PRL 133, 086301 (2024)

Source: `(private intake)`

## Files

| File                  | Content                                              |
|-----------------------|------------------------------------------------------|
| NHQMPrelude.lean      | NH Hamiltonian, complex eigenvalues, nhFermiDirac,   |
|                       | persistentCurrentFromSpec, EP continuity axiom       |
| NHQMCATEPTBridge.lean | CATEPTPluginSlot + TheoryPlugin for NHQM             |

## CATEPT connection

  actionIm(n) = γₙ  (decay rate, ≥ 0)
  eptClock(n) = γₙ/ħ
  cateptConsistencyConstraint: trivial (actionIm/ħ = eptClock)

  At exceptional points: eptClock(m) = eptClock(n), consistent with
  the paper's continuity-of-persistent-current result.
-/

import CATEPTMain.NHQM.NHQMPrelude
import CATEPTMain.NHQM.NHQMCATEPTBridge
