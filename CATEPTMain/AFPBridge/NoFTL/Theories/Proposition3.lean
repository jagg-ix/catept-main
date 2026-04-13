import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Proposition3

/-!
Auto-generated theorem-indexed pilot file.
Theory: Proposition3
Theorem id: No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1
Theorem name: lemProposition3
Lean tactic class: arithmetic_norm_num
-/


theorem lemProposition3 (m : NoFTLObj) (k : NoFTLObj) (x : NoFTLObj) (h1 : sees m k x) : ∃ A y, wvtFunc m k x y ∧ affineApprox A (wvtFunc m k) x ∧ applyToSet (asFunc A) (coneSet m x) ⊆ coneSet k y ∧ coneSet k y = regularConeSet y := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Proposition3
