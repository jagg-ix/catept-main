import NavierStokesClean.CATEPT.External.DSFThermoMetric
import NavierStokesClean.CATEPT.External.DSFRefractiveMetric
import NavierStokesClean.CATEPT.External.DSFWeylTime
import NavierStokesClean.CATEPT.External.DSFOrbitRGFlow

/-!
# DSF External Opt-In Surface

This module provides a narrow import surface for the DSF integration lanes:

- thermodynamic metric integration
- refractive metric integration
- Weyl-symbol emergent time integration
- enstrophy-driven RG orbit flow integration

Use this surface when only DSF bridge modules are needed.
-/
