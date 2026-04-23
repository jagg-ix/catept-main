import CATEPTMain.Geometry.NoFTL.Functions
import CATEPTMain.Geometry.NoFTL.AxEField

/-!
# Quadratics — Quadratic Root Theory

Shows how to find the roots of a quadratic, assuming roots exist (AxEField).
Classifies quadratics into six cases based on the discriminant.

Isabelle: `class Quadratics = Functions + AxEField`.
-/

set_option autoImplicit false

namespace NoFTL.Quadratics

open NoFTL.Points NoFTL.Sorts NoFTL.Functions

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

-- ── Definitions ─────────────────────────────────────────────────────────────

/-- Quadratic polynomial `a x² + b x + c`. -/
def quadratic (a b c : Q) : Q → Q :=
  fun x => a * sqr x + b * x + c

/-- Whether `r` is a root of the quadratic `a x² + b x + c`. -/
def qroot (a b c r : Q) : Prop := quadratic a b c r = 0

/-- The set of roots of the quadratic `a x² + b x + c`. -/
def qroots (a b c : Q) : Set Q := { r | qroot a b c r }

/-- The discriminant `b² - 4ac`. -/
def discriminant (a b c : Q) : Q := sqr b - 4 * a * c

/-- Case 1: `a = 0, b = 0, c = 0` (all values are roots). -/
def qcase1 (a b c : Q) : Prop := a = 0 ∧ b = 0 ∧ c = 0

/-- Case 2: `a = 0, b = 0, c ≠ 0` (no roots). -/
def qcase2 (a b c : Q) : Prop := a = 0 ∧ b = 0 ∧ c ≠ 0

/-- Case 3: `a = 0, b ≠ 0` (one linear root). -/
def qcase3 (a b c : Q) : Prop := a = 0 ∧ b ≠ 0

/-- Case 4: `a ≠ 0` and discriminant < 0 (no real roots). -/
def qcase4 (a b c : Q) : Prop := a ≠ 0 ∧ discriminant a b c < 0

/-- Case 5: `a ≠ 0` and discriminant = 0 (one repeated root). -/
def qcase5 (a b c : Q) : Prop := a ≠ 0 ∧ discriminant a b c = 0

/-- Case 6: `a ≠ 0` and discriminant > 0 (two distinct roots). -/
def qcase6 (a b c : Q) : Prop := a ≠ 0 ∧ discriminant a b c > 0

-- ── Lemmas ──────────────────────────────────────────────────────────────────

theorem lemQuadRootCondition (a b c r : Q) (ha : a ≠ 0) :
    sqr (2 * a * r + b) = discriminant a b c ↔ qroot a b c r := by
  unfold discriminant qroot quadratic sqr
  constructor
  · intro h
    have h4a : (4 * a : Q) ≠ 0 := by
      intro h0
      have : (4 : Q) ≠ 0 := by positivity
      exact ha (by rwa [mul_eq_zero, or_iff_right this] at h0)
    have : 4 * a * (a * (r * r) + b * r + c) = 0 := by nlinarith
    exact (mul_eq_zero.mp this).resolve_left h4a
  · intro h
    have hq : a * (r * r) + b * r + c = 0 := h
    -- (2ar+b)² = 4a²r² + 4abr + b² = 4a(ar²+br+c) + b² - 4ac = b² - 4ac
    have key : (2 * a * r + b) * (2 * a * r + b) - (b * b - 4 * a * c) =
        4 * a * (a * (r * r) + b * r + c) := by ring
    have : 4 * a * (a * (r * r) + b * r + c) = 0 := by rw [hq]; ring
    linarith

theorem lemQuadraticCasesComplete (a b c : Q) :
    qcase1 a b c ∨ qcase2 a b c ∨ qcase3 a b c ∨
    qcase4 a b c ∨ qcase5 a b c ∨ qcase6 a b c := by
  unfold qcase1 qcase2 qcase3 qcase4 qcase5 qcase6
  by_cases ha : a = 0
  · by_cases hb : b = 0
    · by_cases hc : c = 0
      · left; exact ⟨ha, hb, hc⟩
      · right; left; exact ⟨ha, hb, hc⟩
    · right; right; left; exact ⟨ha, hb⟩
  · rcases lt_trichotomy (discriminant a b c) 0 with hd | hd | hd
    · right; right; right; left; exact ⟨ha, hd⟩
    · right; right; right; right; left; exact ⟨ha, hd⟩
    · right; right; right; right; right; exact ⟨ha, hd⟩

theorem lemQCase1 (a b c : Q) (h : qcase1 a b c) :
    ∀ r, qroot a b c r := by
  intro r; unfold qroot quadratic; obtain ⟨ha, hb, hc⟩ := h; rw [ha, hb, hc]; simp [sqr]

theorem lemQCase2 (a b c : Q) (h : qcase2 a b c) :
    ¬ ∃ r, qroot a b c r := by
  intro ⟨r, hr⟩; unfold qroot quadratic at hr; obtain ⟨ha, hb, hc⟩ := h
  rw [ha, hb] at hr; simp [sqr] at hr; exact hc hr

theorem lemQCase3 (a b c r : Q) (h : qcase3 a b c) :
    qroot a b c r ↔ r = -c / b := by
  obtain ⟨ha, hb⟩ := h
  unfold qroot quadratic; rw [ha]; simp [sqr]
  constructor
  · intro hr
    have : b * r = -c := by linarith
    rw [eq_div_iff hb]; linarith
  · intro hr; rw [hr]; field_simp; ring

theorem lemQCase4 (a b c : Q) (h : qcase4 a b c) :
    ¬ ∃ r, qroot a b c r := by
  obtain ⟨ha, hd⟩ := h
  intro ⟨r, hr⟩
  have := (lemQuadRootCondition a b c r ha).mpr hr
  have := sqr_nonneg' (2 * a * r + b)
  linarith

theorem lemQCase5 (a b c r : Q) (h : qcase5 a b c) :
    qroot a b c r ↔ r = -b / (2 * a) := by
  obtain ⟨ha, hd⟩ := h
  have h2a : (2 * a : Q) ≠ 0 := by
    intro h0; exact ha (by rwa [mul_eq_zero, or_iff_right (by positivity : (2 : Q) ≠ 0)] at h0)
  constructor
  · intro hr
    have hsq := (lemQuadRootCondition a b c r ha).mpr hr
    rw [hd] at hsq
    have hzero : 2 * a * r + b = 0 := (lemZeroRoot (2 * a * r + b)).mp hsq
    have : 2 * a * r = -b := by linarith
    rw [show r = (2 * a * r) / (2 * a) from (mul_div_cancel_left₀ r h2a).symm, this]
  · intro hr
    apply (lemQuadRootCondition a b c r ha).mp
    rw [hd, hr]; field_simp; simp [sqr]

theorem lemQCase6 (a b c rd rp rm : Q) (h : qcase6 a b c)
    (hrd : rd = sqrt (discriminant a b c))
    (hrp : rp = (-b + rd) / (2 * a))
    (hrm : rm = (-b - rd) / (2 * a)) :
    rp ≠ rm ∧ qroots a b c = {rp, rm} := by
  obtain ⟨ha, hd⟩ := h
  set d := discriminant a b c with d_def
  -- sqrt properties
  have hroot : hasRoot d := AxEField.axEField d (le_of_lt hd)
  have hrd_sq : sqr rd = d := lemSquareOfSqrt rd d hroot hrd
  -- rd ≠ 0
  have hrd_nz : rd ≠ 0 := by
    intro h0; rw [h0] at hrd_sq; simp [sqr] at hrd_sq; linarith
  -- 2*a ≠ 0
  have h2a : (2 * a : Q) ≠ 0 := by
    intro h0; exact ha (by rwa [mul_eq_zero, or_iff_right (by positivity : (2 : Q) ≠ 0)] at h0)
  -- rp ≠ rm
  have conj1 : rp ≠ rm := by
    rw [hrp, hrm]; intro heq
    have h1 : (-b + rd) / (2 * a) * (2 * a) = (-b - rd) / (2 * a) * (2 * a) :=
      congr_arg (· * (2 * a)) heq
    simp only [div_mul_cancel₀ _ h2a] at h1
    have : rd = 0 := by linarith
    exact hrd_nz this
  -- qroots = {rp, rm}
  have conj2 : qroots a b c = {rp, rm} := by
    ext r; simp only [qroots, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
    constructor
    · -- r is a root → r = rp ∨ r = rm
      intro hr
      have hsq := (lemQuadRootCondition a b c r ha).mpr hr
      -- sqr(2ar+b) = d, so sqrt d = |2ar+b|
      have habs : rd = |2 * a * r + b| := by
        rw [hrd]; exact lemSqrtOfSquare (2 * a * r + b) d hsq.symm
      -- |2ar+b| = rd, so 2ar+b = rd ∨ 2ar+b = -rd
      set v := 2 * a * r + b
      by_cases hv : v ≥ 0
      · -- v ≥ 0, so |v| = v, hence v = rd
        rw [abs_of_nonneg hv] at habs
        left; rw [hrp]
        have : 2 * a * r = -b + rd := by linarith
        rw [show r = (2 * a * r) / (2 * a) from (mul_div_cancel_left₀ r h2a).symm, this]
      · -- v < 0, so |v| = -v, hence -v = rd, i.e., v = -rd
        push_neg at hv
        rw [abs_of_neg hv] at habs
        right; rw [hrm]
        have : 2 * a * r = -b - rd := by linarith
        rw [show r = (2 * a * r) / (2 * a) from (mul_div_cancel_left₀ r h2a).symm, this]
    · -- r = rp ∨ r = rm → r is a root
      rintro (hr | hr) <;> rw [hr]
      · -- rp is a root: 2*a*rp + b = rd, so sqr(2*a*rp+b) = sqr rd = d
        apply (lemQuadRootCondition a b c rp ha).mp
        have h2arp : 2 * a * rp + b = rd := by rw [hrp]; field_simp; ring
        rw [h2arp]; exact hrd_sq
      · -- rm is a root: 2*a*rm + b = -rd, so sqr(2*a*rm+b) = sqr(-rd) = sqr rd = d
        apply (lemQuadRootCondition a b c rm ha).mp
        have h2arm : 2 * a * rm + b = -rd := by rw [hrm]; field_simp; ring
        rw [h2arm, ← lemSquaredNegative]; exact hrd_sq
  exact ⟨conj1, conj2⟩

theorem lemQuadraticRootCount (a b c : Q) (h : ¬ qcase1 a b c) :
    Set.Finite (qroots a b c) ∧ Set.ncard (qroots a b c) ≤ 2 := by
  rcases lemQuadraticCasesComplete (Q := Q) a b c with h1 | h2 | h3 | h4 | h5 | h6
  · exact absurd h1 h
  · -- case 2: no roots
    have := lemQCase2 a b c h2
    have hempty : qroots a b c = ∅ := by
      ext r; simp only [qroots, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
      intro hr; exact this ⟨r, hr⟩
    rw [hempty]; exact ⟨Set.finite_empty, by simp⟩
  · -- case 3: one root
    have : qroots a b c = {-c / b} := by
      ext r; simp only [qroots, Set.mem_setOf_eq, Set.mem_singleton_iff]
      exact lemQCase3 a b c r h3
    rw [this]; exact ⟨Set.finite_singleton _, by simp [Set.ncard_singleton]⟩
  · -- case 4: no roots
    have := lemQCase4 a b c h4
    have hempty : qroots a b c = ∅ := by
      ext r; simp only [qroots, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
      intro hr; exact this ⟨r, hr⟩
    rw [hempty]; exact ⟨Set.finite_empty, by simp⟩
  · -- case 5: one root
    have : qroots a b c = {-b / (2 * a)} := by
      ext r; simp only [qroots, Set.mem_setOf_eq, Set.mem_singleton_iff]
      exact lemQCase5 a b c r h5
    rw [this]; exact ⟨Set.finite_singleton _, by simp [Set.ncard_singleton]⟩
  · -- case 6: two roots
    set rd := sqrt (discriminant a b c)
    set rp := (-b + rd) / (2 * a)
    set rm := (-b - rd) / (2 * a)
    obtain ⟨hne, heq⟩ := lemQCase6 a b c rd rp rm h6 rfl rfl rfl
    rw [heq]
    refine ⟨Set.toFinite _, ?_⟩
    have : Set.ncard ({rp, rm} : Set Q) ≤ Set.ncard ({rm} : Set Q) + 1 :=
      Set.ncard_insert_le rp {rm}
    simp only [Set.ncard_singleton] at this
    omega

end NoFTL.Quadratics
