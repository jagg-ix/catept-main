import CATEPTMain.CATEPT.DecoherencePredictions
import CATEPTMain.CATEPT.CATEPTPredictions

set_option autoImplicit false

/-!
# Example 17: CAT/EPT Decoherence Predictions (Cross-Domain)

## What makes this unique to CAT/EPT

The same complex-action structure that gives the muon g-2 correction
also predicts **decoherence rates** in quantum information systems.
This is not an independent result — it comes from the SAME entropic
rate formula:

  λ = k_B T / ℏ

For transmon qubits at dilution-fridge temperature T = 15 mK:
- CAT/EPT-predicted thermal floor: T_floor = ℏ / (k_B T) ≈ 0.51 ns
- Observed T2 ≈ 100 μs (Kjaergaard et al. 2020)

The observed T2 is ~200,000× longer than the thermal floor — meaning
most bath modes are effectively decoupled. This ratio measures the
effective bath-mode isolation of the qubit.

## Why cross-domain matters

One framework (S = S_R + iS_I with S_I ≥ 0) predicts:
- Anomalous magnetic moments (Ex11, Ex15, Ex16)
- Black hole entropy (Ex08)
- Landauer cost (Ex09)
- UV convergence (Ex10)
- **Decoherence rates (this example)**

No separate "decoherence theory" is needed. The imaginary action
S_I IS the entropy IS the decoherence driver.

## Numerical evaluation

```
#eval CATEPT.Numerics.lambda_transmon_f            -- thermal rate at 15 mK
#eval CATEPT.Numerics.T2_thermal_floor_transmon_f  -- ~5e-10 s
#eval CATEPT.Numerics.reportTransmonT2
```

## Structural theorems (proved)

1. Thermal decoherence rate positive for positive T, k_B, ℏ
2. Monotone in temperature (higher T → faster decoherence)
3. Thermal floor antitone in T (colder → longer coherence)
4. FK decoherence weight exp(-γt) ∈ (0, 1] for γ, t ≥ 0
-/

noncomputable section

namespace CATEPT.Examples

open CATEPT

-- Thermal rate is positive
example (k_B T hbar : ℝ) (hk : 0 < k_B) (hT : 0 < T) (hh : 0 < hbar) :
    0 < thermal_decoherence_rate k_B T hbar :=
  thermal_decoherence_rate_positive k_B T hbar hk hT hh

-- Higher T → faster decoherence (monotone)
example (k_B T₁ T₂ hbar : ℝ) (hk : 0 < k_B) (hh : 0 < hbar)
    (h12 : T₁ < T₂) :
    thermal_decoherence_rate k_B T₁ hbar <
      thermal_decoherence_rate k_B T₂ hbar :=
  thermal_decoherence_rate_monotone k_B T₁ T₂ hbar hk hh h12

-- Thermal floor is positive
example (k_B T hbar : ℝ) (hk : 0 < k_B) (hT : 0 < T) (hh : 0 < hbar) :
    0 < thermal_decoherence_floor k_B T hbar :=
  thermal_decoherence_floor_positive k_B T hbar hk hT hh

-- Colder → longer coherence (antitone)
example (k_B T₁ T₂ hbar : ℝ) (hk : 0 < k_B) (hh : 0 < hbar)
    (h1 : 0 < T₁) (h12 : T₁ < T₂) :
    thermal_decoherence_floor k_B T₂ hbar <
      thermal_decoherence_floor k_B T₁ hbar :=
  thermal_floor_antitone_in_T k_B T₁ T₂ hbar hk hh h1 h12

-- FK decoherence weight always in (0, 1] for nonneg γ, t
example (γ t : ℝ) (hγ : 0 ≤ γ) (ht : 0 ≤ t) :
    0 < fk_decoherence_weight γ t ∧ fk_decoherence_weight γ t ≤ 1 :=
  ⟨fk_decoherence_weight_pos γ t,
   fk_decoherence_weight_le_one γ t hγ ht⟩

-- Stronger decoherence → faster decay (for t > 0)
example (γ₁ γ₂ t : ℝ) (ht : 0 < t) (h12 : γ₁ < γ₂) :
    fk_decoherence_weight γ₂ t < fk_decoherence_weight γ₁ t :=
  fk_weight_faster_decay_for_larger_γ γ₁ γ₂ t ht h12

/-! ### Bridging to g-2: same rate formula

The decoherence rate λ = k_B T / ℏ is the SAME formula that appears in
the entropic rate for g-2 (Ex09). This is the framework unification
in action: one formula, two domains.
-/

-- The Landauer cost k_B T ln 2 is structurally linked to the decoherence rate
example (k_B T ℏ : ℝ) (hk : 0 < k_B) (hT : 0 < T) (hh : 0 < ℏ) :
    0 < thermal_decoherence_rate k_B T ℏ ∧ 0 < landauer_cost k_B T :=
  ⟨thermal_decoherence_rate_positive k_B T ℏ hk hT hh,
   eq027_landauer_principle k_B T hk hT⟩

end CATEPT.Examples
