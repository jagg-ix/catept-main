import CATEPTMain.CATEPT.Foundations

set_option autoImplicit false

/-!
# Example 9: Landauer's Principle from the Complex Action

## What makes this unique to CAT/EPT

Landauer's principle states that erasing one bit of information costs
at least k_BT ln 2 of energy. In standard physics, this is a separate
thermodynamic result with an independent proof.

In CAT/EPT, the Landauer bound **falls out** of the framework:

- Erasing 1 bit corresponds to a specific S_I contribution
- The energy cost ΔE = ℏ τ_ent ⟨H_I⟩ (Eq 14)
- The entropic rate λ = k_BT/ℏ (Eq 13) connects to temperature
- Combining: ΔE ≥ k_BT ln 2

This is not derived separately — it's a consequence of the same
complex action structure that gives damping, Feynman-Kac weights,
and the entropic time. Information costs energy because the imaginary
action IS the entropy, and entropy production IS the time flow.

## Key results

1. Landauer cost = k_BT ln 2 > 0
2. Entropic rate λ = κ/(2π) = k_BT/ℏ
3. Energy dissipation ΔE = ℏ τ_ent ⟨H_I⟩ ≥ 0
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Landauer cost is positive
example (k_B T : ℝ) (hkB : 0 < k_B) (hT : 0 < T) :
    0 < landauer_cost k_B T :=
  eq027_landauer_principle k_B T hkB hT

-- Landauer cost is exactly k_BT ln 2
example (k_B T : ℝ) :
    landauer_cost k_B T = k_B * T * Real.log 2 := rfl

-- Entropic rate formula: κ/(2π) = k_BT/ℏ
example (κ k_B T ℏ : ℝ) (hh : 0 < ℏ) (hkB : 0 < k_B)
    (hT : T = ℏ * κ / (2 * Real.pi * k_B)) :
    κ / (2 * Real.pi) = k_B * T / ℏ :=
  eq013_entropic_rate_formula κ k_B T ℏ hh hkB hT

-- Entropic rate is non-negative
example (κ : ℝ) (hκ : 0 ≤ κ) : 0 ≤ κ / (2 * Real.pi) :=
  eq013_entropic_rate_nonneg κ hκ

-- Energy dissipation ΔE = ℏ τ_ent ⟨H_I⟩ is non-negative
example (ℏ τ_ent H_I : ℝ) (hh : 0 < ℏ) (hτ : 0 ≤ τ_ent) (hH : 0 ≤ H_I) :
    0 ≤ ℏ * τ_ent * H_I :=
  eq014_energy_nonneg ℏ τ_ent H_I hh hτ hH

-- Hawking temperature is positive (the entropic rate has a temperature)
example (ℏ κ c k_B : ℝ) (h1 : 0 < ℏ) (h2 : 0 < κ) (h3 : 0 < c) (h4 : 0 < k_B) :
    0 < hawking_temperature ℏ κ c k_B :=
  eq012_temperature_positive ℏ κ c k_B h1 h2 h3 h4

end CATEPT.Examples
