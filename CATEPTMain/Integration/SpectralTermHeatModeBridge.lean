import CATEPTMain.Integration.T3SpectralPartition
import CATEPTMain.Integration.HeatSemigroupEntropicTime

/-!
# Spectral-Term ↔ Heat-Mode Identification

Tiny structural bridge between two existing infrastructure layers
that use the same Gaussian factor under different parametrizations:

* `SpectralSumPartition.spectralTerm k = exp(-(k²))` — the
  Stokes-spectral 1-D Fourier-mode contribution (parametrized by
  wavenumber `k`).

* `HeatSemigroupEntropicTime.heatMode a t = exp(-(2 a) · t)` — the
  heat-semigroup mode (parametrized by action coefficient `a` and
  evolution time `t`).

Setting `a = 1/2` and `t = (k : ℝ)^2` makes the two coincide:

  `heatMode (1/2) ((k : ℝ)^2) = exp(-(2 · (1/2)) · (k : ℝ)^2)
                              = exp(-((k : ℝ)^2))
                              = spectralTerm k`.

Recording this identity makes the spectral-cutoff side of
`T3SpectralPartition` (used by `T3TailBound`, `HigherDegreeT3TailSharp`,
the no-counterterm chain) a direct re-parametrization of the heat-
semigroup module — and therefore subject to the Green-function
chain documented in `EntropicGreenFromHeatSemigroup` and
`GreenDampingUVChain`.

## What is honestly proven

* `spectralTerm_eq_heatMode_at_unit_action`: 1-D identity
  `spectralTerm k = heatMode (1/2) ((k : ℝ)^2)`.

* `spectralTerm3D_eq_heatMode_sum_of_squares`: 3-D identity
  `spectralTerm3D k = heatMode (1/2) (k₁² + k₂² + k₃²)`.

## Architectural fit

```text
SpectralSumPartition.spectralTerm k = exp(-k²)
        ↑ this PR — pure parametrization identity
HeatSemigroupEntropicTime.heatMode (1/2) ((k:ℝ)^2)
        ↓
EntropicGreenFromHeatSemigroup.green_function_eq_entropicProperTime (PR #38)
        ↓
GreenDampingUVChain.green_to_uv_damping_chain (PR #39)
        ↓
GreenDampingUVChainMultimode.multimode_green_damping_bounded (PR #40)
        ↓
T3TailBound / HigherDegreeT3TailSharp (PR #32) → no_counterterm chain
```

The identity is purely algebraic; the proof is one `simp`-style
rewriting that unfolds the two definitions and applies `2 · (1/2) = 1`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SpectralTermHeatModeBridge

open CATEPTMain.Integration.SpectralSumPartition
open CATEPTMain.Integration.HeatSemigroupEntropicTime
open CATEPTMain.Integration.T3SpectralPartition

noncomputable section

/-- **1-D identity**: the Stokes-spectral term at wavenumber `k` is
the heat-semigroup mode at action coefficient `a = 1/2` and time
`t = (k : ℝ)^2`.

  `spectralTerm k = heatMode (1/2) ((k : ℝ)^2)`. -/
theorem spectralTerm_eq_heatMode_at_unit_action (k : ℕ) :
    spectralTerm k = heatMode (1 / 2 : ℝ) ((k : ℝ)^2) := by
  unfold spectralTerm heatMode
  congr 1
  ring

/-- **3-D identity**: the 3-D Stokes-spectral term at multi-index
`k = (k₁, k₂, k₃)` is the heat-semigroup mode at action coefficient
`a = 1/2` and time `t = k₁² + k₂² + k₃²`.

  `spectralTerm3D k = heatMode (1/2) (k₁² + k₂² + k₃²)`. -/
theorem spectralTerm3D_eq_heatMode_sum_of_squares
    (k : ℕ × ℕ × ℕ) :
    spectralTerm3D k =
      heatMode (1 / 2 : ℝ)
        ((k.1 : ℝ)^2 + (k.2.1 : ℝ)^2 + (k.2.2 : ℝ)^2) := by
  unfold spectralTerm3D heatMode
  congr 1
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- Partial / total spectral partitions as heat-semigroup sums
-- ═══════════════════════════════════════════════════════════════════════

/-- **Z_N as heat-semigroup partial sum.**  The 1-D cutoff partition
`Z_N = ∑ k < N, spectralTerm k` is exactly the heat-semigroup
partial sum `∑ k < N, heatMode (1/2) (k²)`.  Records that the
canonical 1-D spectral partition (used by `RealSpectralEntropicModel`,
`CanonicalEntropicModel`, etc.) is the integrated heat semigroup at
finite cutoff. -/
theorem Z_N_eq_heatMode_partial_sum (N : ℕ) :
    Z_N N = ∑ k ∈ Finset.range N, heatMode (1 / 2 : ℝ) ((k : ℝ)^2) := by
  unfold Z_N
  refine Finset.sum_congr rfl ?_
  intro k _
  exact spectralTerm_eq_heatMode_at_unit_action k

/-- **Z_inf as heat-semigroup tsum.**  The 1-D continuum partition
`Z_inf = ∑' k, spectralTerm k` is exactly the heat-semigroup
infinite-mode partition `∑' k, heatMode (1/2) (k²)`. -/
theorem Z_inf_eq_heatMode_tsum :
    Z_inf = ∑' k : ℕ, heatMode (1 / 2 : ℝ) ((k : ℝ)^2) := by
  unfold Z_inf
  exact tsum_congr (fun k => spectralTerm_eq_heatMode_at_unit_action k)

-- ═══════════════════════════════════════════════════════════════════════
-- 3-D partition as cube of 1-D heat-semigroup sum
-- ═══════════════════════════════════════════════════════════════════════

/-- **Z_N_3D as cube of heat-semigroup partial sum.**  Composes
`T3SpectralPartition.Z_N_3D_eq_Z_N_pow` (cube-factorisation of the 3-D
cutoff partition) with `Z_N_eq_heatMode_partial_sum` to get

  `Z_N_3D N = (∑ k < N, heatMode (1/2) (k²))^3`.

This is the partition-level shape that the no-renormalization
cube-factorization argument (P22 / `T3TailBound`,
`HigherDegreeT3TailSharp`) consumes. -/
theorem Z_N_3D_eq_heatMode_partial_sum_cube (N : ℕ) :
    Z_N_3D N = (∑ k ∈ Finset.range N, heatMode (1 / 2 : ℝ) ((k : ℝ)^2))^3 := by
  rw [Z_N_3D_eq_Z_N_pow, Z_N_eq_heatMode_partial_sum]

/-- **Z_inf_3D as cube of heat-semigroup tsum.**  Composes
`T3SpectralPartition.Z_inf_3D_eq_Z_inf_pow` with
`Z_inf_eq_heatMode_tsum` to get

  `Z_inf_3D = (∑' k, heatMode (1/2) (k²))^3`. -/
theorem Z_inf_3D_eq_heatMode_tsum_cube :
    Z_inf_3D = (∑' k : ℕ, heatMode (1 / 2 : ℝ) ((k : ℝ)^2))^3 := by
  rw [Z_inf_3D_eq_Z_inf_pow, Z_inf_eq_heatMode_tsum]

-- ═══════════════════════════════════════════════════════════════════════
-- Per-mode bounds via the heat-mode identification
-- ═══════════════════════════════════════════════════════════════════════

/-- **Per-mode heat-mode positivity.**  At `a = 1/2` the heat-semigroup
mode is strictly positive: `0 < heatMode (1/2) (k²)`. -/
theorem heatMode_at_unit_action_pos (k : ℕ) :
    0 < heatMode (1 / 2 : ℝ) ((k : ℝ)^2) := by
  unfold heatMode
  exact Real.exp_pos _

/-- **Per-mode heat-mode upper bound.**  At `a = 1/2`, the heat-
semigroup mode satisfies `heatMode (1/2) (k²) ≤ 1` (since the
exponent `-(2 · 1/2) · k² = -k² ≤ 0`). -/
theorem heatMode_at_unit_action_le_one (k : ℕ) :
    heatMode (1 / 2 : ℝ) ((k : ℝ)^2) ≤ 1 := by
  unfold heatMode
  rw [Real.exp_le_one_iff]
  have hk : 0 ≤ (k : ℝ)^2 := sq_nonneg _
  linarith

-- ═══════════════════════════════════════════════════════════════════════
-- Capstone: Stokes-spectral cube cutoff structural shape
-- ═══════════════════════════════════════════════════════════════════════

/-- ★ **Capstone — Stokes-spectral cube-cutoff structural chain** ★

For any cutoff `N`:
  1. `Z_N_3D N = (∑ k < N, heatMode (1/2) (k²))^3`  (PR #46);
  2. each mode contributes a bounded weight in `(0, 1]`.

Bundles the cube-decomposition with per-mode positivity and upper
bound, exposing the structural shape downstream consumers (no-renorm
chain via `T3TailBound`, `HigherDegreeT3TailSharp`) need at one
boundary. -/
theorem stokes_spectral_cube_chain (N : ℕ) :
    Z_N_3D N
        = (∑ k ∈ Finset.range N, heatMode (1 / 2 : ℝ) ((k : ℝ)^2))^3 ∧
      (∀ k ∈ Finset.range N,
        0 < heatMode (1 / 2 : ℝ) ((k : ℝ)^2) ∧
          heatMode (1 / 2 : ℝ) ((k : ℝ)^2) ≤ 1) :=
  ⟨Z_N_3D_eq_heatMode_partial_sum_cube N,
   fun k _ => ⟨heatMode_at_unit_action_pos k,
              heatMode_at_unit_action_le_one k⟩⟩

end

end CATEPTMain.Integration.SpectralTermHeatModeBridge
