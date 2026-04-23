import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 020

Lean4 specification skeleton for a typed command/state layer.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G020

inductive rowG020CommandType where
  | tick
  | report
  | reset
  deriving DecidableEq, Repr

structure rowG020State where
  tauEnt : ℝ
  delta   : ℝ

/-- Core step function for the spec-level command language. -/
def rowG020Step : rowG020CommandType → rowG020State → rowG020State
  | .tick,   s => { s with tauEnt := s.tauEnt + max s.delta 0 }
  | .report, s => s
  | .reset,  s => { s with tauEnt := 0 }

/-- Report is observational and preserves state. -/
theorem rowG020_step_report_id (s : rowG020State) :
    rowG020Step .report s = s := by
  rfl

/-- Tick command is monotone in `tauEnt`. -/
theorem rowG020_step_tick_monotone (s : rowG020State) :
    s.tauEnt ≤ (rowG020Step .tick s).tauEnt := by
  unfold rowG020Step
  nlinarith [le_max_right s.delta 0]

/-- Reset command sets `tauEnt` to zero. -/
theorem rowG020_step_reset_zero (s : rowG020State) :
    (rowG020Step .reset s).tauEnt = 0 := by
  rfl

/-- Bundle theorem for row-020 Lean4 specification layer. -/
theorem rowG020_bundle (s : rowG020State) :
    rowG020Step .report s = s ∧
      s.tauEnt ≤ (rowG020Step .tick s).tauEnt ∧
      (rowG020Step .reset s).tauEnt = 0 := by
  exact ⟨
    rowG020_step_report_id s,
    rowG020_step_tick_monotone s,
    rowG020_step_reset_zero s
  ⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G020

