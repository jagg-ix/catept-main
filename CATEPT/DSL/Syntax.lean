/-!
# NavierStokesClean.CATEPT.DSL.Syntax

Minimal typed syntax for DTL-oriented formalization.

Phase 1 scope: define command shapes and a normalized payload used by
small-step semantics.
-/

namespace NavierStokesClean.CATEPT.DSL

/-- Minimal command family for the first compiler-correctness phase. -/
inductive CommandType where
  | entropicEvolve
  | openFermionHamiltonian
  | quantumOpticsJLEntropicSolve
  | noop
  deriving DecidableEq, Repr

/-- Command payload distilled to entropic-clock relevant values. -/
structure Command where
  kind : CommandType
  deltaSIHint : Rat
  lambdaHint : Rat
  deriving DecidableEq, Repr

end NavierStokesClean.CATEPT.DSL
