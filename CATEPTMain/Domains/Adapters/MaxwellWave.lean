import CATEPTMain.Domains.TemporalFramework
import Mathlib.Tactic.Positivity

/-!
# MaxwellWave Adapter — `TemporalFramework` instance for the Maxwell
wave equation

Magnitude-level adapter wrapping the Maxwell-wave content of
`MaxwellWaveCATEPTSpaceTimeBridge` and `MaxwellWaveEntropicTimeBridge`
as a kernel-tier `TemporalFramework` instance.

## Carrier

The Maxwell wave equation `□A_μ = J_μ` admits a positive-definite energy
functional `E[A] = (1/2)(|∂A|² + ω² |A|²)` at each Fourier mode.
We expose a 2-parameter magnitude carrier:

* `frequencySquared : ℝ` — `ω² ≥ 0` (wave-mode frequency squared)
* `amplitudeSquared : ℝ` — `|A|² ≥ 0` (squared amplitude)

with surrogate clock `τ_wave[c] := ω² · |A|² ≥ 0`.  Carrier-level imprint
of the proven non-negativity in
`CATEPTMain.Integration.MaxwellWaveCATEPTSpaceTimeBridge`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

/-- **Magnitude-level MaxwellWave carrier.** Wave-mode frequency² + squared
amplitude, both non-negative. -/
structure MaxwellWaveConfig where
  /-- `ω² ≥ 0`, frequency squared. -/
  frequencySquared : ℝ
  /-- `|A|² ≥ 0`, mode amplitude squared. -/
  amplitudeSquared : ℝ
  /-- `ω² ≥ 0`. -/
  frequencySquared_nonneg : 0 ≤ frequencySquared
  /-- `|A|² ≥ 0`. -/
  amplitudeSquared_nonneg : 0 ≤ amplitudeSquared

namespace MaxwellWaveConfig

/-- **Maxwell-wave magnitude clock**:
    `τ_wave[c] := ω² · |A|² ≥ 0`. -/
def waveAction (c : MaxwellWaveConfig) : ℝ :=
  c.frequencySquared * c.amplitudeSquared

theorem waveAction_nonneg (c : MaxwellWaveConfig) : 0 ≤ c.waveAction :=
  mul_nonneg c.frequencySquared_nonneg c.amplitudeSquared_nonneg

/-- Trivial witness: zero-frequency, zero-amplitude vacuum mode. -/
def vacuum : MaxwellWaveConfig where
  frequencySquared := 0
  amplitudeSquared := 0
  frequencySquared_nonneg := le_refl 0
  amplitudeSquared_nonneg := le_refl 0

end MaxwellWaveConfig

/-- **MaxwellWave as a kernel-tier `TemporalFramework`.** -/
def maxwellWave : TemporalFramework where
  Config := MaxwellWaveConfig
  clock := MaxwellWaveConfig.waveAction
  clock_nonneg := MaxwellWaveConfig.waveAction_nonneg
  witness := MaxwellWaveConfig.vacuum

/-- The MaxwellWave adapter satisfies the spine by the universal coherence
theorem. -/
theorem maxwellWave_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      maxwellWave.toCATEPTSlot :=
  maxwellWave.coherence_spine

end CATEPTMain.Temporal.Adapter
