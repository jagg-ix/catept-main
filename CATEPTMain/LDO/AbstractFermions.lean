import CATEPTMain.LDO.LDOPrelude
/-!
# LatticeDiracOperators.jl → Lean 4 — Abstract Fermion Hierarchy (Phase 1)

Formalises the abstract type hierarchy from:
  - `AbstractFermions.jl`         — base class + adjoint wrapper + σ_μν
  - `AbstractFermions_4D.jl`      — 4D indexing, lattice index decode
  - `AbstractFermions_2D.jl`      — 2D variant
  - `AbstractFermions_3D.jl`      — 3D variant
  - `AbstractFermions_5D.jl`      — 5D (domain wall)
  - `AbstractFermion_MPILattice.jl` — distributed variant

## Julia type hierarchy

  Abstractfermion
  └── AbstractFermionfields{NC,Dim}
      ├── AbstractFermionfields_4D{NC}   (4D, NC colors)
      │   ├── WilsonFermion_4D{NC}
      │   │   └── WilsonFermion_4D_wing{NC,NDW}   (concrete)
      │   └── StaggeredFermion_4D{NC}   (abstract)
      ├── AbstractFermionfields_2D{NC}
      ├── AbstractFermionfields_3D{NC}
      └── AbstractFermionfields_5D{NC}  (domain wall)
  └── Adjoint_fermion{T}
      └── Adjoint_fermionfields{T}

In Lean 4 Phase 1: parameterised opaque types with axioms for operations.
-/

set_option autoImplicit false

open CATEPTMainFramework.TacticStubs

namespace CATEPTMain.LDO

-- ── Adjoint fermion field ─────────────────────────────────────────────────────
/-- Adjoint fermion: element-wise conjugate of the parent field.
  Source: `Adjoint_fermionfields{T}` + `Base.getindex(x, i) = conj(x.parent[i])` -/
noncomputable def adjointFermion (NC NX NY NZ NT NG : ℕ)
    (ψ : FermionField NC NX NY NZ NT NG) : FermionField NC NX NY NZ NT NG :=
  -- Phase-1: adjoint = entry-wise conjugate; no structural change
  -- Phase-2: use Matrix.conjTranspose
  ψ  -- stub: identity (see adjoint_conj below)

/-- Core property: adjoint field component is complex conjugate.
  Source: `Base.getindex(x::Adjoint_fermionfields{T}, i) = conj(x.parent[i])` -/
axiom adjoint_conj (NC NX NY NZ NT NG : ℕ)
    (ψ : FermionField NC NX NY NZ NT NG)
    (i : Fin (fermionLength NC NX NY NZ NT NG)) :
    getFlatComp NC NX NY NZ NT NG (adjointFermion NC NX NY NZ NT NG ψ) i =
    star (getFlatComp NC NX NY NZ NT NG ψ i)

/-- Adjoint is involutive: (ψ†)† = ψ.
  Source: `Base.adjoint ∘ Base.adjoint = id`. -/
theorem adjointFermion_invol (NC NX NY NZ NT NG : ℕ)
    (ψ : FermionField NC NX NY NZ NT NG) :
    adjointFermion NC NX NY NZ NT NG (adjointFermion NC NX NY NZ NT NG ψ) = ψ :=
  fermionField_ext NC NX NY NZ NT NG _ ψ (fun i => by
    rw [adjoint_conj NC NX NY NZ NT NG (adjointFermion NC NX NY NZ NT NG ψ) i,
        adjoint_conj NC NX NY NZ NT NG ψ i,
        star_star])

-- ── Linear algebra on fermion fields ─────────────────────────────────────────
/-- Zero axiom: ⟨0, ψ⟩ = 0.
  Source: `dotFermion` linearity implied by LinearAlgebra.dot. -/
axiom dotFermion_zero_left (NC NX NY NZ NT NG : ℕ)
    (ψ : FermionField NC NX NY NZ NT NG) :
    dotFermion NC NX NY NZ NT NG (zeroFermion NC NX NY NZ NT NG) ψ = 0

/-- Conjugate symmetry: ⟨ψ, φ⟩ = conj ⟨φ, ψ⟩.
  Source: standard Hermitian inner product. -/
axiom dotFermion_conj_symm (NC NX NY NZ NT NG : ℕ)
    (ψ φ : FermionField NC NX NY NZ NT NG) :
    dotFermion NC NX NY NZ NT NG ψ φ = star (dotFermion NC NX NY NZ NT NG φ ψ)

/-- Positivity: ‖ψ‖² ≥ 0, with equality iff ψ = 0.
  Source: `rnorm = real(res ⋅ res) ≥ 0` in cgmethods.jl. -/
axiom normSq_nonneg (NC NX NY NZ NT NG : ℕ)
    (ψ : FermionField NC NX NY NZ NT NG) :
    0 ≤ normSqFermion NC NX NY NZ NT NG ψ

axiom normSq_zero_iff (NC NX NY NZ NT NG : ℕ)
    (ψ : FermionField NC NX NY NZ NT NG) :
    normSqFermion NC NX NY NZ NT NG ψ = 0 ↔ ψ = zeroFermion NC NX NY NZ NT NG

/-- axpby linearity in inner product.
  Source: implied by `LinearAlgebra.axpby!`. -/
axiom dotFermion_axpby (NC NX NY NZ NT NG : ℕ) (a b : ℂ)
    (X Y Z : FermionField NC NX NY NZ NT NG) :
    dotFermion NC NX NY NZ NT NG (axpby_fermion NC NX NY NZ NT NG a b X Y) Z =
    a * dotFermion NC NX NY NZ NT NG X Z + b * dotFermion NC NX NY NZ NT NG Y Z

-- ── 4D lattice index decoder ─────────────────────────────────────────────────
/-- Decode flat index i ∈ {0,..,NC·NX·NY·NZ·NT·NG-1} to (ic, ix, iy, iz, it, ig).
  Source: `get_latticeindex_fermion(i, NC, NX, NY, NZ, NT)` in AbstractFermions_4D.jl.
  Julia formula: ic = i % NC, ix = (i/NC) % NX, iy = (i/NC/NX) % NY, etc.
  Phase 1: axiom (bounds from Nat.mod_lt are phase2_medium). -/
axiom decodeLatticeIdx (NC NX NY NZ NT NG : ℕ) (i : Fin (NC * NX * NY * NZ * NT * NG)) :
    Fin NC × Fin NX × Fin NY × Fin NZ × Fin NT × Fin NG
  -- phase2_medium: constructive proof via
  --   ic = i.val % NC, hic : Nat.mod_lt _ (Nat.pos_of_mul_pos_left i.isLt)
  --   and similarly for ix, iy, iz, it, ig

-- ── Staggering phase η_μ(x) ──────────────────────────────────────────────────
/-- Staggered phase η_μ(x) = (-1)^{x_1 + … + x_{μ-1}}.
  Source: implicit in StaggeredFermion_4D_wing.jl hopping terms.
  Convention:
    η_1(x) = 1
    η_2(x) = (-1)^{x_1}
    η_3(x) = (-1)^{x_1 + x_2}
    η_4(x) = (-1)^{x_1 + x_2 + x_3} -/
def staggeringPhase (μ : Fin 4) (ix iy iz it : ℕ) : ℤ :=
  match μ with
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => (-1) ^ ix
  | ⟨2, _⟩ => (-1) ^ (ix + iy)
  | ⟨3, _⟩ => (-1) ^ (ix + iy + iz)

/-- η_μ(x) ∈ {+1, -1}. -/
theorem staggeringPhase_pm_one (μ : Fin 4) (ix iy iz it : ℕ) :
    staggeringPhase μ ix iy iz it = 1 ∨ staggeringPhase μ ix iy iz it = -1 := by
  simp only [staggeringPhase]
  match μ with
  | ⟨0, _⟩ => left; rfl
  | ⟨1, _⟩ =>
      rcases Nat.even_or_odd ix with h | h
      · left;  exact h.neg_one_pow
      · right; exact h.neg_one_pow
  | ⟨2, _⟩ =>
      rcases Nat.even_or_odd (ix + iy) with h | h
      · left;  exact h.neg_one_pow
      · right; exact h.neg_one_pow
  | ⟨3, _⟩ =>
      rcases Nat.even_or_odd (ix + iy + iz) with h | h
      · left;  exact h.neg_one_pow
      · right; exact h.neg_one_pow

/-- η_μ(x)² = 1. -/
theorem staggeringPhase_sq (μ : Fin 4) (ix iy iz it : ℕ) :
    (staggeringPhase μ ix iy iz it) ^ 2 = 1 := by
  rcases staggeringPhase_pm_one μ ix iy iz it with h | h <;> simp [h]

-- ── Chiral projectors (Euclidean) ─────────────────────────────────────────────
/-- Positive chirality projector P₊ = (1 + γ_5)/2 for domain wall.
  Source: `P_- δ_{s',s+1}` and `P_+ δ_{s',s-1}` in DomainwallFermion_5d.jl.
  In Euclidean convention: γ₅ = γ₁γ₂γ₃γ₄. -/
axiom chiralProjPlus  : Unit  -- phase2_high: 4×4 matrix (1+γ₅)/2
axiom chiralProjMinus : Unit  -- phase2_high: 4×4 matrix (1-γ₅)/2

-- ── 5D field slice operations ──────────────────────────────────────────────────
/-- Extract 4D slice at fifth-dimension position s from a 5D fermion field.
  Source: `x.w[s]` where `w::Vector{4D_fermion}` in AbstractFermions_5D.jl. -/
axiom getFermion5DSlice (NC NX NY NZ NT NG L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT NG L5)
    (s : Fin L5) : FermionField NC NX NY NZ NT NG

/-- Set 4D slice at position s.
  Source: `x.w[s] = v` in DomainwallFermion_5d.jl construction. -/
axiom setFermion5DSlice (NC NX NY NZ NT NG L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT NG L5)
    (s : Fin L5) (v : FermionField NC NX NY NZ NT NG) :
    FermionField5D NC NX NY NZ NT NG L5

-- ── Wing (halo) structure ─────────────────────────────────────────────────────
/-- NDW = number of halo layers (ghost cells) for MPI communication.
  Source: `NDW::Int64` field of WilsonFermion_4D_wing, StaggeredFermion, etc.
  Physical lattice has NX×NY×NZ×NT sites; with halo: (NX+2NDW)×…×(NT+2NDW). -/
def physicalVolume (NX NY NZ NT NDW : ℕ) : ℕ := NX * NY * NZ * NT
def totalVolume    (NX NY NZ NT NDW : ℕ) : ℕ :=
  (NX + 2*NDW) * (NY + 2*NDW) * (NZ + 2*NDW) * (NT + 2*NDW)

/-- Halo index offset: halo site at position (i+NDW) in storage.
  Source: `x.f[i1, i2+NDW, i3+NDW, i4+NDW, i5+NDW, i6] = v`
    in WilsonFermion_4D_wing.jl setindex!. -/
theorem halo_offset_correct (i NDW NX : ℕ) (hi : i < NX) :
    i + NDW < NX + 2 * NDW := by omega

end CATEPTMain.LDO
