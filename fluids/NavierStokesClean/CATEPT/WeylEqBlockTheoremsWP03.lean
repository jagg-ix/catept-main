import NavierStokesClean.CATEPT.MeasurePathIntegral

/-!
# Weyl EqBlock Theorems — Workpack 03

This module theoremizes `wp03` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

namespace NavierStokesClean.CATEPT

namespace MeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (m : MeasurePathIntegralModel α)

theorem weyl_eqblock_257_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_265_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_279_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_286_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_300_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_302_theorem (x : α) :
    m.phase x = Complex.exp (((m.actionReScaled x : ℝ) : ℂ) * Complex.I) := rfl

theorem weyl_eqblock_304_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_317_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_320_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_338_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

theorem weyl_eqblock_339_theorem (x : α) :
    ‖m.weight x‖ = m.damping x :=
  m.norm_weight_eq_damping x

theorem weyl_eqblock_366_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

end MeasurePathIntegralModel

end NavierStokesClean.CATEPT

end
