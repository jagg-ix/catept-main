import CATEPTMain.CATEPT.CATEPT.LazoKrumreichBridge

set_option autoImplicit false

/-!
# Example 23: Lazo–Krumreich Fractional Dissipation

REPLYID: 20260129-00139

## What makes this unique to CAT/EPT

The Lazo–Krumreich action principle replaces explicit friction terms
in classical mechanics with **half-order Caputo derivatives**.  Inside
CAT/EPT the very same half-order operator structure naturally arises
from the imaginary action `S_I` (the gravitational-backreaction sector
that drives entropic time).  This example file demonstrates the typed
reusable surface provided by `LazoKrumreichBridge`.

## Key results illustrated

1. The LK eq. (17) half-derivative compose identity holds for the
   canonical instance (so the bundle is non-empty in pure Lean).
2. The LK dissipative Lagrangian (eq. (32)) has a non-negative
   dissipative part whenever the friction coupling `γ ≥ 0`.
3. The conservative limit (`γ = 0`) of eq. (32) is the Newtonian
   Lagrangian (eq. (25) local form).
4. The dissipative Hamiltonian (eq. (36)) is non-negative under the
   expected physical hypotheses.
5. The local friction coefficient `(2/π) γ` (eq. (33)) is positive
   for `γ > 0`.
6. The radiation-reaction coefficient `(2 e²)/(3 c³)` (eq. (50)) is
   non-negative, vanishing at zero charge (Abraham–Lorentz decouples).
7. The radiation Lagrangian / Hamiltonian (eqs. (44), (48)) reduce
   to ordinary Newtonian mechanics at `e = 0`.
-/

namespace CATEPT.Examples

open CATEPTMain.CATEPT.CATEPT

/-- 1. Eq. (17) compose identity, discharged on the canonical instance. -/
example (x : ℝ → ℝ) (t : ℝ) :
    lk_canonical_operators.RLleft (1 / 2)
        (lk_canonical_operators.Cleft (1 / 2) x) t
      = deriv x t :=
  lkHalfDerivativeCompose lk_canonical_operators x t

/-- 2. LK eq. (32) dissipative part is non-negative for `γ ≥ 0`. -/
example (FC : LKFractionalOperators) (γ : ℝ) (hγ : 0 ≤ γ)
    (x : ℝ → ℝ) (t : ℝ) :
    0 ≤ (γ / 2) * (FC.Cright (1 / 2) x t) ^ 2 :=
  dissipativeLagrangian_real_dissipative_part_nonneg FC γ hγ x t

/-- 3. Conservative limit (`γ = 0`) of LK eq. (32). -/
example (FC : LKFractionalOperators) (m : ℝ) (U : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) :
    dissipativeLagrangian_real FC m 0 U x t
      = (1 / 2) * m * (deriv x t) ^ 2 - U (x t) :=
  dissipativeLagrangian_real_conservative_limit FC m U x t

/-- 4. LK eq. (36) Hamiltonian non-negativity under physical hypotheses. -/
example (FC : LKFractionalOperators) (m γ : ℝ) (U : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ)
    (hm : 0 ≤ m) (hγ : 0 ≤ γ) (hU : 0 ≤ U (x t)) :
    0 ≤ dissipativeHamiltonian FC m γ U x t :=
  dissipativeHamiltonian_nonneg FC m γ U x t hm hγ hU

/-- 5a. Local friction coefficient `(2/π) γ` is positive for `γ > 0`. -/
example (γ : ℝ) (hγ : 0 < γ) :
    0 < localFrictionCoefficient γ :=
  localFrictionCoefficient_pos γ hγ

/-- 5b. Local friction coefficient is non-negative for `γ ≥ 0`. -/
example (γ : ℝ) (hγ : 0 ≤ γ) :
    0 ≤ localFrictionCoefficient γ :=
  localFrictionCoefficient_nonneg γ hγ

/-- 6a. Abraham–Lorentz radiation-reaction coefficient is non-negative. -/
example (e c : ℝ) (hc : 0 < c) :
    0 ≤ radiationReactionCoefficient e c :=
  radiationReactionCoefficient_nonneg e c hc

/-- 6b. At zero electric charge, the radiation-reaction coefficient
vanishes (eq. (50) chargeless decoupling). -/
example (c : ℝ) :
    radiationReactionCoefficient 0 c = 0 :=
  radiationReactionCoefficient_chargeless c

/-- 7a. Chargeless reduction of the radiation Lagrangian (eq. (44)). -/
example (FC : LKFractionalOperators) (m c : ℝ) (U : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) :
    radiationLagrangian FC m 0 c U x t
      = (1 / 2) * m * (deriv x t) ^ 2 - U (x t) :=
  radiationLagrangian_chargeless_limit FC m c U x t

/-- 7b. Chargeless reduction of the radiation Hamiltonian (eq. (48)). -/
example (FC : LKFractionalOperators) (m c : ℝ) (U : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) :
    radiationHamiltonian FC m 0 c U x t
      = (1 / 2) * m * (deriv x t) ^ 2 + U (x t) :=
  radiationHamiltonian_chargeless_limit FC m c U x t

/-- 8. Friction-coupling additivity for the LK Lagrangian (eq. (32)). -/
example (FC : LKFractionalOperators) (m γ₁ γ₂ : ℝ) (U : ℝ → ℝ)
    (x : ℝ → ℝ) (t : ℝ) :
    dissipativeLagrangian_real FC m (γ₁ + γ₂) U x t
      = dissipativeLagrangian_real FC m γ₁ U x t
        + (γ₂ / 2) * (FC.Cright (1 / 2) x t) ^ 2 :=
  dissipativeLagrangian_real_friction_linear FC m γ₁ γ₂ U x t

end CATEPT.Examples
