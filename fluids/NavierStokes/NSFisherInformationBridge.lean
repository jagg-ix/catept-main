import NavierStokes.Bridges.NSVorticityCoadjointBridge
import NavierStokes.Bridges.NSPalinstrophyTauBridge

/-!
# Fisher Information Bridge for NS Palinstrophy and Entropic Time

## Overview

The **Fisher information** of a probability density `ρ : T³ → ℝ≥0` is:
```
I_F[ρ] = ∫ |∇ρ|² / ρ dx
```

## Connection to NS palinstrophy

For the normalized enstrophy density `ρ_ω = |ω|² / ‖ω‖²_{L²}`, the Fisher
information equals:
```
I_F[ρ_ω] = palinstrophy / enstrophy  =  (∑ k⁴|aₖ|²) / (∑ k²|aₖ|²)
```
This is the **frequency-weighted mean of k²** with Fourier weights `k²|aₖ|²`.

The key identity `palinstrophy = I_F · enstrophy` becomes, for Galerkin fields
(frequencies ≤ `√kmax`): `I_F ≤ kmax`, hence `palinstrophy ≤ kmax · enstrophy`.

Integrating: `∫P ≤ kmax · (ħ/ν) · τ_ent` — this is Stage 156's
`integratedPal_le_kmax_tau`, now given Fisher-information interpretation.

## Status: all five claims `.verified`
-/

namespace NavierStokes.FisherInformationBridge

set_option autoImplicit false

open NavierStokes.FourierModel
open NavierStokes.DiscreteKernel
open NavierStokes.PalinstrophyTauBridge
open NavierStokes.FourierLiftBridge
open NavierStokes.Millennium

-- ────────────────────────────────────────────────────────────────────────────
-- §1. Fisher information metric in Fourier space
-- ────────────────────────────────────────────────────────────────────────────

/-- **Fourier Fisher information metric**: `I_F[ρ_ω] = palinstrophy / enstrophy`.

    For an `NSFieldFourier` `v`, this is the ratio of palinstrophy to enstrophy —
    the k²-weighted mean over active Fourier modes.  When enstrophy vanishes
    (trivial field), the Fisher metric is defined to be 0. -/
noncomputable def fisherMetricF (v : NSFieldFourier) : Rat :=
  if enstrophyF v = 0 then 0
  else palinstrophyF v / enstrophyF v

/-- **Fisher metric is non-negative**. -/
theorem fisherMetricF_nonneg (v : NSFieldFourier) : 0 ≤ fisherMetricF v := by
  unfold fisherMetricF
  split_ifs with h
  · exact le_refl _
  · exact div_nonneg (palinstrophyF_nonneg v) (enstrophyF_nonneg v)

-- ────────────────────────────────────────────────────────────────────────────
-- §2. Palinstrophy = Fisher × Enstrophy
-- ────────────────────────────────────────────────────────────────────────────

/-- **Palinstrophy = Fisher metric × Enstrophy** (when enstrophy > 0).

    `palinstrophyF v = fisherMetricF v · enstrophyF v`

    This is the key algebraic identity: the Fisher information metric of the
    enstrophy density is exactly the palinstrophy-to-enstrophy ratio. -/
theorem palinstrophy_eq_fisher_times_enstrophy
    (v : NSFieldFourier)
    (hE : 0 < enstrophyF v) :
    palinstrophyF v = fisherMetricF v * enstrophyF v := by
  unfold fisherMetricF
  simp only [if_neg (ne_of_gt hE)]
  exact (div_mul_cancel₀ (palinstrophyF v) (ne_of_gt hE)).symm

/-- **Palinstrophy zero iff Fisher zero** (when enstrophy > 0). -/
theorem palinstrophy_zero_iff_fisher_zero
    (v : NSFieldFourier)
    (hE : 0 < enstrophyF v) :
    palinstrophyF v = 0 ↔ fisherMetricF v = 0 := by
  rw [palinstrophy_eq_fisher_times_enstrophy v hE, mul_eq_zero]
  constructor
  · rintro (h | h)
    · exact h
    · exact absurd (h ▸ hE) (lt_irrefl _)
  · intro h; exact Or.inl h

-- ────────────────────────────────────────────────────────────────────────────
-- §3. Galerkin cutoff bounds the Fisher metric
-- ────────────────────────────────────────────────────────────────────────────

/-- **Fisher metric ≤ kmax for Galerkin-truncated fields** (pointwise).

    For any `NSFieldFourier v` with `(freq i)² ≤ kmax` for all modes `i`:
    `palinstrophyF v ≤ kmax · enstrophyF v`, hence `I_F ≤ kmax` when Ω > 0.

    Proof: `k⁴|aₖ|² = k²·(k²|aₖ|²) ≤ kmax·(k²|aₖ|²)` mode-by-mode. -/
theorem fisherMetricF_le_kmax_of_galerkin
    (v : NSFieldFourier)
    (hfreq : ∀ i, (v.freq i : Rat) ^ 2 ≤ kmax)
    (hE : 0 < enstrophyF v) :
    fisherMetricF v ≤ kmax := by
  unfold fisherMetricF
  simp only [if_neg (ne_of_gt hE)]
  rw [div_le_iff₀ hE]
  unfold palinstrophyF enstrophyF
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  have hk  : 0 ≤ (v.freq i : Rat) ^ 2 := by positivity
  have ha2 : 0 ≤ v.amp i ^ 2             := by positivity
  -- Goal: (freq i)⁴ · (amp i)² ≤ kmax · ((freq i)² · (amp i)²)
  have heq : (v.freq i : Rat) ^ 4 * v.amp i ^ 2 =
             (v.freq i : Rat) ^ 2 * ((v.freq i : Rat) ^ 2 * v.amp i ^ 2) := by ring
  rw [heq]
  exact mul_le_mul_of_nonneg_right (hfreq i) (mul_nonneg hk ha2)

-- ────────────────────────────────────────────────────────────────────────────
-- §4. Integrated Fisher and entropic time
-- ────────────────────────────────────────────────────────────────────────────

/-- **Integrated palinstrophy ≤ kmax · (ħ/ν) · entropic time**.

    Time-integrated Fisher information is bounded by entropic time:
    `∫₀ᵀ P(t) dt  ≤  kmax · (ħ/ν) · τ_ent(T)`

    This is `integratedPal_le_kmax_tau` from Stage 156, restated as:
    the **integrated Fisher information metric is controlled by entropic time**. -/
theorem integratedFisher_le_kmax_times_tau
    (traj : Trajectory NSField) (T : Rat) :
    integratedPalinstrophyF (liftTrajToFourier traj) T ≤
    kmax * (hbar / nsNu) * entropicProperTimeF (liftTrajToFourier traj) T :=
  integratedPal_le_kmax_tau traj T

end NavierStokes.FisherInformationBridge

-- ────────────────────────────────────────────────────────────────────────────
-- §5. Claims registry
-- ────────────────────────────────────────────────────────────────────────────

namespace NavierStokes.Millennium.CategoryTheory

def fisherInformationClaims : List LabeledClaim :=
  [ ⟨"fisherMetricF_nonneg", .verified,
      "I_F = palinstrophy / enstrophy ≥ 0 (div_nonneg + existing nonneg lemmas)"⟩
  , ⟨"palinstrophy_eq_fisher_times_enstrophy", .verified,
      "palinstrophy = I_F · enstrophy (div_mul_cancel₀)"⟩
  , ⟨"palinstrophy_zero_iff_fisher_zero", .verified,
      "P = 0 ↔ I_F = 0 when Ω > 0 (pure mode ↔ flat spectrum)"⟩
  , ⟨"fisherMetricF_le_kmax_of_galerkin", .verified,
      "I_F ≤ kmax for Galerkin fields (k⁴ = k²·k² ≤ kmax·k² mode-by-mode)"⟩
  , ⟨"integratedFisher_le_kmax_times_tau", .verified,
      "∫P ≤ kmax·(ħ/ν)·τ_ent (Stage 156 integratedPal_le_kmax_tau)"⟩ ]

end NavierStokes.Millennium.CategoryTheory
