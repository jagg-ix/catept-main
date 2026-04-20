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

require cslib from git
  "https://github.com/Timeroot/cslib.git" @ "0d37cc7fcc985cfc53b155e7eef2453f846c6da2"

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
  git "https://github.com/jagg-ix/lgt.git" @ "9879f2cc06b507a0ba1bef9efd11ab0591a0471f"

require DimensionalAnalysis from
  git "https://github.com/ATOMSLab/LeanDimensionalAnalysis.git" @ "de263eed945693058ef2b8a1fa56c2ec5642ea7a"

-- AQEI-Bridge: causal poset H₁ stability under AQEI stress-energy perturbations.
require aqeiBridge from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/aqei-bridge/lean"

-- lean-inf: Levi-Civita numbers, SafeFloat, Array utilities (updated to v4.29.0).
require «lean-inf» from git
  "https://github.com/jagg-ix/lean-inf.git" @ "2b1ce9a448fb9360c4b960809dec4ed42144da08"

-- VML: Formal verification of the Vlasov-Maxwell-Landau steady-state theorem.
require aristotle from git
  "https://github.com/jagg-ix/aristotle.git" @ "5150aee67b9ac385730b0404bd9fbd72289fb686"

-- UnifiedTheory: Bell theorem, causal foundation, Einstein equation from causal set.
-- Zero sorry, zero axioms. Provides proved CHSH violation + classical bound.
require UnifiedTheory from
  git "https://github.com/tomdif/unifiedtheory.git" @ "b73c5d2a22ca3c0c6fd5796f0b62de25e19c296d"

-- DeGiorgi: 0-sorry De Giorgi–Nash–Moser regularity theory.
-- Proves: GNS inequality, Poincaré, Sobolev-Poincaré, Caccioppoli, Harnack, Hölder, Lax-Milgram.
require «DeGiorgi» from
  git "https://github.com/scottnarmstrong/DeGiorgi.git" @ "4c1b3077d3782b24065184df4ba59501b2e56fc7"

-- Spectral-Physics-Lean: spectral gap, Rayleigh quotient, heat semigroup, Bakry-Émery.
require spectralPhysics from
  git "https://github.com/ember-research-lab/Spectral-Physics-Lean.git" @ "d41d27cd15f540d6dca442a67718200941bedf27"

-- Keep mathlib last so its transitive versions win during resolution.
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"

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

-- NavierStokes module hierarchy (NavierStokes/*.lean).
-- These are imported directly by BianchiKucharEPTBridge and ComplexFunctionalsBridge.
lean_lib NavierStokes where
  srcDir := "."

-- NavierStokesClean module hierarchy (NavierStokesClean/*.lean).
-- Imported by CATEPTSelfConsistency and related integration modules.
lean_lib NavierStokesClean where
  srcDir := "."
