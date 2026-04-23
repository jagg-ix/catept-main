import CATEPTMain.GaugeTheory.EQFTRTFT.EQFTRTFTPrelude

/-!
# Wick Polynomials (EV-002, Phase 1)

Minimal algebraic layer for normal-ordered monomials used by the
EQFTRTFT variational port.

This file is intentionally ring-provable and introduces no new axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.GaugeTheory.EQFTRTFT

/-- Renormalization constant `a_T = 6 E[W^2]`. -/
def a_T (EW2 : Real) : Real :=
  6 * EW2

/-- Renormalization constant `b_T = 3 (E[W^2])^2`. -/
def b_T (EW2 : Real) : Real :=
  3 * EW2 ^ 2

/-- Normal-ordered quadratic monomial `[W^2] = W^2 - E[W^2]`. -/
def Wick2 (W EW2 : Real) : Real :=
  W ^ 2 - EW2

/-- Normal-ordered cubic monomial `[W^3] = W^3 - 3 E[W^2] W`. -/
def Wick3 (W EW2 : Real) : Real :=
  W ^ 3 - 3 * EW2 * W

/-- Normal-ordered quartic monomial `[W^4] = W^4 - 6 E[W^2] W^2 + 3 (E[W^2])^2`. -/
def Wick4 (W EW2 : Real) : Real :=
  W ^ 4 - 6 * EW2 * W ^ 2 + 3 * EW2 ^ 2

theorem b_T_nonneg (EW2 : Real) : 0 ≤ b_T EW2 := by
  unfold b_T
  nlinarith [sq_nonneg EW2]

theorem a_T_nonneg (EW2 : Real) (hEW2 : 0 ≤ EW2) : 0 ≤ a_T EW2 := by
  unfold a_T
  nlinarith

theorem wick4_eq_wick2_sq_correction (W EW2 : Real) :
    Wick4 W EW2 = Wick2 W EW2 ^ 2 - 4 * EW2 * W ^ 2 + 2 * EW2 ^ 2 := by
  unfold Wick4 Wick2
  ring_nf

theorem renorm_energy_def (W EW2 lam : Real) :
    lam * Wick4 W EW2 - a_T EW2 * Wick2 W EW2 - b_T EW2 =
      lam * (W ^ 4 - 6 * EW2 * W ^ 2 + 3 * EW2 ^ 2) - (6 * EW2) * (W ^ 2 - EW2) - 3 * EW2 ^ 2 := by
  unfold Wick4 Wick2 a_T b_T
  ring

end CATEPTMain.GaugeTheory.EQFTRTFT
