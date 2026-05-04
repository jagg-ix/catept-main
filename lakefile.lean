import Lake
open Lake DSL

package CATEPTMain where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

-- 4.29-compatible dependencies pinned by commit for reproducibility.
require «Physlib» from git
  "https://github.com/leanprover-community/physlib.git" @ "9ca1ee1d0cac43391399fcdc9e9fca8c94c17057"

require «BochnerMinlos» from git
  "https://github.com/mrdouglasny/bochner.git" @ "1b56973aff9b4e6ba761a6bd8af678e38bfd8d10"

require HilleYosida from git
  "https://github.com/mrdouglasny/hille-yosida.git" @ "7731442e5b0144dcede6aaf33f535b7a4bf95ef6"

-- catept-plugin-hille-yosida: extracted CATEPTMain.Integration.HilleYosidaBridge.
-- Sibling repo following Target 4 sibling-split pattern (target-4-plan.md).
require «catept-plugin-hille-yosida» from git
  "https://github.com/jagg-ix/catept-plugin-hille-yosida.git" @ "a25792615fe64d7a551dc32a940d60c219fa3d06"


-- catept-plugin-dimensional-analysis: extracted CATEPTMain.Integration.LeanDimensionalAnalysisBridge.
-- Third plugin under Target 4 sibling-split pattern (Target 4 follow-up beyond the >=2 minimum).
require «catept-plugin-dimensional-analysis» from git
  "https://github.com/jagg-ix/catept-plugin-dimensional-analysis.git" @ "d89c87a3612d9c1fccf469b13ad3d12c29ac3f40"

-- catept-plugin-cslib: extracted CATEPTMain.Integration.CslibBridge.
-- Fourth plugin under Target 5 (scale-out wave).
require «catept-plugin-cslib» from git
  "https://github.com/jagg-ix/catept-plugin-cslib.git" @ "bc5ae8bb3d83bd45ebb3151a153ac8cc035c491a"


-- catept-plugin-gaussian-field-lsi: extracted CATEPTMain.Integration.GaussianFieldLogSobolevBridge.
-- Sixth plugin under Target 5 (T5.4). Wraps GaussianField's Gross LSI + spectral-gap machinery.
require «catept-plugin-gaussian-field-lsi» from git
  "https://github.com/jagg-ix/catept-plugin-gaussian-field-lsi.git" @ "3783875a6d58d59fdc93a9c10988c4fefe5cb6c5"

-- catept-plugin-spectral-physics: extracted CATEPTMain.Integration.SpectralPhysicsBridge.
-- Seventh plugin under Target 5 (T5.5). Wraps Spectral-Physics-Lean's gap/Rayleigh/heat/Bakry-Émery results.
require «catept-plugin-spectral-physics» from git
  "https://github.com/jagg-ix/catept-plugin-spectral-physics.git" @ "95b216bf92f2e8306abc14ec733f70da50411004"

-- catept-plugin-degiorgi: extracted CATEPTMain.Integration.DeGiorgiBridge.
-- Eighth plugin (T5.6) — hits Target 5's >=8 sibling milestone.
-- Wraps the DeGiorgi package's GNS / Poincaré / Sobolev-Poincaré / Harnack / Hölder-Moser / Lax-Milgram results.
require «catept-plugin-degiorgi» from git
  "https://github.com/jagg-ix/catept-plugin-degiorgi.git" @ "5b06dc824b0dfb6c12cba57c1a364d142c678c93"


-- catept-plugin-vml-landau: extracted CATEPTMain.Integration.VMLLandauBridge.
-- Tenth plugin (T5 follow-on). Wraps Aristotle/Clawristotle's VML.CoulombConcreteTheorem42
-- (Vlasov-Maxwell-Landau steady-state rigidity on T^3) under namespace CATEPTPluginVMLLandau.
require «catept-plugin-vml-landau» from git
  "https://github.com/jagg-ix/catept-plugin-vml-landau.git" @ "7ef1b4b0d7c171aeee9f395b87a5ebb4a38add7d"

-- catept-plugin-bochner-minlos: extracted CATEPTMain.Integration.BochnerMinlosBridge.
-- Eleventh plugin (T5 follow-on). Wraps mrdouglasny/bochner (PD characteristic functions +
-- Bochner-theorem + Sazonov tightness + Schur product + abstract Minlos extension witness).
require «catept-plugin-bochner-minlos» from git
  "https://github.com/jagg-ix/catept-plugin-bochner-minlos.git" @ "6efe4238c8a9da26f1064e9bc430404c7d03ea0a"







-- catept-plugin-afp-framework: extracted CATEPTMain.Core.Framework.AFPBridgeFramework.
-- 18th plugin (T61 step 0 — prerequisite for the catept-domain-quantum bundle).
-- Generic AFP carriers (AFPObj/AFPSet/AFPMat/AFPVec) + ~25 axioms for matrix/vector ops
-- + 15 TacticStubs scoped macros. Imported by 30+ Prelude files across CATEPTMain/
-- (Quantum/QUANTUM, GaugeTheory/{LDO,QCD,FEYNCALC,EQFTRTFT}, Geometry/{MINK,SM,GYR,OCT,QUAT},
-- Analysis/{MODE,LAPL,CPM,ODE,FOU,LSI}, Core/{MTN,PHQ,PDC}, CATEPT/{QFT,EPT,CATEPT}, …).
-- Sibling module path: `CATEPTPluginAFPFramework.IntegrationBridge` (avoids the
-- Lake lib-name collision with catept-main's local `lean_lib CATEPTMain`).
-- Phase-1 abstract scaffold; phase-2 swap to concrete Mathlib types is per-Prelude.
require «catept-plugin-afp-framework» from git
  "https://github.com/jagg-ix/catept-plugin-afp-framework.git" @ "27c58a8337eca6cf2ec684602c0cd6cc37d2dc52"

-- catept-domain-quantum: Class B domain umbrella for CATEPTMain.Quantum.*.
-- ALL six Quantum/* sub-bundles consolidated as of v0.4.0:
--   QUANTUM (10 files / 1931 LoC), SCHTZ (2 / 385), IMD (15 / 2510),
--   PM (5 / 753), CBO (22 / 2053), HSTP (17 / 1428).
-- Total 71 files / 9,060 LoC under one private umbrella repo.
-- 2 pre-existing sorrys in QUANTUM/QFIMeasurements carry over verbatim.
-- **Private** per maintainer policy 2026-04-25.
require «catept-domain-quantum» from git
  "https://github.com/jagg-ix/catept-domain-quantum.git" @ "497848e180aadbce4ab2f89309d64eab6fbfaaf0"

-- catept-domain-geometry: Class B domain umbrella for CATEPTMain.Geometry.*.
-- Sub-bundles live at CATEPTPluginDomainGeometry.<BUNDLE>.* — one subdirectory
-- per source bundle. ALL Geometry/* sub-bundles consolidated as of v0.6.0:
-- QUAT (v0.1.0), MINK (v0.2.0), OCT (v0.3.0), GYR (v0.4.0), SM (v0.5.0),
-- NoFTL (v0.6.0). Replaces the deprecated thin sibling jagg-ix/catept-domain-quat.
-- **Private** per maintainer policy 2026-04-25.
require «catept-domain-geometry» from git
  "https://github.com/jagg-ix/catept-domain-geometry.git" @ "d1a588a9976cb2c82266bca0f4064479fcf60c7c"

-- catept-domain-core: Class B domain umbrella for CATEPTMain.Core.* (excluding
-- Framework, which is the standalone Class A plugin catept-plugin-afp-framework).
-- ALL three Core/* sub-bundles consolidated as of v0.2.0:
--   MTN (5 files / 383 LoC), PDC (2 files / 358 LoC), PHQ (2 files / 421 LoC).
-- Total 9 source files / 1,162 LoC.
-- Replaces the deprecated thin sibling jagg-ix/catept-domain-mtn.
-- **Private** per maintainer policy 2026-04-25.
require «catept-domain-core» from git
  "https://github.com/jagg-ix/catept-domain-core.git" @ "2a551615db755816b2e467f7de09d8bb36da2e05"

-- catept-domain-gauge: GaugeTheory umbrella sibling.
-- T63a (Electromagnetic-first): ELECTROWEAK + FEYNCALC core support modules.
require «catept-domain-gauge» from git
  "https://github.com/jagg-ix/catept-domain-gauge.git" @ "93ee396aa8505bf336093f41e599f07de395c14d"

-- catept-domain-analysis: Class B Analysis umbrella sibling — last of 5/5.
-- Sub-bundles at CATEPTPluginDomainAnalysis.<BUNDLE>.* (CPM, FOU, LAPL, LSI,
-- MODE, ODE). Two ODE files (AFPODEBridge, MatricesForODEsBridge) stay
-- in-tree as cross-NavierStokesClean bridge glue. **Private** per
-- maintainer policy 2026-04-25.
require «catept-domain-analysis» from git
  "https://github.com/jagg-ix/catept-domain-analysis.git" @ "14dedcdeae7b2a16789f983df2f136c72ecbbf5c"

-- catept-gravitas-port: Class C standalone physics-port sibling.
-- Lean 4 port of the Wolfram Mathematica Gravitas symbolic-GR package.
-- 25 files / 4032 LoC under bare namespaces (ADMDecomposition, EinsteinTensor,
-- RicciTensor, …). In-tree shims under CATEPTMain/Gravitas/*.lean re-export
-- via `import CATEPTGravitasPort.X` (no `export` clause needed — bare
-- namespaces propagate transparently). **Private** per maintainer policy.
require «catept-gravitas-port» from git
  "https://github.com/jagg-ix/catept-gravitas-port.git" @ "cb0e7dbd3e99f67f1ce73d7406661f97ea39cb66"

-- catept-core: namespace-preserving home for the CAT/EPT publication-bridge core.
-- T60 step 2 — extracts CATEPTMain.Core.Assumptions and
-- CATEPTMain.CATEPT.CATEPT.{Foundations, PathIntegrals, MeasurePathIntegral}
-- into a sibling repo. Lean *namespaces* inside those files are preserved
-- verbatim (`CATEPTMain.*`), so the 36 internal importers see no change to any
-- in-namespace symbol. The four in-tree files at CATEPTMain/{Core,CATEPT/CATEPT}/
-- are reduced to one-line re-export shims that `import CATEPTMainExtracted.<...>`.
-- Module paths in the dep are `CATEPTMainExtracted.*` to avoid the Lake lib-name
-- collision with catept-main's local `lean_lib CATEPTMain`.
-- Cascade-unblocks 4 of 6 remaining CATEPTPort sub-modules (Wave-2 leverage).
require «catept-core» from git
  "https://github.com/jagg-ix/catept-core.git" @ "e3cd2440d0cba2cd2939520993a3ebd507eb6530"

-- jagg-ix/lean-mwe: namespace-preserving home for MaxwellWave and
-- PlasmaEquations (originally vendored as top-level `MaxwellWave/` and
-- `PlasmaEquations/` subtrees in commit 884c11c62, now externalised).
-- Routed through the maintainer's fork because catept-main needs the
-- toolchain-bump commits (Lean v4.26 -> v4.28 -> v4.29) that upstream
-- a-bekheet/lean-mwe hasn't picked up.  All proofs verified to close
-- under Lean v4.29.0 + mathlib v4.29.0 at the pinned SHA below.
-- Repinning discipline mirrors catept-core: pin to a permanent commit
-- reachable from `main`, never to a PR-branch tip.
require «MaxwellWave» from git
  "https://github.com/jagg-ix/lean-mwe.git" @ "095175e42ba56563092aff973f5554bfdc4a065c"

-- catept-plugin-architecture: namespace-preserving home for the CAT/EPT
-- Integration-layer plugin-slot abstractions (T60 step 2). Extracts
-- CATEPTMain.Integration.TheoryPluginArchitecture (370 lines, 10 in-tree
-- consumer bridges including TheoryPluginAdapter, QuantumCATEPTBridge,
-- VMLCATEPTBridge, ElectroweakCATEPTBridge, ComplexEinsteinPathIntegralBridge,
-- TheoryPluginPhyslibConstructBridge, TheoryPluginClassicalETHBridge,
-- TheoryPluginDimSlot, plus ActionIntegrationBridge / Domains/SuperiorMethod /
-- UnifiedConstraintsCoupling). Lean *namespace* `CATEPTMain.Integration` is
-- preserved verbatim inside the dep; module path is
-- `CATEPTPluginArchitecture.Integration.TheoryPluginArchitecture` to avoid
-- the Lake lib-name collision with catept-main's local `lean_lib CATEPTMain`.
-- The in-tree CATEPTMain/Integration/TheoryPluginArchitecture.lean becomes
-- a one-line re-export shim. Cascade-unblocks the heavy CATEPTPort barrel
-- decoupling work (T60 follow-on) by removing the central plugin-slot
-- coupling point.
require «catept-plugin-architecture» from git
  "https://github.com/jagg-ix/catept-plugin-architecture.git" @ "09b06d768e09d8172ebd8480f05cc39ed325b789"

require cslib from git
  "https://github.com/Timeroot/cslib.git" @ "0d37cc7fcc985cfc53b155e7eef2453f846c6da2"

-- QuantumAlgebra: absorbed into catept-main (2026-04-22). Original lived at ../QuantumAlgebra.
-- See lean_lib QuantumAlgebra below.

require pphi2 from git
  "https://github.com/jagg-ix/pphi2.git" @ "b0cbac4703cfa6c6bb859a10687915472ad88fca"

require GaussianField from git
  "https://github.com/jagg-ix/gaussian-field.git" @ "cacaa98743ee90a7dc9010d62eca488a8561953e"

-- pphi2N: O(N) linear sigma model, large-N mass gap via Hubbard-Stratonovich.
require pphi2N from git
  "https://github.com/jagg-ix/pphi2N.git" @ "985e636af7dc4c9b7d0f66249adfc8e7b8ef19f4"

-- LGT: 2D Yang-Mills mass gap via discrete differential geometry + Doeblin mixing.
-- Requires GaussianField + MarkovSemigroups transitively via pphi2/pphi2N.
-- GaugeFixing.lean has 2 localized sorries (Faddeev-Popov); bridge staged for Ph2.
require LGT from
  git "https://github.com/jagg-ix/lgt.git" @ "f09c3991044ae1f2a750a3b2de9e8e36931f03cb"

require DimensionalAnalysis from
  git "https://github.com/jagg-ix/LeanDimensionalAnalysis.git" @ "7cc72525a27032de4b2302db1bfa6dc29c68c088"

-- AQEI-Bridge: causal poset H₁ stability under AQEI stress-energy perturbations.
require aqeiBridge from git
  "https://github.com/jagg-ix/aqei-bridge-lean.git" @ "e3d9c719a05913596616c20371509cae724d402c"

-- lean-inf: Levi-Civita numbers, SafeFloat, Array utilities (updated to v4.29.0).
require «lean-inf» from git
  "https://github.com/jagg-ix/lean-inf.git" @ "2b1ce9a448fb9360c4b960809dec4ed42144da08"

-- VML: Formal verification of the Vlasov-Maxwell-Landau steady-state theorem.
-- Pinned at jagg-ix/aristotle main HEAD (post-v4.29.0 port + Maxwell molecules
-- theorem additions). Bumped from 08faff16 -> 5150aee6 on 2026-04-26.
require aristotle from git
  "https://github.com/jagg-ix/aristotle.git" @ "5150aee67b9ac385730b0404bd9fbd72289fb686"

-- UnifiedTheory: Bell theorem, causal foundation, Einstein equation from causal set.
-- Zero sorry, zero axioms. Provides proved CHSH violation + classical bound.
require UnifiedTheory from
  git "https://github.com/jagg-ix/unifiedtheory.git" @ "b1d0836adabed08d4c1a4f00a3ea73598892d150"

-- DeGiorgi: 0-sorry De Giorgi–Nash–Moser regularity theory.
-- Proves: GNS inequality, Poincaré, Sobolev-Poincaré, Caccioppoli, Harnack, Hölder, Lax-Milgram.
require «DeGiorgi» from
  git "https://github.com/jagg-ix/DeGiorgi.git" @ "da79aa390d608de383ce7bd087cfd004c0335576"

-- Spectral-Physics-Lean: spectral gap, Rayleigh quotient, heat semigroup, Bakry-Émery.
require spectralPhysics from
  git "https://github.com/jagg-ix/Spectral-Physics-Lean.git" @ "c6ad16c3873d6e6dc2e415d4da2fd727eea35990"

-- OSreconstruction: Osterwalder-Schrader reconstruction, Wightman, SCV, ComplexLieGroups,
-- von Neumann algebras. Provides the Euclidean-to-Lorentzian bridge used by the CATEPT
-- QFT-GR infrastructure. Pinned on v4.29.0 stable.
require OSreconstruction from
  git "https://github.com/xiyin137/OSreconstruction.git" @ "6d9a639a7e5aa0266c5b47fe072cb4aaec0141a2"


@[default_target]
lean_lib CATEPTMain where
  srcDir := "."

lean_lib CATEPT where
  srcDir := "."

lean_lib QuantumInfo where
  srcDir := "."

lean_lib ClassicalInfo where
  srcDir := "."

lean_lib StatMech where
  srcDir := "."

lean_lib NavierStokes where
  srcDir := "."

lean_lib NavierStokesClean where
  srcDir := "."

lean_lib QuantumAlgebra where
  srcDir := "."

-- External String / PDE / Stochastic-PDE sibling repositories.
-- Converted from relative-path requires to git pins on 2026-04-24 so
-- catept-main builds reproducibly on CI runners (where the parent
-- directory containing the local clones doesn't exist). All siblings
-- live under jagg-ix/<repo> and were synced with their remotes at the
-- time of conversion. See worklog catept_main_ci_lakefile_relative_paths_20260424.
require StochasticPDE from git
  "https://github.com/jagg-ix/StochasticPDE.git" @ "48b3d433ccf93e84a823300f2ab0b113d444db87"
require StochasticPDEItoCalculus from git
  "https://github.com/jagg-ix/stochasticpde-itocalculus.git" @ "0b92a0f630db14e32967b2fc248c4199c051d28e"
require StochasticPDENonstandard from git
  "https://github.com/jagg-ix/stochasticpde-nonstandard.git" @ "c6988de1eb641cd006f12a6c8738bb84813e3a28"
require StringAlgebra from git
  "https://github.com/jagg-ix/StringAlgebra.git" @ "62bde1a2dee32d0be1e70a8473c05f0e8ea3f5e6"
require StringAlgebraLinfinity from git
  "https://github.com/jagg-ix/StringAlgebra-Linfinity.git" @ "1d6c4ce79c2150d13b548d3e7bf65918fb648f59"
require StringAlgebraMTC from git
  "https://github.com/jagg-ix/StringAlgebra-MTC.git" @ "a31d31c77aab9d6ff85b0d0bc098cce8bfdd4075"
require StringAlgebraMZV from git
  "https://github.com/jagg-ix/StringAlgebra-MZV.git" @ "d30a2fc0d9b64e57b76091f888c0190e59d21b29"
require StringAlgebraVOA from git
  "https://github.com/jagg-ix/StringAlgebra-VOA.git" @ "09c87f4ca6687902df13da099dc17c7d9f3d152c"
require StringGeometry from git
  "https://github.com/jagg-ix/StringGeometry.git" @ "a79430d0174a892b6e351db2f870edd3f75b0968"
require SGRiemannSurfaces from git
  "https://github.com/jagg-ix/stringgeometry-riemann-surfaces.git" @ "37ee82f9fd0584a7d84162472ca8ce0814bd937f"
require SGSuperRiemannSurfaces from git
  "https://github.com/jagg-ix/stringgeometry-super-riemann-surfaces.git" @ "617976775a894ff0c8638194f7891f561c269442"
require SGSupermanifolds from git
  "https://github.com/jagg-ix/stringgeometry-supermanifolds.git" @ "1559c4f7bda935a85341ee6eb8ea90e4ff539a6b"

-- Logos_Library — provides the operator-algebraic Tomita-Takesaki carrier
-- (`LogosLibrary.QuantumMechanics.ModularTheory.TomitaTakesaki`) consumed by
-- `CATEPTMain.Integration.TomitaTakesakiPhase3Bridge`. Pinned at the v4.29.0
-- bump (jagg-ix/Logos_Library, branch bump-to-lean-v4.29.0).
require «logos_library» from git
  "https://github.com/jagg-ix/Logos_Library.git" @ "852151dfe6fe5907cf3bcf1291176061b4e205a1"

-- Keep mathlib last so its transitive versions win during resolution.
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"
