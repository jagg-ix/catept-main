import CATEPTMain.CATEPT.CatsimEntropicTimeBridge
import Mathlib.Data.Real.Basic

set_option autoImplicit false

/-!
# Catsim CFL Stability Bridge

## Purpose

Ported from `multiphysics/catsim/lean/CatsimLean/CFL.lean`.

The catsim simulator enforces a CFL-style stability constraint for both
coordinate time `t` and entropic proper time `τ_ent`. Reparameterizing
time does **not** relax hyperbolic stability — the constraint merely
transforms:

  Δt ≤ Δx / c           (base CFL)
  Δτ = λ̄ · Δt            (entropic reparameterization)

Under λ̄ ≥ 0, the entropic step is monotone in Δt. The original statement
by the catsim authors in `multiphysics/catsim/docs/cfl_clock.md`:

  "Reparameterizing time does *not* remove CFL-like stability constraints
   for explicit hyperbolic solvers. It changes how the step is *chosen*
   (adaptive stepping), but the causality/stability constraints still apply
   in coordinate time."

## Key results

1. `dtau` is monotone in `dt` when `λbar ≥ 0`
2. CFL in `t` implies a corresponding bound in `τ`:
     `CFL_ok p dt  →  dtau λbar dt ≤ λbar * cflBound p`
-/

noncomputable section

namespace CATEPT

/-- CFL parameters: grid spacing and wave speed. -/
structure CFLParams where
  dx : ℝ
  c : ℝ
  h_dx : 0 < dx
  h_c : 0 < c

/-- CFL upper bound on the coordinate-time step: `Δt ≤ Δx / c`. -/
def cflBound (p : CFLParams) : ℝ := p.dx / p.c

/-- Propositional CFL check: a given `dt` satisfies the CFL bound. -/
def CFL_ok (p : CFLParams) (dt : ℝ) : Prop := dt ≤ cflBound p

/-- Entropic step size induced by average entropic rate `λbar`:
    `Δτ = λ̄ · Δt`. -/
def dtau (lambar dt : ℝ) : ℝ := lambar * dt

/-- Entropic step is monotone in coordinate-time step when `λbar ≥ 0`. -/
theorem dtau_monotone_dt (lambar : ℝ) (hlam : 0 ≤ lambar) :
    Monotone (fun dt => dtau lambar dt) := by
  intro a b hab
  dsimp [dtau]
  nlinarith

/-- CFL constraint in `t` ⇒ corresponding bound in `τ`.
    If `dt` satisfies the coordinate-CFL `dt ≤ Δx/c`, then
    `Δτ = λ̄ · dt ≤ λ̄ · (Δx/c)`. -/
theorem cfl_t_implies_cfl_tau
    (p : CFLParams) (lambar : ℝ) (hlam : 0 ≤ lambar) (dt : ℝ)
    (hdt : CFL_ok p dt) :
    dtau lambar dt ≤ lambar * cflBound p := by
  dsimp [CFL_ok, cflBound, dtau] at *
  nlinarith

end CATEPT
