import NavierStokesClean.CATEPT.External.BochnerMinlosInterface
import NavierStokesClean.CATEPT.External.HilleYosidaInterface
import NavierStokesClean.CATEPT.External.NoFasterThanLightInterface
import NavierStokesClean.CATEPT.External.NoFasterThanLightTranslatorSnapshot
import NavierStokesClean.CATEPT.External.IsabelleMarriesDiracInterface
import NavierStokesClean.CATEPT.External.Pphi2OSInterface
import NavierStokesClean.CATEPT.External.ThermodynamicsEntropyInterface
import NavierStokesClean.CATEPT.External.ExternalLeverageCatalog
import NavierStokesClean.CATEPT.External.IntegratedEquationContracts
import NavierStokesClean.CATEPT.External.BellEntanglementRelativityBridge
import NavierStokesClean.CATEPT.External.CarlesonInterface
import NavierStokesClean.CATEPT.External.ETHQuantumThermalizationBridge
import NavierStokesClean.CATEPT.External.ETHQGOptInSurface
import NavierStokesClean.CATEPT.External.GibbsMeasureInterface
import NavierStokesClean.CATEPT.External.BrownianMotionInterface
import NavierStokesClean.CATEPT.External.ETHGibbsBrownianIntegration
import NavierStokesClean.CATEPT.External.KolmogorovComplexityInterface
import NavierStokesClean.CATEPT.External.QuantumInfoInterface
import NavierStokesClean.CATEPT.External.HyperbolicUnificationInterface
import NavierStokesClean.CATEPT.External.DSFThermoMetric
import NavierStokesClean.CATEPT.External.DSFRefractiveMetric
import NavierStokesClean.CATEPT.External.DSFWeylTime
import NavierStokesClean.CATEPT.External.DSFOrbitRGFlow
import NavierStokesClean.CATEPT.External.DimensionalEmbeddings
import NavierStokesClean.CATEPT.External.TopologicalHolonomy
import NavierStokesClean.CATEPT.External.OrthogonalProjections
import NavierStokesClean.CATEPT.External.DSFQuantizedCohomology
import NavierStokesClean.CATEPT.External.DSFLQGIntertwiners
import NavierStokesClean.CATEPT.External.LQGOperators
import NavierStokesClean.CATEPT.External.WDWProblemOfTimeBridge
import NavierStokesClean.CATEPT.External.CslibFoundationInterface

/-!
# CATEPT External Opt-In Surface

This module is intentionally **not** imported by `CATEPT/CoreSurface.lean`.
It provides an optional import layer for external theorem-bridge contracts:

- Bochner/Minlos measure-theory interfaces
- Hille-Yosida semigroup interfaces
- AFP No-faster-than-light causality interfaces
- AFP no-faster-than-light translator snapshot interfaces
- AFP Isabelle_Marries_Dirac compatibility interfaces
- pphi2 OS/QFT certificate interfaces
- thermodynamic entropy-principle interfaces
- External leverage catalog (non-duplicated priority queue)
- Carleson spectral/dephasing control interfaces
- ETH quantum thermalization bridge layer
- ETH/QG bridge entry-point layer (spinor, alpha-divergence, Boue-Dupuis)
- Gibbs-measure specification interfaces
- Brownian-motion and stochastic-integration interfaces
- ETH-Gibbs-Brownian integration layer
- Kolmogorov-complexity / AIT interfaces
- finite-dimensional quantum-information interfaces
- hyperbolic-unification/Schmidt-thermal bridge interfaces
- DSF thermodynamic, refractive, weyl-time and RG orbit flow layers
- CSLib foundational semantics/inference interfaces (LTS, bisimulation, context congruence)
-/
