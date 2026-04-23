import CATEPTMain.CATEPT.FeynmanKacBridge
import CATEPTMain.CATEPT.ModularFlowBridge
import CATEPTMain.CATEPT.ComplexMeasureBridge
import CATEPTMain.CATEPT.CATEPTPlanckBridge
-- Note: PlanckModeBridge imports TheoryPluginArchitecture which imports CATEPTPort,
-- so it must be wired at the AFPBridge level to avoid a cycle.
/-!
# CATEPT Port — Root Module

Complex Action / Entropic Time (CAT/EPT) framework port for CATEPTMain AFPBridge.

This barrel file aggregates all CATEPT submodules in dependency order.

## Module map

  CATEPTPrelude         — core structures: ComplexAction, MeasurePathIntegralModel,
                          weight factorization, Cameron condition, Bochner bounds,
                          ComplexSchrodingerFunctional
  FeynmanKacBridge      — FK ↔ CAT/EPT bridge: τ_ent ↔ ∫V ds, Euclidean correspondence,
                          decay ODE, complex FK bridge (axiom)
  ModularFlowBridge     — Tomita-Takesaki: τ_ent = accumulated modular flow,
                          Page-Wootters = Connes-Rovelli, Hyers-Ulam stability
  ComplexMeasureBridge  — measure existence via L¹-density: ν(A)=∫_A w dγ is a
                          finite countably additive complex measure (VectorMeasure α ℂ)

## Theorems proved (Phase 1)

  CATEPTPrelude:
    • `weight_factorizes`               — w = phase · damping
    • `phase_norm_one`                  — |exp(iS_R/ħ)| = 1  (Mazur-Ulam)
    • `weight_norm_is_damping`          — |w| = exp(−τ_ent)
    • `damping_pos`                     — exp(−τ_ent) > 0
    • `damping_le_one`                  — exp(−τ_ent) ≤ 1
    • `weight_bochner_bounded`          — ‖w‖ ≤ 1  (Bochner bound)
    • `cameron_condition`               — Re(exponent) ≤ 0  (Cameron condition)
    • `measurable_weight`               — w is measurable
    • `kernel_integrable`               — k ∈ L¹ (Schrödinger functional)

  FeynmanKacBridge:
    • `euclidean_weight_is_real_positive` — S_R=0 → w = exp(−τ_ent) ∈ ℝ₊
    • `entropic_time_is_cumulative_potential` — τ_ent = ∫V ds (const V)
    • `fk_weight_equals_catept_damping`  — exp(−VT) = exp(−τ_ent)
    • `damping_satisfies_decay_ODE`      — dw/dt = −Vw
    • `decay_ODE_initial_condition`      — w(0) = 1
    • `catept_fk_euclidean_correspondence` — |w| = exp(−τ_ent) (main)

  ModularFlowBridge:
    • `entropic_time_eq_accumulated_modular_flow` — τ_ent = ∫ λ dτ
    • `page_wootters_time_eq_accumulated_modular_flow` — PW time = ∫ λ dτ
    • `connes_rovelli_time_eq_accumulated_modular_flow` — CR time = ∫ λ dτ
    • `relational_time_eq_thermal_time`  — PW clock = CR clock
    • `hyers_ulam_weight_stability`      — FK damping is (1/ħ)-Lipschitz in S_I

  ComplexMeasureBridge:
    • `weight_integrable_of_damping_integrable` — damping ∈ L¹ → w ∈ L¹
    • `integral_weight_hasSum`           — HasSum / countable additivity via DCT
    • `integral_weight_iUnion`           — tsum = ∫_{⋃ sₙ} w dγ
    • `setIntegral_weight_norm_le_damping` — ‖∫_A w‖ ≤ ∫_A damping (total variation)
    • `catept_complex_measure`           — VectorMeasure α ℂ construction
    • `catept_complex_measure_apply`     — ν(A) = ∫_A w dγ for measurable A
    • `catept_complex_measure_norm_le`   — ‖ν(A)‖ ≤ Z₀ = ∫ damping dγ
    • `catept_fk_decomposition`          — ν(A) = ∫_A phase·damping dγ
    • `catept_measure_exists_from_finite_reference` — finite γ → L¹ automatic
    • `cameron_condition_gives_pointwise_bound` — pointwise bound clarification

## Axiom surface (pending Phase 2)

  FeynmanKacBridge:
    • `complex_FK_bridge` — open problem (Glimm-Jaffe 1987, complex FK)

  ModularFlowBridge:
    • `kms_condition`         — KMS from modular flow theory (Type III₁)
    • `cameron_martin_girsanov` — absolute continuity w.r.t. Wiener measure

  ComplexMeasureBridge:
    • `cameron_martin_quasi_invariance` — d(T_h)*ν/dν Radon-Nikodym (Phase 2)

## Phase-2 roadmap

  HIGH: `kms_condition` — derive from modular Hamiltonian K = −ln ρ = τ_ent
  HIGH: `cameron_martin_girsanov` — Radon-Nikodym dμ/dμ_W = exp(−τ_ent)
  MED:  `complex_FK_bridge` — Itô diffusion on α + complex parabolic PDE
  MED:  Heat kernel `heatKernelModel` port from NS-clean MeasurePathIntegral.lean
-/
