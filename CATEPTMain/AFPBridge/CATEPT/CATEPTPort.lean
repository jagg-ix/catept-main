import CATEPTMain.AFPBridge.CATEPT.CATEPTPrelude
import CATEPTMain.AFPBridge.CATEPT.FeynmanKacBridge
import CATEPTMain.AFPBridge.CATEPT.ModularFlowBridge
/-!
# CATEPT Port — Root Module

Complex Action / Entropic Time (CAT/EPT) framework port for CATEPTMain AFPBridge.

This barrel file aggregates all CATEPT submodules in dependency order.

## Module map

  CATEPTPrelude       — core structures: ComplexAction, MeasurePathIntegralModel,
                        weight factorization, Cameron condition, Bochner bounds,
                        ComplexSchrodingerFunctional
  FeynmanKacBridge    — FK ↔ CAT/EPT bridge: τ_ent ↔ ∫V ds, Euclidean correspondence,
                        decay ODE, complex FK bridge (axiom)
  ModularFlowBridge   — Tomita-Takesaki: τ_ent = accumulated modular flow,
                        Page-Wootters = Connes-Rovelli, Hyers-Ulam stability

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

## Axiom surface (pending Phase 2)

  FeynmanKacBridge:
    • `complex_FK_bridge` — open problem (Glimm-Jaffe 1987, complex FK)

  ModularFlowBridge:
    • `kms_condition`         — KMS from modular flow theory (Type III₁)
    • `cameron_martin_girsanov` — absolute continuity w.r.t. Wiener measure
    • `hyers_ulam_weight_stability` — 2 sorry stubs (need S_I ≥ 0 + MVT)

## Phase-2 roadmap

  HIGH: `hyers_ulam_weight_stability` — fill 2 sorry with MVT argument
  HIGH: `kms_condition` — derive from modular Hamiltonian K = −ln ρ = τ_ent
  HIGH: `cameron_martin_girsanov` — Radon-Nikodym dμ/dμ_W = exp(−τ_ent)
  MED:  `complex_FK_bridge` — Itô diffusion on α + complex parabolic PDE
  MED:  Heat kernel `heatKernelModel` port from NS-clean MeasurePathIntegral.lean
-/
