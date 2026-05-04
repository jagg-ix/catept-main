import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Adapters.Pphi2
import Mathlib.Tactic.Positivity

/-!
# Pphi2N Adapter — `TemporalFramework` instance for the O(N) extension

Magnitude-level adapter for `mrdouglasny/pphi2N` — the O(N)-symmetric
linear sigma model extension of `pphi2`.  Wraps the imaginary-action
magnitude in a `TemporalFramework` instance so the O(N) sigma model
participates in the `JointAdapter` N-way spine composition.

## Carrier

The Pphi2N carrier extends `Pphi2Config` with the field-component count
`N : ℕ` (positive), and the surrogate clock scales the φ²₂ imaginary
action linearly in N — the carrier-level imprint of the large-N
Hubbard–Stratonovich decoupling proven in
`CATEPTMain.Integration.Pphi2NCATEPTBridge`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

/-- **Magnitude-level Pphi2N carrier**: scalar pphi2 data + O(N)
component count. -/
structure Pphi2NConfig where
  /-- Underlying scalar pphi2 carrier. -/
  scalar : Pphi2Config
  /-- Number of O(N) field components, `N ≥ 1`. -/
  N      : ℕ
  /-- `N ≥ 1` (non-degenerate field structure). -/
  N_pos  : 1 ≤ N

namespace Pphi2NConfig

/-- **Pphi2N imaginary action**:
    `S_I[c] := N · S_I[c.scalar] = N · (m²·L + λ_0·L)`. -/
def imaginaryAction (c : Pphi2NConfig) : ℝ :=
  (c.N : ℝ) * c.scalar.imaginaryAction

theorem imaginaryAction_nonneg (c : Pphi2NConfig) : 0 ≤ c.imaginaryAction := by
  unfold imaginaryAction
  exact mul_nonneg (Nat.cast_nonneg _) c.scalar.imaginaryAction_nonneg

/-- Trivial witness: scalar = vacuum, N = 1. -/
def vacuum : Pphi2NConfig where
  scalar := Pphi2Config.vacuum
  N      := 1
  N_pos  := le_refl 1

end Pphi2NConfig

/-- **Pphi2N as a kernel-tier `TemporalFramework`.** -/
def pphi2N : TemporalFramework where
  Config := Pphi2NConfig
  clock := Pphi2NConfig.imaginaryAction
  clock_nonneg := Pphi2NConfig.imaginaryAction_nonneg
  witness := Pphi2NConfig.vacuum

/-- The Pphi2N adapter satisfies the spine by the universal coherence
theorem. -/
theorem pphi2N_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      pphi2N.toCATEPTSlot :=
  pphi2N.coherence_spine

end CATEPTMain.Temporal.Adapter
