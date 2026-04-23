import CATEPTMain.EPT.EPTPrelude
/-!
# EPT Port — Root Module

Entropic Proper Time (EPT) port for CATEPTMain AFPBridge.

This barrel file aggregates all EPT submodules in dependency order.

## Module map

  EPTPrelude  — core definitions: entropicTime, eptDamping, eptDecayRate,
                eptCriticalTime, Constantin-Iyer identification, tauBound,
                BKM degree-4 bound (axiom)

## Theorems proved (Phase 1)

  EPTPrelude:
    • `entropicTime_nonneg`  — τ_ent ≥ 0 for S_I ≥ 0
    • `entropicTime_linear`  — τ_ent(S+S') = τ_ent(S) + τ_ent(S')
    • `eptDamping_pos`       — exp(−τ_ent) > 0
    • `eptDamping_le_one`    — exp(−τ_ent) ≤ 1 for S_I ≥ 0
    • `eptDamping_antitone`  — larger S_I → smaller damping
    • `eptDecayRate_pos`     — σ > 0
    • `eptCriticalTime_pos`  — T_crit > 0
    • `eptDecayRate_ci`      — σ = 1 under ħ = 2ν (CI)
    • `eptCriticalTime_ci`   — T_crit = 1 under ħ = 2ν (CI)
    • `tauBound_nonneg`      — τ_bound ≥ 0
    • `tauBound_denom_pos`   — 1 − σT > 0 for T < T_crit

## Axiom surface (pending Phase 2)

  EPTPrelude:
    • `constantinIyer_identification` — ħ = 2ν (physical calibration)
    • `ept_physical_bound_axiom`      — τ_ent ≤ τ_bound (Gronwall self-referential)
    • `ept_linear_bound_ns`           — τ_ent ≤ (ν/ħ)·Ω₀·T (global, NS PDE)
    • `bkm_degree4_bound`             — BKM(T) ≤ B·(1+τ_linear)³·τ_linear

## Source

Ported from:
  - `entropic-time/.../NSEPTPhysicalTimeBridge.lean`    (Stage 280)
  - `entropic-time/.../NSEPTCIBound.lean`               (Stage 281)
  - `entropic-time/.../NSEPTNSSynthesisBound.lean`      (Stage 283)
  - `entropic-time/.../NSEPTUniformBound.lean`          (Stage 282)

## Phase-2 roadmap

  HIGH: `ept_physical_bound_axiom` — prove via Gronwall + discrete integral
  HIGH: `ept_linear_bound_ns` — port enstrophy Lyapunov chain (Stage 73–83)
  HIGH: `bkm_degree4_bound` — port full bkm_ns_polynomial_bound (Stage 283)
  MED:  `constantinIyer_identification` — derive from enstrophy saturation
-/
