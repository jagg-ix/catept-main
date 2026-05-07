import CATEPTMain.Integration.GreenDampingUVChain
import Mathlib.Algebra.Order.BigOperators.GroupWithZero.Finset

/-!
# Green-Damping UV Chain — Multimode Lift (Step 5b)

Lifts the single-mode `green_to_uv_damping_chain` (PR #39) to a finite
indexed family of Gaussian modes.  For any finite index `ι`, finset
`s : Finset ι`, and family `a : ι → ℝ` with each `a i > 0`, the
product

  `∏ i ∈ s, exp(−entropicProperTime (a i))`

is the multimode "Green damping" weight, and it inherits the canonical
damping-shape `(0, 1]` directly from the single-mode chain.

This is the natural lift to the multimode Gaussian field (e.g. the
spectral side of `T3SpectralPartition`): each Fourier mode `k ∈ ℤ³`
contributes its own `exp(−τ(a_k))` weight, and the joint partition
takes the finite product over a cube cutoff.  The single-mode link
to `MeasurePathIntegralModel.damping` (PR #39's
`green_damping_weight_bounded`) factorises through this product.

## What is honestly proven

* `multimode_green_damping_pos`: for any finite finset `s` and any
  family with each `a i > 0`,
  `0 < ∏ i ∈ s, Real.exp (−(entropicProperTime (a i)))`.

* `multimode_green_damping_le_one`: same family,
  `∏ i ∈ s, Real.exp (−(entropicProperTime (a i))) ≤ 1`.

* `multimode_green_damping_bounded` (★ HEADLINE ★): full damping shape:
  `0 < ∏ ≤ 1`.  This is the multimode-level link from
  `green_damping_weight_bounded` (single-mode) to the cube-factorization
  argument used by `T3TailBound` and `HigherDegreeT3TailSharp` (PR #32).

## Architectural fit

```text
single mode:  green_damping_weight_bounded  (PR #39)
                            ↓
multimode lift:  THIS PR — `Finset.prod_pos` + `Finset.prod_le_one`
                            ↓
cube-factorization argument: T3TailBound / HigherDegreeT3TailSharp (PR #32)
                            ↓
PhysicalUVConvergenceCertificate.physical_uv_certificate_no_counterterm_needed
```

The chain is now sequential and machine-checkable end-to-end at the
**multimode finite-cutoff level**.  Lifting from finite to the full
spectral cutoff family `Z_N` plugs in via the existing P22/P28
infrastructure.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GreenDampingUVChainMultimode

open CATEPTMain.Integration.GreenDampingUVChain
open CATEPTMain.Integration.PropagatorEntropicTime
open Finset

noncomputable section

variable {ι : Type*}

-- ═══════════════════════════════════════════════════════════════════════
-- Multimode positivity
-- ═══════════════════════════════════════════════════════════════════════

/-- **Multimode Green-damping is strictly positive.**  For any finite
finset `s` and any family `a : ι → ℝ` with each `a i > 0`,

  `0 < ∏ i ∈ s, exp(−entropicProperTime (a i))`. -/
theorem multimode_green_damping_pos
    (s : Finset ι) (a : ι → ℝ) (ha : ∀ i ∈ s, 0 < a i) :
    0 < ∏ i ∈ s, Real.exp (-(entropicProperTime (a i))) :=
  Finset.prod_pos fun i hi =>
    (green_damping_weight_bounded (a i) (ha i hi)).1

-- ═══════════════════════════════════════════════════════════════════════
-- Multimode upper bound
-- ═══════════════════════════════════════════════════════════════════════

/-- **Multimode Green-damping is at most 1.**  Each per-mode factor
sits in `(0, 1]`, so the product over any finite finset is also in
`(0, 1]`. -/
theorem multimode_green_damping_le_one
    (s : Finset ι) (a : ι → ℝ) (ha : ∀ i ∈ s, 0 < a i) :
    ∏ i ∈ s, Real.exp (-(entropicProperTime (a i))) ≤ 1 :=
  Finset.prod_le_one
    (fun i hi => (green_damping_weight_bounded (a i) (ha i hi)).1.le)
    (fun i hi => (green_damping_weight_bounded (a i) (ha i hi)).2)

-- ═══════════════════════════════════════════════════════════════════════
-- Headline: multimode damping shape (0, 1]
-- ═══════════════════════════════════════════════════════════════════════

/-- ★ **HEADLINE — multimode Green-damping shape** ★

Combines the per-mode damping shape `(0, 1]` from
`green_damping_weight_bounded` (PR #39) into the multimode product
shape `(0, 1]` for any finite finset of Gaussian modes.

This is the multimode analogue of `green_damping_weight_bounded`:
the partition-level UV-suppression weight for a finite Fourier cutoff
inherits the canonical `MeasurePathIntegralModel.damping` shape
directly from the single-mode chain, opening the route to the
cube-factorization argument (T3TailBound / HigherDegreeT3TailSharp)
without re-deriving positivity / upper-bound at every cutoff level. -/
theorem multimode_green_damping_bounded
    (s : Finset ι) (a : ι → ℝ) (ha : ∀ i ∈ s, 0 < a i) :
    0 < ∏ i ∈ s, Real.exp (-(entropicProperTime (a i))) ∧
      ∏ i ∈ s, Real.exp (-(entropicProperTime (a i))) ≤ 1 :=
  ⟨multimode_green_damping_pos s a ha,
   multimode_green_damping_le_one s a ha⟩

end

end CATEPTMain.Integration.GreenDampingUVChainMultimode
