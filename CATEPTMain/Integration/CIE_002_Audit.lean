import CATEPTMain.Integration.CausalImplementabilitySMatrixBridge

/-!
# CIE-002 S-matrix factorisation — kernel-axiom audit

Reviewer-facing reproducible audit for the load-bearing declarations
that land CIE-002 from `CAUSAL_IMPLEMENTABILITY_WORKLOG.lean`. Each
must report `[propext, Classical.choice, Quot.sound]` — no other
axioms.
-/

#print axioms CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.LocalSmatrix.exists_trivial
#print axioms CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.CauchySplit.exists_trivial
#print axioms CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.Unitary
#print axioms CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.ContinuousAdditive
#print axioms CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.continuousAdditive_of_constant_one
#print axioms CATEPTMain.Integration.CausalImplementabilitySMatrixBridge.HammersteinFactorisation.exists_trivial
