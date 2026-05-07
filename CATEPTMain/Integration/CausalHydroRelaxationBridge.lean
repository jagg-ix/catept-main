import CATEPTMain.Geometry.EntropicLapse
import CATEPTMain.Integration.MISNoFTLBridge
import CATEPTMain.CATEPT.CATEPT.InfluenceFunctionalBridge

/-!
# CausalHydroRelaxationBridge — Telegrapher / Relaxation-Time Dictionary for CAT/EPT

This module is the **first formal landing pad** for the causal-hydrodynamics
reading used in `REPLYID: CAT-EPT-20260415-25`:

* Parabolic diffusion is acausal (instantaneous tails).
* Causal hydrodynamics replaces it with **finite relaxation time** dynamics
  (Cattaneo/telegrapher/Müller–Israel–Stewart style).
* In CAT/EPT, the irreversible sector already carries a **rate** (an entropic
  ticking rate / damping rate).  This file makes the simplest dictionary
  explicit:

`relaxationTime τ_R > 0`  ↔  `relaxationRate λ_R := τ_R⁻¹ > 0`.

## Why this is useful in your codebase

You already have two independent sources of a **positive irreversible rate**:

1. `InfluenceFunctionalBridge`:
   Markovian influence functional gives a local-in-time damping scale `γ > 0`.
2. `MISNoFTLBridge`:
   NS palinstrophy coercivity gives the explicit rate
   `C = ν · k_UV⁴ > 0` (see `MISNoFTLData.coercivityConstant_pos`).

This file does not attempt to formalize PDE calculus (deriving the telegrapher
equation from continuity + Cattaneo law).  Instead it provides:

* tiny **contracts** for relaxation-time parameters,
* a canonical way to extract a relaxation time from the palinstrophy rate, and
* the no-FTL inequality shape used by the telegrapher front speed
  `v_front² = D / τ_R`.

Those are the exact “glue points” needed to *reuse* existing CAT/EPT geometry
(`EntropicLapse`) and existing NS data (`MISNoFTLData`) when we later add
the actual causal-hydro semantics.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.CausalHydroRelaxationBridge

open CATEPTMain.Geometry.EntropicLapse
open CATEPTMain.Geometry.FiniteMinkowski
open CATEPTMain.Integration.MISNoFTLBridge
open CATEPTMain.CATEPT.CATEPT

-- ============================================================================
-- 1. Minimal relaxation-time contract
-- ============================================================================

/-- A strictly positive relaxation time `τ_R > 0`. -/
structure RelaxationTime where
  τ : ℝ
  τ_pos : 0 < τ

namespace RelaxationTime

variable (rt : RelaxationTime)

/-- The relaxation rate `λ_R = τ_R⁻¹`. -/
def rate : ℝ := 1 / rt.τ

theorem rate_pos : 0 < rt.rate := by
  unfold rate
  exact one_div_pos.mpr rt.τ_pos

theorem inv_rate_eq_tau : 1 / rt.rate = rt.τ := by
  unfold rate
  simp

end RelaxationTime

-- ============================================================================
-- 2. Telegrapher front-speed shape + compatibility with an entropic lapse
-- ============================================================================

/-- Parameters for the scalar telegrapher equation in the Natsuume / MIS style:

`τ · ∂ₜ² ρ + ∂ₜ ρ - D · Δρ = 0`

This structure only records the non-negativity constraints on parameters,
because those are what the CAT/EPT bridges consume. -/
structure TelegrapherParams where
  /-- Diffusivity `D ≥ 0`. -/
  D : ℝ
  D_nonneg : 0 ≤ D
  /-- Relaxation time `τ > 0`. -/
  τR : RelaxationTime

namespace TelegrapherParams

variable (p : TelegrapherParams)

/-- The standard telegrapher “front speed squared”:

`v_front² := D / τ_R`.

In causal hydrodynamics one requires `v_front ≤ c` (no-FTL).  In CAT/EPT
coordinates the entropic lapse plays the role of a *local* `c`. -/
def frontSpeedSq : ℝ := p.D / p.τR.τ

theorem frontSpeedSq_nonneg : 0 ≤ p.frontSpeedSq := by
  unfold frontSpeedSq
  exact div_nonneg p.D_nonneg p.τR.τ_pos.le

theorem frontSpeedSq_eq_mul_rate : p.frontSpeedSq = p.D * p.τR.rate := by
  unfold frontSpeedSq RelaxationTime.rate
  simp [div_eq_mul_inv]

/-- **No-FTL shape** under a lapse field:

If `D ≤ τ_R · N(x)²`, then `D/τ_R ≤ N(x)²`, i.e. the front speed respects the
entropic local speed of light. -/
theorem frontSpeedSq_le_lapse_sq {N : EntropicLapse} {x : CATEPTST}
    (h : p.D ≤ p.τR.τ * (N.lapse x) ^ 2) :
    p.frontSpeedSq ≤ (N.lapse x) ^ 2 := by
  have ht : 0 < p.τR.τ := p.τR.τ_pos
  have hτ : p.τR.τ ≠ 0 := ne_of_gt ht
  -- Multiply the assumed bound by `1/τ` to isolate the front-speed term.
  have h' : p.D * (1 / p.τR.τ) ≤ (p.τR.τ * (N.lapse x) ^ 2) * (1 / p.τR.τ) := by
    exact mul_le_mul_of_nonneg_right h (one_div_nonneg.mpr ht.le)
  -- Rewrite `D/τ = D*(1/τ)` and cancel `τ*(1/τ)`.
  simpa [frontSpeedSq, div_eq_mul_inv, mul_assoc, mul_left_comm, mul_comm, hτ] using h'

end TelegrapherParams

-- ============================================================================
-- 3. The CAT/EPT ↔ MIS reuse point: palinstrophy coercivity rate as λ_R
-- ============================================================================

section MISReuse

variable {Φ : Type} (data : MISNoFTLData Φ)

/-- **Canonical CAT/EPT relaxation time** extracted from NS palinstrophy
coercivity:

`λ_R := C = ν · k_UV⁴` (already in `MISNoFTLBridge`)
`τ_R := 1/λ_R`.

This is the simplest formal realization of the “relaxation-time as entropic
memory” dictionary used in the causal-hydrodynamics reading. -/
def mis_relaxationTimeFromPalinstrophy : RelaxationTime where
  τ := 1 / data.coercivityConstant
  τ_pos := one_div_pos.mpr data.coercivityConstant_pos

/-- The derived relaxation rate is exactly the palinstrophy coercivity constant.

This is a *definitional* normalization choice:
`rate(τ_R) = C`. -/
theorem relaxationRate_eq_coercivityConstant :
    (mis_relaxationTimeFromPalinstrophy data).rate = data.coercivityConstant := by
  unfold mis_relaxationTimeFromPalinstrophy RelaxationTime.rate
  simp

/-- The derived relaxation time is the inverse of the coercivity constant. -/
theorem relaxationTime_eq_inv_coercivityConstant :
    (mis_relaxationTimeFromPalinstrophy data).τ = 1 / data.coercivityConstant := rfl

/-- **Constantin–Iyer / Madelung normalization**: if the viscosity in the
palinstrophy datum satisfies `ν = ħ/2` (the same normalization used in the
NS↔Madelung bridge), then the relaxation rate becomes

`λ_R = (ħ/2) · k_UV⁴`. -/
theorem relaxationRate_via_hbar
    (hbar : ℝ) (hν : data.palinstrophy.ν = hbar / 2) :
    data.coercivityConstant = hbar / 2 * data.palinstrophy.k_UV_4 := by
  -- `coercivityConstant = ν * k_UV⁴` by definition.
  simp [MISNoFTLData.coercivityConstant, hν]

end MISReuse

-- ============================================================================
-- 4. Influence-functional reuse point (Markovian damping rate as λ_R)
-- ============================================================================

section InfluenceFunctionalReuse

variable (m : MarkovianInfluenceFunctional)

/-- In the Markovian (local-in-time) influence functional,
`gamma > 0` is already the natural irreversible scale.  We package it as a
relaxation-time object `τ_R := 1/gamma`. -/
def markovian_relaxationTimeFromGamma : RelaxationTime where
  τ := 1 / m.gamma
  τ_pos := one_div_pos.mpr m.gamma_pos

theorem relaxationRate_eq_gamma :
    (markovian_relaxationTimeFromGamma m).rate = m.gamma := by
  unfold markovian_relaxationTimeFromGamma RelaxationTime.rate
  simp

end InfluenceFunctionalReuse

end CATEPTMain.Integration.CausalHydroRelaxationBridge
