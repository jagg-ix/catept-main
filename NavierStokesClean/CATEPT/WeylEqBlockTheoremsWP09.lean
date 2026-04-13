import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral

/-!
# Weyl EqBlock Theorems — Workpack 09

This module theoremizes `wp09` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

namespace NavierStokesClean.CATEPT

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : CurvedMeasurePathIntegralModel α)

theorem weyl_eqblock_086_theorem
    (ops : CurvedOperatorStack α) (ξ : ℝ) (x : α) :
    curvatureCoupledActionIm (c := c) ops ξ x = c.actionIm x + ξ * ops.scalarCurvature x := rfl

theorem weyl_eqblock_110_theorem
    (ops : CurvedOperatorStack α) (ξ : ℝ) (x : α) :
    curvatureCoupledActionIm (c := c) ops ξ x = c.actionIm x + ξ * ops.scalarCurvature x := rfl

end CurvedMeasurePathIntegralModel

end NavierStokesClean.CATEPT

end
