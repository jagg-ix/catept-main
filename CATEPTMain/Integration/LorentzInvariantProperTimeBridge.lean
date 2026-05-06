import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import CATEPTMain.GaugeTheory.FEYNCALC.LorentzAlgebra
import CATEPTMain.CATEPT_ProperTime.ProperTimeResolvent

set_option autoImplicit false

/-!
# Lorentz-invariant proper-time kernel (FEYNCALC)

Defines a Lorentz-invariant proper-time denominator using the FEYNCALC
Lorentz product and connects it to the CAT/EPT proper-time kernel.
-/-

namespace CATEPTMain.Integration.LorentzInvariantProperTimeBridge

noncomputable section

open CATEPTMain.GaugeTheory.FEYNCALC
open CATEPTMain.CATEPT_ProperTime.ProperTimeResolvent

/-- Lorentz-invariant denominator `p^2 + m^2`. -/
def lorentzInvariantDenominator (p : FCIdx → ℝ) (m : ℝ) : ℝ :=
  lorentzProduct p p + m ^ 2

/-- Proper-time kernel built from the Lorentz-invariant denominator. -/
def lorentzInvariantProperTimeKernel (p : FCIdx → ℝ) (m sigma : ℝ) : ℝ :=
  Real.exp (-(lorentzInvariantDenominator p m) * sigma)

/-- Proper-time Lorentzian operator with a Lorentz-invariant real part. -/
def lorentzProperTimeOperator (p : FCIdx → ℝ) (m : ℝ) : ProperTimeLorentzianOperator :=
  { O_L := lorentzProduct p p - m ^ 2
    K_I := 0
    K_I_nonneg := by simp }

/-- Lorentzian proper-time kernel factorization (K_I = 0). -/
theorem lorentzProperTimeKernel_factor
    (p : FCIdx → ℝ) (m sigma epsilon : ℝ) :
    properTimeLorentzianKernel (lorentzProperTimeOperator p m) sigma epsilon =
      Complex.exp ((sigma * (lorentzProduct p p - m ^ 2) : ℂ) * Complex.I) *
        (Real.exp (-(epsilon * sigma)) : ℂ) := by
  unfold lorentzProperTimeOperator properTimeLorentzianKernel
  simp [mul_assoc, sub_eq_add_neg]

end

end CATEPTMain.Integration.LorentzInvariantProperTimeBridge
