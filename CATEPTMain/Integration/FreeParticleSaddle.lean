/-
  T-H Phase 1: Free-particle action time-additivity at the saddle.

  The path-integral slicing identity at the classical level: when a
  free particle traverses `xa → xb` over total time `T₁ + T₂`, the
  intermediate point `xm` that minimises the broken-path action is

        xm*  =  (T₂ · xa  +  T₁ · xb)  /  (T₁ + T₂),

  and at this saddle the action *adds*:

        S_cl(xa, xm*, T₁)  +  S_cl(xm*, xb, T₂)
              =  S_cl(xa, xb, T₁ + T₂).

  This is the algebraic Chapman–Kolmogorov identity that the Feynman
  slicing construction relies on at every step: the kinetic action of
  the straight-line classical trajectory is additive when sampled at
  the geometric saddle, exactly because the saddle is the unique point
  where dS/dxm = 0.

  Phase 1 ships two honest, kernel-only identities:

    (1) `freeSaddle_displacement_split` — the segment displacements
          xm* - xa = T₁ · (xb - xa) / (T₁ + T₂)
          xb - xm* = T₂ · (xb - xa) / (T₁ + T₂)
    (2) `freeClassicalAction_additive_at_saddle` — the additivity law
          itself, proved by direct ring/field_simp manipulation.

  Phase 2 (deferred): the variational *characterisation* of `xm*`
  (`d/dxm [S_cl(xa,xm,T₁) + S_cl(xm,xb,T₂)] = 0` at xm = xm*), and
  the convexity result giving global minimum (not just stationary
  point), and the n-fold Trotter slicing that this 2-fold identity
  iterates into.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.Calculus.Deriv.Pow
import Mathlib.Analysis.Calculus.Deriv.Mul
import Mathlib.Analysis.Calculus.Deriv.Add
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import CATEPTMain.Integration.FreeParticleAction

set_option autoImplicit false

namespace CATEPTMain.Integration.FreeParticleSaddle

open CATEPTMain.Integration.FreeParticleAction

noncomputable section

/-- The classical saddle: the intermediate point at which a broken
    free-particle path `xa → xm → xb` over times `(T₁, T₂)` has minimal
    action. -/
def freeSaddle (xa xb T₁ T₂ : ℝ) : ℝ :=
  (T₂ * xa + T₁ * xb) / (T₁ + T₂)

/-- Each segment of a saddle-broken free-particle path carries
    a displacement proportional to the corresponding time interval:
    `xm* - xa = T₁·(xb - xa)/(T₁ + T₂)` and
    `xb - xm* = T₂·(xb - xa)/(T₁ + T₂)`. -/
theorem freeSaddle_displacement_split
    (xa xb T₁ T₂ : ℝ) (_hT : T₁ + T₂ ≠ 0) :
    freeSaddle xa xb T₁ T₂ - xa
      = T₁ * (xb - xa) / (T₁ + T₂)
    ∧ xb - freeSaddle xa xb T₁ T₂
      = T₂ * (xb - xa) / (T₁ + T₂) := by
  refine ⟨?_, ?_⟩
  · unfold freeSaddle
    field_simp
    ring
  · unfold freeSaddle
    field_simp
    ring

/-- Classical-action additivity at the saddle (Chapman–Kolmogorov):
    summing the free-particle actions over the two segments of a
    saddle-broken path equals the action over the unbroken total. -/
theorem freeClassicalAction_additive_at_saddle
    (m xa xb T₁ T₂ : ℝ)
    (_hT₁ : T₁ ≠ 0) (_hT₂ : T₂ ≠ 0) (_hTsum : T₁ + T₂ ≠ 0) :
    freeClassicalAction m xa (freeSaddle xa xb T₁ T₂) T₁
      + freeClassicalAction m (freeSaddle xa xb T₁ T₂) xb T₂
      = freeClassicalAction m xa xb (T₁ + T₂) := by
  unfold freeClassicalAction freeSaddle
  field_simp
  ring

/-! ## Phase 2: variational characterisation of the saddle.

The midpoint `xm* = (T₂·xa + T₁·xb)/(T₁ + T₂)` is not just *some*
point at which the broken-path action adds (Phase 1); it is the unique
stationary point of the broken-path action viewed as a function of the
midpoint `xm`. Concretely, with

    F(u)  :=  S_cl(xa, u, T₁)  +  S_cl(u, xb, T₂)
           =  m·(u - xa)²/(2·T₁)  +  m·(xb - u)²/(2·T₂),

we have `F'(u) = m·(u - xa)/T₁ - m·(xb - u)/T₂`, which vanishes
exactly at `u = xm*`. This is the variational characterisation
`∂_{xₘ}[S_cl(xa,xm,T₁) + S_cl(xm,xb,T₂)] = 0 at xm = xm*` underlying
Feynman's slicing: the saddle of every two-step segment is the
classical trajectory's midpoint, and iterating this is what produces
the path integral over the classical action.
-/

/-- Variational characterisation of the free-particle saddle:
the broken-path action `u ↦ S_cl(xa, u, T₁) + S_cl(u, xb, T₂)` has
derivative zero at `u = xm* = (T₂·xa + T₁·xb)/(T₁ + T₂)`. -/
theorem freeClassicalAction_sum_hasDerivAt_saddle
    (m xa xb T₁ T₂ : ℝ)
    (hT₁ : T₁ ≠ 0) (hT₂ : T₂ ≠ 0) (hTsum : T₁ + T₂ ≠ 0) :
    HasDerivAt
      (fun u : ℝ => freeClassicalAction m xa u T₁
                  + freeClassicalAction m u xb T₂)
      0
      (freeSaddle xa xb T₁ T₂) := by
  set xm := freeSaddle xa xb T₁ T₂ with hxm_def
  -- Derivative of the first segment: d/du [m·(u-xa)²/(2·T₁)] = m·(u-xa)/T₁.
  have h1 : HasDerivAt
      (fun u : ℝ => m * (u - xa) ^ 2 / (2 * T₁))
      (m * (xm - xa) / T₁) xm := by
    have hu : HasDerivAt (fun u : ℝ => u - xa) 1 xm :=
      (hasDerivAt_id' xm).sub_const xa
    have hd : HasDerivAt (fun u : ℝ => (u - xa) ^ 2) (2 * (xm - xa)) xm := by
      have h := hu.pow 2
      convert h using 1 <;> push_cast <;> ring
    have h := (hd.const_mul m).div_const (2 * T₁)
    convert h using 1
    field_simp
  -- Derivative of the second segment: d/du [m·(xb-u)²/(2·T₂)] = -m·(xb-u)/T₂.
  have h2 : HasDerivAt
      (fun u : ℝ => m * (xb - u) ^ 2 / (2 * T₂))
      (-(m * (xb - xm) / T₂)) xm := by
    have hu : HasDerivAt (fun u : ℝ => xb - u) (-1) xm := by
      have := (hasDerivAt_const xm xb).sub (hasDerivAt_id' xm)
      simpa using this
    have hd : HasDerivAt (fun u : ℝ => (xb - u) ^ 2) (-(2 * (xb - xm))) xm := by
      have h := hu.pow 2
      convert h using 1 <;> push_cast <;> ring
    have h := (hd.const_mul m).div_const (2 * T₂)
    convert h using 1
    field_simp
  -- Sum derivative.
  have hsum := h1.add h2
  -- The sum of derivatives vanishes at xm = saddle.
  have hzero : m * (xm - xa) / T₁ + -(m * (xb - xm) / T₂) = 0 := by
    rw [hxm_def]
    unfold freeSaddle
    field_simp
    ring
  -- Repackage as the goal: replace the explicit derivative by 0 and
  -- unfold `freeClassicalAction` so the lambda matches `hsum`.
  have hgoal : HasDerivAt
      (fun u : ℝ => m * (u - xa) ^ 2 / (2 * T₁)
                  + m * (xb - u) ^ 2 / (2 * T₂))
      0 xm := by
    have := hsum
    rw [hzero] at this
    exact this
  -- The displayed lambda is definitionally the unfolded form.
  unfold freeClassicalAction
  exact hgoal

end

end CATEPTMain.Integration.FreeParticleSaddle
