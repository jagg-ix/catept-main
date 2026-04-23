import CATEPTMain.NoFTL.Translations
import CATEPTMain.NoFTL.LinearMaps

/-!
# Affine — Affine Transformations

Defines affine transformations and establishes their key properties:
uniqueness of linear/translation parts, composition, continuity,
and affine approximation.

Isabelle: `class Affine = Translations + LinearMaps`.
-/

set_option autoImplicit false

namespace NoFTL.Affine

open NoFTL.Points NoFTL.Sorts NoFTL.Functions NoFTL.Norms NoFTL.Vectors
open NoFTL.Translations NoFTL.LinearMaps NoFTL.Matrices

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

-- ── Definitions ─────────────────────────────────────────────────────────────

/-- A function is affine if it can be written as `T ∘ L` where `L` is linear
    and `T` is a translation. -/
def affine (A : Point Q → Point Q) : Prop :=
  ∃ L T : Point Q → Point Q, linear L ∧ translation T ∧ A = T ∘ L

/-- An affine function that is also invertible. -/
def affInvertible (A : Point Q → Point Q) : Prop :=
  affine A ∧ invertible A

/-- `L` is the linear part of the affine map `A`. -/
def isLinearPart (A L : Point Q → Point Q) : Prop :=
  affine A ∧ linear L ∧ ∃ T, translation T ∧ A = T ∘ L

/-- `T` is the translation part of the affine map `A`. -/
def isTranslationPart (A T : Point Q → Point Q) : Prop :=
  affine A ∧ translation T ∧ ∃ L, linear L ∧ A = T ∘ L

/-- Affine approximation: `A` is an invertible affine map that approximates
    the relational function `f` at `x`. -/
def affineApprox (A : Point Q → Point Q) (f : Point Q → Point Q → Prop) (x : Point Q) : Prop :=
  isFunction f ∧ affInvertible A ∧ diffApprox (asFunc A) f x

/-- The image of a line under an affine map, represented structurally. -/
def applyAffineToLine (A : Point Q → Point Q) (l l' : Set (Point Q)) : Prop :=
  affine A ∧
  ∃ T L b d, linear L ∧ translation T ∧ A = T ∘ L ∧
    l = line b d ∧ l' = line (A b) (L d)

/-- An affine map is constant on a set near `x`. -/
def affConstantOn (A : Point Q → Point Q) (x : Point Q) (s : Set (Point Q)) : Prop :=
  ∃ ε > 0, ∀ y ∈ s, inBall y ε x → A y = A x

-- ── Lemmas ──────────────────────────────────────────────────────────────────

theorem lemTranslationPartIsUnique (A T1 T2 : Point Q → Point Q)
    (h1 : isTranslationPart A T1) (h2 : isTranslationPart A T2) :
    T1 = T2 := by
  obtain ⟨_, hT1, L1, hL1, hA1⟩ := h1
  obtain ⟨_, hT2, L2, hL2, hA2⟩ := h2
  obtain ⟨t1, ht1⟩ := hT1
  obtain ⟨t2, ht2⟩ := hT2
  -- T1 x = x ⊕ t1, T2 x = x ⊕ t2
  -- A = T1 ∘ L1 = T2 ∘ L2
  -- A origin = T1 (L1 origin) = T1 origin = origin ⊕ t1 = t1 (morally)
  -- Similarly A origin = t2. So t1 = t2.
  have h : T1 (L1 origin) = T2 (L2 origin) := by
    have h1 : A origin = T1 (L1 origin) := congr_fun hA1 origin
    have h2 : A origin = T2 (L2 origin) := congr_fun hA2 origin
    rw [← h1, ← h2]
  rw [hL1.1, hL2.1] at h
  -- T1 origin = T2 origin means origin ⊕ t1 = origin ⊕ t2 means t1 = t2
  simp only [ht1, ht2, moveBy, origin, Point.mk.injEq] at h
  have ht_eq : t1 = t2 :=
    Point.ext (by linarith [h.1]) (by linarith [h.2.1])
      (by linarith [h.2.2.1]) (by linarith [h.2.2.2])
  funext x; rw [ht1, ht2, ht_eq]

theorem lemLinearPartIsUnique (A L1 L2 : Point Q → Point Q)
    (h1 : isLinearPart A L1) (h2 : isLinearPart A L2) :
    L1 = L2 := by
  obtain ⟨_, hL1, T1, hT1, hA1⟩ := h1
  obtain ⟨_, hL2, T2, hT2, hA2⟩ := h2
  -- T1 = T2 by translation part uniqueness
  have hTeq : T1 = T2 :=
    lemTranslationPartIsUnique A T1 T2
      ⟨⟨L1, T1, hL1, hT1, hA1⟩, hT1, L1, hL1, hA1⟩
      ⟨⟨L2, T2, hL2, hT2, hA2⟩, hT2, L2, hL2, hA2⟩
  -- A = T ∘ L1 = T ∘ L2, and T is injective, so L1 = L2
  subst hTeq
  obtain ⟨t, ht⟩ := hT1
  funext x
  have h := congr_fun (hA1.symm.trans hA2) x
  simp only [Function.comp] at h
  -- h : T1 (L1 x) = T1 (L2 x), i.e. L1 x ⊕ t = L2 x ⊕ t
  simp only [ht, moveBy, Point.mk.injEq] at h
  exact Point.ext (by linarith [h.1]) (by linarith [h.2.1]) (by linarith [h.2.2.1]) (by linarith [h.2.2.2])

theorem lemLinearImpliesAffine (L : Point Q → Point Q) (hL : linear L) :
    affine L := by
  exact ⟨L, id, hL, lemIdIsTranslation, by simp [Function.comp]⟩

theorem lemTranslationImpliesAffine (T : Point Q → Point Q) (hT : translation T) :
    affine T := by
  exact ⟨id, T, lemIdIsLinear, hT, by simp [Function.comp]⟩

theorem lemAffineDiff (A L : Point Q → Point Q) (p q : Point Q)
    (hL : linear L)
    (hT : ∃ T, translation T ∧ A = T ∘ L) :
    A p ⊖ A q = L (p ⊖ q) := by
  obtain ⟨T, hTtrans, rfl⟩ := hT
  simp only [Function.comp]
  rw [lemTranslationCancel T hTtrans (L p) (L q)]
  exact (hL.2.2.2 p q).symm

theorem lemAffineImpliesTotalFunction (A : Point Q → Point Q) (hA : affine A) :
    isTotalFunction (asFunc A) := by
  constructor
  · intro x; exact ⟨A x, rfl⟩
  · intro x y z ⟨h1, h2⟩; rw [h1, h2]

theorem lemAffineEqualAtBase (A : Point Q → Point Q)
    (f : Point Q → Point Q → Prop) (x : Point Q)
    (happrox : affineApprox A f x) :
    ∀ y, f x y ↔ y = A x := by
  intro y
  obtain ⟨hfun, _, hdiff⟩ := happrox
  constructor
  · intro hfy
    exact lemApproxEqualAtBase (asFunc A) f x hdiff y (A x) hfy rfl
  · intro hy; subst hy
    -- f is defined at x, so ∃ z, f x z. By single-valuedness and the approx, z = A x
    obtain ⟨z, hz⟩ := hdiff.1
    have : z = A x := lemApproxEqualAtBase (asFunc A) f x hdiff z (A x) hz rfl
    rw [← this]; exact hz

theorem lemAffineOfPointOnLine (A L : Point Q → Point Q) (b d : Point Q) (a : Q)
    (hL : linear L) (hT : ∃ T, translation T ∧ A = T ∘ L) :
    A (b ⊕ (a ⊗ d)) = A b ⊕ (a ⊗ L d) := by
  obtain ⟨T, hTtrans, rfl⟩ := hT
  simp only [Function.comp]
  -- L(b ⊕ (a ⊗ d)) = L(b) ⊕ L(a ⊗ d) = L(b) ⊕ (a ⊗ L(d))
  rw [hL.2.2.1 b (a ⊗ d), hL.2.1 a d]
  exact lemTranslationSum T hTtrans (L b) (a ⊗ L d)

theorem lemAffineOfLineIsLine (A : Point Q → Point Q) (l l' : Set (Point Q))
    (hline : isLine l) :
    applyAffineToLine A l l' ↔ (affine A ∧ l' = applyToSet (asFunc A) l) := by
  constructor
  · -- Forward: applyAffineToLine → affine ∧ l' = applyToSet
    intro ⟨hA, T, L, b, d, hL, hT, hcomp, hl, hl'⟩
    refine ⟨hA, ?_⟩
    ext p'; constructor
    · -- p' ∈ l' → p' ∈ applyToSet (asFunc A) l
      intro hp'
      rw [hl'] at hp'
      simp only [line, Set.mem_setOf_eq] at hp'
      obtain ⟨a, ha⟩ := hp'
      -- p' = A b ⊕ (a ⊗ L d) = A (b ⊕ (a ⊗ d))
      have hpt := lemAffineOfPointOnLine A L b d a hL ⟨T, hT, hcomp⟩
      refine ⟨b ⊕ (a ⊗ d), ?_, ?_⟩
      · rw [hl]; simp only [line, Set.mem_setOf_eq]; exact ⟨a, rfl⟩
      · simp only [asFunc]; rw [hpt]; exact ha
    · -- p' ∈ applyToSet (asFunc A) l → p' ∈ l'
      intro ⟨p, hp, hfp⟩
      simp only [asFunc] at hfp
      rw [hl] at hp
      simp only [line, Set.mem_setOf_eq] at hp
      obtain ⟨a, rfl⟩ := hp
      rw [hl']
      simp only [line, Set.mem_setOf_eq]
      exact ⟨a, by rw [hfp, lemAffineOfPointOnLine A L b d a hL ⟨T, hT, hcomp⟩]⟩
  · -- Backward: affine ∧ l' = applyToSet → applyAffineToLine
    intro ⟨hA, hl'⟩
    obtain ⟨b, d, hbd⟩ := hline
    obtain ⟨L, T, hL, hT, hcomp⟩ := hA
    refine ⟨⟨L, T, hL, hT, hcomp⟩, T, L, b, d, hL, hT, hcomp, hbd, ?_⟩
    rw [hl']; ext p'
    simp only [applyToSet, line, asFunc, Set.mem_setOf_eq]
    constructor
    · rintro ⟨p, hp, rfl⟩
      rw [hbd] at hp
      simp only [line, Set.mem_setOf_eq] at hp
      obtain ⟨a, rfl⟩ := hp
      exact ⟨a, lemAffineOfPointOnLine A L b d a hL ⟨T, hT, hcomp⟩⟩
    · intro ⟨a, ha⟩
      refine ⟨b ⊕ (a ⊗ d), ?_, ?_⟩
      · rw [hbd]; simp only [line, Set.mem_setOf_eq]; exact ⟨a, rfl⟩
      · rw [lemAffineOfPointOnLine A L b d a hL ⟨T, hT, hcomp⟩]; exact ha

theorem lemOnLineUnderAffine (A : Point Q → Point Q) (p : Point Q) (l : Set (Point Q))
    (hA : affine A) (hon : onLine p l) :
    onLine (A p) (applyToSet (asFunc A) l) := by
  obtain ⟨hline, hmem⟩ := hon
  obtain ⟨b, d, rfl⟩ := hline
  obtain ⟨L, T, hL, hT, rfl⟩ := hA
  constructor
  · -- applyToSet (asFunc (T ∘ L)) (line b d) is a line
    refine ⟨(T ∘ L) b, L d, ?_⟩
    ext q; simp only [applyToSet, line, asFunc, Set.mem_setOf_eq]
    constructor
    · rintro ⟨p', ⟨α, rfl⟩, rfl⟩
      exact ⟨α, lemAffineOfPointOnLine (T ∘ L) L b d α hL ⟨T, hT, rfl⟩⟩
    · rintro ⟨α, rfl⟩
      exact ⟨b ⊕ (α ⊗ d), ⟨α, rfl⟩,
        (lemAffineOfPointOnLine (T ∘ L) L b d α hL ⟨T, hT, rfl⟩).symm⟩
  · exact ⟨p, hmem, rfl⟩

theorem lemLineJoiningUnderAffine (A : Point Q → Point Q) (p q : Point Q) (hA : affine A) :
    applyToSet (asFunc A) (lineJoining p q) = lineJoining (A p) (A q) := by
  obtain ⟨L, T, hL, hT, rfl⟩ := hA
  simp only [lineJoining]
  ext r; simp only [applyToSet, line, asFunc, Set.mem_setOf_eq]
  have hdiff := lemAffineDiff (T ∘ L) L q p hL ⟨T, hT, rfl⟩
  -- hdiff : (T ∘ L) q ⊖ (T ∘ L) p = L (q ⊖ p)
  constructor
  · rintro ⟨s, ⟨α, rfl⟩, rfl⟩
    refine ⟨α, ?_⟩
    rw [lemAffineOfPointOnLine (T ∘ L) L p (q ⊖ p) α hL ⟨T, hT, rfl⟩, hdiff]
  · rintro ⟨α, rfl⟩
    refine ⟨p ⊕ (α ⊗ (q ⊖ p)), ⟨α, rfl⟩, ?_⟩
    rw [lemAffineOfPointOnLine (T ∘ L) L p (q ⊖ p) α hL ⟨T, hT, rfl⟩, hdiff]

theorem lemAffineIsCts (A : Point Q → Point Q) (hA : affine A) (x : Point Q) :
    cts (asFunc A) x := by
  obtain ⟨L, T, hL, hT, rfl⟩ := hA
  -- asFunc (T ∘ L) = composeRel (asFunc T) (asFunc L)
  have hcomp : asFunc (T ∘ L) = composeRel (asFunc T) (asFunc L) := by
    funext p r; simp [asFunc, composeRel, Function.comp]
  rw [hcomp]
  exact lemCtsOfCtsIsCts (asFunc L) (asFunc T) x
    (lemLinearIsCts L hL x) (fun y _ => lemTranslationIsCts T hT y)

theorem lemAffineContinuity (A : Point Q → Point Q) (hA : affine A) :
    ∀ x, ∀ ε > 0, ∃ δ > 0, ∀ p, inBall p δ x → inBall (A p) ε (A x) := by
  intro x ε hε
  have hcts := lemAffineIsCts A hA x
  -- cts gives: ∀ y, asFunc A x y → ∀ ε > 0, ∃ δ > 0, applyToSet (asFunc A) (ball x δ) ⊆ ball y ε
  obtain ⟨δ, hδ, hsub⟩ := hcts (A x) rfl ε hε
  refine ⟨δ, hδ, fun p hp => ?_⟩
  -- hp : inBall p δ x, i.e. sep2 p x < sqr δ
  -- ball x δ = { q | inBall x δ q } = { q | sep2 x q < sqr δ }
  -- Need: p ∈ ball x δ, i.e. sep2 x p < sqr δ
  have hp_ball : p ∈ ball x δ := by
    simp only [ball, Set.mem_setOf_eq, inBall]; rw [lemSep2Symmetry]; exact hp
  have hAp_in : A p ∈ ball (A x) ε := hsub ⟨p, hp_ball, rfl⟩
  -- hAp_in : inBall (A x) ε (A p), i.e. sep2 (A x) (A p) < sqr ε
  -- Need: inBall (A p) ε (A x), i.e. sep2 (A p) (A x) < sqr ε
  simp only [ball, Set.mem_setOf_eq, inBall] at hAp_in ⊢
  rw [lemSep2Symmetry]; exact hAp_in

theorem lemAffOfAffIsAff (A B : Point Q → Point Q)
    (hA : affine A) (hB : affine B) :
    affine (B ∘ A) := by
  obtain ⟨LA, TA, hLA, hTA, rfl⟩ := hA
  obtain ⟨LB, TB, hLB, hTB, rfl⟩ := hB
  -- B ∘ A = (TB ∘ LB) ∘ (TA ∘ LA) = TB ∘ (LB ∘ TA ∘ LA)
  -- We need to show TB ∘ LB ∘ TA ∘ LA is affine
  -- LB ∘ TA is affine (linear composed with translation)
  -- Actually, we need L' linear and T' translation with B ∘ A = T' ∘ L'
  -- (TB ∘ LB) ∘ (TA ∘ LA) = TB ∘ (LB ∘ TA) ∘ LA
  -- LB ∘ TA: linear composed with translation
  -- Let TA translate by t. Then LB(TA(x)) = LB(x ⊕ t) = LB(x) ⊕ LB(t) (by linearity)
  -- So LB ∘ TA = (mkTranslation (LB t)) ∘ LB for the t in TA
  obtain ⟨t, ht⟩ := hTA
  -- B ∘ A = TB ∘ LB ∘ TA ∘ LA
  -- = TB ∘ (mkTranslation (LB t)) ∘ LB ∘ LA
  -- Linear part: LB ∘ LA, Translation part: TB ∘ mkTranslation (LB t)
  set L' := LB ∘ LA
  set T' := TB ∘ mkTranslation (LB t)
  refine ⟨L', T', lemLinOfLinIsLin LA LB hLA hLB, ?_, ?_⟩
  · -- T' is a translation
    obtain ⟨s, hs⟩ := hTB
    refine ⟨LB t ⊕ s, fun p => ?_⟩
    simp only [T', Function.comp, mkTranslation, hs, moveBy]
    ext <;> simp <;> ring
  · -- B ∘ A = T' ∘ L'
    funext x
    simp only [Function.comp, T', L', mkTranslation]
    rw [ht (LA x), hLB.2.2.1 (LA x) t]

theorem lemInverseAffine (A : Point Q → Point Q) (h : affInvertible A) :
    ∃ A', affine A' ∧ ∀ p q, A p = q ↔ A' q = p := by
  obtain ⟨⟨L, T, hL, hT, hA⟩, hinv⟩ := h
  -- Get inverse of L
  -- First show L is invertible
  have hLinv : invertible L := by
    intro q
    -- A = T ∘ L, A is invertible
    -- For any q, we need ∃! p, L p = q
    -- T(L p) = T q for the unique p with A p = T q
    obtain ⟨t, ht⟩ := hT
    -- A p = T(L p), and A is invertible
    -- For q: let r = T q = q ⊕ t. Get p with A p = r, unique.
    obtain ⟨p, hp, huniq⟩ := hinv (T q)
    -- hp : A p = T q, i.e., (T ∘ L) p = T q, i.e., T(L p) = T q
    have hp' : T (L p) = T q := by
      have : A p = (T ∘ L) p := by rw [hA]
      simp only [Function.comp] at this; rw [← this]; exact hp
    -- T is injective, so L p = q
    have hLpq : L p = q := by
      simp only [ht, moveBy, Point.mk.injEq] at hp'
      exact Point.ext (by linarith [hp'.1]) (by linarith [hp'.2.1])
        (by linarith [hp'.2.2.1]) (by linarith [hp'.2.2.2])
    refine ⟨p, hLpq, fun x hx => ?_⟩
    apply huniq; show A x = T q
    have : A x = (T ∘ L) x := by rw [hA]
    simp only [Function.comp] at this; rw [this, hx]
  obtain ⟨L', hL', hLbij⟩ := lemInverseLinear L hL hLinv
  obtain ⟨T', hT', hTbij⟩ := lemInverseTrans T hT
  -- A' = L' ∘ T' — but we need it in the form T_new ∘ L_new
  -- L'(T'(x)) = L'(x ⊕ (-t)) = L'(x) ⊕ L'(-t) since L' is linear
  -- So A' = mkTranslation(L' (-t)) ∘ L' which is T_new ∘ L_new
  obtain ⟨t, ht⟩ := hT
  set A' := L' ∘ T' with hA'_def
  -- Show A' is affine
  have hA'affine : affine A' := by
    have hT'trans : translation T' := hT'
    obtain ⟨s, hs⟩ := hT'trans
    refine ⟨L', mkTranslation (L' s), hL', lemMkTrans (L' s), ?_⟩
    funext x; simp only [Function.comp, hA'_def, mkTranslation]
    rw [hs x, hL'.2.2.1 x s]
  refine ⟨A', hA'affine, ?_⟩
  intro p q
  constructor
  · intro hpq
    -- A p = q means (T ∘ L) p = q
    have hTLp : T (L p) = q := by
      have : A p = (T ∘ L) p := by rw [hA]
      simp only [Function.comp] at this; rw [← this]; exact hpq
    -- T' q = L p
    have hT'q : T' q = L p := (hTbij (L p) q).mp hTLp
    -- L'(L p) = p
    have hL'Lp : L' (L p) = p := (hLbij p (L p)).mp rfl
    show A' q = p; simp only [hA'_def, Function.comp]; rw [hT'q, hL'Lp]
  · intro hqp
    -- A' q = p means L'(T' q) = p
    simp only [hA'_def, Function.comp] at hqp
    -- L(p) = T' q
    have hLp : L p = T' q := (hLbij p (T' q)).mpr hqp
    -- T(T' q) = q
    have hTT'q : T (T' q) = q := (hTbij (T' q) q).mpr rfl
    show A p = q
    have : A p = (T ∘ L) p := by rw [hA]
    simp only [Function.comp] at this; rw [this, hLp, hTT'q]

theorem lemAffineApproxDomainTranslation
    (T A : Point Q → Point Q) (T' : Point Q → Point Q)
    (f : Point Q → Point Q → Prop) (x : Point Q)
    (hT : translation T) (happrox : affineApprox A f x)
    (hTT' : ∀ p q, T p = q ↔ T' q = p) :
    affineApprox (A ∘ T) (composeRel f (asFunc T)) (T' x) := by
  obtain ⟨hfun, ⟨haffA, hinvA⟩, hdef, hdiff⟩ := happrox
  have hToT' : ∀ p, T (T' p) = p := fun p => (hTT' (T' p) p).mpr rfl
  have hT'oT : ∀ p, T' (T p) = p := fun p => (hTT' p (T p)).mp rfl
  -- T' is a translation
  have hT_saved := hT
  obtain ⟨t, ht⟩ := hT
  have transT' : translation T' := by
    refine ⟨origin ⊖ t, fun p => ?_⟩
    -- T(T' p) = p and T q = q ⊕ t, so T' p ⊕ t = p, hence T' p = p ⊖ t
    have h := hToT' p; rw [ht] at h
    -- h : T' p ⊕ t = p, i.e. moveBy (T' p) t = p
    -- Need: T' p = p ⊕ (origin ⊖ t) = moveBy p (origin ⊖ t)
    ext <;> simp only [moveBy, movebackBy, origin] at h ⊢ <;>
      linarith [(Point.mk.inj h).1, (Point.mk.inj h).2.1,
                (Point.mk.inj h).2.2.1, (Point.mk.inj h).2.2.2]
  set A0 := A ∘ T
  set g := composeRel f (asFunc T)
  -- 1. isFunction g
  have hfun_g : isFunction g := by
    intro y u v ⟨hgu, hgv⟩
    simp only [g, composeRel] at hgu hgv
    obtain ⟨q1, hTq1, hfq1⟩ := hgu
    obtain ⟨q2, hTq2, hfq2⟩ := hgv
    simp only [asFunc] at hTq1 hTq2
    -- q1 = T y = q2
    rw [hTq1] at hfq1; rw [hTq2] at hfq2
    exact hfun (T y) u v ⟨hfq1, hfq2⟩
  -- 2. affInvertible A0
  have haff_A0 : affine A0 :=
    lemAffOfAffIsAff T A (lemTranslationImpliesAffine T hT_saved) haffA
  have hinv_A0 : invertible A0 := by
    intro q
    obtain ⟨p, hp, huniq⟩ := hinvA q
    set p0 := T' p
    refine ⟨p0, ?_, ?_⟩
    · show (A ∘ T) p0 = q; simp only [Function.comp, p0]; rw [hToT']; exact hp
    · intro y hy
      have : A (T y) = q := hy
      have hTy_eq : T y = p := huniq (T y) this
      calc y = T' (T y) := (hT'oT y).symm
        _ = T' p := by rw [hTy_eq]
  -- 3. diffApprox (asFunc A0) g (T' x)
  have hdef_g : definedAt g (T' x) := by
    obtain ⟨u, hu⟩ := hdef
    -- f x u, and T (T' x) = x, so definedAt g (T' x) via T(T' x) = x
    exact ⟨u, T (T' x), rfl, by rw [hToT']; exact hu⟩
  have hdiff_g : ∀ ε : Q, ε > 0 → ∃ δ : Q, δ > 0 ∧ ∀ y,
      inBall y δ (T' x) → definedAt g y ∧ ∀ u v, g y u → asFunc A0 y v →
        sep2 v u ≤ sqr ε * sep2 y (T' x) := by
    intro ε hε
    obtain ⟨δ, hδ, hδ_spec⟩ := hdiff ε hε
    refine ⟨δ, hδ, fun y hy => ?_⟩
    -- y within δ of T' x ⟹ T y within δ of T(T' x) = x
    have hTy_ball : inBall (T y) δ x := by
      rw [← hToT' x]
      simp only [inBall]
      rw [← Translations.lemTranslationPreservesSep2 T hT_saved y (T' x)]
      exact hy
    obtain ⟨hdefy, happrox_y⟩ := hδ_spec (T y) hTy_ball
    constructor
    · -- definedAt g y
      obtain ⟨u, hu⟩ := hdefy; exact ⟨u, T y, rfl, hu⟩
    · intro u v hgu hA0v
      simp only [g, composeRel] at hgu
      obtain ⟨q, hTq, hfq⟩ := hgu
      simp only [asFunc] at hTq
      rw [hTq] at hfq  -- hfq : f (T y) u
      simp only [A0, Function.comp, asFunc] at hA0v
      -- hA0v : v = A(T y)
      rw [hA0v]
      -- sep2 (A(Ty)) u ≤ sqr ε * sep2 y (T' x)
      -- = sqr ε * sep2 (T y) x  (T preserves sep2, T' x ↔ T(T' x) = x)
      have hsep := Translations.lemTranslationPreservesSep2 T hT_saved y (T' x)
      -- sep2 y (T' x) = sep2 (T y) (T(T' x)) = sep2 (T y) x
      rw [hToT'] at hsep
      rw [hsep]
      exact happrox_y u (A (T y)) hfq rfl
  exact ⟨hfun_g, ⟨haff_A0, hinv_A0⟩, hdef_g, hdiff_g⟩

theorem lemAffineApproxRangeTranslation
    (T A : Point Q → Point Q) (f : Point Q → Point Q → Prop) (x : Point Q)
    (hT : translation T) (happrox : affineApprox A f x) :
    affineApprox (T ∘ A) (composeRel (asFunc T) f) x := by
  obtain ⟨hfun, ⟨haffA, hinvA⟩, hdef, hdiff⟩ := happrox
  obtain ⟨T', hT', hTbij⟩ := Translations.lemInverseTrans T hT
  have hToT' : ∀ p, T (T' p) = p := fun p => (hTbij (T' p) p).mpr rfl
  have hT'oT : ∀ p, T' (T p) = p := fun p => (hTbij p (T p)).mp rfl
  set A0 := T ∘ A
  set g := composeRel (asFunc T) f
  -- 1. isFunction g
  have hfun_g : isFunction g := by
    intro y u v ⟨hgu, hgv⟩
    simp only [g, composeRel] at hgu hgv
    obtain ⟨q1, hfq1, hTq1⟩ := hgu
    obtain ⟨q2, hfq2, hTq2⟩ := hgv
    simp only [asFunc] at hTq1 hTq2
    rw [hTq1, hTq2, hfun y q1 q2 ⟨hfq1, hfq2⟩]
  -- 2. affInvertible A0
  have haff_A0 : affine A0 := lemAffOfAffIsAff A T haffA (lemTranslationImpliesAffine T hT)
  have hinv_A0 : invertible A0 := by
    intro q
    obtain ⟨p, hp, huniq⟩ := hinvA (T' q)
    refine ⟨p, ?_, ?_⟩
    · -- A0 p = q, i.e., T(A p) = q. A p = T' q, so T(T' q) = q ✓
      show (T ∘ A) p = q; simp only [Function.comp]; rw [hp]; exact hToT' q
    · intro y hy
      apply huniq; show A y = T' q
      have : (T ∘ A) y = q := hy
      simp only [Function.comp] at this
      calc A y = T' (T (A y)) := (hT'oT (A y)).symm
        _ = T' q := by rw [this]
  -- 3. diffApprox (asFunc A0) g x
  have hdef_g : definedAt g x := by
    obtain ⟨u, hu⟩ := hdef
    exact ⟨T u, u, hu, rfl⟩
  have hdiff_g : ∀ ε : Q, ε > 0 → ∃ δ : Q, δ > 0 ∧ ∀ y,
      inBall y δ x → definedAt g y ∧ ∀ u v, g y u → asFunc A0 y v →
        sep2 v u ≤ sqr ε * sep2 y x := by
    intro ε hε
    obtain ⟨δ, hδ, hδ_spec⟩ := hdiff ε hε
    refine ⟨δ, hδ, fun y hy => ?_⟩
    obtain ⟨hdefy, happrox_y⟩ := hδ_spec y hy
    constructor
    · -- definedAt g y
      obtain ⟨u, hu⟩ := hdefy; exact ⟨T u, u, hu, rfl⟩
    · intro u v hgu hA0v
      -- hgu : g y u, i.e., ∃ q, f y q ∧ u = T q
      -- hA0v : asFunc A0 y v, i.e., v = A0 y = T(A y)
      simp only [g, composeRel] at hgu
      obtain ⟨q, hfq, hTqu⟩ := hgu
      simp only [asFunc] at hTqu hA0v
      -- sep2 v u = sep2 (T(Ay)) (Tq)
      -- T preserves sep2, so sep2 (T(Ay)) (Tq) = sep2 (Ay) q
      -- v = A0 y = T(A y), u = T q
      -- sep2 v u = sep2 (T(Ay)) (Tq) = sep2 (Ay) q  (T preserves sep2)
      simp only [A0, Function.comp] at hA0v
      rw [hA0v, hTqu, ← Translations.lemTranslationPreservesSep2 T hT (A y) q]
      exact happrox_y q (A y) hfq rfl
  exact ⟨hfun_g, ⟨haff_A0, hinv_A0⟩, hdef_g, hdiff_g⟩

theorem lemAffineIdentity (A : Point Q → Point Q) (x : Point Q) (e : Q)
    (hA : affine A) (he : e > 0)
    (hfix : ∀ y, inBall y e x → A y = y) :
    A = id := by
  obtain ⟨L, T, hL, hT, rfl⟩ := hA
  obtain ⟨t, ht⟩ := hT
  -- x is fixed: T(L(x)) = x
  have hxx : inBall x e x := by
    simp only [inBall, sep2, norm2, movebackBy, sqr]; nlinarith
  have xfixed : T (L x) = x := hfix x hxx
  funext p; simp only [Function.comp, id]
  set d := p ⊖ x
  obtain ⟨a, ha_pos, ha_norm⟩ := lemSmallPoints d e he
  have ha_nz : a ≠ 0 := ne_of_gt ha_pos
  set p' := (a ⊗ d) ⊕ x
  -- p' is in ball
  have hp'_ball : inBall p' e x := by
    simp only [inBall, sep2, p', d, moveBy, movebackBy, scaleBy, norm2, sqr] at ha_norm ⊢
    linarith
  have p'fixed : T (L p') = p' := hfix p' hp'_ball
  -- Key algebraic chain via coordinates
  -- T q = q ⊕ t, so xfixed: (L x) ⊕ t = x, p'fixed: (L p') ⊕ t = p'
  rw [ht] at xfixed p'fixed
  -- L p = L(((1/a)⊗(p'⊖x)) ⊕ x) = (1/a)⊗L(p'⊖x) ⊕ L x
  --     = (1/a)⊗(L p' ⊖ L x) ⊕ L x
  -- T(L p) = ((1/a)⊗(L p' ⊖ L x) ⊕ L x) ⊕ t
  -- From fixed points: L x = x ⊖ t, L p' = p' ⊖ t (coord-wise from moveBy eqs)
  -- So T(L p) works out to p by coordinate computation
  -- From xfixed: T(L(x)) = x, i.e. L(x) ⊕ t = x
  -- From p'fixed: T(L(p')) = p', i.e. L(p') ⊕ t = p'
  -- So L(p') ⊖ L(x) = (p' ⊖ t) ⊖ (x ⊖ t) = p' ⊖ x  (coordinate-wise)
  -- xfixed : L x ⊕ t = x, so L x = x ⊖ t
  have hLx : L x = x ⊖ t := by
    have h := xfixed -- L x ⊕ t = x
    ext <;> simp only [moveBy, movebackBy] at h ⊢ <;>
      linarith [(Point.mk.inj h).1, (Point.mk.inj h).2.1,
                (Point.mk.inj h).2.2.1, (Point.mk.inj h).2.2.2]
  -- p'fixed : L p' ⊕ t = p', so L p' = p' ⊖ t
  have hLp' : L p' = p' ⊖ t := by
    have h : moveBy (L p') t = p' := p'fixed
    ext
    · have := congr_arg Point.tval h; simp [moveBy, movebackBy] at this ⊢; linarith
    · have := congr_arg Point.xval h; simp [moveBy, movebackBy] at this ⊢; linarith
    · have := congr_arg Point.yval h; simp [moveBy, movebackBy] at this ⊢; linarith
    · have := congr_arg Point.zval h; simp [moveBy, movebackBy] at this ⊢; linarith
  -- L(p'⊖x) = L(p') ⊖ L(x) = (p'⊖t) ⊖ (x⊖t) = p' ⊖ x
  have hLdiff_val : L p' ⊖ L x = p' ⊖ x := by
    rw [hLp', hLx]; ext <;> simp [movebackBy] <;> ring
  -- (1/a)⊗(p'⊖x) = p⊖x (since p' = (a⊗d)⊕x and d = p⊖x)
  have hp'x : p' ⊖ x = a ⊗ (p ⊖ x) := by
    ext <;> simp [p', d, moveBy, movebackBy, scaleBy] <;> ring
  have hscale : (1/a) ⊗ (p' ⊖ x) = p ⊖ x := by
    rw [hp'x, lemScaleAssoc]
    have : 1 / a * a = 1 := one_div_mul_cancel ha_nz
    rw [this]; ext <;> simp [scaleBy]
  -- p = ((1/a)⊗(p'⊖x)) ⊕ x
  have hp : p = ((1/a) ⊗ (p' ⊖ x)) ⊕ x := by
    rw [hscale]; ext <;> simp [moveBy, movebackBy] <;> ring
  -- L p = L(((1/a)⊗(p'⊖x)) ⊕ x) = (1/a)⊗L(p'⊖x) ⊕ L(x)
  --     = (1/a)⊗(L(p')⊖L(x)) ⊕ L(x) = (1/a)⊗(p'⊖x) ⊕ L(x) = (p⊖x) ⊕ L(x)
  conv_lhs => rw [ht]
  conv_lhs => rw [show L p = (1/a) ⊗ (L p' ⊖ L x) ⊕ L x from by
    conv_lhs => rw [hp]; rw [hL.2.2.1, hL.2.1, hL.2.2.2]]
  rw [hLdiff_val, hscale, hLx]
  ext <;> simp [moveBy, movebackBy] <;> ring

end NoFTL.Affine
