/-!
# VML Integration Worklog — Bridge First, Native Dependency After Port

Repository:
https://github.com/allofphysicsgraph/Formal-Verification-of-the-Vlasov-Maxwell-Landau-Steady-State-Theorem.git

Tracking mode:
- Phase-1: bridge contract first
- Phase-2: native dependency after Lean 4.29 port

This file is a worklog and issue tracker. It defines no runnable Lean code.
-/

## VML-PRE-001  Register external repo in integration registries (P1)
Status: DONE
Severity: P1
Goal:
- Ensure the VML repository is visible to CATEPT integration governance and
  appears in both integration manifests.
Acceptance:
- Registry entry exists with mode `legacy_port_required`.
- repos.yaml entry exists with phase-1 and phase-2 scope.
Record:
- Added external registry entry with leverage module
  `CATEPTMain.Integration.VMLSteadyStateBridge`.
- Added integration metadata entry with worklog target path.

## VML-PRE-002  Define bridge contract module (P1)
Status: DONE
Severity: P1
Goal:
- Add a build-stable bridge contract file that captures what CATEPT expects
  from VML while direct import is blocked by toolchain mismatch.
Acceptance:
- New bridge module compiles standalone.
- Witness and contract include entropy, local Maxwellian, transport chain,
  equilibrium rigidity, and axiom-audit fields.
Record:
- Created `CATEPTMain.Integration.VMLSteadyStateBridge` with witness,
  contract, and bridge theorem.

## VML-INT-001  Consume bridge contract from downstream integration (P2)
Status: DONE
Severity: P2
Goal:
- Add an integration theorem that uses the VML bridge contract as an input to
  CAT/EPT assumptions for kinetic steady-state arguments.
Acceptance:
- New downstream theorem references `VMLSteadyStateIntegrationContract`.
- No new axioms introduced in the downstream module.
Record:
- Added VML consistency slot `vml_steady_state_consistent` to
  `CATEPTAFPConsistencyWitness` in
  `CATEPTMain/Integration/CATEPTSelfConsistency.lean`.
- Extended `CATEPTSelfConsistencyContract` with VML conjunct.
- Added theorem `catept_vml_steady_state_consistent` with hypothesis
  `hContract : VMLSteadyStateIntegrationContract w`.
- Updated `catept_self_consistent` witness/proof tuple to include VML.

## VML-QA-001  Phase-1 governance checks (P2)
Status: DONE
Severity: P2
Goal:
- Track explicit phase-1 quality gates so contract mode does not drift into
  implicit native dependency assumptions.
Acceptance:
- CI check verifies no direct `import` from VML repository in phase-1.
- Axiom-audit flag is required in all phase-1 witnesses.
Record:
- Added phase-1 VML import guard to `scripts/check_integration.sh`.
- Guard blocks direct external VML imports in `CATEPTMain/Integration/*.lean`
  while allowing local `CATEPTMain.*` imports.
- Validation run: integration check script reports
  `OK       phase-1 VML import guard`.

## VML-P2-001  Port VML repo to Lean 4.29 (P1)
Status: TODO
Severity: P1
Goal:
- Port external VML repo from Lean 4.24 to Lean 4.29 and replay theorem chain.
Acceptance:
- Core theorem chain builds on Lean 4.29.
- Port notes captured with deltas by module.

## VML-P2-002  Promote to native dependency (P1)
Status: TODO
Severity: P1
Goal:
- Replace bridge-only contract usage with optional direct dependency mode.
Acceptance:
- integration_mode promoted from `legacy_port_required` to `direct_4_29`.
- Bridge theorem remains as fallback, but native import path is available.

## VML-P2-003  Contract-to-native equivalence check (P2)
Status: TODO
Severity: P2
Goal:
- Prove that the bridge contract assumptions are satisfied by imported native
  theorems after porting.
Acceptance:
- A theorem maps native theorem names to all witness fields.
- Governance report records this as closure of phase-1 contract debt.
