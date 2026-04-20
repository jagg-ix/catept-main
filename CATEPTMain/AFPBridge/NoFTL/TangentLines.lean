import CATEPTMain.AFPBridge.NoFTL.Translations
import CATEPTMain.AFPBridge.NoFTL.AxSelfMinus

/-!
# TangentLines — Tangent Lines and Instantaneous Velocity

Defines tangent lines to worldlines and the instantaneous velocity of
a body. The main results show that tangent lines are preserved under
translations.

Isabelle: `class TangentLines = Translations + AxSelfMinus`.
-/

set_option autoImplicit false

namespace NoFTL.TangentLines

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Translations NoFTL.WorldView

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable {B : Type*} [WorldViewRel B Q]

/-- `tangentLine l s x` means `l` is a tangent line to the set `s` at point `x`:
    `x ∈ s`, `x` lies on the line `l`, `x` is an accumulation point of `s`,
    and there exists a point `p` on `l` (different from `x`) witnessing the
    tangency condition. -/
def tangentLine (l s : Set (Point Q)) (x : Point Q) : Prop :=
  x ∈ s ∧ onLine x l ∧ accPoint x s ∧
    ∃ p, onLine p l ∧ p ≠ x ∧
      ∀ ε : Q, ε > 0 → ∃ δ : Q, δ > 0 ∧ ∀ y ∈ s,
        (inBall y δ x ∧ y ≠ x) →
          ∃ r, onLine r (lineJoining x y) ∧ inBall r ε p

/-- `tangentLineA l s x` is the universal (∀p) version of the tangent condition:
    for every `p` on `l` different from `x`, the approximation property holds. -/
def tangentLineA (l s : Set (Point Q)) (x : Point Q) : Prop :=
  x ∈ s ∧ onLine x l ∧ accPoint x s ∧
    ∀ p, onLine p l ∧ p ≠ x →
      ∀ ε : Q, ε > 0 → ∃ δ : Q, δ > 0 ∧ ∀ y ∈ s,
        (inBall y δ x ∧ y ≠ x) →
          ∃ r, onLine r (lineJoining x y) ∧ inBall r ε p

/-- A set has a tangent at a point. -/
def hasTangent (s : Set (Point Q)) (p : Point Q) : Prop :=
  ∃ l, tangentLine l s p

/-- The set of velocities associated with a line's direction vectors.
    Ported from Points.thy `lineVelocity`. -/
def lineVelocity (l : Set (Point Q)) : Set (Space Q) :=
  { v | ∃ d ∈ drtn l, v = velocityJoining origin d }

/-- The instantaneous velocity of a body along its worldline at a point. -/
def vel (wl : Set (Point Q)) (p : Point Q) (v : Space Q) : Prop :=
  ∃ l, tangentLine l wl p ∧ v ∈ lineVelocity l

-- ── Lemmas ───────────────────────────────────────────────────────────────────

theorem lemTangentLineTranslation (T : Point Q → Point Q) (hT : translation T)
    (l s : Set (Point Q)) (x : Point Q) (htgt : tangentLine l s x) :
    tangentLine (applyToSet (asFunc T) l) (applyToSet (asFunc T) s) (T x) := by
  obtain ⟨hxs, hxl, hacc, p, hpl, hne, hball⟩ := htgt
  refine ⟨⟨x, hxs, rfl⟩,
          Translations.lemOnLineTranslation T hT x l hxl,
          Translations.lemAccPointTranslation T hT x s hacc,
          T p, Translations.lemOnLineTranslation T hT p l hpl, ?_, ?_⟩
  · intro h; apply hne
    obtain ⟨t, ht⟩ := hT
    simp only [ht, moveBy, Point.mk.injEq] at h
    ext <;> linarith [h.1, h.2.1, h.2.2.1, h.2.2.2]
  · intro ε hε
    obtain ⟨δ, hδ, hδ_spec⟩ := hball ε hε
    refine ⟨δ, hδ, ?_⟩
    intro y' hy'_mem ⟨hy'_ball, hy'_ne⟩
    obtain ⟨y, hys, rfl⟩ := hy'_mem
    have hy_ball : inBall y δ x := by
      simp only [inBall] at hy'_ball ⊢
      rwa [Translations.lemTranslationPreservesSep2 T hT]
    have hy_ne : y ≠ x := by
      intro h; exact hy'_ne (by rw [h])
    obtain ⟨r, hr_line, hr_ball⟩ := hδ_spec y hys ⟨hy_ball, hy_ne⟩
    refine ⟨T r, ?_, Translations.lemBallTranslation T hT r p ε hr_ball⟩
    -- onLine (T r) (lineJoining (T x) (T y))
    -- Since lineJoining (T x) (T y) = applyToSet (asFunc T) (lineJoining x y)
    have hlj := Translations.lemLineJoiningTranslation T hT x y
    rw [← hlj]
    constructor
    · -- isLine (applyToSet (asFunc T) (lineJoining x y))
      rw [hlj]; exact ⟨T x, T y ⊖ T x, rfl⟩
    · exact ⟨r, hr_line.2, rfl⟩

theorem lemTangentLineA (l s : Set (Point Q)) (x : Point Q)
    (htgt : tangentLine l s x) : tangentLineA l s x := by
  obtain ⟨hxs, hxl, hacc, P, hPl, hPne, hPball⟩ := htgt
  refine ⟨hxs, hxl, hacc, ?_⟩
  intro p ⟨hpl, hpne⟩ ε hε
  -- l = lineJoining x p (since both x, p on l and x ≠ p)
  have hxne : x ≠ p := Ne.symm hpne
  have hl_eq : l = lineJoining x p :=
    (lemLineAndPoints x p l hxne).mp ⟨hxl, hpl⟩
  -- P is on l = lineJoining x p, so P = x ⊕ a⊗(p⊖x) for some a
  rw [hl_eq] at hPl
  obtain ⟨_, ⟨a, ha_eq⟩⟩ := hPl
  -- P ≠ x means a ≠ 0
  have anz : a ≠ 0 := by
    intro h; apply hPne; rw [ha_eq, h]
    ext <;> simp [moveBy, scaleBy] <;> ring
  -- Use |a|*ε as the ε for P
  set e₁ := |a| * ε with he1_def
  have he1_pos : e₁ > 0 := mul_pos (abs_pos.mpr anz) hε
  obtain ⟨δ, hδ, hδ_spec⟩ := hPball e₁ he1_pos
  refine ⟨δ, hδ, ?_⟩
  intro y hys ⟨hy_ball, hy_ne⟩
  obtain ⟨R, hR_line, hR_ball⟩ := hδ_spec y hys ⟨hy_ball, hy_ne⟩
  -- Construct r = x ⊕ (1/a)⊗(R⊖x)
  set r := x ⊕ ((1/a) ⊗ (R ⊖ x))
  -- r is on lineJoining x y
  have hr_on : onLine r (lineJoining x y) := by
    obtain ⟨_, ⟨γ, hγ⟩⟩ := hR_line
    -- hγ : R = x ⊕ (γ ⊗ (y ⊖ x))
    -- r = x ⊕ (1/a)⊗(R⊖x) = x ⊕ (γ/a)⊗(y⊖x)
    constructor
    · exact ⟨x, y ⊖ x, rfl⟩
    · refine ⟨γ / a, ?_⟩
      simp only [r]; rw [hγ]
      ext <;> simp [moveBy, movebackBy, scaleBy] <;> field_simp <;> ring
  -- r is near p (inBall r ε p)
  have hr_near : inBall r ε p := by
    simp only [inBall] at hR_ball ⊢
    -- sep2 r p = sqr(1/a) * sep2 R P  (by coordinate computation)
    have hsep_eq : sep2 r p = sqr (1/a) * sep2 R P := by
      rw [ha_eq]; simp only [r, sep2, norm2, movebackBy, moveBy, scaleBy, sqr]
      field_simp; ring
    rw [hsep_eq]
    -- sqr(1/a) * sep2 R P < sqr(1/a) * sqr e₁
    have ha2_pos : sqr (1/a) > 0 := lemSquaresPositive (1/a) (one_div_ne_zero anz)
    have h1 : sqr (1/a) * sep2 R P < sqr (1/a) * sqr e₁ :=
      mul_lt_mul_of_pos_left hR_ball ha2_pos
    -- sqr(1/a) * sqr(e₁) = sqr ε
    have hterm : sqr (1/a) * sqr e₁ = sqr ε := by
      simp only [he1_def, sqr]
      have hab : |a| * |a| = a * a := by rw [← abs_mul, abs_mul_self]
      field_simp; nlinarith
    linarith
  exact ⟨r, hr_on, hr_near⟩

theorem lemTangentLineE (l s : Set (Point Q)) (x : Point Q)
    (htgt : tangentLineA l s x) (hp : ∃ p, p ≠ x ∧ onLine p l) :
    tangentLine l s x := by
  obtain ⟨p, hne, hon⟩ := hp
  exact ⟨htgt.1, htgt.2.1, htgt.2.2.1, p, hon, hne, htgt.2.2.2 p ⟨hon, hne⟩⟩

end NoFTL.TangentLines
