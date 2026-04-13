import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Vectors

/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotDecomposition#1
Theorem name: lemDotDecomposition
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotDecomposition (u : NoFTLObj) (v : NoFTLObj) : dot u v = (tval u * tval v) + sdot (sComponent u) (sComponent v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotCommute#1
Theorem name: lemDotCommute
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotCommute (u : NoFTLObj) (v : NoFTLObj) : dot u v = dot v u := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleLeft#1
Theorem name: lemDotScaleLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotScaleLeft (a : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : dot (a * u) v = a * (dot u v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotScaleRight#1
Theorem name: lemDotScaleRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotScaleRight (u : NoFTLObj) (a : NoFTLObj) (v : NoFTLObj) : dot u (a * v) = a * (dot u v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumLeft#1
Theorem name: lemDotSumLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotSumLeft (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot (u+v) w = (dot u w) + (dot v w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotSumRight#1
Theorem name: lemDotSumRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotSumRight (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot u (v+w) = (dot u v) + (dot u w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffLeft#1
Theorem name: lemDotDiffLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotDiffLeft (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot (u-v) w = (dot u w) - (dot v w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemDotDiffRight#1
Theorem name: lemDotDiffRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemDotDiffRight (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : dot u (v-w) = (dot u v) - (dot u w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemNorm2OfSum#1
Theorem name: lemNorm2OfSum
Lean tactic class: arithmetic_norm_num
-/

theorem lemNorm2OfSum (u : NoFTLObj) (v : NoFTLObj) : norm2 (u + v) = norm2 u + 2*(dot u v) + norm2 v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotCommute#1
Theorem name: lemSDotCommute
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotCommute (u : NoFTLObj) (v : NoFTLObj) : sdot u v = sdot v u := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleLeft#1
Theorem name: lemSDotScaleLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotScaleLeft (a : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : sdot (a *s u) v = a * (sdot u v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotScaleRight#1
Theorem name: lemSDotScaleRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotScaleRight (u : NoFTLObj) (a : NoFTLObj) (v : NoFTLObj) : sdot u (a *s v) = a * (sdot u v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumLeft#1
Theorem name: lemSDotSumLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotSumLeft (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : sdot (u +s v) w = (sdot u w) + (sdot v w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotSumRight#1
Theorem name: lemSDotSumRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotSumRight (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : sdot u (v +s w) = (sdot u v) + (sdot u w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffLeft#1
Theorem name: lemSDotDiffLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotDiffLeft (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : sdot (u -s v) w = (sdot u w) - (sdot v w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSDotDiffRight#1
Theorem name: lemSDotDiffRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemSDotDiffRight (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : sdot u (v -s w) = (sdot u v) - (sdot u w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotDiffLeft#1
Theorem name: lemMDotDiffLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemMDotDiffLeft (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : mdot (u-v) w = (mdot u w) - (mdot v w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotSumLeft#1
Theorem name: lemMDotSumLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemMDotSumLeft (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) (w : NoFTLObj) : mdot (u + v) w = (mdot u w) + (mdot v w) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleLeft#1
Theorem name: lemMDotScaleLeft
Lean tactic class: arithmetic_norm_num
-/

theorem lemMDotScaleLeft (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (a : NoFTLObj) (u : NoFTLObj) (v : NoFTLObj) : mdot (a * u) v = a * (mdot u v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDotScaleRight#1
Theorem name: lemMDotScaleRight
Lean tactic class: arithmetic_norm_num
-/

theorem lemMDotScaleRight (mdot : NoFTLObj → NoFTLObj → NoFTLObj) (u : NoFTLObj) (a : NoFTLObj) (v : NoFTLObj) : mdot u (a * v) = a * (mdot u v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSNorm2OfSum#1
Theorem name: lemSNorm2OfSum
Lean tactic class: arithmetic_norm_num
-/

theorem lemSNorm2OfSum (u : NoFTLObj) (s : NoFTLObj → NoFTLObj) (v : NoFTLObj) : sNorm2 (u +s v) = sNorm2 u + 2*(u *s v) + sNorm2 v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemSNormNonNeg#1
Theorem name: lemSNormNonNeg
Lean tactic class: needs_human
-/

theorem lemSNormNonNeg (v : NoFTLObj) : sNorm v ≥ 0 := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfSum#1
Theorem name: lemMNorm2OfSum
Lean tactic class: arithmetic_norm_num
-/

theorem lemMNorm2OfSum (u : NoFTLObj) (v : NoFTLObj) (m : NoFTLObj → NoFTLObj) : mNorm2 (u + v) = mNorm2 u + 2*(u *m v) + mNorm2 v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2OfDiff#1
Theorem name: lemMNorm2OfDiff
Lean tactic class: arithmetic_norm_num
-/

theorem lemMNorm2OfDiff (u : NoFTLObj) (v : NoFTLObj) (m : NoFTLObj → NoFTLObj) : mNorm2 (u - v) = mNorm2 u - 2*(u *m v) + mNorm2 v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMNorm2Decomposition#1
Theorem name: lemMNorm2Decomposition
Lean tactic class: arithmetic_norm_num
-/

theorem lemMNorm2Decomposition (p : NoFTLObj) (m : NoFTLObj → NoFTLObj) : mNorm2 p = (p *m p) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Vectors
Theorem id: No_FTL_observers_Gen_Rel.Vectors.lemMDecomposition#1
Theorem name: lemMDecomposition
Lean tactic class: arithmetic_norm_num
-/

theorem lemMDecomposition (u : NoFTLObj) (up : NoFTLObj) (uo : NoFTLObj) (parallel : NoFTLObj → NoFTLObj) (v : NoFTLObj) (h1 : (u *m v) ≠ 0) (h2 : mNorm2 v ≠ 0) (h3 : a = (u *m v) / (mNorm2 v)) (h4 : up = a * v) (h5 : uo = u - up) : u = (up + uo) ∧ (parallel up = v) ∧ orthogm uo v ∧ (up *m v) = (u *m v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Vectors
