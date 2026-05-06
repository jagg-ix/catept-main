import CATEPTMain.Integration.ProperTimePathIntegralBridge
import CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant
import CATEPTMain.CATEPT_ProperTime.ProperTimeResolvent
import CATEPTMain.GaugeTheory.FEYNCALC.SpinorPropagator
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.Tactic

set_option autoImplicit false

/-!
# Proper-time ↔ FEYNCALC propagator bridge

Connects the FEYNCALC Schwinger/Laplace representation of the Euclidean
propagator to the proper-time kernel used in the CAT/EPT bridges.
-/-

namespace CATEPTMain.Integration.ProperTimeFeynCalcBridge

noncomputable section

open CATEPTMain.GaugeTheory.FEYNCALC
open CATEPTMain.CATEPT_ProperTime.ProperTimeResolvent
open MeasureTheory

/-- FEYNCALC Euclidean proper-time kernel for a momentum mode. -/
def feyncalcEuclideanProperTimeKernel (k : FCIdx → ℝ) (m : ℝ) (t : ℝ) : ℝ :=
  Real.exp (-(euclideanDenominator k m) * t)

/-- FEYNCALC propagator equals the proper-time Laplace integral. -/
theorem feyncalc_propagator_as_proper_time
    (k : FCIdx → ℝ) (m : ℝ) (hm : 0 < m) :
    1 / euclideanDenominator k m =
      ∫ t in Set.Ioi (0 : ℝ), feyncalcEuclideanProperTimeKernel k m t := by
  simpa [feyncalcEuclideanProperTimeKernel] using
    (propagator_as_catept_laplace k m hm)

/-- Heat-kernel operator induced by the FEYNCALC Euclidean denominator. -/
def heatKernelOperator_of_feyncalc (k : FCIdx → ℝ) (m : ℝ) :
    CATEPTMain.CATEPT_ProperTime.HeatKernelDeterminant.HeatKernelOperator :=
  { O_E := euclideanDenominator k m
    K_I := 0
    K_I_nonneg := by simp }

/-- FEYNCALC Dirac numerator weighted by Euclidean proper-time damping. -/
def feyncalcDiracProperTimeKernel (k : FCIdx → ℝ) (m : ℝ) (t : ℝ) : FCEnd :=
  smulEnd (feyncalcEuclideanProperTimeKernel k m t : ℂ)
    (diracPropagatorNumerator k m)

/-- Trace of the weighted Dirac numerator. -/
theorem feyncalcDiracProperTimeKernel_trace (k : FCIdx → ℝ) (m t : ℝ) :
    spinorTrace (feyncalcDiracProperTimeKernel k m t) =
      (feyncalcEuclideanProperTimeKernel k m t : ℂ) * (4 * (m : ℂ)) := by
  unfold feyncalcDiracProperTimeKernel
  rw [spinorTrace_smul, diracPropNumerator_trace]

/-- Proper-time Lorentzian operator from the FEYNCALC Euclidean denominator. -/
def properTimeLorentzianOp_of_feyncalc (k : FCIdx → ℝ) (m : ℝ) :
    ProperTimeLorentzianOperator :=
  { O_L := 0
    K_I := euclideanDenominator k m
    K_I_nonneg := by
      have : 0 ≤ euclideanDenominator k m := euclideanDenominator_nonneg k m
      exact this }

/-- FEYNCALC damping appears as the K_I part of the proper-time Lorentzian kernel. -/
theorem proper_time_kernel_from_feyncalc
    (k : FCIdx → ℝ) (m sigma : ℝ) :
    properTimeLorentzianKernel (properTimeLorentzianOp_of_feyncalc k m) sigma 0 =
      (Real.exp (-(sigma * euclideanDenominator k m)) : ℂ) := by
  unfold properTimeLorentzianOp_of_feyncalc properTimeLorentzianKernel
  simp

/-- FEYNCALC Euclidean actionIm matches K_I damping when scaled by hbar. -/
theorem euclideanActionIm_div_hbar
    (k : FCIdx → ℝ) (m hbar : ℝ) (hh : 0 < hbar) :
    euclideanActionIm k m hbar / hbar = euclideanDenominator k m := by
  unfold euclideanActionIm
  have hne : hbar ≠ 0 := ne_of_gt hh
  field_simp [hne]

/-- Damping written as exp(-sigma * (S_I / hbar)) for FEYNCALC actionIm. -/
theorem feyncalc_damping_as_actionIm
    (k : FCIdx → ℝ) (m hbar sigma : ℝ) (hh : 0 < hbar) :
    Real.exp (-(sigma * euclideanDenominator k m)) =
      Real.exp (-(sigma * (euclideanActionIm k m hbar / hbar))) := by
  simp [euclideanActionIm_div_hbar k m hbar hh]

end

end CATEPTMain.Integration.ProperTimeFeynCalcBridge
