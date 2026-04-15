set_option autoImplicit false

/-!
# VML Steady-State Integration Bridge

Bridge contract for integrating the external Lean formalization repository
"Formal Verification of the Vlasov-Maxwell-Landau Steady-State Theorem"
into CATEPT in two phases:

- Phase-1: bridge-contract mode (`legacy_port_required`)
- Phase-2: native import mode after Lean 4.29 port (`direct_4_29`)

This file intentionally avoids direct imports from the external repository so
it remains build-stable while the external code is still on Lean 4.24.
-/

namespace CATEPTMain.Integration.VMLSteadyState

/-- Abstract witness for the key mathematical outputs CATEPT wants from the
VML steady-state formalization. -/
structure VMLSteadyStateWitness where
  /-- Entropy-dissipation chain and nullspace characterization are available. -/
  entropyDissipationChainAvailable : Prop
  /-- Steady state implies local Maxwellian structure. -/
  localMaxwellianAvailable : Prop
  /-- Transport and polynomial constraints force equilibrium parameters. -/
  transportConstraintChainAvailable : Prop
  /-- Main rigidity conclusion available: Maxwellian profile, E=0, B=constant. -/
  equilibriumRigidityAvailable : Prop
  /-- Audit evidence exists for no hidden custom axioms beyond standard ones. -/
  axiomAuditAvailable : Prop

/-- Phase-1 contract used by integration modules while native dependency is
not yet imported. -/
def VMLSteadyStateIntegrationContract (w : VMLSteadyStateWitness) : Prop :=
  w.entropyDissipationChainAvailable ∧
  w.localMaxwellianAvailable ∧
  w.transportConstraintChainAvailable ∧
  w.equilibriumRigidityAvailable ∧
  w.axiomAuditAvailable

/-- Phase-1 bridge theorem: package-level assumptions imply the integration
contract CATEPT consumes. -/
theorem vmlSteadyState_integration_contract
    (w : VMLSteadyStateWitness)
    (hEntropy : w.entropyDissipationChainAvailable)
    (hLocal : w.localMaxwellianAvailable)
    (hTransport : w.transportConstraintChainAvailable)
    (hRigidity : w.equilibriumRigidityAvailable)
    (hAudit : w.axiomAuditAvailable) :
    VMLSteadyStateIntegrationContract w :=
  ⟨hEntropy, hLocal, hTransport, hRigidity, hAudit⟩

end CATEPTMain.Integration.VMLSteadyState
