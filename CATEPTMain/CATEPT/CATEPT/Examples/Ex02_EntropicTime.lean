import CATEPTMain.CATEPT.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.InfluenceFunctionalBridge

set_option autoImplicit false

/-!
# Example 2: Entropic Time — τ_ent = S_I / ℏ

## What makes this unique to CAT/EPT

In standard physics, time is either:
- A background parameter (Newtonian, SR, QM)
- Frozen / absent (Wheeler-DeWitt, timeless QG)

In CAT/EPT, time **emerges from information loss**:

  τ_ent = S_I / ℏ

where S_I is the imaginary part of the complex action. Since S_I ≥ 0
(proved from the influence functional), entropic time τ_ent ≥ 0
automatically — time flows forward because entropy increases.

The entropic rate λ = (1/ℏ) dS_I/dt = (1/k_B) dS_ent/dt bridges
quantum mechanics (ℏ) and thermodynamics (k_B) in a single parameter.

## Key properties

1. τ_ent ≥ 0 (time flows forward)
2. τ_ent is additive (time from successive intervals adds)
3. τ_ent is a scalar, not an operator (bypasses Pauli no-go)
4. τ_ent = 0 when S_I = 0 (no time flows without entropy production)
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Definition: entropic time is S_I / ℏ
example (hbar S_I : ℝ) (hh : 0 < hbar) :
    entropic_time hbar S_I = S_I / hbar :=
  eq003_entropic_time_def hbar S_I hh

-- Non-negativity: τ_ent ≥ 0 when S_I ≥ 0
example (hbar S_I : ℝ) (hh : 0 < hbar) (hS : 0 ≤ S_I) :
    0 ≤ entropic_time hbar S_I :=
  eq003_entropic_time_nonneg hbar S_I hh hS

-- Derived from influence functional (not assumed!)
example (m : InfluenceFunctionalModel) :
    0 ≤ entropic_time m.hbar m.actionIm :=
  entropic_time_nonneg_from_influence_functional m

-- Additivity: τ_ent(S_I₁ + S_I₂) = τ_ent(S_I₁) + τ_ent(S_I₂)
example (hbar S1 S2 : ℝ) (hh : 0 < hbar) :
    entropic_time hbar (S1 + S2) =
      entropic_time hbar S1 + entropic_time hbar S2 :=
  eq003_entropic_time_linear hbar S1 S2 hh

-- Zero: no time without entropy production
example (hbar : ℝ) : entropic_time hbar 0 = 0 := by
  unfold entropic_time; simp

-- Thermal Hamiltonian = entropic time (Eq 17 of CAT/EPT)
-- H_th = -ln ρ = S_I/ℏ = τ_ent
example (hbar S_I : ℝ) (hh : 0 < hbar) :
    S_I / hbar = entropic_time hbar S_I :=
  eq017_thermal_hamiltonian_equals_entropic_time hbar S_I hh

end CATEPT.Examples
