import CATEPTMain.Integration.EntropicLocalityTheoremsBridge

/-!
# CIE-001 Sorkin scenario — kernel-axiom audit

Reviewer-facing reproducible audit for the four declarations that land
CIE-001 from `CAUSAL_IMPLEMENTABILITY_WORKLOG.lean`. Each must report
`[propext, Classical.choice, Quot.sound]` — no other axioms.
-/

#print axioms CATEPTMain.Integration.EntropicLocalityTheoremsBridge.SorkinScenario.noSignallingInSorkinScenario
#print axioms CATEPTMain.Integration.EntropicLocalityTheoremsBridge.SorkinScenario.exists_trivial
#print axioms CATEPTMain.Integration.EntropicLocalityTheoremsBridge.NoSignallingInSorkinScenario
#print axioms CATEPTMain.Integration.EntropicLocalityTheoremsBridge.sorkinScenario_satisfies_noSignalling
