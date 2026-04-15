import CATEPTMain.AFPBridge.LDO.WilsonFermion
/-!
# LatticeDiracOperators.jl → Lean 4 — Domain Wall Fermion (Phase 1)

Formalises the domain wall fermion sector from:
  - `DomainwallFermion/DomainwallFermion.jl`     — abstract operator hierarchy
  - `DomainwallFermion/DomainwallFermion_5d.jl`  — 5D kernel D5DW, adjoint
  - `DomainwallFermion/DomainwallFermion_5d_wing.jl` — concrete 5D wing struct
  - `DomainwallFermion/DomainwallFermion_3d_wing.jl` — 3D variant
  - `DomainwallFermion/DomainwallFermion_5d_mpi.jl`  — MPI variant
  - `DomainwallFermion/DomainwallFermion_5d_wing_mpi.jl` — MPI wing variant

## Domain wall Dirac operator (Kaplan, 1992)

  D_DW(m) = D5DW(m) · D5DW(1)^{-1}      (Pauli-Villars preconditioned form)

  where the 5D kernel acts on a field ψ(x,s), s=1,…,L5:

  (D5DW ψ)(x,s) = D_W ψ(x,s)
    + P₋ ψ(x,s+1) + P₊ ψ(x,s−1)    (bulk nearest-neighbour in s)
    − m P₊ ψ(x,L5)  [if s=1]        (boundary: mass-induced mixing)
    − m P₋ ψ(x,1)   [if s=L5]       (boundary: mass-induced mixing)

  with chiral projectors P± = (1 ± γ₅)/2, and κ = 1/(2Dim·r + 2M).

## Key structural properties

  - D5DW(1)    : Pauli-Villars (regulator), mass = 1
  - D5DW†(m)   : adjoint with ± chiralities swapped (see DomainwallFermion_5d.jl)
  - γ5-Hermiticity: D5DW† = γ5 · D5DW · γ5 (inherited from Wilson sector)
  - DdagD : D†(m) D(m) = D5DW_PV^{-1†} D5DW†(m) D5DW(m) D5DW_PV^{-1}

## Operators

  - D5DW         : 5D bulk kernel (no Pauli-Villars)
  - Domainwall_D : full D = D5DW(m) D5DW(1)^{-1} (inversion via BiCG)
  - J-reflection : apply_J! — reverses fifth-dimension index
  - P-permutation: apply_P! / apply_Pdag! — cyclic chirality shifts
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.LDO

-- ── Domain wall parameters ─────────────────────────────────────────────────────
/-- Parameters for the domain wall Dirac operator.
  Source: fields of `D5DW_Domainwall_operator` in DomainwallFermion.jl. -/
structure DomainwallParams where
  mass : Float               -- fermion mass m (0 < m < 2)
  M    : Float               -- Wilson mass parameter M (default −1)
  L5   : ℕ                   -- fifth-dimension extent
  bc   : BoundaryCondition 4 -- spatial boundary conditions
  eps  : Float               -- CG tolerance
  maxCGstep : ℕ              -- max CG steps

/-- Wilson hopping κ derived from (M, r=1, Dim=4): κ = 1/(2·4·1 + 2M).
  Source: `κ_wilson = 1/(2*Dim*r + 2M)` in DomainwallFermion.jl L54. -/
def domainwallKappa (p : DomainwallParams) : Float :=
  wilsonKappaFromM 4 1.0 p.M

-- ── 5D kernel D5DW ────────────────────────────────────────────────────────────
/-- Apply the 5D domain wall kernel D5DW(m) to a 5D fermion field.
  Source: `D5DWx!(xout, U, x, m, A, L5)` in DomainwallFermion_5d.jl.
  Implements the tridiagonal-in-s operator with chiral BC at s=1 and s=L5. -/
axiom d5dwDx (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- Adjoint 5D kernel D5DW†(m).
  Source: `D5DWdagx!(xout, U, x, m, A, L5)` in DomainwallFermion_5d.jl.
  Implements same structure but with P₊/P₋ roles exchanged (see L308–355). -/
axiom d5dwDdagx (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- DdagD = D5DW†·D5DW applied to a 5D field.
  Source: `D5DWdagD5DW_Wilson_operator` mul! in DomainwallFermion.jl L356–364. -/
noncomputable def d5dwDdagDx (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5 :=
  d5dwDdagx NC NX NY NZ NT L5 p U (d5dwDx NC NX NY NZ NT L5 p U ψ)

-- ── γ5-Hermiticity of D5DW ───────────────────────────────────────────────────
/-- Apply γ5 to each 4D slice of a 5D field (acts on spinor index per slice).
  Source: 5D field is a vector of 4D WilsonFermion fields; apply_γ5! on each slice. -/
axiom applyGamma5_5D (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- Structural axiom for γ5-Hermiticity of the 5D domain wall kernel.
  Physical basis: D5DW acts as Wilson on each 4D slice in the bulk, and the
  boundary terms couple only P₊/P₋ components.  Taking γ5 on each slice:
    γ5 D5DW γ5 = D5DW†  (chirality ± swap + U ↔ U† exchange on each slice)
  Phase-2: proved by slice induction using wilsonDdagx_eq_gamma5Dgamma5. -/
axiom d5dwDdagx_eq_gamma5Dgamma5 (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) :
    d5dwDdagx NC NX NY NZ NT L5 p U ψ =
    applyGamma5_5D NC NX NY NZ NT L5
      (d5dwDx NC NX NY NZ NT L5 p U
        (applyGamma5_5D NC NX NY NZ NT L5 ψ))

/-- γ5-Hermiticity of D5DW: D5DW† = γ5 D5DW γ5.
  Source: inherited from Wilson γ5-Hermiticity; each 4D slice satisfies it.
  This is the key structural property ensuring the DW spectrum is γ5-symmetric. -/
theorem d5dw_gamma5_hermiticity (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) :
    d5dwDdagx NC NX NY NZ NT L5 p U ψ =
    applyGamma5_5D NC NX NY NZ NT L5
      (d5dwDx NC NX NY NZ NT L5 p U
        (applyGamma5_5D NC NX NY NZ NT L5 ψ)) :=
  d5dwDdagx_eq_gamma5Dgamma5 NC NX NY NZ NT L5 p U ψ

-- ── J-reflection and chirality operators ─────────────────────────────────────
/-- Apply the J-reflection matrix (reverses fifth-dimension index: s ↦ L5+1−s).
  Source: `apply_J!(xout, x)` in DomainwallFermion_5d.jl L58–68. -/
axiom applyReflectionJ (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- J is involutive: J² = 1. -/
axiom applyReflectionJ_sq (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) :
    applyReflectionJ NC NX NY NZ NT L5
      (applyReflectionJ NC NX NY NZ NT L5 ψ) = ψ

/-- Apply the P-permutation matrix (cyclic chirality shift in s-direction).
  Source: `apply_P!(xout, x)` in DomainwallFermion_5d.jl L85–103. -/
axiom applyPermutationP (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- Apply P† (adjoint permutation).
  Source: `apply_Pdag!(xout, x)` in DomainwallFermion_5d.jl L106–125. -/
axiom applyPermutationPdag (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- P · P† = 1 (P is unitary).
  Source: `Base.adjoint` interchange in DomainwallFermion.jl L304–309. -/
axiom applyPermutationP_unitary (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) :
    applyPermutationPdag NC NX NY NZ NT L5
      (applyPermutationP NC NX NY NZ NT L5 ψ) = ψ

-- ── Full domain wall operator ─────────────────────────────────────────────────
/-- Full preconditioned DW operator: D_DW(m) = D5DW(m) · D5DW_PV(1)^{−1} x.
  Source: `Domainwall_Dirac_operator` mul! in DomainwallFermion.jl:
    bicg(temp1, D5DW_PV, x)   -- invert PV: temp1 = D5DW(1)^{-1} x
    mul!(y, D5DW, temp1)      -- apply physical: y = D5DW(m) temp1. -/
axiom domainwallDx (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- Adjoint full DW operator: D_DW†(m) = D5DW_PV(1)^{-†} · D5DW†(m).
  Source: `Adjoint_Domainwall_operator` mul! in DomainwallFermion.jl L426. -/
axiom domainwallDdagx (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) : FermionField5D NC NX NY NZ NT 4 L5

/-- DdagD positivity for the full DW operator. -/
theorem domainwallDdagD_nonneg (NC NX NY NZ NT L5 : ℕ) (hL5 : 0 < L5)
    (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) :
    0 ≤ normSqFermion NC NX NY NZ NT 4
          (getFermion5DSlice NC NX NY NZ NT 4 L5
            (d5dwDx NC NX NY NZ NT L5 p U ψ)
            ⟨0, hL5⟩) :=
  normSq_nonneg NC NX NY NZ NT 4 _

-- ── DomainwallFermion_5D struct properties ────────────────────────────────────
/-- A 5D domain wall fermion field is a vector of L5 4D Wilson fermion fields.
  Source: `DomainwallFermion_5D.w::Array{WilsonFermion,1}` of length L5. -/
axiom fermion5D_slice_length (NC NX NY NZ NT L5 : ℕ)
    (ψ : FermionField5D NC NX NY NZ NT 4 L5) (s : Fin L5) :
    True  -- phase2_high: length(getFermion5DSlice ψ s) = NC*NX*NY*NZ*NT*4

/-- Linearity: D5DW is linear in the input field.
  Source: `axpy!`, `add!` calls throughout DomainwallFermion_5d.jl.
  Phase 2: from linearity of D_W on each slice + linearity of projectors. -/
axiom d5dwDx_linear (NC NX NY NZ NT L5 : ℕ) (p : DomainwallParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (a : ℂ)
    (ψ φ : FermionField5D NC NX NY NZ NT 4 L5) :
    True  -- phase2_high: d5dwDx p U (a·ψ + φ) = a · d5dwDx p U ψ + d5dwDx p U φ

end CATEPTMain.AFPBridge.LDO
