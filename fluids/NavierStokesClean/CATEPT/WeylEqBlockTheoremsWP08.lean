import NavierStokesClean.CATEPT.BianchiComplexEFEContracts

/-!
# Weyl EqBlock Theorems — Workpack 08

This module theoremizes `wp08` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

namespace NavierStokesClean.CATEPT

theorem weyl_eqblock_090_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.stressComplex = C.stressTensor.toComplex := rfl

theorem weyl_eqblock_097_theorem
    {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α) :
    C.stressComplex = C.stressTensor.toComplex := rfl

theorem weyl_eqblock_098_theorem
    {α : Type*} [MeasurableSpace α]
    (D : ComplexFieldDivergence α)
    (C : ComplexEFEContract α)
    (hC : C.HoldsPointwise) :
    D.ContractedConservation C :=
  ComplexFieldDivergence.contractedConservation_of_holdsPointwise (D := D) C hC

end NavierStokesClean.CATEPT

end
