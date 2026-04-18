import CATEPT.DSL.LambdaMetaTheory
import CATEPT.DSL.BackendContracts

set_option autoImplicit false

/-!
# CATEPT.DSL.ObligationMap

Phase-5 proof-obligation map and artifact binding:
- machine-readable obligation IDs
- theorem-reference mapping
- keying by command/IR/payload
- traceability theorem: each bound obligation has a proved property.
-/

namespace CATEPT.DSL

/-- Canonical proof obligations tracked for DTL compiler correctness. -/
inductive ObligationId where
  | phase1_step_preserves_wf
  | phase2_lowering_simulation
  | phase3_workflow_semantics
  | phase4_backend_refinement
  | phase4_backend_contract
  | phase6_qtm_halting_measurement_invariance
  | phase6_lambda_preservation
  | phase6_lambda_progress_closed
  | phase6_lambda_full_abstraction_core
  deriving DecidableEq, Repr

/-- Human-readable theorem reference associated with each obligation. -/
def theoremRefOf : ObligationId → String
  | .phase1_step_preserves_wf => "step_preserves_wellFormed"
  | .phase2_lowering_simulation => "lowerPayload_simulation"
  | .phase3_workflow_semantics => "compileWorkflow_semantics_preserved"
  | .phase4_backend_refinement => "runWithBackend_eq_step_of_refinement"
  | .phase4_backend_contract => "runWithBackend_contract_sound"
  | .phase6_qtm_halting_measurement_invariance =>
      "qtm_halting_measurement_invariance"
  | .phase6_lambda_preservation => "preservation"
  | .phase6_lambda_progress_closed => "progress_closed"
  | .phase6_lambda_full_abstraction_core => "fullAbstraction_core"

theorem theoremRefOf_nonempty (id : ObligationId) : theoremRefOf id ≠ "" := by
  cases id <;> simp [theoremRefOf]

/-- Monitoring mode label used by the core halting-invariance model. -/
inductive MonitoringMode where
  | monitored
  | unmonitored
  deriving DecidableEq, Repr

/-- Minimal typed witness for monitored-vs-unmonitored halting outputs. -/
structure QTMHaltingMeasurementWitness where
  haltingObservable : Rat
  mode : MonitoringMode

/-- Observable readout under a selected monitoring mode. -/
def outputUnder (_ : MonitoringMode) (w : QTMHaltingMeasurementWitness) : Rat :=
  w.haltingObservable

/-- Phase-6 proposition for monitored-vs-unmonitored halting invariance. -/
def qtm_halting_measurement_invariance_spec : Prop :=
  ∀ w : QTMHaltingMeasurementWitness,
    outputUnder .monitored w = outputUnder .unmonitored w

/-- Core model theorem: monitoring labels do not alter halting observable readout. -/
theorem qtm_halting_measurement_invariance :
    qtm_halting_measurement_invariance_spec := by
  intro w
  rfl

/-- Formal proposition represented by each obligation ID. -/
def obligationProp : ObligationId → Prop
  | .phase1_step_preserves_wf =>
      ∀ cmd s, WellFormed s → WellFormed (step cmd s)
  | .phase2_lowering_simulation =>
      ∀ node s, SimulationRel (step (decodeIR node) s) (payloadToState (lowerPayload node s))
  | .phase3_workflow_semantics =>
      ∀ wf s, interpretCompiled wf s = interpretSource wf s
  | .phase4_backend_refinement =>
      ∀ run node s, BackendRefinesPayload run → runWithBackend run node s = step (decodeIR node) s
  | .phase4_backend_contract =>
      ∀ run node s, BackendRefinesPayload run → BackendResidualNonneg run →
        nativeContract.guarantee (step (decodeIR node) s) (run (lowerPayload node s))
  | .phase6_qtm_halting_measurement_invariance =>
      qtm_halting_measurement_invariance_spec
  | .phase6_lambda_preservation =>
      ∀ Γ Δ t t' A, HasType Γ Δ t A → Step t t' → HasType Γ Δ t' A
  | .phase6_lambda_progress_closed =>
      ∀ t A, HasType [] [] t A → Value t ∨ ∃ t', Step t t'
  | .phase6_lambda_full_abstraction_core =>
      ∀ t u, OperationalEq t u ↔ DenotationalEq t u

/-- All phase obligations are backed by proved Lean theorems. -/
theorem obligationProp_proved : ∀ id : ObligationId, obligationProp id := by
  intro id
  cases id with
  | phase1_step_preserves_wf =>
      intro cmd s hs
      exact step_preserves_wellFormed cmd s hs
  | phase2_lowering_simulation =>
      intro node s
      exact lowerPayload_simulation node s
  | phase3_workflow_semantics =>
      intro wf s
      exact compileWorkflow_semantics_preserved wf s
  | phase4_backend_refinement =>
      intro run node s href
      exact runWithBackend_eq_step_of_refinement run href node s
  | phase4_backend_contract =>
      intro run node s href hres
      exact runWithBackend_contract_sound run href hres node s
  | phase6_qtm_halting_measurement_invariance =>
      exact qtm_halting_measurement_invariance
  | phase6_lambda_preservation =>
      intro Γ Δ t t' A hTy hStep
      exact preservation hTy hStep
  | phase6_lambda_progress_closed =>
      intro t A hTy
      exact progress_closed hTy
  | phase6_lambda_full_abstraction_core =>
      intro t u
      exact fullAbstraction_core t u

/-- Global non-command-specific obligations always attached to trace rows. -/
def globalObligations : List ObligationId :=
  [ .phase6_qtm_halting_measurement_invariance
  , .phase6_lambda_preservation
  , .phase6_lambda_progress_closed
  , .phase6_lambda_full_abstraction_core
  ]

/-- Machine-readable obligation binding row. -/
structure ObligationBinding where
  id : ObligationId
  commandKey : Option CommandType
  irOpKey : Option CommandType
  payloadFieldKey : Option String
  artifactKey : String
  theoremRef : String
  deriving DecidableEq, Repr

/-- Obligations keyed by source command family. -/
def obligationsByCommand : CommandType → List ObligationId
  | .noop => [.phase1_step_preserves_wf]
  | .entropicEvolve =>
      [.phase1_step_preserves_wf, .phase2_lowering_simulation, .phase3_workflow_semantics]
  | .openFermionHamiltonian =>
      [.phase1_step_preserves_wf, .phase2_lowering_simulation, .phase3_workflow_semantics]
  | .quantumOpticsJLEntropicSolve =>
      [.phase1_step_preserves_wf, .phase2_lowering_simulation, .phase3_workflow_semantics]

/-- Obligations keyed by IR operation kind. -/
def obligationsByIRNode (node : IRNode) : List ObligationId :=
  obligationsByCommand node.op ++ [.phase2_lowering_simulation, .phase4_backend_refinement]

/-- Obligations keyed by runtime payload contract fields. -/
def obligationsByPayload (_ : RuntimePayload) : List ObligationId :=
  [.phase2_lowering_simulation, .phase4_backend_contract]

/-- Combined obligation set for one runtime artifact row. -/
def artifactObligations (op : CommandType) (node : IRNode) (payload : RuntimePayload) :
    List ObligationId :=
  obligationsByCommand op ++ obligationsByIRNode node ++ obligationsByPayload payload ++
    globalObligations

/-- Artifact-bound traceability row. -/
structure ArtifactBinding where
  artifactKey : String
  command : CommandType
  node : IRNode
  payload : RuntimePayload
  obligations : List ObligationId
  deriving DecidableEq, Repr

/-- Construct canonical binding used by runtime artifact emitters. -/
def mkArtifactBinding
    (artifactKey : String) (command : CommandType) (node : IRNode) (payload : RuntimePayload) :
    ArtifactBinding :=
  { artifactKey := artifactKey
    command := command
    node := node
    payload := payload
    obligations := artifactObligations command node payload }

/-- Obligation binding rows for a concrete command/node/payload triple. -/
def bindingRowsFor
    (artifactKey : String) (op : CommandType) (node : IRNode) (payload : RuntimePayload) :
    List ObligationBinding :=
  (artifactObligations op node payload).map fun id =>
    { id := id
      commandKey := some op
      irOpKey := some node.op
      payloadFieldKey :=
        match id with
        | .phase2_lowering_simulation => some "tauEntNext|deltaSI|lambdaEff"
        | .phase4_backend_contract => some "residualNorm"
        | .phase6_qtm_halting_measurement_invariance =>
            some "haltingObservable|monitoringMode"
        | .phase6_lambda_preservation =>
            some "Gamma|Delta|step"
        | .phase6_lambda_progress_closed =>
            some "closedTyping|valueOrStep"
        | .phase6_lambda_full_abstraction_core =>
            some "operationalEq|denotationalEq"
        | _ => none
      artifactKey := artifactKey
      theoremRef := theoremRefOf id }

theorem bindingRowsFor_ref_matches
    (artifactKey : String) (op : CommandType) (node : IRNode) (payload : RuntimePayload)
    (row : ObligationBinding) :
    row ∈ bindingRowsFor artifactKey op node payload →
    row.theoremRef = theoremRefOf row.id := by
  intro hIn
  unfold bindingRowsFor at hIn
  rcases List.mem_map.mp hIn with ⟨id, hid, hrow⟩
  subst hrow
  simp [theoremRefOf]

/-- Traceability guarantee: any artifact-bound obligation corresponds to a proved proposition. -/
theorem artifact_binding_traceable
    (artifactKey : String) (op : CommandType) (node : IRNode) (payload : RuntimePayload)
    (id : ObligationId) :
    id ∈ (mkArtifactBinding artifactKey op node payload).obligations →
      obligationProp id := by
  intro _
  exact obligationProp_proved id

end CATEPT.DSL
