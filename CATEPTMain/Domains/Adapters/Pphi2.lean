import CATEPTMain.Domains.TemporalFramework
import Mathlib.Tactic.Positivity

/-!
# Pphi2 Adapter — `TemporalFramework` instance for Euclidean φ⁴_2 QFT

Carrier-level adapter wrapping the magnitude-level imaginary-action of the
constructive Euclidean P(Φ)₂ quantum field theory (`mrdouglasny/pphi2`,
already integrated via `CATEPTMain/Integration/Pphi2CATEPTEPTBridge.lean`)
as a `TemporalFramework` instance.

## Carrier surrogate

The constructive OS framework on Pphi2 yields a positive-definite
imaginary action `S_I[φ] ≥ 0`.  At the magnitude level we expose a
3-parameter carrier:

* `massSquared : ℝ` — squared bare mass `m²` (`≥ 0`)
* `volume      : ℝ` — finite-volume box scale `L` (`≥ 0`)
* `coupling    : ℝ` — bare coupling `λ_0` (`≥ 0`)

with surrogate clock `S_I[c] := c.massSquared · c.volume + c.coupling · c.volume`,
non-negative by construction.  This is the carrier-level imprint of the
proven `pphi2_catept_ept_nonneg` from `Pphi2CATEPTEPTBridge`.

The full constructive OS theorems (`os0`–`os4` reflection-positivity, mass-
gap, reconstruction) live in the `Pphi2` package proper; this adapter is
the lightweight glue exposing pphi2 as a `TemporalFramework` so it
participates in the `JointAdapter` N-way spine composition.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

/-- **Magnitude-level Pphi2 carrier.** Three non-negative real fields
encoding the bare-action data of a P(Φ)₂ Euclidean QFT. -/
structure Pphi2Config where
  /-- Squared bare mass `m²`. -/
  massSquared : ℝ
  /-- Finite-volume box scale `L`. -/
  volume      : ℝ
  /-- Bare coupling `λ_0`. -/
  coupling    : ℝ
  /-- `m² ≥ 0` (vacuum stability). -/
  massSquared_nonneg : 0 ≤ massSquared
  /-- `L ≥ 0` (finite volume). -/
  volume_nonneg      : 0 ≤ volume
  /-- `λ_0 ≥ 0` (positive coupling). -/
  coupling_nonneg    : 0 ≤ coupling

namespace Pphi2Config

/-- **Magnitude-level pphi2 imaginary action**:
    `S_I[c] := m²·L + λ_0·L`.  Non-negative by construction; carrier-level
    imprint of `pphi2_catept_ept_nonneg`. -/
def imaginaryAction (c : Pphi2Config) : ℝ :=
  c.massSquared * c.volume + c.coupling * c.volume

theorem imaginaryAction_nonneg (c : Pphi2Config) : 0 ≤ c.imaginaryAction := by
  unfold imaginaryAction
  exact add_nonneg
    (mul_nonneg c.massSquared_nonneg c.volume_nonneg)
    (mul_nonneg c.coupling_nonneg c.volume_nonneg)

/-- Trivial witness: `m² = L = λ_0 = 0` (vacuum). -/
def vacuum : Pphi2Config where
  massSquared := 0
  volume      := 0
  coupling    := 0
  massSquared_nonneg := le_refl 0
  volume_nonneg      := le_refl 0
  coupling_nonneg    := le_refl 0

end Pphi2Config

/-- **Pphi2 as a kernel-tier `TemporalFramework`.** -/
def pphi2 : TemporalFramework where
  Config := Pphi2Config
  clock := Pphi2Config.imaginaryAction
  clock_nonneg := Pphi2Config.imaginaryAction_nonneg
  witness := Pphi2Config.vacuum

/-- The Pphi2 adapter satisfies the spine by the universal coherence
theorem — no per-domain proof needed. -/
theorem pphi2_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      pphi2.toCATEPTSlot :=
  pphi2.coherence_spine

end CATEPTMain.Temporal.Adapter
