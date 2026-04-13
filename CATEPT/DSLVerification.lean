import NavierStokesClean.CATEPT.DSL

/-!
# CAT/EPT DSL Verification Tower (Facade)

This module is intentionally a thin compatibility facade.

Historically, `DSLVerification.lean` duplicated the declarations from
`NavierStokesClean.CATEPT.DSL.*`, which caused namespace collisions when both
were imported. The canonical implementation now lives in the modular DSL files,
and this file re-exports that surface for existing import paths.

Coverage remains provided by:
- `DSL.Syntax`
- `DSL.Semantics`
- `DSL.CompilerCorrectness`
- `DSL.Lowering`
- `DSL.WorkflowCorrectness`
- `DSL.BackendContracts`
- `DSL.LambdaMetaTheory`
- `DSL.ObligationMap`
-/

-- This file is an import facade; canonical declarations live in DSL/* submodules.
-- No vacuous marker theorems needed.

namespace NavierStokesClean.CATEPT

/-- Compatibility certificate for downstream audit/gate tooling.
It re-exports two canonical DSL results from the modular tower:
1) compiler semantic preservation, and 2) closed-term type safety. -/
theorem dsl_verification_complete :
    (∀ (wf : List DSL.SourceStep) (s : DSL.State),
      DSL.interpretCompiled wf s = DSL.interpretSource wf s) ∧
    (∀ {t t' : DSL.LTerm} {A : DSL.LType},
      DSL.HasType [] [] t A →
      Relation.ReflTransGen DSL.Step t t' →
      DSL.Value t' ∨ ∃ u, DSL.Step t' u) := by
  refine ⟨?_, ?_⟩
  · intro wf s
    simpa using (DSL.compileWorkflow_semantics_preserved wf s)
  · intro t t' A ht hstar
    exact DSL.typeSafety_closed ht hstar

end NavierStokesClean.CATEPT
