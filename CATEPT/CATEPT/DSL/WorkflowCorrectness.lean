import CATEPT.DSL.Lowering

/-!
# CATEPT.DSL.WorkflowCorrectness

Phase-3 workflow composition correctness:
- source workflow semantics
- compiled workflow semantics
- segment composition (`wf1 ++ wf2`)
- source-to-compiled semantic equivalence.
-/

namespace CATEPT.DSL

/-- Source-level workflow step before lowering. -/
structure SourceStep where
  op : CommandType
  deltaSIHint : Rat
  lambdaHint : Rat
  deriving DecidableEq, Repr

/-- Source interpretation into executable command. -/
def sourceToCommand (step : SourceStep) : Command :=
  { kind := step.op, deltaSIHint := step.deltaSIHint, lambdaHint := step.lambdaHint }

/-- Compiler lowering for a source step. -/
def sourceToIR (step : SourceStep) : IRNode :=
  buildIR step.op step.deltaSIHint step.lambdaHint

/-- Compile source workflow into IR workflow. -/
def compileWorkflow (wf : List SourceStep) : List IRNode :=
  wf.map sourceToIR

/-- Decode a lowered IR workflow into executable commands. -/
def decodeWorkflow (wf : List IRNode) : List Command :=
  wf.map decodeIR

/-- Source workflow semantics. -/
def interpretSource (wf : List SourceStep) (s : State) : State :=
  execList (wf.map sourceToCommand) s

/-- Compiled workflow semantics. -/
def interpretCompiled (wf : List SourceStep) (s : State) : State :=
  execList (decodeWorkflow (compileWorkflow wf)) s

theorem sourceToCommand_eq_decode_sourceToIR (step : SourceStep) :
    sourceToCommand step = decodeIR (sourceToIR step) := by
  cases step
  rfl

theorem decodeWorkflow_compileWorkflow_eq_source_map (wf : List SourceStep) :
    decodeWorkflow (compileWorkflow wf) = wf.map sourceToCommand := by
  induction wf with
  | nil =>
      simp [compileWorkflow, decodeWorkflow]
  | cons x xs ih =>
      simp [compileWorkflow, decodeWorkflow, sourceToCommand_eq_decode_sourceToIR]

/-- Sequential composition law for workflow execution. -/
theorem execList_append (xs ys : List Command) (s : State) :
    execList (xs ++ ys) s = execList ys (execList xs s) := by
  induction xs generalizing s with
  | nil =>
      simp [execList]
  | cons x xs ih =>
      simp [execList, ih]

theorem interpretSource_append (wf₁ wf₂ : List SourceStep) (s : State) :
    interpretSource (wf₁ ++ wf₂) s =
    interpretSource wf₂ (interpretSource wf₁ s) := by
  simp [interpretSource, List.map_append, execList_append]

theorem interpretCompiled_append (wf₁ wf₂ : List SourceStep) (s : State) :
    interpretCompiled (wf₁ ++ wf₂) s =
    interpretCompiled wf₂ (interpretCompiled wf₁ s) := by
  simp [interpretCompiled, compileWorkflow, decodeWorkflow, List.map_append, execList_append]

/-- Phase-3 main theorem: compiled workflow preserves source semantics. -/
theorem compileWorkflow_semantics_preserved (wf : List SourceStep) (s : State) :
    interpretCompiled wf s = interpretSource wf s := by
  simp [interpretCompiled, interpretSource, decodeWorkflow_compileWorkflow_eq_source_map]

/-- Segment composition remains semantics-preserving under compilation. -/
theorem compileWorkflow_segment_composition
    (wf₁ wf₂ : List SourceStep) (s : State) :
    interpretCompiled (wf₁ ++ wf₂) s =
    interpretSource wf₂ (interpretSource wf₁ s) := by
  calc
    interpretCompiled (wf₁ ++ wf₂) s
        = interpretCompiled wf₂ (interpretCompiled wf₁ s) := interpretCompiled_append wf₁ wf₂ s
    _ = interpretSource wf₂ (interpretSource wf₁ s) := by
        simp [compileWorkflow_semantics_preserved]

/-- Workflow execution preserves well-formed state invariants. -/
theorem execList_preserves_wellFormed (cmds : List Command) (s : State) (hs : WellFormed s) :
    WellFormed (execList cmds s) := by
  induction cmds generalizing s with
  | nil =>
      simpa [execList] using hs
  | cons c cs ih =>
      have hStep : WellFormed (step c s) := step_preserves_wellFormed c s hs
      simpa [execList] using ih (step c s) hStep

theorem interpretCompiled_preserves_wellFormed
    (wf : List SourceStep) (s : State) (hs : WellFormed s) :
    WellFormed (interpretCompiled wf s) := by
  unfold interpretCompiled decodeWorkflow compileWorkflow
  simpa [List.map_map] using
    (execList_preserves_wellFormed (((wf.map sourceToIR).map decodeIR)) s hs)

end CATEPT.DSL
