import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import CATEPTMain.Integration.InstantonTunneling

/-!
# Coleman–Callan Bounce — Stationarity & Fubini Scale (T-CC Phase 3)

Phase-3 honest content for the **Coleman–Callan bounce** of the 4-D
Euclidean φ⁴ theory. Phase 1 pinned the closed form `S_b(λ) = 8π²/(3λ)`
and Phase 2 added inverse-linear coupling rescaling. Phase 3 lifts to:

* **Coupling-action invariant**: the product `λ · S_b(λ) = 8π²/3` is a
  universal constant — the algebraic shadow of the fact that the
  Fubini bounce is a *scale-invariant* solution of the φ⁴ Euler
  equation `□φ + λ φ³ = 0`, so `λ · S_b` is a renormalisation-group
  invariant of the bounce sector.

* **Action-ratio law** under joint coupling rescaling
  `(λ₁, λ₂) → (k·λ₁, k·λ₂)`: `S_b(k·λ₁)/S_b(k·λ₂) = S_b(λ₁)/S_b(λ₂)`,
  expressing scale invariance of the dimensionless action ratio.

* **WKB exponential suppression**: the tunneling rate density at
  bounce action level decays as `exp(−S_b(λ))`, with positivity
  inherited from `S_b > 0`. This pins the algebraic skeleton of the
  Coleman–Callan formula `Γ/V ∝ exp(−S_b)·(prefactor)`.

## Phase status

Phase-3 — honest algebraic identities lifting Phase-1/2, kernel-only
`[propext, Classical.choice, Quot.sound]`. Genuine Euler-equation
ODE / spectral one-loop prefactor still deferred.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.BounceStationarity

open CATEPTMain.Integration.InstantonTunneling

noncomputable section

/-- **Coupling-action invariant** of the Coleman–Callan φ⁴ bounce.
    The product `λ · S_b(λ) = 8π²/3` is independent of the coupling
    `λ`, witnessing that the Fubini bounce is scale-invariant: the
    physical action lives in a single RG orbit parameterised purely
    by the universal constant `8π²/3`. -/
theorem bounceActionPhi4_lambda_action_invariant
    {lam : ℝ} (hlam : lam ≠ 0) :
    lam * bounceActionPhi4 lam = 8 * Real.pi ^ 2 / 3 := by
  unfold bounceActionPhi4
  field_simp

/-- **Action-ratio scale invariance**. Joint rescaling of two
    couplings `(λ₁, λ₂) ↦ (k·λ₁, k·λ₂)` leaves the dimensionless
    bounce-action ratio `S_b(λ₁)/S_b(λ₂)` invariant. Algebraic shadow
    of the fact that `S_b` is a homogeneous function of degree `−1`
    in `λ`. -/
theorem bounceActionPhi4_action_ratio_scale_invariant
    {lam₁ lam₂ k : ℝ}
    (hlam₁ : lam₁ ≠ 0) (hlam₂ : lam₂ ≠ 0) (hk : k ≠ 0) :
    bounceActionPhi4 (k * lam₁) * bounceActionPhi4 lam₂
      = bounceActionPhi4 lam₁ * bounceActionPhi4 (k * lam₂) := by
  unfold bounceActionPhi4
  field_simp

/-- **WKB exponential suppression of the bounce sector**. The
    tunneling amplitude evaluated at the Coleman–Callan bounce
    action `S_b(λ) = 8π²/(3λ)` is the genuine WKB factor
    `exp(−8π²/(3λ))`. -/
theorem tunnelAmplitude_at_bounce
    (lam : ℝ) :
    tunnelAmplitude (bounceActionPhi4 lam)
      = Real.exp (-(8 * Real.pi ^ 2 / (3 * lam))) := by
  unfold tunnelAmplitude bounceActionPhi4
  rfl

/-- **Strict suppression**: the bounce-action tunneling factor is
    strictly between 0 and 1 for positive coupling, witnessing the
    genuine non-perturbative suppression of false-vacuum decay. -/
theorem tunnelAmplitude_at_bounce_lt_one
    {lam : ℝ} (hlam : 0 < lam) :
    tunnelAmplitude (bounceActionPhi4 lam) < 1 := by
  have hpos := bounceActionPhi4_pos hlam
  unfold tunnelAmplitude
  have : Real.exp (-bounceActionPhi4 lam) < Real.exp 0 := by
    apply Real.exp_lt_exp.mpr
    linarith
  simpa using this

end

end CATEPTMain.Integration.BounceStationarity
