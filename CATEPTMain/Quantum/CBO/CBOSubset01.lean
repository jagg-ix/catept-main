import Mathlib.Analysis.InnerProductSpace.Adjoint
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.Matrix.ToLin

/-!
# AFP Complex_Bounded_Operators → Lean4 Faithful Port — Subset 01

Source: AFP Isabelle `Complex_Bounded_Operators`
Date: 2026-04-08

## AFP → Lean4 type map

| AFP type | Lean4 type |
|----------|-----------|
| `cblinfun A` | `A : E →L[ℂ] F` (ContinuousLinearMap) |
| `adj A` | `ContinuousLinearMap.adjoint A` |
| `cinner x y` | `@inner ℂ E _ x y` (inner product) |

## Coverage (closed_faithful):
  [01] `opNorm_adjoint` — norm(adj A) = norm(A)
  [02] `inner_clm_right` — inner x (adj A y) = inner (A x) y
  [03] `inner_clm_left` — inner (adj A y) x = inner y (A x)
  [04] `adj_adj` — adj (adj A) = A
  [05] `adj_comp` — adj (A comp B) = adj B comp adj A
  [06] `norm_inner_le` — norm(inner x y) <= norm x * norm y (Cauchy-Schwarz)
  [07] `inner_self_norm` — inner x x = norm(x)^2 (in the field)

## needs_human (structural):
  [08] `self_adjoint_iff` — adj A = A iff IsSelfAdjoint
  [09] `cblinfun_matrix_mul` — matrix of composition = product
  [10] `cblinfun_matrix_adjoint` — matrix of adj = conjTranspose
  [11] `complex_L2_parseval` — Parseval identity
  [12] `one_dim_iso` — 1-dim space isomorphic to field
-/

set_option autoImplicit false

open Matrix Module

namespace CATEPTMain.Quantum.CBO

-- Abbreviation for CLM adjoint to avoid notation issues
private noncomputable abbrev clm_adj {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [CompleteSpace F]
    (A : E →L[𝕜] F) : F →L[𝕜] E := ContinuousLinearMap.adjoint A

-- ── [01] AFP `opNorm_adjoint` ─────────────────────────────────────────────────

/-- AFP `opNorm_adjoint`: norm of adjoint = norm of operator.
    Mathlib: `ContinuousLinearMap.adjoint` is a `LinearIsometryEquiv`. -/
theorem afp_opNorm_adjoint {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [CompleteSpace F]
    (A : E →L[𝕜] F) :
    ‖ContinuousLinearMap.adjoint A‖ = ‖A‖ :=
  ContinuousLinearMap.adjoint.norm_map A

-- ── [02] AFP `inner_clm_right` ────────────────────────────────────────────────

/-- AFP `inner_clm_apply` (right): inner x (adj(A) y) = inner (A x) y.
    Mathlib: `ContinuousLinearMap.adjoint_inner_right`. -/
theorem afp_inner_clm_right {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [CompleteSpace F]
    (A : E →L[𝕜] F) (x : E) (y : F) :
    @inner 𝕜 E _ x (ContinuousLinearMap.adjoint A y) =
    @inner 𝕜 F _ (A x) y :=
  ContinuousLinearMap.adjoint_inner_right A x y

-- ── [03] AFP `inner_clm_left` ─────────────────────────────────────────────────

/-- AFP `inner_clm_apply` (left): inner (adj(A) y) x = inner y (A x).
    Mathlib: `ContinuousLinearMap.adjoint_inner_left`. -/
theorem afp_inner_clm_left {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [CompleteSpace F]
    (A : E →L[𝕜] F) (x : E) (y : F) :
    @inner 𝕜 E _ (ContinuousLinearMap.adjoint A y) x =
    @inner 𝕜 F _ y (A x) :=
  ContinuousLinearMap.adjoint_inner_left A x y

-- ── [04] AFP `adj_adj` ────────────────────────────────────────────────────────

/-- AFP `adj_adj`: adj(adj(A)) = A.
    Mathlib: `ContinuousLinearMap.adjoint_adjoint`. -/
theorem afp_adjoint_adjoint {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [CompleteSpace F]
    (A : E →L[𝕜] F) :
    ContinuousLinearMap.adjoint (ContinuousLinearMap.adjoint A) = A :=
  ContinuousLinearMap.adjoint_adjoint A

-- ── [05] AFP `adj_comp` ───────────────────────────────────────────────────────

/-- AFP `adj_comp`: adj(A ∘ B) = adj(B) ∘ adj(A).
    Mathlib: `ContinuousLinearMap.adjoint_comp`. -/
theorem afp_adjoint_comp {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [CompleteSpace F]
    {G : Type*} [NormedAddCommGroup G] [InnerProductSpace 𝕜 G] [CompleteSpace G]
    (A : F →L[𝕜] G) (B : E →L[𝕜] F) :
    ContinuousLinearMap.adjoint (A ∘L B) =
      ContinuousLinearMap.adjoint B ∘L ContinuousLinearMap.adjoint A :=
  ContinuousLinearMap.adjoint_comp A B

-- ── [06] AFP `norm_inner_le`: Cauchy-Schwarz ──────────────────────────────────

/-- AFP `cinner_Cauchy_Schwarz`: norm(inner x y) <= norm(x) * norm(y).
    Mathlib: `norm_inner_le_norm`. -/
theorem afp_norm_inner_le {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [SeminormedAddCommGroup E] [InnerProductSpace 𝕜 E]
    (x y : E) :
    ‖@inner 𝕜 E _ x y‖ ≤ ‖x‖ * ‖y‖ :=
  norm_inner_le_norm x y

-- ── [07] AFP `inner_self_norm`: inner x x = (norm x : field)^2 ────────────────

/-- AFP `cinner_norm_sq`: inner x x = (norm x cast to field)^2.
    Mathlib: `inner_self_eq_norm_sq_to_K`. -/
theorem afp_inner_self_norm_sq {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [SeminormedAddCommGroup E] [InnerProductSpace 𝕜 E]
    (x : E) :
    @inner 𝕜 E _ x x = (‖x‖ : 𝕜) ^ 2 :=
  inner_self_eq_norm_sq_to_K x

-- ── [08-12] needs_human stubs ─────────────────────────────────────────────────

/-- AFP `self_adjoint_iff`: IsSelfAdjoint A ↔ adj(A) = A.
    Mathlib: `ContinuousLinearMap.isSelfAdjoint_iff'` (Analysis.InnerProductSpace.Adjoint). -/
theorem afp_self_adjoint_iff {𝕜 : Type*} [RCLike 𝕜]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]
    (A : E →L[𝕜] E) :
    IsSelfAdjoint A ↔ ContinuousLinearMap.adjoint A = A :=
  ContinuousLinearMap.isSelfAdjoint_iff'

/-- AFP `cblinfun_matrix_mul`: mat(S∘T) = mat(S)·mat(T).
    Faithful port via `LinearMap.toMatrix_comp` (Mathlib).
    AFP `cblinfun` ≡ `E →ₗ[R] F`; composition is `LinearMap.comp`. -/
theorem afp_toMatrix_comp {R : Type*} [CommSemiring R]
    {ι₁ ι₂ ι₃ : Type*} [Fintype ι₁] [Finite ι₁] [DecidableEq ι₁] [Fintype ι₂] [DecidableEq ι₂] [Fintype ι₃]
    {E₁ E₂ E₃ : Type*}
    [AddCommMonoid E₁] [Module R E₁]
    [AddCommMonoid E₂] [Module R E₂]
    [AddCommMonoid E₃] [Module R E₃]
    (v₁ : Basis ι₁ R E₁) (v₂ : Basis ι₂ R E₂) (v₃ : Basis ι₃ R E₃)
    (S : E₂ →ₗ[R] E₃) (T : E₁ →ₗ[R] E₂) :
    LinearMap.toMatrix v₁ v₃ (S ∘ₗ T) =
      LinearMap.toMatrix v₂ v₃ S * LinearMap.toMatrix v₁ v₂ T :=
  LinearMap.toMatrix_comp v₁ v₂ v₃ S T

/-- AFP `cblinfun_matrix_adjoint`: mat(adj f) = conjTranspose(mat f) for orthonormal bases.
    Faithful port via `LinearMap.toMatrix_adjoint` (Mathlib.Analysis.InnerProductSpace.Adjoint).
    AFP `adj` ≡ `LinearMap.adjoint` on finite-dim InnerProductSpace. -/
theorem afp_toMatrix_adjoint {𝕜 : Type*} [RCLike 𝕜]
    {ι₁ ι₂ : Type*} [Fintype ι₁] [DecidableEq ι₁] [Fintype ι₂] [DecidableEq ι₂]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [FiniteDimensional 𝕜 E]
    {F : Type*} [NormedAddCommGroup F] [InnerProductSpace 𝕜 F] [FiniteDimensional 𝕜 F]
    (v₁ : OrthonormalBasis ι₁ 𝕜 E) (v₂ : OrthonormalBasis ι₂ 𝕜 F)
    (f : E →ₗ[𝕜] F) :
    LinearMap.toMatrix v₂.toBasis v₁.toBasis (LinearMap.adjoint f) =
      conjTranspose (LinearMap.toMatrix v₁.toBasis v₂.toBasis f) :=
  LinearMap.toMatrix_adjoint v₁ v₂ f

/-- AFP `complex_L2_parseval`: ‖x‖² = ∑ᵢ ‖⟪bᵢ, x⟫‖² for an orthonormal basis.
    Mathlib: `OrthonormalBasis.sum_sq_norm_inner_right`. -/
theorem afp_complex_L2_parseval {𝕜 : Type*} [RCLike 𝕜]
    {ι : Type*} [Fintype ι]
    {E : Type*} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [FiniteDimensional 𝕜 E]
    (b : OrthonormalBasis ι 𝕜 E) (x : E) :
    ∑ i, ‖@inner 𝕜 E _ (b i) x‖ ^ 2 = ‖x‖ ^ 2 :=
  b.sum_sq_norm_inner_right x

-- ── Helper: EuclideanSpace ℂ (Fin 1) ≃ₗᵢ[ℂ] ℂ ────────────────────────────────

/-- The evaluation isometry: EuclideanSpace ℂ (Fin 1) ≃ₗᵢ[ℂ] ℂ, sending v ↦ v 0. -/
private noncomputable def euclideanFinOneEquiv : EuclideanSpace ℂ (Fin 1) ≃ₗᵢ[ℂ] ℂ where
  toFun v := v 0
  invFun c := EuclideanSpace.single 0 c
  left_inv v := by
    ext i; fin_cases i
    simp [EuclideanSpace.single_apply]
  right_inv c := by simp [EuclideanSpace.single_apply]
  map_add' v w := by simp
  map_smul' c v := by simp
  norm_map' v := by
    -- goal reduces to ‖v.ofLp 0‖ = ‖v.ofLp 0‖ since Fin 1 has a unique element
    simp [EuclideanSpace.norm_eq, Fin.sum_univ_one]

/-- AFP `one_dim_iso`: a 1-dimensional complex Hilbert space is isometrically isomorphic to ℂ.
    Proof: `stdOrthonormalBasis` gives `E ≃ₗᵢ[ℂ] EuclideanSpace ℂ (Fin 1)`;
    `euclideanFinOneEquiv` gives `EuclideanSpace ℂ (Fin 1) ≃ₗᵢ[ℂ] ℂ`. -/
theorem afp_one_dim_iso {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℂ E]
    [FiniteDimensional ℂ E] (h : finrank ℂ E = 1) :
    Nonempty (E ≃ₗᵢ[ℂ] ℂ) := by
  let b : OrthonormalBasis (Fin 1) ℂ E :=
    (stdOrthonormalBasis ℂ E).reindex (finCongr h)
  exact ⟨b.repr.trans euclideanFinOneEquiv⟩

-- ── Summary ───────────────────────────────────────────────────────────────────

def cboSubset01Summary : String :=
  "CBOSubset01 (AFP Complex_Bounded_Operators, priority 5 + 2 bonus): " ++
  "All 12 needs_human items closed (0 sorry): " ++
  "opNorm_adjoint, inner_clm_right, inner_clm_left, adjoint_adjoint, adjoint_comp, " ++
  "norm_inner_le (CS), inner_self_norm_sq, toMatrix_comp, toMatrix_adjoint, Parseval, " ++
  "self_adjoint_iff, one_dim_iso (via euclideanFinOneEquiv ≃ₗᵢ)."

end CATEPTMain.Quantum.CBO
