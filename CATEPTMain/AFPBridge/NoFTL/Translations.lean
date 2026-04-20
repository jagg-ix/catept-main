import CATEPTMain.AFPBridge.NoFTL.Functions

/-!
# Translations — Spacetime Translation Maps

Defines spacetime translations and proves they preserve separation,
are injective, surjective, continuous, and compose properly.

Isabelle: `class Translations = Functions`.
-/

set_option autoImplicit false

namespace NoFTL.Translations

open NoFTL.Points NoFTL.Functions NoFTL.Sorts

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

/-- A translation by vector `t`: sends `p` to `p ⊕ t`. -/
def mkTranslation (t : Point Q) : Point Q → Point Q :=
  fun p => p ⊕ t

/-- A function is a translation if it is `mkTranslation t` for some `t`. -/
def translation (T : Point Q → Point Q) : Prop :=
  ∃ q, ∀ p, T p = p ⊕ q

-- ── Lemmas ───────────────────────────────────────────────────────────────────

theorem lemMkTrans (t : Point Q) : translation (mkTranslation t) :=
  ⟨t, fun _ => rfl⟩

/-- Helper: prove Point equality by showing each component matches. -/
private theorem point_eq {p q : Point Q}
    (ht : p.tval = q.tval) (hx : p.xval = q.xval)
    (hy : p.yval = q.yval) (hz : p.zval = q.zval) : p = q :=
  Point.ext ht hx hy hz

theorem lemInverseTranslation (t : Point Q) :
    mkTranslation (origin ⊖ t) ∘ mkTranslation t = id ∧
    mkTranslation t ∘ mkTranslation (origin ⊖ t) = id := by
  constructor <;> {
    funext p
    simp only [Function.comp, id, mkTranslation, moveBy, movebackBy, origin]
    exact point_eq (by ring) (by ring) (by ring) (by ring)
  }

theorem lemTranslationSum (T : Point Q → Point Q) (hT : translation T)
    (u v : Point Q) : T (u ⊕ v) = T u ⊕ v := by
  obtain ⟨t, ht⟩ := hT; simp only [ht, moveBy]
  exact point_eq (by ring) (by ring) (by ring) (by ring)

theorem lemIdIsTranslation : translation (id : Point Q → Point Q) :=
  ⟨origin, fun p => by
    show p = p ⊕ origin
    simp only [moveBy, origin]
    exact (point_eq (by ring) (by ring) (by ring) (by ring)).symm⟩

theorem lemTranslationCancel (T : Point Q → Point Q) (hT : translation T)
    (p q : Point Q) : T p ⊖ T q = p ⊖ q := by
  obtain ⟨t, ht⟩ := hT; simp only [ht, moveBy, movebackBy]
  exact point_eq (by ring) (by ring) (by ring) (by ring)

theorem lemTranslationSwap (T : Point Q → Point Q) (hT : translation T)
    (p q : Point Q) : moveBy p (T q) = moveBy (T p) q := by
  obtain ⟨t, ht⟩ := hT; simp only [ht, moveBy]
  exact point_eq (by ring) (by ring) (by ring) (by ring)

theorem lemTranslationPreservesSep2 (T : Point Q → Point Q) (hT : translation T)
    (p q : Point Q) : sep2 p q = sep2 (T p) (T q) := by
  simp only [sep2]; congr 1
  exact (lemTranslationCancel T hT p q).symm

theorem lemTranslationInjective (T : Point Q → Point Q) (hT : translation T) :
    injective (asFunc T) := by
  obtain ⟨t, ht⟩ := hT
  intro x₁ x₂ y₁ y₂ ⟨⟨h1, h2⟩, hne⟩ heq
  simp only [asFunc] at h1 h2
  apply hne
  have hTeq : T x₁ = T x₂ := by rw [← h1, heq, h2]
  simp only [ht, moveBy] at hTeq
  exact point_eq
    (by have := congr_arg Point.tval hTeq; simp at this; linarith)
    (by have := congr_arg Point.xval hTeq; simp at this; linarith)
    (by have := congr_arg Point.yval hTeq; simp at this; linarith)
    (by have := congr_arg Point.zval hTeq; simp at this; linarith)

theorem lemTranslationSurjective (T : Point Q → Point Q) (hT : translation T) :
    surjective (asFunc T) := by
  obtain ⟨t, ht⟩ := hT
  intro y
  refine ⟨y ⊖ t, ?_⟩
  show y = T (y ⊖ t)
  simp only [ht, moveBy, movebackBy]
  exact (point_eq (by ring) (by ring) (by ring) (by ring)).symm

theorem lemTranslationTotalFunction (T : Point Q → Point Q) (hT : translation T) :
    isTotalFunction (asFunc T) := by
  exact ⟨fun x => ⟨T x, rfl⟩,
         fun x y z ⟨hy, hz⟩ => by simp only [asFunc] at hy hz; rw [hy, hz]⟩

theorem lemTranslationOfLine (T : Point Q → Point Q) (hT : translation T)
    (B D : Point Q) :
    applyToSet (asFunc T) (line B D) = line (T B) D := by
  ext q'
  simp only [applyToSet, line, Set.mem_setOf_eq, asFunc]
  constructor
  · rintro ⟨q, ⟨α, rfl⟩, rfl⟩
    exact ⟨α, lemTranslationSum T hT B (α ⊗ D)⟩
  · rintro ⟨α, rfl⟩
    exact ⟨B ⊕ (α ⊗ D), ⟨α, rfl⟩, (lemTranslationSum T hT B (α ⊗ D)).symm⟩

theorem lemOnLineTranslation (T : Point Q → Point Q) (hT : translation T)
    (p : Point Q) (l : Set (Point Q)) (hp : onLine p l) :
    onLine (T p) (applyToSet (asFunc T) l) := by
  obtain ⟨hline, hmem⟩ := hp
  obtain ⟨B, D, rfl⟩ := hline
  have himg : applyToSet (asFunc T) (line B D) = line (T B) D :=
    lemTranslationOfLine T hT B D
  constructor
  · rw [himg]; exact ⟨T B, D, rfl⟩
  · exact ⟨p, hmem, rfl⟩

theorem lemLineJoiningTranslation (T : Point Q → Point Q) (hT : translation T)
    (p q : Point Q) :
    applyToSet (asFunc T) (lineJoining p q) = lineJoining (T p) (T q) := by
  simp only [lineJoining]
  rw [lemTranslationOfLine T hT p (q ⊖ p)]
  congr 1
  exact (lemTranslationCancel T hT q p).symm

theorem lemBallTranslation (T : Point Q → Point Q) (hT : translation T)
    (x y : Point Q) (e : Q) (h : inBall x e y) :
    inBall (T x) e (T y) := by
  simp only [inBall] at *
  rwa [← lemTranslationPreservesSep2 T hT]

theorem lemBallTranslationWithBoundary (T : Point Q → Point Q) (hT : translation T)
    (x y : Point Q) (e : Q) (h : sep2 x y ≤ sqr e) :
    sep2 (T x) (T y) ≤ sqr e := by
  rwa [← lemTranslationPreservesSep2 T hT]

theorem lemTranslationIsCts (T : Point Q → Point Q) (hT : translation T)
    (x : Point Q) : cts (asFunc T) x := by
  intro y hy ε hε
  simp only [asFunc] at hy; subst hy
  refine ⟨ε, hε, ?_⟩
  intro p' hp'
  simp only [applyToSet, ball, Set.mem_setOf_eq, asFunc] at hp'
  obtain ⟨p, hp_ball, rfl⟩ := hp'
  simp only [ball, Set.mem_setOf_eq]
  exact lemBallTranslation T hT x p ε hp_ball

theorem lemAccPointTranslation (T : Point Q → Point Q) (hT : translation T)
    (x : Point Q) (s : Set (Point Q)) (hacc : accPoint x s) :
    accPoint (T x) (applyToSet (asFunc T) s) := by
  intro ε hε
  obtain ⟨q, hqs, hneq, hball⟩ := hacc ε hε
  refine ⟨T q, ⟨q, hqs, rfl⟩, ?_, lemBallTranslation T hT q x ε hball⟩
  intro h
  have hinj := lemTranslationInjective T hT
  exact hneq (by
    by_contra hc
    exact hinj x q (T x) (T q) ⟨⟨rfl, rfl⟩, hc⟩ h)

theorem lemInverseOfTransIsTrans (T : Point Q → Point Q) (hT : translation T)
    (T' : Point Q → Point Q → Prop) (hT' : T' = invFunc (asFunc T)) :
    translation (toFunc T') := by
  obtain ⟨t, ht⟩ := hT
  -- The inverse translation is mkTranslation (origin ⊖ t)
  -- toFunc T' should equal mkTranslation (origin ⊖ t)
  -- First show T' p r ↔ T r = p ↔ r ⊕ t = p ↔ r = p ⊕ (origin ⊖ t)
  have hT'_spec : ∀ p, toFunc T' p = mkTranslation (origin ⊖ t) p := by
    intro p
    show Classical.epsilon (T' p) = mkTranslation (origin ⊖ t) p
    rw [hT']
    show Classical.epsilon (fun r => asFunc T r p) = _
    simp only [asFunc]
    -- Goal: Classical.epsilon (fun r => p = T r) = mkTranslation (origin ⊖ t) p
    have hex : ∃ r, p = T r := ⟨mkTranslation (origin ⊖ t) p, by
      simp [ht, mkTranslation, moveBy, movebackBy, origin]⟩
    have huniq : ∀ r, p = T r → r = mkTranslation (origin ⊖ t) p := by
      intro r hr
      simp [ht, mkTranslation, moveBy, movebackBy, origin] at hr ⊢
      exact point_eq (by linarith [congr_arg Point.tval hr])
                     (by linarith [congr_arg Point.xval hr])
                     (by linarith [congr_arg Point.yval hr])
                     (by linarith [congr_arg Point.zval hr])
    exact huniq _ (Classical.epsilon_spec hex)
  exact ⟨origin ⊖ t, fun p => hT'_spec p⟩

theorem lemInverseTrans (T : Point Q → Point Q) (hT : translation T) :
    ∃ T', translation T' ∧ ∀ p q, T p = q ↔ T' q = p := by
  obtain ⟨t, ht⟩ := hT
  refine ⟨mkTranslation (origin ⊖ t), lemMkTrans _, ?_⟩
  intro p q; simp only [ht, mkTranslation]
  constructor
  · rintro rfl
    simp only [moveBy, movebackBy, origin]
    exact point_eq (by ring) (by ring) (by ring) (by ring)
  · intro h
    simp only [moveBy, movebackBy, origin] at h
    have ht := congr_arg Point.tval h
    have hx := congr_arg Point.xval h
    have hy := congr_arg Point.yval h
    have hz := congr_arg Point.zval h
    simp only [moveBy] at ht hx hy hz ⊢
    exact point_eq (by linarith) (by linarith) (by linarith) (by linarith)

end NoFTL.Translations
