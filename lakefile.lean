import Lake
open Lake DSL

package CATEPTMain where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

-- 4.29-compatible local dependencies (pinned by commit for reproducibility).
require «Physlib» from git
  "https://github.com/leanprover-community/physlib.git" @ "9ca1ee1d0cac43391399fcdc9e9fca8c94c17057"

require «BochnerMinlos» from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/bochner" @ "1b56973aff9b"

require HilleYosida from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/hille-yosida" @ "7731442e5b01"

require cslib from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/cslib-inspect" @ "0d37cc7fcc98"

require pphi2 from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/pphi2" @ "b0cbac4"

require MarkovSemigroups from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/markov-semigroups"

-- Override transitive GaussianField (from LGT/pphi2) with an editable local source.
-- This avoids patching `.lake/packages/GaussianField` directly.
require GaussianField from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/gaussian-field"

-- pphi2N: O(N) linear sigma model, large-N mass gap via Hubbard-Stratonovich.
-- Requires pphi2 (above) + MarkovSemigroups (transitive via pphi2).
require pphi2N from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/pphi2N"

-- LGT: 2D Yang-Mills mass gap via discrete differential geometry + Doeblin mixing.
-- Requires GaussianField + MarkovSemigroups (both transitive via pphi2/pphi2N).
-- GaugeFixing.lean has 2 localized sorries (Faddeev-Popov); bridge staged for Ph2.
require LGT from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/lgt"

require DimensionalAnalysis from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/LeanDimensionalAnalysis"

-- AQEI-Bridge: causal poset H₁ stability under AQEI stress-energy perturbations.
require aqeiBridge from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/aqei-bridge/lean"

-- lean-inf: Levi-Civita numbers, SafeFloat, Array utilities (updated to v4.29.0).
require «lean-inf» from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/lean-inf"

-- VML: Formal verification of the Vlasov-Maxwell-Landau steady-state theorem.
require aristotle from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/Formal-Verification-of-the-Vlasov-Maxwell-Landau-Steady-State-Theorem"

-- UnifiedTheory: Bell theorem, causal foundation, Einstein equation from causal set.
-- Zero sorry, zero axioms. Provides proved CHSH violation + classical bound.
require UnifiedTheory from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/unifiedtheory"

-- DeGiorgi: 0-sorry De Giorgi–Nash–Moser regularity theory.
-- Proves: GNS inequality, Poincaré, Sobolev-Poincaré, Caccioppoli, Harnack, Hölder, Lax-Milgram.
require «DeGiorgi» from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/DeGiorgi"

-- Spectral-Physics-Lean: spectral gap, Rayleigh quotient, heat semigroup, Bakry-Émery.
require spectralPhysics from
  "/Users/macbookpro/lab/tau/tau-information-dynamics/Spectral-Physics-Lean"

-- Keep mathlib last so its transitive versions win during resolution.
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"

@[default_target]
lean_lib CATEPTMain where
  srcDir := "."

lean_lib CATEPT where
  srcDir := "."

-- NavierStokes module hierarchy (NavierStokes/*.lean).
-- These are imported directly by BianchiKucharEPTBridge and ComplexFunctionalsBridge.
lean_lib NavierStokes where
  srcDir := "."

-- NavierStokesClean module hierarchy (NavierStokesClean/*.lean).
-- Imported by CATEPTSelfConsistency and related integration modules.
lean_lib NavierStokesClean where
  srcDir := "."
