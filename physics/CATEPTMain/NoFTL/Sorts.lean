import CATEPTMain.NoFTL.NoFTLPrelude

/-!
# Sorts — Arithmetic Foundation

Faithful port of `No_FTL_observers_Gen_Rel.Sorts` from the AFP.

GenRel is a 2-sorted first-order logic. The two sorts are:
- **Bodies** (things that can move) — defined in `NoFTLPrelude`
- **Quantities** (used to specify coordinates, masses, etc.) — a linearly ordered field

The Isabelle `class Quantities = linordered_field` maps directly to
`[Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]` in Mathlib.
All lemmas are proved with real tactics.
-/

set_option autoImplicit false

namespace NoFTL.Sorts

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

-- ══════════════════════════════════════════════════════════════════════════════
-- §1  Basic arithmetic lemmas
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemLEPlus (a b c : Q) : a ≤ b + c → c ≥ a - b := by
  intro h; linarith

theorem lemMultPosLT1 (a b : Q) (h : a > 0 ∧ b ≥ 0 ∧ b < 1) : a * b < a := by
  nlinarith [mul_lt_mul_of_pos_left h.2.2 h.1]

theorem lemAbsRange (e a b : Q) : e > 0 → ((a - e < b ∧ b < a + e) ↔ |b - a| < e) := by
  intro he; constructor
  · intro ⟨h1, h2⟩; rw [abs_lt]; constructor <;> linarith
  · intro h; rw [abs_lt] at h; constructor <;> linarith

theorem lemAbsNeg (x : Q) : |x| = |- x| := (abs_neg x).symm

theorem lemAbsNegNeg (a b : Q) : |(-a) - b| = |a + b| := by
  rw [show -a - b = -(a + b) from by ring, abs_neg]

theorem lemGENZGT (x : Q) : x ≥ 0 ∧ x ≠ 0 → x > 0 := by
  intro ⟨h1, h2⟩; exact lt_of_le_of_ne' h1 h2

theorem lemLENZLT (x : Q) : x ≤ 0 ∧ x ≠ 0 → x < 0 := by
  intro ⟨h1, h2⟩; exact lt_of_le_of_ne h1 h2

theorem lemSumOfNonNegAndPos (x y : Q) : x ≥ 0 ∧ y > 0 → x + y > 0 := by
  intro ⟨h1, h2⟩; linarith

theorem lemSumOfTwoHalves (x : Q) : x = x / 2 + x / 2 := by ring

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
theorem lemDiffDiffAdd (a b c : Q) : (b - a) + (c - b) = c - a := by ring

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
theorem lemSumDiffCancelMiddle (a b c : Q) : (a - b) + (b - c) = a - c := by ring

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
theorem lemDiffSumCancelMiddle (a b c : Q) : (a - b) + (b + c) = a + c := by ring

theorem lemMultPosLT (a b c : Q) : 0 < a ∧ b < c → a * b < a * c := by
  intro ⟨ha, hbc⟩; exact mul_lt_mul_of_pos_left hbc ha

theorem lemMultPosLE (a b c : Q) : 0 < a ∧ b ≤ c → a * b ≤ a * c := by
  intro ⟨ha, hbc⟩; exact mul_le_mul_of_nonneg_left hbc (le_of_lt ha)

theorem lemNonNegLT (a b c : Q) : 0 ≤ a ∧ b < c → a * b ≤ a * c := by
  intro ⟨ha, hbc⟩; exact mul_le_mul_of_nonneg_left (le_of_lt hbc) ha

theorem lemMultNonNegLE (a b c : Q) : 0 ≤ a ∧ b ≤ c → a * b ≤ a * c := by
  intro ⟨ha, hbc⟩; exact mul_le_mul_of_nonneg_left hbc ha

-- ══════════════════════════════════════════════════════════════════════════════
-- §2  Squares, roots, and sqrt
-- ══════════════════════════════════════════════════════════════════════════════

/-- Square of a field element. -/
def sqr (x : Q) : Q := x * x

/-- `x` has a (not necessarily non-negative) square root. -/
def hasRoot (x : Q) : Prop := ∃ r : Q, x = sqr r

/-- `r` is a non-negative root of `x`. -/
def isNonNegRoot (x r : Q) : Prop := r ≥ 0 ∧ x = sqr r

/-- `x` has a unique non-negative root. -/
def hasUniqueRoot (x : Q) : Prop := ∃! r : Q, isNonNegRoot x r

/-- The non-negative square root, defined via definite description.
    Returns an arbitrary value when no root exists. -/
noncomputable def sqrt (x : Q) : Q :=
  Classical.epsilon (fun r : Q => isNonNegRoot x r)

theorem lemAbsIsRootOfSquare (x : Q) : isNonNegRoot (sqr x) |x| := by
  refine ⟨abs_nonneg x, ?_⟩
  unfold sqr; exact (abs_mul_abs_self x).symm

theorem sqr_nonneg' (x : Q) : sqr x ≥ 0 := by
  unfold sqr; exact mul_self_nonneg x

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
@[simp] theorem sqr_zero : sqr (0 : Q) = 0 := by unfold sqr; ring

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
@[simp] theorem sqr_one : sqr (1 : Q) = 1 := by unfold sqr; ring

theorem lemSqrt (x : Q) (h : hasRoot x) : hasUniqueRoot x := by
  obtain ⟨r, hr⟩ := h
  refine ⟨|r|, ?_, ?_⟩
  · refine ⟨abs_nonneg r, ?_⟩
    unfold sqr at hr ⊢; rw [hr]; exact (abs_mul_abs_self r).symm
  · intro y ⟨hy_nn, hy_sq⟩
    unfold sqr at hr hy_sq
    have hab : |r| * |r| = y * y := by
      rw [abs_mul_abs_self]; linarith
    nlinarith [abs_nonneg r, mul_self_nonneg (|r| - y)]

theorem lemSqrMonoStrict (u v : Q) (h : 0 ≤ u ∧ u < v) : sqr u < sqr v := by
  unfold sqr; nlinarith [h.1, h.2]

theorem lemSqrMono (u v : Q) : 0 ≤ u ∧ u ≤ v → sqr u ≤ sqr v := by
  intro ⟨hu, huv⟩; unfold sqr; nlinarith

theorem lemSqrOrderedStrict (u v : Q) : v > 0 ∧ sqr u < sqr v → u < v := by
  intro ⟨hv, hsq⟩
  by_contra h
  push Not at h
  have : sqr v ≤ sqr u := by unfold sqr at *; nlinarith
  linarith

theorem lemSqrOrdered (u v : Q) : v ≥ 0 ∧ sqr u ≤ sqr v → u ≤ v := by
  intro ⟨hv, hsq⟩
  by_contra h
  push Not at h
  have : sqr v < sqr u := lemSqrMonoStrict v u ⟨hv, h⟩
  linarith

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
theorem lemSquaredNegative (x : Q) : sqr x = sqr (-x) := by unfold sqr; ring

theorem lemSqrDiffSymmetrical (x y : Q) : sqr (x - y) = sqr (y - x) := by
  rw [show y - x = -(x - y) from by ring, ← lemSquaredNegative]

theorem lemSquaresPositive (x : Q) : x ≠ 0 → sqr x > 0 := by
  intro hx; unfold sqr
  rcases lt_or_gt_of_ne hx with h | h
  · exact mul_pos_of_neg_of_neg h h
  · exact mul_pos h h

theorem lemZeroRoot (x : Q) : sqr x = 0 ↔ x = 0 := by
  constructor
  · intro h; unfold sqr at h; exact mul_self_eq_zero.mp h
  · intro h; rw [h]; exact sqr_zero

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
theorem lemSqrMult (a b : Q) : sqr (a * b) = sqr a * sqr b := by unfold sqr; ring

theorem lemEqualSquares (u v : Q) : sqr u = sqr v → |u| = |v| := by
  intro h
  have hab : |u| * |u| = |v| * |v| := by
    rw [abs_mul_abs_self, abs_mul_abs_self]; unfold sqr at h; linarith
  nlinarith [abs_nonneg u, abs_nonneg v, mul_self_nonneg (|u| - |v|)]

-- ══════════════════════════════════════════════════════════════════════════════
-- §3  Sqrt properties (require hasRoot hypotheses)
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemSqrtOfSquare (a b : Q) (h : b = sqr a) : sqrt b = |a| := by
  have hab : isNonNegRoot b |a| := by rw [h]; exact lemAbsIsRootOfSquare a
  have hex : ∃ r, isNonNegRoot b r := ⟨|a|, hab⟩
  have hsqrt : isNonNegRoot b (sqrt b) := Classical.epsilon_spec hex
  obtain ⟨_, _, huniq⟩ := lemSqrt b ⟨a, h⟩
  exact (huniq _ hsqrt).trans (huniq _ hab).symm

theorem lemSquareOfSqrt (a b : Q) (hroot : hasRoot b) (ha : a = sqrt b) : sqr a = b := by
  subst ha
  obtain ⟨r, hr, _⟩ := lemSqrt b hroot
  have hsqrt : isNonNegRoot b (sqrt b) := Classical.epsilon_spec ⟨r, hr⟩
  exact hsqrt.2.symm

theorem lemSqrt1 : sqrt (1 : Q) = 1 := by
  have h := lemSqrtOfSquare (1 : Q) 1 sqr_one.symm
  rwa [abs_of_pos (by norm_num : (1 : Q) > 0)] at h

theorem lemSqrt0 : sqrt (0 : Q) = 0 := by
  have h := lemSqrtOfSquare (0 : Q) 0 sqr_zero.symm
  rwa [abs_of_nonneg (le_refl (0 : Q))] at h

-- ══════════════════════════════════════════════════════════════════════════════
-- §4  Expansion and quadratic lemmas
-- ══════════════════════════════════════════════════════════════════════════════

omit [LinearOrder Q] [IsStrictOrderedRing Q] in
theorem lemSqrSum (x y : Q) : sqr (x + y) = x * x + 2 * x * y + y * y := by
  unfold sqr; ring

theorem lemQuadraticGEZero (a b c : Q) (hpos : ∀ x : Q, a * sqr x + b * x + c ≥ 0)
    (ha : a > 0) : sqr b ≤ 4 * a * c := by
  by_contra h
  push Not at h
  -- If b*b > 4*a*c, we can find x making a*x² + b*x + c < 0
  -- Use x = -b/(2a)
  have ha2 : (2 * a : Q) ≠ 0 := by positivity
  have key := hpos (-b / (2 * a))
  unfold sqr at key h
  -- key says a*(-b/(2a))² + b*(-b/(2a)) + c ≥ 0
  -- multiply through by 4a > 0 to clear denominators
  have h4a : (4 * a : Q) > 0 := by positivity
  have key' : 4 * a * (a * (-b / (2 * a) * (-b / (2 * a))) + b * (-b / (2 * a)) + c) ≥ 0 :=
    mul_nonneg (le_of_lt h4a) key
  -- The LHS simplifies to 4ac - b²
  have : 4 * a * (a * (-b / (2 * a) * (-b / (2 * a))) + b * (-b / (2 * a)) + c) =
    4 * a * c - b * b := by field_simp; ring
  linarith

-- ══════════════════════════════════════════════════════════════════════════════
-- §5  Existence of large and small squares
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemSquareExistsAbove (y : Q) : ∃ x : Q, x > 0 ∧ sqr x > y := by
  by_cases hy : y ≤ 0
  · exact ⟨1, one_pos, by unfold sqr; nlinarith [one_pos (α := Q)]⟩
  · push Not at hy
    by_cases hy1 : y ≤ 1
    · exact ⟨2, by norm_num, by unfold sqr; nlinarith⟩
    · push Not at hy1
      exact ⟨y, hy, by unfold sqr; nlinarith⟩

theorem lemSmallSquares (x : Q) (hx : x > 0) : ∃ y : Q, y > 0 ∧ sqr y < x := by
  obtain ⟨z, hz_pos, hz_sq⟩ := lemSquareExistsAbove (1 / x : Q)
  have hzz : z * z > 0 := mul_pos hz_pos hz_pos
  refine ⟨1 / z, by positivity, ?_⟩
  unfold sqr at *
  rw [div_mul_div_comm, show (1 : Q) * 1 = 1 from by ring]
  -- Goal: 1 / (z * z) < x  ⟵  z * z > 1 / x  ⟵  hz_sq
  rw [div_lt_iff₀ hzz]
  calc 1 = 1 / x * x := by rw [div_mul_cancel₀ 1 (ne_of_gt hx)]
    _ < z * z * x := by nlinarith
    _ = x * (z * z) := by ring

theorem lemSqrLT1 (x : Q) (h : 0 < x ∧ x < 1) : 0 < sqr x ∧ sqr x < x := by
  constructor
  · exact lemSquaresPositive x (ne_of_gt h.1)
  · unfold sqr; nlinarith [h.1, h.2]

theorem lemReducedBound (x : Q) (hx : x > 0) :
    ∃ y : Q, y > 0 ∧ y < x ∧ sqr y < y ∧ y < 1 := by
  set y := min (x / 2) (1 / 2) with hy_def
  have hy_pos : y > 0 := lt_min (by linarith) (by norm_num : (0 : Q) < 1 / 2)
  have hy_lt_x : y < x := by
    have := min_le_left (x / 2) ((1 : Q) / 2); linarith
  have hy_lt_1 : y < 1 := by
    have := min_le_right (x / 2) ((1 : Q) / 2); linarith
  exact ⟨y, hy_pos, hy_lt_x, (lemSqrLT1 y ⟨hy_pos, hy_lt_1⟩).2, hy_lt_1⟩

end NoFTL.Sorts
