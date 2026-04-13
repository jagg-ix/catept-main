import NavierStokesClean.CATEPT.ModularFlowKucharBridge

/-!
Legacy-compat leverage surface for `NSCATEPTModularFlowQFTKucharBridge.lean`.
Re-exports key modular-flow/QFT/Kuchar theorems from the clean MTPI bridge.
-/

set_option autoImplicit false

open MeasureTheory Filter

namespace NavierStokesClean.LegacyCompat.NSCATEPTModularFlowQFTKucharBridge

open NavierStokesClean.CATEPT

noncomputable section

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : CurvedMeasurePathIntegralModel α)

lemma entropic_time_eq_accumulated_modular_flow
    (clk : c.EntropicModularFlowClock) :
    clk.entropicTime = ∫ x, clk.modularRate x ∂ c.toMeasurePathIntegralModel.μ :=
  CurvedMeasurePathIntegralModel.EntropicModularFlowClock.entropicTime_eq_modularIntegral (c := c) clk

lemma relational_time_eq_thermal_time
    (clk : c.EntropicModularFlowClock)
    (pw : c.PageWoottersClock clk)
    (cr : c.ConnesRovelliClock clk) :
    pw.relationalTime = cr.thermalTime :=
  CurvedMeasurePathIntegralModel.relationalTime_eq_thermalTime (c := c) clk pw cr

lemma uv_partition_converges
    {s : c.ComplexSchrodingerFunctionalScheme}
    (uv : c.ExplicitUVConvergenceAnalysis s) :
    Tendsto uv.cutoffPartition atTop (nhds uv.continuumPartition) :=
  CurvedMeasurePathIntegralModel.ExplicitUVConvergenceAnalysis.tendsto_partition (c := c) uv

end CurvedMeasurePathIntegralModel

end
end NavierStokesClean.LegacyCompat.NSCATEPTModularFlowQFTKucharBridge
