/-
  T-G Phase 1: Free-particle classical action — closed-form algebra.

  The classical action of a free particle of mass `m` traversing from
  `xa` to `xb` over time `T` is

        S_cl(xa, xb, T)  =  m · (xb - xa)²  /  (2 · T).

  This is the exponent of the Feynman free propagator
  K(xb, xa; T) ∝ exp(i · S_cl / ℏ), the universal x-space kernel of
  every non-relativistic path integral when the potential vanishes,
  and the leading-order WKB phase otherwise.

  Phase 1 ships four honest, kernel-only identities:

    (1) `freeClassicalAction_zero_displacement` — vanishes when xb = xa
    (2) `freeClassicalAction_endpoint_symm`     — invariant under xa ↔ xb
    (3) `freeClassicalAction_endpoint_rescale`  — quadratic in displacement
    (4) `freeClassicalAction_mass_linear`       — linear in mass

  Phase 2 (deferred): time-additivity along a slicing
  S_cl(xa, xb; T₁+T₂) = min_{xm} (S_cl(xa, xm; T₁) + S_cl(xm, xb; T₂))
  with the minimum attained at xm* = (T₂·xa + T₁·xb)/(T₁+T₂); harmonic
  oscillator extension; and the propagator's Gaussian-integral identity
  K(xb,xa;T) = √(m/(2π·iℏ·T)) · exp(i·m·(xb-xa)²/(2ℏT)).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

set_option autoImplicit false

namespace CATEPTMain.Integration.FreeParticleAction

noncomputable section

/-- Free-particle classical action: `m·(xb-xa)² / (2·T)`.
    Exponent of the Feynman free-propagator kernel. -/
def freeClassicalAction (m xa xb T : ℝ) : ℝ :=
  m * (xb - xa) ^ 2 / (2 * T)

/-- Zero displacement ⇒ zero action: a particle that stays put accumulates
    no classical action. -/
theorem freeClassicalAction_zero_displacement (m x T : ℝ) :
    freeClassicalAction m x x T = 0 := by
  unfold freeClassicalAction
  ring

/-- Endpoint-swap symmetry: the action depends only on `(xb - xa)²`,
    hence is invariant under `xa ↔ xb`. -/
theorem freeClassicalAction_endpoint_symm (m xa xb T : ℝ) :
    freeClassicalAction m xa xb T = freeClassicalAction m xb xa T := by
  unfold freeClassicalAction
  ring

/-- Quadratic endpoint rescaling: scaling both endpoints by `k` (around
    origin) scales the action by `k²`. The classical action is
    homogeneous of degree 2 in the displacement. -/
theorem freeClassicalAction_endpoint_rescale (m k xa xb T : ℝ) :
    freeClassicalAction m (k * xa) (k * xb) T
      = k ^ 2 * freeClassicalAction m xa xb T := by
  unfold freeClassicalAction
  ring

/-- Linearity in mass: doubling the mass doubles the action. -/
theorem freeClassicalAction_mass_linear (k m xa xb T : ℝ) :
    freeClassicalAction (k * m) xa xb T
      = k * freeClassicalAction m xa xb T := by
  unfold freeClassicalAction
  ring

end

end CATEPTMain.Integration.FreeParticleAction
