import CATEPTMain.Domains.TemporalFramework
import Mathlib.Tactic.Positivity

/-!
# Jacobson Thermodynamics Adapter — `TemporalFramework` instance

Magnitude-level adapter for Jacobson's *thermodynamics-of-spacetime*
program (Jacobson, *Phys. Rev. Lett.* 75 (1995) 1260; Verlinde,
*JHEP* 04 (2011) 029).  In Jacobson's argument the Einstein equation
`G_μν = 8πG T_μν` arises from the local Clausius identity
`δQ = T·δS` applied across a Rindler horizon, with `δS` proportional
to the area variation of the horizon.

## Carrier

The natural CAT/EPT clock on a Jacobson configuration is the entropy
*flux* across the local Rindler horizon — a non-negative quantity by
the second law (`δS ≥ 0`).

We expose a 2-field magnitude carrier:

* `entropyFlux : ℝ` — `δS / dλ ≥ 0`, the entropy production rate
* `properTime  : ℝ` — `λ ≥ 0`, affine parameter along the horizon
   generator

with surrogate clock `τ_ent[c] := δS · λ`, non-negative by the second
law.

## Honest scope

The full Jacobson discharge — proving `G_μν = 8πG T_μν` from local
equilibrium of horizon entropy flux — is **Phase 5E-γ work** referenced
in `CATEPTMain/Integration/CATEPTSpaceTime.lean` (`EPTEntropicEinsteinLocality`
axiom).  This adapter contributes the carrier-level TF instance that
participates in the spine; the operator-side discharge from Fisher info
+ entropy production to Einstein's equations is documented in
`Integration/LocalFisherEntropicGeneratorBridge.lean` and
`Integration/ConditionalEinsteinBridge.lean` and remains separately
trackable.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

/-- **Magnitude-level Jacobson thermodynamics carrier.**
Entropy flux + horizon affine parameter, both non-negative. -/
structure JacobsonConfig where
  /-- Entropy flux `δS / dλ ≥ 0` (second law of horizon thermodynamics). -/
  entropyFlux : ℝ
  /-- Affine parameter `λ ≥ 0` along the local Rindler horizon
      generator. -/
  properTime  : ℝ
  /-- `δS ≥ 0`. -/
  entropyFlux_nonneg : 0 ≤ entropyFlux
  /-- `λ ≥ 0`. -/
  properTime_nonneg  : 0 ≤ properTime

namespace JacobsonConfig

/-- **Jacobson entropic-time clock**:
    `τ_ent[c] := δS · λ ≥ 0`.  Carrier-level imprint of the second-law
    monotonicity `δS ≥ 0` along the horizon generator. -/
def entropicTime (c : JacobsonConfig) : ℝ :=
  c.entropyFlux * c.properTime

theorem entropicTime_nonneg (c : JacobsonConfig) : 0 ≤ c.entropicTime :=
  mul_nonneg c.entropyFlux_nonneg c.properTime_nonneg

/-- Trivial witness: equilibrium (zero entropy flux). -/
def equilibrium : JacobsonConfig where
  entropyFlux := 0
  properTime  := 0
  entropyFlux_nonneg := le_refl 0
  properTime_nonneg  := le_refl 0

end JacobsonConfig

/-- **Jacobson thermodynamics as a kernel-tier `TemporalFramework`.** -/
def jacobson : TemporalFramework where
  Config := JacobsonConfig
  clock := JacobsonConfig.entropicTime
  clock_nonneg := JacobsonConfig.entropicTime_nonneg
  witness := JacobsonConfig.equilibrium

/-- The Jacobson adapter satisfies the spine by the universal coherence
theorem. -/
theorem jacobson_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      jacobson.toCATEPTSlot :=
  jacobson.coherence_spine

end CATEPTMain.Temporal.Adapter
