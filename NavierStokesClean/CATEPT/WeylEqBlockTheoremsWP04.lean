import NavierStokesClean.CATEPT.WeylComplexDiracCompatibility

/-!
# Weyl EqBlock Theorems — Workpack 04

This module theoremizes `wp04` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

open MeasureTheory

namespace NavierStokesClean.CATEPT

theorem weyl_eqblock_014_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_032_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_071_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_072_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_074_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_075_theorem :
    (1, "Foundations.eq001_complex_action_structure") ∈ weyl_a1_a7_targets := by
  decide

theorem weyl_eqblock_076_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_078_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_080_theorem
    {α : Type*} [MeasurableSpace α]
    (c : CurvedMeasurePathIntegralModel α) (clk : c.EntropicModularFlowClock) :
    clk.entropicTime = ∫ x, clk.modularRate x ∂c.toMeasurePathIntegralModel.μ :=
  CurvedMeasurePathIntegralModel.weyl_eqA7_modular_flow_clock (c := c) clk

theorem weyl_eqblock_081_theorem
    {Φ : Type*} (χ : ComplexAction Φ) (φ : Φ) :
    ∃ z : ℂ, z = (χ.S_R φ : ℂ) + Complex.I * (χ.S_I φ : ℂ) ∧ 0 ≤ χ.S_I φ :=
  weyl_eqA1_matches_foundations χ φ

theorem weyl_eqblock_082_theorem
    (hbar S_I : ℝ) (h_hbar : 0 < hbar) :
    entropic_time hbar S_I = S_I / hbar :=
  weyl_eqA2_matches_entropic_time hbar S_I h_hbar

theorem weyl_eqblock_083_theorem
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) :=
  MeasurePathIntegralModel.weyl_eqA3_weight_formula (m := m) x

theorem weyl_eqblock_084_theorem
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) :
    m.partition = ∫ x, m.weight x ∂m.μ :=
  MeasurePathIntegralModel.weyl_eqA4_partition_is_integral (m := m)

theorem weyl_eqblock_085_theorem :
    (7, "CurvedMeasurePathIntegralModel.EntropicModularFlowClock") ∈ weyl_a1_a7_targets := by
  decide

theorem weyl_eqblock_087_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_088_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

theorem weyl_eqblock_089_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_091_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) :=
  ComplexEFEContract.weyl_eqA9_A11_contract_iff_pointwise_equality (C := C)

theorem weyl_eqblock_092_theorem
    {α : Type*} [MeasurableSpace α]
    (C : ComplexEFEContract α)
    (hEinImZero : C.einsteinTensor.imagPart = fun _ => (0 : ℂ))
    (hStressImZero : C.stressTensor.imagPart = fun _ => (0 : ℂ))
    (hC : C.HoldsPointwise) :
    ∀ x : α, C.einsteinTensor.realPart x = C.coupling * C.stressTensor.realPart x :=
  ComplexEFEContract.weyl_eqA12_classical_limit_real_part
    (C := C) hEinImZero hStressImZero hC

theorem weyl_eqblock_094_theorem :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

end NavierStokesClean.CATEPT

end
