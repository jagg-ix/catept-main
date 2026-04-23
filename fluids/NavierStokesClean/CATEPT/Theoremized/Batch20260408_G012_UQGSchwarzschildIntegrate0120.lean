import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 012

Schwarzschild-style integration bridge with compile-safe invariants.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G012

/-- Dimensionless Schwarzschild factor `1 - 2M/r`. -/
noncomputable def rowG012SchwarzschildFactor (M r : ℝ) : ℝ :=
  1 - (2 * M) / r

/-- Redshift / lapse proxy `sqrt(1 - 2M/r)`. -/
noncomputable def rowG012RedshiftFactor (M r : ℝ) : ℝ :=
  Real.sqrt (rowG012SchwarzschildFactor M r)

/-- For positive mass and radius, `1 - 2M/r < 1`. -/
theorem rowG012_factor_lt_one (M r : ℝ) (hM : 0 < M) (hr : 0 < r) :
    rowG012SchwarzschildFactor M r < 1 := by
  unfold rowG012SchwarzschildFactor
  have hdivPos : 0 < (2 * M) / r := by positivity
  linarith

/-- Outside `r > 2M`, the Schwarzschild factor is positive. -/
theorem rowG012_factor_pos_of_subcritical (M r : ℝ) (hr : 0 < r) (hsub : 2 * M < r) :
    0 < rowG012SchwarzschildFactor M r := by
  unfold rowG012SchwarzschildFactor
  have hdiv : (2 * M) / r < 1 := by
    exact (div_lt_iff₀ hr).2 (by simpa [one_mul] using hsub)
  linarith

/-- Redshift factor is always nonnegative whenever the factor is nonnegative. -/
theorem rowG012_redshift_nonneg (M r : ℝ) :
    0 ≤ rowG012RedshiftFactor M r := by
  unfold rowG012RedshiftFactor
  exact Real.sqrt_nonneg _

/-- If `0 ≤ factor ≤ 1`, then the redshift factor is bounded by `1`. -/
theorem rowG012_redshift_le_one (M r : ℝ)
    (h1 : rowG012SchwarzschildFactor M r ≤ 1) :
    rowG012RedshiftFactor M r ≤ 1 := by
  unfold rowG012RedshiftFactor
  refine (Real.sqrt_le_iff).2 ?_
  constructor
  · positivity
  · simpa using h1

/-- Bundle theorem for subcritical Schwarzschild regime. -/
theorem rowG012_bundle (M r : ℝ) (hM : 0 < M) (hr : 0 < r) (hsub : 2 * M < r) :
    rowG012SchwarzschildFactor M r < 1 ∧
      0 < rowG012SchwarzschildFactor M r ∧
      0 ≤ rowG012RedshiftFactor M r ∧
      rowG012RedshiftFactor M r ≤ 1 := by
  have hlt : rowG012SchwarzschildFactor M r < 1 :=
    rowG012_factor_lt_one M r hM hr
  have hpos : 0 < rowG012SchwarzschildFactor M r :=
    rowG012_factor_pos_of_subcritical M r hr hsub
  have hnonneg : 0 ≤ rowG012RedshiftFactor M r :=
    rowG012_redshift_nonneg M r
  have hle : rowG012RedshiftFactor M r ≤ 1 :=
    rowG012_redshift_le_one M r (le_of_lt hlt)
  exact ⟨hlt, hpos, hnonneg, hle⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G012
