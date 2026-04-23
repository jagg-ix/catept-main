import CATEPTMain.Geometry.NoFTL.Sorts

/-!
# Points — (1+3)-dimensional spacetime

Faithful port of `No_FTL_observers_Gen_Rel.Points` from the AFP.

A point has four coordinates: the first is time, the remaining three are
spatial. We define translations, scaling, origins, separation functions,
balls, accumulation points, lines, and directions.
-/

set_option autoImplicit false

namespace NoFTL.Points

open NoFTL.Sorts

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]

-- ══════════════════════════════════════════════════════════════════════════════
-- §1  Core data types
-- ══════════════════════════════════════════════════════════════════════════════

/-- A (1+3)-dimensional spacetime point. -/
@[ext]
structure Point (Q : Type*) where
  tval : Q
  xval : Q
  yval : Q
  zval : Q
  deriving DecidableEq, Repr

/-- A 3-dimensional spatial vector. -/
structure Space (Q : Type*) where
  svalx : Q
  svaly : Q
  svalz : Q
  deriving DecidableEq, Repr

-- ══════════════════════════════════════════════════════════════════════════════
-- §2  Constructors and projections
-- ══════════════════════════════════════════════════════════════════════════════

/-- Extract the time component of a point. -/
abbrev tComponent (p : Point Q) : Q := p.tval

/-- Extract the spatial component of a point. -/
abbrev sComponent (p : Point Q) : Space Q :=
  ⟨p.xval, p.yval, p.zval⟩

/-- Build a point from four coordinates. -/
abbrev mkPoint (t x y z : Q) : Point Q := ⟨t, x, y, z⟩

/-- Build a point from a time value and a spatial vector. -/
abbrev stPoint (t : Q) (s : Space Q) : Point Q :=
  ⟨t, s.svalx, s.svaly, s.svalz⟩

/-- Build a spatial vector from three coordinates. -/
abbrev mkSpace (x y z : Q) : Space Q := ⟨x, y, z⟩

-- ══════════════════════════════════════════════════════════════════════════════
-- §3  Translations
-- ══════════════════════════════════════════════════════════════════════════════

/-- Pointwise addition of two points (translation). Isabelle: `p ⊕ q`. -/
def moveBy (p q : Point Q) : Point Q :=
  ⟨p.tval + q.tval, p.xval + q.xval, p.yval + q.yval, p.zval + q.zval⟩

/-- Pointwise subtraction. Isabelle: `p ⊖ q`. -/
def movebackBy (p q : Point Q) : Point Q :=
  ⟨p.tval - q.tval, p.xval - q.xval, p.yval - q.yval, p.zval - q.zval⟩

infixl:65 " ⊕ " => moveBy
infixl:65 " ⊖ " => movebackBy

/-- Spatial addition. -/
def sMoveBy (p q : Space Q) : Space Q :=
  ⟨p.svalx + q.svalx, p.svaly + q.svaly, p.svalz + q.svalz⟩

/-- Spatial subtraction. -/
def sMovebackBy (p q : Space Q) : Space Q :=
  ⟨p.svalx - q.svalx, p.svaly - q.svaly, p.svalz - q.svalz⟩

infixl:65 " ⊕ₛ " => sMoveBy
infixl:65 " ⊖ₛ " => sMovebackBy

-- ══════════════════════════════════════════════════════════════════════════════
-- §4  Scaling
-- ══════════════════════════════════════════════════════════════════════════════

/-- Scale a point by a scalar. Isabelle: `α ⊗ p`. -/
def scaleBy (a : Q) (p : Point Q) : Point Q :=
  ⟨a * p.tval, a * p.xval, a * p.yval, a * p.zval⟩

/-- Scale a spatial vector by a scalar. -/
def sScaleBy (a : Q) (s : Space Q) : Space Q :=
  ⟨a * s.svalx, a * s.svaly, a * s.svalz⟩

infixl:70 " ⊗ " => scaleBy
infixl:70 " ⊗ₛ " => sScaleBy

-- ══════════════════════════════════════════════════════════════════════════════
-- §5  Origins and unit vectors
-- ══════════════════════════════════════════════════════════════════════════════

/-- The spatial origin. -/
def sOrigin : Space Q := ⟨0, 0, 0⟩

/-- The spacetime origin. -/
def origin : Point Q := ⟨0, 0, 0, 0⟩

/-- Unit vector along the time axis. -/
def tUnit : Point Q := ⟨1, 0, 0, 0⟩

/-- Unit vector along the x axis. -/
def xUnit : Point Q := ⟨0, 1, 0, 0⟩

/-- Unit vector along the y axis. -/
def yUnit : Point Q := ⟨0, 0, 1, 0⟩

/-- Unit vector along the z axis. -/
def zUnit : Point Q := ⟨0, 0, 0, 1⟩

-- ══════════════════════════════════════════════════════════════════════════════
-- §6  Time axis
-- ══════════════════════════════════════════════════════════════════════════════

/-- The time axis: points with all spatial coordinates zero. -/
def timeAxis : Set (Point Q) :=
  { p | p.xval = 0 ∧ p.yval = 0 ∧ p.zval = 0 }

/-- Whether a point lies on the time axis. -/
def onTimeAxis (p : Point Q) : Prop := p ∈ timeAxis

-- ══════════════════════════════════════════════════════════════════════════════
-- §7  Squared norms and separation functions
-- ══════════════════════════════════════════════════════════════════════════════

/-- Euclidean norm squared of a spacetime point (sum of squares of all 4 coords). -/
def norm2 (p : Point Q) : Q :=
  sqr p.tval + sqr p.xval + sqr p.yval + sqr p.zval

/-- Squared separation between two points. -/
def sep2 (p q : Point Q) : Q := norm2 (p ⊖ q)

/-- Spatial norm squared. -/
def sNorm2 (s : Space Q) : Q :=
  sqr s.svalx + sqr s.svaly + sqr s.svalz

/-- Spatial squared separation. -/
def sSep2 (p q : Point Q) : Q :=
  sqr (p.xval - q.xval) + sqr (p.yval - q.yval) + sqr (p.zval - q.zval)

/-- Minkowski norm squared: t² - |s|². -/
def mNorm2 (p : Point Q) : Q :=
  sqr p.tval - sNorm2 (sComponent p)

-- ══════════════════════════════════════════════════════════════════════════════
-- §8  Balls and accumulation points
-- ══════════════════════════════════════════════════════════════════════════════

/-- Whether `q` is within distance `ε` of `p` (using squared norm). -/
def inBall (q : Point Q) (ε : Q) (p : Point Q) : Prop :=
  sep2 q p < sqr ε

/-- The open ball of radius `ε` around `q`. -/
def ball (q : Point Q) (ε : Q) : Set (Point Q) :=
  { p | inBall q ε p }

/-- `p` is an accumulation point of `s`. -/
def accPoint (p : Point Q) (s : Set (Point Q)) : Prop :=
  ∀ ε > 0, ∃ q ∈ s, p ≠ q ∧ inBall q ε p

-- ══════════════════════════════════════════════════════════════════════════════
-- §9  Lines
-- ══════════════════════════════════════════════════════════════════════════════

/-- The line through `base` with direction `drtn`. -/
def line (base drtn : Point Q) : Set (Point Q) :=
  { p | ∃ α : Q, p = base ⊕ (α ⊗ drtn) }

/-- The line joining two points. -/
def lineJoining (p q : Point Q) : Set (Point Q) :=
  line p (q ⊖ p)

/-- Whether a set is a line. -/
def isLine (l : Set (Point Q)) : Prop :=
  ∃ b d : Point Q, l = line b d

/-- Whether two line sets are the same line. -/
def sameLine (l₁ l₂ : Set (Point Q)) : Prop :=
  (isLine l₁ ∨ isLine l₂) ∧ l₁ = l₂

/-- Whether a point lies on a line. -/
def onLine (p : Point Q) (l : Set (Point Q)) : Prop :=
  isLine l ∧ p ∈ l

-- ══════════════════════════════════════════════════════════════════════════════
-- §10  Directions
-- ══════════════════════════════════════════════════════════════════════════════

/-- The set of direction vectors of a line. -/
def drtn (l : Set (Point Q)) : Set (Point Q) :=
  { d | ∃ p q : Point Q, p ≠ q ∧ onLine p l ∧ onLine q l ∧ d = q ⊖ p }

/-- Two lines are parallel if they share a direction. -/
def parallelLines (l₁ l₂ : Set (Point Q)) : Prop :=
  (drtn l₁ ∩ drtn l₂).Nonempty

/-- Two points are parallel (one is a nonzero scalar multiple of the other). -/
def parallel (p q : Point Q) : Prop :=
  ∃ α : Q, α ≠ 0 ∧ p = α ⊗ q

-- ══════════════════════════════════════════════════════════════════════════════
-- §11  Slopes and velocities
-- ══════════════════════════════════════════════════════════════════════════════

/-- Whether two points have finite slope (distinct time coordinates). -/
def slopeFinite (p q : Point Q) : Prop := p.tval ≠ q.tval

/-- Whether two points have infinite slope (same time coordinate). -/
def slopeInfinite (p q : Point Q) : Prop := p.tval = q.tval

/-- Whether a line has finite slope (contains two distinct points with different
    time coordinates). -/
def lineSlopeFinite (l : Set (Point Q)) : Prop :=
  ∃ x y, onLine x l ∧ onLine y l ∧ x ≠ y ∧ slopeFinite x y

open Classical in
/-- The sloper: spatial direction per unit time. Returns origin if slope is infinite. -/
noncomputable def sloper (p q : Point Q) : Point Q :=
  if slopeFinite p q then (1 / (p.tval - q.tval)) ⊗ (p ⊖ q)
  else origin

/-- The velocity joining two points (spatial component of sloper). -/
noncomputable def velocityJoining (p q : Point Q) : Space Q :=
  sComponent (sloper p q)

-- ══════════════════════════════════════════════════════════════════════════════
-- §12  Lemmas — norm decomposition
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemNorm2Decomposition (u : Point Q) :
    norm2 u = sqr u.tval + sNorm2 (sComponent u) := by
  simp [norm2, sNorm2, sComponent]; ring

-- ══════════════════════════════════════════════════════════════════════════════
-- §13  Lemmas — scaling arithmetic
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemScaleLeftSumDistrib (a b : Q) (p : Point Q) :
    (a + b) ⊗ p = (a ⊗ p) ⊕ (b ⊗ p) := by
  simp only [scaleBy, moveBy, Point.mk.injEq]
  exact ⟨by ring, by ring, by ring, by ring⟩

theorem lemScaleLeftDiffDistrib (a b : Q) (p : Point Q) :
    (a - b) ⊗ p = (a ⊗ p) ⊖ (b ⊗ p) := by
  simp only [scaleBy, movebackBy, Point.mk.injEq]
  exact ⟨by ring, by ring, by ring, by ring⟩

theorem lemScaleAssoc (α β : Q) (p : Point Q) :
    α ⊗ (β ⊗ p) = (α * β) ⊗ p := by
  simp only [scaleBy, Point.mk.injEq]
  exact ⟨by ring, by ring, by ring, by ring⟩

theorem lemScaleCommute (α β : Q) (p : Point Q) :
    α ⊗ (β ⊗ p) = β ⊗ (α ⊗ p) := by
  simp only [scaleBy, Point.mk.injEq]
  exact ⟨by ring, by ring, by ring, by ring⟩

theorem lemScaleDistribSum (α : Q) (p q : Point Q) :
    α ⊗ (p ⊕ q) = (α ⊗ p) ⊕ (α ⊗ q) := by
  simp only [scaleBy, moveBy, Point.mk.injEq]
  exact ⟨by ring, by ring, by ring, by ring⟩

theorem lemScaleDistribDiff (α : Q) (p q : Point Q) :
    α ⊗ (p ⊖ q) = (α ⊗ p) ⊖ (α ⊗ q) := by
  simp only [scaleBy, movebackBy, Point.mk.injEq]
  exact ⟨by ring, by ring, by ring, by ring⟩

@[simp] theorem lemScaleOrigin (α : Q) : α ⊗ (origin : Point Q) = origin := by
  simp [scaleBy, origin]

-- ══════════════════════════════════════════════════════════════════════════════
-- §14  Lemmas — norm scaling
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemNorm2OfScaled (α : Q) (p : Point Q) :
    norm2 (α ⊗ p) = sqr α * norm2 p := by
  simp [norm2, scaleBy, sqr]; ring

theorem lemSNorm2OfScaled (α : Q) (s : Space Q) :
    sNorm2 (α ⊗ₛ s) = sqr α * sNorm2 s := by
  simp [sNorm2, sScaleBy, sqr]; ring

theorem lemMNorm2OfScaled (α : Q) (p : Point Q) :
    mNorm2 (α ⊗ p) = sqr α * mNorm2 p := by
  simp [mNorm2, sNorm2, sComponent, scaleBy, sqr]; ring

theorem lemScaleSep2 (a : Q) (p q : Point Q) :
    sqr a * sep2 p q = sep2 (a ⊗ p) (a ⊗ q) := by
  simp [sep2]; rw [← lemScaleDistribDiff, lemNorm2OfScaled]

theorem lemSScaleAssoc (α β : Q) (s : Space Q) :
    α ⊗ₛ (β ⊗ₛ s) = (α * β) ⊗ₛ s := by
  simp only [sScaleBy, Space.mk.injEq]
  exact ⟨by ring, by ring, by ring⟩

-- ══════════════════════════════════════════════════════════════════════════════
-- §15  Lemmas — separation symmetry
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemSSep2Symmetry (p q : Point Q) : sSep2 p q = sSep2 q p := by
  simp only [sSep2]
  congr 1; congr 1
  · exact lemSqrDiffSymmetrical _ _
  · exact lemSqrDiffSymmetrical _ _
  · exact lemSqrDiffSymmetrical _ _

theorem lemSep2Symmetry (p q : Point Q) : sep2 p q = sep2 q p := by
  simp only [sep2, norm2, movebackBy]
  congr 1; congr 1; congr 1
  · exact lemSqrDiffSymmetrical _ _
  · exact lemSqrDiffSymmetrical _ _
  · exact lemSqrDiffSymmetrical _ _
  · exact lemSqrDiffSymmetrical _ _

-- ══════════════════════════════════════════════════════════════════════════════
-- §16  Lemmas — norm positivity and origin characterization
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemSpatialNullImpliesSpatialOrigin (s : Space Q) (h : sNorm2 s = 0) :
    s = sOrigin := by
  have hx := sqr_nonneg' s.svalx
  have hy := sqr_nonneg' s.svaly
  have hz := sqr_nonneg' s.svalz
  simp [sNorm2] at h
  have hxz : sqr s.svalx = 0 := by linarith
  have hyz : sqr s.svaly = 0 := by linarith
  have hzz : sqr s.svalz = 0 := by linarith
  rw [lemZeroRoot] at hxz hyz hzz
  cases s; simp_all [sOrigin]

theorem lemNorm2NonNeg (p : Point Q) : norm2 p ≥ 0 := by
  simp [norm2]; linarith [sqr_nonneg' p.tval, sqr_nonneg' p.xval,
    sqr_nonneg' p.yval, sqr_nonneg' p.zval]

theorem lemNullImpliesOrigin (p : Point Q) (h : norm2 p = 0) : p = origin := by
  have ht := sqr_nonneg' p.tval
  have hx := sqr_nonneg' p.xval
  have hy := sqr_nonneg' p.yval
  have hz := sqr_nonneg' p.zval
  simp [norm2] at h
  have h1 : sqr p.tval = 0 := by linarith
  have h2 : sqr p.xval = 0 := by linarith
  have h3 : sqr p.yval = 0 := by linarith
  have h4 : sqr p.zval = 0 := by linarith
  rw [lemZeroRoot] at h1 h2 h3 h4
  cases p; simp_all [origin]

theorem lemNotOriginImpliesPosNorm2 (p : Point Q) (h : p ≠ origin) : norm2 p > 0 := by
  have hnn := lemNorm2NonNeg p
  have hnz : norm2 p ≠ 0 := fun h0 => h (lemNullImpliesOrigin p h0)
  exact lt_of_le_of_ne' hnn hnz

theorem lemNotEqualImpliesSep2Pos (x y : Point Q) (h : y ≠ x) : sep2 y x > 0 := by
  apply lemNotOriginImpliesPosNorm2
  intro heq
  apply h
  have : (y ⊖ x) = origin := heq
  simp [movebackBy, origin] at this
  obtain ⟨ht, hx, hy, hz⟩ := this
  cases x; cases y; simp_all [sub_eq_zero]

-- ══════════════════════════════════════════════════════════════════════════════
-- §17  Lemmas — balls
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemBallContainsCentre (x : Point Q) (ε : Q) (hε : ε > 0) :
    inBall x ε x := by
  unfold inBall sep2 norm2 movebackBy
  simp [sub_self, sqr]
  exact ne_of_gt hε

theorem lemPointLimit (u v : Point Q)
    (h : ∀ ε > 0, inBall v ε u) : v = u := by
  by_contra hne
  have hpos := lemNotEqualImpliesSep2Pos u v hne
  obtain ⟨s, hs_pos, hs_sq⟩ := lemSmallSquares (sep2 v u) hpos
  have := h s hs_pos
  simp [inBall] at this
  linarith

theorem lemBallInBall (p q : Point Q) (x y : Q) (hp : inBall p x q) (hxy : 0 < x ∧ x ≤ y) :
    inBall p y q := by
  simp [inBall] at *
  have := lemSqrMono x y ⟨le_of_lt hxy.1, hxy.2⟩
  linarith

-- ══════════════════════════════════════════════════════════════════════════════
-- §18  Lemmas — lines (key results, some deferred)
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemLineJoiningContainsEndPoints (x p : Point Q) :
    onLine x (lineJoining x p) ∧ onLine p (lineJoining x p) := by
  constructor
  · refine ⟨⟨x, p ⊖ x, rfl⟩, ⟨0, ?_⟩⟩
    ext <;> simp [moveBy, scaleBy]
  · refine ⟨⟨x, p ⊖ x, rfl⟩, ⟨1, ?_⟩⟩
    ext <;> simp [moveBy, scaleBy, movebackBy] <;> ring

theorem lemTimeAxisIsLine : isLine (timeAxis : Set (Point Q)) := by
  refine ⟨origin, tUnit, ?_⟩
  ext p; simp only [timeAxis, line, Set.mem_setOf_eq]
  constructor
  · rintro ⟨hx, hy, hz⟩
    exact ⟨p.tval, by ext <;> simp [moveBy, scaleBy, origin, tUnit, hx, hy, hz]⟩
  · rintro ⟨α, rfl⟩
    simp [moveBy, scaleBy, origin, tUnit]

theorem lemSameLine (p : Point Q) (b d : Point Q) (hp : p ∈ line b d) :
    sameLine (line b d) (line p d) := by
  simp only [line, Set.mem_setOf_eq] at hp
  obtain ⟨α, rfl⟩ := hp
  refine ⟨Or.inl ⟨b, d, rfl⟩, ?_⟩
  ext q; simp only [line, Set.mem_setOf_eq]
  constructor
  · rintro ⟨β, rfl⟩
    exact ⟨β - α, by ext <;> simp [moveBy, scaleBy] <;> ring⟩
  · rintro ⟨β, rfl⟩
    exact ⟨α + β, by ext <;> simp [moveBy, scaleBy] <;> ring⟩

private theorem lemLineScaleDir (b d : Point Q) (c : Q) (hc : c ≠ 0) :
    line b d = line b (c ⊗ d) := by
  ext x; simp only [line, Set.mem_setOf_eq]
  constructor
  · rintro ⟨γ, rfl⟩
    exact ⟨γ / c, by ext <;> simp [moveBy, scaleBy] <;> field_simp <;> ring⟩
  · rintro ⟨γ, rfl⟩
    exact ⟨γ * c, by ext <;> simp [moveBy, scaleBy] <;> ring⟩

theorem lemLineAndPoints (p q : Point Q) (l : Set (Point Q)) (hne : p ≠ q) :
    (onLine p l ∧ onLine q l) ↔ l = lineJoining p q := by
  constructor
  · rintro ⟨⟨⟨b, d, rfl⟩, hp⟩, ⟨_, hq⟩⟩
    simp only [line, Set.mem_setOf_eq] at hp hq
    obtain ⟨α, rfl⟩ := hp
    obtain ⟨β, rfl⟩ := hq
    -- p = b ⊕ (α ⊗ d), q = b ⊕ (β ⊗ d), p ≠ q so α ≠ β
    have hαβ : α ≠ β := by
      intro h; apply hne; rw [h]
    -- q ⊖ p = (β - α) ⊗ d
    have hdiff : (b ⊕ (β ⊗ d)) ⊖ (b ⊕ (α ⊗ d)) = (β - α) ⊗ d := by
      ext <;> simp [moveBy, movebackBy, scaleBy] <;> ring
    simp only [lineJoining]
    rw [hdiff]
    -- line b d = line (b ⊕ (α ⊗ d)) d  (by lemSameLine)
    have hsame := lemSameLine (b ⊕ (α ⊗ d)) b d ⟨α, rfl⟩
    rw [hsame.2]
    -- line (b ⊕ (α ⊗ d)) d = line (b ⊕ (α ⊗ d)) ((β - α) ⊗ d)
    exact lemLineScaleDir _ d (β - α) (sub_ne_zero.mpr (Ne.symm hαβ))
  · intro h
    rw [h]
    exact ⟨(lemLineJoiningContainsEndPoints p q).1, (lemLineJoiningContainsEndPoints p q).2⟩

theorem lemLineDefinedByPair (x p : Point Q) (l₁ l₂ : Set (Point Q))
    (hne : x ≠ p)
    (h1 : onLine p l₁ ∧ onLine x l₁)
    (h2 : onLine p l₂ ∧ onLine x l₂) : l₁ = l₂ := by
  have hpne : p ≠ x := fun h => hne (h ▸ rfl)
  have h1' := (lemLineAndPoints p x l₁ hpne).mp ⟨h1.1, h1.2⟩
  have h2' := (lemLineAndPoints p x l₂ hpne).mp ⟨h2.1, h2.2⟩
  rw [h1', h2']

theorem lemDrtn (l : Set (Point Q)) (d₁ d₂ : Point Q)
    (h : d₁ ∈ drtn l ∧ d₂ ∈ drtn l) :
    ∃ α : Q, α ≠ 0 ∧ d₂ = α ⊗ d₁ := by
  simp only [drtn, Set.mem_setOf_eq] at h
  obtain ⟨⟨p₁, q₁, hne₁, hon_p₁, hon_q₁, rfl⟩, ⟨p₂, q₂, hne₂, hon_p₂, hon_q₂, rfl⟩⟩ := h
  -- All four points are on l, which is a line b d
  obtain ⟨b, d, rfl⟩ := hon_p₁.1
  simp only [line, Set.mem_setOf_eq] at hon_p₁ hon_q₁ hon_p₂ hon_q₂
  obtain ⟨α₁, rfl⟩ := hon_p₁.2
  obtain ⟨β₁, rfl⟩ := hon_q₁.2
  obtain ⟨α₂, rfl⟩ := hon_p₂.2
  obtain ⟨β₂, rfl⟩ := hon_q₂.2
  -- d₁ = (β₁ - α₁) ⊗ d, d₂ = (β₂ - α₂) ⊗ d
  have hdiff₁ : (b ⊕ (β₁ ⊗ d)) ⊖ (b ⊕ (α₁ ⊗ d)) = (β₁ - α₁) ⊗ d := by
    ext <;> simp [moveBy, movebackBy, scaleBy] <;> ring
  have hdiff₂ : (b ⊕ (β₂ ⊗ d)) ⊖ (b ⊕ (α₂ ⊗ d)) = (β₂ - α₂) ⊗ d := by
    ext <;> simp [moveBy, movebackBy, scaleBy] <;> ring
  rw [hdiff₁, hdiff₂]
  have hne₁' : β₁ - α₁ ≠ 0 := by
    intro h; apply hne₁
    have : β₁ = α₁ := by linarith
    rw [this]
  have hne₂' : β₂ - α₂ ≠ 0 := by
    intro h; apply hne₂
    have : β₂ = α₂ := by linarith
    subst this; rfl
  refine ⟨(β₂ - α₂) / (β₁ - α₁), div_ne_zero hne₂' hne₁', ?_⟩
  ext <;> simp [scaleBy] <;> field_simp <;> ring

-- ══════════════════════════════════════════════════════════════════════════════
-- §19  Lemmas — small points
-- ══════════════════════════════════════════════════════════════════════════════

theorem lemSmallPoints (p : Point Q) (e : Q) (he : e > 0) :
    ∃ a : Q, a > 0 ∧ norm2 (a ⊗ p) < sqr e := by
  by_cases hp : p = origin
  · refine ⟨1, one_pos, ?_⟩
    rw [hp]; simp [scaleBy, origin, norm2, sqr]
    exact ne_of_gt he
  · obtain ⟨e1, he1_pos, he1_lt, he1_sqr, _⟩ := lemReducedBound e he
    have hn2_pos := lemNotOriginImpliesPosNorm2 p hp
    obtain ⟨s, hs_pos, hs_sq⟩ := lemSquareExistsAbove (norm2 p)
    have hs_sqr_pos : sqr s > 0 := lemSquaresPositive s (ne_of_gt hs_pos)
    have he1_sqr_pos : sqr e1 > 0 := lemSquaresPositive e1 (ne_of_gt he1_pos)
    refine ⟨e1 / s, by positivity, ?_⟩
    rw [lemNorm2OfScaled]
    have hsqr_div : sqr (e1 / s) = sqr e1 / sqr s := by
      simp [sqr]; rw [div_mul_div_comm]
    rw [hsqr_div, div_mul_eq_mul_div]
    calc sqr e1 * norm2 p / sqr s
        < sqr e1 * sqr s / sqr s := by
          apply div_lt_div_of_pos_right
          · exact mul_lt_mul_of_pos_left hs_sq he1_sqr_pos
          · exact hs_sqr_pos
      _ = sqr e1 := by rw [mul_div_cancel_of_imp]; intro h; linarith
      _ < sqr e := lemSqrMonoStrict e1 e ⟨le_of_lt he1_pos, he1_lt⟩

end NoFTL.Points
