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

/-!
## REPLYID: CAT-EPT-20260505-02 — Middle targets (NH spectral leverage)

Scope: integrate non-Hermitian spectral machinery into CAT/EPT via
`H_eff = H_R - i H_I`, proper-time/heat-kernel links, and response theory.

### NHQM-MID-001  Spectral calibration of entropic time (P1)
Goal:
  Define the spectral map
    epsilon_n = E_n - i * Gamma_n / 2
    tau_ent_n = Gamma_n * t / (2 * hbar)
  and record a carrier lemma connecting `H_I` to `Gamma_n`.
Status: DONE
Record:
  - Added `NHQMMiddleTargets.lean` with `epsilonComplex`, `tauEntSpectral`,
    and `gammaFromHIClaim`.

### NHQM-MID-002  Non-Hermitian Fermi-Dirac occupation (P1)
Goal:
  Add a carrier for `f_eff(epsilon, beta)` and wire it into
  `nhStateOccupation` as the equilibrium rule for complex spectra.
Status: DONE
Record:
  - `fEff` carrier and `nhStateOccupation_eq_fEff` in
    `NHQMMiddleTargets.lean` (uses `nhFermiDirac`).

### NHQM-MID-003  Persistent-current response template (P2)
Goal:
  Define
    F_eff = sum_n F_eff(epsilon_n, beta)
    J_alpha = - dF_eff / d alpha
  and add a bridge placeholder for flux/holonomy response.
  Status: DONE
  Record:
    - `ResponseTemplate` and `responseTemplateFromSpec` in
      `NHQMMiddleTargets.lean`.

### NHQM-MID-004  Exceptional-point regularity (P2)
Goal:
  Add an EP continuity lemma for matrix functions
    (f(epsilon_plus) - f(epsilon_minus)) / (epsilon_plus - epsilon_minus)
    -> f'(epsilon_EP)
  and link to `nhPersistentCurrentField_continuousAtEP`.
Status: DONE
Record:
  - Proof-carrying `EPRegularityCarrier` and `epRegularityCarrier` in
    `NHQMMiddleTargets.lean` (links to `nhFermiDirac_continuousAtEP`).

### NHQM-MID-005  Proper-time determinant linkage (P2)
Goal:
  Connect
    Tr log H_eff <-> integral_0^inf (d sigma / sigma) Tr exp(-sigma H_eff)
  to the proper-time/heat-kernel carriers in `CATEPT_ProperTime`.
Status: DONE
Record:
  - `ProperTimeDeterminantCarrier` with `traceLog`, `properTimeIntegral`,
    and `linkClaim` in `NHQMMiddleTargets.lean`.

### NHQM-MID-006  Gauge/QCD holonomy response (P3)
Goal:
  Add a placeholder bridge
    D_eff[A] psi_n = epsilon_n[A] psi_n
    J_alpha[A] = - dF_eff[A] / d alpha
  with alpha in {holonomy, theta, chemical potential}.
Status: DONE
Record:
  - `GaugeHolonomyResponseCarrier` anchored to `ResponseTemplate` in
    `NHQMMiddleTargets.lean`.

### NHQM-MID-007  Curved-spacetime response (P3)
Goal:
  Add a carrier for
    O_eff[g, Phi] psi_n = epsilon_n[g] psi_n
    S_I,mu,nu = -(2 / sqrt(-g)) d S_I / d g^{mu nu}
  and a conservation placeholder for `nabla^mu S_I,mu,nu = 0`.
Status: DONE
Record:
  - `CurvedSpacetimeResponseCarrier` with stress-energy/conservation fields
    in `NHQMMiddleTargets.lean`.
-/
