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
require aristotle from git
  "https://github.com/jagg-ix/aristotle.git" @ "10dad7ae6f7f91c9a1198cadad262e353ec9f4dd"

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
