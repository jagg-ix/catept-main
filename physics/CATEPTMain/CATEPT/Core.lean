import CATEPTMain.CATEPT.Basic
import CATEPTMain.CATEPT.Foundations
import CATEPTMain.CATEPT.PathIntegrals
import CATEPTMain.CATEPT.FoundationalSwapArchitecture
import CATEPTMain.CATEPT.BellCHSHBohmCoreAbstractions
import CATEPTMain.CATEPT.BohmianBornRuleCoreAbstractions
import CATEPTMain.CATEPT.ModularFlowKucharCoreAbstractions
import CATEPTMain.CATEPT.MeasurePathIntegral
import CATEPTMain.CATEPT.PathIntegralMeasureContracts
import CATEPTMain.CATEPT.MeasurementCommunicationCoreAbstractions
import CATEPTMain.CATEPT.QTMCoreAbstractions
import CATEPTMain.CATEPT.KolmogorovCoreAbstractions
import CATEPTMain.CATEPT.OriginCoreBridge
import CATEPTMain.CATEPT.TheoryPluginArchitecture
import CATEPTMain.CATEPT.TheoryPluginDimCategoryCore
import CATEPTMain.CATEPT.TheoryPluginAdapterFacade
import CATEPTMain.CATEPT.TheoryPluginAdapterFacadeExamples
import CATEPTMain.CATEPT.TheoryPluginExamples
import CATEPTMain.CATEPT.ComplexMeasureBridge
import CATEPTMain.CATEPT.UnitsDimensionalAnalysis
import CATEPTMain.CATEPT.CFLDimensionalCategoryBridge
import CATEPTMain.CATEPT.NHQMCATEPTBridge
import CATEPTMain.CATEPT.QIFCoreAbstractions
import CATEPTMain.CATEPT.ThermodynamicsCoreAbstractions
import CATEPTMain.CATEPT.FeynmanKacBridge
import CATEPTMain.CATEPT.QuantumGravity
import CATEPTMain.CATEPT.QFTGRClosures
import CATEPTMain.CATEPT.ElectromagnetismCoreAbstractions
import CATEPTMain.CATEPT.GravitasCoreBridge
import CATEPTMain.CATEPT.QEDCoreAbstractions
import CATEPTMain.CATEPT.QCDCoreAbstractions
import CATEPTMain.CATEPT.FundamentalInteractionsCoreBridge
import CATEPTMain.CATEPT.PauliNoGoEntropicTimeBridge
import CATEPTMain.CATEPT.InfluenceFunctionalBridge
import CATEPTMain.CATEPT.MuonGMinus2Bridge
import CATEPTMain.CATEPT.TrefoilTopologyBridge

set_option autoImplicit false

/-!
# CATEPT Core (Standalone)

Clean, theorist-oriented entry surface for the core CAT/EPT formal stack.

Included lanes:
- foundational CAT/EPT identities
- path-integral structure
- foundational-swap architecture contracts
- path-integral contract surface
- measurement/communication contract surface
- theory-plugin architecture contracts
- theory-plugin concrete examples
- Bell/CHSH/Bohm core abstractions
- Bohmian/Born-rule core abstractions
- modular-flow/Kuchar core abstractions
- quantum-gravity bridge layer
- QFT/GR closure lemmas
- electromagnetism/gravitas/QED/QCD compatibility lanes
- aggregated fundamental-interactions contract surface

This surface intentionally excludes external integration lanes, theoremized
batch imports, and plugin-heavy infrastructure.
-/
import CATEPTMain.CATEPT.SpinorPathIntegralBridge
import CATEPTMain.CATEPT.CATEPTPredictions
import CATEPTMain.CATEPT.DiracMatrixAlgebra
import CATEPTMain.CATEPT.PerturbativeExpansionBridge
import CATEPTMain.CATEPT.DecoherencePredictions
import CATEPTMain.CATEPT.ClassicalGravityBridge
import CATEPTMain.CATEPT.CatsimEntropicTimeBridge
import CATEPTMain.CATEPT.CatsimGRObserversBridge
import CATEPTMain.CATEPT.GammaSandwichBridge
import CATEPTMain.CATEPT.ComplexEFEBridge
import CATEPTMain.CATEPT.EntropicLambdaCoupler
import CATEPTMain.CATEPT.FeynmanDiagramAlgebra
import CATEPTMain.CATEPT.LoopIntegrationReduction
import CATEPTMain.CATEPT.MuonG2Anomaly
import CATEPTMain.CATEPT.QCDConfinement
