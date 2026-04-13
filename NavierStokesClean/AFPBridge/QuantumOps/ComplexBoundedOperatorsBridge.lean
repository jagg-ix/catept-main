/-!
# AFP Complex_Bounded_Operators → Lean4 Bridge Anchor

Source: AFP Isabelle `Complex_Bounded_Operators`
Pipeline: extract→IR→CTIR→Lean stubs (2026-04-07)
Theorems: 982 total | 852 arithmetic_norm_num | 4 induction | 126 needs_human
Subsets: 33 (30 each)
Artifacts: verification_results/afp_isabelle/complex_bounded_operators/

Theories covered:
- `Complex_Vector_Spaces`, `Complex_Vector_Spaces0`: complex TVS, normed spaces
- `Complex_Inner_Product`, `Complex_Inner_Product0`: complex inner products, Cauchy-Schwarz
- `Complex_L2`: L² space over ℂ, orthonormal bases
- `Complex_Bounded_Linear_Function`, `Complex_Bounded_Linear_Function0`: CLMs over ℂ
- `Complex_Euclidean_Space0`: finite-dim complex Euclidean space
- `Cblinfun_Matrix`: matrix representation of CLMs
- `One_Dimensional_Spaces`: 1-dim complex Hilbert space
- `Extra_*`: operator norm extras, Jordan normal form, vector space supplements

Mathlib Lean4 mapping targets (direct hits):
- `ContinuousLinearMap` (ℂ →L[ℂ] ℂ), `ContinuousLinearMap.opNorm`
- `InnerProductSpace` over ℂ, `inner_comm`, `norm_inner_le_norm`
- `EuclideanSpace ℂ (Fin n)`, `OrthonormalBasis`
- `LinearMap.toMatrix`, `Matrix.toLinearMap`
- `IsSelfAdjoint`, `IsUnitary`, `star_mul_self`

Direct CATEPT relevance:
This AFP entry provides the rigorous complex CLM foundation that CATEPT path-integral
and QFT operator stacks build on. Especially: operator norm bounds, adjoint properties,
and CLM composition — already used in CurvedSpacetimeAFPLeanMWECompositionBridge.
-/

namespace NavierStokesClean.AFPBridge.QuantumOps.ComplexBoundedOperators

/-- Bridge status for AFP Complex_Bounded_Operators integration. -/
def complexBoundedOperatorsBridgeStatus : String :=
  "active: 982 theorems extracted; 33 subsets planned; CTIR+Lean stubs generated 2026-04-07"

/-- Highest-priority Mathlib mappings (needs_human class = 126 theorems). -/
def priorityMathlib : List String := [
  "opNorm_adjoint: ‖T†‖ = ‖T‖  →  ContinuousLinearMap.opNorm_adjoint",
  "inner_clm_apply: ⟨T x, y⟩ = ⟨x, T† y⟩  →  ContinuousLinearMap.adjoint_inner_right",
  "complex_l2_parseval: ‖f‖² = Σ |⟨f, eᵢ⟩|²  →  OrthonormalBasis.sum_inner_mul_inner",
  "cblinfun_matrix_mul: matrix of (S∘T) = mat(S)*mat(T)  →  LinearMap.toMatrix_comp",
  "one_dim_iso: dim=1 → CLM(ℂ,ℂ) ≅ ℂ  →  ContinuousLinearMap.linearIsometryEquiv",
]

end NavierStokesClean.AFPBridge.QuantumOps.ComplexBoundedOperators
