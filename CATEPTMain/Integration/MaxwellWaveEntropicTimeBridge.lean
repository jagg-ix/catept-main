import CATEPTMain.Integration.CATEPTSpaceTime
import NavierStokesClean.CATEPT.MaxwellWaveEntropicTimePublic
import NavierStokesClean.CATEPT.CurvedSpacetimeLeanMWEToMTPIBridge
import NavierStokesClean.CATEPT.CurvedSpacetimeAFPLeanMWEBridge

/-!
# MaxwellWave ↔ CAT/EPT Entropic-Time Bridge (Spine Surface)

This module puts the `MaxwellWave` (aka "lean-mwe") theorem surface on the
**CATEPTMain repo spine**, on-par with other physics components such as
`catept-plugin-vml-landau`.

What we use `MaxwellWave` for in the CAT/EPT spine:

- **Electromagnetism**: Maxwell's equations and derived wave equations.
- **Entropic proper time**: re-index the already-proved MaxwellWave theorems
  under an entropic-first coordinate `τ`, using the public surface
  `NavierStokesClean.CATEPT.MaxwellWaveEntropicTimePublic`.
- **Curved-spacetime integration point**: lift sampled MaxwellWave observables
  into the CAT/EPT curved measure-theoretic path-integral layer (MTPI) via
  `CurvedSpacetimeLeanMWEToMTPIBridge` and its AFP composition layer.

This file is intentionally a *thin* re-export surface:
it does not re-prove MaxwellWave, and it does not alter any semantics.
It makes the MaxwellWave/EPT/curved-space bridge *reachable* from the top-level
`CATEPTMain.lean` import spine so other integration lanes can depend on it
without importing `NavierStokesClean.CATEPT.*` directly.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.MaxwellWaveEntropicTime

open NavierStokesClean.CATEPT

-- Public entropic-first MaxwellWave API (τ fundamental, t derived).
export NavierStokesClean.CATEPT.MaxwellWaveEntropicTimePublic
  (EntropicSpaceTime
   geometricTime
   geometricTime_eq_composed
   general_wave_equation_E_tau
   general_wave_equation_B_tau
   gauss_simplified_tau
   faraday_tau
   cfl_invariant
   dt_bound_from_dtau_bound)

-- Curved-spacetime MTPI lift of sampled MaxwellWave fields/observables.
export NavierStokesClean.CATEPT
  (LeanMWEFieldLift
   LeanMWEGeneratingFamily)

-- AFP + lean-mwe + curved MTPI composition layer.
export NavierStokesClean.CATEPT
  (CurvedSpacetimeAFPLeanMWEBridge)

end CATEPTMain.Integration.MaxwellWaveEntropicTime

