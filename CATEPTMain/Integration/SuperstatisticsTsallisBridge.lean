import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import CATEPTMain.CATEPT.CATEPT.CAT_EPT_ETH_CanonicalBridge
import NavierStokesClean.CATEPT.Theoremized.Batch20260408_46_EntropyBraidTsallisKernel0005

noncomputable section

set_option autoImplicit false

open CATEPTMain.CATEPT.CATEPT

namespace CATEPTMain.Integration

open NavierStokesClean.CATEPT.Theoremized.Batch20260408.B46

/-- Superstatistical Tsallis kernel with a Boltzmann-Gibbs branch at `q = 1`. -/
def qExponentialKernel (beta0 q E : ℝ) : ℝ :=
  if hq : q = 1 then
    Real.exp (-beta0 * E)
  else
    Real.rpow (1 + (q - 1) * beta0 * E) (-1 / (q - 1))

/-- The `q = 1` branch recovers the standard Boltzmann-Gibbs factor. -/
theorem qExponentialKernel_at_q1 (beta0 E : ℝ) :
    qExponentialKernel beta0 1 E = Real.exp (-beta0 * E) := by
  simp [qExponentialKernel]

/-- Focused-5 adapter: superstatistics Tsallis entropy delegates to the row-46
entropy-family wrapper already formalized in the theoremized Navier-Stokes lane. -/
def tsallisEntropyAdapter (q integralVal shannonFallback : ℝ) : ℝ :=
  row46_tsallisEntropy q integralVal shannonFallback

/-- At `q = 1`, the adapter agrees with Shannon fallback exactly as row-46 proves. -/
theorem tsallisEntropyAdapter_at_q1
    (integralVal shannonFallback : ℝ) :
    tsallisEntropyAdapter 1 integralVal shannonFallback = shannonFallback :=
  row46_tsallis_at_q1 integralVal shannonFallback

/-- Row-46 damping envelope is exponential in `S_I`, matching canonical ETH form
once the canonical entropic clock is identified with `S_I / π`. -/
theorem canonicalSuppression_eq_row46_norm
    {X : Type} (p : CanonicalETHBridgeParams X) (x : X) (S_I : ℝ)
    (htau : canonicalTauDiag p x = S_I / Real.pi) :
    canonicalSuppressionFactor p x = ‖row46_amplitude 0 S_I‖ := by
  unfold canonicalSuppressionFactor
  rw [htau, row46_norm_amplitude (E := 0) (S_I := S_I)]
  have hneg : -(S_I / Real.pi) = -S_I / Real.pi := by ring
  simpa [hneg]

end CATEPTMain.Integration
