import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Norms

/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormSqrIsNorm2#1
Theorem name: lemNormSqrIsNorm2
Lean tactic class: arithmetic_norm_num
-/

theorem lemNormSqrIsNorm2 (p : NoFTLObj) : norm2 p = sqr (norm p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemZeroNorm#1
Theorem name: lemZeroNorm
Lean tactic class: arithmetic_norm_num
-/

theorem lemZeroNorm (p : NoFTLObj) (origin : NoFTLObj) : (p = origin) ↔ (norm p = 0) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormNonNegative#1
Theorem name: lemNormNonNegative
Lean tactic class: needs_human
-/

theorem lemNormNonNegative (p : NoFTLObj) : norm p ≥ 0 := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNotOriginImpliesPositiveNorm#1
Theorem name: lemNotOriginImpliesPositiveNorm
Lean tactic class: arithmetic_norm_num
-/

theorem lemNotOriginImpliesPositiveNorm (p : NoFTLObj) (h1 : p ≠ origin) : (norm p > 0) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormSymmetry#1
Theorem name: lemNormSymmetry
Lean tactic class: arithmetic_norm_num
-/

theorem lemNormSymmetry (p : NoFTLObj) (q : NoFTLObj) : norm (p-q) = norm (q-p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemNormOfScaled#1
Theorem name: lemNormOfScaled
Lean tactic class: arithmetic_norm_num
-/

theorem lemNormOfScaled (p : NoFTLObj) : norm (α*p) = (abs α) * (norm p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAdd#1
Theorem name: lemDistancesAdd
Lean tactic class: arithmetic_norm_num
-/

theorem lemDistancesAdd (r : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (p : NoFTLObj) (triangle : axTriangleInequality (qp) (rq)) (distances : (x > 0) ∧ (y > 0) ∧ (sep^2 p q < sqr x) ∧ (sep^2 r q < sqr y)) : withinOf r (x+y) p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Norms
Theorem id: No_FTL_observers_Gen_Rel.Norms.lemDistancesAddStrictR#1
Theorem name: lemDistancesAddStrictR
Lean tactic class: arithmetic_norm_num
-/

theorem lemDistancesAddStrictR (r : NoFTLObj) (x : NoFTLObj) (y : NoFTLObj) (p : NoFTLObj) (triangle : axTriangleInequality (qp) (rq)) (distances : (x > 0) ∧ (y > 0) ∧ (sep^2 p q ≤ sqr x) ∧ (sep^2 r q < sqr y)) : withinOf r (x+y) p := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Norms
