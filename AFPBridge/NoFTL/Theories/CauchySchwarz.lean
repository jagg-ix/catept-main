import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.CauchySchwarz

/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz4#1
Theorem name: lemCauchySchwarz4
Lean tactic class: arithmetic_norm_num
-/

theorem lemCauchySchwarz4 (u : NoFTLObj) (v : NoFTLObj) : abs (dot u v) ≤ (norm u)*(norm v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr4#1
Theorem name: lemCauchySchwarzSqr4
Lean tactic class: needs_human
-/

theorem lemCauchySchwarzSqr4 (u : NoFTLObj) (v : NoFTLObj) : sqr (dot u v) ≤ (norm2 u)*(norm2 v) := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarz#1
Theorem name: lemCauchySchwarz
Lean tactic class: arithmetic_norm_num
-/

theorem lemCauchySchwarz (u : NoFTLObj) (v : NoFTLObj) : abs (sdot u v) ≤ (sNorm u)*(sNorm v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzSqr#1
Theorem name: lemCauchySchwarzSqr
Lean tactic class: needs_human
-/

theorem lemCauchySchwarzSqr (u : NoFTLObj) (v : NoFTLObj) : sqr (sdot u v) ≤ (sNorm2 u)*(sNorm2 v) := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEquality#1
Theorem name: lemCauchySchwarzEquality
Lean tactic class: arithmetic_norm_num
-/

theorem lemCauchySchwarzEquality (u : NoFTLObj) (s : NoFTLObj → NoFTLObj) (v : NoFTLObj) (h1 : sqr (sdot u v) = (sNorm2 u)*(sNorm2 v)) (h2 : u ≠ sOrigin ∧ v ≠ sOrigin) : ∃ a ≠ 0, u = (a *s v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCauchySchwarzEqualityInUnitSphere#1
Theorem name: lemCauchySchwarzEqualityInUnitSphere
Lean tactic class: arithmetic_norm_num
-/

theorem lemCauchySchwarzEqualityInUnitSphere (u : NoFTLObj) (v : NoFTLObj) (h1 : (sNorm2 u ≤ 1) ∧ (sNorm2 v ≤ 1)) (h2 : sdot u v = 1) : u = v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: CauchySchwarz
Theorem id: No_FTL_observers_Gen_Rel.CauchySchwarz.lemCausalOrthogmToLightlikeImpliesParallel#1
Theorem name: lemCausalOrthogmToLightlikeImpliesParallel
Lean tactic class: arithmetic_norm_num
-/

theorem lemCausalOrthogmToLightlikeImpliesParallel (parallel : NoFTLObj → NoFTLObj → Prop) (p : NoFTLObj) (q : NoFTLObj) (h1 : causal p) (h2 : lightlike q) (h3 : orthogm p q) : parallel p q := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.CauchySchwarz
