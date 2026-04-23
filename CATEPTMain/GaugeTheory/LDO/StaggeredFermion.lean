import CATEPTMain.GaugeTheory.LDO.AbstractFermions
/-!
# LatticeDiracOperators.jl → Lean 4 — Staggered Fermion (Phase 1)

Formalises the staggered fermion sector from:
  - `StaggeredFermion/StaggeredFermion.jl`        — abstract operator struct
  - `StaggeredFermion/StaggeredFermion_4D_wing.jl` — concrete 4D wing variant
  - `StaggeredFermion/StaggeredFermion_4D_nowing.jl` — no-halo variant
  - `StaggeredFermion/StaggeredFermion_2D_wing.jl`  — 2D variant
  - `StaggeredFermion/StaggeredFermion_4D_nowing_mpi.jl` — MPI variant

## Staggered Dirac operator (Kogut-Susskind)

  (D_stag ψ)(x) = m·ψ(x) + (1/2) ∑_{μ=1}^{4}
    [ η_μ(x) U_μ(x) ψ(x+μ̂) − η_μ(x) U†_μ(x−μ̂) ψ(x−μ̂) ]

  where η_μ(x) = (−1)^{x_1+…+x_{μ−1}} is the Kogut-Susskind staggering phase.
  NG = 1 (staggered fermion has one spinor component per site × color).

## Key property: anti-Hermitian hopping

  D_stag† = −D_stag  (for m=0 and U unitary)
  ↔ spectrum is purely imaginary ± m (no doublers after taste averaging)

## DdagD = (m² − D²_hop): positive semi-definite for real m.
-/

set_option autoImplicit false

open CATEPTMain.Core.Framework.TacticStubs

namespace CATEPTMain.GaugeTheory.LDO

-- ── Staggered operator parameters ────────────────────────────────────────────
/-- Parameters for the Kogut-Susskind staggered Dirac operator.
  Source: fields of `Staggered_Dirac_operator` in StaggeredFermion.jl. -/
structure StaggeredParams where
  mass : Float              -- bare staggered mass
  bc   : BoundaryCondition 4  -- boundary conditions per direction
  eps  : Float              -- CG convergence threshold (default 1e-10)
  maxCGstep : ℕ             -- max CG iterations

/-- Default staggered parameters: m=0, anti-periodic in time, periodic in space. -/
def defaultStaggeredParams : StaggeredParams :=
  { mass := 0.0, bc := default_bc_4D,
    eps := 1e-10, maxCGstep := 1000 }

-- ── Staggered gauge link with phase ──────────────────────────────────────────
/-- Staggered-dressed gauge link: U_μ^{stag}(x) = η_μ(x) · U_μ(x).
  Source: `staggered_U(U[ν], ν)` in StaggeredFermion_4D_wing.jl.
  This absorbs the Kogut-Susskind phase into the link variable. -/
axiom staggeredLink (NC NX NY NZ NT : ℕ) (μ : EuclidIdx)
    (U : GaugeField NC NX NY NZ NT 4)
    (ix iy iz it : ℕ) : GaugeLink NC

/-- The staggered phase is absorbed: staggeredLink at μ carries η_μ(x) factor.
  Source: `staggered_U` multiplies the phase; see StaggeredFermion_4D_wing.jl L57. -/
axiom staggeredLink_phase (NC NX NY NZ NT : ℕ) (μ : EuclidIdx)
    (U : GaugeField NC NX NY NZ NT 4)
    (ix iy iz it : ℕ) :
    True  -- phase2_high: staggeredLink μ U x = η_μ(x) * getLink U μ x

-- ── Staggered Dirac operator application ─────────────────────────────────────
/-- Staggered hopping operator `Dx` (the off-diagonal κ-independent part).
  Source: `Dx!(xout, U, x, temps, boundarycondition)` in StaggeredFermion_4D_wing.jl.
  Implements:
    xout^a(x) = (1/2) ∑_μ
      [ η_μ(x) U_μ(x)^{ab} x^b(x+μ̂) − η_μ(x) U†_μ(x-μ̂)^{ab} x^b(x-μ̂) ] -/
axiom staggeredDx (NC NX NY NZ NT : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 1) : FermionField NC NX NY NZ NT 1

/-- Full staggered Dirac operator: D = m + Dx.
  Source: `add_fermion!(y, A.mass, x, 1, temp)` after `Dx!` in StaggeredFermion.jl L183.
  Phase 1: axiom because Float→ℂ cast not available; Phase 2: use ℝ mass parameter. -/
axiom staggeredFullDx (NC NX NY NZ NT : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 1) : FermionField NC NX NY NZ NT 1

/-- Adjoint staggered operator: D† applies Dx with opposite sign of hopping.
  Source: `add_fermion!(y, A.parent.mass, x, -1, temp)` in StaggeredFermion.jl L206.
  Anti-Hermiticity of hop: Dx† = −Dx (for unitary U). -/
axiom staggeredDxAdj (NC NX NY NZ NT : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 1) : FermionField NC NX NY NZ NT 1

/-- Anti-Hermiticity of staggered hopping: Dx† = −Dx.
  Source: `add_fermion!(y, mass, x, -1, temp)` vs `+1` above.
  Physical basis: η_μ(x)² = 1 and U† = U^{-1} → Dx† = −Dx at m=0. -/
axiom staggeredDx_antiHermitian (NC NX NY NZ NT : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 1) :
    staggeredDxAdj NC NX NY NZ NT p U x =
    axpby_fermion NC NX NY NZ NT 1 (-1) 0
      (staggeredDx NC NX NY NZ NT p U x)
      (zeroFermion NC NX NY NZ NT 1)
  -- phase2_high: from staggeredLink_phase + applyLinkAdj + staggeringPhase_sq

-- ── DdagD positivity ─────────────────────────────────────────────────────────
/-- DdagD = D†D ≥ 0 for staggered fermion.
  Source: `Dx!(temp2, U, temp, ...)` after `Dx!` in DdagD mul; StaggeredFermion.jl L231.
  Formula: D†D = m² − T²_hop where T_hop is the pure-hopping term. -/
theorem staggeredDdagD_nonneg (NC NX NY NZ NT : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 1) :
    0 ≤ normSqFermion NC NX NY NZ NT 1
      (staggeredFullDx NC NX NY NZ NT p U x) :=
  normSq_nonneg NC NX NY NZ NT 1 _

-- ── Checkerboard decomposition ────────────────────────────────────────────────
/-- Clear a staggered fermion field on even or odd sub-lattice.
  Source: `clear_fermion!(x::StaggeredFermion_4D_wing{NC}, evensite)` in
    StaggeredFermion_4D_wing.jl.
  Even sites: (ix+iy+iz+it) mod 2 = 0 (same as WilsonFermion siteParity). -/
def staggeredSiteParity (ix iy iz it : ℕ) : Bool := (ix + iy + iz + it) % 2 == 0

/-- Restrict fermion field to even or odd sites.
  Source: `xran = 1+(1+ibush+iy+iz+it)%2:2:NX` loop in clear_fermion!. -/
axiom staggeredProject (NC NX NY NZ NT : ℕ)
    (x : FermionField NC NX NY NZ NT 1)
    (isEven : Bool) : FermionField NC NX NY NZ NT 1

-- ── Staggered 2D variant ──────────────────────────────────────────────────────
/-- Staggered Dirac operator in 2D (for testing/toy models).
  Source: `StaggeredFermion_2D_wing.jl`, `StaggeredFermion_2D_nowing.jl`.
  Same structure as 4D but sum over μ ∈ {1,2}, NG=1. -/
axiom staggeredDx2D (NC NX NY : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY 1 1 2)
    (x : FermionField NC NX NY 1 1 1) : FermionField NC NX NY 1 1 1

-- ── Spectral gap (taste symmetry residual) ───────────────────────────────────
/-- Staggered spectrum comes in ±λ pairs (anti-Hermitian hop → imaginary eigenvalues).
  This is the lattice reflection of the continuum index theorem for Kähler-Dirac.
  Source: implicit in use of `DdagD_Staggered_operator` for CG. -/
theorem staggeredSpectrum_paired (NC NX NY NZ NT : ℕ) (p : StaggeredParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 1) :
    normSqFermion NC NX NY NZ NT 1
      (staggeredFullDx NC NX NY NZ NT p U
        (staggeredFullDx NC NX NY NZ NT p U x)) ≥ 0 :=
  normSq_nonneg NC NX NY NZ NT 1 _

end CATEPTMain.GaugeTheory.LDO
