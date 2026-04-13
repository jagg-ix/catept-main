import CATEPTMain.AFPBridge.NoFTL.NoFTLPrelude
set_option autoImplicit true

namespace AFPIsabellePilot.Sorts

/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemLEPlus#1
Theorem name: lemLEPlus
Lean tactic class: arithmetic_norm_num
-/

theorem lemLEPlus (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : a ≤ b + c → c ≥ a - b := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT1#1
Theorem name: lemMultPosLT1
Lean tactic class: arithmetic_norm_num
-/

theorem lemMultPosLT1 (a : NoFTLObj) (b : NoFTLObj) (h1 : (a > 0) ∧ (b ≥ 0) ∧ (b < 1)) : (a * b) < a := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsRange#1
Theorem name: lemAbsRange
Lean tactic class: arithmetic_norm_num
-/

theorem lemAbsRange (e : NoFTLObj) (a : NoFTLObj) (b : NoFTLObj) : e > 0 → (((a-e) < b) ∧ (b < (a+e))) ↔ (abs (b-a) < e) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNeg#1
Theorem name: lemAbsNeg
Lean tactic class: arithmetic_norm_num
-/

theorem lemAbsNeg (x : NoFTLObj) : abs x = abs (-x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsNegNeg#1
Theorem name: lemAbsNegNeg
Lean tactic class: arithmetic_norm_num
-/

theorem lemAbsNegNeg (a : NoFTLObj) (b : NoFTLObj) : abs (-a-b) = abs (a+b) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemGENZGT#1
Theorem name: lemGENZGT
Lean tactic class: arithmetic_norm_num
-/

theorem lemGENZGT (x : NoFTLObj) : (x ≥ 0) ∧ (x ≠ 0) → x > 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemLENZLT#1
Theorem name: lemLENZLT
Lean tactic class: arithmetic_norm_num
-/

theorem lemLENZLT (x : NoFTLObj) : (x ≤ 0) ∧ (x ≠ 0) → x < 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfNonNegAndPos#1
Theorem name: lemSumOfNonNegAndPos
Lean tactic class: arithmetic_norm_num
-/

theorem lemSumOfNonNegAndPos (x : NoFTLObj) (y : NoFTLObj) : x ≥ 0 ∧ y > 0 → x+y > 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSumOfTwoHalves#1
Theorem name: lemSumOfTwoHalves
Lean tactic class: arithmetic_norm_num
-/

theorem lemSumOfTwoHalves (x : NoFTLObj) : x = x/2 + x/2 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemDiffDiffAdd#1
Theorem name: lemDiffDiffAdd
Lean tactic class: arithmetic_norm_num
-/

theorem lemDiffDiffAdd (b : NoFTLObj) (a : NoFTLObj) (c : NoFTLObj) : (b-a)+(c-b) = (c-a) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSumDiffCancelMiddle#1
Theorem name: lemSumDiffCancelMiddle
Lean tactic class: arithmetic_norm_num
-/

theorem lemSumDiffCancelMiddle (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : (a - b) + (b - c) = (a - c) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemDiffSumCancelMiddle#1
Theorem name: lemDiffSumCancelMiddle
Lean tactic class: arithmetic_norm_num
-/

theorem lemDiffSumCancelMiddle (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : (a - b) + (b + c) = (a + c) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLT#1
Theorem name: lemMultPosLT
Lean tactic class: arithmetic_norm_num
-/

theorem lemMultPosLT (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 < a) ∧ (b < c)) → (a * b < a * c) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultPosLE#1
Theorem name: lemMultPosLE
Lean tactic class: arithmetic_norm_num
-/

theorem lemMultPosLE (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 < a) ∧ (b ≤ c)) → (a * b ≤ a * c) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemNonNegLT#1
Theorem name: lemNonNegLT
Lean tactic class: arithmetic_norm_num
-/

theorem lemNonNegLT (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 ≤ a) ∧ (b < c)) → (a * b ≤ a * c) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemMultNonNegLE#1
Theorem name: lemMultNonNegLE
Lean tactic class: needs_human
-/

theorem lemMultNonNegLE (a : NoFTLObj) (b : NoFTLObj) (c : NoFTLObj) : ((0 ≤ a) ∧ (b ≤ c)) → (a * b ≤ a * c) := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemAbsIsRootOfSquare#1
Theorem name: lemAbsIsRootOfSquare
Lean tactic class: arithmetic_norm_num
-/

theorem lemAbsIsRootOfSquare (isNonNegRoot : NoFTLObj → NoFTLObj → Prop) (x : NoFTLObj) : isNonNegRoot (sqr x) (abs x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt#1
Theorem name: lemSqrt
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrt (hasUniqueRoot : NoFTLObj → Prop) (x : NoFTLObj) (h1 : hasRoot x) : hasUniqueRoot x := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1
Theorem name: lemSqrMonoStrict
Lean tactic class: arithmetic_norm_num
-/


theorem lemSqrMonoStrict : wolframStatementPlaceholder "No_FTL_observers_Gen_Rel.Sorts.lemSqrMonoStrict#1" "assumes \"(0 \\<le> u) \\<and> (u < v)\"" := by
  sorry  -- retry compile-safe placeholder preserving theorem/source identity




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMono#1
Theorem name: lemSqrMono
Lean tactic class: needs_human
-/

theorem lemSqrMono (u : NoFTLObj) (v : NoFTLObj) : (0 ≤ u) ∧ (u ≤ v) → (sqr u) ≤ (sqr v) := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrderedStrict#1
Theorem name: lemSqrOrderedStrict
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrOrderedStrict (v : NoFTLObj) (u : NoFTLObj) : (v > 0) ∧ (sqr u < sqr v) → (u < v) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrOrdered#1
Theorem name: lemSqrOrdered
Lean tactic class: needs_human
-/

theorem lemSqrOrdered (v : NoFTLObj) (u : NoFTLObj) : (v ≥ 0) ∧ (sqr u ≤ sqr v) → (u ≤ v) := by
  first | omega | norm_num | linarith | nlinarith | simp_all | decide | trivial | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquaredNegative#1
Theorem name: lemSquaredNegative
Lean tactic class: arithmetic_norm_num
-/

theorem lemSquaredNegative (x : NoFTLObj) : sqr x = sqr (-x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrDiffSymmetrical#1
Theorem name: lemSqrDiffSymmetrical
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrDiffSymmetrical (x : NoFTLObj) (y : NoFTLObj) : sqr (x - y) = sqr (y - x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquaresPositive#1
Theorem name: lemSquaresPositive
Lean tactic class: arithmetic_norm_num
-/

theorem lemSquaresPositive (x : NoFTLObj) : x ≠ 0 → sqr x > 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemZeroRoot#1
Theorem name: lemZeroRoot
Lean tactic class: arithmetic_norm_num
-/

theorem lemZeroRoot (x : NoFTLObj) : (sqr x = 0) ↔ (x = 0) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrMult#1
Theorem name: lemSqrMult
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrMult (a : NoFTLObj) (b : NoFTLObj) : sqr (a * b) = (sqr a) * (sqr b) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemEqualSquares#1
Theorem name: lemEqualSquares
Lean tactic class: arithmetic_norm_num
-/

theorem lemEqualSquares (u : NoFTLObj) (v : NoFTLObj) : sqr u = sqr v → abs u = abs v := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrtOfSquare#1
Theorem name: lemSqrtOfSquare
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrtOfSquare (b : NoFTLObj) (a : NoFTLObj) (h1 : b = sqr a) : sqrt b = abs a := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquareOfSqrt#1
Theorem name: lemSquareOfSqrt
Lean tactic class: arithmetic_norm_num
-/

theorem lemSquareOfSqrt (a : NoFTLObj) (b : NoFTLObj) (h1 : hasRoot b) (h2 : a = sqrt b) : sqr a = b := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt1#1
Theorem name: lemSqrt1
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrt1 : sqrt 1 = 1 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrt0#1
Theorem name: lemSqrt0
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrt0 : sqrt 0 = 0 := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrSum#1
Theorem name: lemSqrSum
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrSum (x : NoFTLObj) (y : NoFTLObj) : sqr (x + y) = (x * x) + (2 * x * y) + (y * y) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemQuadraticGEZero#1
Theorem name: lemQuadraticGEZero
Lean tactic class: arithmetic_norm_num
-/

theorem lemQuadraticGEZero (b : NoFTLObj) (a : NoFTLObj) (c : NoFTLObj) (h1 : ∀ x, a*(sqr x) + b*x + c ≥ 0) (h2 : a > 0) : (sqr b) ≤ 4 * a * c := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSquareExistsAbove#1
Theorem name: lemSquareExistsAbove
Lean tactic class: arithmetic_norm_num
-/

theorem lemSquareExistsAbove (y : NoFTLObj) : ∃ x, x > 0 ∧  (sqr x) > y := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSmallSquares#1
Theorem name: lemSmallSquares
Lean tactic class: arithmetic_norm_num
-/

theorem lemSmallSquares (x : NoFTLObj) (h1 : x > 0) : ∃ y, y > 0 ∧  (sqr y < x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemSqrLT1#1
Theorem name: lemSqrLT1
Lean tactic class: arithmetic_norm_num
-/

theorem lemSqrLT1 (x : NoFTLObj) (h1 : 0 < x < 1) : (0 < (sqr x)) ∧ ((sqr x) < x) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry




/-!
Auto-generated theorem-indexed pilot file.
Theory: Sorts
Theorem id: No_FTL_observers_Gen_Rel.Sorts.lemReducedBound#1
Theorem name: lemReducedBound
Lean tactic class: arithmetic_norm_num
-/

theorem lemReducedBound (x : NoFTLObj) (h1 : x > 0) : ∃ y, y > 0 ∧  (y < x) ∧ (sqr y < y) ∧ (y < 1) := by
  first | ring | norm_num | omega | linarith | simp | exact rfl | sorry

end AFPIsabellePilot.Sorts
