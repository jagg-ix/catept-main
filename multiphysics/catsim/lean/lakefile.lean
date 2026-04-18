import Lake
open Lake DSL

/--
CatsimLean: optional Lean/PhysLean verification harness for catsim.

Design:
  - Keep this project isolated under ./lean so Python workflows remain unchanged.
  - Allow use of `sorry` so the file tree is buildable while we iteratively
    formalize results (the proof status is captured by Phase 6.22).

Notes:
  - Dependencies are declared but may require network access to fetch.
  - Phase 6.22 will SKIP gracefully when Lean tooling isn't installed.
-/

package CatsimLean where
  moreServerArgs := #["-K" , "1024"]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "master"

-- PhysLean is optional for humans; if you vend it as a submodule, you can
-- edit this require to a local path.
require PhysLean from git
  "https://github.com/HEPLean/PhysLean" @ "main"

lean_lib CatsimLean
