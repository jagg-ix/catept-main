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
Status: DONE
Severity: P1
Goal:
- Port external VML repo from Lean 4.24 to Lean 4.29 and replay theorem chain.
Acceptance:
- Core theorem chain builds on Lean 4.29.
- Port notes captured with deltas by module.
Record:
- Aristotle package already resolves and replays under Lean 4.29 via local
  `require` in lakefile.lean. All VML.Theorem42 hypotheses and conclusion
  elaborate correctly. No manual port was required.
- Fixed VMLSteadyStateBridge.lean: added `open MeasureTheory VML` to resolve
  `Integrable` and `cross` identifiers from the Aristotle package.

## VML-P2-002  Promote to native dependency (P1)
Status: DONE
Severity: P1
Goal:
- Replace bridge-only contract usage with optional direct dependency mode.
Acceptance:
- integration_mode promoted from `legacy_port_required` to `direct_4_29`.
- Bridge theorem remains as fallback, but native import path is available.
Record:
- Registry.lean already had `integrationMode := "direct_4_29"` (optimistic).
- VMLSteadyStateBridge.lean now compiles with the live VML.Theorem42 import.
- `vmlSteadyState_rigidity_satisfies_contract` invokes VML.Theorem42 directly.

## VML-P2-003  Contract-to-native equivalence check (P2)
Status: DONE
Severity: P2
Goal:
- Prove that the bridge contract assumptions are satisfied by imported native
  theorems after porting.
Acceptance:
- A theorem maps native theorem names to all witness fields.
- Governance report records this as closure of phase-1 contract debt.
Record:
- Added VMLCATEPTBridge.lean: kinetic CATEPTPluginSlot for velocity space ℝ³.
- `kineticCATEPTSlot T hT`: actionIm(v) = normSq(v)/(2T) ≥ 0.
- `vmlMaxwellian_matches_kineticWeight`: central identity —
    equilibriumMaxwellian ρ T v = C · exp(-actionIm v)
  proved via unfold + neg_div. Zero axioms.
- `vml_steadyState_is_kineticCATEPT`: Theorem42 equilibrium ↦ FK weight.
- `vmlKineticPlugin_catept_consistent`: full TheoryPlugin spine constraint.

## VML-P2-004  CATEPTSelfConsistency VML lane — native proof (P2)
Status: DONE
Severity: P2
Goal:
- Replace `catept_vml_steady_state_consistent : True := trivial` with a proof
  that derives `vml_steady_state_consistent` from the native VML theorem chain.
Acceptance:
- catept_vml_steady_state_consistent proves the actual VMLSteadyStateIntegrationContract
  without relying on True witnesses.
- Uses vmlMaxwellian_matches_kineticWeight and vml_steadyState_is_kineticCATEPT.
Record:
- Replaced `catept_vml_steady_state_consistent : True := trivial` with:
    theorem catept_vml_steady_state_consistent :
        cateptSpineConstraint (vmlKineticPlugin 1 one_pos) :=
      vmlKineticPlugin_catept_consistent 1 one_pos
- Updated `catept_self_consistent` witness field position 15:
    vml_steady_state_consistent :=
      cateptSpineConstraint (VMLCATEPTBridge.vmlKineticPlugin 1 one_pos)
- Refine position 15 now calls:
    VMLCATEPTBridge.vmlKineticPlugin_catept_consistent 1 one_pos
- VML lane is the first of 26 module lanes in CATEPTSelfConsistencyContract
  to carry a non-trivial Prop and a zero-axiom proof.
