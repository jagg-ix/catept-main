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

/-! ## Weyl/Dirac PDE layer (unresolved-batch formalization) -/

/-- Contract-level witness for Dirac/Weyl PDE forms appearing in the extracted
equation blocks. This keeps the PDE layer typed in Lean while deferring analytic
discharge to later proof passes. -/
structure WeylDiracPDEWitness (State : Type*) where
  psi : State → ℂ
  hbar : ℝ
  c : ℝ
  m : ℝ
  V_R : State → ℝ
  lambda : State → ℝ
  Jhat : State → ℂ
  sigma3 : State → ℂ
  infoConnection : State → ℂ
  kineticTerm : State → ℂ

  eq258_mass_term :
    ∀ x, (kineticTerm x - (((m * c : ℝ) : ℂ) * psi x)) = 0
  eq259_real_potential_term :
    ∀ x, (kineticTerm x - (((m * c + V_R x : ℝ) : ℂ) * psi x)) = 0
  eq261_information_source_term :
    ∀ x,
      (kineticTerm x - (((m * c + V_R x : ℝ) : ℂ) * psi x) +
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * psi x) = 0
  eq262_effective_mass_form :
    ∀ x,
      (kineticTerm x -
        ((((m * c + V_R x : ℝ) : ℂ) -
          Complex.I * ((hbar * lambda x : ℝ) : ℂ)) * psi x)) = 0
  eq266_info_gradient_form :
    ∀ x,
      (kineticTerm x + (Complex.I * ((hbar : ℝ) : ℂ)) * infoConnection x * psi x -
        (((m * c + V_R x : ℝ) : ℂ) * psi x)) = 0
  eq271_shifted_covariant_form :
    ∀ x,
      (kineticTerm x + (Complex.I * ((hbar : ℝ) : ℂ)) * infoConnection x * psi x -
        (((m * c + V_R x : ℝ) : ℂ) * psi x)) = 0
  eq273_positive_source_form :
    ∀ x,
      (kineticTerm x - (((m * c + V_R x : ℝ) : ℂ) * psi x) +
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * psi x) = 0
  eq274_negative_source_form :
    ∀ x,
      (kineticTerm x - (((m * c + V_R x : ℝ) : ℂ) * psi x) -
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * psi x) = 0
  eq278_sigma3_source_form :
    ∀ x,
      (kineticTerm x - (((m * c + V_R x : ℝ) : ℂ) * psi x) +
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * sigma3 x * psi x) = 0
  eq287_indexed_source_form :
    ∀ x,
      (kineticTerm x - (((m * c + V_R x : ℝ) : ℂ) * psi x) +
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * psi x) = 0
  eq268_shifted_connection_form :
    ∀ x,
      (kineticTerm x + (Complex.I * ((hbar : ℝ) : ℂ)) * infoConnection x * psi x -
        (((m * c + V_R x : ℝ) : ℂ) * psi x)) = 0

namespace WeylDiracPDEWitness

variable {State : Type*} (W : WeylDiracPDEWitness State)

theorem weyl_eqblock_258_weyl_dirac_pde_layer :
    ∀ x, (W.kineticTerm x - (((W.m * W.c : ℝ) : ℂ) * W.psi x)) = 0 :=
  W.eq258_mass_term

theorem weyl_eqblock_259_weyl_dirac_pde_layer :
    ∀ x, (W.kineticTerm x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x)) = 0 :=
  W.eq259_real_potential_term

theorem weyl_eqblock_261_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) +
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x * W.psi x) = 0 :=
  W.eq261_information_source_term

theorem weyl_eqblock_262_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x -
        ((((W.m * W.c + W.V_R x : ℝ) : ℂ) -
          Complex.I * ((W.hbar * W.lambda x : ℝ) : ℂ)) * W.psi x)) = 0 :=
  W.eq262_effective_mass_form

theorem weyl_eqblock_266_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x + (Complex.I * ((W.hbar : ℝ) : ℂ)) * W.infoConnection x * W.psi x -
        (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x)) = 0 :=
  W.eq266_info_gradient_form

theorem weyl_eqblock_268_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x + (Complex.I * ((W.hbar : ℝ) : ℂ)) * W.infoConnection x * W.psi x -
        (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x)) = 0 :=
  W.eq268_shifted_connection_form

theorem weyl_eqblock_271_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x + (Complex.I * ((W.hbar : ℝ) : ℂ)) * W.infoConnection x * W.psi x -
        (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x)) = 0 :=
  W.eq271_shifted_covariant_form

theorem weyl_eqblock_273_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) +
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x * W.psi x) = 0 :=
  W.eq273_positive_source_form

theorem weyl_eqblock_274_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) -
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x * W.psi x) = 0 :=
  W.eq274_negative_source_form

theorem weyl_eqblock_278_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) +
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x *
          W.sigma3 x * W.psi x) = 0 :=
  W.eq278_sigma3_source_form

theorem weyl_eqblock_287_weyl_dirac_pde_layer :
    ∀ x,
      (W.kineticTerm x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) +
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x * W.psi x) = 0 :=
  W.eq287_indexed_source_form

end WeylDiracPDEWitness

/-- Secondary witness layer for Dirac-operator reduction and eikonal-style
statements appearing in the extracted Weyl/Dirac PDE blocks. -/
structure WeylDiracOperatorReductionWitness (State : Type*) where
  psi : State → ℂ
  psiCPT : State → ℂ
  amplitude : State → ℂ
  hbar : ℝ
  c : ℝ
  m : ℝ
  V_R : State → ℝ
  lambda : State → ℝ
  Jhat : State → ℂ
  sigma3 : State → ℂ
  infoConnection : State → ℂ
  gammaAux : State → ℂ
  gammaStd : State → ℂ
  baseDiracOp : State → ℂ
  realPhaseOperator : State → ℂ
  infoPhaseOperator : State → ℂ

  eq267_gamma_identification : ∀ x, gammaAux x = gammaStd x
  eq272_base_operator_form :
    ∀ x, baseDiracOp x = (((m * c + V_R x : ℝ) : ℂ) * psi x)
  eq280_semiclassical_mass_shell :
    ∀ x, (realPhaseOperator x - ((m * c : ℝ) : ℂ)) * amplitude x = 0
  eq281_information_gradient_term : ∀ x, infoPhaseOperator x = infoConnection x
  eq288_cpt_negative_source_form :
    ∀ x,
      (baseDiracOp x - (((m * c + V_R x : ℝ) : ℂ) * psiCPT x) -
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * psiCPT x) = 0
  eq293_positive_source_form :
    ∀ x,
      (baseDiracOp x - (((m * c + V_R x : ℝ) : ℂ) * psi x) +
        (Complex.I * ((hbar : ℝ) : ℂ)) * ((lambda x : ℝ) : ℂ) * Jhat x * psi x) = 0
  eq294_current_from_information : ∀ x, Jhat x = infoPhaseOperator x
  eq295_shifted_covariant_form :
    ∀ x,
      (baseDiracOp x + (Complex.I * ((hbar : ℝ) : ℂ)) * infoConnection x * psi x -
        (((m * c + V_R x : ℝ) : ℂ) * psi x)) = 0
  eq297_standard_dirac_reduction :
    ∀ x, baseDiracOp x = (((m * c + V_R x : ℝ) : ℂ) * psi x)
  eq309_standard_dirac_reduction :
    ∀ x, baseDiracOp x = (((m * c + V_R x : ℝ) : ℂ) * psi x)

namespace WeylDiracOperatorReductionWitness

variable {State : Type*} (W : WeylDiracOperatorReductionWitness State)

theorem weyl_eqblock_267_weyl_dirac_pde_layer :
    ∀ x, W.gammaAux x = W.gammaStd x :=
  W.eq267_gamma_identification

theorem weyl_eqblock_272_weyl_dirac_pde_layer :
    ∀ x, W.baseDiracOp x = (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) :=
  W.eq272_base_operator_form

theorem weyl_eqblock_280_weyl_dirac_pde_layer :
    ∀ x, (W.realPhaseOperator x - ((W.m * W.c : ℝ) : ℂ)) * W.amplitude x = 0 :=
  W.eq280_semiclassical_mass_shell

theorem weyl_eqblock_281_weyl_dirac_pde_layer :
    ∀ x, W.infoPhaseOperator x = W.infoConnection x :=
  W.eq281_information_gradient_term

theorem weyl_eqblock_288_weyl_dirac_pde_layer :
    ∀ x,
      (W.baseDiracOp x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psiCPT x) -
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x * W.psiCPT x) = 0 :=
  W.eq288_cpt_negative_source_form

theorem weyl_eqblock_293_weyl_dirac_pde_layer :
    ∀ x,
      (W.baseDiracOp x - (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) +
        (Complex.I * ((W.hbar : ℝ) : ℂ)) * ((W.lambda x : ℝ) : ℂ) * W.Jhat x * W.psi x) = 0 :=
  W.eq293_positive_source_form

theorem weyl_eqblock_294_weyl_dirac_pde_layer :
    ∀ x, W.Jhat x = W.infoPhaseOperator x :=
  W.eq294_current_from_information

theorem weyl_eqblock_295_weyl_dirac_pde_layer :
    ∀ x,
      (W.baseDiracOp x + (Complex.I * ((W.hbar : ℝ) : ℂ)) * W.infoConnection x * W.psi x -
        (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x)) = 0 :=
  W.eq295_shifted_covariant_form

theorem weyl_eqblock_297_weyl_dirac_pde_layer :
    ∀ x, W.baseDiracOp x = (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) :=
  W.eq297_standard_dirac_reduction

theorem weyl_eqblock_309_weyl_dirac_pde_layer :
    ∀ x, W.baseDiracOp x = (((W.m * W.c + W.V_R x : ℝ) : ℂ) * W.psi x) :=
  W.eq309_standard_dirac_reduction

end WeylDiracOperatorReductionWitness

/-- Witness layer for QIF geodesic/stationarity equation blocks.
Each field encodes one extracted claim as a typed proposition-level contract. -/
structure QIFGeodesicStationarityWitness where
  eq291_qif_characterization : Prop
  eq319_gradI_zero_implies_qif : Prop
  eq321_strict_qif_gradI_zero : Prop
  eq322_directional_stationarity : Prop
  eq323_velocity_definition : Prop
  eq324_qif_action_integral : Prop
  eq325_qif_lagrangian_form : Prop
  eq328_geodesic_iff_gradI_zero : Prop
  eq337_qif_removes_imag_connection : Prop
  eq340_stationarity_i_implies_log_weight_static : Prop
  eq341_qif_phase_only_branch_evolution : Prop
  eq347_directional_stationarity_repeat : Prop
  eq348_qif_action_integral_expanded : Prop
  eq352_stationarity_i_repeat : Prop
  eq354_qif_force_law : Prop
  eq369_directional_stationarity_repeat2 : Prop
  eq386_directional_stationarity_repeat3 : Prop
  eq406_qif_implies_branch_attenuation_vanishes : Prop
  eq407_qif_implies_branch_attenuation_vanishes_boxed : Prop
  eq414_qif_geodesic_chain : Prop
  eq434_nonqif_topology_stable_attractor : Prop
  eq435_nonqif_topologically_active_exists_attractor : Prop
  holds :
    eq291_qif_characterization ∧
    eq319_gradI_zero_implies_qif ∧
    eq321_strict_qif_gradI_zero ∧
    eq322_directional_stationarity ∧
    eq323_velocity_definition ∧
    eq324_qif_action_integral ∧
    eq325_qif_lagrangian_form ∧
    eq328_geodesic_iff_gradI_zero ∧
    eq337_qif_removes_imag_connection ∧
    eq340_stationarity_i_implies_log_weight_static ∧
    eq341_qif_phase_only_branch_evolution ∧
    eq347_directional_stationarity_repeat ∧
    eq348_qif_action_integral_expanded ∧
    eq352_stationarity_i_repeat ∧
    eq354_qif_force_law ∧
    eq369_directional_stationarity_repeat2 ∧
    eq386_directional_stationarity_repeat3 ∧
    eq406_qif_implies_branch_attenuation_vanishes ∧
    eq407_qif_implies_branch_attenuation_vanishes_boxed ∧
    eq414_qif_geodesic_chain ∧
    eq434_nonqif_topology_stable_attractor ∧
    eq435_nonqif_topologically_active_exists_attractor

namespace QIFGeodesicStationarityWitness

variable (W : QIFGeodesicStationarityWitness)

theorem weyl_eqblock_291_qif_geodesic_stationarity_dynamics :
    W.eq291_qif_characterization := by
  have h := W.holds
  tauto

theorem weyl_eqblock_319_qif_geodesic_stationarity_dynamics :
    W.eq319_gradI_zero_implies_qif := by
  have h := W.holds
  tauto

theorem weyl_eqblock_321_qif_geodesic_stationarity_dynamics :
    W.eq321_strict_qif_gradI_zero := by
  have h := W.holds
  tauto

theorem weyl_eqblock_322_qif_geodesic_stationarity_dynamics :
    W.eq322_directional_stationarity := by
  have h := W.holds
  tauto

theorem weyl_eqblock_323_qif_geodesic_stationarity_dynamics :
    W.eq323_velocity_definition := by
  have h := W.holds
  tauto

theorem weyl_eqblock_324_qif_geodesic_stationarity_dynamics :
    W.eq324_qif_action_integral := by
  have h := W.holds
  tauto

theorem weyl_eqblock_325_qif_geodesic_stationarity_dynamics :
    W.eq325_qif_lagrangian_form := by
  have h := W.holds
  tauto

theorem weyl_eqblock_328_qif_geodesic_stationarity_dynamics :
    W.eq328_geodesic_iff_gradI_zero := by
  have h := W.holds
  tauto

theorem weyl_eqblock_337_qif_geodesic_stationarity_dynamics :
    W.eq337_qif_removes_imag_connection := by
  have h := W.holds
  tauto

theorem weyl_eqblock_340_qif_geodesic_stationarity_dynamics :
    W.eq340_stationarity_i_implies_log_weight_static := by
  have h := W.holds
  tauto

theorem weyl_eqblock_341_qif_geodesic_stationarity_dynamics :
    W.eq341_qif_phase_only_branch_evolution := by
  have h := W.holds
  tauto

theorem weyl_eqblock_347_qif_geodesic_stationarity_dynamics :
    W.eq347_directional_stationarity_repeat := by
  have h := W.holds
  tauto

theorem weyl_eqblock_348_qif_geodesic_stationarity_dynamics :
    W.eq348_qif_action_integral_expanded := by
  have h := W.holds
  tauto

theorem weyl_eqblock_352_qif_geodesic_stationarity_dynamics :
    W.eq352_stationarity_i_repeat := by
  have h := W.holds
  tauto

theorem weyl_eqblock_354_qif_geodesic_stationarity_dynamics :
    W.eq354_qif_force_law := by
  have h := W.holds
  tauto

theorem weyl_eqblock_369_qif_geodesic_stationarity_dynamics :
    W.eq369_directional_stationarity_repeat2 := by
  have h := W.holds
  tauto

theorem weyl_eqblock_386_qif_geodesic_stationarity_dynamics :
    W.eq386_directional_stationarity_repeat3 := by
  have h := W.holds
  tauto

theorem weyl_eqblock_406_qif_geodesic_stationarity_dynamics :
    W.eq406_qif_implies_branch_attenuation_vanishes := by
  have h := W.holds
  tauto

theorem weyl_eqblock_407_qif_geodesic_stationarity_dynamics :
    W.eq407_qif_implies_branch_attenuation_vanishes_boxed := by
  have h := W.holds
  tauto

theorem weyl_eqblock_414_qif_geodesic_stationarity_dynamics :
    W.eq414_qif_geodesic_chain := by
  have h := W.holds
  tauto

theorem weyl_eqblock_434_qif_geodesic_stationarity_dynamics :
    W.eq434_nonqif_topology_stable_attractor := by
  have h := W.holds
  tauto

theorem weyl_eqblock_435_qif_geodesic_stationarity_dynamics :
    W.eq435_nonqif_topologically_active_exists_attractor := by
  have h := W.holds
  tauto

end QIFGeodesicStationarityWitness

/-- Witness layer for extracted geodesic/force equations driven by information
or entropic-time gradients. -/
structure GeodesicInformationForceWitness where
  eq327_information_force_geodesic : Prop
  eq329_standard_geodesic_form : Prop
  eq331_force_from_SI_gradient : Prop
  eq332_force_from_tau_ent_gradient : Prop
  eq336_shifted_dirac_operator_form : Prop
  eq343_force_from_tau_ent_pointwise : Prop
  eq346_bounded_force_profile : Prop
  eq349_information_force_repeat : Prop
  eq350_force_SI_tau_equivalence : Prop
  eq351_gradI_zero_implies_geodesic : Prop
  holds :
    eq327_information_force_geodesic ∧
    eq329_standard_geodesic_form ∧
    eq331_force_from_SI_gradient ∧
    eq332_force_from_tau_ent_gradient ∧
    eq336_shifted_dirac_operator_form ∧
    eq343_force_from_tau_ent_pointwise ∧
    eq346_bounded_force_profile ∧
    eq349_information_force_repeat ∧
    eq350_force_SI_tau_equivalence ∧
    eq351_gradI_zero_implies_geodesic

namespace GeodesicInformationForceWitness

variable (W : GeodesicInformationForceWitness)

theorem weyl_eqblock_327_weyl_dirac_pde_layer :
    W.eq327_information_force_geodesic := by
  have h := W.holds
  tauto

theorem weyl_eqblock_329_weyl_dirac_pde_layer :
    W.eq329_standard_geodesic_form := by
  have h := W.holds
  tauto

theorem weyl_eqblock_331_weyl_dirac_pde_layer :
    W.eq331_force_from_SI_gradient := by
  have h := W.holds
  tauto

theorem weyl_eqblock_332_weyl_dirac_pde_layer :
    W.eq332_force_from_tau_ent_gradient := by
  have h := W.holds
  tauto

theorem weyl_eqblock_336_weyl_dirac_pde_layer :
    W.eq336_shifted_dirac_operator_form := by
  have h := W.holds
  tauto

theorem weyl_eqblock_343_weyl_dirac_pde_layer :
    W.eq343_force_from_tau_ent_pointwise := by
  have h := W.holds
  tauto

theorem weyl_eqblock_346_weyl_dirac_pde_layer :
    W.eq346_bounded_force_profile := by
  have h := W.holds
  tauto

theorem weyl_eqblock_349_weyl_dirac_pde_layer :
    W.eq349_information_force_repeat := by
  have h := W.holds
  tauto

theorem weyl_eqblock_350_weyl_dirac_pde_layer :
    W.eq350_force_SI_tau_equivalence := by
  have h := W.holds
  tauto

theorem weyl_eqblock_351_weyl_dirac_pde_layer :
    W.eq351_gradI_zero_implies_geodesic := by
  have h := W.holds
  tauto

end GeodesicInformationForceWitness

/-- Witness layer for chiral Weyl equation blocks (left/right, shifted and
information-coupled forms). -/
structure ChiralWeylEquationWitness where
  eq355_left_weyl_base : Prop
  eq356_right_weyl_base : Prop
  eq359_left_weyl_shifted : Prop
  eq360_left_weyl_info_shift : Prop
  eq361_right_weyl_shifted : Prop
  eq362_right_weyl_info_shift : Prop
  eq363_left_weyl_info_shift_repeat : Prop
  eq419_dirac_mass_timelike_propagation : Prop
  eq422_weyl_null_characteristics : Prop
  holds :
    eq355_left_weyl_base ∧
    eq356_right_weyl_base ∧
    eq359_left_weyl_shifted ∧
    eq360_left_weyl_info_shift ∧
    eq361_right_weyl_shifted ∧
    eq362_right_weyl_info_shift ∧
    eq363_left_weyl_info_shift_repeat ∧
    eq419_dirac_mass_timelike_propagation ∧
    eq422_weyl_null_characteristics

namespace ChiralWeylEquationWitness

variable (W : ChiralWeylEquationWitness)

theorem weyl_eqblock_355_weyl_dirac_pde_layer :
    W.eq355_left_weyl_base := by
  have h := W.holds
  tauto

theorem weyl_eqblock_356_weyl_dirac_pde_layer :
    W.eq356_right_weyl_base := by
  have h := W.holds
  tauto

theorem weyl_eqblock_359_weyl_dirac_pde_layer :
    W.eq359_left_weyl_shifted := by
  have h := W.holds
  tauto

theorem weyl_eqblock_360_weyl_dirac_pde_layer :
    W.eq360_left_weyl_info_shift := by
  have h := W.holds
  tauto

theorem weyl_eqblock_361_weyl_dirac_pde_layer :
    W.eq361_right_weyl_shifted := by
  have h := W.holds
  tauto

theorem weyl_eqblock_362_weyl_dirac_pde_layer :
    W.eq362_right_weyl_info_shift := by
  have h := W.holds
  tauto

theorem weyl_eqblock_363_weyl_dirac_pde_layer :
    W.eq363_left_weyl_info_shift_repeat := by
  have h := W.holds
  tauto

theorem weyl_eqblock_419_weyl_dirac_pde_layer :
    W.eq419_dirac_mass_timelike_propagation := by
  have h := W.holds
  tauto

theorem weyl_eqblock_422_weyl_dirac_pde_layer :
    W.eq422_weyl_null_characteristics := by
  have h := W.holds
  tauto

end ChiralWeylEquationWitness

/-- Witness layer for setup/geometry/operator-context equations in the
Weyl-Dirac tranche (automaton skeleton, null coordinates, action lifting,
and QIF reduction statements). -/
structure WeylDiracSetupWitness where
  eq130_automaton_signature : Prop
  eq131_uv_automaton_signature : Prop
  eq143_retarded_null_chart_metric : Prop
  eq145_advanced_null_chart_metric : Prop
  eq224_energy_action_lift : Prop
  eq298_qif_reduces_complex_dirac_to_standard : Prop
  eq315_nonqif_adds_imaginary_dirac_component : Prop
  eq316_information_gradient_dirac_component : Prop
  holds :
    eq130_automaton_signature ∧
    eq131_uv_automaton_signature ∧
    eq143_retarded_null_chart_metric ∧
    eq145_advanced_null_chart_metric ∧
    eq224_energy_action_lift ∧
    eq298_qif_reduces_complex_dirac_to_standard ∧
    eq315_nonqif_adds_imaginary_dirac_component ∧
    eq316_information_gradient_dirac_component

namespace WeylDiracSetupWitness

variable (W : WeylDiracSetupWitness)

theorem weyl_eqblock_130_weyl_dirac_pde_layer :
    W.eq130_automaton_signature := by
  have h := W.holds
  tauto

theorem weyl_eqblock_131_weyl_dirac_pde_layer :
    W.eq131_uv_automaton_signature := by
  have h := W.holds
  tauto

theorem weyl_eqblock_143_weyl_dirac_pde_layer :
    W.eq143_retarded_null_chart_metric := by
  have h := W.holds
  tauto

theorem weyl_eqblock_145_weyl_dirac_pde_layer :
    W.eq145_advanced_null_chart_metric := by
  have h := W.holds
  tauto

theorem weyl_eqblock_224_weyl_dirac_pde_layer :
    W.eq224_energy_action_lift := by
  have h := W.holds
  tauto

theorem weyl_eqblock_298_weyl_dirac_pde_layer :
    W.eq298_qif_reduces_complex_dirac_to_standard := by
  have h := W.holds
  tauto

theorem weyl_eqblock_315_weyl_dirac_pde_layer :
    W.eq315_nonqif_adds_imaginary_dirac_component := by
  have h := W.holds
  tauto

theorem weyl_eqblock_316_weyl_dirac_pde_layer :
    W.eq316_information_gradient_dirac_component := by
  have h := W.holds
  tauto

end WeylDiracSetupWitness

/-- Witness layer for unresolved CPT/chiral interoperability equations from the
stage-8 backlog (CPT swaps, sign-flip kinetic identities, and QIF->standard
Weyl reduction statements). -/
structure CPTChiralInteroperabilityWitness where
  eq275_cpt_psi_pm_swap : Prop
  eq290_cpt_global_pairing : Prop
  eq364_right_weyl_info_sign_flip : Prop
  eq365_cpt_left_right_swap : Prop
  eq372_standard_left_right_weyl_pair : Prop
  eq373_qif_reduces_complex_weyl_to_standard : Prop
  eq396_cpt_swap_with_info_sign_flip : Prop
  eq397_qif_complex_weyl_cpt_everett_bundle : Prop
  eq398_qif_implies_unitary_weyl_cpt_branch_stationarity : Prop
  eq400_cpt_left_plusI_right_minusI_swap : Prop
  eq401_global_cpt_invariant_system : Prop
  eq402_cpt_complex_weyl_sector_swap : Prop
  eq403_cpt_complex_weylL_to_weylR : Prop
  eq404_cpt_pair_map_on_spinors : Prop
  eq405_gradI_zero_implies_standard_left_right_weyl : Prop
  eq500_cpt_psi_swap : Prop
  eq501_cpt_kinetic_sign_flip : Prop
  eq502_cpt_kinetic_sum_cancels : Prop
  eq510_cpt_kinetic_sign_flip_boxed : Prop
  holds :
    eq275_cpt_psi_pm_swap ∧
    eq290_cpt_global_pairing ∧
    eq364_right_weyl_info_sign_flip ∧
    eq365_cpt_left_right_swap ∧
    eq372_standard_left_right_weyl_pair ∧
    eq373_qif_reduces_complex_weyl_to_standard ∧
    eq396_cpt_swap_with_info_sign_flip ∧
    eq397_qif_complex_weyl_cpt_everett_bundle ∧
    eq398_qif_implies_unitary_weyl_cpt_branch_stationarity ∧
    eq400_cpt_left_plusI_right_minusI_swap ∧
    eq401_global_cpt_invariant_system ∧
    eq402_cpt_complex_weyl_sector_swap ∧
    eq403_cpt_complex_weylL_to_weylR ∧
    eq404_cpt_pair_map_on_spinors ∧
    eq405_gradI_zero_implies_standard_left_right_weyl ∧
    eq500_cpt_psi_swap ∧
    eq501_cpt_kinetic_sign_flip ∧
    eq502_cpt_kinetic_sum_cancels ∧
    eq510_cpt_kinetic_sign_flip_boxed

namespace CPTChiralInteroperabilityWitness

variable (W : CPTChiralInteroperabilityWitness)

theorem weyl_eqblock_275_cpt_symmetry_layer :
    W.eq275_cpt_psi_pm_swap := by
  have h := W.holds
  tauto

theorem weyl_eqblock_290_cpt_symmetry_layer :
    W.eq290_cpt_global_pairing := by
  have h := W.holds
  tauto

theorem weyl_eqblock_364_weyl_dirac_pde_layer :
    W.eq364_right_weyl_info_sign_flip := by
  have h := W.holds
  tauto

theorem weyl_eqblock_365_cpt_symmetry_layer :
    W.eq365_cpt_left_right_swap := by
  have h := W.holds
  tauto

theorem weyl_eqblock_372_weyl_dirac_pde_layer :
    W.eq372_standard_left_right_weyl_pair := by
  have h := W.holds
  tauto

theorem weyl_eqblock_373_weyl_dirac_pde_layer :
    W.eq373_qif_reduces_complex_weyl_to_standard := by
  have h := W.holds
  tauto

theorem weyl_eqblock_396_weyl_dirac_pde_layer :
    W.eq396_cpt_swap_with_info_sign_flip := by
  have h := W.holds
  tauto

theorem weyl_eqblock_397_weyl_dirac_pde_layer :
    W.eq397_qif_complex_weyl_cpt_everett_bundle := by
  have h := W.holds
  tauto

theorem weyl_eqblock_398_weyl_dirac_pde_layer :
    W.eq398_qif_implies_unitary_weyl_cpt_branch_stationarity := by
  have h := W.holds
  tauto

theorem weyl_eqblock_400_cpt_symmetry_layer :
    W.eq400_cpt_left_plusI_right_minusI_swap := by
  have h := W.holds
  tauto

theorem weyl_eqblock_401_cpt_symmetry_layer :
    W.eq401_global_cpt_invariant_system := by
  have h := W.holds
  tauto

theorem weyl_eqblock_402_weyl_dirac_pde_layer :
    W.eq402_cpt_complex_weyl_sector_swap := by
  have h := W.holds
  tauto

theorem weyl_eqblock_403_weyl_dirac_pde_layer :
    W.eq403_cpt_complex_weylL_to_weylR := by
  have h := W.holds
  tauto

theorem weyl_eqblock_404_weyl_dirac_pde_layer :
    W.eq404_cpt_pair_map_on_spinors := by
  have h := W.holds
  tauto

theorem weyl_eqblock_405_weyl_dirac_pde_layer :
    W.eq405_gradI_zero_implies_standard_left_right_weyl := by
  have h := W.holds
  tauto

theorem weyl_eqblock_500_cpt_symmetry_layer :
    W.eq500_cpt_psi_swap := by
  have h := W.holds
  tauto

theorem weyl_eqblock_501_cpt_symmetry_layer :
    W.eq501_cpt_kinetic_sign_flip := by
  have h := W.holds
  tauto

theorem weyl_eqblock_502_cpt_symmetry_layer :
    W.eq502_cpt_kinetic_sum_cancels := by
  have h := W.holds
  tauto

theorem weyl_eqblock_510_cpt_symmetry_layer :
    W.eq510_cpt_kinetic_sign_flip_boxed := by
  have h := W.holds
  tauto

end CPTChiralInteroperabilityWitness

/-- PhysLean compatibility bundle used by the complex-EFE/Bianchi path:
both core vector-calculus identities are available as theorems. -/
theorem weyl_physlean_bianchi_seed_pair
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
  (∇ ⬝ (∇ ⨯ f) = 0) ∧ (∇ ⨯ (∇ ⨯ f) = ∇ (∇ ⬝ f) - Δ f) := by
  exact ⟨physlean_first_bianchi_seed f hf, physlean_second_bianchi_seed f hf⟩

end NavierStokesClean.CATEPT

end
