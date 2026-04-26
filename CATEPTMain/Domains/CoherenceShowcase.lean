import CATEPTMain.Domains.CoherenceSpine

/-!
# Coherence Spine — Kernel-Axiom Showcase

Inline `#print axioms` audit for the three adapters and the headline
coherence-spine theorem.

Expected (matches the gate documented in the top-level README):
```
'…minkowski_satisfies_spine'   depends on axioms: [propext, Classical.choice, Quot.sound]
'…em_satisfies_spine'          depends on axioms: [propext, Classical.choice, Quot.sound]
'…vml_satisfies_spine'         depends on axioms: [propext, Classical.choice, Quot.sound]
'…coherence_spine_GR_EM_VML'   depends on axioms: [propext, Classical.choice, Quot.sound]
'…live_dynamics_EM_VML'        depends on axioms: [propext, Classical.choice, Quot.sound]
```

Any other axiom appearing in the list is a regression.
-/

#print axioms CATEPTMain.Temporal.Adapter.minkowski_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.em_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.vml_satisfies_spine
#print axioms CATEPTMain.Temporal.coherence_spine_GR_EM_VML
#print axioms CATEPTMain.Temporal.live_dynamics_EM_VML
