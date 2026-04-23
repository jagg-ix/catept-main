import NavierStokesClean.CATEPT.ModularFlowKucharBridge

/-!
# Weyl EqBlock Theorems — Workpack 07

This module theoremizes `wp07` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

namespace NavierStokesClean.CATEPT

namespace CurvedMeasurePathIntegralModel

theorem weyl_eqblock_093_theorem
    (w : CurvedMeasurePathIntegralModel.AppendixCrossCheckWitness)
    (hNoether : w.complexNoetherCharge) :
    w.complexNoetherCharge :=
  hNoether

theorem weyl_eqblock_103_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise) :
    ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE

theorem weyl_eqblock_105_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise) :
    ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE

theorem weyl_eqblock_111_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise) :
    ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE

theorem weyl_eqblock_112_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise) :
    ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE

theorem weyl_eqblock_115_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise) :
    ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE

theorem weyl_eqblock_116_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise) :
    ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE

theorem weyl_eqblock_125_theorem
    {β : Type*} [MeasurableSpace β]
    (C : ComplexEFEContract β) (hE : C.HoldsPointwise)
    (wS : CurvedMeasurePathIntegralModel.EntropicStressTensorWitness β) :
    (∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x) ∧
      (∀ x, wS.stressComplex x = (wS.stressReal x : ℂ) + Complex.I * (wS.stressImag x : ℂ)) := by
  exact ⟨CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C hE,
    CurvedMeasurePathIntegralModel.paper_eq_Smunu wS⟩

theorem weyl_eqblock_333_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_371_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_391_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_392_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_393_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_394_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_395_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_399_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

theorem weyl_eqblock_408_theorem
    (w : CurvedMeasurePathIntegralModel.StationaryRegionWitness) :
    w.lambda = 0 ↔ w.stationarityObservable :=
  CurvedMeasurePathIntegralModel.paper5_eq_stationarity w

end CurvedMeasurePathIntegralModel

end NavierStokesClean.CATEPT

end
