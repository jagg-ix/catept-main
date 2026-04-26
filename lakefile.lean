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

-- catept-plugin-brownian-motion: extracted CATEPTMain.Integration.BrownianMotionBridge.
-- Second plugin under Target 4 sibling-split pattern (T4.5).
require «catept-plugin-brownian-motion» from git
  "https://github.com/jagg-ix/catept-plugin-brownian-motion.git" @ "318d4d750a09f5fde73c0c62cd790c57bb8e1bdf"

-- catept-plugin-dimensional-analysis: extracted CATEPTMain.Integration.LeanDimensionalAnalysisBridge.
-- Third plugin under Target 4 sibling-split pattern (Target 4 follow-up beyond the >=2 minimum).
require «catept-plugin-dimensional-analysis» from git
  "https://github.com/jagg-ix/catept-plugin-dimensional-analysis.git" @ "d89c87a3612d9c1fccf469b13ad3d12c29ac3f40"

-- catept-plugin-cslib: extracted CATEPTMain.Integration.CslibBridge.
-- Fourth plugin under Target 5 (scale-out wave).
require «catept-plugin-cslib» from git
  "https://github.com/jagg-ix/catept-plugin-cslib.git" @ "b71b95fc5859ef6277c994212979e009c79c1b76"

-- catept-plugin-quantum-info: extracted CATEPTMain.Integration.QuantumInfoBridge.
-- Fifth plugin under Target 5 (T5.3).
require «catept-plugin-quantum-info» from git
  "https://github.com/jagg-ix/catept-plugin-quantum-info.git" @ "ad9eada1f4449bdc7d5a25704a1c555b7bbc989f"

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

-- catept-plugin-maxwell-curvespace-pphi2: extracted CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge.
-- Ninth plugin (T5.8). Interface-level Maxwell-curved-space ↔ pphi2 OS-reconstruction contract.
-- Distinct from the parallel VML / Vlasov-Maxwell-Landau extraction (different physics, different upstream).
require «catept-plugin-maxwell-curvespace-pphi2» from git
  "https://github.com/jagg-ix/catept-plugin-maxwell-curvespace-pphi2.git" @ "be3d80bd7946461bb0a8c3e3f737b29bd2f69efa"

-- catept-plugin-vml-landau: extracted CATEPTMain.Integration.VMLLandauBridge.
-- Tenth plugin (T5 follow-on). Wraps Aristotle/Clawristotle's VML.CoulombConcreteTheorem42
-- (Vlasov-Maxwell-Landau steady-state rigidity on T^3) under namespace CATEPTPluginVMLLandau.
require «catept-plugin-vml-landau» from git
  "https://github.com/jagg-ix/catept-plugin-vml-landau.git" @ "7ef1b4b0d7c171aeee9f395b87a5ebb4a38add7d"

-- catept-plugin-bochner-minlos: extracted CATEPTMain.Integration.BochnerMinlosBridge.
-- Eleventh plugin (T5 follow-on). Wraps mrdouglasny/bochner (PD characteristic functions +
-- Bochner-theorem + Sazonov tightness + Schur product + abstract Minlos extension witness).
require «catept-plugin-bochner-minlos» from git
  "https://github.com/jagg-ix/catept-plugin-bochner-minlos.git" @ "dae9f683e724970f7d335cf4223b24bac8f4fa65"

-- catept-plugin-carleson: extracted CATEPTMain.Integration.CarlesonBridge.
-- Twelfth plugin (T5 follow-on). Abstract Carleson integration witness (a.e. Fourier convergence,
-- maximal-operator bound, Dirichlet kernel, Jackson, antichain) — upstream carleson @ v4.28.0
-- not yet pinned in catept-main; witness is toolchain-independent.
require «catept-plugin-carleson» from git
  "https://github.com/jagg-ix/catept-plugin-carleson.git" @ "684eeb46e364a0fca7709bb0c6c8ea6063538c57"

-- catept-plugin-gibbs-measure: extracted CATEPTMain.Integration.GibbsMeasureBridge.
-- 13th plugin (T5 follow-on). Abstract Gibbs-measure witness (Kolmogorov extension,
-- conditional expectations, Giry monad, Gibbs-DLR, existence). Upstream targets v4.22.0;
-- witness is toolchain-independent.
require «catept-plugin-gibbs-measure» from git
  "https://github.com/jagg-ix/catept-plugin-gibbs-measure.git" @ "6b0c701baddadfecf454b9319ab9071ecec0dd49"

-- catept-plugin-hopf-lean: extracted CATEPTMain.Integration.HopfLeanBridge.
-- 14th plugin (T5 follow-on). Abstract Hopf-algebra witness (coalgebra, bialgebra, Hopf,
-- Yang-Baxter, BMod-monoidal). Upstream targets v4.26.0; witness is toolchain-independent.
require «catept-plugin-hopf-lean» from git
  "https://github.com/jagg-ix/catept-plugin-hopf-lean.git" @ "6236741efbba64355b24ca699482c2acd3d67ac0"

-- catept-plugin-kolmogorov-complexity: extracted CATEPTMain.Integration.KolmogorovComplexityBridge.
-- 15th plugin (T5 follow-on). Abstract Kolmogorov-complexity witness (AIT invariance,
-- Chaitin Ω, incompressibility, Gödel-2 via K). Upstream targets v4.29.0-rc8.
require «catept-plugin-kolmogorov-complexity» from git
  "https://github.com/jagg-ix/catept-plugin-kolmogorov-complexity.git" @ "b29f32d938dd6db0287ec6c6298934ffeda423e9"

-- catept-plugin-thermodynamics-lean: extracted CATEPTMain.Integration.ThermodynamicsLeanBridge.
-- 16th plugin (T5 follow-on). Abstract Lieb-Yngvason thermodynamics witness (LY axioms,
-- entropy existence/uniqueness/continuity, Kelvin-Planck, entropy-increase). Upstream targets v4.24.0-rc1.
require «catept-plugin-thermodynamics-lean» from git
  "https://github.com/jagg-ix/catept-plugin-thermodynamics-lean.git" @ "9a97fce70dd7e179c3219103df1f4a4053668aac"

-- catept-plugin-bt-compat: extracted CATEPTMain.CATEPT.CATEPT.BridgeTheoryCompatibility.
-- 17th plugin (T60 step 1 — first extraction from the CAT/EPT *core* tree, not Integration/).
-- Auci EM↔Relativity bridge: 11 scalar BT-equation defs + 10 sanity/invariance theorems.
require «catept-plugin-bt-compat» from git
  "https://github.com/jagg-ix/catept-plugin-bt-compat.git" @ "02918aecb838a9993af0a43374afca60f3595750"

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

-- catept-domain-quantum: extracted CATEPTMain.Quantum.QUANTUM.* (10 files / 1931 LoC).
-- 19th sibling, T61 — first **domain bundle** extraction (distinct from
-- catept-plugin-* integration plugins and catept-core publication-bridge core).
-- Provides QuantumPrelude / QuantumGates / DensityMatrix / QFIScaffold /
-- JordanWigner / QFIToolbox / PhysicsHamiltonians / QFIMeasurements / QuantumPort
-- under namespace `CATEPTPluginDomainQuantum`. In-tree shims under
-- CATEPTMain/Quantum/QUANTUM/*.lean re-export every public symbol back into
-- `CATEPTMain.Quantum.QUANTUM.*` so existing consumers compile unchanged.
-- 2 pre-existing sorrys in QFIMeasurements (lines 161, 234) carry over verbatim.
require «catept-domain-quantum» from git
  "https://github.com/jagg-ix/catept-domain-quantum.git" @ "deebbbed5cee29259475477782e36805c094a4f4"

-- catept-domain-geometry: Class B domain umbrella for CATEPTMain.Geometry.*.
-- Sub-bundles live at CATEPTPluginDomainGeometry.<BUNDLE>.* — one subdirectory
-- per source bundle (QUAT shipped; MINK / OCT / SM / GYR / NoFTL planned).
-- Replaces the deprecated thin sibling jagg-ix/catept-domain-quat (consolidation
-- per docs/architecture/sibling-repo-inventory.md).
-- **Private** per maintainer policy 2026-04-25.
require «catept-domain-geometry» from git
  "https://github.com/jagg-ix/catept-domain-geometry.git" @ "a6480b0c16ad5bee059fe01b3a3b96deb591f09c"

-- catept-domain-core: Class B domain umbrella for CATEPTMain.Core.* (excluding
-- Framework, which is the standalone Class A plugin catept-plugin-afp-framework).
-- Sub-bundles live at CATEPTPluginDomainCore.<BUNDLE>.* (MTN shipped; PDC, PHQ planned).
-- Replaces the deprecated thin sibling jagg-ix/catept-domain-mtn.
-- **Private** per maintainer policy 2026-04-25.
require «catept-domain-core» from git
  "https://github.com/jagg-ix/catept-domain-core.git" @ "9fbba431cb49a6ee05d509538e6c8263047403ad"

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
-- Pinned at the v4.29.0 port branch (jagg-ix fork, feat/copilot-claude/aristotle-v429-port).
require aristotle from git
  "https://github.com/jagg-ix/aristotle.git" @ "08faff16c3b3ff476f59d82356c4aac0c0bdb01e"

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

-- Keep mathlib last so its transitive versions win during resolution.
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"
