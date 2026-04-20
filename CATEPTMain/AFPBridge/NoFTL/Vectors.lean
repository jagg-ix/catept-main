import CATEPTMain.AFPBridge.NoFTL.Norms

/-!
# Vectors — Dot Products and Causal Classification

Defines dot products (`dot`, `sdot`, `mdot`) and classifies spacetime
vectors as timelike, lightlike, spacelike, or causal. Proves algebraic
identities for dot products.

Isabelle: `class Vectors = Norms`.
-/

set_option autoImplicit false

namespace NoFTL.Vectors

open NoFTL.Points NoFTL.Sorts NoFTL.Norms

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

-- ── Dot products ─────────────────────────────────────────────────────────────

/-- Euclidean dot product on 4-vectors. -/
def dot (u v : Point Q) : Q :=
  u.tval * v.tval + u.xval * v.xval + u.yval * v.yval + u.zval * v.zval

/-- Spatial dot product on 3-vectors. -/
def sdot (u v : Space Q) : Q :=
  u.svalx * v.svalx + u.svaly * v.svaly + u.svalz * v.svalz

/-- Minkowski dot product. -/
def mdot (u v : Point Q) : Q :=
  u.tval * v.tval - sdot (sComponent u) (sComponent v)

infixl:70 " ⊙ " => dot
infixl:70 " ⊙ₛ " => sdot
infixl:70 " ⊙ₘ " => mdot

-- ── Causal classification ────────────────────────────────────────────────────

def timelike (p : Point Q) : Prop := mNorm2 p > 0
def lightlike (p : Point Q) : Prop := p ≠ origin ∧ mNorm2 p = 0
def spacelike (p : Point Q) : Prop := mNorm2 p < 0
def causal (p : Point Q) : Prop := timelike p ∨ lightlike p

-- ── Orthogonality ────────────────────────────────────────────────────────────

def orthog (p q : Point Q) : Prop := dot p q = 0
def orthogs (p q : Space Q) : Prop := sdot p q = 0
def orthogm (p q : Point Q) : Prop := mdot p q = 0

-- ── Lemmas ───────────────────────────────────────────────────────────────────

theorem lemDotDecomposition (u v : Point Q) :
    dot u v = u.tval * v.tval + sdot (sComponent u) (sComponent v) := by
  simp [dot, sdot, sComponent]; ring

theorem lemDotCommute (u v : Point Q) : dot u v = dot v u := by
  simp [dot]; ring

theorem lemDotScaleLeft (a : Q) (u v : Point Q) : dot (a ⊗ u) v = a * dot u v := by
  simp [dot, scaleBy]; ring

theorem lemDotScaleRight (a : Q) (u v : Point Q) : dot u (a ⊗ v) = a * dot u v := by
  simp [dot, scaleBy]; ring

theorem lemDotSumLeft (u v w : Point Q) : dot (u ⊕ v) w = dot u w + dot v w := by
  simp [dot, moveBy]; ring

theorem lemDotSumRight (u v w : Point Q) : dot u (v ⊕ w) = dot u v + dot u w := by
  simp [dot, moveBy]; ring

theorem lemDotDiffLeft (u v w : Point Q) : dot (u ⊖ v) w = dot u w - dot v w := by
  simp [dot, movebackBy]; ring

theorem lemDotDiffRight (u v w : Point Q) : dot u (v ⊖ w) = dot u v - dot u w := by
  simp [dot, movebackBy]; ring

theorem lemNorm2OfSum (u v : Point Q) :
    norm2 (u ⊕ v) = norm2 u + 2 * dot u v + norm2 v := by
  simp [norm2, dot, moveBy, sqr]; ring

-- ── Spatial dot lemmas ───────────────────────────────────────────────────────

theorem lemSDotCommute (u v : Space Q) : sdot u v = sdot v u := by
  simp [sdot]; ring

theorem lemSDotScaleLeft (a : Q) (u v : Space Q) : sdot (a ⊗ₛ u) v = a * sdot u v := by
  simp [sdot, sScaleBy]; ring

theorem lemSDotScaleRight (a : Q) (u v : Space Q) : sdot u (a ⊗ₛ v) = a * sdot u v := by
  simp [sdot, sScaleBy]; ring

theorem lemSDotSumLeft (u v w : Space Q) : sdot (u ⊕ₛ v) w = sdot u w + sdot v w := by
  simp [sdot, sMoveBy]; ring

theorem lemSDotSumRight (u v w : Space Q) : sdot u (v ⊕ₛ w) = sdot u v + sdot u w := by
  simp [sdot, sMoveBy]; ring

theorem lemSDotDiffLeft (u v w : Space Q) : sdot (u ⊖ₛ v) w = sdot u w - sdot v w := by
  simp [sdot, sMovebackBy]; ring

theorem lemSDotDiffRight (u v w : Space Q) : sdot u (v ⊖ₛ w) = sdot u v - sdot u w := by
  simp [sdot, sMovebackBy]; ring

-- ── Minkowski dot lemmas ─────────────────────────────────────────────────────

theorem lemMDotDiffLeft (u v w : Point Q) : mdot (u ⊖ v) w = mdot u w - mdot v w := by
  simp [mdot, sdot, sComponent, movebackBy]; ring

theorem lemMDotSumLeft (u v w : Point Q) : mdot (u ⊕ v) w = mdot u w + mdot v w := by
  simp [mdot, sdot, sComponent, moveBy]; ring

theorem lemMDotScaleLeft (a : Q) (u v : Point Q) : mdot (a ⊗ u) v = a * mdot u v := by
  simp [mdot, sdot, sComponent, scaleBy]; ring

theorem lemMDotScaleRight (a : Q) (u v : Point Q) : mdot u (a ⊗ v) = a * mdot u v := by
  simp [mdot, sdot, sComponent, scaleBy]; ring

theorem lemSNorm2OfSum' (u v : Space Q) :
    sNorm2 (u ⊕ₛ v) = sNorm2 u + 2 * sdot u v + sNorm2 v := by
  simp [sNorm2, sdot, sMoveBy, sqr]; ring

theorem lemSNormNonNeg (v : Space Q) : sNorm v ≥ 0 := by
  unfold sNorm
  have hnn : sNorm2 v ≥ 0 := by
    unfold sNorm2; linarith [sqr_nonneg' v.svalx, sqr_nonneg' v.svaly, sqr_nonneg' v.svalz]
  have hr := NoFTL.AxEField.axEField (sNorm2 v) hnn
  have huniq := lemSqrt (sNorm2 v) hr
  obtain ⟨r, hr', _⟩ := huniq
  exact (Classical.epsilon_spec ⟨r, hr'⟩).1

theorem lemMNorm2OfSum (u v : Point Q) :
    mNorm2 (u ⊕ v) = mNorm2 u + 2 * mdot u v + mNorm2 v := by
  simp [mNorm2, mdot, sdot, sComponent, moveBy, sqr, sNorm2, sMoveBy]; ring

theorem lemMNorm2OfDiff (u v : Point Q) :
    mNorm2 (u ⊖ v) = mNorm2 u - 2 * mdot u v + mNorm2 v := by
  simp [mNorm2, mdot, sdot, sComponent, movebackBy, sqr, sNorm2, sMovebackBy]; ring

theorem lemMNorm2Decomposition (p : Point Q) : mNorm2 p = mdot p p := by
  simp [mNorm2, mdot, sNorm2, sdot, sComponent, sqr]

theorem lemMDecomposition (u v : Point Q) (a : Q) (up uo : Point Q)
    (hmdot : mdot u v ≠ 0) (hmn : mNorm2 v ≠ 0)
    (ha : a = mdot u v / mNorm2 v)
    (hup : up = a ⊗ v) (huo : uo = u ⊖ up) :
    u = moveBy up uo ∧ parallel up v ∧ orthogm uo v ∧ mdot up v = mdot u v := by
  have anz : a ≠ 0 := by
    rw [ha]; exact div_ne_zero hmdot hmn
  -- 1) u = up ⊕ uo
  have psum : u = moveBy up uo := by
    rw [huo]; ext <;> simp [moveBy, movebackBy] <;> ring
  -- 2) parallel up v
  have hpar : parallel up v := ⟨a, anz, hup⟩
  -- 3) mdot up v = mdot u v
  have hmdot_eq : mdot up v = mdot u v := by
    rw [hup, lemMDotScaleLeft]
    rw [ha]; field_simp
    rw [lemMNorm2Decomposition]
  -- 4) orthogm uo v
  have horth : orthogm uo v := by
    unfold orthogm
    have : mdot (moveBy up uo) v = mdot up v + mdot uo v := lemMDotSumLeft up uo v
    rw [← psum] at this
    linarith [hmdot_eq]
  exact ⟨psum, hpar, horth, hmdot_eq⟩

end NoFTL.Vectors
