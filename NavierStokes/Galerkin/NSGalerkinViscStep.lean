import NavierStokes.Galerkin.NSGalerkinConvectionBridge

/-!
# NSGalerkinViscStep — Implicit-Euler Viscous Step (Stage 189A lift)

Extracted from `NSGalerkinNSODETrajectory` (Stage 164) so that the viscous step can
be accessed by files that are **upstream** of `NSGalerkinNSODETrajectory` in the import
graph.  Specifically, `NSGalerkinConvStepHBridge` and `NSGalerkinSplittingLemmata`
(both of which are above `NSGalerkinNSODETrajectory` in Stage 189's new topology) need
`viscStep` and its basic energy-contraction lemmas.

## What is here (0 new axioms)

* `normSqC_div`              — `normSqC(z/d) = normSqC z / d²`
* `viscStep`                 — implicit Euler per mode: `u_i ↦ u_i / (1 + ν h |k_i|²)`
* `viscStep_denom_pos`       — denominator is positive when ν, h > 0
* `normSqC_viscStep`         — `normSqC (viscStep u i) = normSqC (u i) / denom²`
* `viscStep_energy_le_single`— pointwise contraction
* `viscStep_energy_le`       — global (summed) contraction

## Net counts

  - New defs:     1  (viscStep — moved from NSGalerkinNSODETrajectory)
  - New axioms:   0
  - New theorems: 5  (moved from NSGalerkinNSODETrajectory)
  - sorry:        0
  - warnings:     0
-/

namespace NavierStokes.GalerkinODE

set_option autoImplicit false

open NavierStokes.GalerkinComplexModel  -- CRat, CoeffC, normSqC, waveVecMag2
open NavierStokes.GalerkinConvection    -- GalerkinBasis

/-! ## CRat norm-squared lemma -/

/-- `normSqC (re/d, im/d) = normSqC (re, im) / d²`. -/
theorem normSqC_div (z : CRat) (d : Rat) :
    normSqC ((z.re / d, z.im / d)) = normSqC z / d ^ 2 := by
  simp only [normSqC, CRat.re, CRat.im]
  rw [div_pow, div_pow, ← add_div]

/-! ## Viscous step (implicit Euler per mode) -/

/-- Implicit Euler for the viscous term `-ν |k_i|² u_i` applied to mode `i`:
      `u_i^{n+1} = u_i^n / (1 + ν h |k_i|²)`
    componentwise in `CRat`.

    The denominator `1 + ν h |k_i|²` is always ≥ 1 when `ν, h > 0` and `|k_i|² ≥ 0`,
    so this map is **unconditionally contractive**: `|u_i^{n+1}| ≤ |u_i^n|`.
    No CFL condition needed. -/
def viscStep {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (u : CoeffC N) (i : Fin N) : CRat :=
  let denom := (1 : Rat) + ν * h * waveVecMag2 (basis.wvec i)
  ((u i).re / denom, (u i).im / denom)

/-- The implicit Euler denominator is strictly positive. -/
theorem viscStep_denom_pos {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (hν : 0 < ν) (hh : 0 < h) (i : Fin N) :
    (0 : Rat) < 1 + ν * h * waveVecMag2 (basis.wvec i) := by
  have hnn : 0 ≤ ν * h * waveVecMag2 (basis.wvec i) :=
    mul_nonneg (mul_pos hν hh).le (waveVecMag2_nonneg _)
  linarith

/-- The norm-squared of the viscous step equals `normSqC / denom²`. -/
theorem normSqC_viscStep {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (u : CoeffC N) (i : Fin N) :
    normSqC (viscStep basis ν h u i) =
    normSqC (u i) / (1 + ν * h * waveVecMag2 (basis.wvec i)) ^ 2 :=
  normSqC_div (u i) _

/-- **Viscous step is contractive** (pointwise): `normSqC (u_i^{n+1}) ≤ normSqC (u_i^n)`. -/
theorem viscStep_energy_le_single {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (hν : 0 < ν) (hh : 0 < h) (u : CoeffC N) (i : Fin N) :
    normSqC (viscStep basis ν h u i) ≤ normSqC (u i) := by
  rw [normSqC_viscStep basis ν h]
  have hdenom_ge1 : (1 : Rat) ≤ 1 + ν * h * waveVecMag2 (basis.wvec i) := by
    linarith [mul_nonneg (mul_pos hν hh).le (waveVecMag2_nonneg (basis.wvec i))]
  have hdenom2_ge1 : (1 : Rat) ≤ (1 + ν * h * waveVecMag2 (basis.wvec i)) ^ 2 := by
    nlinarith
  exact div_le_self (normSqC_nonneg _) hdenom2_ge1

/-- Viscous step is contractive (summed): `∑ normSqC u_i^{n+1} ≤ ∑ normSqC u_i^n`. -/
theorem viscStep_energy_le {N : Nat} (basis : GalerkinBasis N) (ν h : Rat)
    (hν : 0 < ν) (hh : 0 < h) (u : CoeffC N) :
    ∑ i : Fin N, normSqC (viscStep basis ν h u i) ≤
    ∑ i : Fin N, normSqC (u i) :=
  Finset.sum_le_sum (fun i _ => viscStep_energy_le_single basis ν h hν hh u i)

def stageViscStepSummary : String :=
  "NSGalerkinViscStep (Stage 189A lift): viscStep extracted from NSGalerkinNSODETrajectory. " ++
  "normSqC_div: THEOREM (algebra). " ++
  "viscStep: DEF (implicit Euler per mode). " ++
  "viscStep_denom_pos: THEOREM (linarith). " ++
  "normSqC_viscStep: THEOREM (normSqC_div). " ++
  "viscStep_energy_le_single: THEOREM (denom²≥1). " ++
  "viscStep_energy_le: THEOREM (sum_le_sum). " ++
  "Net: +0 axioms, +5 theorems, 0 sorry."

end NavierStokes.GalerkinODE
