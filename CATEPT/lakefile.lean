import Lake
open Lake DSL

package CATEPT where
  -- Lean 4 formal verification of CAT/EPT framework

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib CATEPT where
  -- Source files will be in CATEPT/
