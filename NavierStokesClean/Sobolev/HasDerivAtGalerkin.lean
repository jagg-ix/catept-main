import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Comp
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.l2Space
import NavierStokesClean.Sobolev.EnergyIdentityT3

/-!
# Phase 5D Task 3: HasDerivAt for Galerkin Energy Trajectory

This file provides the interface scaffold for the `HasDerivAt` statement on the
Galerkin energy trajectory.  The central claim is:

  For a smooth Galerkin solution `u : ℝ → L²(T³)` satisfying the truncated
  Navier-Stokes system at level N, the projected energy curve
  `E_N(t) := ‖P_N u(t)‖²` satisfies
  ```
  HasDerivAt E_N (-2ν · ∑_{k ∈ Λ_N} |k|² |û_k|² - 0) t
  ```
  where `∑_{k ∈ Λ_N} |k|² |û_k|²` is `projectedGradientTerm N (u t)`
  (the Galerkin-truncated H¹ Fourier seminorm), and the convection term
  vanishes by the divergence-free condition.

## Structure of this file

- `GalerkinTrajectoryHyps`: hypothesis bundle for the trajectory.
- `galerkin_energy_deriv_eq`: consequence of `HasDerivAt` via `.deriv`.
- `galerkin_energy_nonincreasing`: for ν ≥ 0, the time derivative is ≤ 0.

## Sorry status

The actual proof that NS Galerkin trajectories satisfy the `HasDerivAt`
hypothesis is left to future work (requires smoothness of the Galerkin ODE
and chain rule for the squared norm).

The chain-rule bridge `projectedEnergyCurve_hasDerivAt_chain` is sorry'd,
pending formalization of `spectralProjL2 N` as a `ContinuousLinearMap`.
The NS-equation bridge `inner_eq_projectedGradientTerm_of_NS` is sorry'd,
pending the Parseval identity for the projected inner product.
-/

set_option autoImplicit false

private noncomputable instance factPeriodOneHDG : Fact (0 < (1 : ℝ)) := ⟨one_pos⟩

noncomputable local instance : MeasureTheory.MeasureSpace UnitAddCircle :=
  ⟨AddCircle.haarAddCircle⟩

namespace NavierStokesClean.Sobolev.HasDerivAtGalerkin

open MeasureTheory
open UnitAddTorus
open scoped BigOperators ENNReal NNReal

local notation "L²(" α ")" => Lp ℂ 2 (volume : Measure α)

open NavierStokesClean.Sobolev.EnergyIdentityT3
open NavierStokesClean.Sobolev.SpectralProjectionT3

/-! ## Trajectory hypothesis bundle -/

/-- Hypothesis bundle encoding smoothness conditions on a Galerkin trajectory
    `u : ℝ → L²(T³)` at truncation level `N` and viscosity `ν`. -/
structure GalerkinTrajectoryHyps
    (ν : ℝ) (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3))) : Prop where
  /-- Viscosity is nonnegative. -/
  nu_nonneg : 0 ≤ ν
  /-- The path `t ↦ u t` is continuous into `L²`. -/
  path_continuous : Continuous u
  /-- The projected energy curve is differentiable at every time. -/
  energy_differentiable : ∀ t : ℝ, DifferentiableAt ℝ (projectedEnergyCurve N u) t

/-! ## Consequence lemmas -/

/-- If `HasDerivAt E_N v t` holds for the projected energy curve, the `deriv` agrees. -/
theorem galerkin_energy_deriv_eq
    (ν : ℝ) (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3))) (t : ℝ)
    (hd : HasDerivAt (projectedEnergyCurve N u)
          (-2 * ν * projectedGradientTerm N (u t) - projectedConvectionTerm N (u t)) t) :
    deriv (projectedEnergyCurve N u) t =
      -2 * ν * projectedGradientTerm N (u t) - projectedConvectionTerm N (u t) :=
  hd.deriv

/-- For ν ≥ 0, the right-hand side of the projected energy identity is ≤ 0.

    This encodes viscous energy decrease: the convection term vanishes (by
    `projectedConvectionTerm_eq_zero`) and `projectedGradientTerm N (u t) ≥ 0`. -/
theorem galerkin_energy_rhs_nonpos
    (ν : ℝ) (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (hν : 0 ≤ ν) (t : ℝ) :
    -2 * ν * projectedGradientTerm N (u t) - projectedConvectionTerm N (u t) ≤ 0 := by
  simp only [projectedConvectionTerm_eq_zero, sub_zero]
  have hg := projectedGradientTerm_nonneg N (u t)
  have h2νg : 0 ≤ 2 * ν * projectedGradientTerm N (u t) :=
    mul_nonneg (mul_nonneg (by norm_num) hν) hg
  linarith

/-! ## Chain-rule bridge -/

/-- **Chain-rule bridge** (sorry): if `u : ℝ → L²(T³)` has derivative `u' t` at time `t`,
    then the projected energy curve `E_N(t) = ‖P_N u(t)‖²` has derivative
    `2 * re ⟪P_N u(t), P_N u'(t)⟫` at `t`.

    **Proof route** (deferred):
    1. `spectralProjL2 N` is a bounded ℝ-linear map on `L²` (finite-rank → bounded).
    2. Chain rule: `HasDerivAt (spectralProjL2 N ∘ u) (spectralProjL2 N (u' t)) t`.
    3. Derivative of `x ↦ ‖x‖² : L²(ℂ) → ℝ` at `v` in direction `w` is
       `2 * Complex.re ⟪v, w⟫_ℂ` (real part of the ℂ-inner product).
    4. Composition gives the stated derivative. -/
theorem projectedEnergyCurve_hasDerivAt_chain
    (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3)))
    (hdu : ∀ t, HasDerivAt u (u' t) t) (t : ℝ) :
    HasDerivAt (projectedEnergyCurve N u)
      (2 * Complex.re (inner (𝕜 := ℂ)
          (spectralProjL2 N (u t))
          (spectralProjL2 N (u' t)))) t := by
  sorry

/-- **NS-equation bridge** (sorry): when `u'` satisfies the projected Galerkin NS equation,
    the chain-rule derivative equals `-2ν · projectedGradientTerm N (u t)`.

    The identity uses:
    ```
    re ⟪P_N u, P_N (ν Δ u)⟫ = -ν · ∑_{k ∈ Λ_N} |k|² |û_k|²
    ```
    (Parseval + Fourier derivative: `⟪mFourier k, Δ mFourier k⟫ = -(2π|k|)²`). -/
theorem inner_eq_projectedGradientTerm_of_NS
    (ν : ℝ) (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3)))
    (t : ℝ) :
    2 * Complex.re (inner (𝕜 := ℂ)
        (spectralProjL2 N (u t))
        (spectralProjL2 N (u' t))) =
      -2 * ν * projectedGradientTerm N (u t) - projectedConvectionTerm N (u t) := by
  sorry

/-- **Full interface theorem**: given path differentiability and the NS-inner-product bridge,
    the projected energy satisfies `phase5dEnergyIdentityStatement`. -/
theorem phase5d_energy_identity_from_chain
    (ν : ℝ) (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (u' : ℝ → L²(UnitAddTorus (Fin 3)))
    (hdu : ∀ t, HasDerivAt u (u' t) t)
    (hinner : ∀ t,
      2 * Complex.re (inner (𝕜 := ℂ)
          (spectralProjL2 N (u t))
          (spectralProjL2 N (u' t))) =
        -2 * ν * projectedGradientTerm N (u t) - projectedConvectionTerm N (u t))
    (t : ℝ) :
    phase5dEnergyIdentityStatement ν N u t := by
  unfold phase5dEnergyIdentityStatement
  have hd := projectedEnergyCurve_hasDerivAt_chain N u u' hdu t
  rwa [hinner t] at hd

end NavierStokesClean.Sobolev.HasDerivAtGalerkin