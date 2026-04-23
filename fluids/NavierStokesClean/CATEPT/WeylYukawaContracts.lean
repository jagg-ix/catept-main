/-
# Weyl/Yukawa Contracts (Compile-Safe Bridge)

This module ports reusable ideas from the seven extracted Lean artifacts into
compile-safe CAT/EPT contracts and definitions.

Design goals:
- Keep reusable algebraic/data definitions executable.
- Encode unresolved physics steps as explicit contracts/axioms.
- Reuse CAT/EPT foundations (`ComplexAction`) via a clean adapter.
-/

import Mathlib.Data.Complex.Basic
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Matrix.Diagonal
import Mathlib.LinearAlgebra.Matrix.ConjTranspose
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Matrix.Spectrum
import Mathlib.Analysis.Matrix.PosDef
import NavierStokesClean.CATEPT.Foundations

noncomputable section

open Complex Matrix Real
open scoped InnerProductSpace

namespace NavierStokesClean.CATEPT
namespace WeylYukawa

/-! ## 1) Shared Complex-Action Carrier (from 0241/0243/0244, aligned to CATEPT) -/

/-- Scalar view of complex action used in the extracted Weyl/Yukawa snippets. -/
structure ScalarComplexAction where
  E : ℝ
  SI : ℝ

/-- Phase-to-imaginary-action map used in extracted modules. -/
def SI_from_phase (δ : ℝ) : ℝ := Real.log (1 + δ ^ 2)

theorem SI_from_phase_nonneg (δ : ℝ) : 0 ≤ SI_from_phase δ := by
  unfold SI_from_phase
  have h : (1 : ℝ) ≤ 1 + δ ^ 2 := by nlinarith [sq_nonneg δ]
  exact Real.log_nonneg h

/-- Adapter into CAT/EPT foundational `ComplexAction`. -/
def toFoundationsComplexAction (S : ScalarComplexAction) (hSI : 0 ≤ S.SI) :
    NavierStokesClean.CATEPT.ComplexAction Unit where
  S_R := fun _ => S.E
  S_I := fun _ => S.SI
  S_I_nonneg := by
    intro _
    exact hSI

/-! ## 2) Weyl / Chiral Contracts (from 0064/0065/0072) -/

structure TrefoilStructure where
  toLeptonMass : ℝ
  wavefunction : ℂ := 0

structure TrefoilTag where
  crossings : Nat := 3
  writhe : Int := 3
  chirality : Bool := true

structure ChiralCurrent where
  divergence : ℝ

structure KLDecomposition where
  energy : ℝ
  information : ℝ

structure WeylOperatorContext where
  weylOperator : TrefoilStructure → ℂ
  momentumOperator : TrefoilStructure → ℂ

/-- Compile-safe version of `weyl_equation_trefoil` intent from 0064. -/
def weyl_equation_trefoil (op : WeylOperatorContext) (ψ : TrefoilStructure) : Prop :=
  op.weylOperator ψ * op.momentumOperator ψ * ψ.wavefunction = 0

structure WeylContractContext where
  freeAction : TrefoilStructure → ScalarComplexAction
  interactingAction : TrefoilStructure → ScalarComplexAction → ScalarComplexAction
  klDivergence : ScalarComplexAction → ScalarComplexAction → KLDecomposition
  weylLagrangianDensity : TrefoilStructure → ScalarComplexAction → ℝ
  chiralConservationMeasure : TrefoilStructure → ScalarComplexAction → ℝ
  chiralCurrent : TrefoilStructure → ScalarComplexAction → ChiralCurrent
  chiralConservationMeasure_pos : ∀ ψ A, 0 < chiralConservationMeasure ψ A

/-- Contract form of `massless_KL_weyl_correspondence` (0065). -/
def massless_KL_weyl_correspondence_contract (ctx : WeylContractContext) : Prop :=
  ∀ (ψ : TrefoilStructure) (Aext : ScalarComplexAction),
    ψ.toLeptonMass = 0 →
      let freeA := ctx.freeAction ψ
      let intA := ctx.interactingAction ψ Aext
      let KL := ctx.klDivergence freeA intA
      KL.energy = ctx.weylLagrangianDensity ψ Aext ∧
        KL.information = Real.log (ctx.chiralConservationMeasure ψ Aext)

/-- Contract form of `weyl_chiral_information_flow` (0072). -/
def weyl_chiral_information_flow_contract (ctx : WeylContractContext) : Prop :=
  ∀ (ψ : TrefoilStructure) (Aext : ScalarComplexAction),
    ψ.toLeptonMass = 0 →
      (ctx.chiralCurrent ψ Aext).divergence = 0 ∧
        let KL := ctx.klDivergence (ctx.freeAction ψ) (ctx.interactingAction ψ Aext)
        KL.information = Real.log (ctx.chiralConservationMeasure ψ Aext)

/-- Open physics bridge from 0065 encoded as an explicit contract obligation.
    Sorry-theorem: the contract is physically well-motivated (massless Weyl fermion +
    KL divergence correspondence) but requires QFT formalization beyond current Mathlib4. -/
theorem massless_KL_weyl_correspondence :
  ∀ ctx : WeylContractContext, massless_KL_weyl_correspondence_contract ctx := by
  sorry

/-- Open physics bridge from 0072 encoded as an explicit contract obligation.
    Sorry-theorem: chiral information flow is physically motivated but requires
    formal QFT measure theory beyond current Mathlib4. -/
theorem weyl_chiral_information_flow :
  ∀ ctx : WeylContractContext, weyl_chiral_information_flow_contract ctx := by
  sorry

/-! ## 3) DSF Information Definitions (from 0030) -/

structure InformationMetrics where
  entropicMeasure : ℝ
  complexityValue : ℝ
  stationaryInfo : ℝ

/-- Generic phantom-condition shape used by DSF snippets. -/
abbrev PhantomCondition := ℝ → ℝ → ℝ

def phantomInformationPreservation
    (phantomCondition : PhantomCondition) (qNorm Δ a : ℝ) : ℝ :=
  let deviation := abs (Δ - phantomCondition qNorm a)
  (1 - deviation) * (1 / (1 + deviation))

def dimensionalEntropyFlow
    (phantomCondition : PhantomCondition)
    (initialDim finalDim : Nat) (Q Δ : ℝ) : ℝ :=
  let scalingFactor := Real.sqrt ((finalDim : ℝ) / (initialDim : ℝ))
  let effectiveQ := Q * scalingFactor
  abs (phantomCondition effectiveQ 1 - Δ) * ((finalDim : ℝ) - (initialDim : ℝ))

/-! ## 4) Yukawa/EW Reusable Core (from 0241/0243/0244) -/

abbrev Gen := Fin 3
abbrev MatC := Matrix Gen Gen ℂ

structure EWSMParams where
  g : ℝ
  gp : ℝ
  v : ℝ
  g_pos : 0 < g
  gp_pos : 0 < gp
  v_pos : 0 < v

def sqrt2R : ℝ := Real.sqrt 2

def Unitary (U : MatC) : Prop :=
  Matrix.conjTranspose U * U = (1 : MatC)

def DiracMassMatrix (v : ℝ) (Y : MatC) : MatC :=
  ((v / sqrt2R : ℝ) : ℂ) • Y

structure YukawaSector where
  Yu : MatC
  Yd : MatC
  Ye : MatC
  Yν : MatC

def CKM (UuL UdL : MatC) : MatC := Matrix.conjTranspose UuL * UdL

def PMNS (UeL UνL : MatC) : MatC := Matrix.conjTranspose UeL * UνL

def sW (p : EWSMParams) : ℝ := p.gp / Real.sqrt (p.g ^ 2 + p.gp ^ 2)
def cW (p : EWSMParams) : ℝ := p.g / Real.sqrt (p.g ^ 2 + p.gp ^ 2)
def electricCharge (p : EWSMParams) : ℝ := p.g * sW p

def mW (p : EWSMParams) : ℝ := p.g * p.v / 2
def mZ (p : EWSMParams) : ℝ := (p.v / 2) * Real.sqrt (p.g ^ 2 + p.gp ^ 2)
def mA (_p : EWSMParams) : ℝ := 0

def rhoTree (p : EWSMParams) : ℝ := (mW p) ^ 2 / ((mZ p) ^ 2 * (cW p) ^ 2)

/-- Contractized identity from 0243: `(sin θ_W)^2 + (cos θ_W)^2 = 1`. -/
def sW2_plus_cW2_contract (p : EWSMParams) : Prop := (sW p) ^ 2 + (cW p) ^ 2 = 1

/-- Contractized identity from 0243: tree-level custodial `ρ = 1`. -/
def rho_tree_eq_one_contract (p : EWSMParams) : Prop := rhoTree p = 1

/-- Algebraic electroweak identity `(sin θ_W)^2 + (cos θ_W)^2 = 1`. -/
theorem sW2_plus_cW2_holds : ∀ p : EWSMParams, sW2_plus_cW2_contract p := by
  intro p
  unfold sW2_plus_cW2_contract sW cW
  set D : ℝ := Real.sqrt (p.g ^ 2 + p.gp ^ 2)
  have hD_pos : 0 < D := by
    have hsum_pos : 0 < p.g ^ 2 + p.gp ^ 2 := by
      nlinarith [sq_pos_of_pos p.g_pos, sq_nonneg p.gp]
    simpa [D] using Real.sqrt_pos.mpr hsum_pos
  have hD_ne : D ≠ 0 := ne_of_gt hD_pos
  have hD_sq : D ^ 2 = p.g ^ 2 + p.gp ^ 2 := by
    have hsum_nonneg : 0 ≤ p.g ^ 2 + p.gp ^ 2 := by nlinarith [sq_nonneg p.g, sq_nonneg p.gp]
    calc
      D ^ 2 = (Real.sqrt (p.g ^ 2 + p.gp ^ 2)) ^ 2 := by simp [D]
      _ = p.g ^ 2 + p.gp ^ 2 := by rw [sq_sqrt hsum_nonneg]
  have hsum_ne : p.g ^ 2 + p.gp ^ 2 ≠ 0 := by
    nlinarith [sq_pos_of_pos p.g_pos, sq_nonneg p.gp]
  calc
    (p.gp / D) ^ 2 + (p.g / D) ^ 2
        = (p.gp ^ 2 + p.g ^ 2) / D ^ 2 := by
            field_simp [hD_ne]
    _ = 1 := by
          rw [hD_sq]
          field_simp [hsum_ne]
          ring

/-- Tree-level custodial relation `ρ = 1` for the EW mass definitions used here. -/
theorem rho_tree_eq_one_holds : ∀ p : EWSMParams, rho_tree_eq_one_contract p := by
  intro p
  unfold rho_tree_eq_one_contract rhoTree mW mZ cW
  set D : ℝ := Real.sqrt (p.g ^ 2 + p.gp ^ 2)
  have hD_pos : 0 < D := by
    have hsum_pos : 0 < p.g ^ 2 + p.gp ^ 2 := by
      nlinarith [sq_pos_of_pos p.g_pos, sq_nonneg p.gp]
    simpa [D] using Real.sqrt_pos.mpr hsum_pos
  have hD_ne : D ≠ 0 := ne_of_gt hD_pos
  have hg_ne : p.g ≠ 0 := ne_of_gt p.g_pos
  have hv_ne : p.v ≠ 0 := ne_of_gt p.v_pos
  have h_four_ne : (4 : ℝ) ≠ 0 := by norm_num
  field_simp [hD_ne, hg_ne, hv_ne, h_four_ne]

def fermionMassFromY (y v : ℝ) : ℝ := y * v / sqrt2R

def y_eff (κ : ℝ) (tag : TrefoilTag) (S : ScalarComplexAction) (y : ℝ) : ℝ :=
  y * (1 + κ * S.SI * (tag.writhe : ℝ))

structure DiagonalizationData where
  UL : MatC
  UR : MatC
  diag : Gen → ℝ

def biunitaryDiagonalizationContract (M : MatC) (d : DiagonalizationData) : Prop :=
  Unitary d.UL ∧
    Unitary d.UR ∧
      (Matrix.conjTranspose d.UL * M * d.UR) =
        Matrix.diagonal (fun i => (d.diag i : ℂ))

/-- Diagonal matrices satisfy the biunitary contract with identity unitaries. -/
theorem biunitaryDiagonalizationContract_diagonal (d : Gen → ℝ) :
    biunitaryDiagonalizationContract
      (Matrix.diagonal (fun i => (d i : ℂ)))
      { UL := 1, UR := 1, diag := d } := by
  unfold biunitaryDiagonalizationContract Unitary
  simp

/-- Constructive diagonal special case of the biunitary-diagonalization bridge. -/
theorem exists_biunitary_diag_of_diagonal (d : Gen → ℝ) :
    ∃ data : DiagonalizationData,
      biunitaryDiagonalizationContract (Matrix.diagonal (fun i => (d i : ℂ))) data := by
  exact ⟨{ UL := 1, UR := 1, diag := d }, biunitaryDiagonalizationContract_diagonal d⟩

/-- **Hermitian case** of biunitary diagonalization (0 axioms, pure Mathlib).

    For `M.IsHermitian`, the spectral theorem gives `U† * M * U = diagonal(eigenvalues)`
    where `U = eigenvectorUnitary hM`. Taking `UL = UR = U` yields the contract.

    Proof route:
    - `Unitary UL/UR`: `(star ↑U : MatC) * ↑U = 1` from `Unitary.coe_star_mul_self`;
       `star = conjTranspose` definitionally on `Matrix Gen Gen ℂ`.
    - Diagonal equality: `conjStarAlgAut_star_eigenvectorUnitary` gives
      `conjStarAlgAut ℂ _ (star U) M = diagonal(ofReal ∘ eigenvalues)`;
      `conjStarAlgAut_star_apply` unfolds to `(star ↑U : MatC) * M * ↑U`.

    **Reference**: `Matrix.IsHermitian.conjStarAlgAut_star_eigenvectorUnitary`
    (Mathlib `Analysis.Matrix.Spectrum`). **Axioms consumed**: 0. -/
theorem exists_biunitary_diag_hermitian (M : MatC) (hM : M.IsHermitian) :
    ∃ d : DiagonalizationData, biunitaryDiagonalizationContract M d := by
  classical
  refine ⟨{ UL := hM.eigenvectorUnitary,
             UR := hM.eigenvectorUnitary,
             diag := hM.eigenvalues }, ?_, ?_, ?_⟩
  · -- Unitary UL: (star ↑U : MatC) * ↑U = 1, i.e., Uᴴ * U = 1
    -- star = conjTranspose definitionally; Unitary.coe_star_mul_self gives (star U : R) * U = 1
    exact _root_.Unitary.coe_star_mul_self hM.eigenvectorUnitary
  · -- Unitary UR: same
    exact _root_.Unitary.coe_star_mul_self hM.eigenvectorUnitary
  · -- Uᴴ * M * U = diagonal(eigenvalues)
    -- conjStarAlgAut_star_eigenvectorUnitary: conjStarAlgAut ℂ _ (star U) M = diagonal(ofReal∘λ)
    -- Unitary.conjStarAlgAut_star_apply unfolds LHS to (star ↑U : MatC) * M * ↑U
    -- star = conjTranspose definitionally; (r : ℂ) = RCLike.ofReal r definitionally
    simpa only [Unitary.conjStarAlgAut_star_apply, Function.comp]
      using hM.conjStarAlgAut_star_eigenvectorUnitary (𝕜 := ℂ)

/-- **Non-Hermitian case** of biunitary diagonalization (NSC-P1 narrowed sub-axiom).

    For `¬M.IsHermitian`, the singular value decomposition `M = UL * Σ * URᴴ` (SVD) gives
    `ULᴴ * M * UR = diagonal(σᵢ)` with `UL, UR` unitary and `σᵢ ≥ 0`.
    This is strictly narrower than `exists_biunitary_diag`: only covers non-Hermitian matrices.

    **Why separate from Hermitian case**: Mathlib4 has `IsHermitian.spectral_theorem` but
    NO general matrix SVD or polar decomposition. The non-Hermitian case is the only residual
    physics gap; the Hermitian case is fully discharged by `exists_biunitary_diag_hermitian`.

    **Reference**: Golub–Van Loan (1996) §2.5; missing from Mathlib4 as of 2026-03-30.
    **Discharge target**: WP12 (CATEPT off NS critical path). -/
theorem exists_biunitary_diag_nonhermitian (M : MatC) (_hM : ¬M.IsHermitian) :
  ∃ d : DiagonalizationData, biunitaryDiagonalizationContract M d := by
  classical
  -- ── Setup: spectral decomp of M†M ──────────────────────────────────────────────
  have hB : (Matrix.conjTranspose M * M).IsHermitian :=
    Matrix.isHermitian_conjTranspose_mul_self M
  -- UR = eigenvectorUnitary of M†M (unitary in Mathlib unitaryGroup sense)
  let UR_unit := hB.eigenvectorUnitary  -- : unitaryGroup (Fin 3) ℂ
  let UR : MatC := UR_unit              -- coercion to matrix
  -- Eigenvalues eigv ≥ 0; singular values singv = sqrt(eigv)
  let eigv : Fin 3 → ℝ := hB.eigenvalues
  let singv : Fin 3 → ℝ := fun j => Real.sqrt (eigv j)
  have heig_nn : ∀ j : Fin 3, 0 ≤ eigv j :=
    Matrix.eigenvalues_conjTranspose_mul_self_nonneg M
  have hsing_nn : ∀ j : Fin 3, 0 ≤ singv j := fun j => Real.sqrt_nonneg _
  -- UR is unitary in local sense (Mᴴ * M = 1 convention)
  have hUR : Matrix.conjTranspose UR * UR = 1 :=
    Unitary.coe_star_mul_self UR_unit
  -- ── P = M * UR; compute P†P = diagonal(eigv) ──────────────────────────────────
  let P : MatC := M * UR
  have hPtP : Matrix.conjTranspose P * P = Matrix.diagonal (RCLike.ofReal ∘ eigv) := by
    -- P = M * ↑UR_unit, so Pᴴ * P = ↑UR_unitᴴ * Mᴴ * M * ↑UR_unit = diagonal(eigv)
    have hSpec := hB.conjStarAlgAut_star_eigenvectorUnitary (𝕜 := ℂ)
    simp only [Unitary.conjStarAlgAut_star_apply] at hSpec
    -- hSpec: (star ↑UR_unit : MatC) * (Mᴴ * M) * ↑UR_unit = diagonal(RCLike.ofReal ∘ eigv)
    -- P is definitionally M * (↑UR_unit : MatC)
    change (M * (↑UR_unit : MatC))ᴴ * (M * (↑UR_unit : MatC)) = _
    rw [Matrix.conjTranspose_mul, Matrix.mul_assoc (Matrix.conjTranspose (↑UR_unit : MatC)),
        ← Matrix.mul_assoc (Matrix.conjTranspose M)]
    -- Goal: (↑UR_unit)ᴴ * ((Mᴴ * M) * ↑UR_unit) = diagonal(...)
    -- ↑UR_unitᴴ = star ↑UR_unit definitionally; hSpec has (star ...) * (B) * C = (star ...) * (B * C)
    rw [Matrix.mul_assoc] at hSpec  -- converts (A * B) * C to A * (B * C) in hSpec
    exact hSpec
  -- ── Inner product formula for columns of P ──────────────────────────────────────
  -- ⟪toLp 2 (P.col i), toLp 2 (P.col j)⟫_ℂ = (P†P) i j = if i=j then eigv i else 0
  have hPcol_inner : ∀ i j : Fin 3,
      ⟪(WithLp.toLp 2 (Matrix.col P i) : EuclideanSpace ℂ (Fin 3)),
       WithLp.toLp 2 (Matrix.col P j)⟫_ℂ = if i = j then (eigv i : ℂ) else 0 := by
    intro i j
    rw [EuclideanSpace.inner_toLp_toLp]
    have hDot : dotProduct (Matrix.col P j) (star (Matrix.col P i)) =
                (Matrix.conjTranspose P * P) i j := by
      simp [dotProduct, Matrix.col, Matrix.mul_apply,
            Matrix.conjTranspose_apply, star_def, mul_comm]
    rw [hDot, hPtP, Matrix.diagonal_apply, Function.comp_apply]
    simp [RCLike.ofReal_eq_zero]
  -- ── Columns of P are zero when singv j = 0 ────────────────────────────────────
  have hPcol_zero : ∀ j : Fin 3, singv j = 0 → Matrix.col P j = 0 := by
    intro j hs0
    have he0 : eigv j = 0 :=
      le_antisymm (Real.sqrt_eq_zero'.mp hs0) (heig_nn j)
    have hInner : ⟪(WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3)),
                   WithLp.toLp 2 (Matrix.col P j)⟫_ℂ = 0 := by
      rw [hPcol_inner j j, if_pos rfl]; exact_mod_cast he0
    have hVecZero : (WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3)) = 0 :=
      inner_self_eq_zero.mp hInner
    exact (WithLp.toLp_eq_zero 2).mp hVecZero
  -- ── Build normalized partial ONB from nonzero columns of P ─────────────────────
  -- For j ∈ S = {j | singv j ≠ 0}: ev j = (singv j : ℂ)⁻¹ • toLp 2 (P.col j)
  -- For j ∉ S: ev j = 0 (will be filled in by extension)
  let S : Set (Fin 3) := {j | singv j ≠ 0}
  let ev : Fin 3 → EuclideanSpace ℂ (Fin 3) := fun j =>
    if h : singv j ≠ 0 then ((singv j : ℂ)⁻¹) • WithLp.toLp 2 (Matrix.col P j) else 0
  -- Norm of P.col j as EuclideanSpace vector equals singv j
  have hNorm : ∀ j : Fin 3,
      ‖(WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3))‖ = singv j := by
    intro j
    have h1 := hPcol_inner j j; rw [if_pos rfl] at h1
    have hN2 : ‖(WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3))‖ ^ 2 = eigv j := by
      have h2 := inner_self_eq_norm_sq (𝕜 := ℂ)
                   (WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3))
      -- h2 : re ⟪x, x⟫_ℂ = ‖x‖^2
      rw [h1] at h2; simp [RCLike.ofReal_re] at h2; linarith
    rw [← Real.sqrt_sq (norm_nonneg _), hN2]
  -- ev is orthonormal on S
  have hev_on : Orthonormal ℂ (S.restrict ev) := by
    constructor
    · intro ⟨j, hj⟩
      have hj' : singv j ≠ 0 := hj
      simp only [Set.restrict_apply, ev, dif_pos hj', norm_smul, norm_inv]
      rw [hNorm j]
      simp only [map_inv₀, Complex.norm_real, abs_of_nonneg (hsing_nn j),
                 Real.norm_of_nonneg (hsing_nn j)]
      exact inv_mul_cancel₀ hj'
    · intro ⟨i, hi⟩ ⟨j, hj⟩ hij
      have hi' : singv i ≠ 0 := hi
      have hj' : singv j ≠ 0 := hj
      have hne : (i : Fin 3) ≠ j := fun h => hij (Subtype.ext h)
      simp only [Set.restrict_apply, ev, dif_pos hi', dif_pos hj',
                 inner_smul_left, inner_smul_right, hPcol_inner i j, if_neg hne,
                 smul_zero, mul_zero]
  -- ── Extend ev|S to full ONB ──────────────────────────────────────────────────────
  have hrank : Module.finrank ℂ (EuclideanSpace ℂ (Fin 3)) = Fintype.card (Fin 3) := by
    simp [finrank_euclideanSpace]
  obtain ⟨b, hb_ext⟩ := hev_on.exists_orthonormalBasis_extension_of_card_eq hrank
  -- ── Define UL from ONB b ─────────────────────────────────────────────────────────
  -- UL i j = (b j) i (column j of UL = j-th basis vector as a function Fin 3 → ℂ)
  let UL : MatC := fun i j => WithLp.ofLp (b j) i
  -- UL is unitary: ULᴴ * UL = 1
  have hUL : Matrix.conjTranspose UL * UL = 1 := by
    ext i j
    simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, Matrix.one_apply, UL, star_def]
    -- Σ_k conj((b i) k) * (b j) k = ⟪b i, b j⟫_ℂ = if i=j then 1 else 0
    have hInner : ∑ k, starRingEnd ℂ (WithLp.ofLp (b i) k) * WithLp.ofLp (b j) k =
                  ⟪(b i : EuclideanSpace ℂ (Fin 3)), b j⟫_ℂ := by
      rw [PiLp.inner_apply]; congr 1; ext k; rw [RCLike.inner_apply']
    rw [hInner, b.inner_eq_ite]
  -- ULᴴ * P = diagonal(singv): key SVD condition
  have hDiag : Matrix.conjTranspose UL * P = Matrix.diagonal (fun j => (singv j : ℂ)) := by
    ext i j
    simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, Matrix.diagonal_apply, UL, star_def]
    -- Σ_k conj((b i) k) * P k j = ⟪b i, toLp 2 (P.col j)⟫_ℂ
    have hInner : ∑ k, starRingEnd ℂ (WithLp.ofLp (b i) k) * P k j =
                  ⟪(b i : EuclideanSpace ℂ (Fin 3)), WithLp.toLp 2 (Matrix.col P j)⟫_ℂ := by
      rw [PiLp.inner_apply]; congr 1; ext k
      rw [RCLike.inner_apply', starRingEnd_apply, WithLp.ofLp_toLp]
      simp [Matrix.col]
    rw [hInner]
    by_cases hj : singv j ≠ 0
    · -- j ∈ S: b j = (singv j)⁻¹ • toLp 2 (P.col j), so toLp 2 (P.col j) = singv j • b j
      have hbj : b j = ev j := hb_ext j (Set.mem_setOf.mpr hj)
      simp only [ev, dif_pos hj] at hbj
      -- hbj : b j = (singv j)⁻¹ • toLp 2 (P.col j)
      -- Hence toLp 2 (P.col j) = singv j • b j
      have hne_c : (singv j : ℂ) ≠ 0 := by exact_mod_cast hj
      have hPeq : (WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3)) =
                  (singv j : ℂ) • b j := by
        rw [hbj, smul_smul, mul_inv_cancel₀ hne_c, one_smul]
      rw [hPeq, inner_smul_right, b.inner_eq_ite]
      -- goal: (if i=j then ↑(singv j) else 0) = if i=j then ↑(singv i) else 0
      -- split on i=j: equal by rfl; i≠j: both 0
      simp only [mul_ite, mul_one, mul_zero]
      split_ifs with h
      · rw [h]
      · rfl
    · -- j ∉ S: singv j = 0, P.col j = 0
      push_neg at hj
      have hcol0 : (WithLp.toLp 2 (Matrix.col P j) : EuclideanSpace ℂ (Fin 3)) = 0 := by
        rw [hPcol_zero j hj]; simp
      rw [hcol0, inner_zero_right]
      -- goal: 0 = if i=j then ↑(singv i) else 0; when i=j: singv j=0 so rhs=0
      split_ifs with h
      · simp [h, hj]
      · rfl
  -- ── Assemble: DiagonalizationData with UL, UR, singv ────────────────────────────
  refine ⟨{ UL := UL, UR := UR, diag := singv }, hUL, hUR, ?_⟩
  -- Goal: ULᴴ * M * UR = diagonal(singv); from ULᴴ * P = diagonal(singv) and P = M * UR
  have : Matrix.conjTranspose UL * M * UR = Matrix.conjTranspose UL * P := by
    show Matrix.conjTranspose UL * M * UR = Matrix.conjTranspose UL * (M * UR)
    rw [← Matrix.mul_assoc]
  rw [this]; exact hDiag

/-- **Biunitary diagonalization** for all 3×3 complex matrices — THEOREM (P1 decomposition).

    Derived from:
    - `exists_biunitary_diag_hermitian` (0 axioms; Hermitian case via spectral theorem)
    - `exists_biunitary_diag_nonhermitian` (1 axiom; non-Hermitian SVD gap)

    **Net axiom change**: 1 broad axiom → 1 narrower axiom (+ 1 theorem).
    Axiom count unchanged at 14, but epistemic surface is narrower: the remaining axiom
    covers only `¬M.IsHermitian` (SVD missing from Mathlib4). -/
theorem exists_biunitary_diag :
    ∀ M : MatC, ∃ d : DiagonalizationData, biunitaryDiagonalizationContract M d := by
  intro M
  by_cases hM : M.IsHermitian
  · exact exists_biunitary_diag_hermitian M hM
  · exact exists_biunitary_diag_nonhermitian M hM

end WeylYukawa
end NavierStokesClean.CATEPT
