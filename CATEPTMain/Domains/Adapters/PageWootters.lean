import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
import Mathlib.Tactic.Positivity

/-!
# Page–Wootters Adapter — `TemporalFramework` instance

Wraps the `PageWoottersQuantumTimeCarrier` (PR #6,
`CATEPTMain.Integration.PageWoottersQuantumTimeCarrier`) as a kernel-tier
`TemporalFramework` instance.

## Carrier

The Page–Wootters mechanism (Page–Wootters PRD 27 (1983) 2885) gives a
clock-conditional time parameter `t` and a Schrödinger phase
`phaseS = -E_S·t/ℏ`.  At positive system energy `E_S ≥ 0` and clock
reading `t ≥ 0`, the magnitude `|phaseS|·ℏ = E_S · t ≥ 0` is the natural
non-negative clock.

The TF Config is therefore a 2-parameter carrier:

* `systemEnergy : ℝ` — `E_S ≥ 0`
* `clockReading : ℝ` — `t ≥ 0`

with clock `τ_PW[c] := E_S · t`.  Equivalent up to constants to the
Wick-rotation magnitude `−phaseS · ℏ = E_S · t` proved in
`pageWootters_thermal_eval_identity`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

/-- **Page–Wootters magnitude carrier**: system energy + clock reading,
both non-negative. -/
structure PageWoottersConfig where
  /-- System Hamiltonian eigenvalue (energy), `≥ 0`. -/
  systemEnergy : ℝ
  /-- Clock reading `t`, `≥ 0`. -/
  clockReading : ℝ
  /-- `E_S ≥ 0` (semibounded Hamiltonian). -/
  systemEnergy_nonneg : 0 ≤ systemEnergy
  /-- `t ≥ 0` (forward time). -/
  clockReading_nonneg : 0 ≤ clockReading

namespace PageWoottersConfig

/-- **Page–Wootters clock magnitude**:
    `τ_PW[c] := E_S · t`.  Carrier-level imprint of the proven
    `pageWootters_thermal_eval_identity` from the PW carrier. -/
def conditionalTime (c : PageWoottersConfig) : ℝ :=
  c.systemEnergy * c.clockReading

theorem conditionalTime_nonneg (c : PageWoottersConfig) : 0 ≤ c.conditionalTime :=
  mul_nonneg c.systemEnergy_nonneg c.clockReading_nonneg

/-- Trivial witness: zero energy, zero clock reading. -/
def vacuum : PageWoottersConfig where
  systemEnergy := 0
  clockReading := 0
  systemEnergy_nonneg := le_refl 0
  clockReading_nonneg := le_refl 0

end PageWoottersConfig

/-- **Page–Wootters as a kernel-tier `TemporalFramework`.** -/
def pageWootters : TemporalFramework where
  Config := PageWoottersConfig
  clock := PageWoottersConfig.conditionalTime
  clock_nonneg := PageWoottersConfig.conditionalTime_nonneg
  witness := PageWoottersConfig.vacuum

/-- The Page–Wootters adapter satisfies the spine by the universal
coherence theorem. -/
theorem pageWootters_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      pageWootters.toCATEPTSlot :=
  pageWootters.coherence_spine

end CATEPTMain.Temporal.Adapter
