import CATEPTMain.Analysis.CPM.Coproduct_Measure
import Mathlib

set_option autoImplicit false

namespace CATEPTMain.Analysis.CPM.Coproduct_Measure_Additional

private axiom coprodMeasure_lintegral_law {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i))
    (f : Sigma alpha -> ENNReal)
    (hf : Measurable f) :
    MeasureTheory.lintegral (CATEPTMain.Analysis.CPM.coprodMeasure mu) f =
    tsum (fun i : I =>
      MeasureTheory.lintegral (mu i) (fun x => f (Sigma.mk i x)))

theorem coprodMeasure_lintegral {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i))
    (f : Sigma alpha -> ENNReal)
    (hf : Measurable f) :
    MeasureTheory.lintegral (CATEPTMain.Analysis.CPM.coprodMeasure mu) f =
    tsum (fun i : I =>
      MeasureTheory.lintegral (mu i) (fun x => f (Sigma.mk i x))) :=
  coprodMeasure_lintegral_law mu f hf

private axiom coprodMeasure_integral_formula_law {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i))
    (f : Sigma alpha -> Real)
    (hf : MeasureTheory.Integrable f (CATEPTMain.Analysis.CPM.coprodMeasure mu)) :
    MeasureTheory.integral (CATEPTMain.Analysis.CPM.coprodMeasure mu) f =
    tsum (fun i : I =>
      MeasureTheory.integral (mu i) (fun x => f (Sigma.mk i x)))

theorem coprodMeasure_integral_formula {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i))
    (f : Sigma alpha -> Real)
    (hf : MeasureTheory.Integrable f (CATEPTMain.Analysis.CPM.coprodMeasure mu)) :
    MeasureTheory.integral (CATEPTMain.Analysis.CPM.coprodMeasure mu) f =
    tsum (fun i : I =>
      MeasureTheory.integral (mu i) (fun x => f (Sigma.mk i x))) :=
  coprodMeasure_integral_formula_law mu f hf

private axiom coprodMeasure_pushforward_law {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    {N : Type} [MeasurableSpace N]
    (mu : forall i : I, MeasureTheory.Measure (alpha i))
    (f : Sigma alpha -> N)
    (hf : Measurable f) :
    MeasureTheory.Measure.map f (CATEPTMain.Analysis.CPM.coprodMeasure mu) =
    MeasureTheory.Measure.sum (fun i : I =>
      MeasureTheory.Measure.map (fun x => f (Sigma.mk i x)) (mu i))

theorem coprodMeasure_pushforward {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    {N : Type} [MeasurableSpace N]
    (mu : forall i : I, MeasureTheory.Measure (alpha i))
    (f : Sigma alpha -> N)
    (hf : Measurable f) :
    MeasureTheory.Measure.map f (CATEPTMain.Analysis.CPM.coprodMeasure mu) =
    MeasureTheory.Measure.sum (fun i : I =>
      MeasureTheory.Measure.map (fun x => f (Sigma.mk i x)) (mu i)) :=
  coprodMeasure_pushforward_law mu f hf

private axiom coprodMeasure_prod_distrib_law {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i)) :
    CATEPTMain.Analysis.CPM.IsSFinite (CATEPTMain.Analysis.CPM.coprodMeasure mu)

theorem coprodMeasure_prod_distrib {I : Type} [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i)) :
    CATEPTMain.Analysis.CPM.IsSFinite (CATEPTMain.Analysis.CPM.coprodMeasure mu) :=
  coprodMeasure_prod_distrib_law mu

private axiom coprodMeasure_prob_total_law {I : Type} [Fintype I] [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i)) :
    CATEPTMain.Analysis.CPM.coprodMeasure mu Set.univ =
    tsum (fun i : I => mu i Set.univ)

theorem coprodMeasure_prob_total {I : Type} [Fintype I] [Countable I] {alpha : I -> Type}
    [forall i, MeasurableSpace (alpha i)]
    (mu : forall i : I, MeasureTheory.Measure (alpha i)) :
    CATEPTMain.Analysis.CPM.coprodMeasure mu Set.univ =
    tsum (fun i : I => mu i Set.univ) :=
  coprodMeasure_prob_total_law mu

end CATEPTMain.Analysis.CPM.Coproduct_Measure_Additional
