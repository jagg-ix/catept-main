import CatsimLean.EntropicTime
import Mathlib.Data.Real.Basic

/-!
CFL-style stability constraints (symbolic skeleton).

The catsim repository enforces a CFL-like stability constraint for both
coordinate time `t` and entropic proper time `τ_ent`.

This file provides a small interface for expressing that relationship:

  Δt ≤ Δx / c     (base CFL)
  Δτ = λ̄ Δt      (entropic reparam)

Under λ̄ ≥ 0, the step in τ is monotone in Δt; with additional bounds one can
translate between constraints.
-/

namespace CatsimLean

structure CFLParams where
  dx : ℝ
  c : ℝ
  (h_dx : 0 < dx)
  (h_c : 0 < c)

def cflBound (p : CFLParams) : ℝ := p.dx / p.c

def CFL_ok (p : CFLParams) (dt : ℝ) : Prop := dt ≤ cflBound p

/-!
Given an average entropic rate `λbar` over a step, define the corresponding
entropic step size.
-/
def dtau (λbar dt : ℝ) : ℝ := λbar * dt

theorem dtau_monotone_dt (λbar : ℝ) (hλ : 0 ≤ λbar) : Monotone (fun dt => dtau λbar dt) := by
  intro a b hab
  dsimp [dtau]
  nlinarith

/-!
Skeleton theorem: CFL constraint in `t` implies a derived constraint in `τ`.
We keep the statement minimal; the tight version depends on how λ is bounded.
-/
theorem cfl_t_implies_cfl_tau
    (p : CFLParams) (λbar : ℝ) (hλ : 0 ≤ λbar) (dt : ℝ)
    (hdt : CFL_ok p dt) :
    dtau λbar dt ≤ λbar * cflBound p := by
  dsimp [CFL_ok, cflBound, dtau] at *
  nlinarith

end CatsimLean
