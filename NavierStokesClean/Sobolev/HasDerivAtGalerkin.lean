import Mathlib.Analysis.Calculus.Deriv.Basic
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

/-- Combined: under `GalerkinTrajectoryHyps` and the `HasDerivAt` assumption,
    the energy derivative is nonpositive (energy is non-increasing). -/
theorem galerkin_energy_nonincreasing
    (ν : ℝ) (N : ℕ) (u : ℝ → L²(UnitAddTorus (Fin 3)))
    (hyps : GalerkinTrajectoryHyps ν N u) (t : ℝ)
    (hd : HasDerivAt (projectedEnergyCurve N u)
          (-2 * ν * projectedGradientTerm N (u t) - projectedConvectionTerm N (u t)) t) :
    deriv (projectedEnergyCurve N u) t ≤ 0 := by
  rw [galerkin_energy_deriv_eq ν N u t hd]
  exact galerkin_energy_rhs_nonpos ν N u hyps.nu_nonneg t

end NavierStokesClean.Sobolev.HasDerivAtGalerkin
