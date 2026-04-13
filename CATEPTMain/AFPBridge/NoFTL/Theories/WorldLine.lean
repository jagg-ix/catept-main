import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.WorldLine

/-!
Auto-generated theorem-indexed pilot file.
Theory: WorldLine
Theorem id: No_FTL_observers_Gen_Rel.WorldLine.lemWorldLineUnderWVT#1
Theorem name: lemWorldLineUnderWVT
Lean tactic class: needs_human
-/

theorem lemWorldLineUnderWVT (m : NoFTLObj) (k : NoFTLObj) (b : NoFTLObj) : applyToSet (wvt m k) (wline m b) ⊆ wline k b := by
  first | simp_all [Set.mem_setOf_eq, Set.subset_def] | tauto | omega | decide | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: WorldLine
Theorem id: No_FTL_observers_Gen_Rel.WorldLine.lemFiniteLineVelocityUnique#1
Theorem name: lemFiniteLineVelocityUnique
Lean tactic class: arithmetic_norm_num
-/

theorem lemFiniteLineVelocityUnique (u : NoFTLObj) (v : NoFTLObj) (h1 : (u ∈ lineVelocity l) ∧ (v ∈ lineVelocity l)) (h2 : lineSlopeFinite l) : u = v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.WorldLine
