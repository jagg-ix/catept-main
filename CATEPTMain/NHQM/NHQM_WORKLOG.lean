/-!
# NHQM WORKLOG — Non-Hermitian Persistent Current Bridge

Source paper:
  Shen, Lu, Lado, Trif (PRL 133, 086301, 2024)
  "Non-Hermitian Fermi-Dirac Distribution in Persistent Current Transport"

## Current integration status

- `NHQMPrelude.lean`
  - [x] `NHHamiltonian` structure
  - [x] spectral placeholders: `complexEigenvalueRe`, `complexEigenvalueIm`
  - [x] EP predicates: `exceptionalPointAt`, `exceptionalPointAtStrong`
  - [x] NH FD + persistent current phase-1 axioms
  - [x] branch wrappers: `nhEnergyBranch`, `nhDecayBranch`, `nhStateOccupation`
  - [x] continuity wrapper: `nhPersistentCurrentField_continuousAtEP`

- `NHQMCATEPTBridge.lean`
  - [x] `nhqmCATEPTSlot` with `actionIm = γₙ`, `eptClock = γₙ/ħ`
  - [x] slot consistency theorem
  - [x] EP clock equality theorem
  - [x] EP FK-weight equality theorem (`nhqmFKWeight_at_EP`)
  - [x] plugin constructor `nhqmPlugin`
  - [x] plugin-level EP continuity theorem

## Phase-2 targets

1. `nhFermiDirac`
   - Replace axiom with proof from Matsubara/digamma identity.
   - Planned bridge: `AFPBridge/QUANTUM/QFIScaffold`.

2. `persistentCurrentFromSpec`
   - Replace axiom with `HasDerivAt`-based derivation on eigenvalue branches.
   - Planned bridge: `AFPBridge/CALCULUS/*`.

3. `nhFermiDirac_continuousAtEP`
   - Replace axiom with analyticity/continuity derivation in `γ`.
   - Target theorem: continuity of `nhPersistentCurrentField` at EP.

4. `complexEigenvalueRe/Im`
   - Promote scalar branch axioms to full matrix-eigenvalue interface.
   - Planned bridge: `AFPBridge/HSTP/Eigenvalues`, `AFPBridge/MTN/Eigenvalues_Kron`.

## External evidence path (non-lean artifacts)

- DMRG notebooks:
  - `Ring.ipynb`
  - `SNS.ipynb`
- Symbolic notebook:
  - `NonHermitianFermiDiracPersistentCurrent.nb`

These should be tracked as external evidence artifacts in the ZIL control plane.
-/

