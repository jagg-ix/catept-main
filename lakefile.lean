import Lake
open Lake DSL

package NavierStokesClean where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]

-- PhysLean: HEP/physics formal library.
-- Using local clone pinned to v4.26.0 (matches our toolchain and LeanDojo).
require PhysLean from git
  "https://github.com/HEPLean/PhysLean.git" @ "v4.26.0"

-- LeanDojo Millennium Prize Problems (official judge target).
-- Provides MillenniumNavierStokes.NavierStokesMillenniumProblem.
require problems from git
  "https://github.com/lean-dojo/LeanMillenniumPrizeProblems.git" @ "540da94826f7"

@[default_target]
lean_lib NavierStokesClean where
  srcDir := "."
