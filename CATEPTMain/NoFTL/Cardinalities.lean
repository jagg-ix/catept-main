import CATEPTMain.NoFTL.Functions

/-!
# Cardinalities — Set Cardinality Lemmas

For the NoFTL development, the only relevant cardinalities are 0, 1, 2
and more-than-2 (a proxy for "infinite"). These are used when classifying
how lines intersect cones.

Isabelle: `class Cardinalities = Functions`.
-/

set_option autoImplicit false

namespace NoFTL.Cardinalities

open NoFTL.Points NoFTL.Sorts NoFTL.Functions

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

-- ── Lemmas ──────────────────────────────────────────────────────────────────

theorem lemInjectiveValueUnique
    (f : Point Q → Point Q → Prop) (x y : Point Q)
    (hinj : injective f) (hfun : isFunction f) (hfy : f x y) :
    { q | f x q } = { y } := by
  ext q
  simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
  constructor
  · intro hfq; exact hfun x q y ⟨hfq, hfy⟩
  · intro heq; rw [heq]; exact hfy

theorem lemBijectionOnTwo
    (f : Point Q → Point Q → Prop) (s : Set (Point Q))
    (hbij : bijective f) (hfun : isFunction f)
    (hsub : s ⊆ domain f) (hcard : Set.ncard s = 2) :
    Set.ncard (applyToSet f s) = 2 := by
  obtain ⟨x, y, hxy, heq⟩ := Set.ncard_eq_two.mp hcard
  -- x,y in domain, so get fx, fy
  have hx_dom : x ∈ domain f := hsub (heq ▸ Set.mem_insert x {y})
  have hy_dom : y ∈ domain f := hsub (heq ▸ Set.mem_insert_iff.mpr (Or.inr (Set.mem_singleton y)))
  obtain ⟨fx, hfx⟩ := hx_dom
  obtain ⟨fy, hfy⟩ := hy_dom
  -- applyToSet f s = {fx, fy}
  have himg : applyToSet f s = {fx, fy} := by
    ext q; simp only [applyToSet, Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
    constructor
    · rintro ⟨p, hp, hfpq⟩
      rw [heq] at hp
      simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hp
      rcases hp with hp | hp
      · left; exact hfun p q fx ⟨hfpq, hp ▸ hfx⟩
      · right; exact hfun p q fy ⟨hfpq, hp ▸ hfy⟩
    · rintro (rfl | rfl)
      · exact ⟨x, by rw [heq]; exact Set.mem_insert x {y}, hfx⟩
      · exact ⟨y, by rw [heq]; exact Set.mem_insert_iff.mpr (Or.inr rfl), hfy⟩
  -- fx ≠ fy (from injectivity)
  have hfxy : fx ≠ fy := by
    exact hbij.1 x y fx fy ⟨⟨hfx, hfy⟩, hxy⟩
  rw [himg]; exact Set.ncard_eq_two.mpr ⟨fx, fy, hfxy, rfl⟩

theorem lemElementsOfSet2 (S : Set (Point Q)) (hcard : Set.ncard S = 2) :
    ∃ p q, p ≠ q ∧ p ∈ S ∧ q ∈ S := by
  obtain ⟨x, y, hne, heq⟩ := Set.ncard_eq_two.mp hcard
  rw [heq]; exact ⟨x, y, hne, Set.mem_insert x {y}, Set.mem_insert_iff.mpr (Or.inr rfl)⟩

theorem lemThirdElementOfSet2 (p q r : Point Q) (S : Set (Point Q))
    (hpq : p ≠ q ∧ p ∈ S ∧ q ∈ S ∧ Set.ncard S = 2)
    (hr : r ∈ S) :
    p = r ∨ q = r := by
  obtain ⟨hne, hp, hq, hcard⟩ := hpq
  obtain ⟨x, y, hxy, heq⟩ := Set.ncard_eq_two.mp hcard
  rw [heq] at hp hq hr
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hp hq hr
  -- r = x ∨ r = y, p = x ∨ p = y, q = x ∨ q = y
  -- Since p ≠ q, one is x and the other is y
  rcases hp with hp | hp <;> rcases hq with hq | hq <;> rcases hr with hr | hr <;>
    simp_all

theorem lemSmallCardUnderInvertible
    (f : Point Q → Point Q) (S : Set (Point Q))
    (hinv : invertible f) (hcard : 0 < Set.ncard S ∧ Set.ncard S ≤ 2) :
    Set.ncard S = Set.ncard (applyToSet (asFunc f) S) := by
  -- invertible means f is injective
  have hinj : Function.Injective f := by
    intro a b hab
    obtain ⟨p₀, _, huniq⟩ := hinv (f a)
    exact ((huniq b hab.symm).trans (huniq a rfl).symm).symm
  -- applyToSet (asFunc f) S = f '' S
  have himg : applyToSet (asFunc f) S = f '' S := by
    ext q; simp only [applyToSet, asFunc, Set.mem_setOf_eq, Set.image]
    constructor
    · rintro ⟨p, hp, rfl⟩; exact ⟨p, hp, rfl⟩
    · rintro ⟨p, hp, rfl⟩; exact ⟨p, hp, rfl⟩
  rw [himg]
  -- S is finite (ncard > 0 and ≤ 2)
  have hfin : S.Finite := by
    by_contra hinf
    rw [Set.Infinite.ncard hinf] at hcard
    omega
  exact (Set.ncard_image_of_injective S hinj).symm

theorem lemCardOfLineIsBig (x p : Point Q) (l : Set (Point Q))
    (hne : x ≠ p) (hon : onLine x l ∧ onLine p l) :
    ∃ p1 p2 p3, (onLine p1 l ∧ onLine p2 l ∧ onLine p3 l) ∧
      (p1 ≠ p2 ∧ p2 ≠ p3 ∧ p3 ≠ p1) := by
  -- l is a line, get base and direction
  obtain ⟨b, d, hbd⟩ := hon.1.1
  -- p is on l = line b d, so l = line p d
  have hp_mem : p ∈ line b d := hbd ▸ hon.2.2
  have hl_eq : l = line p d := by rw [hbd]; exact (lemSameLine p b d hp_mem).2
  -- d ≠ origin (otherwise p = x)
  have hd : d ≠ origin := by
    intro h0; apply hne
    rw [hbd] at hon
    obtain ⟨_, ⟨α, rfl⟩⟩ := hon.1
    obtain ⟨_, ⟨β, rfl⟩⟩ := hon.2
    rw [h0]; ext <;> simp [moveBy, scaleBy, origin]
  -- construct p1 = p ⊕ 1⊗d, p2 = p ⊕ 2⊗d, p3 = p ⊕ 3⊗d
  set p1 := p ⊕ (1 ⊗ d) with p1_def
  set p2 := p ⊕ (2 ⊗ d) with p2_def
  set p3 := p ⊕ (3 ⊗ d) with p3_def
  have hline : isLine l := ⟨b, d, hbd⟩
  refine ⟨p1, p2, p3, ⟨?_, ?_, ?_⟩, ?_, ?_, ?_⟩
  · exact ⟨hline, hl_eq ▸ ⟨1, rfl⟩⟩
  · exact ⟨hline, hl_eq ▸ ⟨2, rfl⟩⟩
  · exact ⟨hline, hl_eq ▸ ⟨3, rfl⟩⟩
  · -- p1 ≠ p2
    intro h; simp only [p1_def, p2_def, moveBy, scaleBy, Point.mk.injEq] at h
    apply hd; ext <;> simp [origin] <;> linarith [h.1, h.2.1, h.2.2.1, h.2.2.2]
  · intro h; simp only [p2_def, p3_def, moveBy, scaleBy, Point.mk.injEq] at h
    apply hd; ext <;> simp [origin] <;> linarith [h.1, h.2.1, h.2.2.1, h.2.2.2]
  · intro h; simp only [p3_def, p1_def, moveBy, scaleBy, Point.mk.injEq] at h
    apply hd; ext <;> simp [origin] <;> linarith [h.1, h.2.1, h.2.2.1, h.2.2.2]

end NoFTL.Cardinalities
