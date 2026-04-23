import NavierStokesClean.CATEPT.DSL.WorkflowCorrectness

/-!
# NavierStokesClean.CATEPT.DSL.BackendContracts

Phase-4 backend contract layer:
- assume/guarantee contract shape for native backends
- refinement condition from runtime payload to backend output
- proofs that backend execution preserves compiled/source semantics.
-/

namespace NavierStokesClean.CATEPT.DSL

/-- Backend-reported output envelope. -/
structure BackendOutput where
  tauEntNext : Rat
  deltaSI : Rat
  lambdaEff : Rat
  residualNorm : Rat
  deriving DecidableEq, Repr

/-- Convert backend output into DSL state view. -/
def backendOutputToState (out : BackendOutput) : State :=
  { tauEnt := out.tauEntNext, deltaSI := out.deltaSI, lambdaEff := out.lambdaEff }

/-- Abstract backend executor over lowered payloads. -/
abbrev BackendExecutor := RuntimePayload → BackendOutput

/-- Backend refinement: preserves the semantic payload fields exactly. -/
def BackendRefinesPayload (run : BackendExecutor) : Prop :=
  ∀ p : RuntimePayload,
    (run p).tauEntNext = p.tauEntNext ∧
    (run p).deltaSI = p.deltaSI ∧
    (run p).lambdaEff = p.lambdaEff

/-- Backend residual contract: diagnostic residuals are non-negative. -/
def BackendResidualNonneg (run : BackendExecutor) : Prop :=
  ∀ p : RuntimePayload, 0 ≤ (run p).residualNorm

/-- Assumption/guarantee contract schema for lowered execution. -/
structure AssumeGuaranteeContract where
  assume : RuntimePayload → Prop
  guarantee : State → BackendOutput → Prop

/-- Canonical native contract used in phase-4 proofs. -/
def nativeContract : AssumeGuaranteeContract where
  assume := fun p => 0 ≤ p.deltaSI ∧ 0 ≤ p.lambdaEff
  guarantee := fun expected out =>
    SimulationRel expected (backendOutputToState out) ∧ 0 ≤ out.residualNorm

/-- Apply backend for one lowered IR step. -/
def runWithBackend (run : BackendExecutor) (node : IRNode) (s : State) : State :=
  backendOutputToState (run (lowerPayload node s))

theorem simulationRel_symm {a b : State} :
    SimulationRel a b → SimulationRel b a := by
  intro h
  rcases h with ⟨hTau, hDelta, hLam⟩
  exact ⟨hTau.symm, hDelta.symm, hLam.symm⟩

theorem simulationRel_trans {a b c : State} :
    SimulationRel a b → SimulationRel b c → SimulationRel a c := by
  intro hab hbc
  rcases hab with ⟨hTau1, hDelta1, hLam1⟩
  rcases hbc with ⟨hTau2, hDelta2, hLam2⟩
  exact ⟨hTau1.trans hTau2, hDelta1.trans hDelta2, hLam1.trans hLam2⟩

theorem simulationRel_implies_eq (a b : State) :
    SimulationRel a b → a = b := by
  intro h
  cases a with
  | mk aTau aDelta aLam =>
      cases b with
      | mk bTau bDelta bLam =>
          rcases h with ⟨hTau, hDelta, hLam⟩
          simp at hTau hDelta hLam
          simp [hTau, hDelta, hLam]

theorem runWithBackend_eq_step_of_refinement
    (run : BackendExecutor) (href : BackendRefinesPayload run)
    (node : IRNode) (s : State) :
    runWithBackend run node s = step (decodeIR node) s := by
  have hStepPayload : SimulationRel (step (decodeIR node) s) (payloadToState (lowerPayload node s)) :=
    lowerPayload_simulation node s
  rcases href (lowerPayload node s) with ⟨hTau, hDelta, hLam⟩
  have hPayloadBackend :
      SimulationRel (payloadToState (lowerPayload node s)) (runWithBackend run node s) := by
    unfold SimulationRel payloadToState runWithBackend backendOutputToState
    constructor
    · simpa using hTau.symm
    · constructor
      · simpa using hDelta.symm
      · simpa using hLam.symm
  have hStepBackend : SimulationRel (step (decodeIR node) s) (runWithBackend run node s) :=
    simulationRel_trans hStepPayload hPayloadBackend
  exact (simulationRel_implies_eq _ _ hStepBackend).symm

theorem runWithBackend_contract_sound
    (run : BackendExecutor)
    (href : BackendRefinesPayload run)
    (hres : BackendResidualNonneg run)
    (node : IRNode) (s : State) :
    nativeContract.guarantee (step (decodeIR node) s) (run (lowerPayload node s)) := by
  unfold nativeContract
  constructor
  · have hEq : runWithBackend run node s = step (decodeIR node) s :=
      runWithBackend_eq_step_of_refinement run href node s
    have hSim : SimulationRel (step (decodeIR node) s) (runWithBackend run node s) := by
      simpa [hEq] using (simulationRel_refl (step (decodeIR node) s))
    simpa [runWithBackend]
  · exact hres (lowerPayload node s)

/-- Execute an IR workflow through a backend executor. -/
def execIRWithBackend (run : BackendExecutor) : List IRNode → State → State
  | [], s => s
  | n :: ns, s => execIRWithBackend run ns (runWithBackend run n s)

theorem execIRWithBackend_eq_execList_decode
    (run : BackendExecutor) (href : BackendRefinesPayload run) :
    ∀ nodes s, execIRWithBackend run nodes s = execList (decodeWorkflow nodes) s := by
  intro nodes
  induction nodes with
  | nil =>
      intro s
      simp [execIRWithBackend, decodeWorkflow, execList]
  | cons n ns ih =>
      intro s
      simp [execIRWithBackend, decodeWorkflow, execList, ih,
        runWithBackend_eq_step_of_refinement, href]

/-- Source workflow execution routed through compile + backend. -/
def execSourceWithBackend (run : BackendExecutor) (wf : List SourceStep) (s : State) : State :=
  execIRWithBackend run (compileWorkflow wf) s

/-- Main phase-4 theorem: backend refinement preserves source workflow semantics. -/
theorem execSourceWithBackend_semantics
    (run : BackendExecutor) (href : BackendRefinesPayload run)
    (wf : List SourceStep) (s : State) :
    execSourceWithBackend run wf s = interpretSource wf s := by
  unfold execSourceWithBackend
  calc
    execIRWithBackend run (compileWorkflow wf) s
        = execList (decodeWorkflow (compileWorkflow wf)) s :=
          execIRWithBackend_eq_execList_decode run href (compileWorkflow wf) s
    _ = interpretCompiled wf s := by
          simp [interpretCompiled]
    _ = interpretSource wf s := compileWorkflow_semantics_preserved wf s

/-- Well-formedness is preserved through backend execution under refinement. -/
theorem execSourceWithBackend_preserves_wellFormed
    (run : BackendExecutor) (href : BackendRefinesPayload run)
    (wf : List SourceStep) (s : State) (hs : WellFormed s) :
    WellFormed (execSourceWithBackend run wf s) := by
  simpa [execSourceWithBackend_semantics run href wf s, interpretSource] using
    (execList_preserves_wellFormed (wf.map sourceToCommand) s hs)

end NavierStokesClean.CATEPT.DSL
