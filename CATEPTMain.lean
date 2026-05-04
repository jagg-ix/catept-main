import Bochner
import HilleYosida
import Cslib
import CATEPTMain.External.Registry
-- Canonical small “single import” spine entrypoint (prevents proof islands).
import CATEPTMain.RepoSpine
-- Superior-Method plugin architecture (Target 3)
import CATEPTMain.Domains.SuperiorMethod
import CATEPTMain.Domains.QM.Domain
import CATEPTMain.Domains.GR.Domain
import CATEPTMain.Domains.ETH.Domain
import CATEPTMain.Bridges.SuperiorMethodBridges
import CATEPTMain.Bridges.CrossDomainCompat
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge
import CATEPTMain.Integration.EntropicProperTimeCoreBridge
import CATEPTMain.Integration.Pphi2CATEPTEPTBridge
import CATEPTMain.Integration.ComplexDimensionalModularBridge
import CATEPTMain.Integration.AlphaDivergencePathIntegralBridge
import CATEPTMain.Integration.AlphaPathIntegralIntegration
import CATEPTMain.Integration.ComplexEinsteinPathIntegralBridge
import CATEPTMain.Integration.YoshidaFreeFisherBridge
import CATEPTMain.Integration.QuantumFisherBridge
import CATEPTMain.Integration.InformationDimensionalFrameworkBridge
import CATEPTMain.Integration.Pphi2NCATEPTBridge
import CATEPTMain.Integration.LGTCATEPTBridge
import CATEPTMain.Integration.LatticeQCDWilsonBridge
import CATEPTMain.Integration.NSCATEPTCoreBridge
import CATEPTMain.Integration.NSCATEPTExtendedBridge
import CATEPTMain.Integration.AdSCFTBridge
import CATEPTMain.Integration.CATEPTSpaceTime
import CATEPTMain.Integration.CarlesonBridge
import CATEPTMain.Integration.NSEPTNoetherInvariantBridge
import CATEPTMain.Integration.AdSCFTFourierCATEPTBridge
import CATEPTMain.Integration.AdSCFTMonoidalUnitArtifactBridge
import CATEPTMain.Integration.BohmianQMBridge
import CATEPTMain.Integration.QuantumInfoFisherBridge
import CATEPTMain.Integration.GravitasBridge
import CATEPTMain.Integration.BCJBridge
import CATEPTMain.Integration.TheoryPluginArchitecture
import CATEPTMain.Integration.TheoryPluginClassicalETHBridge
import CATEPTMain.Integration.SuperstatisticsTsallisBridge
import CATEPTMain.Integration.UnifiedTheorySpine
import CATEPTMain.Integration.QuantumCATEPTBridge
import CATEPTMain.Integration.ElectroweakCATEPTBridge
import CATEPTMain.Integration.VMLCATEPTBridge
import CATEPTMain.Integration.TheoryPluginAdapterSupport
import CATEPTMain.Integration.TheoryPluginAdapter
import CATEPTMain.Integration.TheoryPluginStressTests
import CATEPTMain.Integration.TheoryPluginDimSlot
import CATEPTMain.Integration.TheoryPluginDimCore
import CATEPTMain.Integration.TheoryPluginDimCategory
import CATEPTMain.Integration.TheoryPluginDimFundamental
import CATEPTMain.Integration.TheoryPluginQTMBridge
import CATEPTMain.Integration.QuantumMpembaUnificationBridge
import CATEPTMain.Integration.TheoryPluginKolmogorovLadder
import CATEPTMain.Integration.TheoryPluginOriginBridge
import CATEPTMain.Integration.TheoryPluginThermodynamicsOfChoiceBridge
import CATEPTMain.Integration.TheoryPluginPhyslibConstructBridge
import CATEPTMain.Integration.AQEIBridgeLane
import CATEPTMain.Integration.AdSCFTEntropicEntanglementBridge
import CATEPTMain.Integration.AdSCFTExtended
import CATEPTMain.Integration.BochnerMinlosBridge
import CATEPTMain.Integration.BrownianMotionBridge
import CATEPTMain.Integration.CslibBridge
import CATEPTMain.Integration.EnergyTensorConeLane
import CATEPTMain.Integration.GibbsMeasureBridge
import CATEPTMain.Integration.HilleYosidaBridge
import CATEPTMain.Integration.HopfLeanBridge
import CATEPTMain.Integration.LeanDimensionalAnalysisBridge
import CATEPTMain.Integration.LeanInfBridge
import CATEPTMain.Integration.QuantumInfoBridge
import CATEPTMain.Integration.TheoryPluginHerglotzETH
import CATEPTMain.Integration.ThermodynamicsLeanBridge
import CATEPTMain.Integration.UnifiedTheoryBellBridge
import CATEPTMain.Integration.BornRuleUnificationBridge
import CATEPTMain.Integration.VMLSteadyStateBridge
import CATEPTMain.Integration.ConditionalEinsteinBridge
import CATEPTMain.Integration.DiscreteHolographyBridge
import CATEPTMain.Integration.GaussianFieldLogSobolevBridge
import CATEPTMain.Integration.Pphi2CameronBridge
import CATEPTMain.Integration.DeGiorgiBridge
import CATEPTMain.Integration.SpectralPhysicsBridge
import CATEPTMain.Integration.NSStressEnergyEinsteinBridge
import CATEPTMain.Integration.NSNoetherEinsteinLocalityBridge
import CATEPTMain.Integration.EinsteinViscosityMpembaBridge
import CATEPTMain.Bridges
import CATEPTMain.Gravitas
import CATEPTMain.ActionIntegrationBridge
import CATEPTMain.Integration.SGSupermanifoldsBridge
import CATEPTMain.Integration.SGSuperRiemannSurfacesBridge
import CATEPTMain.Integration.SGRiemannSurfacesBridge
import CATEPTMain.Integration.StringGeometryBridge
import CATEPTMain.Integration.StringAlgebraVOABridge
import CATEPTMain.Integration.StringAlgebraMZVBridge
import CATEPTMain.Integration.StringAlgebraMTCBridge
import CATEPTMain.Integration.StringAlgebraLinfinityBridge
import CATEPTMain.Integration.StringAlgebraBridge
import CATEPTMain.Integration.StochasticPDENonstandardBridge
import CATEPTMain.Integration.StochasticPDEItoCalculusBridge
import CATEPTMain.Integration.StochasticPDEBridge
-- Operator-algebraic foundations: Logos Tomita-Takesaki ↔ CAT/EPT
-- modular flow / reduced channel layer (capstone aggregating five bridges).
import CATEPTMain.Integration.OperatorAlgebraicFoundationsBundle
-- Matsubara / Luttinger-Ward thermal-action carrier and AQFT modular-flow
-- equivalence (PR #127, #128).
import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import CATEPTMain.Integration.MatsubaraAQFTModularFlowEquivalenceBridge
-- Page-Wootters quantum-time carrier (clock-conditional emergent time)
-- and PW <-> Matsubara equivalence at the imaginary-time evaluation point.
-- Page & Wootters PRD 27 (1983) 2885; Hoehn-Smith-Lock Front. Phys. 9 (2021) 587083.
import CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
import CATEPTMain.Integration.PageWoottersMatsubaraEquivalenceBridge
-- Spine theorem: WDW <-> path integral <-> modular flow with Schrodinger
-- reduction under no entropic-clock evolution.  Connes-Rovelli thermal-time
-- hypothesis CQG 11 (1994) 2899.
import CATEPTMain.Integration.PageWoottersWDWPathIntegralModularFlowSpine
-- Concrete discrete-path-integral instantiation of the spine: Mathlib
-- gaussianReal product measure + discrete harmonic Euclidean action with
-- coercivity bridge into catept-core's eq054/eq057/eq058 damping ladder.
import CATEPTMain.Integration.DiscreteGaussianPathMeasure
import CATEPTMain.Integration.EuclideanActionHarmonicDiscrete
import CATEPTMain.Integration.DiscreteHarmonicSpineInstance
-- Bundled five-fold proven realizations of S_I via Matsubara/Luttinger-Ward
-- AND Tomita-Takesaki modular flow (Connes-Rovelli thermal-time hypothesis
-- imprint).  S_I is multiply realized at the carrier level; not contractual.
import CATEPTMain.Integration.SIRealizationsBundle
-- Capstone: single entropic-time parameter wiring QM + Thermodynamics + EM + GR.
import CATEPTMain.Integration.UnificationSpine
-- Previously-orphaned bridges now wired into root:

/-!
CATEPTMain root module for clean Lean 4.29 migration work.
-/

def integratedRepoCount : Nat := CATEPTMain.External.repos.length
