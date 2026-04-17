import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Positivity
import CATEPT.ClassicalCore
import CATEPT.ClassicalHerglotzETHBridge
import CATEPT.CAT_EPT_ETH_CanonicalBridge

/-!
# CFL–Entropic Clock Bridge

Formalizes the **CFL–EPT analysis** (CFL_FINAL_SUMMARY.txt, CFL_FINAL_VERIFICATION.txt,
CFL_VISUAL_SUMMARY.txt, ENTROPIC_TIME_CFL_INTERPRETATION.txt):

## Core result: CFL invariance under time reparameterization

For the advection equation `∂_t u + a ∂_x u = 0`:
  - Coordinate time t:   CFL constraint `Δt ≤ Δx/a`
  - Entropic time τ_ent: CFL constraint `Δτ ≤ lam · Δx/a`
  - Converting back: `Δt = Δτ/lam ≤ (lam · Δx/a)/lam = Δx/a` — same constraint!

Causality is coordinate-independent. Reparameterizing t → τ_ent = ∫ lam dt
rescales characteristic speeds (a → a/lam) but preserves the stability bound.

## Physical vs numerical constraints

Physical (fundamental):
  - Causality bound:  `lam ≤ c / ell_min`
  - Second Law:       `lam ≥ 0`

Numerical (scheme-dependent):
  - Standard CFL:          `Δt ≤ Δx / c`
  - Dissipation stability: `Δt · lam_max ≲ α_scheme` (α ≈ 2 Euler, 2.8 RK4)

## Constructive proof parallel (CFL 1928 ↔ CAT/EPT)

CFL:    Finite-difference solutions converge as mesh → 0 via amplification ≤ 1
        (positivity of mesh stability) → PDE solution EXISTS constructively.

CAT/EPT: `exp(-S_I/ħ) ∈ [0,1]` because `S_I ≥ 0` (actionIm_nonneg).
         Path integral EXISTS constructively via entropy production positivity.

Both: POSITIVITY for EXISTENCE without assuming solutions exist a priori.

## Theorem status

| Name                                    | Status | Notes                                      |
|-----------------------------------------|--------|--------------------------------------------|
| `CFLConstraint`                         | def    | Prop: Δt ≤ Δx/a                           |
| `CFLConstraint_τ`                       | def    | Prop: Δτ ≤ lam·Δx/a                       |
| `cfl_reparameterization_invariant`      | proved | CFLConstraint_τ ↔ CFLConstraint(Δτ/lam)   |
| `cfl_invariant_char_speed`              | proved | Δt ≤ Δx/a ↔ lam·Δt ≤ lam·Δx/a           |
| `EntropicTimeCFLParams`                 | struct | Physical parameters for CFL–EPT bridge    |
| `dissipationLength`                     | def    | ell_diss = c/lam                          |
| `causalityBound_implies_cfl_consistent` | proved | causality bound → CFL satisfiable         |
| `oscillatorCFLParams`                   | def    | CFL params from DampedOscillatorParams    |
| `oscillator_dissipationLength`          | proved | ell_diss = m·c/γ                          |
| `herglotz_entropic_step`                | proved | Δτ_ent = (γ/m)·Δt                        |
| `constructiveUVConvergence`             | proved | S_I ≥ 0 → exp(-S_I/ħ) ∈ [0,1]           |
| `catept_damping_pos`                    | proved | exp(-S_I/ħ) > 0                           |
| `catept_damping_antitone`               | proved | S₁ ≤ S₂ → exp(-S₂/ħ) ≤ exp(-S₁/ħ)      |
-/

noncomputable section

set_option autoImplicit false

namespace CATEPT

open Real

-- ── CFL constraint definitions ────────────────────────────────────────────────

/-- The CFL constraint in coordinate time: `Δt ≤ Δx / a`. -/
def CFLConstraint (Δt Δx a : ℝ) : Prop := Δt ≤ Δx / a

/-- The CFL constraint in entropic proper time: `Δτ ≤ lam · Δx / a`.
    Here `lam = dτ_ent/dt` is the dissipation rate; `a/lam` is the
    effective characteristic speed in entropic time. -/
def CFLConstraint_τ (Δτ Δx a lam : ℝ) : Prop := Δτ ≤ lam * Δx / a

-- ── Core invariance theorem ───────────────────────────────────────────────────

/-- **CFL reparameterization invariance**: the CFL constraint in entropic time
    is equivalent to the CFL constraint in coordinate time (`Δt = Δτ/lam`).

    Key: `Δτ ≤ lam·Δx/a ↔ Δτ·a ≤ lam·Δx ↔ (Δτ/lam)·a ≤ Δx ↔ Δτ/lam ≤ Δx/a`.

    Physical meaning: causality is coordinate-independent.
    You cannot violate the speed-of-light limit by changing the time coordinate. -/
theorem cfl_reparameterization_invariant
    (Δτ Δx a lam : ℝ) (hlam : 0 < lam) (ha : 0 < a) :
    CFLConstraint_τ Δτ Δx a lam ↔ CFLConstraint (Δτ / lam) Δx a := by
  simp only [CFLConstraint, CFLConstraint_τ]
  constructor
  · intro h
    -- h : Δτ ≤ lam * Δx / a → Δτ / lam ≤ Δx / a
    have hstep : Δτ / lam ≤ (lam * Δx / a) / lam :=
      div_le_div_of_nonneg_right h (le_of_lt hlam)
    calc Δτ / lam ≤ (lam * Δx / a) / lam := hstep
      _ = Δx / a := by field_simp [hlam.ne', ha.ne']
  · intro h
    -- h : Δτ / lam ≤ Δx / a → Δτ ≤ lam * Δx / a
    have hstep : Δτ / lam * lam ≤ Δx / a * lam :=
      mul_le_mul_of_nonneg_right h (le_of_lt hlam)
    have hsimpl : Δτ / lam * lam = Δτ := div_mul_cancel₀ Δτ hlam.ne'
    linarith [show Δx / a * lam = lam * Δx / a from by ring]

/-- Equivalent form: multiplying both sides of `Δt ≤ Δx/a` by `lam > 0`
    gives the entropic CFL constraint `lam·Δt ≤ lam·Δx/a`. -/
theorem cfl_invariant_char_speed
    (Δt Δx a lam : ℝ) (hlam : 0 < lam) (ha : 0 < a) :
    CFLConstraint Δt Δx a ↔ CFLConstraint_τ (lam * Δt) Δx a lam := by
  simp only [CFLConstraint, CFLConstraint_τ]
  constructor
  · intro h
    -- h : Δt ≤ Δx/a → lam*Δt ≤ lam*Δx/a
    have : lam * Δt ≤ lam * (Δx / a) := mul_le_mul_of_nonneg_left h (le_of_lt hlam)
    linarith [show lam * (Δx / a) = lam * Δx / a from by ring]
  · intro h
    -- h : lam*Δt ≤ lam*Δx/a → Δt ≤ Δx/a
    have hconv : lam * Δt ≤ lam * (Δx / a) := by
      linarith [show lam * Δx / a = lam * (Δx / a) from by ring]
    exact le_of_mul_le_mul_left hconv hlam

-- ── Physical parameters ───────────────────────────────────────────────────────

/-- Physical and numerical parameters for the CFL–EPT bridge.
    Encodes:
    - `charSpeed a > 0`: characteristic propagation speed
    - `dissipRate lam ≥ 0`: dissipation rate (Second Law)
    - `minLength ell_min > 0`: minimum resolved spatial scale
    - `lam_bound`: physical causality bound `lam ≤ a/ell_min`

    Numerical constraints (Δt ≤ Δx/c, Δt·lam ≲ α_scheme) are NOT encoded
    here — they are scheme-dependent and NOT fundamental physics. -/
structure EntropicTimeCFLParams where
  charSpeed   : ℝ
  dissipRate  : ℝ
  minLength   : ℝ
  charSpeed_pos  : 0 < charSpeed
  minLength_pos  : 0 < minLength
  lam_nonneg  : 0 ≤ dissipRate
  lam_bound   : dissipRate ≤ charSpeed / minLength

/-- The dissipation length `ell_diss = c/lam`.
    The mesh resolution must satisfy `Δx ≥ ell_diss` to avoid the dissipation
    appearing superluminal at the grid scale. -/
def dissipationLength (p : EntropicTimeCFLParams) : ℝ :=
  p.charSpeed / p.dissipRate

/-- The causality bound `lam ≤ c/ell_min` holds by construction. -/
theorem entropicCFLParams_causality (p : EntropicTimeCFLParams) :
    p.dissipRate ≤ p.charSpeed / p.minLength := p.lam_bound

/-- Under the causality bound, the CFL constraint can always be satisfied
    for any mesh spacing Δx > 0: the system is numerically tractable. -/
theorem causalityBound_implies_cfl_consistent
    (p : EntropicTimeCFLParams) (Δx : ℝ) (hΔx : 0 < Δx) :
    ∃ Δt : ℝ, 0 < Δt ∧ CFLConstraint Δt Δx p.charSpeed := by
  refine ⟨Δx / p.charSpeed / 2, ?_, ?_⟩
  · apply div_pos (div_pos hΔx p.charSpeed_pos); norm_num
  · unfold CFLConstraint
    have h1 : 0 < Δx / p.charSpeed := div_pos hΔx p.charSpeed_pos
    nlinarith

-- ── Entropic time step ────────────────────────────────────────────────────────

/-- The entropic time step: `Δτ_ent = lam · Δt`. -/
def entropicTimeStep (p : EntropicTimeCFLParams) (Δt : ℝ) : ℝ :=
  p.dissipRate * Δt

/-- Entropic time step is nonneg when `Δt ≥ 0`. -/
theorem entropicTimeStep_nonneg (p : EntropicTimeCFLParams) (Δt : ℝ) (hΔt : 0 ≤ Δt) :
    0 ≤ entropicTimeStep p Δt :=
  mul_nonneg p.lam_nonneg hΔt

-- ── Classical oscillator CFL parameters ──────────────────────────────────────

/-- Build `EntropicTimeCFLParams` from the classical damped oscillator.
    Physical identification: `lam = γ/m` (Herglotz contact rate = ETH β_I).
    The bound `γ/m ≤ c/ell_min` is an external physical postulate. -/
def oscillatorCFLParams
    (p : DampedOscillatorParams) (c ell_min : ℝ)
    (hc : 0 < c) (hell : 0 < ell_min)
    (hbound : herglotzContactRate p ≤ c / ell_min) :
    EntropicTimeCFLParams where
  charSpeed      := c
  dissipRate     := herglotzContactRate p
  minLength      := ell_min
  charSpeed_pos  := hc
  minLength_pos  := hell
  lam_nonneg     := div_nonneg p.gamma_nonneg (le_of_lt p.m_pos)
  lam_bound      := hbound

/-- Oscillator dissipation length: `ell_diss = mc/γ`.
    Mesh must satisfy `Δx ≥ mc/γ` to resolve the damped oscillator dynamics. -/
theorem oscillator_dissipationLength
    (p : DampedOscillatorParams) (c ell_min : ℝ)
    (hc : 0 < c) (hell : 0 < ell_min)
    (hbound : herglotzContactRate p ≤ c / ell_min)
    (hgamma : 0 < p.gamma) :
    dissipationLength (oscillatorCFLParams p c ell_min hc hell hbound) =
    p.m * c / p.gamma := by
  unfold dissipationLength oscillatorCFLParams herglotzContactRate
  simp only
  field_simp [ne_of_gt hgamma, ne_of_gt p.m_pos]

/-- Oscillator entropic time step: `Δτ_ent = (γ/m)·Δt`. -/
theorem herglotz_entropic_step
    (p : DampedOscillatorParams) (c ell_min Δt : ℝ)
    (hc : 0 < c) (hell : 0 < ell_min)
    (hbound : herglotzContactRate p ≤ c / ell_min) :
    entropicTimeStep (oscillatorCFLParams p c ell_min hc hell hbound) Δt =
    herglotzContactRate p * Δt := rfl

-- ── Constructive proof parallel ───────────────────────────────────────────────

/-- **Constructive UV convergence** (CAT/EPT ↔ CFL existence proof).

    CFL:    amplification ≤ 1 (mesh stability, positivity) → PDE solution exists.
    CAT/EPT: exp(-S_I/ħ) ∈ [0,1] (actionIm_nonneg, positivity) → path integral exists.

    Both prove EXISTENCE via POSITIVITY without assuming solutions a priori.

    This theorem directly formalizes: S_I ≥ 0 → the damping factor is in [0,1],
    which is the CAT/EPT analogue of CFL's amplification factor ≤ 1. -/
theorem constructiveUVConvergence
    (S_I hbar : ℝ) (hS : 0 ≤ S_I) (hbar_pos : 0 < hbar) :
    0 ≤ Real.exp (-S_I / hbar) ∧ Real.exp (-S_I / hbar) ≤ 1 := by
  refine ⟨le_of_lt (Real.exp_pos _), ?_⟩
  apply Real.exp_le_one_iff.mpr
  apply div_nonpos_of_nonpos_of_nonneg
  · linarith
  · exact hbar_pos.le

/-- The CAT/EPT damping factor is strictly positive: path integral contributions
    never vanish completely (analogue: CFL gives non-trivial mesh solutions). -/
theorem catept_damping_pos (S_I hbar : ℝ) : 0 < Real.exp (-S_I / hbar) :=
  Real.exp_pos _

/-- Stronger entropy production → smaller damping weight.
    Analogue: finer mesh (more stable CFL) → smaller amplification factor. -/
theorem catept_damping_antitone (S₁ S₂ hbar : ℝ)
    (hbar_pos : 0 < hbar) (h : S₁ ≤ S₂) :
    Real.exp (-S₂ / hbar) ≤ Real.exp (-S₁ / hbar) := by
  apply Real.exp_le_exp.mpr
  apply div_le_div_of_nonneg_right _ hbar_pos.le
  linarith

end CATEPT

end
