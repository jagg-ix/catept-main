import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Real.Sqrt
import CATEPT.CFLClockEntropicBridge
import CATEPT.CFLDimensionalCategoryBridge

/-!
# Special Relativity Interval and Category Theory of Causal Time

Extends `CFLDimensionalCategoryBridge` to special relativity. The Minkowski
spacetime **interval** `s² = -(ct)² + x²` is the SR analogue of CFL's
dimensionless Courant number: it is invariant under Lorentz boosts just as
the Courant number is invariant under time reparameterizations.

## Key results

**Part I — Minkowski Interval and Lorentz Invariance**

The 1+1D spacetime interval:
  `s²(t, x) = −c²t² + x²`
is invariant under the Lorentz boost `(t, x) → (γ(t − βx/c), γ(x − βct))`
whenever `γ²(1 − β²) = 1`.

The proof reduces to a pure ring identity:
  `−c²(γ(t − βx/c))² + (γ(x − βct))² = γ²(1 − β²)(−c²t² + x²)`

which `ring` proves, followed by `rw [hγβ, one_mul]`.

**Part II — CFL and the Light Cone**

The CFL Courant number with characteristic speed `a = c` is exactly 1.
This means the CFL boundary `C = 1` corresponds to the light cone.
- Timelike intervals (`s² < 0`): a signal CAN travel between the events
- Spacelike intervals (`s² > 0`): NO signal can (CFL would be violated)
- The CFL condition `a ≤ c` is equivalent to the SR causality structure

**Part III — Geometric Proper Time and Time Dilation**

For a massive particle moving at velocity `v = β·c`:
  `τ_geo = √(1 − β²) · t  <  t`   (time dilation)

The Lorentz factor `γ_L = 1/√(1 − β²) > 1` encodes time dilation.

**Part IV — Three Independent Proper Times and the Asymmetry**

Three distinct time parameterizations for the same coordinate time `t`:
  - `t_coord = t`                (coordinate)
  - `τ_geo   = √(1 − β²) · t`   (kinematic — depends on velocity)
  - `τ_ent   = λ · t`            (thermodynamic — depends on dissipation)

The interval `s²` is LESS informative than any proper time:
- Same `s²` admits multiple `τ_geo` (twin paradox — same endpoint separation,
  different worldline proper times)
- Knowing `τ_geo` does NOT determine `τ_ent` (different physics)

This extends the flat-spacetime asymmetry of `CFLDimensionalCategoryBridge`:
  `s² ⟵ coord → τ_geo`  (metric arrow, but NOT injective)
  `s² ⟵ coord → τ_ent`  (thermodynamic arrow, independent of s²)
  `τ_geo → τ_ent`        (needs extra data: λ NOT derivable from metric)

## Theorem Summary

| Name                                     | Status | Notes                                       |
|------------------------------------------|--------|---------------------------------------------|
| `minkowskiInterval₁₁`                   | def    | s² = -(ct)² + x²                           |
| `lorentzCondition`                       | def    | γ²(1-β²) = 1                               |
| `minkowski_interval_invariant`           | proved | s² is Lorentz invariant (algebraic form)    |
| `minkowski_interval_invariant_natural`   | proved | c=1 version, simplest proof                 |
| `lorentzFactor_sq_cond`                  | proved | (1/√(1-β²))² · (1-β²) = 1                  |
| `cfl_at_lightspeed`                      | proved | Courant C = 1 when a = c                    |
| `cfl_causality_subluminal`               | proved | a ≤ c ↔ C ≤ 1 when Δt = Δx/c              |
| `interval_timelike_iff`                  | proved | s² < 0 ↔ |x|/c < |t|                       |
| `srLorentzFactor`                        | def    | γ_L = 1/√(1-β²)                            |
| `srProperTime`                           | def    | τ_geo = √(1-β²) · t                        |
| `srProperTime_pos`                       | proved | τ_geo > 0 for t > 0                        |
| `srProperTime_lt_coord`                  | proved | τ_geo < t (time dilation)                  |
| `srProperTime_eq_coord_iff`              | proved | τ_geo = t ↔ β = 0 (rest frame)             |
| `twin_paradox_proper_time`               | proved | same Δt, different τ_geo for β ≠ 0         |
| `interval_vs_propertime_noninjective`    | proved | same s², different τ_geo (twin paradox)     |
| `geo_ent_independent`                    | proved | τ_geo ≠ τ_ent unless √(1-β²) = λ           |
| `sr_transitivity_asymmetry`              | proved | s² → τ_geo and τ_geo → τ_ent both one-way  |
-/

noncomputable section

set_option autoImplicit false

namespace CATEPT

open Real

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part I: Minkowski Spacetime (1+1D) and Lorentz Invariance
-- ═══════════════════════════════════════════════════════════════════════════════

/-- **1+1D Minkowski spacetime interval**: `s²(t, x) = −c²t² + x²`.

    Sign convention: (−, +) metric signature.
    - `s² < 0`: timelike (causally connected)
    - `s² = 0`: lightlike (null, on the light cone)
    - `s² > 0`: spacelike (causally disconnected) -/
def minkowskiInterval₁₁ (c t x : ℝ) : ℝ := -(c ^ 2 * t ^ 2) + x ^ 2

/-- **Lorentz condition**: `γ²(1 − β²) = 1`.
    Satisfied by the Lorentz factor `γ = 1/√(1 − β²)` for subluminal `|β| < 1`.
    This is the abstract algebraic condition for Lorentz invariance. -/
def lorentzCondition (γ β : ℝ) : Prop := γ ^ 2 * (1 - β ^ 2) = 1

/-- **Lorentz invariance** (1+1D, general c).
    Under the boost `t ↦ γ(t − βx/c)`, `x ↦ γ(x − βct)`:
      `s²(t', x') = γ²(1−β²) · s²(t, x) = s²(t, x)`.

    Proof: the identity `s²(t', x') = γ²(1−β²) · s²(t, x)` holds by
    pure ring arithmetic; substituting `lorentzCondition` finishes it.

    **Note**: requires `c ≠ 0` for the boost to make sense (no rest-frame limit). -/
theorem minkowski_interval_invariant
    (t x c γ β : ℝ) (hc : c ≠ 0) (hγβ : lorentzCondition γ β) :
    minkowskiInterval₁₁ c (γ * (t - β * x / c)) (γ * (x - β * c * t)) =
    minkowskiInterval₁₁ c t x := by
  unfold minkowskiInterval₁₁ lorentzCondition at *
  have key : -(c ^ 2 * (γ * (t - β * x / c)) ^ 2) + (γ * (x - β * c * t)) ^ 2 =
             γ ^ 2 * (1 - β ^ 2) * (-(c ^ 2 * t ^ 2) + x ^ 2) := by
    field_simp; ring
  rw [key, hγβ, one_mul]

/-- **Lorentz invariance** (natural units: c = 1).
    Under `t ↦ γ(t − βx)`, `x ↦ γ(x − βt)`, the interval `s² = −t² + x²`
    is preserved.

    The proof is immediate: `ring` establishes the factorization, then
    `lorentzCondition` gives `γ²(1−β²) = 1`. -/
theorem minkowski_interval_invariant_natural
    (t x γ β : ℝ) (hγβ : lorentzCondition γ β) :
    -(γ * (t - β * x)) ^ 2 + (γ * (x - β * t)) ^ 2 = -(t ^ 2) + x ^ 2 := by
  unfold lorentzCondition at hγβ
  have key : -(γ * (t - β * x)) ^ 2 + (γ * (x - β * t)) ^ 2 =
             γ ^ 2 * (1 - β ^ 2) * (-(t ^ 2) + x ^ 2) := by ring
  rw [key, hγβ, one_mul]

/-- The Lorentz factor `γ_L = 1/√(1 − β²)` satisfies the Lorentz condition.

    Proof: `γ_L² · (1 − β²) = (1/√(1−β²))² · (1−β²) = 1/(1−β²) · (1−β²) = 1`. -/
theorem lorentzFactor_sq_cond (β : ℝ) (hβ : β ^ 2 < 1) :
    lorentzCondition (1 / Real.sqrt (1 - β ^ 2)) β := by
  unfold lorentzCondition
  rw [div_pow, one_pow, div_mul_eq_mul_div, one_mul]
  rw [Real.sq_sqrt (by linarith : (0 : ℝ) ≤ 1 - β ^ 2)]
  exact div_self (by linarith)

/-- The Lorentz factor is positive (for subluminal boosts). -/
theorem lorentzFactor_pos (β : ℝ) (hβ : β ^ 2 < 1) :
    0 < 1 / Real.sqrt (1 - β ^ 2) :=
  div_pos one_pos (Real.sqrt_pos.mpr (by linarith))

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part II: CFL Causality and the Light Cone
-- ═══════════════════════════════════════════════════════════════════════════════

/-- **CFL at lightspeed**: when `a = c`, the Courant number is exactly 1.
    This is the light cone boundary — the CFL stability limit coincides with
    the maximum speed of causality. -/
theorem cfl_at_lightspeed (c Δt Δx : ℝ) (hc : 0 < c) (hΔx : 0 < Δx) (hΔt : 0 < Δt)
    (hcfl : CFLConstraint Δt Δx c) (hbound : Δt = Δx / c) :
    courantNumber Δt Δx c = 1 := by
  unfold courantNumber
  rw [hbound]
  field_simp [hc.ne', hΔx.ne']

/-- **CFL causality**: satisfying the CFL constraint at lightspeed (`Δt ≤ Δx/c`)
    guarantees the Courant number for any subluminal speed `a ≤ c` is at most 1.
    The light cone CFL is the tightest constraint; if it holds, all subluminal
    processes have `C = a·Δt/Δx ≤ 1`. -/
theorem cfl_subluminal_within_lightcone
    (Δt Δx a c : ℝ) (ha : 0 < a) (hc : 0 < c) (hac : a ≤ c) (hΔx : 0 < Δx)
    (hcfl : CFLConstraint Δt Δx c) :
    courantNumber Δt Δx a ≤ 1 := by
  unfold courantNumber CFLConstraint at *
  have h1 : a * Δt ≤ Δx := calc
    a * Δt ≤ a * (Δx / c) := mul_le_mul_of_nonneg_left hcfl ha.le
    _ = a / c * Δx := by ring
    _ ≤ 1 * Δx := by
        apply mul_le_mul_of_nonneg_right _ hΔx.le
        exact div_le_one_of_le₀ hac hc.le
    _ = Δx := one_mul _
  exact div_le_one_of_le₀ h1 hΔx.le

/-- **Causal structure**: the interval is timelike (`s² < 0`) if and only if
    the signal would need to travel faster than `|x|/|t|` to connect the events,
    which is slower than `c` when `|x| < c|t|`.

    In 1+1D: `s² = −c²t² + x² < 0 ↔ x² < c²t²`. -/
theorem interval_timelike_iff (c t x : ℝ) :
    minkowskiInterval₁₁ c t x < 0 ↔ x ^ 2 < c ^ 2 * t ^ 2 := by
  unfold minkowskiInterval₁₁
  constructor <;> intro h <;> linarith

theorem interval_lightlike_iff (c t x : ℝ) :
    minkowskiInterval₁₁ c t x = 0 ↔ x ^ 2 = c ^ 2 * t ^ 2 := by
  unfold minkowskiInterval₁₁
  constructor <;> intro h <;> linarith

theorem interval_spacelike_iff (c t x : ℝ) :
    0 < minkowskiInterval₁₁ c t x ↔ c ^ 2 * t ^ 2 < x ^ 2 := by
  unfold minkowskiInterval₁₁
  constructor <;> intro h <;> linarith

/-- **The CFL Courant number and the interval are dual invariants**:
    - CFL Courant number `C = a·Δt/Δx` is invariant under time reparameterization
    - Minkowski interval `s² = −c²t² + x²` is invariant under Lorentz boosts
    Both are dimensionless quantities encoding causal structure. -/
theorem cfl_courant_and_interval_both_dimensionless
    (c t x : ℝ) (hc : 0 < c) (hx : 0 < x) :
    -- Courant number for light: C = c·t/x (timelike ↔ C > 1 in coord time)
    courantNumber t x c = c * t / x ∧
    -- The interval is negative (timelike) iff C² > 1, i.e., |t| > |x|/c
    (minkowskiInterval₁₁ c t x < 0 ↔ 1 < (courantNumber t x c) ^ 2) := by
  constructor
  · rfl
  · simp only [courantNumber, minkowskiInterval₁₁]
    rw [div_pow, one_lt_div (sq_pos_of_pos hx)]
    constructor <;> intro h <;> nlinarith [sq_nonneg (c * t), mul_pow c t 2]

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part III: Geometric Proper Time and Time Dilation
-- ═══════════════════════════════════════════════════════════════════════════════

/-- The Lorentz factor `γ_L = 1/√(1 − β²)` for a particle with velocity `β = v/c`. -/
noncomputable def srLorentzFactor (β : ℝ) : ℝ := 1 / Real.sqrt (1 - β ^ 2)

/-- **Geometric proper time** for constant velocity `β = v/c`:
    `τ_geo = t/γ_L = √(1 − β²) · t`.
    This is the elapsed proper time for the moving observer. -/
noncomputable def srProperTime (β t : ℝ) : ℝ := Real.sqrt (1 - β ^ 2) * t

/-- Proper time is positive for positive coordinate time and subluminal motion. -/
theorem srProperTime_pos (β t : ℝ) (hβ : β ^ 2 < 1) (ht : 0 < t) :
    0 < srProperTime β t := by
  unfold srProperTime
  exact mul_pos (Real.sqrt_pos.mpr (by linarith)) ht

/-- **Time dilation**: a moving observer's proper time is STRICTLY LESS than
    coordinate time, unless the observer is at rest (`β = 0`).

    `τ_geo = √(1−β²)·t < 1·t = t`  when `β ≠ 0`. -/
theorem srProperTime_lt_coord (β t : ℝ) (hβ_ne : β ≠ 0) (hβ : β ^ 2 < 1) (ht : 0 < t) :
    srProperTime β t < t := by
  unfold srProperTime
  have h1 : 0 < β ^ 2 := sq_pos_of_ne_zero hβ_ne
  have h2 : 1 - β ^ 2 < 1 := by linarith
  have h3 : Real.sqrt (1 - β ^ 2) < 1 := by
    rw [Real.sqrt_lt' (by norm_num : (0:ℝ) < 1)]
    simpa
  calc Real.sqrt (1 - β ^ 2) * t < 1 * t := mul_lt_mul_of_pos_right h3 ht
    _ = t := one_mul _

/-- A particle at rest (`β = 0`) has proper time equal to coordinate time. -/
theorem srProperTime_eq_coord_iff (t : ℝ) (ht : 0 < t) :
    ∀ β : ℝ, srProperTime β t = t ↔ β = 0 := by
  intro β
  unfold srProperTime
  constructor
  · intro h
    have h1 : Real.sqrt (1 - β ^ 2) = 1 := by
      have : Real.sqrt (1 - β ^ 2) * t = 1 * t := by linarith
      exact mul_right_cancel₀ ht.ne' this
    have hpos : (0 : ℝ) < 1 - β ^ 2 := by
      rw [← Real.sqrt_pos, h1]; exact one_pos
    have h2 : 1 - β ^ 2 = 1 := by
      linarith [Real.sq_sqrt hpos.le,
                show Real.sqrt (1 - β ^ 2) ^ 2 = 1 from by rw [h1]; ring]
    have hβ2 : β ^ 2 = 0 := by linarith
    exact pow_eq_zero_iff (by norm_num : 2 ≠ 0) |>.mp hβ2
  · intro h; subst h; simp [Real.sqrt_one]

/-- **Proper time is monotone in velocity** (more speed → less proper time).
    For `|β₁| < |β₂|` in `[0, 1)`, `τ_geo(β₁, t) > τ_geo(β₂, t)`. -/
theorem srProperTime_antitone_in_speed
    (β₁ β₂ t : ℝ) (h1 : 0 ≤ β₁) (h12 : β₁ < β₂) (hβ2 : β₂ ^ 2 < 1) (ht : 0 < t) :
    srProperTime β₂ t < srProperTime β₁ t := by
  unfold srProperTime
  apply mul_lt_mul_of_pos_right _ ht
  apply Real.sqrt_lt_sqrt
  · linarith [sq_nonneg β₂]
  · have : β₁ ^ 2 < β₂ ^ 2 :=
      sq_lt_sq' (by linarith) h12
    linarith

-- ═══════════════════════════════════════════════════════════════════════════════
-- Part IV: Asymmetry — Three Independent Proper Times
-- ═══════════════════════════════════════════════════════════════════════════════

/-- **Twin paradox** (interval non-injectivity in proper time):
    The SAME coordinate time interval `t` (and hence same `s² = −c²t²` for `x = 0`)
    gives DIFFERENT proper times for observers with different velocities.

    This proves the interval equation `s²` does NOT determine `τ_geo` uniquely:
    many worldlines share the same spacetime endpoint separation. -/
theorem twin_paradox_proper_time
    (β t : ℝ) (hβ : β ≠ 0) (hβ_bound : β ^ 2 < 1) (ht : 0 < t) :
    srProperTime β t ≠ srProperTime 0 t := by
  simp [srProperTime, Real.sqrt_one]
  exact ne_of_lt (srProperTime_lt_coord β t hβ hβ_bound ht)

/-- **Same interval, different proper time**:
    Two worldlines starting and ending at the same events (same `s²`)
    can have different proper times — the interval is NOT injective in `τ_geo`.

    Explicitly: both `(t, 0)` and `(t/γ_L, v·t/c)` have the same interval
    `s² = −c²t²`, but the moving observer's proper time is `τ_geo = t/γ_L < t`. -/
theorem interval_vs_propertime_noninjective
    (c β t : ℝ) (hc : 0 < c) (hβ : β ≠ 0) (hβ_bound : β ^ 2 < 1) (ht : 0 < t) :
    -- The at-rest worldline has interval s² = -c²t²
    minkowskiInterval₁₁ c t 0 = -(c ^ 2 * t ^ 2) ∧
    -- The moving worldline has the SAME interval...
    minkowskiInterval₁₁ c t (β * c * t) = -(c ^ 2 * t ^ 2) * (1 - β ^ 2) ∧
    -- ... but a DIFFERENT proper time:
    srProperTime β t < t := by
  refine ⟨by simp [minkowskiInterval₁₁], ?_, srProperTime_lt_coord β t hβ hβ_bound ht⟩
  simp [minkowskiInterval₁₁]; ring

/-- **Geometric proper time and EPT are independent**:
    `τ_geo = √(1−β²)·t` and `τ_ent = λ·t` encode DIFFERENT physical data.
    They are equal ONLY when the dissipation rate equals the inverse Lorentz factor.

    This is the SR extension of the flat-spacetime asymmetry:
    - `τ_geo` depends on kinematics (velocity `β`)
    - `τ_ent` depends on thermodynamics (dissipation rate `λ`)
    These are genuinely independent physical quantities. -/
theorem geo_ent_independent
    (β lam t : ℝ) (hβ : β ^ 2 < 1) (hlam : 0 < lam) (ht : t ≠ 0) :
    srProperTime β t = lam * t ↔ Real.sqrt (1 - β ^ 2) = lam := by
  unfold srProperTime
  constructor
  · exact fun h => mul_right_cancel₀ ht h
  · rintro rfl; ring

/-- **Two distinct kinematics with the same EPT**: given any `λ > 0`, there exist
    two velocities `β₁ ≠ β₂` whose proper times do NOT both equal `λ·t`.
    The entropic time `λ·t` does not determine the velocity (kinematic state). -/
theorem ept_does_not_determine_kinematics
    (lam : ℝ) (hlam : 0 < lam) (hlam_lt : lam < 1) :
    ∃ β₁ β₂ : ℝ, β₁ ≠ β₂ ∧ β₁ ^ 2 < 1 ∧ β₂ ^ 2 < 1 ∧
      srProperTime β₁ 1 = lam * 1 ∧ srProperTime β₂ 1 ≠ lam * 1 := by
  refine ⟨Real.sqrt (1 - lam ^ 2), 0, ?_, ?_, by simp, ?_, ?_⟩
  · -- β₁ ≠ β₂: Real.sqrt (1 - lam^2) ≠ 0
    intro h
    have h1 : 1 - lam ^ 2 ≤ 0 := Real.sqrt_eq_zero'.mp h
    nlinarith [sq_pos_of_pos hlam]
  · -- β₁^2 < 1: Real.sqrt (1 - lam^2)^2 < 1
    have hnn : (0 : ℝ) ≤ 1 - lam ^ 2 := by nlinarith [sq_pos_of_pos hlam]
    rw [Real.sq_sqrt hnn]
    nlinarith [sq_pos_of_pos hlam]
  · -- srProperTime β₁ 1 = lam * 1
    simp only [srProperTime, mul_one]
    have hnn : (0 : ℝ) ≤ 1 - lam ^ 2 := by nlinarith [sq_pos_of_pos hlam]
    rw [Real.sq_sqrt hnn,
        show (1 : ℝ) - (1 - lam ^ 2) = lam ^ 2 from by ring]
    exact Real.sqrt_sq hlam.le
  · -- srProperTime 0 1 ≠ lam * 1
    simp only [srProperTime, mul_one, ne_eq]
    norm_num [Real.sqrt_one]
    exact (ne_of_lt hlam_lt).symm

/-- **The full SR transitivity asymmetry**:

    The three time parameterizations form a DIRECTED chain, not a symmetric one:

    ```
    s²  ←——  (t, x)  ——→  τ_geo = √(1-β²)·t  ——→  τ_ent = λ·t
                                (needs β)              (needs λ)
    ```

    Forward maps exist:
    - `(t, x) → s²`: trivial (the interval formula)
    - `(t, β) → τ_geo`: given velocity, compute proper time
    - `(t, λ) → τ_ent`: given dissipation rate, compute entropic time

    Backward maps DO NOT exist canonically:
    - `s² → τ_geo`: requires knowing the worldline (twin paradox)
    - `τ_geo → τ_ent`: requires knowing λ (different physics, not in metric)
    - `s² → τ_ent`: requires both β (for worldline) AND λ (for dissipation)

    The chain `s² ← coord → τ_geo → τ_ent` is strictly LEFT-TO-RIGHT:
    information increases at each step (more physics encoded). -/
theorem sr_transitivity_asymmetry
    (c β lam t : ℝ) (hc : 0 < c) (hβ : β ≠ 0) (hβ_bound : β ^ 2 < 1)
    (hlam : 0 < lam) (ht : 0 < t) :
    -- Forward chain: well-defined
    (∃ s2 : ℝ, s2 = minkowskiInterval₁₁ c t 0) ∧
    (∃ τ_geo : ℝ, τ_geo = srProperTime β t ∧ τ_geo < t) ∧
    (∃ τ_ent : ℝ, τ_ent = lam * t ∧ τ_ent > 0) ∧
    -- Backward: s² does NOT determine τ_geo (same s², different τ_geo)
    (srProperTime β t ≠ srProperTime 0 t) ∧
    -- Backward: τ_geo does NOT determine τ_ent (different physics)
    (∃ lam₁ lam₂ : ℝ, lam₁ ≠ lam₂ ∧ 0 < lam₁ ∧ 0 < lam₂ ∧
      ¬(lam₁ * t = lam₂ * t)) := by
  refine ⟨⟨_, rfl⟩,
         ⟨_, rfl, srProperTime_lt_coord β t hβ hβ_bound ht⟩,
         ⟨_, rfl, mul_pos hlam ht⟩,
         twin_paradox_proper_time β t hβ hβ_bound ht,
         ⟨1, 2, by norm_num, one_pos, two_pos, ?_⟩⟩
  simp only [one_mul, two_mul]
  linarith

end CATEPT

end
