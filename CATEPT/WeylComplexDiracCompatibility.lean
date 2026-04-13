import NavierStokesClean.CATEPT.WeylComplexDiracCoreEquations
import NavierStokesClean.CATEPT.Foundations
import NavierStokesClean.CATEPT.PaperEqAliases
import NavierStokesClean.CATEPT.MeasurePathIntegral
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.CATEPT.ComplexEinsteinMTPIBridge
import NavierStokesClean.CATEPT.BianchiComplexEFEContracts
import NavierStokesClean.CATEPT.ModularFlowKucharBridge

/-!
# Weyl-Complex-Dirac Compatibility Layer

This module upgrades the extracted A1..A7 equation catalog from string-level TeX
into typed contracts over the existing CAT/EPT + MTPI + complex-EFE stack.

Design:
- keep extraction artifacts as provenance (`WeylComplexDiracCoreEquations`)
- map core equations to existing formal objects/theorems
- expose PhysLean compatibility seeds for divergence/curl identities
- avoid new axioms: this layer is a compatibility wrapper only
-/

set_option autoImplicit false

noncomputable section

open MeasureTheory
open Space

namespace NavierStokesClean.CATEPT

/-- Machine-check the extracted core-equation cardinality from A1..A7 section. -/
theorem weyl_core_equation_count_is_15 :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 := by
  decide

/-- Provenance anchor: extracted source document path. -/
def weyl_source_document : String :=
  WeylComplexDiracCoreEquations.sourceDocument

/-- Compatibility target table for the extracted A1..A7 equation set. -/
def weyl_a1_a7_targets : List (Nat × String) :=
  [ (1, "Foundations.eq001_complex_action_structure")
  , (2, "Foundations.eq003_entropic_time_def")
  , (3, "MeasurePathIntegralModel.weight / norm_weight_eq_damping")
  , (4, "MeasurePathIntegralModel.partition")
  , (5, "CurvedMeasurePathIntegralModel + ComplexEFEContract (geometric action route)")
  , (6, "CurvedMeasurePathIntegralModel.curvatureCoupledActionIm")
  , (7, "CurvedMeasurePathIntegralModel.EntropicModularFlowClock")
  ]

/-- A1 compatibility: complex action structure. -/
theorem weyl_eqA1_matches_foundations
    {Φ : Type*} (χ : ComplexAction Φ) (φ : Φ) :
    ∃ z : ℂ, z = (χ.S_R φ : ℂ) + Complex.I * (χ.S_I φ : ℂ) ∧ 0 ≤ χ.S_I φ :=
  paper_eq_1_complex_action_structure χ φ

/-- A2 compatibility: entropic time definition. -/
theorem weyl_eqA2_matches_entropic_time
    (hbar S_I : ℝ) (h_hbar : 0 < hbar) :
    entropic_time hbar S_I = S_I / hbar :=
  paper_eq_2_entropic_proper_time hbar S_I h_hbar

namespace MeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (m : MeasurePathIntegralModel α)

/-- A3 compatibility: CAT/EPT complex weight is exactly `exp(i S_R/ℏ - S_I/ℏ)`. -/
theorem weyl_eqA3_weight_formula (x : α) :
    m.weight x =
      Complex.exp
        ((-(m.actionImScaled x) : ℂ) +
          (((m.actionReScaled x : ℝ) : ℂ) * Complex.I)) :=
  rfl

/-- A3 compatibility: extracted damping factor equals norm of complex weight. -/
theorem weyl_eqA3_norm_matches_damping (x : α) :
    ‖m.weight x‖ = m.damping x :=
  m.norm_weight_eq_damping x

/-- A4 compatibility: partition functional is the Bochner integral of weight. -/
theorem weyl_eqA4_partition_is_integral :
    m.partition = ∫ x, m.weight x ∂m.μ :=
  rfl

end MeasurePathIntegralModel

namespace ComplexEFEContract

variable {α : Type*} [MeasurableSpace α] (C : ComplexEFEContract α)

/-- A9-A11 compatibility: residual-vanishing and pointwise complex-EFE equality
are equivalent presentations of the same contract. -/
theorem weyl_eqA9_A11_contract_iff_pointwise_equality :
    C.HoldsPointwise ↔ (∀ x : α, C.einsteinComplex x = C.coupling * C.stressComplex x) := by
  constructor
  · intro h x
    have hx : C.residual x = 0 := h x
    unfold residual at hx
    exact sub_eq_zero.mp hx
  · intro h
    exact C.holdsPointwise_of_eq h

/-- A12 classical limit compatibility:
if imaginary tensor components are zero, the contract reduces to a real-part
Einstein/stress relation. -/
theorem weyl_eqA12_classical_limit_real_part
    (hEinImZero : C.einsteinTensor.imagPart = fun _ => (0 : ℂ))
    (hStressImZero : C.stressTensor.imagPart = fun _ => (0 : ℂ))
    (hC : C.HoldsPointwise) :
    ∀ x : α, C.einsteinTensor.realPart x = C.coupling * C.stressTensor.realPart x := by
  intro x
  have hContract : C.einsteinComplex x = C.coupling * C.stressComplex x := by
    have hx : C.residual x = 0 := hC x
    unfold residual at hx
    exact sub_eq_zero.mp hx
  have hEin : C.einsteinComplex x = C.einsteinTensor.realPart x := by
    unfold einsteinComplex ComplexTensorField.toComplex
    simp [hEinImZero]
  have hStress : C.stressComplex x = C.stressTensor.realPart x := by
    unfold stressComplex ComplexTensorField.toComplex
    simp [hStressImZero]
  calc
    C.einsteinTensor.realPart x = C.einsteinComplex x := by simpa [hEin] using hEin.symm
    _ = C.coupling * C.stressComplex x := hContract
    _ = C.coupling * C.stressTensor.realPart x := by rw [hStress]

end ComplexEFEContract

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α] (c : CurvedMeasurePathIntegralModel α)

/-- A7 compatibility (entropic time accumulation):
clock time is represented as accumulated modular flow integral in the
curved-space CAT/EPT model. -/
theorem weyl_eqA7_modular_flow_clock
    (clk : c.EntropicModularFlowClock) :
    clk.entropicTime = ∫ x, clk.modularRate x ∂c.toMeasurePathIntegralModel.μ :=
  clk.entropicTime_eq_modularIntegral

end CurvedMeasurePathIntegralModel

/-- PhysLean compatibility bundle used by the complex-EFE/Bianchi path:
both core vector-calculus identities are available as theorems. -/
theorem weyl_physlean_bianchi_seed_pair
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
    (∇ ⬝ (∇ × f) = 0) ∧ (∇ × (∇ × f) = ∇ (∇ ⬝ f) - Δ f) := by
  exact ⟨physlean_first_bianchi_seed f hf, physlean_second_bianchi_seed f hf⟩

end NavierStokesClean.CATEPT

end
