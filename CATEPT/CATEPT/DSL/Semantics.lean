import Mathlib
import CATEPT.DSL.Syntax

/-!
# CATEPT.DSL.Semantics

Executable small-step semantics for a minimal DTL subset and
foundational invariants used by later lowering-correctness proofs.
-/

namespace CATEPT.DSL

/-- State tracked by the entropic-time orchestration layer. -/
structure State where
  tauEnt : Rat
  deltaSI : Rat
  lambdaEff : Rat
  deriving DecidableEq, Repr

/-- Basic well-formedness invariant for runtime state contracts. -/
def WellFormed (s : State) : Prop :=
  0 ≤ s.tauEnt ∧ 0 ≤ s.deltaSI ∧ 0 ≤ s.lambdaEff

/-- Non-negativity clamp used by runtime contracts. -/
def clampNonneg (x : Rat) : Rat := if x < 0 then 0 else x

theorem clampNonneg_nonneg (x : Rat) : 0 ≤ clampNonneg x := by
  unfold clampNonneg
  by_cases h : x < 0
  · simp [h]
  · have hx : 0 ≤ x := le_of_not_gt h
    simp [h, hx]

/-- One-step semantics for the phase-1 command subset. -/
def step (cmd : Command) (s : State) : State :=
  let d := clampNonneg cmd.deltaSIHint
  let l := clampNonneg cmd.lambdaHint
  match cmd.kind with
  | .noop => s
  | .entropicEvolve =>
      { tauEnt := s.tauEnt + d, deltaSI := d, lambdaEff := l }
  | .openFermionHamiltonian =>
      { tauEnt := s.tauEnt + d, deltaSI := d, lambdaEff := l }
  | .quantumOpticsJLEntropicSolve =>
      { tauEnt := s.tauEnt + d, deltaSI := d, lambdaEff := l }

/-- Sequential semantics for workflows. -/
def execList : List Command → State → State
  | [], s => s
  | c :: cs, s => execList cs (step c s)

/-- Monotonicity of tauEnt for one non-noop command step. -/
theorem tauEnt_step_monotone_nonnoop
    (cmd : Command) (s : State)
    (h : cmd.kind ≠ .noop) :
    s.tauEnt ≤ (step cmd s).tauEnt := by
  unfold step
  cases hk : cmd.kind with
  | noop => contradiction
  | entropicEvolve =>
      have hd : 0 ≤ clampNonneg cmd.deltaSIHint := clampNonneg_nonneg cmd.deltaSIHint
      simpa [step, hk] using
        (le_add_of_nonneg_right hd : s.tauEnt ≤ s.tauEnt + clampNonneg cmd.deltaSIHint)
  | openFermionHamiltonian =>
      have hd : 0 ≤ clampNonneg cmd.deltaSIHint := clampNonneg_nonneg cmd.deltaSIHint
      simpa [step, hk] using
        (le_add_of_nonneg_right hd : s.tauEnt ≤ s.tauEnt + clampNonneg cmd.deltaSIHint)
  | quantumOpticsJLEntropicSolve =>
      have hd : 0 ≤ clampNonneg cmd.deltaSIHint := clampNonneg_nonneg cmd.deltaSIHint
      simpa [step, hk] using
        (le_add_of_nonneg_right hd : s.tauEnt ≤ s.tauEnt + clampNonneg cmd.deltaSIHint)

/-- Monotonicity extends to command lists when all commands are non-noop. -/
theorem tauEnt_execList_monotone
    (cmds : List Command) (s : State)
    (hNoNoop : ∀ c ∈ cmds, c.kind ≠ .noop) :
    s.tauEnt ≤ (execList cmds s).tauEnt := by
  induction cmds generalizing s with
  | nil =>
      simp [execList]
  | cons c cs ih =>
      have hc : c.kind ≠ .noop := hNoNoop c (by simp)
      have hs : s.tauEnt ≤ (step c s).tauEnt := tauEnt_step_monotone_nonnoop c s hc
      have htail : ∀ c' ∈ cs, c'.kind ≠ .noop := by
        intro c' hc'
        exact hNoNoop c' (by simp [hc'])
      have hrest : (step c s).tauEnt ≤ (execList cs (step c s)).tauEnt := ih (step c s) htail
      simp [execList]
      exact le_trans hs hrest

/-- `step` preserves non-negative report fields from a well-formed input state. -/
theorem step_report_nonneg (cmd : Command) (s : State) (hs : WellFormed s) :
    0 ≤ (step cmd s).deltaSI ∧ 0 ≤ (step cmd s).lambdaEff := by
  unfold step
  cases cmd.kind <;> simp [clampNonneg_nonneg, WellFormed] at *
  · exact ⟨hs.2.1, hs.2.2⟩

/-- `step` preserves full well-formedness. -/
theorem step_preserves_wellFormed (cmd : Command) (s : State) (hs : WellFormed s) :
    WellFormed (step cmd s) := by
  unfold WellFormed
  cases hk : cmd.kind with
  | noop =>
      simpa [step, hk] using hs
  | entropicEvolve =>
      constructor
      · simp [step, hk]
        exact add_nonneg hs.1 (clampNonneg_nonneg cmd.deltaSIHint)
      · constructor <;> simp [step, hk, clampNonneg_nonneg]
  | openFermionHamiltonian =>
      constructor
      · simp [step, hk]
        exact add_nonneg hs.1 (clampNonneg_nonneg cmd.deltaSIHint)
      · constructor <;> simp [step, hk, clampNonneg_nonneg]
  | quantumOpticsJLEntropicSolve =>
      constructor
      · simp [step, hk]
        exact add_nonneg hs.1 (clampNonneg_nonneg cmd.deltaSIHint)
      · constructor <;> simp [step, hk, clampNonneg_nonneg]

end CATEPT.DSL
