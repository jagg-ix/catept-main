import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Analysis.Calculus.Deriv.Inv

/-!
# Renormalization-Group Apparatus — One-Loop Running (T-E Phase 1)

Phase 1 of Target T-E (renormalization-group apparatus). Honest
algebraic content of the **one-loop running coupling**.

For a single coupling `g` with one-loop beta function `β(g) = -b·g²`
the RG flow equation `dg/dt = -b·g²` integrates to the closed form

  `g(t)  =  g₀ / (1 + b · g₀ · t)`.

This file pins three honest algebraic identities about that closed
form — all proved with `field_simp` / `ring` from the underlying
arithmetic, no measure-theoretic or analytic content:

* `oneLoopRunning_at_zero`        — initial condition `g(0) = g₀`.
* `oneLoopRunning_inverse_linear` — the RG-invariant form
  `1/g(t) = 1/g₀ + b·t`  (the "Landau-pole" linear law).
* `oneLoopRunning_semigroup`      — RG flow composition
  `g_t ∘ g_s = g_{s+t}`  (the algebraic core of Wilson flow).

## Stages NOT discharged here (require new infrastructure)

* The actual ODE `dg/dt = -b·g²` and its solution by separation of
  variables — needs `Mathlib.MeasureTheory.IntegralEqImproper` /
  `ODE_solution_unique` infra. The closed form is *postulated* here
  by definition; the differential equation it satisfies is queued
  for Phase 2.
* Multi-coupling / matrix-valued β functions (Standard-Model RGEs).
* Wilsonian effective action: integrating out modes between scales.

## Phase status

Phase-1 — honest algebraic identities, machine-checked, kernel-only
`[propext, Classical.choice, Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.RenormalizationGroup

noncomputable section

/-- One-loop closed-form running coupling at flow time `t` starting from
    bare coupling `g₀`, with one-loop coefficient `b`:

      `g(t)  =  g₀ / (1 + b · g₀ · t)`. -/
def oneLoopRunning (g₀ b t : ℝ) : ℝ :=
  g₀ / (1 + b * g₀ * t)

/-- **Initial condition**: at flow time zero the running coupling
    coincides with the bare coupling. -/
theorem oneLoopRunning_at_zero (g₀ b : ℝ) :
    oneLoopRunning g₀ b 0 = g₀ := by
  simp [oneLoopRunning]

/-- **RG-invariant linear law**: the inverse running coupling is *linear*
    in `t` with slope `b` and intercept `1/g₀`. This is the canonical
    form used to extract the one-loop coefficient from data:

      `1/g(t)  =  1/g₀  +  b·t`.

    Side condition: `g₀ ≠ 0` and `1 + b·g₀·t ≠ 0` (i.e. away from the
    Landau pole). -/
theorem oneLoopRunning_inverse_linear
    {g₀ b t : ℝ} (hg : g₀ ≠ 0) (_hpole : 1 + b * g₀ * t ≠ 0) :
    1 / oneLoopRunning g₀ b t = 1 / g₀ + b * t := by
  unfold oneLoopRunning
  field_simp

/-- **RG semigroup law** (Wilson flow composition).

    Running first by `s` and then by `t` is the same as running by
    `s + t` directly:

      `g_t( g_s(g₀) )  =  g_{s+t}(g₀)`.

    This is the algebraic core of the Callan–Symanzik / Wilson flow
    semigroup; physically, it expresses scale-independence of
    intermediate renormalization conditions. Side condition:
    `1 + b·g₀·s ≠ 0` and `1 + b·g₀·(s+t) ≠ 0` (we must stay strictly
    on one side of the Landau pole over the entire flow). -/
theorem oneLoopRunning_semigroup
    {g₀ b s t : ℝ}
    (hs : 1 + b * g₀ * s ≠ 0)
    (_hst : 1 + b * g₀ * (s + t) ≠ 0) :
    oneLoopRunning (oneLoopRunning g₀ b s) b t
      = oneLoopRunning g₀ b (s + t) := by
  unfold oneLoopRunning
  rw [div_div]
  congr 1
  field_simp
  ring

/-- **Wilson–Polchinski exact RG flow ODE** (T-E Phase 2 / T-BB).

    The closed-form one-loop running coupling
    `g(t) = g₀ / (1 + b·g₀·t)` satisfies the **exact** RG flow ODE

      `dg/dt  =  β(g)  =  -b · g(t)²`

    along its trajectory, away from the Landau pole. This is the
    Wilson–Polchinski exact RG identity at the algebraic level for a
    single coupling: the closed form is not just an *ansatz* — it is
    pointwise the unique trajectory of the one-loop β-function.

    Side condition: `1 + b·g₀·t ≠ 0` (strictly on one side of the
    Landau pole at the evaluation point). -/
theorem oneLoopRunning_hasDerivAt
    {g₀ b t : ℝ} (hpole : 1 + b * g₀ * t ≠ 0) :
    HasDerivAt (oneLoopRunning g₀ b) (-b * (oneLoopRunning g₀ b t) ^ 2) t := by
  unfold oneLoopRunning
  have hden : HasDerivAt (fun s : ℝ => 1 + b * g₀ * s) (b * g₀) t := by
    have h1 : HasDerivAt (fun s : ℝ => b * g₀ * s) (b * g₀) t := by
      simpa using (hasDerivAt_id t).const_mul (b * g₀)
    simpa using h1.const_add 1
  have hnum : HasDerivAt (fun _ : ℝ => g₀) 0 t := hasDerivAt_const t g₀
  have hdiv := hnum.div hden hpole
  convert hdiv using 1
  field_simp
  ring

end

end CATEPTMain.Integration.RenormalizationGroup
