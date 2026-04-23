import CATEPTMain.NoFTL.Points

/-!
# Functions — Relational Function Theory

Characterises various types of function (injective, bijective, etc.) in
relational form suitable for worldview transformations. Many "functions"
in the NoFTL development are actually relations `Point Q → Point Q → Prop`
because we cannot assume a priori that worldview transformations are
single-valued or total.

Isabelle: `class Functions = Points`.
-/

set_option autoImplicit false

namespace NoFTL.Functions

open NoFTL.Points

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

-- ── Relational definitions ───────────────────────────────────────────────────

/-- A function (as a `Point → Point` map) is bounded if there exists `bnd > 0`
    such that `norm2 (f p) ≤ bnd * norm2 p` for all `p`. -/
def bounded (f : Point Q → Point Q) : Prop :=
  ∃ bnd : Q, bnd > 0 ∧ ∀ p, norm2 (f p) ≤ bnd * norm2 p

/-- Relational composition: `(composeRel g f) p r ↔ ∃ q, f p q ∧ g q r`. -/
def composeRel (g f : Point Q → Point Q → Prop) : Point Q → Point Q → Prop :=
  fun p r => ∃ q, f p q ∧ g q r

/-- A relation is injective if distinct inputs map to distinct outputs. -/
def injective (f : Point Q → Point Q → Prop) : Prop :=
  ∀ x₁ x₂ y₁ y₂, (f x₁ y₁ ∧ f x₂ y₂) ∧ x₁ ≠ x₂ → y₁ ≠ y₂

/-- A relation is defined at `x` if there exists some `y` with `f x y`. -/
def definedAt (f : Point Q → Point Q → Prop) (x : Point Q) : Prop :=
  ∃ y, f x y

/-- The domain of a relation. -/
def domain (f : Point Q → Point Q → Prop) : Set (Point Q) :=
  { x | definedAt f x }

/-- A relation is total if it is defined at every point. -/
def total (f : Point Q → Point Q → Prop) : Prop :=
  ∀ x, definedAt f x

/-- A relation is surjective if every point is in the range. -/
def surjective (f : Point Q → Point Q → Prop) : Prop :=
  ∀ y, ∃ x, f x y

/-- A relation is bijective if it is injective and surjective. -/
def bijective (f : Point Q → Point Q → Prop) : Prop :=
  injective f ∧ surjective f

/-- A standard function is invertible if for every `q` there exists a unique
    preimage. -/
def invertible (f : Point Q → Point Q) : Prop :=
  ∀ q, ∃ p, f p = q ∧ ∀ x, f x = q → x = p

/-- Image of a set under a relation. -/
def applyToSet (f : Point Q → Point Q → Prop) (s : Set (Point Q)) : Set (Point Q) :=
  { q | ∃ p ∈ s, f p q }

/-- A relation is single-valued at `x`. -/
def singleValued (f : Point Q → Point Q → Prop) (x : Point Q) : Prop :=
  ∀ y z, f x y ∧ f x z → y = z

/-- A relation is a (partial) function if it is single-valued everywhere. -/
def isFunction (f : Point Q → Point Q → Prop) : Prop :=
  ∀ x, singleValued f x

/-- A relation is a total function. -/
def isTotalFunction (f : Point Q → Point Q → Prop) : Prop :=
  total f ∧ isFunction f

instance : Nonempty (Point Q) := ⟨origin⟩

/-- Convert a relation to a function using `Classical.choice`. -/
noncomputable def toFunc (f : Point Q → Point Q → Prop) : Point Q → Point Q :=
  fun x => Classical.epsilon (fun y => f x y)

/-- Convert a standard function to a relation. -/
def asFunc (f : Point Q → Point Q) : Point Q → Point Q → Prop :=
  fun x y => y = f x

-- ── Differentiable approximation ─────────────────────────────────────────────

/-- `diffApprox g f x` means `g` differentiably approximates `f` at `x`:
    `f` is defined at `x`, and for every `ε > 0` there exists `δ > 0` such that
    for all `y` within `δ` of `x`, `f` is defined at `y` and the separation
    `sep2 v u ≤ sqr ε * sep2 y x` for any `f y u` and `g y v`. -/
def diffApprox (g f : Point Q → Point Q → Prop) (x : Point Q) : Prop :=
  definedAt f x ∧
    ∀ ε : Q, ε > 0 → ∃ δ : Q, δ > 0 ∧ ∀ y,
      inBall y δ x →
        definedAt f y ∧ ∀ u v, f y u → g y v →
          sep2 v u ≤ Sorts.sqr ε * sep2 y x

/-- Continuity of a relation at a point. -/
def cts (f : Point Q → Point Q → Prop) (x : Point Q) : Prop :=
  ∀ y, f x y → ∀ ε : Q, ε > 0 → ∃ δ : Q, δ > 0 ∧
    applyToSet f (ball x δ) ⊆ ball y ε

/-- Inverse of a relation (swap arguments). -/
def invFunc (f : Point Q → Point Q → Prop) : Point Q → Point Q → Prop :=
  fun p q => f q p

-- ── Lemmas ───────────────────────────────────────────────────────────────────

theorem lemBijInv (f : Point Q → Point Q) :
    bijective (asFunc f) ↔ invertible f := by
  constructor
  · rintro ⟨hinj, hsurj⟩
    intro q
    obtain ⟨p, hp⟩ := hsurj q
    simp only [asFunc] at hp
    exact ⟨p, hp.symm, fun x hx => by
      by_contra hne
      have := hinj p x (f p) (f x) ⟨⟨rfl, rfl⟩, (Ne.symm hne)⟩
      exact this (hp.symm.trans hx.symm)⟩
  · intro hinv
    constructor
    · intro x₁ x₂ y₁ y₂ ⟨⟨hy₁, hy₂⟩, hne⟩
      simp only [asFunc] at hy₁ hy₂
      subst hy₁; subst hy₂
      intro h
      obtain ⟨_, _, huniq⟩ := hinv (f x₁)
      exact hne ((huniq x₁ rfl).trans (huniq x₂ h.symm).symm)
    · intro y
      obtain ⟨p, hp, _⟩ := hinv y
      exact ⟨p, hp.symm⟩

theorem lemApproxEqualAtBase
    (g f : Point Q → Point Q → Prop) (x : Point Q)
    (happrox : diffApprox g f x)
    (y z : Point Q) (hfy : f x y) (hgz : g x z) : y = z := by
  obtain ⟨_, heps⟩ := happrox
  obtain ⟨δ, hδ, hball⟩ := heps 1 one_pos
  -- x is within δ of x (sep2 x x = 0 < sqr δ)
  have hx_in : inBall x δ x := by
    unfold inBall sep2 norm2 Sorts.sqr movebackBy; simp; positivity
  obtain ⟨_, hvu⟩ := hball x hx_in
  have hsep : sep2 z y ≤ Sorts.sqr 1 * sep2 x x := hvu y z hfy hgz
  have hsepxx : sep2 x x = 0 := by unfold sep2 norm2 Sorts.sqr movebackBy; ring
  rw [hsepxx, mul_zero] at hsep
  by_contra hne
  have : sep2 z y > 0 := by
    rw [lemSep2Symmetry]; exact lemNotEqualImpliesSep2Pos z y hne
  linarith

theorem lemCtsOfCtsIsCts
    (f g : Point Q → Point Q → Prop) (x : Point Q)
    (hf : cts f x) (hg : ∀ y, f x y → cts g y) :
    cts (composeRel g f) x := by
  intro z ⟨y, hfy, hgyz⟩ ε hε
  -- Get δ_y from continuity of g at y
  obtain ⟨δy, hδy_pos, hδy_sub⟩ := (hg y hfy) z hgyz ε hε
  -- Get δ from continuity of f at x with ε = δ_y
  obtain ⟨δ, hδ_pos, hδ_sub⟩ := hf y hfy δy hδy_pos
  refine ⟨δ, hδ_pos, ?_⟩
  intro w hw
  simp only [applyToSet, composeRel, ball, Set.mem_setOf_eq] at hw
  obtain ⟨p, hp_ball, q, hfpq, hgqw⟩ := hw
  -- p ∈ ball x δ, so f(p) = q ∈ ball y δ_y
  have hq_in : q ∈ ball y δy := by
    apply hδ_sub
    exact ⟨p, hp_ball, hfpq⟩
  -- q ∈ ball y δ_y, so g(q) = w ∈ ball z ε
  exact hδy_sub ⟨q, hq_in, hgqw⟩

theorem lemInjOfInjIsInj
    (f g : Point Q → Point Q → Prop)
    (hf : injective f) (hg : injective g) :
    injective (composeRel g f) := by
  intro x₁ x₂ z₁ z₂ ⟨⟨⟨y₁, hfy₁, hgy₁⟩, ⟨y₂, hfy₂, hgy₂⟩⟩, hne⟩
  have hyne : y₁ ≠ y₂ := hf x₁ x₂ y₁ y₂ ⟨⟨hfy₁, hfy₂⟩, hne⟩
  exact hg y₁ y₂ z₁ z₂ ⟨⟨hgy₁, hgy₂⟩, hyne⟩

theorem lemInverseComposition
    (f g : Point Q → Point Q → Prop)
    (h : Point Q → Point Q → Prop)
    (hdef : h = composeRel g f) :
    invFunc h = composeRel (invFunc f) (invFunc g) := by
  funext p r
  simp [invFunc, composeRel, hdef]
  constructor
  · rintro ⟨q, hfq, hgq⟩
    exact ⟨q, hgq, hfq⟩
  · rintro ⟨q, hgq, hfq⟩
    exact ⟨q, hfq, hgq⟩

theorem lemToFuncAsFunc
    (f : Point Q → Point Q → Prop)
    (hfun : isFunction f) (htot : total f) :
    asFunc (toFunc f) = f := by
  funext p r
  simp [asFunc, toFunc]
  constructor
  · intro h
    rw [h]
    exact Classical.epsilon_spec (htot p)
  · intro hfpr
    have huniq := hfun p r (Classical.epsilon (fun y => f p y))
    exact huniq ⟨hfpr, Classical.epsilon_spec (htot p)⟩

theorem lemAsFuncToFunc (f : Point Q → Point Q) :
    toFunc (asFunc f) = f := by
  funext x
  simp [toFunc, asFunc]
  have : ∃ y, y = f x := ⟨f x, rfl⟩
  exact Classical.epsilon_spec this

end NoFTL.Functions
