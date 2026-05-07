import Mathlib.Analysis.Complex.Basic
import CATEPTMain.CATEPT.CATEPT.LoopIntegralBridge
import CATEPTMain.Integration.MatsubaraEuclideanCATEPTBridge

set_option autoImplicit false

/-!
# FeynCalc × Matsubara bridge (Reply 18)

Links FEYNCALC loop amplitudes to the Matsubara/KMS Euclidean upgrade.
Matsubara compactification supplies thermal boundary conditions; CAT/EPT
adds only the extra entropy functional (no double-counting of KMS).
-/

namespace CATEPTMain.Integration.FeynCalcMatsubaraBridge

noncomputable section

open CATEPTMain.Integration.MatsubaraEuclideanCATEPTBridge
open CATEPTMain.CATEPT.CATEPT
open CATEPTMain.GaugeTheory.FEYNCALC
open NavierStokesClean.CATEPT

/-- Curved loop model paired with Matsubara compact time. -/
structure MatsubaraLoopModel (α : Type*) [MeasurableSpace α] where
  compactTime : MatsubaraCompactTime
  curvedModel : CurvedMeasurePathIntegralModel α

/-- FEYNCALC loop amplitude in a Matsubara thermal setting. -/
def matsubaraLoopAmplitude {α : Type*} [MeasurableSpace α]
    (M : MatsubaraLoopModel α) (F : α → FCEnd) : ℂ :=
  loopAmplitude M.curvedModel F

/-- Entropy kernel correction `Gamma_n(k)` for Matsubara modes. -/
structure MatsubaraEntropyKernel where
  gamma : ℤ → ℝ → ℝ
  nonneg : ∀ n k, 0 ≤ gamma n k

/-- Fermionic Matsubara inverse propagator with entropy correction. -/
def matsubaraFermionInversePropagator
    (M : MatsubaraCompactTime) (n : ℤ) (k m : ℝ) (gamma : ℝ) : ℝ :=
  euclideanInversePropagator (matsubaraOmegaFermion M n) k m gamma

/-- Bosonic Matsubara inverse propagator with entropy correction. -/
def matsubaraBosonInversePropagator
    (M : MatsubaraCompactTime) (n : ℤ) (k m : ℝ) (gamma : ℝ) : ℝ :=
  euclideanInversePropagator (matsubaraOmegaBoson M n) k m gamma

/-- Fermionic inverse propagator using a Matsubara entropy kernel. -/
def matsubaraFermionInversePropagatorWithKernel
    (M : MatsubaraCompactTime) (K : MatsubaraEntropyKernel)
    (n : ℤ) (k m : ℝ) : ℝ :=
  matsubaraFermionInversePropagator M n k m (K.gamma n k)

/-- Bosonic inverse propagator using a Matsubara entropy kernel. -/
def matsubaraBosonInversePropagatorWithKernel
    (M : MatsubaraCompactTime) (K : MatsubaraEntropyKernel)
    (n : ℤ) (k m : ℝ) : ℝ :=
  matsubaraBosonInversePropagator M n k m (K.gamma n k)

end

end CATEPTMain.Integration.FeynCalcMatsubaraBridge
