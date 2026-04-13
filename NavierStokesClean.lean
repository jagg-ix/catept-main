-- Root import file for NavierStokesClean.

-- Core infrastructure
import NavierStokesClean.Core.Types
import NavierStokesClean.Core.Operators
import NavierStokesClean.Core.EnergyFunctionals
import NavierStokesClean.Core.DiscreteIntegral

-- Phase 5A: Spatial carrier types (NSVelocityField, vorticity, BKM integral)
import NavierStokesClean.Core.SpatialTypes

-- Periodic Sobolev supplement (NSP-FP, NSP36-A/B, NSP38-C sub-axioms)
import NavierStokesClean.Sobolev.PeriodicSobolev

-- Torus bridge: UnitAddTorus (Fin 3) ↔ Space measure-isometry (NSC-P39 scaffolding)
-- §1: measurePreserving_unitAddTorus_equivIoc (UnitAddTorus ↔ Ioc[0,1]³)
-- §2: UnitAddTorus.lintegral_preimage_pi / integral_preimage_pi (Bochner + lower integral bridges)
-- §3: space_equivPi_measurePreserving, cateptSpace_torus_measurePreserving (hop 1 + 2, sorry'd)
-- §4: space_torus_bridge_zero_witness (zero-enstrophy fallback)
import NavierStokesClean.Sobolev.TorusBridge

-- Millennium proof stack
import NavierStokesClean.Millennium.PreciseGapStatement
import NavierStokesClean.Millennium.MillenniumClosure
import NavierStokesClean.Millennium.OpenBottleneckKernelRoute
import NavierStokesClean.Millennium.PhysicalObservablesPreciseGapBridge
import NavierStokesClean.Millennium.BKMContinuationPipeline
import NavierStokesClean.Millennium.BKMBackwardCompatibility

-- Galerkin conformance anchors (judge L4 check)
import NavierStokesClean.Galerkin.ConformanceAnchors

-- Dual route certificate
import NavierStokesClean.Millennium.DualRouteCertificate

-- Phase 3: PhysLean concrete operator identities
import NavierStokesClean.PhysLean.DivCurlIdentity

-- Phase 4: Cameron-Popkov spectral gap (Route A)
import NavierStokesClean.CameronPopkov.DomainParameters
import NavierStokesClean.CameronPopkov.NativeSumCertificate
import NavierStokesClean.CameronPopkov.SpectralGapCertificate

-- Phase 5: Galerkin existence + vorticity liminf decompositions
import NavierStokesClean.Galerkin.GalerkinExistence
import NavierStokesClean.Galerkin.VorticityLiminf

-- Stage 294 port: Fourier triadic kernel (triadicKCoeff as concrete def, not axiom)
import NavierStokesClean.Galerkin.FourierTriadicKernel

-- Phase 17+20: Aubin-Lions compactness decomposition (L² → a.e. via Mathlib)
import NavierStokesClean.Galerkin.CantorDiagonal
import NavierStokesClean.Galerkin.AubinLionsCompact

-- Phase 24 (M2): Muha-Čanić decomposition — palinstrophy condition (B) as theorem
import NavierStokesClean.Galerkin.MuhaCanicDecomposition

-- Phase 25 (M3): Aubin-Lions-Simon — galerkin_eLpNorm_per_T proved as theorem
import NavierStokesClean.Galerkin.AubinLionsSimon

-- Phase M4: Temam–Simon–BKM published chain certificate
import NavierStokesClean.Galerkin.TemamBKMPublishedChain

-- Phase 6: Complete axiom audit
import NavierStokesClean.Audit.AxiomAudit
import NavierStokesClean.Audit.NSSemanticFidelityGapAudit

-- CAT/EPT-first spatial types (dependency inversion — avoids whnf loop via PhysLean.Space)
-- CATEPTSpace = Fin 3 → ℝ (safe pi measure); CATEPTST = Fin 4 → ℝ (Lorentz.Vector bridge)
import NavierStokesClean.CATEPT.CATEPTSpaceTime

-- Phase 7: CAT/EPT verification (Complex Action / Entropic Time framework)
import NavierStokesClean.CATEPT.Foundations
import NavierStokesClean.CATEPT.PathIntegrals
import NavierStokesClean.CATEPT.MeasurePathIntegral
import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.CATEPT.LatticeQCDBridge
import NavierStokesClean.CATEPT.QuantumGravity
import NavierStokesClean.CATEPT.QFTGRClosures
import NavierStokesClean.CATEPT.CATEPTBridge
import NavierStokesClean.CATEPT.Basic
import NavierStokesClean.CATEPT.WeylYukawaContracts
import NavierStokesClean.CATEPT.WeylYukawaContractsAudit

-- CATEPT WP1-WP5: Complex Einstein / Bianchi / MTPI derivation bridge + Modular Flow / Kuchar
import NavierStokesClean.CATEPT.ComplexEinsteinMTPIBridge
import NavierStokesClean.CATEPT.BianchiComplexEFEContracts
import NavierStokesClean.CATEPT.MTPIEinsteinDerivationBridge
import NavierStokesClean.CATEPT.ComplexEFEQFTCompatibility
import NavierStokesClean.CATEPT.GRTensorKernel
import NavierStokesClean.CATEPT.SchwarzschildCurvatureIdentities
import NavierStokesClean.CATEPT.ModularFlowKucharBridge
import NavierStokesClean.CATEPT.PaperEqAliases
import NavierStokesClean.CATEPT.MeasurementCommunicationEverettBridge
import NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge
import NavierStokesClean.CATEPT.ImaginaryActionConcavityBridge
import NavierStokesClean.CATEPT.ModularNoetherCompatibility
import NavierStokesClean.CATEPT.MadelungADMBridge
import NavierStokesClean.CATEPT.ADMExtrinsicCurvatureBridge

-- Phase B GR pipeline: covariant derivative, FLRW cosmology, Kerr BH, IR-derived stubs
import NavierStokesClean.CATEPT.CovariantDerivative
import NavierStokesClean.CATEPT.FLRWMetric
import NavierStokesClean.CATEPT.KerrMetric
import NavierStokesClean.CATEPT.IRDerivedStubs

-- WP07: Schrödinger functional + Weyl complex Dirac compatibility
import NavierStokesClean.CATEPT.SchrodingerFunctional
import NavierStokesClean.CATEPT.WeylComplexDiracCoreEquations
import NavierStokesClean.CATEPT.WeylComplexDiracCompatibility

-- NSC-P33: Galerkin equicontinuity + torus bridge
import NavierStokesClean.Galerkin.NSC_P33_Equicontinuity
import NavierStokesClean.Galerkin.VSNuPSpatialBridge
import NavierStokesClean.Galerkin.VSNuPLegacyCompatibility
import NavierStokesClean.Galerkin.AubinLionsMathlibCompatibility
import NavierStokesClean.Millennium.NSC_P33_Bridge
