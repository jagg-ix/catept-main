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


def wolframStatementPlaceholder (_theoremId : String) (_sourceStatement : String) : Prop := True
theorem lemProposition3 (wvtFunc : NoFTLObj) (m : NoFTLObj) (k : NoFTLObj) (x : NoFTLObj) (coneSet : NoFTLObj → NoFTLSet → NoFTLSet) (h1 : m sees k at x) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Proposition3.lemProposition3#1" "assumes \"m sees k at x\" shows \"\\<exists> A y . (wvtFunc m k x y) \\<and> (affineApprox A (wvtFunc m k) x) \\<and> (applyToSet (asFunc A) (coneSet m x) \\<subseteq> coneSet k y) \\<and> (coneSet k y = regularConeSet y)\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity

end AFPIsabellePilot.Proposition3
