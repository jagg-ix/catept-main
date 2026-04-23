import CATEPTMain.CATEPT.CATEPT.QuantumGravity

set_option autoImplicit false

/-!
# Example 8: Bekenstein-Hawking Entropy and Entropic Rate

## What makes this unique to CAT/EPT

The Bekenstein-Hawking entropy S_BH = 4πGM² is normally presented as
an isolated result connecting black hole area to entropy.

In CAT/EPT, it fits naturally into the entropic time framework:

- Surface gravity κ defines the entropic rate: λ = κ/(2π)
- Hawking temperature: T = ℏκ/(2πck_B)
- BH entropy: S_BH = 4πGM² scales as area (holographic)
- S(2M) = 4·S(M) (area law from M² scaling)

The key insight: Bekenstein-Hawking entropy is an **entropic time
budget** — it measures the total entropic time available before the
black hole evaporates. The surface gravity κ sets the rate at which
the entropic clock ticks at the horizon.

## Key results

1. S_BH = A/(4G) (area formula)
2. S_BH > 0 (entropy is positive)
3. S_BH ∝ M² (scales as mass squared = area)
4. S(2M) = 4·S(M) (area-law doubling)
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- BH entropy equals area / (4G)
example (G M : ℝ) (hG : 0 < G) (hM : 0 < M) :
    bekenstein_hawking_entropy G M = horizon_area G M / (4 * G) :=
  eq147_152_bh_entropy_formula G M hG hM

-- BH entropy is positive
example (G M : ℝ) (hG : 0 < G) (hM : 0 < M) :
    0 < bekenstein_hawking_entropy G M :=
  eq147_152_bh_entropy_positive G M hG hM

-- M² scaling: S(M₂)/S(M₁) = (M₂/M₁)²
example (G M₁ M₂ : ℝ) (hG : 0 < G) (hM1 : 0 < M₁) :
    bekenstein_hawking_entropy G M₂ / bekenstein_hawking_entropy G M₁ =
      (M₂ / M₁) ^ 2 :=
  eq147_152_bh_entropy_scaling G M₁ M₂ hG hM1

-- Area-law doubling: doubling mass quadruples entropy
example (G M : ℝ) (hG : 0 < G) (hM : 0 < M) :
    bekenstein_hawking_entropy G (2 * M) =
      4 * bekenstein_hawking_entropy G M :=
  eq147_152_bh_entropy_doubling G M hG hM

-- Surface gravity is positive outside the horizon
-- (sets the entropic rate λ = κ/(2π) for the BH clock)
example (M r_B : ℝ) (hM : 0 < M) (hr : 2 * M < r_B) :
    0 < surface_gravity M r_B :=
  eq047_surface_gravity_positive M r_B hM hr

end CATEPT.Examples
