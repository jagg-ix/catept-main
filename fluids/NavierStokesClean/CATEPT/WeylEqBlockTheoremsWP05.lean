import NavierStokesClean.CATEPT.WeylComplexDiracCompatibility

/-!
# Weyl EqBlock Theorems — Workpack 05

This module theoremizes `wp05` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

open MeasureTheory

namespace NavierStokesClean.CATEPT

theorem weyl_eqblock_095_theorem
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) (clk : c.EntropicModularFlowClock) :
    clk.entropicTime = ∫ x, clk.modularRate x ∂c.toMeasurePathIntegralModel.μ :=
  CurvedMeasurePathIntegralModel.weyl_eqA7_modular_flow_clock (c := c) clk

theorem weyl_eqblock_096_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_104_theorem
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α)
    (hEinImZero : C.einsteinTensor.imagPart = fun _ => (0 : ℂ))
    (hStressImZero : C.stressTensor.imagPart = fun _ => (0 : ℂ))
    (hC : C.HoldsPointwise) :
    ∀ x : α, C.einsteinTensor.realPart x = C.coupling * C.stressTensor.realPart x :=
  ComplexEFEContract.weyl_eqA12_classical_limit_real_part
    (C := C) hEinImZero hStressImZero hC

theorem weyl_eqblock_537_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_539_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_550_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_557_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_566_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

end NavierStokesClean.CATEPT

end
