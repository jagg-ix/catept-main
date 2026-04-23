import CATEPTMain.NoFTL.Vectors

/-!
# CauchySchwarz — Cauchy-Schwarz Inequality

Defines and proves the Cauchy-Schwarz inequality for both spatial and
spacetime vectors. Also proves the equality condition and applications
to causal vectors.

Isabelle: `class CauchySchwarz = Vectors`.
-/

set_option autoImplicit false

namespace NoFTL.CauchySchwarz

open NoFTL.Points NoFTL.Sorts NoFTL.Norms NoFTL.Vectors

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

-- ── 4-vector Cauchy-Schwarz ─────────────────────────────────────────────────

private theorem dot_self_eq_norm2 (v : Point Q) : dot v v = norm2 v := by
  simp [dot, norm2, sqr]

private theorem dot_self_nonneg (v : Point Q) : dot v v ≥ 0 := by
  rw [dot_self_eq_norm2]; exact lemNorm2NonNeg v

private theorem dot_self_pos_of_ne_origin (v : Point Q) (hv : v ≠ origin) : dot v v > 0 := by
  rw [dot_self_eq_norm2]
  have h := lemNotOriginImpliesPositiveNorm v hv
  have := lemNormSqrIsNorm2 v
  rw [this]; exact lemSquaresPositive (norm v) (ne_of_gt h)

theorem lemCauchySchwarz4 (u v : Point Q) :
    |dot u v| ≤ norm u * norm v := by
  -- Case v = origin
  by_cases hv : v = origin
  · subst hv
    show |dot u origin| ≤ norm u * norm origin
    have h1 : dot u origin = 0 := by simp [dot, origin]
    have h2 : norm (origin (Q := Q)) = 0 := (lemZeroNorm (origin (Q := Q))).mp rfl
    rw [h1, h2, abs_zero, mul_zero]
  -- Case v ≠ origin: quadratic argument
  -- For all x, dot (u ⊕ (x ⊗ v)) (u ⊕ (x ⊗ v)) ≥ 0
  -- This expands to: a*x² + b*x + c ≥ 0 where a = dot v v, b = 2*dot u v, c = dot u u
  set a := dot v v
  set b := 2 * dot u v
  set c := dot u u
  have ha_pos : a > 0 := dot_self_pos_of_ne_origin v hv
  have hquad : ∀ x : Q, a * sqr x + b * x + c ≥ 0 := by
    intro x
    have hnn : dot (moveBy u (x ⊗ v)) (moveBy u (x ⊗ v)) ≥ 0 := dot_self_nonneg _
    have hexp : dot (moveBy u (x ⊗ v)) (moveBy u (x ⊗ v)) =
        a * sqr x + b * x + c := by
      simp only [dot, moveBy, scaleBy, sqr, a, b, c]; ring
    linarith
  have hdisc : sqr b ≤ 4 * a * c := lemQuadraticGEZero a b c hquad ha_pos
  -- sqr b = sqr (2 * dot u v) = 4 * sqr (dot u v)
  -- 4 * a * c = 4 * norm2 v * norm2 u = 4 * sqr(norm v) * sqr(norm u) = sqr(2 * norm v * norm u)
  have hnn_prod : 2 * norm v * norm u ≥ 0 :=
    mul_nonneg (mul_nonneg (by norm_num : (2 : Q) ≥ 0) (lemNormNonNegative v)) (lemNormNonNegative u)
  have hsqr_eq : sqr (|b|) ≤ sqr (2 * norm v * norm u) := by
    rw [show sqr (|b|) = sqr b from by unfold sqr; rw [abs_mul_abs_self]]
    calc sqr b ≤ 4 * a * c := hdisc
      _ = 4 * dot v v * dot u u := rfl
      _ = 4 * norm2 v * norm2 u := by rw [dot_self_eq_norm2, dot_self_eq_norm2]
      _ = 4 * sqr (norm v) * sqr (norm u) := by
          rw [lemNormSqrIsNorm2 v, lemNormSqrIsNorm2 u]
      _ = sqr (2 * norm v * norm u) := by unfold sqr; ring
  have hle : |b| ≤ 2 * norm v * norm u :=
    lemSqrOrdered (|b|) (2 * norm v * norm u) ⟨hnn_prod, hsqr_eq⟩
  -- |b| = |2 * dot u v| = 2 * |dot u v|
  have hb_abs : |b| = 2 * |dot u v| := by
    show |2 * dot u v| = 2 * |dot u v|
    rw [abs_mul, abs_of_pos (by norm_num : (2 : Q) > 0)]
  rw [hb_abs] at hle
  have : |dot u v| ≤ norm v * norm u := by linarith
  linarith [mul_comm (norm u) (norm v)]

theorem lemCauchySchwarzSqr4 (u v : Point Q) :
    sqr (dot u v) ≤ norm2 u * norm2 v := by
  have h1 : sqr (dot u v) = sqr (|dot u v|) := by
    unfold sqr; rw [abs_mul_abs_self]
  rw [h1]
  have h2 : sqr (|dot u v|) ≤ sqr (norm u * norm v) :=
    lemSqrMono (|dot u v|) (norm u * norm v)
      ⟨abs_nonneg _, lemCauchySchwarz4 u v⟩
  calc sqr (|dot u v|) ≤ sqr (norm u * norm v) := h2
    _ = sqr (norm u) * sqr (norm v) := lemSqrMult (norm u) (norm v)
    _ = norm2 u * norm2 v := by rw [← lemNormSqrIsNorm2 u, ← lemNormSqrIsNorm2 v]

-- ── Spatial Cauchy-Schwarz ──────────────────────────────────────────────────

private theorem sdot_self_eq_sNorm2 (v : Space Q) : sdot v v = sNorm2 v := by
  simp [sdot, sNorm2, sqr]

private theorem sdot_self_nonneg (v : Space Q) : sdot v v ≥ 0 := by
  rw [sdot_self_eq_sNorm2]
  unfold sNorm2; linarith [sqr_nonneg' v.svalx, sqr_nonneg' v.svaly, sqr_nonneg' v.svalz]

private theorem sNorm2_nonneg (v : Space Q) : sNorm2 v ≥ 0 := by
  unfold sNorm2; linarith [sqr_nonneg' v.svalx, sqr_nonneg' v.svaly, sqr_nonneg' v.svalz]

private theorem sdot_self_pos_of_ne_sOrigin (v : Space Q) (hv : v ≠ sOrigin) :
    sdot v v > 0 := by
  rw [sdot_self_eq_sNorm2]
  unfold sNorm2 sqr sOrigin at *
  by_contra h; push_neg at h
  have hnn := sNorm2_nonneg v
  unfold sNorm2 sqr at hnn
  have heq : v.svalx * v.svalx + v.svaly * v.svaly + v.svalz * v.svalz = 0 := by linarith
  have hx := mul_self_nonneg v.svalx
  have hy := mul_self_nonneg v.svaly
  have hz := mul_self_nonneg v.svalz
  have hx : v.svalx = 0 := mul_self_eq_zero.mp (by linarith)
  have hy : v.svaly = 0 := mul_self_eq_zero.mp (by linarith)
  have hz : v.svalz = 0 := mul_self_eq_zero.mp (by linarith)
  exact hv (show v = sOrigin by cases v; simp_all [sOrigin])

private theorem lemSNormSqrIsSNorm2 (v : Space Q) : sNorm2 v = sqr (sNorm v) := by
  unfold sNorm
  have hnn := sNorm2_nonneg v
  have hr := NoFTL.AxEField.axEField (sNorm2 v) hnn
  have huniq := lemSqrt (sNorm2 v) hr
  obtain ⟨r, hr', _⟩ := huniq
  exact (Classical.epsilon_spec ⟨r, hr'⟩).2

theorem lemCauchySchwarz (u v : Space Q) :
    |sdot u v| ≤ sNorm u * sNorm v := by
  by_cases hv : v = sOrigin
  · subst hv
    show |sdot u sOrigin| ≤ sNorm u * sNorm sOrigin
    have h1 : sdot u sOrigin = 0 := by simp [sdot, sOrigin]
    have h2 : sNorm (sOrigin (Q := Q)) = 0 := by
      show sqrt (sNorm2 (sOrigin (Q := Q))) = 0
      have : sNorm2 (sOrigin (Q := Q)) = 0 := by unfold sNorm2 sOrigin sqr; ring
      rw [this]; exact lemSqrt0
    rw [h1, h2, abs_zero, mul_zero]
  set a := sdot v v
  set b := 2 * sdot u v
  set c := sdot u u
  have ha_pos : a > 0 := sdot_self_pos_of_ne_sOrigin v hv
  have hquad : ∀ x : Q, a * sqr x + b * x + c ≥ 0 := by
    intro x
    have hnn : sdot (sMoveBy u (x ⊗ₛ v)) (sMoveBy u (x ⊗ₛ v)) ≥ 0 := sdot_self_nonneg _
    have hexp : sdot (sMoveBy u (x ⊗ₛ v)) (sMoveBy u (x ⊗ₛ v)) =
        a * sqr x + b * x + c := by
      simp only [sdot, sMoveBy, sScaleBy, sqr, a, b, c]; ring
    linarith
  have hdisc : sqr b ≤ 4 * a * c := lemQuadraticGEZero a b c hquad ha_pos
  have hnn_prod : 2 * sNorm v * sNorm u ≥ 0 :=
    mul_nonneg (mul_nonneg (by norm_num : (2 : Q) ≥ 0) (lemSNormNonNeg v)) (lemSNormNonNeg u)
  have hsqr_eq : sqr (|b|) ≤ sqr (2 * sNorm v * sNorm u) := by
    rw [show sqr (|b|) = sqr b from by unfold sqr; rw [abs_mul_abs_self]]
    calc sqr b ≤ 4 * a * c := hdisc
      _ = 4 * sdot v v * sdot u u := rfl
      _ = 4 * sNorm2 v * sNorm2 u := by rw [sdot_self_eq_sNorm2, sdot_self_eq_sNorm2]
      _ = 4 * sqr (sNorm v) * sqr (sNorm u) := by
          rw [lemSNormSqrIsSNorm2 v, lemSNormSqrIsSNorm2 u]
      _ = sqr (2 * sNorm v * sNorm u) := by unfold sqr; ring
  have hle : |b| ≤ 2 * sNorm v * sNorm u :=
    lemSqrOrdered (|b|) (2 * sNorm v * sNorm u) ⟨hnn_prod, hsqr_eq⟩
  have hb_abs : |b| = 2 * |sdot u v| := by
    show |2 * sdot u v| = 2 * |sdot u v|
    rw [abs_mul, abs_of_pos (by norm_num : (2 : Q) > 0)]
  rw [hb_abs] at hle
  have : |sdot u v| ≤ sNorm v * sNorm u := by linarith
  linarith [mul_comm (sNorm u) (sNorm v)]

theorem lemCauchySchwarzSqr (u v : Space Q) :
    sqr (sdot u v) ≤ sNorm2 u * sNorm2 v := by
  have h1 : sqr (sdot u v) = sqr (|sdot u v|) := by
    unfold sqr; rw [abs_mul_abs_self]
  rw [h1]
  have h2 : sqr (|sdot u v|) ≤ sqr (sNorm u * sNorm v) :=
    lemSqrMono (|sdot u v|) (sNorm u * sNorm v)
      ⟨abs_nonneg _, lemCauchySchwarz u v⟩
  calc sqr (|sdot u v|) ≤ sqr (sNorm u * sNorm v) := h2
    _ = sqr (sNorm u) * sqr (sNorm v) := lemSqrMult (sNorm u) (sNorm v)
    _ = sNorm2 u * sNorm2 v := by rw [← lemSNormSqrIsSNorm2 u, ← lemSNormSqrIsSNorm2 v]

-- ── Equality conditions ────────────────────────────────────────────────────

theorem lemCauchySchwarzEquality (u v : Space Q)
    (heq : sqr (sdot u v) = sNorm2 u * sNorm2 v)
    (hnz : u ≠ sOrigin ∧ v ≠ sOrigin) :
    ∃ a : Q, a ≠ 0 ∧ u = a ⊗ₛ v := by
  -- Project u onto v: a = sdot u v / sNorm2 v
  have uvnz := hnz
  have hsn2u_nz : sNorm2 u ≠ 0 := by
    intro h; exact uvnz.1 (lemSpatialNullImpliesSpatialOrigin u h)
  have hsn2v_nz : sNorm2 v ≠ 0 := by
    intro h; exact uvnz.2 (lemSpatialNullImpliesSpatialOrigin v h)
  set a := sdot u v / sNorm2 v with ha_def
  have anz : a ≠ 0 := by
    intro h; rw [ha_def, div_eq_zero_iff] at h
    rcases h with h | h
    · -- sdot u v = 0 means sqr(sdot u v) = 0, so sNorm2 u * sNorm2 v = 0
      have : sqr (sdot u v) = 0 := by rw [h]; unfold sqr; ring
      rw [this] at heq
      rcases mul_eq_zero.mp heq.symm with h' | h'
      · exact uvnz.1 (lemSpatialNullImpliesSpatialOrigin u h')
      · exact uvnz.2 (lemSpatialNullImpliesSpatialOrigin v h')
    · exact uvnz.2 (lemSpatialNullImpliesSpatialOrigin v h)
  -- upv = a ⊗ₛ v is the projection
  set upv := a ⊗ₛ v
  -- sdot upv v = a * sNorm2 v = sdot u v
  have hsdot_upv : sdot upv v = sdot u v := by
    simp only [upv]; rw [lemSDotScaleLeft, sdot_self_eq_sNorm2, ha_def]
    exact div_mul_cancel₀ (sdot u v) hsn2v_nz
  -- sNorm2 upv = a² * sNorm2 v
  have hsn2_upv : sNorm2 upv = sqr a * sNorm2 v := by
    simp only [upv]; exact lemSNorm2OfScaled a v
  -- uov = u ⊖ₛ upv, u = upv ⊕ₛ uov
  set uov := u ⊖ₛ upv
  have hsum : u = upv ⊕ₛ uov := by
    simp only [uov, sMoveBy, sMovebackBy]; rcases u with ⟨ux, uy, uz⟩; rcases upv with ⟨vx, vy, vz⟩
    simp [Space.mk.injEq]
  -- sdot uov v = 0
  have hsdot_uov : sdot uov v = 0 := by
    have : sdot u v = sdot upv v + sdot uov v := by
      conv_lhs => rw [hsum]; rw [lemSDotSumLeft]
    linarith [hsdot_upv]
  -- sdot uov upv = 0
  have hsdot_uov_upv : sdot uov upv = 0 := by
    simp only [upv]; rw [lemSDotScaleRight, hsdot_uov, mul_zero]
  -- sNorm2 u = sNorm2 upv + sNorm2 uov (cross term = 0)
  have hsn2_u : sNorm2 u = sNorm2 upv + sNorm2 uov := by
    conv_lhs => rw [hsum]; rw [lemSNorm2OfSum']
    rw [lemSDotCommute] at hsdot_uov_upv; linarith
  -- From heq: sNorm2 u * sNorm2 v = sqr(sdot u v) = sqr a * sqr(sNorm2 v)
  have hlhs : sqr (sdot u v) = sqr a * sqr (sNorm2 v) := by
    simp only [ha_def, sqr]; field_simp
  -- sNorm2 u * sNorm2 v = sqr a * sqr(sNorm2 v) + sNorm2 uov * sNorm2 v
  have hrhs : sNorm2 u * sNorm2 v = sqr a * sqr (sNorm2 v) + sNorm2 uov * sNorm2 v := by
    rw [hsn2_u, hsn2_upv]; unfold sqr; ring
  -- Combining: sNorm2 uov * sNorm2 v = 0
  have hprod_zero : sNorm2 uov * sNorm2 v = 0 := by linarith [heq, hlhs, hrhs]
  -- Since sNorm2 v ≠ 0: sNorm2 uov = 0, so uov = sOrigin
  have huov_zero : sNorm2 uov = 0 := by
    rcases mul_eq_zero.mp hprod_zero with h | h
    · exact h
    · exact absurd h hsn2v_nz
  have huov_origin : uov = sOrigin := lemSpatialNullImpliesSpatialOrigin uov huov_zero
  -- u = upv ⊕ₛ sOrigin = upv = a ⊗ₛ v
  have : u = a ⊗ₛ v := by
    rw [hsum, huov_origin]; simp only [upv, sMoveBy, sOrigin, sScaleBy]
    rcases v with ⟨vx, vy, vz⟩; simp [Space.mk.injEq]
  exact ⟨a, anz, this⟩

theorem lemCauchySchwarzEqualityInUnitSphere (u v : Space Q)
    (hsphere : sNorm2 u ≤ 1 ∧ sNorm2 v ≤ 1)
    (hprod : sdot u v = 1) :
    u = v := by
  -- u, v ≠ sOrigin since sdot u v = 1 ≠ 0
  have uvnz : u ≠ sOrigin ∧ v ≠ sOrigin := by
    constructor <;> intro h <;> simp [h, sdot, sOrigin] at hprod
  -- sNorm2 u = 1 ∧ sNorm2 v = 1
  have norms1 : sNorm2 u = 1 ∧ sNorm2 v = 1 := by
    have hsnu_pos : sNorm2 u > 0 := by
      have hnn := sNorm2_nonneg u
      rcases hnn.lt_or_eq with h | h
      · exact h
      · exact absurd (lemSpatialNullImpliesSpatialOrigin u h.symm) uvnz.1
    have hsnv_pos : sNorm2 v > 0 := by
      have hnn := sNorm2_nonneg v
      rcases hnn.lt_or_eq with h | h
      · exact h
      · exact absurd (lemSpatialNullImpliesSpatialOrigin v h.symm) uvnz.2
    -- Cauchy-Schwarz: 1 = sqr(sdot u v) ≤ sNorm2 u * sNorm2 v ≤ 1 * 1 = 1
    have hcs := lemCauchySchwarzSqr u v
    have hsq1 : sqr (sdot u v) = 1 := by rw [hprod]; unfold sqr; ring
    rw [hsq1] at hcs
    -- sNorm2 u * sNorm2 v ≥ 1 and sNorm2 u ≤ 1, sNorm2 v ≤ 1
    -- If sNorm2 u < 1 then sNorm2 u * sNorm2 v < 1 * sNorm2 v ≤ 1, contradiction
    -- So sNorm2 u = 1, similarly sNorm2 v = 1
    constructor
    · by_contra hne; push_neg at hne
      have hlt := lt_of_le_of_ne hsphere.1 hne
      have : sNorm2 u * sNorm2 v < 1 := by nlinarith
      linarith
    · by_contra hne; push_neg at hne
      have hlt := lt_of_le_of_ne hsphere.2 hne
      have : sNorm2 u * sNorm2 v < 1 := by nlinarith
      linarith
  -- sqr(sdot u v) = sNorm2 u * sNorm2 v
  have heq_cs : sqr (sdot u v) = sNorm2 u * sNorm2 v := by
    rw [hprod, norms1.1, norms1.2]; unfold sqr; ring
  -- Get a ≠ 0 with u = a ⊗ₛ v
  obtain ⟨a, anz, ha⟩ := lemCauchySchwarzEquality u v heq_cs uvnz
  -- sdot u v = a * sNorm2 v = a * 1 = a
  have hsdot_eq : sdot u v = a * sNorm2 v := by
    rw [ha, lemSDotScaleLeft, sdot_self_eq_sNorm2]
  rw [norms1.2, mul_one] at hsdot_eq
  -- a = 1
  have ha1 : a = 1 := by linarith [hprod]
  rw [ha, ha1]; rcases v with ⟨vx, vy, vz⟩; simp [sScaleBy, Space.mk.injEq]

-- ── Application to causal/lightlike vectors ─────────────────────────────────

theorem lemCausalOrthogmToLightlikeImpliesParallel (p q : Point Q)
    (hcausal : causal p) (hlight : lightlike q) (horth : orthogm p q) :
    parallel p q := by
  -- Helper: if tval = 0 then mNorm2 ≤ 0
  have lemZTNeg : ∀ v : Point Q, v.tval = 0 → mNorm2 v ≤ 0 := by
    intro v hv; simp only [mNorm2, sNorm2, sComponent, sqr]; rw [hv]
    nlinarith [mul_self_nonneg v.xval, mul_self_nonneg v.yval, mul_self_nonneg v.zval]
  -- Helper: if tval = 0 and mNorm2 = 0, then v = origin
  have lemZTOrigin : ∀ v : Point Q, v.tval = 0 → mNorm2 v = 0 → v = origin := by
    intro v hv hmn; simp only [mNorm2, sNorm2, sComponent, sqr] at hmn; rw [hv] at hmn
    have hx := mul_self_nonneg v.xval; have hy := mul_self_nonneg v.yval
    have hz := mul_self_nonneg v.zval
    have hvx : v.xval = 0 := by nlinarith
    have hvy : v.yval = 0 := by nlinarith
    have hvz : v.zval = 0 := by nlinarith
    ext <;> simp [origin, hv, hvx, hvy, hvz]
  -- p.tval ≠ 0
  have tpnz : p.tval ≠ 0 := by
    rcases hcausal with htl | hll
    · intro h; have := lemZTNeg p h; unfold timelike at htl; linarith
    · intro h; exact hll.1 (lemZTOrigin p h hll.2)
  -- q.tval ≠ 0
  have tqnz : q.tval ≠ 0 := by
    intro h; exact hlight.1 (lemZTOrigin q h hlight.2)
  -- Normalise
  set phat := (1/p.tval) ⊗ p; set qhat := (1/q.tval) ⊗ q
  -- mNorm2 scaling
  have hmn2p : mNorm2 phat = sqr (1/p.tval) * mNorm2 p := lemMNorm2OfScaled (1/p.tval) p
  have hmn2q : mNorm2 qhat = sqr (1/q.tval) * mNorm2 q := lemMNorm2OfScaled (1/q.tval) q
  -- tval = 1
  have hpt1 : phat.tval = 1 := by simp only [phat, scaleBy]; field_simp
  have hqt1 : qhat.tval = 1 := by simp only [qhat, scaleBy]; field_simp
  -- mNorm2 qhat = 0
  have hql : mNorm2 qhat = 0 := by rw [hmn2q, hlight.2, mul_zero]
  -- mNorm2 = sqr tval - sNorm2 (sComponent ...)
  -- For qhat: 0 = 1 - sNorm2(sComponent qhat), so sNorm2(sComponent qhat) = 1
  have hsn2_qs : sNorm2 (sComponent qhat) = 1 := by
    simp only [mNorm2, sqr] at hql; rw [hpt1] at *; rw [hqt1] at *; linarith
  -- For phat: mNorm2 phat ≥ 0 (causal), so sNorm2(sComponent phat) ≤ 1
  have hsn2_ps : sNorm2 (sComponent phat) ≤ 1 := by
    rcases hcausal with htl | hll
    · have hpos : mNorm2 phat > 0 := by
        rw [hmn2p]; exact mul_pos (lemSquaresPositive _ (one_div_ne_zero tpnz)) htl
      simp only [mNorm2, sqr] at hpos; rw [hpt1] at hpos; linarith
    · have hzero : mNorm2 phat = 0 := by rw [hmn2p, hll.2, mul_zero]
      simp only [mNorm2, sqr] at hzero; rw [hpt1] at hzero; linarith
  -- orthogm phat qhat
  have horth_hat : orthogm phat qhat := by
    simp only [orthogm, phat, qhat]
    rw [lemMDotScaleLeft, lemMDotScaleRight]
    simp only [orthogm] at horth; rw [horth]; ring
  -- sdot (sComponent phat) (sComponent qhat) = 1
  -- From orthogm: mdot phat qhat = phat.t * qhat.t - sdot(sc phat)(sc qhat) = 0
  -- So sdot = 1 * 1 = 1
  have hsdot1 : sdot (sComponent phat) (sComponent qhat) = 1 := by
    simp only [orthogm, mdot] at horth_hat; rw [hpt1, hqt1] at horth_hat; linarith
  -- Apply C-S equality in unit sphere
  have hps_eq : sComponent phat = sComponent qhat :=
    lemCauchySchwarzEqualityInUnitSphere (sComponent phat) (sComponent qhat)
      ⟨hsn2_ps, le_of_eq hsn2_qs⟩ hsdot1
  -- phat = qhat
  have hphat_eq : phat = qhat := by
    have hx := congr_arg Space.svalx hps_eq
    have hy := congr_arg Space.svaly hps_eq
    have hz := congr_arg Space.svalz hps_eq
    simp only [sComponent] at hx hy hz
    ext
    · rw [hpt1, hqt1]
    · exact hx
    · exact hy
    · exact hz
  -- p = (p.tval / q.tval) ⊗ q
  have hpeq : p = (p.tval / q.tval) ⊗ q := by
    have h : (1/p.tval) ⊗ p = (1/q.tval) ⊗ q := hphat_eq
    -- From (1/tp)*p = (1/tq)*q, multiply by tp to get p = (tp/tq)*q
    ext
    · simp [scaleBy]; field_simp
    all_goals {
      have := congr_arg Point.xval h; have := congr_arg Point.yval h
      have := congr_arg Point.zval h
      simp only [scaleBy] at *; field_simp at *; nlinarith
    }
  exact ⟨p.tval / q.tval, div_ne_zero tpnz tqnz, hpeq⟩

end NoFTL.CauchySchwarz
