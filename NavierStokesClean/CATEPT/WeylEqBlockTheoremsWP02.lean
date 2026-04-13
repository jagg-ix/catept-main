import NavierStokesClean.CATEPT.Foundations
import NavierStokesClean.CATEPT.MeasurePathIntegral
import NavierStokesClean.CATEPT.ModularFlowKucharBridge

/-!
# Weyl EqBlock Theorems — Workpack 02

This module theoremizes `wp02` from
`verification_results/weyl_complex_dirac/theoremization_ready_workpacks.csv`.
-/

set_option autoImplicit false

noncomputable section

open MeasureTheory

namespace NavierStokesClean.CATEPT

namespace MeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (m : MeasurePathIntegralModel α)

theorem weyl_eqblock_001_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_006_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_007_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) ∧
      m.partition = ∫ y, m.weight y ∂m.μ := by
  exact ⟨rfl, rfl⟩

theorem weyl_eqblock_015_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_018_theorem (x : α) :
    m.damping x = Real.exp (-(m.actionImScaled x)) := rfl

theorem weyl_eqblock_021_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_023_theorem (x : α) :
    m.damping x = Real.exp (-(m.actionImScaled x)) := rfl

theorem weyl_eqblock_029_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_031_theorem (x : α) :
    m.damping x = Real.exp (-(m.actionImScaled x)) := rfl

theorem weyl_eqblock_037_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_040_theorem (x : α) :
    m.damping x = Real.exp (-(m.actionImScaled x)) := rfl

theorem weyl_eqblock_045_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) ∧
      m.partition = ∫ y, m.weight y ∂m.μ := by
  exact ⟨rfl, rfl⟩

theorem weyl_eqblock_048_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_050_theorem :
    m.partition = ∫ x, m.weight x ∂m.μ := rfl

theorem weyl_eqblock_052_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) ∧
      m.partition = ∫ y, m.weight y ∂m.μ := by
  exact ⟨rfl, rfl⟩

theorem weyl_eqblock_055_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) ∧
      m.partition = ∫ y, m.weight y ∂m.μ := by
  exact ⟨rfl, rfl⟩

theorem weyl_eqblock_061_theorem (O : α → ℂ) :
    m.normalizedExpectation O = m.unnormalizedExpectation O / m.partition := rfl

theorem weyl_eqblock_108_theorem (x : α) (hbar S_I : ℝ) (h_hbar : 0 < hbar) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) ∧
      m.partition = ∫ y, m.weight y ∂m.μ ∧
      entropic_time hbar S_I = S_I / hbar := by
  exact ⟨rfl, rfl, eq003_entropic_time_def hbar S_I h_hbar⟩

theorem weyl_eqblock_139_theorem (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) := rfl

end MeasurePathIntegralModel

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (c : CurvedMeasurePathIntegralModel α)

theorem weyl_eqblock_141_theorem
    {s : c.ComplexSchrodingerFunctionalScheme}
    (uv : c.ExplicitUVConvergenceAnalysis s) (N : Nat) :
    ‖uv.cutoffPartition N - uv.continuumPartition‖ ≤
      Real.exp (-(uv.entropicRegStrength * (N : ℝ))) :=
  CurvedMeasurePathIntegralModel.ExplicitUVConvergenceAnalysis.tailBound (c := c) uv N

end CurvedMeasurePathIntegralModel

end NavierStokesClean.CATEPT

end
