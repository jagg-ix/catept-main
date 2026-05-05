import CATEPTMain.Integration.RelativeEntropyModularBridge
import CATEPTMain.Integration.StochasticEntropyIntegrationBridge
import CATEPTMain.Integration.CausalHydroRelaxationBridge
import CATEPTMain.Integration.SpectralSumPartition
import CATEPTMain.Integration.T3SpectralPartition
import CATEPTMain.Integration.EntropicCoercivityFromEntropyProduction
import CATEPTMain.Integration.RelativeEntropyProductionBridge
import CATEPTMain.Integration.GibbsMeasureKolmogorovBridge
import CATEPTMain.Integration.ThermodynamicsLYEntropyBridge

import CATEPTMain.CATEPT.CATEPT.Examples.Ex22_UnifiedMercuryMpemba
import CATEPTMain.Integration.EntropicCoercivityFromViscousDissipation
import CATEPTMain.Integration.GelfandYaglomPartition
import CATEPTMain.Integration.GelfandYaglomPartitionPos
import CATEPTMain.Integration.QuantumInfoEntropyConsistencyBridge
import CATEPTMain.Integration.QuantumMpembaUnificationExample
import CATEPTMain.Integration.TolmanDissipationRedshiftBridge
import CATEPTMain.QuantumOps.Theoremized.Batch20260408_13_OperatorEntropyIntegration
import CATEPTMain.Spacetime.Theoremized.Batch20260408_18_RegularizedEntropyMinimization
/-!
# ThermoOrphanBundle — Option B spine-recovery bundle for thermo pillar

Wires substantive previously-orphan thermodynamics modules onto the
root-reachable spine.  Builds the thermo pillar coverage from the
4-module post-Option-A baseline up to ~14 reachable thermo modules.

## Modules wired (9)

* `RelativeEntropyModularBridge` — relative-entropy / modular-flow seam (14 thm, 3 struct).
* `StochasticEntropyIntegrationBridge` — stochastic-entropy integration (10 thm, 2 struct).
* `CausalHydroRelaxationBridge` — causal hydrodynamic relaxation (9 thm, 2 struct).
* `SpectralSumPartition` — spectral partition sum (13 thm).
* `T3SpectralPartition` — T³ spectral partition (9 thm).
* `EntropicCoercivityFromEntropyProduction` — entropy-production coercivity (5 thm, 1 struct).
* `RelativeEntropyProductionBridge` — relative entropy production (3 thm, 1 struct).
* `GibbsMeasureKolmogorovBridge` — Gibbs-Kolmogorov bridge (6 thm).
* `ThermodynamicsLYEntropyBridge` — Lieb-Yngvason entropy seam (6 thm).

ArrowMpemba (CATEPTMain.CATEPT.CATEPT.ArrowMpemba) was probed and
fails to build cleanly; deferred to a future fix-and-wire task.

Tracked by worklog task `catept_spine_orphan_triage_thermo_20260503`.
-/
namespace CATEPTMain.Integration.ThermoOrphanBundle
end CATEPTMain.Integration.ThermoOrphanBundle
