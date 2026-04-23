import CATEPTMain.Geometry.NoFTL.Cones
import CATEPTMain.Geometry.NoFTL.Quadratics
import CATEPTMain.Geometry.NoFTL.CauchySchwarz
import CATEPTMain.Geometry.NoFTL.AxLightMinus

/-!
# Classification — Cone Membership Classification

Classifies points as inside, on, or outside a regular cone. The classification
scheme relies on purely affine concepts: for a given point, we consider lines
through it and count how many intersection points the line has with the cone.

This is the largest file in the NoFTL development (2064 lines in Isabelle, 32
lemmas). All proofs are deferred to phase 2.

Isabelle: `class Classification = Cones + Quadratics + CauchySchwarz`.
-/

set_option autoImplicit false

namespace NoFTL.Classification

open NoFTL.Points NoFTL.Sorts NoFTL.Norms NoFTL.Vectors
open NoFTL.Functions NoFTL.Quadratics NoFTL.CauchySchwarz
open NoFTL.TangentLines NoFTL.Cones NoFTL.WorldView

variable {B Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q] [WorldViewRel B Q] [BodySorts B]

-- ── Definitions ─────────────────────────────────────────────────────────────

/-- `p` is the vertex of the cone at `x`. -/
def vertex (x p : Point Q) : Prop := x = p

/-- `p` is strictly inside the regular cone at `x`. -/
def insideRegularCone (x p : Point Q) : Prop :=
  slopeFinite x p ∧ ∃ v ∈ lineVelocity (lineJoining x p), sNorm2 v < 1

/-- `p` is strictly outside the regular cone at `x`. -/
def outsideRegularCone (x p : Point Q) : Prop :=
  x ≠ p ∧
    (slopeInfinite x p ∨ ∃ v ∈ lineVelocity (lineJoining x p), sNorm2 v > 1)

/-- `p` is on the regular cone at `x`. -/
def onRegularCone (x p : Point Q) : Prop :=
  x = p ∨ ∃ v ∈ lineVelocity (lineJoining x p), sNorm2 v = 1

-- ── Lemmas ──────────────────────────────────────────────────────────────────

theorem lemDrtnLineJoining (l : Set (Point Q)) (x p : Point Q)
    (hl : l = lineJoining x p) (hne : x ≠ p) :
    (p ⊖ x) ∈ drtn l := by
  simp only [drtn, Set.mem_setOf_eq]
  have ⟨hx, hp⟩ := lemLineJoiningContainsEndPoints (Q := Q) x p
  exact ⟨x, p, hne, hl ▸ hx, hl ▸ hp, rfl⟩

theorem lemVelocityLineJoining (l : Set (Point Q)) (x p : Point Q) (v : Space Q)
    (hl : l = lineJoining x p) (hv : v = velocityJoining origin (p ⊖ x))
    (hne : x ≠ p) :
    v ∈ lineVelocity l := by
  simp only [lineVelocity, Set.mem_setOf_eq]
  exact ⟨p ⊖ x, lemDrtnLineJoining l x p hl hne, hv⟩

theorem lemSlopeLineJoining (l : Set (Point Q)) (p q : Point Q)
    (hl : l = lineJoining p q) (hne : p ≠ q) :
    (∃ x y, onLine x l ∧ onLine y l ∧ x ≠ y ∧ slopeFinite x y) ↔ slopeFinite p q := by
  have ⟨hp, hq⟩ := lemLineJoiningContainsEndPoints (Q := Q) p q
  constructor
  · -- lineSlopeFinite l → slopeFinite p q
    rintro ⟨x, y, hxl, hyl, hxy, hsf⟩
    -- x, y on l = lineJoining p q, so x = p ⊕ a⊗(q⊖p), y = p ⊕ b⊗(q⊖p)
    rw [hl] at hxl hyl
    obtain ⟨_, ⟨a, rfl⟩⟩ := hxl
    obtain ⟨_, ⟨b, rfl⟩⟩ := hyl
    simp only [slopeFinite, ne_eq, moveBy, scaleBy, movebackBy] at hsf ⊢
    intro htpq; exact hsf (by rw [htpq]; ring)
  · -- slopeFinite p q → lineSlopeFinite l
    intro hsf
    exact ⟨p, q, hl ▸ hp, hl ▸ hq, hne, hsf⟩

theorem lemVelocityJoiningUsingPoints (x p : Point Q) (hne : x ≠ p)
    (hfin : slopeFinite x p) :
    velocityJoining origin (p ⊖ x) = sComponent ((1 / (p.tval - x.tval)) ⊗ (p ⊖ x)) := by
  simp only [velocityJoining, sloper]
  have hsf : slopeFinite (Q := Q) origin (p ⊖ x) := by
    simp only [slopeFinite, ne_eq, origin, movebackBy]; intro h; exact hfin (by linarith)
  rw [if_pos hsf]
  have htne : p.tval - x.tval ≠ 0 := sub_ne_zero.mpr hfin.symm
  have htne' : x.tval - p.tval ≠ 0 := sub_ne_zero.mpr hfin
  -- Show the two sComponent args are equal as Points
  suffices h : (1 / (Point.tval origin - Point.tval (p ⊖ x))) ⊗ (origin ⊖ (p ⊖ x)) =
               (1 / (p.tval - x.tval)) ⊗ (p ⊖ x) by rw [h]
  ext <;> simp [origin, movebackBy, scaleBy, one_div] <;> field_simp [htne, htne'] <;> ring_nf

theorem lemLineVelocityNonZeroImpliesFinite (l : Set (Point Q)) (v : Space Q)
    (hv : v ∈ lineVelocity l) (hnz : sNorm2 v ≠ 0) :
    ∃ x y, onLine x l ∧ onLine y l ∧ x ≠ y ∧ slopeFinite x y := by
  simp only [lineVelocity, Set.mem_setOf_eq] at hv
  obtain ⟨d, hd_drtn, hv_eq⟩ := hv
  simp only [drtn, Set.mem_setOf_eq] at hd_drtn
  obtain ⟨p, q, hne, hp, hq, rfl⟩ := hd_drtn
  -- v = velocityJoining origin (q ⊖ p)
  -- If slopeInfinite p q, then (q ⊖ p).tval = 0, so slopeInfinite origin (q ⊖ p)
  -- Then sloper origin (q ⊖ p) = origin, velocityJoining = sOrigin, sNorm2 = 0 → contradiction
  by_cases hsf : slopeFinite p q
  · exact ⟨p, q, hp, hq, hne, hsf⟩
  · exfalso; apply hnz
    simp only [slopeFinite, ne_eq, not_not] at hsf
    have : slopeInfinite (Q := Q) origin (q ⊖ p) := by
      simp [slopeInfinite, origin, movebackBy, hsf]
    rw [hv_eq, velocityJoining, sloper, if_neg (show ¬ slopeFinite (Q := Q) origin (q ⊖ p) from by
      simp [slopeFinite, ne_eq, not_not]; exact this)]
    simp [sComponent, origin, sNorm2, sqr]

theorem lemLineVelocityUsingPoints (l : Set (Point Q)) (x p : Point Q)
    (hl : l = lineJoining x p) (hne : x ≠ p) (hfin : slopeFinite x p)
    (v : Space Q) (hv : v ∈ lineVelocity l) :
    sNorm2 v = sNorm2 (velocityJoining origin (p ⊖ x)) := by
  -- v = velocityJoining origin d for some d ∈ drtn l
  simp only [lineVelocity, Set.mem_setOf_eq] at hv
  obtain ⟨d, hd_drtn, rfl⟩ := hv
  -- p ⊖ x ∈ drtn l
  have hpx_drtn := lemDrtnLineJoining l x p hl hne
  -- d and (p ⊖ x) are proportional
  obtain ⟨α, hα_nz, hd_eq⟩ := lemDrtn l d (p ⊖ x) ⟨hd_drtn, hpx_drtn⟩
  -- velocityJoining origin d = sComponent (sloper origin d)
  -- Since d = (1/α) ⊗ (p ⊖ x), velocity is scaled accordingly
  -- But sNorm2 of velocity depends on d.tval and sComponent d
  -- Since (p ⊖ x) = α ⊗ d, we have tval(p ⊖ x) = α * tval d
  -- and sComponent(p ⊖ x) = α ⊗ₛ sComponent d
  -- Key: sloper origin d = (1/(0 - d.tval)) ⊗ (origin ⊖ d) when slopeFinite origin d
  -- slopeFinite origin d ↔ d.tval ≠ 0
  -- Since (p ⊖ x).tval = p.tval - x.tval ≠ 0 (from hfin)
  -- and (p ⊖ x) = α ⊗ d with α ≠ 0, so d.tval ≠ 0
  have hpx_tval : (p ⊖ x).tval ≠ 0 := by
    simp only [movebackBy]; exact sub_ne_zero.mpr hfin.symm
  have hd_tval : d.tval ≠ 0 := by
    intro h0; apply hpx_tval; rw [hd_eq]; simp [scaleBy, h0]
  have hsf_d : slopeFinite (Q := Q) origin d := by
    simp only [slopeFinite, ne_eq, origin]; exact fun h => hd_tval h.symm
  have hsf_px : slopeFinite (Q := Q) origin (p ⊖ x) := by
    simp only [slopeFinite, ne_eq, origin, movebackBy]; exact fun h => hfin (by linarith)
  -- Show velocityJoining origin d = velocityJoining origin (p ⊖ x)
  suffices h : velocityJoining (Q := Q) origin d = velocityJoining origin (p ⊖ x) by
    rw [h]
  rw [hd_eq]
  simp only [velocityJoining, sloper]
  have hsf_ad : slopeFinite (Q := Q) origin (α ⊗ d) := by
    simp only [slopeFinite, ne_eq, origin, scaleBy]
    exact fun h => mul_ne_zero hα_nz hd_tval h.symm
  rw [if_pos hsf_d, if_pos hsf_ad]
  simp only [sComponent, origin, movebackBy, scaleBy, Space.mk.injEq]
  refine ⟨?_, ?_, ?_⟩ <;> field_simp [hα_nz, hd_tval] <;> ring_nf

theorem lemSNorm2VelocityJoining (x p : Point Q) (hfin : slopeFinite x p) :
    sNorm2 (velocityJoining origin (p ⊖ x)) =
      sSep2 x p / sqr (x.tval - p.tval) := by
  simp only [velocityJoining, sloper]
  have hsf : slopeFinite (Q := Q) origin (p ⊖ x) := by
    simp only [slopeFinite, ne_eq, origin, movebackBy]; exact fun h => hfin (by linarith)
  rw [if_pos hsf]
  simp only [sComponent, origin, movebackBy, scaleBy, sNorm2, sSep2, sqr]
  have htne : x.tval - p.tval ≠ 0 := sub_ne_zero.mpr hfin
  field_simp [htne]
  ring_nf

theorem lemOrthogalSpaceVectorExists (v : Space Q) (hnz : v ≠ sOrigin) :
    ∃ u : Space Q, u ≠ sOrigin ∧ sdot u v = 0 := by
  rcases v with ⟨x, y, z⟩
  by_cases hx : x = 0
  · -- x = 0, so v = (0,y,z) with y ≠ 0 or z ≠ 0. Take w = (1,0,0)
    refine ⟨⟨1, 0, 0⟩, ?_, ?_⟩
    · simp [sOrigin, Space.mk.injEq]
    · simp [sdot, hx]
  · -- x ≠ 0, take w = (y/x, -1, 0)
    refine ⟨⟨y / x, -1, 0⟩, ?_, ?_⟩
    · simp [sOrigin, Space.mk.injEq]
    · simp [sdot]; field_simp; ring

theorem lemNonParallelVectorsExist (v : Space Q) (hnz : v ≠ sOrigin) :
    ∃ u : Space Q, u ≠ sOrigin ∧ ¬ (∃ a : Q, u = a ⊗ₛ v) := by
  rcases v with ⟨x, y, z⟩
  by_cases hx : x = 0
  · -- x = 0, take u = (1,y,z)
    refine ⟨⟨1, y, z⟩, ?_, ?_⟩
    · simp [sOrigin, Space.mk.injEq]
    · rintro ⟨a, ha⟩
      have h1 : (1 : Q) = a * x := by
        simpa [sScaleBy, Space.mk.injEq] using congrArg Space.svalx ha
      have h10 : (1 : Q) = 0 := by simpa [hx] using h1
      exact one_ne_zero h10
  · -- x ≠ 0, take u = (x, y+1, z)
    refine ⟨⟨x, y + 1, z⟩, ?_, ?_⟩
    · simp [sOrigin, Space.mk.injEq, hx]
    · rintro ⟨a, ha⟩
      have hx1 : x = a * x := by
        simpa [sScaleBy, Space.mk.injEq] using congrArg Space.svalx ha
      have ha1 : a = 1 := by
        have hxmul : x * (1 - a) = 0 := by nlinarith [hx1]
        have h1a : 1 - a = 0 := (mul_eq_zero.mp hxmul).resolve_left hx
        linarith
      have hy1 : y + 1 = a * y := by
        simpa [sScaleBy, Space.mk.injEq] using congrArg Space.svaly ha
      rw [ha1] at hy1
      linarith

theorem lemConeContainsVertex (x : Point Q) :
    x ∈ regularConeSet x := by
  -- regularCone x x: use onRegularCone's left disjunct (x = x)
  -- But regularCone needs a line witness. Construct one.
  set d : Point Q := ⟨1, 1, 0, 0⟩ with d_def
  set p := x ⊕ d with p_def
  set l := lineJoining x p with l_def
  have hne : x ≠ p := by
    intro h; rw [p_def] at h
    have := congr_arg Point.tval h; simp [moveBy] at this; linarith
  have hpmx : p ⊖ x = d := by ext <;> simp [p_def, movebackBy, moveBy]
  -- v ∈ lineVelocity l with sNorm2 v = 1
  -- slopeFinite origin d since d.tval = 1 ≠ 0
  have hsf : slopeFinite (Q := Q) origin d := by
    simp only [slopeFinite, ne_eq, origin, d_def]; norm_num
  -- sloper origin d = (1/(0-1)) ⊗ (origin ⊖ d) = (-1) ⊗ (-d) = d (in effect)
  -- velocityJoining origin d = sComponent(sloper origin d)
  set v := velocityJoining (Q := Q) origin d
  have hv1 : sNorm2 v = 1 := by
    simp only [v, velocityJoining, sloper, if_pos hsf]
    simp only [sComponent, origin, movebackBy, scaleBy, d_def, sNorm2, sqr]
    norm_num
  have hvel : v ∈ lineVelocity l := by
    rw [show v = velocityJoining origin (p ⊖ x) from by rw [hpmx]]
    exact lemVelocityLineJoining l x p _ l_def rfl hne
  simp only [regularConeSet, Set.mem_setOf_eq, regularCone]
  have ⟨hxl, _⟩ := lemLineJoiningContainsEndPoints (Q := Q) x p
  exact ⟨l, hxl, hxl, v, hvel, hv1⟩

theorem lemConesExist (x : Point Q) :
    regularConeSet (Q := Q) x ≠ ∅ := by
  intro h
  have := lemConeContainsVertex (Q := Q) x
  rw [Set.eq_empty_iff_forall_notMem] at h
  exact h x this

theorem lemRegularCone (m : B) (x p : Point Q)
    [AxLightMinus B Q] :
    cone m x p ↔ regularCone x p := by
  sorry -- phase2: uses AxLightMinus

theorem lemSlopeInfiniteImpliesOutside (x p : Point Q)
    (hne : x ≠ p) (hsi : slopeInfinite x p) :
    outsideRegularCone x p := by
  exact ⟨hne, Or.inl hsi⟩

theorem lemClassification (x p : Point Q) :
    vertex x p ∨ insideRegularCone x p ∨ outsideRegularCone x p ∨ onRegularCone x p := by
  by_cases hxp : x = p
  · left; exact hxp
  · set l := lineJoining x p
    set v := velocityJoining origin (p ⊖ x)
    have hvel : v ∈ lineVelocity l := lemVelocityLineJoining l x p v rfl rfl hxp
    by_cases hsf : slopeFinite x p
    · -- finite slope: classify by sNorm2 v
      rcases lt_trichotomy (sNorm2 v) 1 with hlt | heq | hgt
      · right; left; exact ⟨hsf, v, hvel, hlt⟩
      · right; right; right; right; exact ⟨v, hvel, heq⟩
      · right; right; left; exact ⟨hxp, Or.inr ⟨v, hvel, hgt⟩⟩
    · -- infinite slope
      right; right; left
      exact ⟨hxp, Or.inl (show slopeInfinite x p by
        simp only [slopeFinite, ne_eq, not_not] at hsf
        exact hsf)⟩

theorem lemQuadCoordinates (x p d : Point Q) (a : Q) :
    sSep2 (x ⊕ (a ⊗ d)) p - sqr ((x ⊕ (a ⊗ d)).tval - p.tval) =
      (sNorm2 (sComponent d) - sqr d.tval) * sqr a +
      2 * (sdot (sComponent d) (sComponent (x ⊖ p)) - d.tval * (x.tval - p.tval)) * a +
      (sSep2 x p - sqr (x.tval - p.tval)) := by
  simp only [sSep2, sNorm2, sComponent, sdot, moveBy, scaleBy, movebackBy, sqr]
  ring

theorem lemConeCoordinates (x p : Point Q) (hne : x ≠ p) (hfin : slopeFinite x p)
    (d : Point Q) :
  1 - sSep2 x p / sqr (x.tval - p.tval) = mNorm2 (p ⊖ x) / sqr (p.tval - x.tval) := by
  have htne : x.tval - p.tval ≠ 0 := sub_ne_zero.mpr hfin
  have htne2 : sqr (x.tval - p.tval) ≠ 0 := by
    intro h; exact htne (by
      have := sqr_nonneg' (x.tval - p.tval)
      unfold sqr at h; nlinarith)
  simp only [sSep2, sNorm2, sComponent, mNorm2, movebackBy, sqr]
  have htne' : p.tval - x.tval ≠ 0 := sub_ne_zero.mpr hfin.symm
  field_simp [htne, htne']
  ring_nf

theorem lemConeCoordinates1 (x p : Point Q) (hne : x ≠ p) (hfin : slopeFinite x p) :
    insideRegularCone x p ↔ mNorm2 (p ⊖ x) > 0 := by
  set l := lineJoining x p
  set v₀ := velocityJoining origin (p ⊖ x)
  have htne : x.tval - p.tval ≠ 0 := sub_ne_zero.mpr hfin
  have ht2_pos : sqr (x.tval - p.tval) > 0 := lemSquaresPositive _ htne
  have hvel₀ : v₀ ∈ lineVelocity l := lemVelocityLineJoining l x p v₀ rfl rfl hne
  have hv₀_eq : sNorm2 v₀ = sSep2 x p / sqr (x.tval - p.tval) :=
    lemSNorm2VelocityJoining x p hfin
  -- mNorm2(p ⊖ x) = sqr(x.tval - p.tval) - sSep2 x p
  have hmn_eq : mNorm2 (p ⊖ x) = sqr (x.tval - p.tval) - sSep2 x p := by
    simp only [mNorm2, sNorm2, sComponent, movebackBy, sqr, sSep2]
    ring
  constructor
  · rintro ⟨_, v, hv, hvlt⟩
    rw [lemLineVelocityUsingPoints l x p rfl hne hfin v hv, hv₀_eq,
        div_lt_one ht2_pos] at hvlt
    rw [hmn_eq]; linarith
  · intro hmn
    rw [hmn_eq] at hmn
    refine ⟨hfin, v₀, hvel₀, ?_⟩
    rw [hv₀_eq, div_lt_one ht2_pos]; linarith

theorem lemWhereLineMeetsCone (x d : Point Q) (p : Point Q)
    (hne : d ≠ origin) :
    (x ⊕ d) ∈ regularConeSet p ↔
      sSep2 (x ⊕ d) p = sqr ((x ⊕ d).tval - p.tval) ∨ (x ⊕ d) = p := by
  sorry -- phase2

theorem lemLineMeetsCone1 (x d p : Point Q) :
    ∀ a : Q, (x ⊕ (a ⊗ d)) ∈ regularConeSet p ↔
      ((x ⊕ (a ⊗ d)) = p ∨
       sSep2 (x ⊕ (a ⊗ d)) p = sqr ((x ⊕ (a ⊗ d)).tval - p.tval)) := by
  sorry -- phase2

theorem lemLineMeetsCone2 (x d p : Point Q) (hxp : x = p)
    (hlight : sNorm2 (sComponent d) = sqr d.tval) :
    ∀ a : Q, (x ⊕ (a ⊗ d)) ∈ regularConeSet p := by
  sorry -- phase2

theorem lemLineMeetsCone3 (x d p : Point Q)
    (A B C : Q)
    (hA : A = sNorm2 (sComponent d) - sqr d.tval)
    (hB : B = 2 * (sdot (sComponent d) (sComponent (x ⊖ p)) - d.tval * (x.tval - p.tval)))
    (hC : C = sSep2 x p - sqr (x.tval - p.tval))
    (hxp : x = p) (hAne : A ≠ 0) :
    Set.ncard { a : Q | (x ⊕ (a ⊗ d)) ∈ regularConeSet p } ≤ 2 := by
  sorry -- phase2

theorem lemLineMeetsCone4 (x d p : Point Q)
    (A B C : Q)
    (hA : A = sNorm2 (sComponent d) - sqr d.tval)
    (hB : B = 2 * (sdot (sComponent d) (sComponent (x ⊖ p)) - d.tval * (x.tval - p.tval)))
    (hC : C = sSep2 x p - sqr (x.tval - p.tval))
    (hxne : x ≠ p) (hBC : B = 0 ∧ C = 0) (hA0 : A = 0) :
    ∀ a : Q, (x ⊕ (a ⊗ d)) ∈ regularConeSet p ↔ a = 0 := by
  sorry -- phase2

theorem lemLineMeetsCone5 (x d p : Point Q)
    (A B C : Q)
    (hA : A = sNorm2 (sComponent d) - sqr d.tval)
    (hB : B = 2 * (sdot (sComponent d) (sComponent (x ⊖ p)) - d.tval * (x.tval - p.tval)))
    (hC : C = sSep2 x p - sqr (x.tval - p.tval))
    (hxne : x ≠ p) (hA0 : A = 0) (hBne : B ≠ 0) :
    Set.ncard { a : Q | (x ⊕ (a ⊗ d)) ∈ regularConeSet p } ≤ 2 := by
  sorry -- phase2

theorem lemLineMeetsCone6 (x d p : Point Q)
    (A B C : Q)
    (hA : A = sNorm2 (sComponent d) - sqr d.tval)
    (hB : B = 2 * (sdot (sComponent d) (sComponent (x ⊖ p)) - d.tval * (x.tval - p.tval)))
    (hC : C = sSep2 x p - sqr (x.tval - p.tval))
    (hxne : x ≠ p) (hAne : A ≠ 0) :
    Set.ncard { a : Q | (x ⊕ (a ⊗ d)) ∈ regularConeSet p } ≤ 2 := by
  sorry -- phase2

theorem lemConeLemma1 (x d p : Point Q)
    (hmeet : (x ⊕ d) ∈ regularConeSet p)
    (hne : (x ⊕ d) ≠ p)
    (hfin : slopeFinite (x ⊕ d) p) :
    sSep2 (x ⊕ d) p / sqr ((x ⊕ d).tval - p.tval) = 1 := by
  sorry -- phase2

theorem lemConeLemma2 (x d p : Point Q)
    (hxp : x ≠ p) (hfin : slopeFinite x p) :
    insideRegularCone x p ↔
      ∀ l, (isLine l ∧ onLine x l ∧ onLine p l) →
        Set.ncard { q ∈ regularConeSet p | onLine q l } > 2 := by
  sorry -- phase2: long proof (350 lines in Isabelle)

theorem lemLineInsideRegularConeHasFiniteSlope (x p : Point Q)
    (hin : insideRegularCone x p) :
    slopeFinite x p := by
  exact hin.1

theorem lemInvertibleOnMeet (x d p : Point Q) (f : Point Q → Point Q)
    (hinv : invertible f) :
    { a : Q | (x ⊕ (a ⊗ d)) ∈ regularConeSet p } =
    { a : Q | f (x ⊕ (a ⊗ d)) ∈ applyToSet (asFunc f) (regularConeSet p) } := by
  sorry -- phase2

theorem lemInsideCone (x p : Point Q)
    (hxp : x ≠ p) (hfin : slopeFinite x p) :
    insideRegularCone x p ↔ timelike (p ⊖ x) := by
  rw [lemConeCoordinates1 x p hxp hfin]; rfl

theorem lemOnRegularConeIff (x p : Point Q) :
    onRegularCone x p ↔ (x = p ∨ lightlike (p ⊖ x)) := by
  constructor
  · -- onRegularCone → x = p ∨ lightlike
    rintro (rfl | ⟨v, hv, hv1⟩)
    · left; rfl
    · right
      have hne : x ≠ p := by
        intro h; rw [h] at hv
        -- v ∈ lineVelocity (lineJoining p p), but lineJoining p p = line p origin
        -- all points on it equal p, so drtn is empty
        simp only [lineVelocity, Set.mem_setOf_eq] at hv
        obtain ⟨d, hd, _⟩ := hv
        simp only [drtn, Set.mem_setOf_eq] at hd
        obtain ⟨a, b, hab, ha, hb, _⟩ := hd
        obtain ⟨_, ⟨α, rfl⟩⟩ := ha; obtain ⟨_, ⟨β, rfl⟩⟩ := hb
        exact hab (by ext <;> simp [lineJoining, line, moveBy, scaleBy, movebackBy])
      constructor
      · -- p ⊖ x ≠ origin
        intro h
        have hp_eq_x : p = x := by
          have ht := congr_arg Point.tval h
          have hx := congr_arg Point.xval h
          have hy := congr_arg Point.yval h
          have hz := congr_arg Point.zval h
          simp [movebackBy, origin] at ht hx hy hz
          ext <;> linarith
        exact hne hp_eq_x.symm
      · -- mNorm2 (p ⊖ x) = 0
        by_cases hfin : slopeFinite x p
        · have hv_norm := lemLineVelocityUsingPoints _ x p rfl hne hfin v hv
          rw [hv1, lemSNorm2VelocityJoining x p hfin] at hv_norm
          have hcoord := lemConeCoordinates (x := x) (p := p) (d := p ⊖ x) hne hfin
          have hleft : 1 - sSep2 x p / sqr (x.tval - p.tval) = 0 := by linarith
          rw [hleft] at hcoord
          have hsqr_ne : sqr (p.tval - x.tval) ≠ 0 :=
            ne_of_gt (lemSquaresPositive _ (sub_ne_zero.mpr hfin.symm))
          exact (div_eq_zero_iff.mp hcoord.symm).resolve_right hsqr_ne
        · -- slopeInfinite: impossible since v has sNorm2 = 1
          exfalso
          simp only [slopeFinite, ne_eq, not_not] at hfin
          simp only [lineVelocity, Set.mem_setOf_eq] at hv
          obtain ⟨d, hd, rfl⟩ := hv
          simp only [drtn, Set.mem_setOf_eq] at hd
          obtain ⟨a, b, hab, ha, hb, rfl⟩ := hd
          have htval_eq : (b ⊖ a).tval = 0 := by
            obtain ⟨_, ⟨α, rfl⟩⟩ := ha; obtain ⟨_, ⟨β, rfl⟩⟩ := hb
            simp [moveBy, scaleBy, movebackBy, hfin]
          have hsf_neg : ¬ slopeFinite (Q := Q) origin (b ⊖ a) := by
            simp only [slopeFinite, ne_eq, not_not, origin]; exact htval_eq.symm
          have hsf_neg0 : ¬ slopeFinite (Q := Q) ({ tval := 0, xval := 0, yval := 0, zval := 0 }) (b ⊖ a) := by
            simpa [origin] using hsf_neg
          have hv0 : sNorm2 (velocityJoining origin (b ⊖ a)) = 0 := by
            have hvel0 : velocityJoining (Q := Q) origin (b ⊖ a) = sOrigin := by
              simp [velocityJoining, sloper, hsf_neg0, sComponent, origin, sOrigin]
            rw [hvel0]
            simp [sNorm2, sOrigin, sqr]
          linarith [hv1, hv0]
  · -- x = p ∨ lightlike → onRegularCone
    rintro (rfl | ⟨hne_origin, hmn⟩)
    · left; rfl
    · right
      have hne : x ≠ p := by
        intro h; rw [h] at hne_origin
        exact hne_origin (by ext <;> simp [movebackBy, origin])
      have hfin : slopeFinite x p := by
        intro h
        -- slopeInfinite: (p ⊖ x).tval = 0, so mNorm2 = -sNorm2 ≤ 0
        -- But if mNorm2 = 0 and tval = 0, then all spatial components = 0, so p = x
        unfold mNorm2 sNorm2 sComponent at hmn
        simp only [movebackBy, sqr] at hmn
        have htval0 : p.tval - x.tval = 0 := by linarith [h]
        rw [htval0, mul_zero, zero_sub] at hmn
        -- -(...) = 0 means ... = 0
        have h_all_zero : (p.xval - x.xval) * (p.xval - x.xval) +
          ((p.yval - x.yval) * (p.yval - x.yval) +
           (p.zval - x.zval) * (p.zval - x.zval)) = 0 := by linarith
        have hx : p.xval = x.xval := by nlinarith [sqr_nonneg' (p.yval - x.yval), sqr_nonneg' (p.zval - x.zval)]
        have hy : p.yval = x.yval := by nlinarith [sqr_nonneg' (p.xval - x.xval), sqr_nonneg' (p.zval - x.zval)]
        have hz : p.zval = x.zval := by nlinarith [sqr_nonneg' (p.xval - x.xval), sqr_nonneg' (p.yval - x.yval)]
        exact hne (by ext <;> linarith)
      set l := lineJoining x p
      set v := velocityJoining origin (p ⊖ x)
      have hvel : v ∈ lineVelocity l := lemVelocityLineJoining l x p v rfl rfl hne
      refine ⟨v, hvel, ?_⟩
      rw [lemSNorm2VelocityJoining x p hfin]
      rw [div_eq_one_iff_eq (ne_of_gt (lemSquaresPositive _ (sub_ne_zero.mpr hfin)))]
      simp only [mNorm2, sNorm2, sComponent, movebackBy, sqr, sSep2] at hmn ⊢
      nlinarith

theorem lemOutsideRegularConeImplies (x p : Point Q)
    (hout : outsideRegularCone x p) :
    spacelike (p ⊖ x) ∨ (x ≠ p ∧ slopeInfinite x p) := by
  obtain ⟨hne, hsi | ⟨v, hv, hvgt⟩⟩ := hout
  · right; exact ⟨hne, hsi⟩
  · left
    -- v ∈ lineVelocity (lineJoining x p), sNorm2 v > 1
    -- Must have slopeFinite x p (otherwise v = sOrigin, sNorm2 = 0, contradiction)
    have hfin : slopeFinite x p := by
      intro h
      simp only [lineVelocity, Set.mem_setOf_eq] at hv
      obtain ⟨d, hd, rfl⟩ := hv
      simp only [drtn, Set.mem_setOf_eq] at hd
      obtain ⟨a, b, _, ha, hb, rfl⟩ := hd
      have htval0 : (b ⊖ a).tval = 0 := by
        obtain ⟨_, ⟨α, rfl⟩⟩ := ha
        obtain ⟨_, ⟨β, rfl⟩⟩ := hb
        simp [moveBy, scaleBy, movebackBy, h]
      have hsf_neg : ¬ slopeFinite (Q := Q) origin (b ⊖ a) := by
        simp only [slopeFinite, ne_eq, not_not, origin]; exact htval0.symm
      have hsf_neg0 : ¬ slopeFinite (Q := Q) ({ tval := 0, xval := 0, yval := 0, zval := 0 }) (b ⊖ a) := by
        simpa [origin] using hsf_neg
      have hv0 : sNorm2 (velocityJoining origin (b ⊖ a)) = 0 := by
        have hvel0 : velocityJoining (Q := Q) origin (b ⊖ a) = sOrigin := by
          simp [velocityJoining, sloper, hsf_neg0, sComponent, origin, sOrigin]
        rw [hvel0]
        simp [sNorm2, sOrigin, sqr]
      linarith [hvgt, hv0]
    have ht2_pos := lemSquaresPositive (x.tval - p.tval) (sub_ne_zero.mpr hfin)
    have hv_norm := lemLineVelocityUsingPoints _ x p rfl hne hfin v hv
    rw [lemSNorm2VelocityJoining x p hfin] at hv_norm
    rw [hv_norm] at hvgt
    -- sSep2 x p / sqr(x.tval - p.tval) > 1, so sSep2 > sqr(...)
    have hsep_gt : sqr (x.tval - p.tval) < sSep2 x p := by
      rwa [gt_iff_lt, lt_div_iff₀ ht2_pos, one_mul] at hvgt
    unfold spacelike
    simp only [mNorm2, sNorm2, sComponent, movebackBy, sqr, sSep2] at hsep_gt ⊢
    nlinarith

theorem lemTimelikeInsideCone (x p : Point Q)
    (htl : timelike (p ⊖ x)) :
    insideRegularCone x p := by
  -- timelike means mNorm2 (p ⊖ x) > 0, which means slopeFinite x p and x ≠ p
  have hne : x ≠ p := by
    intro h; rw [h] at htl; simp [timelike, mNorm2, sNorm2, sComponent, movebackBy, sqr] at htl
  have hfin : slopeFinite x p := by
    simp only [slopeFinite]; intro h
    unfold timelike mNorm2 sNorm2 sComponent at htl
    simp only [movebackBy, sqr, h, sub_self, mul_zero, zero_sub] at htl
    have hsum_nonneg :
        0 ≤ (p.xval - x.xval) * (p.xval - x.xval) +
              ((p.yval - x.yval) * (p.yval - x.yval) +
               (p.zval - x.zval) * (p.zval - x.zval)) := by
      nlinarith [sqr_nonneg' (p.xval - x.xval), sqr_nonneg' (p.yval - x.yval),
                 sqr_nonneg' (p.zval - x.zval)]
    linarith
  exact (lemConeCoordinates1 x p hne hfin).mpr htl

end NoFTL.Classification
