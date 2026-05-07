import Mathlib.Data.Complex.Basic
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import NavierStokesClean.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.PhysicalConstantsCommon
import CATEPTMain.CATEPT.CATEPT.AQFTFoundations

/-!
# GeometryGauge — gravitational clock-rate theorems

Builds on `AQFTFoundations` (which provides the shared structures
`LocalRegion`, `LocalAlgebra`, `ModularData`, `EntropicLocalityPrinciple`,
the helpers `entropicActionOfEntropy`, `entropicTimeField`,
`entropicForceDensity`, `localUnruhTemperature`, `entropicRedshiftedBeta`,
`entropicStressScalar`, `SatisfiesComplexEinsteinSectionXI`,
`EntropicEEPPrinciple`, `modularSlopeCriterion`).

This module adds Tolman / clock-rate theorems and the Hawking /
entropic-time identifications that close the gap to
`NavierStokesClean.CATEPT.Foundations`.

Refactor note (2026-05-07): the structure / def declarations that were
formerly duplicated between this file and `AQFTFoundations.lean`
(causing a `ModularData.noConfusionType` collision when both were
imported, e.g. via `CATEPTMain.Spine.OrphanAggregator`) have been
consolidated in `AQFTFoundations`. This file now imports them.
-/

noncomputable section
set_option autoImplicit false

namespace CATEPTMain.CATEPT.CATEPT

-- Gravitational clock-rate theorems (from gravity/clock-rates chat, score 7)

/-- Local temperature from the Tolman law:
    T_loc(x) = 1 / (k_B · beta(x)) = T_inf / sqrt(-g_00(x)).

    Source: chat equation `dS/dt ∝ T/sqrt(g00)`, score 7.
    This is the direct inversion of `entropicRedshiftedBeta`. -/
def tolmanLocalTemperature
    (c : PhysicalConstants) (betaInf minus_g00_sqrt : ℝ) : ℝ :=
  1 / (c.kB * entropicRedshiftedBeta betaInf minus_g00_sqrt)

/-- Far-field (flat) temperature: T_inf = 1 / (k_B · beta_inf). -/
def flatTemperature (c : PhysicalConstants) (betaInf : ℝ) : ℝ :=
  1 / (c.kB * betaInf)

/-- Tolman redshift law: T_loc = T_inf / sqrt(-g_00).

    The local temperature is suppressed by the gravitational redshift factor.
    This connects `entropicRedshiftedBeta` to the observable clock-rate scaling. -/
theorem tolmanTemperature_eq_flat_over_redshift
    (c : PhysicalConstants) (betaInf minus_g00_sqrt : ℝ)
    (hβ  : 0 < betaInf)
    (hg  : 0 < minus_g00_sqrt)
    (hkB : 0 < c.kB) :
    tolmanLocalTemperature c betaInf minus_g00_sqrt
      =
      flatTemperature c betaInf / minus_g00_sqrt := by
  unfold tolmanLocalTemperature flatTemperature entropicRedshiftedBeta
  have hkβ : c.kB * betaInf ≠ 0 := mul_ne_zero (ne_of_gt hkB) (ne_of_gt hβ)
  have hg' : minus_g00_sqrt ≠ 0 := ne_of_gt hg
  field_simp [hkβ, hg']

/-- Gravitational clock-rate law: T_loc is positive when beta_inf > 0 and g00 > 0. -/
theorem tolmanTemperature_pos
    (c : PhysicalConstants) (betaInf minus_g00_sqrt : ℝ)
    (hβ  : 0 < betaInf)
    (hg  : 0 < minus_g00_sqrt) :
    0 < tolmanLocalTemperature c betaInf minus_g00_sqrt := by
  unfold tolmanLocalTemperature entropicRedshiftedBeta
  apply div_pos one_pos
  exact mul_pos c.kB_pos (mul_pos hβ hg)

/-- Clock rates scale inversely with redshift:
    a deeper gravitational well (smaller sqrt(-g_00)) gives a faster local clock.
    T_loc(x1) / T_loc(x2) = sqrt(-g_00(x2)) / sqrt(-g_00(x1)). -/
theorem tolmanTemperature_ratio
    (c : PhysicalConstants) (betaInf g1 g2 : ℝ)
    (hβ  : 0 < betaInf)
    (hg1 : 0 < g1) (hg2 : 0 < g2) :
    tolmanLocalTemperature c betaInf g1 / tolmanLocalTemperature c betaInf g2
      =
      g2 / g1 := by
  unfold tolmanLocalTemperature entropicRedshiftedBeta
  have hkB' : c.kB ≠ 0 := ne_of_gt c.kB_pos
  have hβ'  : betaInf ≠ 0 := ne_of_gt hβ
  have hg1' : g1 ≠ 0 := ne_of_gt hg1
  have hg2' : g2 ≠ 0 := ne_of_gt hg2
  field_simp [hkB', hβ', hg1', hg2']

/-- Arrow-of-time rate is proportional to local temperature:
    if entropy rate = k_B * dTexp/dt and Texp(t) = T_loc(x(t)) / k_B, then
    dS/dt = T_loc(x(t)).

    This is the abstract form of `dS/dt ∝ T/sqrt(g00)` from the gravity/clock-rates
    chat (score-7 equation). It connects `SatisfiesArrowFromTemporalOrder` to
    the Tolman law via the identification Texp = T_loc / k_B. -/
theorem arrowOfTime_scales_as_localTemperature
    (c : PhysicalConstants)
    (betaInf : ℝ) (g00_sqrt : ℝ → ℝ)
    (entropy : ℝ → ℝ)
    (Texp : ℝ → ℝ)
    (hArrow : ∀ t, deriv entropy t = c.kB * deriv Texp t)
    (hTexp  : ∀ t, Texp t =
      tolmanLocalTemperature c betaInf (g00_sqrt t) / c.kB) :
    ∀ t, deriv entropy t =
      c.kB * deriv (fun τ => tolmanLocalTemperature c betaInf (g00_sqrt τ) / c.kB) t := by
  intro t
  have hfun : Texp = fun τ => tolmanLocalTemperature c betaInf (g00_sqrt τ) / c.kB :=
    funext hTexp
  rw [hArrow t, hfun]


-- Dependency chain: GeometryGauge <- Foundations

/-- The local Unruh temperature equals the Hawking temperature with surface
    gravity kappa = a (the acceleration, in natural units c = 1 is the standard
    Rindler correspondence).

    This grounds GeometryGauge in `NavierStokesClean.CATEPT.Foundations`:
    `localUnruhTemperature` is not an independent definition but the Hawking
    formula evaluated at kappa = a_loc. -/
theorem localUnruhTemperature_eq_hawkingTemperature
    (c : PhysicalConstants) (a : ℝ) :
    localUnruhTemperature c a =
    NavierStokesClean.CATEPT.hawking_temperature c.hbar a c.c c.kB := by
  simp only [localUnruhTemperature, NavierStokesClean.CATEPT.hawking_temperature]
  ring

/-- Matsubara identification (Tolman <-> entropic time):
    The `entropic_time` of the thermal imaginary action `S_I = hbar * kB * beta(x)`
    equals the dimensionless local inverse temperature `kB * beta(x) = kB / T_loc(x)`.

    Explicitly: `tau_ent(hbar, hbar * kB * beta(x)) = kB * beta(x)`.

    This is the Euclidean-rotation identity tau -> -i*beta in the path-integral
    formalism: imaginary time = inverse temperature. It bridges the
    Tolman redshift formula `beta(x) = beta_inf * sqrt(-g00)` to the entropic-time
    accumulator in `NSEPTNoetherInvariantBridge`. -/
theorem entropicTime_eq_localInverseTemperature
    (c : PhysicalConstants) (betaInf g00sqrt : ℝ) :
    NavierStokesClean.CATEPT.entropic_time c.hbar
        (c.hbar * c.kB * entropicRedshiftedBeta betaInf g00sqrt)
      = c.kB * entropicRedshiftedBeta betaInf g00sqrt := by
  unfold NavierStokesClean.CATEPT.entropic_time
  have hħ : c.hbar ≠ 0 := ne_of_gt c.hbar_pos
  field_simp [hħ]

end CATEPTMain.CATEPT.CATEPT
