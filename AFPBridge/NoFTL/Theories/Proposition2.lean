import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Proposition2

/-!
Auto-generated theorem-indexed pilot file.
Theory: Proposition2
Theorem id: No_FTL_observers_Gen_Rel.Proposition2.lemProposition2#1
Theorem name: lemProposition2
Lean tactic class: arithmetic_norm_num
-/

theorem lemProposition2 (A : NoFTLObj) (coneSet : NoFTLObj → NoFTLObj → NoFTLSet) (m : NoFTLObj) (x : NoFTLObj) (k : NoFTLObj) (h1 : affineApprox A (wvtFunc m k) x) : applyToSet (asFunc A) (coneSet m x) ⊆ coneSet k (A x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Proposition2
