import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Quadratics

/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadRootCondition#1
Theorem name: lemQuadRootCondition
Lean tactic class: arithmetic_norm_num
-/

theorem lemQuadRootCondition (a : NoFTLObj) (r : NoFTLObj) (b : NoFTLObj) (discriminant : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj) (c : NoFTLObj) (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (h1 : a ≠ 0) : (sqr (2 * a * r + b) = discriminant a b c) ↔ qroot a b c r := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticCasesComplete#1
Theorem name: lemQuadraticCasesComplete
Lean tactic class: needs_human
-/

theorem lemQuadraticCasesComplete (qcase1 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (qcase4 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (qcase5 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) (qcase6 : NoFTLObj → NoFTLObj → NoFTLObj → Prop) : qcase1 a b c ∨ qcase2 a b c ∨ qcase3 a b c ∨ qcase4 a b c ∨ qcase5 a b c ∨ qcase6 a b c := by
  first | omega | decide | norm_num | ring | linarith | field_simp | simp_all | tauto | trivial | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase1#1
Theorem name: lemQCase1
Lean tactic class: arithmetic_norm_num
-/

theorem lemQCase1 (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (h1 : qcase1 a b c) : ∀ r, qroot a b c r := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase2#1
Theorem name: lemQCase2
Lean tactic class: arithmetic_norm_num
-/

theorem lemQCase2 (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (h1 : qcase2 a b c) : ¬ (∃ r, qroot a b c r) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase3#1
Theorem name: lemQCase3
Lean tactic class: arithmetic_norm_num
-/

theorem lemQCase3 (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (r : NoFTLObj) (h1 : qcase3 a b c) : qroot a b c r ↔ r = -c/b := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase4#1
Theorem name: lemQCase4
Lean tactic class: arithmetic_norm_num
-/

theorem lemQCase4 (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (h1 : qcase4 a b c) : ¬ (∃ r, qroot a b c r) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase5#1
Theorem name: lemQCase5
Lean tactic class: arithmetic_norm_num
-/

theorem lemQCase5 (qroot : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLObj → Prop) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (r : NoFTLObj) (h1 : qcase5 a b c) : qroot a b c r ↔ r = -b/(2 * a) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1
Theorem name: lemQCase6
Lean tactic class: arithmetic_norm_num
-/


theorem lemQCase6 (rp : NoFTLObj) (rm : NoFTLObj) (qroots : NoFTLObj → NoFTLObj → NoFTLSet → NoFTLSet) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLSet) (h1 : qcase6 a b c) (h2 : rd = sqrt (discriminant a b c)) (h3 : rp = ((-b) + rd) / (2*a)) (h4 : rm = ((-b) - rd) / (2*a)) : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Quadratics.lemQCase6#1" "assumes \"qcase6 a b c\" and \"rd = sqrt (discriminant a b c)\" and \"rp = ((-b) + rd) / (2*a)\" and \"rm = ((-b) - rd) / (2*a)\" shows \"(rp \\<noteq> rm) \\<and> qroots a b c = { rp, rm }\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Quadratics
Theorem id: No_FTL_observers_Gen_Rel.Quadratics.lemQuadraticRootCount#1
Theorem name: lemQuadraticRootCount
Lean tactic class: arithmetic_norm_num
-/

theorem lemQuadraticRootCount (qroots : NoFTLObj → NoFTLObj → NoFTLObj → NoFTLSet) (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) (h1 : ¬(qcase1 a b c)) : finite (qroots a b c) ∧ card (qroots a b c) ≤ 2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Quadratics
