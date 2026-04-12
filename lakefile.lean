import Lake
open Lake DSL

package CATEPTMain where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

-- 4.29-compatible local dependencies (pinned by commit for reproducibility).
require «Physlib» from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/physlib" @ "9ca1ee1d0cac"

require «BochnerMinlos» from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/bochner" @ "1b56973aff9b"

require HilleYosida from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/hille-yosida" @ "7731442e5b01"

require cslib from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/cslib-inspect" @ "0d37cc7fcc98"

require pphi2 from git
  "file:///Users/macbookpro/lab/tau/tau-information-dynamics/pphi2" @ "1211294"

-- Keep mathlib last so its transitive versions win during resolution.
require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"

@[default_target]
lean_lib CATEPTMain where
  srcDir := "."
