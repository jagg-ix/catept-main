import CATEPTMain.AFPBridge.NoFTL.Functions
import CATEPTMain.AFPBridge.NoFTL.CauchySchwarz
import CATEPTMain.AFPBridge.NoFTL.Matrices

/-!
# LinearMaps — Linear Maps and Their Properties

Defines linear maps and establishes that every linear map is a matrix
application (and vice versa). Also proves that linear maps are bounded
and continuous.

Isabelle: `class LinearMaps = Functions + CauchySchwarz + Matrices`.
-/

set_option autoImplicit false

namespace NoFTL.LinearMaps

open NoFTL.Points NoFTL.Sorts NoFTL.Norms NoFTL.Vectors
open NoFTL.Functions NoFTL.CauchySchwarz NoFTL.Matrices

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

-- ── Definitions ─────────────────────────────────────────────────────────────

/-- A function `L : Point Q → Point Q` is linear if it preserves the origin,
    scaling, addition, and subtraction. -/
def linear (L : Point Q → Point Q) : Prop :=
  L origin = origin ∧
  (∀ (a : Q) (p : Point Q), L (a ⊗ p) = a ⊗ (L p)) ∧
  (∀ (p q : Point Q), L (moveBy p q) = moveBy (L p) (L q)) ∧
  (∀ (p q : Point Q), L (movebackBy p q) = movebackBy (L p) (L q))

-- ── Lemmas ──────────────────────────────────────────────────────────────────

theorem lemLinearProps (L : Point Q → Point Q) (hL : linear L)
    (a : Q) (p q : Point Q) :
    L origin = origin ∧ L (a ⊗ p) = a ⊗ (L p) ∧
    L (moveBy p q) = moveBy (L p) (L q) ∧
    L (movebackBy p q) = movebackBy (L p) (L q) :=
  ⟨hL.1, hL.2.1 a p, hL.2.2.1 p q, hL.2.2.2 p q⟩

theorem lemMatrixApplicationIsLinear (m : Matrix Q) :
    linear (applyMatrix m) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- L origin = origin
    simp [applyMatrix, dot, origin]
  · -- scaling
    intro a p
    simp only [applyMatrix]
    have ht := lemDotScaleRight a m.trow p
    have hx := lemDotScaleRight a m.xrow p
    have hy := lemDotScaleRight a m.yrow p
    have hz := lemDotScaleRight a m.zrow p
    simp only [scaleBy, Point.mk.injEq]
    exact ⟨ht, hx, hy, hz⟩
  · -- addition
    intro p q
    simp only [applyMatrix, moveBy, Point.mk.injEq]
    exact ⟨lemDotSumRight m.trow p q, lemDotSumRight m.xrow p q,
           lemDotSumRight m.yrow p q, lemDotSumRight m.zrow p q⟩
  · -- subtraction
    intro p q
    simp only [applyMatrix, movebackBy, Point.mk.injEq]
    exact ⟨lemDotDiffRight m.trow p q, lemDotDiffRight m.xrow p q,
           lemDotDiffRight m.yrow p q, lemDotDiffRight m.zrow p q⟩

private theorem lemPointDecomp (p : Point Q) :
    p = moveBy (p.tval ⊗ tUnit) (moveBy (p.xval ⊗ xUnit)
        (moveBy (p.yval ⊗ yUnit) (p.zval ⊗ zUnit))) := by
  ext <;> simp [moveBy, scaleBy, tUnit, xUnit, yUnit, zUnit] <;> ring

theorem lemLinearIsMatrixApplication (L : Point Q → Point Q) (hL : linear L) :
    ∃ m : Matrix Q, L = applyMatrix m := by
  set M := transpose ⟨L tUnit, L xUnit, L yUnit, L zUnit⟩
  refine ⟨M, funext fun p => ?_⟩
  -- Decompose p into basis vectors
  have hdecomp := lemPointDecomp p
  -- Apply L to decomposition using linearity
  conv_lhs => rw [hdecomp]
  rw [hL.2.2.1, hL.2.2.1, hL.2.2.1, hL.2.1, hL.2.1, hL.2.1, hL.2.1]
  -- Now LHS = moveBy (p.tval ⊗ L tUnit) (moveBy (p.xval ⊗ L xUnit) ...)
  -- RHS = applyMatrix M p = ⟨dot M.trow p, ...⟩
  ext <;> simp only [applyMatrix, transpose, tcol, xcol, ycol, zcol,
    dot, moveBy, scaleBy, Point.mk.injEq, M] <;> ring

theorem lemLinearIffMatrix (L : Point Q → Point Q) :
    linear L ↔ (∃ M : Matrix Q, L = applyMatrix M) := by
  constructor
  · exact lemLinearIsMatrixApplication L
  · intro ⟨M, hM⟩; rw [hM]; exact lemMatrixApplicationIsLinear M

theorem lemIdIsLinear : linear (id : Point Q → Point Q) := by
  refine ⟨rfl, ?_, ?_, ?_⟩
  · intro a p; rfl
  · intro p q; rfl
  · intro p q; rfl

theorem lemLinearIsBounded (L : Point Q → Point Q) (hL : linear L) :
    bounded L := by
  obtain ⟨M, hM⟩ := lemLinearIsMatrixApplication L hL
  set bnd := norm2 M.trow + norm2 M.xrow + norm2 M.yrow + norm2 M.zrow + 1
  refine ⟨bnd, by linarith [lemNorm2NonNeg M.trow, lemNorm2NonNeg M.xrow,
    lemNorm2NonNeg M.yrow, lemNorm2NonNeg M.zrow], fun p => ?_⟩
  rw [hM]; simp only [applyMatrix, norm2, sqr]
  have h1 := lemCauchySchwarzSqr4 M.trow p
  have h2 := lemCauchySchwarzSqr4 M.xrow p
  have h3 := lemCauchySchwarzSqr4 M.yrow p
  have h4 := lemCauchySchwarzSqr4 M.zrow p
  have hn := lemNorm2NonNeg p
  calc dot M.trow p * (dot M.trow p) + dot M.xrow p * (dot M.xrow p) +
        dot M.yrow p * (dot M.yrow p) + dot M.zrow p * (dot M.zrow p)
      ≤ norm2 M.trow * norm2 p + norm2 M.xrow * norm2 p +
        norm2 M.yrow * norm2 p + norm2 M.zrow * norm2 p := by
        unfold sqr at h1 h2 h3 h4; linarith
    _ ≤ bnd * norm2 p := by nlinarith

theorem lemLinearIsCts (L : Point Q → Point Q) (hL : linear L) (x : Point Q) :
    cts (asFunc L) x := by
  intro y hy ε hε
  simp only [asFunc] at hy; subst hy
  obtain ⟨bnd, hbnd_pos, hbnd⟩ := lemLinearIsBounded L hL
  obtain ⟨bb, hbb_pos, hbb_sq⟩ := lemSquareExistsAbove bnd
  set δ := ε / bb with hδ_def
  have hδ_pos : δ > 0 := div_pos hε hbb_pos
  refine ⟨δ, hδ_pos, ?_⟩
  intro p' hp'
  simp only [applyToSet, ball, Set.mem_setOf_eq, asFunc] at hp'
  obtain ⟨p, hp_ball, rfl⟩ := hp'
  simp only [ball, Set.mem_setOf_eq]
  -- hp_ball : inBall p δ x, i.e., sep2 p x < sqr δ
  -- Need: inBall (L p) ε (L x), i.e., sep2 (L p) (L x) < sqr ε
  -- L(p⊖x) = L(p) ⊖ L(x) by linearity
  have hLdiff : L (p ⊖ x) = L p ⊖ L x := hL.2.2.2 p x
  -- norm2(L(p⊖x)) ≤ bnd * norm2(p⊖x) = bnd * sep2 p x
  have hbnd_px : norm2 (L (p ⊖ x)) ≤ bnd * sep2 p x := by
    have := hbnd (p ⊖ x); unfold sep2; exact this
  -- sep2 (L p) (L x) = norm2(L(p) ⊖ L(x)) = norm2(L(p⊖x))
  have hsep_eq : sep2 (L p) (L x) = norm2 (L (p ⊖ x)) := by
    unfold sep2; congr 1; exact hLdiff.symm
  -- sep2 p x < sqr δ
  have hsep_px : sep2 p x < sqr δ := by
    rw [lemSep2Symmetry]; exact hp_ball
  -- bnd * sep2 p x < bnd * sqr δ ≤ sqr bb * sqr δ = sqr ε
  have hbb_ne : bb ≠ 0 := ne_of_gt hbb_pos
  have hε_sqr : sqr bb * sqr δ = sqr ε := by
    simp only [sqr, hδ_def]; field_simp
  show sep2 (L x) (L p) < sqr ε
  rw [lemSep2Symmetry, hsep_eq]
  calc norm2 (L (p ⊖ x)) ≤ bnd * sep2 p x := hbnd_px
    _ < bnd * sqr δ := by nlinarith
    _ ≤ sqr bb * sqr δ := by nlinarith [sqr_nonneg' δ]
    _ = sqr ε := hε_sqr

theorem lemLinOfLinIsLin (A B : Point Q → Point Q)
    (hA : linear A) (hB : linear B) :
    linear (B ∘ A) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · simp [Function.comp, hA.1, hB.1]
  · intro a p; simp [Function.comp, hA.2.1 a p, hB.2.1 a (A p)]
  · intro p q; simp [Function.comp, hA.2.2.1 p q, hB.2.2.1 (A p) (A q)]
  · intro p q; simp [Function.comp, hA.2.2.2 p q, hB.2.2.2 (A p) (A q)]

theorem lemInverseLinear (A : Point Q → Point Q)
    (hA : linear A) (hinv : invertible A) :
    ∃ A', linear A' ∧ ∀ p q, A p = q ↔ A' q = p := by
  -- Construct L as the inverse function
  set L := fun q => (hinv q).choose with hL_def
  have hLA : ∀ q, A (L q) = q := fun q => (hinv q).choose_spec.1
  have hAL : ∀ p, L (A p) = p := fun p =>
    ((hinv (A p)).choose_spec.2 p rfl).symm
  have hbij : ∀ p q, A p = q ↔ L q = p := by
    intro p q; constructor
    · rintro rfl; exact hAL p
    · rintro rfl; exact hLA q
  have hLO : L origin = origin := by
    have h : A (origin (Q := Q)) = origin := hA.1
    calc L origin = L (A origin) := by rw [h]
      _ = origin := hAL origin
  have hLsc : ∀ a p', L (a ⊗ p') = a ⊗ L p' := by
    intro a p'
    have : A (a ⊗ L p') = a ⊗ A (L p') := hA.2.1 a (L p')
    rw [hLA] at this; rw [← this, hAL]
  have hLadd : ∀ p' q', L (moveBy p' q') = moveBy (L p') (L q') := by
    intro p' q'
    have : A (moveBy (L p') (L q')) = moveBy (A (L p')) (A (L q')) :=
      hA.2.2.1 (L p') (L q')
    rw [hLA, hLA] at this; rw [← this, hAL]
  have hLsub : ∀ p' q', L (movebackBy p' q') = movebackBy (L p') (L q') := by
    intro p' q'
    have : A (movebackBy (L p') (L q')) = movebackBy (A (L p')) (A (L q')) :=
      hA.2.2.2 (L p') (L q')
    rw [hLA, hLA] at this; rw [← this, hAL]
  exact ⟨L, ⟨hLO, hLsc, hLadd, hLsub⟩, hbij⟩

end NoFTL.LinearMaps
