import CATEPTMain.NoFTL.Points
import CATEPTMain.NoFTL.AxEField

/-!
# Norms — Euclidean Norms on Spacetime Points

Defines norms (as square roots of squared norms) assuming roots exist
(AxEField). Proves basic norm lemmas: non-negativity, zero norm ↔ origin,
symmetry, scaling, and distance addition under the triangle inequality.

Isabelle: `class Norms = Points + AxEField`.
-/

set_option autoImplicit false

namespace NoFTL.Norms

open NoFTL.Points NoFTL.Sorts

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

/-- The norm of a point: `norm p = sqrt (norm2 p)`. -/
noncomputable def norm (p : Point Q) : Q := sqrt (norm2 p)

/-- The spatial norm: `sNorm s = sqrt (sNorm2 s)`. -/
noncomputable def sNorm (s : Space Q) : Q := sqrt (sNorm2 s)

/-- The triangle inequality predicate for specific points. -/
def axTriangleInequality (p q : Point Q) : Prop :=
  norm (moveBy p q) ≤ norm p + norm q

-- ── Lemmas ───────────────────────────────────────────────────────────────────

private theorem norm2_nonneg (p : Point Q) : norm2 p ≥ 0 := by
  unfold norm2 sqr
  have := mul_self_nonneg p.tval
  have := mul_self_nonneg p.xval
  have := mul_self_nonneg p.yval
  have := mul_self_nonneg p.zval
  linarith

private theorem norm2_hasRoot (p : Point Q) : hasRoot (norm2 p) :=
  NoFTL.AxEField.axEField (norm2 p) (norm2_nonneg p)

private theorem sqrt_spec (x : Q) (hx : x ≥ 0) : isNonNegRoot x (sqrt x) := by
  have hr := NoFTL.AxEField.axEField x hx
  have huniq := lemSqrt x hr
  obtain ⟨r, hr', _⟩ := huniq
  exact Classical.epsilon_spec ⟨r, hr'⟩

theorem lemNormSqrIsNorm2 (p : Point Q) : norm2 p = sqr (norm p) := by
  exact (sqrt_spec (norm2 p) (norm2_nonneg p)).2

theorem lemNormNonNegative (p : Point Q) : norm p ≥ 0 := by
  exact (sqrt_spec (norm2 p) (norm2_nonneg p)).1

theorem lemZeroNorm (p : Point Q) : p = origin ↔ norm p = 0 := by
  constructor
  · intro h; subst h; unfold norm norm2 origin; simp [sqr_zero, lemSqrt0]
  · intro h
    have : norm2 p = sqr (norm p) := lemNormSqrIsNorm2 p
    rw [h] at this; simp [sqr_zero] at this
    unfold norm2 sqr at this
    have ht := mul_self_nonneg p.tval
    have hx := mul_self_nonneg p.xval
    have hy := mul_self_nonneg p.yval
    have hz := mul_self_nonneg p.zval
    have h1 : p.tval * p.tval = 0 := by linarith
    have h2 : p.xval * p.xval = 0 := by linarith
    have h3 : p.yval * p.yval = 0 := by linarith
    have h4 : p.zval * p.zval = 0 := by linarith
    have := mul_self_eq_zero.mp h1
    have := mul_self_eq_zero.mp h2
    have := mul_self_eq_zero.mp h3
    have := mul_self_eq_zero.mp h4
    ext <;> simp_all [origin]

theorem lemNotOriginImpliesPositiveNorm (p : Point Q) (h : p ≠ origin) :
    norm p > 0 := by
  have h1 : norm p ≠ 0 := fun h0 => h ((lemZeroNorm p).mpr h0)
  have h2 : norm p ≥ 0 := lemNormNonNegative p
  exact lt_of_le_of_ne h2 (Ne.symm h1)

theorem lemNormSymmetry (p q : Point Q) : norm (p ⊖ q) = norm (q ⊖ p) := by
  unfold norm
  congr 1
  exact lemSep2Symmetry p q

theorem lemNormOfScaled (α : Q) (p : Point Q) :
    norm (α ⊗ p) = |α| * norm p := by
  have hnn_lhs : norm (α ⊗ p) ≥ 0 := lemNormNonNegative (α ⊗ p)
  have hnn_rhs : |α| * norm p ≥ 0 := mul_nonneg (abs_nonneg α) (lemNormNonNegative p)
  have hsqr : sqr (norm (α ⊗ p)) = sqr (|α| * norm p) := by
    calc sqr (norm (α ⊗ p)) = norm2 (α ⊗ p) := (lemNormSqrIsNorm2 (α ⊗ p)).symm
      _ = sqr α * norm2 p := by simp only [norm2, scaleBy, sqr]; ring
      _ = sqr α * sqr (norm p) := by rw [lemNormSqrIsNorm2 p]
      _ = sqr (|α| * norm p) := by
          unfold sqr
          rw [show α * α = |α| * |α| from (abs_mul_abs_self α).symm]
          ring
  have := lemEqualSquares _ _ hsqr
  rwa [abs_of_nonneg hnn_lhs, abs_of_nonneg hnn_rhs] at this

private theorem point_diffDiffAdd (p q r : Point Q) :
    moveBy (q ⊖ p) (r ⊖ q) = r ⊖ p := by
  ext <;> simp [moveBy, movebackBy] <;> ring

theorem lemDistancesAdd (p q r : Point Q) (x y : Q)
    (triangle : axTriangleInequality (q ⊖ p) (r ⊖ q))
    (hx : x > 0) (hy : y > 0)
    (hsep_pq : sep2 p q < sqr x) (hsep_rq : sep2 r q < sqr y) :
    inBall r (x + y) p := by
  -- Step 1: norm(q⊖p) < x
  have hnsq_pq : sqr (norm (q ⊖ p)) < sqr x := by
    rw [← lemNormSqrIsNorm2]
    have : sep2 p q = sep2 q p := lemSep2Symmetry p q
    unfold sep2 at this hsep_pq; linarith
  have hnpq : norm (q ⊖ p) < x :=
    lemSqrOrderedStrict (norm (q ⊖ p)) x ⟨hx, hnsq_pq⟩
  -- Step 2: norm(r⊖q) < y
  have hnsq_rq : sqr (norm (r ⊖ q)) < sqr y := by
    rw [← lemNormSqrIsNorm2]; unfold sep2 at hsep_rq; exact hsep_rq
  have hnrq : norm (r ⊖ q) < y :=
    lemSqrOrderedStrict (norm (r ⊖ q)) y ⟨hy, hnsq_rq⟩
  -- Step 3: triangle inequality gives norm(r⊖p) ≤ norm(q⊖p) + norm(r⊖q)
  have hrp : norm (r ⊖ p) ≤ norm (q ⊖ p) + norm (r ⊖ q) := by
    have : norm (moveBy (q ⊖ p) (r ⊖ q)) ≤ norm (q ⊖ p) + norm (r ⊖ q) := triangle
    rwa [point_diffDiffAdd (Q := Q)] at this
  -- Step 4: norm(r⊖p) < x + y
  have hnrp : norm (r ⊖ p) < x + y := by linarith
  -- Step 5: sep2 r p < sqr(x+y)
  have hnn_rp : norm (r ⊖ p) ≥ 0 := lemNormNonNegative (r ⊖ p)
  have hsq : sqr (norm (r ⊖ p)) < sqr (x + y) :=
    lemSqrMonoStrict (norm (r ⊖ p)) (x + y) ⟨hnn_rp, hnrp⟩
  -- Step 6: conclude inBall
  show sep2 r p < sqr (x + y)
  calc sep2 r p = norm2 (r ⊖ p) := rfl
    _ = sqr (norm (r ⊖ p)) := lemNormSqrIsNorm2 (r ⊖ p)
    _ < sqr (x + y) := hsq

theorem lemDistancesAddStrictR (p q r : Point Q) (x y : Q)
    (triangle : axTriangleInequality (q ⊖ p) (r ⊖ q))
    (hx : x > 0) (hy : y > 0)
    (hsep_pq : sep2 p q ≤ sqr x) (hsep_rq : sep2 r q < sqr y) :
    inBall r (x + y) p := by
  -- Step 1: norm(q⊖p) ≤ x
  have hnsq_pq : sqr (norm (q ⊖ p)) ≤ sqr x := by
    rw [← lemNormSqrIsNorm2]
    have : sep2 p q = sep2 q p := lemSep2Symmetry p q
    unfold sep2 at this hsep_pq; linarith
  have hnpq : norm (q ⊖ p) ≤ x :=
    lemSqrOrdered (norm (q ⊖ p)) x ⟨le_of_lt hx, hnsq_pq⟩
  -- Step 2: norm(r⊖q) < y
  have hnsq_rq : sqr (norm (r ⊖ q)) < sqr y := by
    rw [← lemNormSqrIsNorm2]; unfold sep2 at hsep_rq; exact hsep_rq
  have hnrq : norm (r ⊖ q) < y :=
    lemSqrOrderedStrict (norm (r ⊖ q)) y ⟨hy, hnsq_rq⟩
  -- Step 3: triangle inequality gives norm(r⊖p) ≤ norm(q⊖p) + norm(r⊖q)
  have hrp : norm (r ⊖ p) ≤ norm (q ⊖ p) + norm (r ⊖ q) := by
    have : norm (moveBy (q ⊖ p) (r ⊖ q)) ≤ norm (q ⊖ p) + norm (r ⊖ q) := triangle
    rwa [point_diffDiffAdd (Q := Q)] at this
  -- Step 4: norm(r⊖p) < x + y
  have hnrp : norm (r ⊖ p) < x + y := by linarith
  -- Step 5: sep2 r p < sqr(x+y)
  have hnn_rp : norm (r ⊖ p) ≥ 0 := lemNormNonNegative (r ⊖ p)
  have hsq : sqr (norm (r ⊖ p)) < sqr (x + y) :=
    lemSqrMonoStrict (norm (r ⊖ p)) (x + y) ⟨hnn_rp, hnrp⟩
  -- Step 6: conclude inBall
  show sep2 r p < sqr (x + y)
  calc sep2 r p = norm2 (r ⊖ p) := rfl
    _ = sqr (norm (r ⊖ p)) := lemNormSqrIsNorm2 (r ⊖ p)
    _ < sqr (x + y) := hsq

end NoFTL.Norms
