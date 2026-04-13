import NavierStokesClean.CATEPT.DSL.Semantics

/-
# NavierStokesClean.CATEPT.DSL.CompilerCorrectness

Phase-1 correctness scaffolding:
- semantic relation for source/target states
- proof-obligation record for lowering stages
- baseline theorems that later phases refine.
-/

namespace NavierStokesClean.CATEPT.DSL

/-- Observable state relation used across compiler-lowering phases. -/
def SimulationRel (src tgt : State) : Prop :=
  src.tauEnt = tgt.tauEnt ∧ src.deltaSI = tgt.deltaSI ∧ src.lambdaEff = tgt.lambdaEff

theorem simulationRel_refl (s : State) : SimulationRel s s := by
  unfold SimulationRel
  exact ⟨rfl, rfl, rfl⟩

/-- Generic proof obligation shape for lowering stages. -/
structure LoweringObligation where
  stage : String
  pre : State → Prop
  post : State → State → Prop

/-- A lowering stage is sound when post-condition follows from executing step. -/
def LoweringSound (cmd : Command) (obl : LoweringObligation) : Prop :=
  ∀ s : State, obl.pre s → obl.post s (step cmd s)

/-- Canonical obligation: runtime contracts preserve non-negativity reports. -/
def nonnegReportObligation : LoweringObligation where
  stage := "phase1.nonneg-report"
  pre := WellFormed
  post := fun _ out => 0 ≤ out.deltaSI ∧ 0 ≤ out.lambdaEff

theorem nonneg_report_obligation_sound (cmd : Command) :
    LoweringSound cmd nonnegReportObligation := by
  intro s hPre
  simpa [LoweringSound, nonnegReportObligation] using step_report_nonneg cmd s hPre

end NavierStokesClean.CATEPT.DSL
