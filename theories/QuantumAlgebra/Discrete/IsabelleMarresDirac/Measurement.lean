import QuantumAlgebra.Discrete.IsabelleMarresDirac.Definitions

/-!
# AFP Isabelle_Marries_Dirac → Lean4 Faithful Port — Subset 4
Theories: Measurement (continued), More_Tensor, No_Cloning, Quantum
Theorems: 30 (indices 91–120)
Port date: 2026-04-07
Status: scaffolding — theorems deferred (needs_human: tensor product, measurement, no-cloning)

All theorems in this subset depend on:
  - More_Tensor: Kronecker product properties (tensor assoc, commutativity with scalars)
  - No_Cloning: quantum no-cloning theorem (inner product / unitarity argument)
  - Quantum: core quantum circuit theorems (state/gate composition, adjoint)
  - Measurement: Born rule, partial trace

These require Lean4 infrastructure for:
  - Kronecker product for Matrix (Fin m × Fin n) ℂ
  - Adjoint / dagger in UnitaryGroup
  - Inner product space structure on column vectors
-/

open QuantumAlgebra.Discrete.IsabelleMarresDirac
open IMD

namespace QuantumAlgebra.Discrete.IsabelleMarresDirac.Measurement

-- Scaffolding: theorem stubs will be added as matrix infrastructure is developed.

end QuantumAlgebra.Discrete.IsabelleMarresDirac.Measurement
