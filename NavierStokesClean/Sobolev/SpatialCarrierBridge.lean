import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.InnerProductSpace.l2Space
import Mathlib.MeasureTheory.Integral.IntervalIntegral.Basic
import NavierStokesClean.Sobolev.HasDerivAtGalerkin
import NavierStokesClean.Galerkin.ODEHalfHolderBridge

/-!
# Phase 5D Spatial Carrier Bridge

This file provides the interface scaffold connecting the Phase 5D Galerkin energy
identity framework to the Simon Lemma 5 ½-Hölder bound in
`NavierStokesClean.Galerkin.ODEHalfHolderBridge`.

## Mathematical content

The Simon Lemma 5 in `GalerkinVelocityDerivative` is blocked on:
  - `HasDerivAt traj u' t` (the time derivative of the Galerkin trajectory)
  - `∫_s^t ‖u'(r)‖² ≤ K²` (L² bound on the time derivative)

Both follow from the NS energy identity:
```
d/dt E_N(t) = -2ν · ∑_{k ∈ Λ_N} |k|² |û_k(t)|² ≤ 0
```
and the projected NS ODE (Galerkin system):
```
d/dt P_N u(t) = P_N(νΔu(t)) + P_N(convection)
```
The H^{-1} derivative bound `‖∂_t u_N‖_{H^{-1}} ≤ ν‖∇u_N‖ + ‖u_N‖·‖∇u_N‖`
together with Cauchy-Schwarz + the H¹ energy bound gives:
```
∫₀ᵀ ‖∂_t u_N(r)‖² dr ≤ C₀²/(2ν)
```

## Contents

- `GalerkinL2PathHyps`: hypothesis bundle extending `GalerkinTrajectoryHyps`
  with the NS-ODE time-derivative bound.
- `galerkin_path_hasDerivAt`: abstract `HasDerivAt` for the L²(T³) trajectory
  (sorry'd — pending AFP ODE port).
- `galerkin_deriv_l2_bound`: L² bound on the time derivative
  (sorry'd — from NS energy identity + H^{-1} duality).
- `galerkin_holder_from_l2_bound`: chains to `ODEHalfHolderBridge.half_holder_from_l2_deriv_bound`.

## Sorry status

- `galerkin_path_hasDerivAt`: deferred to `afp_leverage_ode_galerkin_equicont_20260408`
  (Galerkin ODE smoothness from AFP ODE port).
- `galerkin_deriv_l2_bound`: deferred to Phase 5D+E (NS energy identity integration
  + H^{-1} duality for the projected Stokes operator).
-/

set_option autoImplicit false

private noncomputable instance factPeriodOneSCB : Fact (0 < (1 : ℝ)) := ⟨one_pos⟩

noncomputable local instance : MeasureTheory.MeasureSpace UnitAddCircle :=
  ⟨AddCircle.haarAddCircle⟩

namespace NavierStokesClean.Sobolev.SpatialCarrierBridge

open MeasureTheory
open UnitAddTorus
open scoped BigOperators ENNReal NNReal

local notation "L²(" α ")" => Lp ℂ 2 (volume : Measure α)

open NavierStokesClean.Sobolev.EnergyIdentityT3
open NavierStokesClean.Sobolev.SpectralProjectionT3
open NavierStokesClean.Sobolev.HasDerivAtGalerkin

/-! ## §1. Galerkin L² path hypothesis bundle -/

/-- Hypothesis bundle for a Galerkin trajectory `u : ℝ → L²(T³)` with
    NS-ODE time-derivative control.

    This extends `GalerkinTrajectoryHyps` with:
    - `path_differentiable`: `HasDerivAt u (u' t) t` for every `t`
    - `deriv_l2_bound`: `∫_s^t ‖u'(r)‖² dr ≤ (C₀/√(2ν))²` uniformly on `[0,T]`

    The `deriv_l2_bound` encodes the Simon–Temam energy dissipation estimate:
    from the Galerkin ODE + NS H¹ bound + H^{-1} duality. -/
structure GalerkinL2PathHyps
    (ν : ℝ) (N : ℕ) (C₀ : ℝ)
    (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3))) : Prop where
  /-- Viscosity is positive. -/
  nu_pos : 0 < ν
  /-- Initial L² norm bound. -/
  init_bound : ‖u 0‖ ≤ C₀
  /-- The path has derivative `u' t` at every `t`. -/
  path_differentiable : ∀ t : ℝ, HasDerivAt u (u' t) t
  /-- L² derivative bound on every subinterval of `[0, T]`. -/
  deriv_l2_bound : ∀ T : ℝ, 0 < T → ∀ s t : ℝ,
    s ∈ Set.Icc 0 T → t ∈ Set.Icc 0 T → s ≤ t →
    IntervalIntegrable (fun r => ‖u' r‖^2) volume s t ∧
    IntervalIntegrable (u') volume s t ∧
    ∫ r in s..t, ‖u' r‖^2 ≤ (C₀ / Real.sqrt (2 * ν))^2

/-! ## §2. Sorry-bridged path lemmas -/

/-- **Phase 5D bridge** (sorry): a Galerkin trajectory satisfying the projected NS ODE
    has a `HasDerivAt` at every time.

    **Discharge route**: `afp_leverage_ode_galerkin_equicont_20260408` — AFP port of
    `Ordinary_Differential_Equations` Peano existence theorem gives C¹ regularity
    for finite-dimensional Galerkin ODE. -/
theorem galerkin_path_hasDerivAt
    (ν : ℝ) (N : ℕ) (C₀ : ℝ)
    (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3)))
    (hNS : ∀ t, phase5dEnergyIdentityStatement ν N u t) :
    ∀ t : ℝ, HasDerivAt u (u' t) t := by
  sorry -- Discharge: AFP ODE port — C¹ regularity of Galerkin ODE

/-- **NS energy bridge** (sorry): the L² derivative bound holds from the NS energy identity
    and H^{-1} duality.

    **Discharge route**: Phase 5D+E — integrate the energy identity
    `-2ν · projectedGradientTerm N (u t)` over time, apply Simon's H^{-1} duality
    `‖∂_t u_N‖_{H^{-1}} ≤ ν‖∇u_N‖ + ‖u_N‖·‖∇u_N‖`, Cauchy-Schwarz,
    and the H¹ bound `ν ∫₀ᵀ ‖∇u_N‖² ≤ C₀²/2`. -/
theorem galerkin_deriv_l2_bound_from_energy
    (ν : ℝ) (N : ℕ) (C₀ : ℝ)
    (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3)))
    (hC₀ : 0 < C₀) (hν : 0 < ν)
    (hInit : ‖u 0‖ ≤ C₀)
    (hNS : ∀ t, phase5dEnergyIdentityStatement ν N u t)
    (T : ℝ) (hT : 0 < T) (s t : ℝ)
    (hs : s ∈ Set.Icc 0 T) (ht : t ∈ Set.Icc 0 T) (hst : s ≤ t) :
    IntervalIntegrable (fun r => ‖u' r‖^2) volume s t ∧
    IntervalIntegrable (u') volume s t ∧
    ∫ r in s..t, ‖u' r‖^2 ≤ (C₀ / Real.sqrt (2 * ν))^2 := by
  sorry -- Discharge: Phase 5D+E — NS energy identity + H^{-1} duality + Cauchy-Schwarz

/-! ## §3. ½-Hölder bound from Phase 5D -/

/-- **½-Hölder bound for Galerkin trajectory** (bridge theorem).

    Given `GalerkinL2PathHyps`, the Simon ½-Hölder bound holds:
      `‖u(t) - u(s)‖ ≤ (C₀/√(2ν)) · √|t-s|`

    Proof: Apply `ODEHalfHolderBridge.half_holder_from_l2_deriv_bound` using
    the derivative and L² bound from `GalerkinL2PathHyps`. -/
theorem galerkin_l2_holder_bound
    (ν : ℝ) (N : ℕ) (C₀ : ℝ)
    (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3)))
    (hyps : GalerkinL2PathHyps ν N C₀ u u')
    (T : ℝ) (hT : 0 < T) :
    ∀ s t : ℝ, s ∈ Set.Icc 0 T → t ∈ Set.Icc 0 T →
      ‖u t - u s‖ ≤ (C₀ / Real.sqrt (2 * ν)) * Real.sqrt |t - s| := by
  intro s t hs ht
  have hM' : 0 ≤ C₀ / Real.sqrt (2 * ν) := by
    apply div_nonneg
    · have h0 := norm_nonneg (u 0)
      linarith [hyps.init_bound]
    · exact Real.sqrt_nonneg _
  by_cases hst : s ≤ t
  · -- Case s ≤ t: rewrite |t-s| = t-s in goal, then apply hHolder
    obtain ⟨hint_sq, hint, hL2⟩ := hyps.deriv_l2_bound T hT s t hs ht hst
    have hHolder := NavierStokesClean.Galerkin.ODEHalfHolderBridge.half_holder_from_l2_deriv_bound
      hst hM' (fun x _ => hyps.path_differentiable x) hint hint_sq hL2
    rw [abs_of_nonneg (by linarith)]
    exact hHolder
  · -- Case t < s: rewrite |t-s| = s-t in goal, then apply norm_sub_rev + hHolder
    push Not at hst
    have hts : t ≤ s := le_of_lt hst
    obtain ⟨hint_sq, hint, hL2⟩ := hyps.deriv_l2_bound T hT t s ht hs hts
    have hHolder := NavierStokesClean.Galerkin.ODEHalfHolderBridge.half_holder_from_l2_deriv_bound
      hts hM' (fun x _ => hyps.path_differentiable x) hint hint_sq hL2
    rw [norm_sub_rev, show |t - s| = s - t from by
      rw [abs_of_neg (by linarith)]; ring]
    exact hHolder

end NavierStokesClean.Sobolev.SpatialCarrierBridge
