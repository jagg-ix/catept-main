import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 044

Orbit/precession per-century conversion bridge.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G044

/-- Arcseconds of precession accumulated over one century. -/
def rowG044ArcsecPerCentury (arcsecPerOrbit orbitsPerCentury : ℝ) : ℝ :=
  arcsecPerOrbit * orbitsPerCentury

/-- Conversion from arcseconds to radians. -/
noncomputable def rowG044ArcsecToRad (arcsec : ℝ) : ℝ :=
  arcsec * (Real.pi / (180 * 3600))

/-- Century precession in radians. -/
noncomputable def rowG044RadPerCentury (arcsecPerOrbit orbitsPerCentury : ℝ) : ℝ :=
  rowG044ArcsecToRad (rowG044ArcsecPerCentury arcsecPerOrbit orbitsPerCentury)

/-- Linear scaling in number of orbits. -/
theorem rowG044_arcsec_linear_orbits
    (a n1 n2 : ℝ) :
    rowG044ArcsecPerCentury a (n1 + n2) =
      rowG044ArcsecPerCentury a n1 + rowG044ArcsecPerCentury a n2 := by
  unfold rowG044ArcsecPerCentury
  ring

/-- Nonnegative factors give nonnegative century precession (arcseconds). -/
theorem rowG044_arcsec_nonneg
    (a n : ℝ) (ha : 0 ≤ a) (hn : 0 ≤ n) :
    0 ≤ rowG044ArcsecPerCentury a n := by
  unfold rowG044ArcsecPerCentury
  nlinarith

/-- Nonnegative arcseconds yield nonnegative radians under standard conversion. -/
theorem rowG044_rad_nonneg_of_arcsec_nonneg
    (x : ℝ) (hx : 0 ≤ x) :
    0 ≤ rowG044ArcsecToRad x := by
  unfold rowG044ArcsecToRad
  have hfactor : 0 ≤ Real.pi / (180 * 3600) := by positivity
  nlinarith

/-- Bundle theorem for row-044 orbital conversion. -/
theorem rowG044_bundle
    (a n : ℝ) (ha : 0 ≤ a) (hn : 0 ≤ n) :
    0 ≤ rowG044ArcsecPerCentury a n ∧
      0 ≤ rowG044RadPerCentury a n := by
  have harc : 0 ≤ rowG044ArcsecPerCentury a n := rowG044_arcsec_nonneg a n ha hn
  have hrad : 0 ≤ rowG044RadPerCentury a n := by
    unfold rowG044RadPerCentury
    exact rowG044_rad_nonneg_of_arcsec_nonneg _ harc
  exact ⟨harc, hrad⟩

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G044

