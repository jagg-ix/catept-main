import NavierStokesClean.CATEPT.GRTensorKernel
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

/-!
# CAT/EPT GR: FLRW Cosmological Metric (WP-GR-FLRW-01)

Phase B of the multi-tool → IR → Lean pipeline.

Formalizes the Friedmann-Lemaître-Robertson-Walker (FLRW) metric for flat
spatial sections (k=0):

  ds² = −dt² + a(t)² (dx² + dy² + dz²)

using `MetricField (Fin 4)` from `GRTensorKernel`, with coordinates
`(t, x, y, z) = (cv 0, cv 1, cv 2, cv 3)`.

## Main results (0 axioms, 0 sorry)

- `flrwMetric_tt`: g_tt = −1
- `flrwMetric_spatial`: g_ii = a(t)² for spatial i ∈ {1,2,3}
- `flrwMetric_offdiag_zero`: g_ij = 0 for i ≠ j
- `flrwMetric_const_is_constant`: constant scale factor → MetricComponentConst
- `flrwMetric_const_einsteinTensor_zero`: constant a → G_ab = 0 (flat static)
- `FriedmannSolution`: predicate: H² = 8πGρ/3
- `friedmann_const_vacuum`: a = const, ρ = 0 solves Friedmann (Minkowski limit)
- `hubbleParam_const_eq_zero`: constant a has zero Hubble parameter

## Zero axioms, zero sorry.
-/

set_option autoImplicit false

open Real

namespace NavierStokesClean.CATEPT

noncomputable section

/-! ## §1. FLRW metric definition -/

/-- FLRW metric with flat spatial sections and scale factor `a : ℝ → ℝ`.

    Coordinates: `(t, x, y, z) = (cv 0, cv 1, cv 2, cv 3)`.
      g_tt = −1,   g_ii = a(t)² (i = 1,2,3),   g_ij = 0 (i ≠ j) -/
def flrwMetric (a : ℝ → ℝ) : MetricField (Fin 4) :=
  fun cv i j =>
    if i ≠ j then (0 : ℝ)
    else if i = (0 : Fin 4) then (-1 : ℝ)
    else a (cv 0) ^ 2

/-! ## §2. Component theorems -/

/-- Time-time component: g_tt = −1. -/
theorem flrwMetric_tt (a : ℝ → ℝ) (cv : CoordVec (Fin 4)) :
    flrwMetric a cv 0 0 = -1 := by
  unfold flrwMetric
  simp

/-- Spatial diagonal component: g_ii = a(t)² for i ≠ 0. -/
theorem flrwMetric_spatial (a : ℝ → ℝ) (cv : CoordVec (Fin 4)) (i : Fin 4)
    (hi : i ≠ 0) :
    flrwMetric a cv i i = a (cv 0) ^ 2 := by
  unfold flrwMetric
  simp [hi]

/-- Off-diagonal components vanish. -/
theorem flrwMetric_offdiag_zero (a : ℝ → ℝ) (cv : CoordVec (Fin 4))
    (i j : Fin 4) (hij : i ≠ j) :
    flrwMetric a cv i j = 0 := by
  unfold flrwMetric
  simp [hij]

/-- FLRW metric is symmetric. -/
theorem flrwMetric_symm (a : ℝ → ℝ) (cv : CoordVec (Fin 4)) (i j : Fin 4) :
    flrwMetric a cv i j = flrwMetric a cv j i := by
  unfold flrwMetric
  by_cases hij : i = j
  · subst hij; rfl
  · have hji : j ≠ i := Ne.symm hij
    simp [hij, hji]

/-! ## §3. Constant scale factor: MetricComponentConst -/

/-- A constant scale factor `a = fun _ => c` makes the FLRW metric componentwise constant.

    This is the flat static spacetime limit: no expansion, each component
    is a global constant. -/
theorem flrwMetric_const_is_constant (c : ℝ) :
    MetricComponentConst (flrwMetric (fun _ => c)) := by
  intro i j
  by_cases hij : i = j
  · subst hij
    by_cases hi0 : i = 0
    · subst hi0
      exact ⟨-1, fun cv => flrwMetric_tt (fun _ => c) cv⟩
    · exact ⟨c ^ 2, fun cv => by
        simpa using flrwMetric_spatial (fun _ => c) cv i hi0⟩
  · exact ⟨0, fun cv => flrwMetric_offdiag_zero (fun _ => c) cv i j hij⟩

/-- Einstein tensor vanishes for constant FLRW (flat static spacetime).

    Physical content: no expansion, no matter, G_ab = 0. -/
theorem flrwMetric_const_einsteinTensor_zero (c : ℝ) :
    ∀ (cv : CoordVec (Fin 4)) (i j : Fin 4),
      einsteinTensor (flrwMetric (fun _ => c)) cv i j = 0 :=
  einsteinTensor_eq_zero_of_metricComponentConst (flrwMetric_const_is_constant c)

/-! ## §4. Hubble parameter -/

/-- Hubble parameter H(t) = ȧ(t)/a(t). -/
def hubbleParam (a : ℝ → ℝ) (t : ℝ) : ℝ :=
  deriv a t / a t

/-- For constant scale factor, Hubble parameter vanishes. -/
theorem hubbleParam_const_eq_zero (c : ℝ) (t : ℝ) :
    hubbleParam (fun _ => c) t = 0 := by
  simp [hubbleParam, (hasDerivAt_const t c).deriv]

/-! ## §5. Friedmann equation predicate -/

/-- The Friedmann solution predicate for flat sections:
      (ȧ)² = 8πGρ a² / 3   (i.e. H² = 8πGρ/3)

    - `hPositive`: scale factor is everywhere positive
    - `hFriedmann`: the Friedmann constraint at each time -/
structure FriedmannSolution (a : ℝ → ℝ) (ρ : ℝ → ℝ) (G : ℝ) : Prop where
  hPositive : ∀ t : ℝ, 0 < a t
  hFriedmann : ∀ t : ℝ, (deriv a t) ^ 2 = 8 * Real.pi * G * ρ t * (a t) ^ 2 / 3

/-- Constant scale factor with zero energy density solves the Friedmann equation.

    Minkowski limit: no expansion, no matter, ȧ = 0, H = 0. -/
theorem friedmann_const_vacuum (c : ℝ) (hc : 0 < c) (G : ℝ) :
    FriedmannSolution (fun _ => c) (fun _ => 0) G where
  hPositive := fun _ => hc
  hFriedmann := fun t => by
    have hd : deriv (fun _ : ℝ => c) t = 0 := (hasDerivAt_const t c).deriv
    rw [hd]; ring

end

end NavierStokesClean.CATEPT
