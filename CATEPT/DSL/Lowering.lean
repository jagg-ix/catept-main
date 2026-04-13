import NavierStokesClean.CATEPT.DSL.CompilerCorrectness

/-!
# NavierStokesClean.CATEPT.DSL.Lowering

Phase-2 lowering correctness:
- `CommandType -> IRNode` builder
- `IRNode -> Command` decoding
- `IRNode -> RuntimePayload` lowering
- semantic preservation theorems relative to `step`.
-/

namespace NavierStokesClean.CATEPT.DSL

/-- Minimal IR node used in the phase-2 compiler-correctness model. -/
structure IRNode where
  op : CommandType
  deltaSIHint : Rat
  lambdaHint : Rat
  deriving DecidableEq, Repr

/-- Builder from command-level envelope fields into IR node. -/
def buildIR (op : CommandType) (deltaSIHint lambdaHint : Rat) : IRNode :=
  { op := op, deltaSIHint := deltaSIHint, lambdaHint := lambdaHint }

/-- Decode IR into executable command semantics. -/
def decodeIR (node : IRNode) : Command :=
  { kind := node.op, deltaSIHint := node.deltaSIHint, lambdaHint := node.lambdaHint }

theorem decodeIR_buildIR (op : CommandType) (d l : Rat) :
    decodeIR (buildIR op d l) = { kind := op, deltaSIHint := d, lambdaHint := l } := by
  rfl

theorem decodeIR_kind_preserved (node : IRNode) :
    (decodeIR node).kind = node.op := by
  rfl

/-- Runtime payload abstraction produced by lowering. -/
structure RuntimePayload where
  tauEntNext : Rat
  deltaSI : Rat
  lambdaEff : Rat
  deriving DecidableEq, Repr

/-- Lower executable command output into runtime payload. -/
def lowerPayload (node : IRNode) (s : State) : RuntimePayload :=
  let out := step (decodeIR node) s
  { tauEntNext := out.tauEnt, deltaSI := out.deltaSI, lambdaEff := out.lambdaEff }

/-- Reconstruct state view from runtime payload for simulation relation proofs. -/
def payloadToState (p : RuntimePayload) : State :=
  { tauEnt := p.tauEntNext, deltaSI := p.deltaSI, lambdaEff := p.lambdaEff }

theorem lowerPayload_tau_exact (node : IRNode) (s : State) :
    (lowerPayload node s).tauEntNext = (step (decodeIR node) s).tauEnt := by
  rfl

theorem lowerPayload_delta_exact (node : IRNode) (s : State) :
    (lowerPayload node s).deltaSI = (step (decodeIR node) s).deltaSI := by
  rfl

theorem lowerPayload_lambda_exact (node : IRNode) (s : State) :
    (lowerPayload node s).lambdaEff = (step (decodeIR node) s).lambdaEff := by
  rfl

/-- Core phase-2 preservation theorem: lowering simulates `step` exactly. -/
theorem lowerPayload_simulation (node : IRNode) (s : State) :
    SimulationRel (step (decodeIR node) s) (payloadToState (lowerPayload node s)) := by
  simp [SimulationRel, payloadToState, lowerPayload]

/-- Well-formed inputs produce well-formed lowered payload-state outputs. -/
theorem lowerPayload_preserves_wellFormed
    (node : IRNode) (s : State) (hs : WellFormed s) :
    WellFormed (payloadToState (lowerPayload node s)) := by
  simpa [payloadToState] using step_preserves_wellFormed (decodeIR node) s hs

/-- `CommandType -> IR -> Command` preserves executable command semantics. -/
theorem commandType_to_ir_to_command_semantics
    (op : CommandType) (d l : Rat) (s : State) :
    step ({ kind := op, deltaSIHint := d, lambdaHint := l } : Command) s =
    step (decodeIR (buildIR op d l)) s := by
  rfl

end NavierStokesClean.CATEPT.DSL
