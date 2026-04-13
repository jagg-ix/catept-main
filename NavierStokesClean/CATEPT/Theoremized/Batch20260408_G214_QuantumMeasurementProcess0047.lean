import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 214

Quantum-measurement process scaffold adapted from
`0047_3._quantum_measurement_process_imple.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G214

noncomputable section

structure MeasurementProcess where
  w0 : ℝ
  w1 : ℝ
  w0_nonneg : 0 ≤ w0
  w1_nonneg : 0 ≤ w1

def totalWeight (M : MeasurementProcess) : ℝ := M.w0 + M.w1

def normalized0 (M : MeasurementProcess) : ℝ := M.w0 / (1 + totalWeight M)

def normalized1 (M : MeasurementProcess) : ℝ := M.w1 / (1 + totalWeight M)

def communicationAsMeasurement (M : MeasurementProcess) : ℝ :=
  normalized0 M + normalized1 M

theorem totalWeight_nonneg (M : MeasurementProcess) : 0 ≤ totalWeight M := by
  unfold totalWeight
  linarith [M.w0_nonneg, M.w1_nonneg]

theorem normalizer_pos (M : MeasurementProcess) : 0 < 1 + totalWeight M := by
  have htw : 0 ≤ totalWeight M := totalWeight_nonneg M
  linarith

theorem normalized0_nonneg (M : MeasurementProcess) : 0 ≤ normalized0 M := by
  unfold normalized0
  exact div_nonneg M.w0_nonneg (le_of_lt (normalizer_pos M))

theorem normalized1_nonneg (M : MeasurementProcess) : 0 ≤ normalized1 M := by
  unfold normalized1
  exact div_nonneg M.w1_nonneg (le_of_lt (normalizer_pos M))

theorem communicationAsMeasurement_eq_ratio (M : MeasurementProcess) :
    communicationAsMeasurement M = totalWeight M / (1 + totalWeight M) := by
  unfold communicationAsMeasurement normalized0 normalized1 totalWeight
  ring

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G214
