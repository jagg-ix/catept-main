import NavierStokesClean.CATEPT.QuantumGravity
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-!
# CAT/EPT GR: Kerr Rotating Black Hole (WP-GR-KERR-01)

Phase B of the multi-tool → IR → Lean pipeline.

Formalizes the Kerr metric in Boyer-Lindquist coordinates using the
structural functions:

  kerrSig(a, r, θ) = r² + a² cos²θ    (frame-dragging denominator, "Σ")
  kerrDelta(M, a, r) = r² − 2Mr + a²  (horizon polynomial, "Δ")

and the horizons:

  r± = M ± √(M² − a²)

Note: `kerrSig` replaces the mathematical symbol Σ to avoid conflict with
Lean4's `Σ` sigma-type former. `kerrDelta` uses `Δ`, which is safe.

## Main results (0 axioms, 0 sorry)

### Structural functions
- `kerrSig`, `kerrDelta`, `kerrOuterHorizon`, `kerrInnerHorizon`

### Algebraic theorems
- `kerrDelta_horizon_root`: Δ(r₊) = 0 when M² ≥ a²
- `kerrDelta_innerHorizon_root`: Δ(r₋) = 0
- `kerrDelta_positive_outside`: r > r₊ → Δ > 0
- `kerrDelta_reducesToSchwarzschild`: a = 0 → Δ(r) = r(r − 2M)
- `kerrDelta_div_r2_eq_schwarzschildF`: a = 0 → Δ/r² = f(r)

### Horizons
- `kerrOuterHorizon_zero_spin`: r₊(a=0) = 2M (Schwarzschild radius)
- `kerrHorizons_coincide_extremal`: r₊ = r₋ = M when |a| = M (extremal BH)
- `kerrHorizon_gap`: r₊ − r₋ = 2√(M²−a²)

### Positivity of Σ
- `kerrSig_nonneg`: Σ ≥ 0
- `kerrSig_pos_of_r_pos`: r > 0 → Σ > 0
- `kerrSig_pos_of_r_ne_zero`: r ≠ 0 → Σ > 0
- `kerrSig_pos_of_a_cos_nonzero`: a ≠ 0 ∧ cos θ ≠ 0 → Σ > 0

## Zero axioms, zero sorry.
-/

set_option autoImplicit false

open Real

namespace NavierStokesClean.CATEPT

noncomputable section

/-! ## §1. Kerr structural functions -/

/-- kerrSig(a, r, θ) = r² + a² cos²θ — the Kerr frame-dragging denominator Σ.

    Σ = 0 iff r = 0 and cos θ = 0 (ring singularity at r=0, θ=π/2). -/
def kerrSig (a r θ : ℝ) : ℝ := r ^ 2 + a ^ 2 * Real.cos θ ^ 2

/-- kerrDelta(M, a, r) = r² − 2Mr + a² — the Kerr horizon polynomial Δ.

    Δ = 0 has roots r± = M ± √(M²−a²) when |a| ≤ M. -/
def kerrDelta (M a r : ℝ) : ℝ := r ^ 2 - 2 * M * r + a ^ 2

/-- Outer (event) horizon: r₊ = M + √(M²−a²). -/
def kerrOuterHorizon (M a : ℝ) : ℝ := M + Real.sqrt (M ^ 2 - a ^ 2)

/-- Inner (Cauchy) horizon: r₋ = M − √(M²−a²). -/
def kerrInnerHorizon (M a : ℝ) : ℝ := M - Real.sqrt (M ^ 2 - a ^ 2)

/-! ## §2. Horizon root theorems -/

/-- Outer horizon is a root of Δ when M² ≥ a² (black hole regime). -/
theorem kerrDelta_horizon_root (M a : ℝ) (h : a ^ 2 ≤ M ^ 2) :
    kerrDelta M a (kerrOuterHorizon M a) = 0 := by
  unfold kerrDelta kerrOuterHorizon
  set s := Real.sqrt (M ^ 2 - a ^ 2)
  have hs2 : s ^ 2 = M ^ 2 - a ^ 2 := Real.sq_sqrt (by linarith)
  nlinarith [hs2, Real.sqrt_nonneg (M ^ 2 - a ^ 2)]

/-- Inner horizon is also a root of Δ. -/
theorem kerrDelta_innerHorizon_root (M a : ℝ) (h : a ^ 2 ≤ M ^ 2) :
    kerrDelta M a (kerrInnerHorizon M a) = 0 := by
  unfold kerrDelta kerrInnerHorizon
  set s := Real.sqrt (M ^ 2 - a ^ 2)
  have hs2 : s ^ 2 = M ^ 2 - a ^ 2 := Real.sq_sqrt (by linarith)
  nlinarith [hs2, Real.sqrt_nonneg (M ^ 2 - a ^ 2)]

/-- Δ > 0 in the exterior region r > r₊. -/
theorem kerrDelta_positive_outside (M a r : ℝ) (h : a ^ 2 ≤ M ^ 2)
    (hr : kerrOuterHorizon M a < r) :
    0 < kerrDelta M a r := by
  unfold kerrDelta kerrOuterHorizon at *
  set s := Real.sqrt (M ^ 2 - a ^ 2)
  have hs_nn : 0 ≤ s := Real.sqrt_nonneg _
  have hs2 : s ^ 2 = M ^ 2 - a ^ 2 := Real.sq_sqrt (by linarith)
  have hrMs : 0 < r - M - s := by linarith
  have hrMps : 0 < r - M + s := by linarith
  have hprod : (r - M - s) * (r - M + s) = r ^ 2 - 2 * M * r + a ^ 2 := by nlinarith [hs2]
  linarith [mul_pos hrMs hrMps]

/-! ## §3. Reduction to Schwarzschild -/

/-- Setting a = 0 reduces Δ to r(r − 2M). -/
theorem kerrDelta_reducesToSchwarzschild (M r : ℝ) :
    kerrDelta M 0 r = r * (r - 2 * M) := by
  unfold kerrDelta; ring

/-- Δ/r² = schwarzschild_f when a = 0, r ≠ 0. -/
theorem kerrDelta_div_r2_eq_schwarzschildF (M r : ℝ) (hr : r ≠ 0) :
    kerrDelta M 0 r / r ^ 2 = schwarzschild_f M r := by
  unfold kerrDelta schwarzschild_f
  field_simp
  ring

/-- The outer horizon at a = 0 equals the Schwarzschild radius 2M. -/
theorem kerrOuterHorizon_zero_spin (M : ℝ) (hM : 0 < M) :
    kerrOuterHorizon M 0 = 2 * M := by
  unfold kerrOuterHorizon
  simp only [ne_eq, OfNat.ofNat_ne_zero, not_false_eq_true, zero_pow, sub_zero]
  rw [Real.sqrt_sq (le_of_lt hM)]
  ring

/-! ## §4. Positivity of Σ -/

/-- Σ = r² + a² cos²θ ≥ 0. -/
theorem kerrSig_nonneg (a r θ : ℝ) : 0 ≤ kerrSig a r θ := by
  unfold kerrSig; positivity

/-- Σ > 0 when r > 0. -/
theorem kerrSig_pos_of_r_pos (a r θ : ℝ) (hr : 0 < r) :
    0 < kerrSig a r θ := by
  unfold kerrSig
  have hr2 : 0 < r ^ 2 := sq_pos_of_pos hr
  have h2 : 0 ≤ a ^ 2 * Real.cos θ ^ 2 := by positivity
  linarith

/-- Σ > 0 when r ≠ 0 (covers both r > 0 and r < 0). -/
theorem kerrSig_pos_of_r_ne_zero (a r θ : ℝ) (hr : r ≠ 0) :
    0 < kerrSig a r θ := by
  unfold kerrSig
  have hr2 : 0 < r ^ 2 := by
    rcases lt_or_gt_of_ne hr with h | h
    · exact sq_pos_of_neg h
    · exact sq_pos_of_pos h
  have h2 : 0 ≤ a ^ 2 * Real.cos θ ^ 2 := by positivity
  linarith

/-- Σ > 0 when a ≠ 0 and cos θ ≠ 0. -/
theorem kerrSig_pos_of_a_cos_nonzero (a r θ : ℝ) (ha : a ≠ 0) (hθ : Real.cos θ ≠ 0) :
    0 < kerrSig a r θ := by
  unfold kerrSig
  have h1 : 0 ≤ r ^ 2 := sq_nonneg r
  have ha2 : 0 < a ^ 2 := by positivity
  have hc2 : 0 < Real.cos θ ^ 2 := by positivity
  linarith [mul_pos ha2 hc2]

/-! ## §5. Extremal and horizon gap -/

/-- Extremal Kerr (|a| = M): both horizons coincide at r = M. -/
theorem kerrHorizons_coincide_extremal (M : ℝ) (hM : 0 < M) :
    kerrOuterHorizon M M = M ∧ kerrInnerHorizon M M = M := by
  have hsqrt0 : Real.sqrt (M ^ 2 - M ^ 2) = 0 := by
    rw [sub_self]; exact Real.sqrt_zero
  exact ⟨by unfold kerrOuterHorizon; rw [hsqrt0]; ring,
         by unfold kerrInnerHorizon; rw [hsqrt0]; ring⟩

/-- Horizon gap: r₊ − r₋ = 2√(M²−a²). -/
theorem kerrHorizon_gap (M a : ℝ) :
    kerrOuterHorizon M a - kerrInnerHorizon M a = 2 * Real.sqrt (M ^ 2 - a ^ 2) := by
  unfold kerrOuterHorizon kerrInnerHorizon; ring

end

end NavierStokesClean.CATEPT
