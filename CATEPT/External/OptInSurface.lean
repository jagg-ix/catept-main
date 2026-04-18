import NavierStokesClean.CATEPT.External.ETHGibbsBrownianIntegration
import NavierStokesClean.CATEPT.External.ExternalLeverageCatalog
import NavierStokesClean.CATEPT.External.ThermodynamicsEntropyInterface
import NavierStokesClean.CATEPT.External.GibbsMeasureInterface
import NavierStokesClean.CATEPT.External.CarlesonInterface
import NavierStokesClean.CATEPT.External.Pphi2OSInterface
import NavierStokesClean.CATEPT.External.NoFasterThanLightInterface
import NavierStokesClean.CATEPT.External.NoFasterThanLightTranslatorSnapshot
import NavierStokesClean.CATEPT.External.ETHQuantumThermalizationBridge
import NavierStokesClean.CATEPT.External.IntegratedEquationContracts
import NavierStokesClean.CATEPT.External.BrownianMotionInterface
import NavierStokesClean.CATEPT.External.BochnerMinlosInterface
import NavierStokesClean.CATEPT.External.HilleYosidaInterface
import NavierStokesClean.CATEPT.External.QuantumInfoInterface
import NavierStokesClean.CATEPT.External.IsabelleMarriesDiracInterface
import NavierStokesClean.CATEPT.External.CslibFoundationInterface
import NavierStokesClean.CATEPT.External.KolmogorovComplexityInterface
import NavierStokesClean.CATEPT.External.BellEntanglementRelativityBridge

set_option autoImplicit false

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
- Gibbs-measure specification interfaces
- Brownian-motion and stochastic-integration interfaces
- ETH-Gibbs-Brownian integration layer
- Kolmogorov-complexity / AIT interfaces
- finite-dimensional quantum-information interfaces
- CSLib foundational semantics/inference interfaces (LTS, bisimulation, context congruence)
-/
