import NavierStokesClean.CATEPT.ModularFlowKucharBridge
import NavierStokesClean.CATEPT.WeylComplexDiracCompatibility
import NavierStokesClean.CATEPT.SchwarzschildCurvatureIdentities
import NavierStokesClean.CATEPT.External.NoFasterThanLightInterface
import NavierStokesClean.CATEPT.External.NoFasterThanLightTranslatorSnapshot
import NavierStokesClean.CATEPT.External.IsabelleMarriesDiracInterface
import CATEPTMain.AFPBridge.L2TimeIntegral

/-!
# Integrated Equation Contracts

This module provides named theorem contracts aligned with existing CAT/EPT,
GR, AFP, and Isabelle/Dirac bridge infrastructure.
-/

set_option autoImplicit false

open Filter MeasureTheory

namespace NavierStokesClean.CATEPT.External
namespace IntegratedEquationContracts

noncomputable section

namespace CurvedMeasurePathIntegralModel

variable {α : Type*} [MeasurableSpace α]
variable (c : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel α)

/-- Entropic time equals accumulated modular-flow integral. -/
theorem entropicTime_eq_modularFlowIntegral
    (clk : c.EntropicModularFlowClock) :
    clk.entropicTime = ∫ x, clk.modularRate x ∂ c.toMeasurePathIntegralModel.μ :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper5_eq_tauent (c := c) clk

/-- Page-Wootters relational time equals Connes-Rovelli thermal time. -/
theorem relationalTime_eq_thermalTimeBridge
    (clk : c.EntropicModularFlowClock)
    (pw : c.PageWoottersClock clk)
    (cr : c.ConnesRovelliClock clk) :
    pw.relationalTime = cr.thermalTime :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper5_eq_bridge_main (c := c) clk pw cr

/-- Regularized complex-action kernel identity. -/
theorem schrodingerKernel_eq_complexActionForm
    (s : c.ComplexSchrodingerFunctionalScheme) (x : α) :
    s.kernel x =
      Complex.exp
        ((-(s.entropicReg x) : ℂ) + (((s.phase x : ℝ) : ℂ) * Complex.I)) :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.ComplexSchrodingerFunctionalScheme.paper5_eq_complex_action
    (s := s) x

/-- Kernel damping-side norm bound. -/
theorem schrodingerKernel_norm_le_one
    (s : c.ComplexSchrodingerFunctionalScheme) (x : α) :
    ‖s.kernel x‖ ≤ 1 :=
  s.norm_kernel_le_one x

/-- Bell observable as entropic-rate transform. -/
theorem bellObservable_eq_expEntropicRate_sub_one
    (w : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.BellWitness) :
    w.bellObservable = Real.exp w.entropicRate - 1 :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper5_eq_Bell_k w

/-- Tsirelson calibration from a logarithmic rate witness. -/
theorem bellObservable_eq_twoSqrtTwo_of_logRateCalibration
    (w : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.BellWitness)
    (hRate : w.entropicRate = Real.log (2 * Real.sqrt 2 + 1)) :
    w.bellObservable = 2 * Real.sqrt 2 := by
  calc
    w.bellObservable = Real.exp w.entropicRate - 1 :=
      NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper5_eq_Bell_k w
    _ = Real.exp (Real.log (2 * Real.sqrt 2 + 1)) - 1 := by simp [hRate]
    _ = 2 * Real.sqrt 2 := by
      have hpos : 0 < 2 * Real.sqrt 2 + 1 := by
        have hsqrt_nonneg : 0 ≤ Real.sqrt 2 := Real.sqrt_nonneg 2
        nlinarith
      rw [Real.exp_log hpos]
      ring

/-- Wheeler-DeWitt contract rewrite. -/
theorem wheelerDeWitt_constraint_rewrite
    (w : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.WheelerDeWittWitness) :
    w.HC = -w.HS :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper_eq_WDW w

/-- Jacobson correspondence contract. -/
theorem jacobson_thermodynamicLaw_implies_einstein
    (w : NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.JacobsonCorrespondenceWitness) :
    w.thermodynamicLaw → w.emergentEinstein :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper_eq_JAC w

/-- Pointwise complex Einstein equation from residual closure. -/
theorem complexEinstein_pointwise_of_holdsPointwise
    {β : Type*} [MeasurableSpace β]
    (C : NavierStokesClean.CATEPT.ComplexEFEContract β) :
    C.HoldsPointwise → ∀ x : β, C.einsteinComplex x = C.coupling * C.stressComplex x :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper_eq_complex_einstein C

/-- Contracted conservation from complex-Einstein closure. -/
theorem contractedConservation_of_complexEinsteinClosure
    {β : Type*} [MeasurableSpace β]
    (C : NavierStokesClean.CATEPT.ComplexEFEContract β)
    (D : NavierStokesClean.CATEPT.ComplexFieldDivergence β)
    (hE : C.HoldsPointwise) :
    C.HoldsPointwise ∧ D.ContractedConservation C :=
  NavierStokesClean.CATEPT.CurvedMeasurePathIntegralModel.paper_sec_einstein_anchor C D hE

end CurvedMeasurePathIntegralModel

/-- PhysLean Bianchi-seed pair exposed through Weyl/Dirac compatibility. -/
theorem physlean_bianchi_seed_pair
    (f : Space → EuclideanSpace ℝ (Fin 3))
    (hf : ContDiff ℝ 2 f) :
    (Space.div (Space.curl f) = 0) ∧
      (Space.curl (Space.curl f) = Space.grad (Space.div f) - Space.laplacianVec f) :=
  NavierStokesClean.CATEPT.weyl_physlean_bianchi_seed_pair f hf

/-- Schwarzschild `g_tt` component is non-constant in radius. -/
theorem schwarzschild_tt_component_nonconstant
    (M : ℝ) (hM : M ≠ 0) :
    NavierStokesClean.CATEPT.schwarzschildMetric M
        NavierStokesClean.CATEPT.schwarzschildPointR3
        NavierStokesClean.CATEPT.coordT
        NavierStokesClean.CATEPT.coordT ≠
      NavierStokesClean.CATEPT.schwarzschildMetric M
        NavierStokesClean.CATEPT.schwarzschildPointR4
        NavierStokesClean.CATEPT.coordT
        NavierStokesClean.CATEPT.coordT :=
  NavierStokesClean.CATEPT.schwarzschildMetric_nonconstant_tt M hM

/-- No-superluminal bound from AFP no-FTL certificate. -/
theorem noSuperluminal_signal_le_light
    (w : NavierStokesClean.CATEPT.External.NoFasterThanLightCertificate) :
    w.signalSpeed ≤ w.lightSpeed :=
  w.no_superluminal

/-- Causal-separation transfer to signal speed under certificate bounds. -/
theorem causalSeparated_transfer_to_signalSpeed
    (w : NavierStokesClean.CATEPT.External.NoFasterThanLightCertificate)
    {Δx Δt : ℝ}
    (hsep : NavierStokesClean.CATEPT.External.CausalSeparated w.lightSpeed Δx Δt) :
    NavierStokesClean.CATEPT.External.CausalSeparated w.signalSpeed Δx Δt :=
  w.causal_transfer hsep

/-- Strict no-FTL translator snapshot compatibility with certificate. -/
theorem noFtlSnapshot_compatible_with_certificate
    (w : NavierStokesClean.CATEPT.External.NoFasterThanLightCertificate) :
    NavierStokesClean.CATEPT.External.noFtlStrictSnapshot.theoremCount = 246 ∧
      w.signalSpeed ≤ w.lightSpeed :=
  NavierStokesClean.CATEPT.External.NoFasterThanLightCertificate.compatible_with_noFtlStrictSnapshot w

/-- Isabelle-Marries-Dirac anchor on core equation count. -/
theorem isabelleDirac_coreEquationCount_anchor :
    NavierStokesClean.CATEPT.WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  NavierStokesClean.CATEPT.External.isabelle_dirac_core_equation_anchor

/-- Isabelle protocol-stack contract exposure. -/
theorem isabelleDirac_protocolStack_contract
    (w : NavierStokesClean.CATEPT.External.IsabelleMarriesDiracCertificate) :
    w.hasTeleportationProtocol ∧ w.hasEntanglementProtocol ∧ w.hasGateModelClosure :=
  NavierStokesClean.CATEPT.External.IsabelleMarriesDiracCertificate.protocol_stack w

namespace AFP

/-- Cauchy-Schwarz interval bound from AFP L2 bridge. -/
theorem interval_norm_le_sqrt_interval_mul_sqrt_energy
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {s t : ℝ} (hst : s ≤ t) (g : ℝ → E)
    (hg_sq : IntegrableOn (fun r => ‖g r‖ ^ 2) (Set.Icc s t) volume) :
    ‖∫ r in Set.Icc s t, g r‖ ≤
      Real.sqrt (t - s) * Real.sqrt (∫ r in Set.Icc s t, ‖g r‖ ^ 2) :=
  CATEPTMain.AFPBridge.L2TimeIntegral.interval_norm_le_sqrt_mul_sqrt_sq hst g hg_sq

/-- Squared Bochner-integral bound from AFP L2 bridge. -/
theorem sq_norm_integral_le_interval_measure_mul_energy
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {a b : ℝ} (hab : a ≤ b) (f : ℝ → E)
    (hf_sq : IntegrableOn (fun x => ‖f x‖ ^ 2) (Set.Icc a b) volume) :
    ‖∫ x in Set.Icc a b, f x‖ ^ 2 ≤
      (b - a) * ∫ x in Set.Icc a b, ‖f x‖ ^ 2 :=
  CATEPTMain.AFPBridge.L2TimeIntegral.sq_norm_setIntegral_le_measure_mul_setIntegral_sq hab f hf_sq

end AFP

end

end IntegratedEquationContracts
end NavierStokesClean.CATEPT.External
