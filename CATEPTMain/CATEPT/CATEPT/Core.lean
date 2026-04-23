import CATEPTMain.CATEPT.CATEPT.Basic
import CATEPTMain.CATEPT.CATEPT.Foundations
import CATEPTMain.CATEPT.CATEPT.PathIntegrals
import CATEPTMain.CATEPT.CATEPT.FoundationalSwapArchitecture
import CATEPTMain.CATEPT.CATEPT.BellCHSHBohmCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.BohmianBornRuleCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.ModularFlowKucharCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.MeasurePathIntegral
import CATEPTMain.CATEPT.CATEPT.PathIntegralMeasureContracts
import CATEPTMain.CATEPT.CATEPT.MeasurementCommunicationCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.QTMCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.KolmogorovCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.OriginCoreBridge
import CATEPTMain.CATEPT.CATEPT.TheoryPluginArchitecture
import CATEPTMain.CATEPT.CATEPT.TheoryPluginDimCategoryCore
import CATEPTMain.CATEPT.CATEPT.TheoryPluginAdapterFacade
import CATEPTMain.CATEPT.CATEPT.TheoryPluginAdapterFacadeExamples
import CATEPTMain.CATEPT.CATEPT.TheoryPluginExamples
import CATEPTMain.CATEPT.CATEPT.ComplexMeasureBridge
import CATEPTMain.CATEPT.CATEPT.UnitsDimensionalAnalysis
import CATEPTMain.CATEPT.CATEPT.CFLDimensionalCategoryBridge
import CATEPTMain.CATEPT.CATEPT.NHQMCATEPTBridge
import CATEPTMain.CATEPT.CATEPT.QIFCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.ThermodynamicsCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.FeynmanKacBridge
import CATEPTMain.CATEPT.CATEPT.QuantumGravity
import CATEPTMain.CATEPT.CATEPT.QFTGRClosures
import CATEPTMain.CATEPT.CATEPT.ElectromagnetismCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.GravitasCoreBridge
import CATEPTMain.CATEPT.CATEPT.QEDCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.QCDCoreAbstractions
import CATEPTMain.CATEPT.CATEPT.FundamentalInteractionsCoreBridge
import CATEPTMain.CATEPT.CATEPT.PauliNoGoEntropicTimeBridge
import CATEPTMain.CATEPT.CATEPT.InfluenceFunctionalBridge
import CATEPTMain.CATEPT.CATEPT.MuonGMinus2Bridge
import CATEPTMain.CATEPT.CATEPT.TrefoilTopologyBridge

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
import CATEPTMain.CATEPT.CATEPT.SpinorPathIntegralBridge
import CATEPTMain.CATEPT.CATEPT.CATEPTPredictions
import CATEPTMain.CATEPT.CATEPT.DiracMatrixAlgebra
import CATEPTMain.CATEPT.CATEPT.PerturbativeExpansionBridge
import CATEPTMain.CATEPT.CATEPT.DecoherencePredictions
import CATEPTMain.CATEPT.CATEPT.ClassicalGravityBridge
import CATEPTMain.CATEPT.CATEPT.CatsimEntropicTimeBridge
import CATEPTMain.CATEPT.CATEPT.CatsimGRObserversBridge
import CATEPTMain.CATEPT.CATEPT.GammaSandwichBridge
import CATEPTMain.CATEPT.CATEPT.ComplexEFEBridge
import CATEPTMain.CATEPT.CATEPT.EntropicLambdaCoupler
import CATEPTMain.CATEPT.CATEPT.DSFCouplingKernel
import CATEPTMain.CATEPT.CATEPT.UnificationChain
import CATEPTMain.CATEPT.CATEPT.FeynmanDiagramAlgebra
import CATEPTMain.CATEPT.CATEPT.LoopIntegrationReduction
import CATEPTMain.CATEPT.CATEPT.MuonG2Anomaly
import CATEPTMain.CATEPT.CATEPT.QCDConfinement
