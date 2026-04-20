import CATEPTMain.AFPBridge.NoFTL.CauchySchwarz

/-!
# ReverseCauchySchwarz — Reverse Cauchy-Schwarz for Timelike Vectors

Proves the "reverse" Cauchy-Schwarz inequality for timelike vectors
in the Minkowski metric: `sqr (X ⊙ₘ D) ≥ (mNorm2 X) * (mNorm2 D)`.

Isabelle: `class ReverseCauchySchwarz = CauchySchwarz`.
-/

set_option autoImplicit false
set_option maxHeartbeats 1600000

namespace NoFTL.ReverseCauchySchwarz

open NoFTL.Points NoFTL.Sorts NoFTL.Norms NoFTL.Vectors NoFTL.CauchySchwarz

variable {Q : Type*} [Field Q] [LinearOrder Q] [IsStrictOrderedRing Q]
variable [NoFTL.AxEField Q]

-- ── Lemmas ──────────────────────────────────────────────────────────────────

theorem lemTimelikeNotZeroTime (v : Point Q) (htl : timelike v) :
    v.tval ≠ 0 := by
  intro h0
  unfold timelike mNorm2 sNorm2 sComponent at htl
  simp only [h0, sqr] at htl
  have hx := mul_self_nonneg v.xval
  have hy := mul_self_nonneg v.yval
  have hz := mul_self_nonneg v.zval
  linarith

theorem lemOrthogmToTimelike (u v : Point Q)
    (htl : timelike u) (horth : orthogm u v) (hnz : v ≠ origin) :
    spacelike v := by
  -- orthogm: mdot u v = 0, i.e., u.t * v.t = sdot(su, sv)
  unfold orthogm mdot at horth
  -- horth : u.tval * v.tval - sdot (sComponent u) (sComponent v) = 0
  have hut_eq : u.tval * v.tval = sdot (sComponent u) (sComponent v) := by linarith
  have hutnz : u.tval ≠ 0 := lemTimelikeNotZeroTime u htl
  have hut2_pos : sqr u.tval > 0 := lemSquaresPositive u.tval hutnz
  -- From timelike: sqr u.tval > sNorm2(sComponent u)
  unfold timelike mNorm2 at htl
  -- htl : sqr u.tval - sNorm2 (sComponent u) > 0
  have hsu_lt : sNorm2 (sComponent u) < sqr u.tval := by linarith
  -- Cauchy-Schwarz: sqr(sdot(su,sv)) ≤ sNorm2(su) * sNorm2(sv)
  have hcs := lemCauchySchwarzSqr (sComponent u) (sComponent v)
  -- sqr(u.t * v.t) = sqr(sdot(su,sv)) ≤ sNorm2(su) * sNorm2(sv)
  have hsq_eq : sqr (u.tval * v.tval) = sqr (sdot (sComponent u) (sComponent v)) := by
    rw [hut_eq]
  -- sqr(u.t * v.t) = sqr(u.t) * sqr(v.t)
  have hsq_prod : sqr (u.tval * v.tval) = sqr u.tval * sqr v.tval := lemSqrMult u.tval v.tval
  -- So sqr(u.t) * sqr(v.t) ≤ sNorm2(su) * sNorm2(sv) < sqr(u.t) * sNorm2(sv)
  -- Therefore sqr(v.t) < sNorm2(sv) (dividing by sqr(u.t) > 0), i.e., spacelike
  unfold spacelike mNorm2
  -- Need: sqr v.tval - sNorm2 (sComponent v) < 0, i.e., sqr v.tval < sNorm2(sComponent v)
  by_contra h; push_neg at h
  -- h : sqr v.tval - sNorm2 (sComponent v) ≥ 0, i.e., sqr v.tval ≥ sNorm2(sComponent v)
  -- Then sqr(u.t) * sqr(v.t) ≤ sNorm2(su) * sNorm2(sv)
  -- But also sqr(u.t) * sqr(v.t) = sqr(u.t * v.t) = sqr(sdot(su,sv))
  have h1 : sqr u.tval * sqr v.tval ≤ sNorm2 (sComponent u) * sNorm2 (sComponent v) := by
    rw [← hsq_prod, hsq_eq]; exact hcs
  -- And sNorm2(su) * sNorm2(sv) ≤ sqr(u.t) * sNorm2(sv) (since sNorm2(su) ≤ sqr(u.t) - 1... no)
  -- Actually: sNorm2(su) < sqr(u.t), and sNorm2(sv) ≤ sqr(v.t) (from h)
  -- So sNorm2(su) * sNorm2(sv) < sqr(u.t) * sqr(v.t) — contradicting h1
  -- But this only works if sNorm2(sv) > 0
  have hsvnn : sNorm2 (sComponent v) ≥ 0 := by
    unfold sNorm2; linarith [sqr_nonneg' (sComponent v).svalx,
      sqr_nonneg' (sComponent v).svaly, sqr_nonneg' (sComponent v).svalz]
  have hsunn : sNorm2 (sComponent u) ≥ 0 := by
    unfold sNorm2; linarith [sqr_nonneg' (sComponent u).svalx,
      sqr_nonneg' (sComponent u).svaly, sqr_nonneg' (sComponent u).svalz]
  by_cases hsv0 : sNorm2 (sComponent v) = 0
  · -- sNorm2(sv) = 0 means sv = sOrigin, so v.x = v.y = v.z = 0
    -- Then sqr(v.t) ≥ 0 from h, and sqr(sdot(su,sv)) ≤ 0, so sdot = 0
    -- Then u.t * v.t = 0, so v.t = 0 (since u.t ≠ 0)
    -- So v = origin, contradiction
    have : sdot (sComponent u) (sComponent v) = 0 := by
      have hsn := sqr_nonneg' (sdot (sComponent u) (sComponent v))
      rw [hsv0, mul_zero] at hcs
      unfold sqr at hcs; nlinarith
    rw [this] at hut_eq
    have hvt0 : v.tval = 0 := by
      rcases mul_eq_zero.mp hut_eq with h | h
      · exact absurd h hutnz
      · exact h
    have : v = origin := by
      ext <;> simp [origin]
      · exact hvt0
      all_goals {
        unfold sNorm2 sqr at hsv0
        have hx := mul_self_nonneg v.xval
        have hy := mul_self_nonneg v.yval
        have hz := mul_self_nonneg v.zval
        nlinarith
      }
    exact absurd this hnz
  · -- sNorm2(sv) > 0
    have hsv_pos : sNorm2 (sComponent v) > 0 := lt_of_le_of_ne hsvnn (Ne.symm hsv0)
    -- sNorm2(su) * sNorm2(sv) < sqr(u.t) * sNorm2(sv)
    have h2 : sNorm2 (sComponent u) * sNorm2 (sComponent v) <
        sqr u.tval * sNorm2 (sComponent v) := by
      exact mul_lt_mul_of_pos_right hsu_lt hsv_pos
    -- But also sqr(u.t) * sNorm2(sv) ≤ sqr(u.t) * sqr(v.t)
    have hsv_le : sNorm2 (sComponent v) ≤ sqr v.tval := by linarith
    have h3 : sqr u.tval * sNorm2 (sComponent v) ≤ sqr u.tval * sqr v.tval :=
      mul_le_mul_of_nonneg_left hsv_le (le_of_lt hut2_pos)
    -- So sqr(u.t) * sqr(v.t) ≤ sNorm2(su) * sNorm2(sv) < sqr(u.t) * sqr(v.t), contradiction
    linarith

theorem lemNormaliseTimelike (v : Point Q) (htl : timelike v)
    (s : Space Q) (hs : s = sComponent ((1 / v.tval) ⊗ v)) :
    (0 ≤ sNorm2 s ∧ sNorm2 s < 1) ∧ tComponent ((1 / v.tval) ⊗ v) = 1 := by
  have htnz : v.tval ≠ 0 := lemTimelikeNotZeroTime v htl
  constructor
  · constructor
    · unfold sNorm2; linarith [sqr_nonneg' s.svalx, sqr_nonneg' s.svaly, sqr_nonneg' s.svalz]
    · rw [hs]; simp only [sComponent, scaleBy, sNorm2, sqr]
      unfold timelike mNorm2 sNorm2 sComponent sqr at htl
      have htv_nz : v.tval ≠ 0 := htnz
      have htv2_pos : 0 < v.tval * v.tval := by
        rcases (mul_self_nonneg v.tval).lt_or_eq with h | h
        · exact h
        · exact absurd (mul_self_eq_zero.mp h.symm) htv_nz
      -- 1/t * x * (1/t * x) = x*x / (t*t)
      have : ∀ c : Q, 1 / v.tval * c * (1 / v.tval * c) = c * c / (v.tval * v.tval) := by
        intro c; field_simp
      rw [this v.xval, this v.yval, this v.zval]
      rw [show v.xval * v.xval / (v.tval * v.tval) + v.yval * v.yval / (v.tval * v.tval) +
          v.zval * v.zval / (v.tval * v.tval) =
          (v.xval * v.xval + v.yval * v.yval + v.zval * v.zval) / (v.tval * v.tval) from
        by field_simp]
      rw [div_lt_one htv2_pos]
      linarith
  · simp [tComponent, scaleBy]; field_simp

theorem lemReverseCauchySchwarz (X D : Point Q)
    (htl : timelike X ∧ timelike D) :
    sqr (mdot X D) ≥ mNorm2 X * mNorm2 D := by
  -- Expand everything to coordinate arithmetic
  simp only [mdot, mNorm2, sNorm2, sComponent, sdot, sqr]
  -- Cauchy-Schwarz: (sdot sX sD)² ≤ sNorm2(sX) * sNorm2(sD)
  have hcs := lemCauchySchwarzSqr (sComponent X) (sComponent D)
  simp only [sComponent, sNorm2, sdot, sqr] at hcs
  -- Timelike conditions
  have htlX := htl.1; have htlD := htl.2
  unfold timelike mNorm2 sNorm2 sComponent sqr at htlX htlD
  -- Use the identity: sqr(mdot) - mNorm2X * mNorm2D =
  -- (a²-sX²)·sD² + b²·sX² - 2ab·sdot + sdot²
  -- = (a²-sX²)·sD² + (b·sX² - sdot²·sX²/sX² ... )
  -- Alternative: directly show ≥ 0 using Cauchy-Schwarz + timelike
  set a := X.tval; set b := D.tval
  set p := X.xval; set q := D.xval
  set r := X.yval; set s := D.yval
  set u := X.zval; set w := D.zval
  set sX2 := p * p + r * r + u * u
  set sD2 := q * q + s * s + w * w
  set sdot_val := p * q + r * s + u * w
  -- From hcs: sdot_val * sdot_val ≤ sX2 * sD2
  have hcs' : sdot_val * sdot_val ≤ sX2 * sD2 := by
    simp only [sX2, sD2, sdot_val]; exact hcs
  -- From timelike
  have htlX' : a * a > sX2 := by simp only [a, sX2]; linarith
  have htlD' : b * b > sD2 := by simp only [b, sD2]; linarith
  -- Goal: (a * b - sdot_val)² ≥ (a² - sX2)(b² - sD2)
  -- i.e., (a*b - sdot_val)² - (a²-sX2)(b²-sD2) ≥ 0
  -- This equals: a²·sD2 + b²·sX2 - 2ab·sdot_val + sdot_val² - sX2·sD2
  -- = (a²-sX2)·sD2 + b²·sX2 - 2ab·sdot_val + sdot_val²
  -- = (a²-sX2)·sD2 + (b·√sX2 - sdot_val·...)²/... hmm
  -- Let's just show it's ≥ 0 by showing
  -- a²·sD2 + b²·sX2 - 2ab·sdot_val ≥ sX2·sD2 - sdot_val²
  -- LHS ≥ 2|ab|·√(sX2·sD2) - 2ab·sdot_val (by AM-GM on a²·sD2 + b²·sX2)
  -- ... this is still complex. Try nlinarith with explicit products of differences.
  -- Algebraic identity: LHS - RHS = sum of time-cross² - sum of spatial-cross²
  -- Time-crosses:
  have haq_bp := mul_self_nonneg (a * q - b * p)
  have has_br := mul_self_nonneg (a * s - b * r)
  have haw_bu := mul_self_nonneg (a * w - b * u)
  -- Spatial crosses (from Lagrange identity):
  have hps_rq := mul_self_nonneg (p * s - r * q)
  have hpw_uq := mul_self_nonneg (p * w - u * q)
  have hrw_us := mul_self_nonneg (r * w - u * s)
  -- Key identity: (ab-d)² - (a²-S)(b²-T) = (aq-bp)²+(as-br)²+(aw-bu)²-(ps-rq)²-(pw-uq)²-(rw-us)²
  -- And: (ps-rq)²+(pw-uq)²+(rw-us)² = S*T - d² (Lagrange)
  -- So: LHS - RHS = time_cross_sum - (S*T - d²)
  -- = time_cross_sum - S*T + d²
  -- We need: time_cross_sum ≥ S*T - d²
  -- Since d² ≤ S*T (Cauchy-Schwarz, i.e., hcs'), S*T - d² ≥ 0
  -- And time_cross_sum = a²T + b²S - 2abd
  -- We need: a²T + b²S - 2abd ≥ S*T - d²
  -- i.e., (a²-S)T + (b²-T)S + 2ST - 2abd ≥ S*T - d² — hmm
  -- Actually let's use: a²T + b²S - 2abd = (a²-S)T + S(b²-T) + 2ST - 2abd
  -- Since a² > S and b² > T, (a²-S) > 0 and (b²-T) > 0.
  -- Use Lagrange identity as a ring equality
  have hlagrange : (p * s - r * q) * (p * s - r * q) + (p * w - u * q) * (p * w - u * q) +
      (r * w - u * s) * (r * w - u * s) = sX2 * sD2 - sdot_val * sdot_val := by
    simp only [sX2, sD2, sdot_val]; ring
  -- Rewrite the goal
  have hgoal_id : (a * b - sdot_val) * (a * b - sdot_val) - (a * a - sX2) * (b * b - sD2) =
      (a * q - b * p) * (a * q - b * p) + (a * s - b * r) * (a * s - b * r) +
      (a * w - b * u) * (a * w - b * u) -
      ((p * s - r * q) * (p * s - r * q) + (p * w - u * q) * (p * w - u * q) +
       (r * w - u * s) * (r * w - u * s)) := by
    simp only [sX2, sD2, sdot_val]; ring
  -- So goal ≡ (a*b-d)² ≥ (a²-S)(b²-T), i.e., time_crosses ≥ spatial_crosses
  -- We need: (aq-bp)²+(as-br)²+(aw-bu)² ≥ (ps-rq)²+(pw-uq)²+(rw-us)²
  -- By Lagrange: spatial_crosses = ST - d²
  -- time_crosses = a²T + b²S - 2abd
  -- So need: a²T + b²S - 2abd ≥ ST - d²
  -- i.e., (a²-S)T + b²S - 2abd + d² ≥ 0 (using a²T = (a²-S)T + ST)
  -- Wait: (a²-S)T + S(b²-T) + 2(ST - abd) ≥ 0 ... hmm.
  -- Actually: a²T + b²S - 2abd - ST + d² = (a²-S)(T) + S(b²-T) + 2ST - 2abd + d² - ST
  -- = (a²-S)T + S(b²-T) + ST - 2abd + d²
  -- = (a²-S)T + S(b²-T) + (√S·√T - d)² + 2√S·√T·d - 2abd - S*T + d²  — needs sqrt
  -- OK I give up on manual. Let me try nlinarith with the identity.
  -- From hgoal_id: goal_diff = time_crosses - spatial_crosses
  -- From hlagrange + hcs': spatial_crosses = sX2*sD2 - sdot_val² ≥ 0
  -- Need: time_crosses ≥ spatial_crosses
  -- time_crosses = a²sD2 + b²sX2 - 2ab·sdot_val (expand squares)
  -- = (a²-sX2)·sD2 + sX2·sD2 + (b²-sD2)·sX2 + sD2·sX2 - 2sX2·sD2 - 2ab·sdot_val + 2sX2·sD2
  -- This is getting nowhere. Use nlinarith with products of differences.
  -- Key: (a²-sX2)*(b²-sD2) > 0 and (a²-sX2)*sD2² ≥ 0 etc.
  -- By the identities, it suffices to show:
  -- (aq-bp)² + (as-br)² + (aw-bu)² ≥ (ps-rq)² + (pw-uq)² + (rw-us)²
  -- i.e., a²sD2 + b²sX2 - 2ab·d ≥ sX2·sD2 - d² where d = sdot_val
  --
  -- Proof: by cases on whether sX2 = 0.
  by_cases hsX2 : sX2 = 0
  · -- sX2 = 0: the goal and all key identities involve sX2 which is 0
    -- Substitute sX2 = 0 into the ring identities
    rw [hsX2] at hgoal_id hlagrange hcs'
    -- hgoal_id now has sX2 replaced by 0 — simplify arithmetic
    -- Goal reduces to showing time_crosses ≥ spatial_crosses with sX2=0
    -- sdot_val² ≤ 0 * sD2 = 0, so sdot_val = 0
    have hd0 : sdot_val = 0 := by nlinarith [sqr_nonneg' sdot_val]
    rw [hd0] at hgoal_id
    -- hgoal_id: (a*b - 0)*(a*b-0) - (a*a - 0)*(b*b - sD2) = time_crosses - spatial_crosses
    -- = a²b² - a²b² + a²sD2 = a²sD2
    -- So we need a²sD2 ≥ 0 (already in hgoal_id = ... some expression)
    nlinarith [mul_self_nonneg a, mul_self_nonneg q, mul_self_nonneg s, mul_self_nonneg w,
               haq_bp, has_br, haw_bu, hps_rq, hpw_uq, hrw_us]
  · -- sX2 > 0
    have hsX2_pos : sX2 > 0 := by
      have : sX2 ≥ 0 := by nlinarith [mul_self_nonneg p, mul_self_nonneg r, mul_self_nonneg u]
      exact lt_of_le_of_ne this (Ne.symm hsX2)
    -- (a·d - b·sX2)² ≥ 0 gives a²d² + b²sX2² ≥ 2ab·sX2·d
    -- From hcs': d² ≤ sX2·sD2, so a²d² ≤ a²sX2·sD2
    -- Thus: a²sX2·sD2 + b²sX2² ≥ 2ab·sX2·d
    -- Dividing by sX2 > 0: a²sD2 + b²sX2 ≥ 2ab·d
    -- So: a²sD2 + b²sX2 - 2abd ≥ 0
    -- And we also need: a²sD2 + b²sX2 - 2abd ≥ sX2·sD2 - d²
    -- i.e., a²sD2 + b²sX2 - 2abd - sX2sD2 + d² ≥ 0
    -- = (a²-sX2)sD2 + b²sX2 - 2abd + d²
    -- = (a²-sX2)sD2 + (b·√sX2 - d/√sX2)²·sX2/sX2 — needs sqrt
    -- Instead: multiply out (a*d - b*sX2)² and use hcs' directly
    have had_bsX2 := mul_self_nonneg (a * sdot_val - b * sX2)
    -- a²d² + b²sX2² - 2ab·sX2·d ≥ 0
    -- From hcs': d² ≤ sX2·sD2, so (a²-sX2)·d² ≤ (a²-sX2)·sX2·sD2
    -- hmm, we need (a²-sX2)·sD2·sX2 ≥ (a²-sX2)·d² — yes since sX2·sD2 ≥ d²
    -- Then: a²·d² = (a²-sX2)d² + sX2·d²
    -- And: a²sX2sD2 = (a²-sX2)sX2sD2 + sX2²sD2
    -- From (a*d-b*sX2)²: a²d² + b²sX2² ≥ 2ab·sX2·d
    -- Multiply (a²-sX2) ≥ 0 by (sX2·sD2-d²) ≥ 0: (a²-sX2)(sX2sD2-d²) ≥ 0
    -- Expand: a²sX2sD2 - a²d² - sX2²sD2 + sX2d² ≥ 0
    have h_prod := mul_nonneg (by linarith : (0 : Q) ≤ a * a - sX2)
        (by nlinarith : (0 : Q) ≤ sX2 * sD2 - sdot_val * sdot_val)
    -- h_prod: (a²-sX2)(sX2·sD2-d²) ≥ 0
    -- Now combine: from hgoal_id + hlagrange:
    -- goal = (aq-bp)²+(as-br)²+(aw-bu)² - (sX2·sD2-d²) ≥ 0
    -- = a²sD2 + b²sX2 - 2abd - sX2sD2 + d²
    -- From had_bsX2: a²d² + b²sX2² ≥ 2ab·sX2·d
    -- From h_prod: a²sX2sD2 - a²d² ≥ sX2²sD2 - sX2d²
    -- Add: a²sX2sD2 + b²sX2² ≥ 2ab·sX2·d + sX2²sD2 - sX2d²
    -- i.e., sX2(a²sD2 + b²sX2) ≥ sX2(2abd + sX2sD2 - d²)
    -- Divide by sX2: a²sD2 + b²sX2 ≥ 2abd + sX2sD2 - d²
    -- i.e., a²sD2 + b²sX2 - 2abd - sX2sD2 + d² ≥ 0 ✓
    -- had_bsX2 + h_prod gives sX2 * (a²sD2 + b²sX2 - 2abd - sX2sD2 + d²) ≥ 0
    have hkey : sX2 * (a * a * sD2 + b * b * sX2 - 2 * a * b * sdot_val -
        sX2 * sD2 + sdot_val * sdot_val) ≥ 0 := by
      have : (a * sdot_val - b * sX2) * (a * sdot_val - b * sX2) +
          (a * a - sX2) * (sX2 * sD2 - sdot_val * sdot_val) =
          sX2 * (a * a * sD2 + b * b * sX2 - 2 * a * b * sdot_val -
          sX2 * sD2 + sdot_val * sdot_val) := by ring
      linarith [had_bsX2, h_prod]
    -- From hgoal_id + hlagrange: the main goal reduces to
    -- a²sD2 + b²sX2 - 2abd - sX2sD2 + d² ≥ 0
    -- Which follows from hkey and sX2 > 0
    have h_main : a * a * sD2 + b * b * sX2 - 2 * a * b * sdot_val -
        sX2 * sD2 + sdot_val * sdot_val ≥ 0 := by
      by_contra h; push_neg at h
      have : sX2 * (a * a * sD2 + b * b * sX2 - 2 * a * b * sdot_val -
          sX2 * sD2 + sdot_val * sdot_val) < 0 :=
        mul_neg_of_pos_of_neg hsX2_pos h
      linarith
    linarith [hgoal_id, hlagrange]

end NoFTL.ReverseCauchySchwarz
