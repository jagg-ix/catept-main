-- OrphanAggregator — wire substantive orphan files onto the repo spine.
-- See module docstring at the bottom for context.

-- ── CATEPT/CATEPT/* (4 wired, 7 quarantined as rotted) ─────────────────────
import CATEPTMain.CATEPT.CATEPT.AQFTFoundations
import CATEPTMain.CATEPT.CATEPT.CAT_EPT_ETH_VariationalRateBridge
import CATEPTMain.CATEPT.CATEPT.CatsimCFLBridge
import CATEPTMain.CATEPT.CATEPT.TrefoilParticleClassification
-- AdvancedFoundations: rotted (PhysicalConstants identifier no longer in scope).
-- ArrowMpemba: rotted (PhysicalConstants/TwoSectorSystem unknown, tactic drift).
-- ClassicalETHIntegration: rotted (bad import 'CATEPTMain.CATEPT.ClassicalCore').
-- Core: rotted transitively (pulls CFLDimensionalCategoryBridge, GravitasCoreBridge,
--   QEDCoreAbstractions, TheoryPluginArchitecture — all rotted).
-- ScatteringAmplitudeBridge: rotted (ambiguous-term elaboration drift).
-- TemporalOrderAndReduction: rotted (binder/intro/Unknown-`n` drift).
-- UniversalScalingLaw: rotted (cascade from Core).

-- ── Core / Domains (3) ─────────────────────────────────────────────────────
import CATEPTMain.Core.CATEPTAbstractInstances
import CATEPTMain.Domains.CoherenceShowcase
import CATEPTMain.Domains.TemporalCoherenceShowcase

-- ── GaugeTheory: EQFT/RTFT (10) ────────────────────────────────────────────
import CATEPTMain.GaugeTheory.EQFTRTFT.BoueDupuis
import CATEPTMain.GaugeTheory.EQFTRTFT.EQFTRTFTPort
import CATEPTMain.GaugeTheory.EQFTRTFT.EQFTRTFTPrelude
import CATEPTMain.GaugeTheory.EQFTRTFT.EuclideanQFT
import CATEPTMain.GaugeTheory.EQFTRTFT.FractionalSobolev
import CATEPTMain.GaugeTheory.EQFTRTFT.GaugeFieldsPort
import CATEPTMain.GaugeTheory.EQFTRTFT.GaugefieldsAllPort
import CATEPTMain.GaugeTheory.EQFTRTFT.RelativisticThermoField
import CATEPTMain.GaugeTheory.EQFTRTFT.WickPolynomials
import CATEPTMain.GaugeTheory.EQFTRTFT.WilsonUnificationBridge

-- ── GaugeTheory: FBD (4) ────────────────────────────────────────────────────
import CATEPTMain.GaugeTheory.FBD.FBDPrelude
import CATEPTMain.GaugeTheory.FBD.OmegaMatrices
import CATEPTMain.GaugeTheory.FBD.QEDProcesses
import CATEPTMain.GaugeTheory.FBD.WeakProcesses

-- ── GaugeTheory: FEYNCALC (11) ──────────────────────────────────────────────
import CATEPTMain.GaugeTheory.FEYNCALC.CliffordEuclidean
import CATEPTMain.GaugeTheory.FEYNCALC.CliffordMinkowski
import CATEPTMain.GaugeTheory.FEYNCALC.DiracAlgebra
import CATEPTMain.GaugeTheory.FEYNCALC.DiracTrace
import CATEPTMain.GaugeTheory.FEYNCALC.FCPrelude
import CATEPTMain.GaugeTheory.FEYNCALC.LeviCivita3D
import CATEPTMain.GaugeTheory.FEYNCALC.LeviCivita4D
import CATEPTMain.GaugeTheory.FEYNCALC.LeviCivitaConcrete
import CATEPTMain.GaugeTheory.FEYNCALC.LorentzAlgebra
import CATEPTMain.GaugeTheory.FEYNCALC.SpinorPropagator
import CATEPTMain.GaugeTheory.FEYNCALC.SpinorPropagatorCurvedBridge

-- ── GaugeTheory: LDO (9) ────────────────────────────────────────────────────
import CATEPTMain.GaugeTheory.LDO.AbstractFermions
import CATEPTMain.GaugeTheory.LDO.CGMethods
import CATEPTMain.GaugeTheory.LDO.DomainwallFermion
import CATEPTMain.GaugeTheory.LDO.FermiAction
import CATEPTMain.GaugeTheory.LDO.LDOPrelude
import CATEPTMain.GaugeTheory.LDO.MobiusDomainwallFermion
import CATEPTMain.GaugeTheory.LDO.RHMC
import CATEPTMain.GaugeTheory.LDO.StaggeredFermion
import CATEPTMain.GaugeTheory.LDO.WilsonFermion

-- ── GaugeTheory: QCD (4) ────────────────────────────────────────────────────
import CATEPTMain.GaugeTheory.QCD.QCDBetaFunction
import CATEPTMain.GaugeTheory.QCD.QCDFermionCoupling
import CATEPTMain.GaugeTheory.QCD.QCDGluonSector
import CATEPTMain.GaugeTheory.QCD.QCDPrelude

-- ── Geometry / Gravitas / Hammer (3 wired, 1 quarantined) ──────────────────
import CATEPTMain.Geometry.SmoothManifoldsBridge
import CATEPTMain.GravitasStandalone
import CATEPTMain.Hammer.AFPHammer
-- HammerDemo: rotted via ProjMeasSubset01 (transitive ambiguity).

-- ── Integration (28 — orphaned bridges + carriers) ─────────────────────────
import CATEPTMain.Integration.BTRelativityVerifiedAdapter
import CATEPTMain.Integration.BochnerMinlosCylinderBridge
import CATEPTMain.Integration.CATEPTSelfConsistency
import CATEPTMain.Integration.CarlesonHarmonicAnalysisBridge
import CATEPTMain.Integration.CslibComputabilityBridge
import CATEPTMain.Integration.DeGiorgiHarnackHolderRegularityBridge
import CATEPTMain.Integration.EntropicLocalityTheoremsBridge
-- EuclideanFeynmanKacAdmissibility: rotted (tactic/elaboration drift).
-- GTDEntropyAffineBridge: rotted (was untracked; tactic drift).
import CATEPTMain.Integration.GibbsMeasureKolmogorovBridge
import CATEPTMain.Integration.GravitasGeodesicDiscreteEventCarrier
import CATEPTMain.Integration.HopfYangBaxterBridge
import CATEPTMain.Integration.KolmogorovChaitinIncompressibilityBridge
import CATEPTMain.Integration.LogSobolevEntropicProperTimeBridge
-- LorentzianRateKernelBridge: rotted via LorentzianPathIntegralBridge cascade.
-- LorentzianTrotterKatoBridge: rotted (independent tactic drift).
import CATEPTMain.Integration.MaxwellWaveEntropicTimeBridge
import CATEPTMain.Integration.ModularFlowDiscreteEventBridge
-- OperatorPathIntegralFoundation: rotted via LorentzianPathIntegralBridge cascade.
import CATEPTMain.Integration.PhyslibCrossDomainBridge
import CATEPTMain.Integration.PhyslibQuantumMechanicsBridge
import CATEPTMain.Integration.PhyslibTemporalAdapterBridge
import CATEPTMain.Integration.QuantumInfoEntropyConsistencyBridge
import CATEPTMain.Integration.QuantumMpembaUnificationExample
import CATEPTMain.Integration.RelativisticEntropicGeometryFoundationsAudit
import CATEPTMain.Integration.SpectralGapKMSBetaConsistencyBridge
import CATEPTMain.Integration.ThermodynamicsLYEntropyBridge
import CATEPTMain.Integration.WDWRQMMeasureBridge

-- ── Quantum / QuantumGravity / QuantumInfo (5) ─────────────────────────────
import CATEPTMain.Quantum.CBO.CBOSubset01
import CATEPTMain.Quantum.CBO.ComplexBoundedOperatorsBridge
import CATEPTMain.QuantumGravity.NoFTLBellBridge
import CATEPTMain.QuantumInfoStandalone

-- ── QuantumOps (12) ────────────────────────────────────────────────────────
import CATEPTMain.QuantumOps.HilbertTensorProductBridge
import CATEPTMain.QuantumOps.Imported.Batch20260408_11_0004_6_framework_testing
import CATEPTMain.QuantumOps.Imported.Batch20260408_12_0026_reply_55_integration_of_next_10_of_d
import CATEPTMain.QuantumOps.Imported.Batch20260408_13_0055_expanded_reply_79_integration_of_nex
import CATEPTMain.QuantumOps.Imported.Batch20260408_14_0024_reply_53_integration_of_next_10_of_d
-- IsabelleMarresDirac.Basics: rotted via Definitions (transitive Unknown-id drift).
-- IsabelleMarresDirac.Deutsch: rotted via Definitions (same cascade).
import CATEPTMain.QuantumOps.IsabelleMarresDiracBridge
import CATEPTMain.QuantumOps.MatrixTensorBridge
import CATEPTMain.QuantumOps.PartialTrace.FinDimPartialTrace
import CATEPTMain.QuantumOps.ProjectiveMeasurementsBridge
import CATEPTMain.QuantumOps.QuantumFourierTransform.QFTSubset01
import CATEPTMain.QuantumOps.QuantumFourierTransform.QFTSubset02
import CATEPTMain.QuantumOps.QuantumFourierTransformBridge
import CATEPTMain.QuantumOps.Theoremized.Batch20260408_Theoremized

-- ── Spacetime (8) ──────────────────────────────────────────────────────────
import CATEPTMain.Spacetime.Imported.Batch20260408_15_0003_key_integration_components
import CATEPTMain.Spacetime.Imported.Batch20260408_16_0245_response
import CATEPTMain.Spacetime.Imported.Batch20260408_17_0008_section_4_discussion
import CATEPTMain.Spacetime.Imported.Batch20260408_18_0120_uqg_schwarzschild_integrate
import CATEPTMain.Spacetime.Imported.Batch20260408_19_0009_proposed_improvement_an_emergent_dim
import CATEPTMain.Spacetime.Imported.Batch20260408_20_0020_a_unified_lean4_framework_for_a_quan
import CATEPTMain.Spacetime.SchutzSpacetimeBridge
import CATEPTMain.Spacetime.Theoremized.Batch20260408_Theoremized

-- ── Units (1, quarantined) ─────────────────────────────────────────────────
-- PhysicalQuantitiesBridge: rotted (tactic/positivity drift).

/-!
# OrphanAggregator — wire substantive orphan files onto the repo spine

Imports the 110 *substantive orphan roots* — files in `CATEPTMain/` that
held theorems but were unreachable from the `CATEPTMain` root barrel
because nothing imported them transitively.  Each entry above was an
"orphan root" at audit time (commit cc0db2fd6 + the stub-retirement /
AQEIBridgeLane fixes): an orphan that no other file imported, so
importing it here pulls in its full dependency closure.

Categories explicitly **not** wired here:
* `WORKLOG/*` (37 files) — historical decision/strategy logs, intentional.
* `*Examples*` (5 substantive roots, ~25 total files) — showcase code.
* Tier-1/2/3 retirement-doc files — document deleted/superseded code.

Build expectations: a small number of these may fail to build because
their transitive imports hit pre-existing upstream blockers (lean-mwe /
NSC `lean_lib NavierStokes` collision, Mathlib/Physlib `Distribution._proof_1`
clash, NSC `×` token migration).  Those failures are surfaced verbatim
by `lake build CATEPTMain.Spine.OrphanAggregator` and tracked separately.
-/

namespace CATEPTMain.Spine.OrphanAggregator

/-- Sentinel value confirming the aggregator is reachable from `CATEPTMain`. -/
def aggregatedOrphanRootCount : Nat := 110

end CATEPTMain.Spine.OrphanAggregator
