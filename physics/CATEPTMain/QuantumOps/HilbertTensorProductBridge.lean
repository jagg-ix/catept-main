/-!
# AFP Hilbert_Space_Tensor_Product → Lean4 Bridge Anchor

Source: AFP Isabelle `Hilbert_Space_Tensor_Product`
Pipeline: extract→IR→CTIR→Lean stubs (2026-04-07)
Theorems: 741 total | 599 arithmetic_norm_num | 9 induction | 133 needs_human
Subsets: 25 (30 each)
Artifacts: verification_results/afp_isabelle/hilbert_space_tensor_product/

Theories covered:
- `Hilbert_Space_Tensor_Product`: tensor product of Hilbert spaces, universal property
- `Compact_Operators`: compact CLMs, Fredholm theory
- `Positive_Operators`: PSD operators, square root, functional calculus
- `Spectral_Theorem`: spectral decomposition for normal operators
- `Trace_Class`: trace-class operators, Schatten norms ‖·‖₁
- `Partial_Trace`: partial trace, density matrix reduction
- `Von_Neumann_Algebras`: W*-algebras, commutants, double commutant theorem
- `Strong_Operator_Topology`: SOT convergence, bounded nets
- `Weak_Operator_Topology`, `Weak_Star_Topology`: WOT, σ-weak topology
- `HS2Ell2`: Hilbert-Schmidt ↔ ℓ² isomorphism
- `Eigenvalues`: eigenvalue/eigenvector theory, spectral radius
- `Misc_Tensor_Product*`: auxiliary tensor product lemmas

Mathlib Lean4 mapping targets:
- `TensorProduct` (algebraic), `HilbertTensorProduct` (completed)
- `ContinuousLinearMap.IsCompact`, `IsSelfAdjoint.hasEigenvalue`
- `ContinuousLinearMap.trace`, Schatten p-norms
- `VonNeumannAlgebra`, `IsStar`, double commutant
- Direct CATEPT path-integral relevance: density matrix, partial trace,
  trace-class operators for quantum information bridges.
-/

namespace CATEPTMain.QuantumOps.HilbertTensorProduct

/-- Bridge status for AFP Hilbert_Space_Tensor_Product integration. -/
def hilbertTensorProductBridgeStatus : String :=
  "active: 741 theorems extracted; 25 subsets planned; CTIR+Lean stubs generated 2026-04-07"

/-- Priority theory ordering for subset execution. -/
def subsetPriority : List String := [
  "Phase 1 (subsets 1-5): core tensor product + Hilbert completion",
  "Phase 2 (subsets 6-10): compact operators + positive operators",
  "Phase 3 (subsets 11-15): spectral theorem + trace class",
  "Phase 4 (subsets 16-20): partial trace + Von Neumann algebras",
  "Phase 5 (subsets 21-25): SOT/WOT/weak-star topologies + HS2Ell2",
]

end CATEPTMain.QuantumOps.HilbertTensorProduct
