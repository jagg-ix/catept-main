import CATEPTMain.AFPBridge.LDO.AbstractFermions
/-!
# LatticeDiracOperators.jl → Lean 4 — Wilson Fermion (Phase 1)

Formalises the Wilson fermion sector from:
  - `WilsonFermion/WilsonFermion.jl`          — abstract Wilson type + struct
  - `WilsonFermion/WilsonFermion_4D.jl`       — 4D hopping kernel (Wx!, Dx!, Ddagx!, etc.)
  - `WilsonFermion/WilsonFermion_4D_wing.jl`  — concrete `WilsonFermion_4D_wing{NC,NDW}`
  - `WilsonFermion/WilsonFermion_4D_nowing.jl`— no-halo variant
  - `WilsonFermion/WilsonFermion_faster.jl`   — fused kernel variant
  - `WilsonFermion/WilsoncloverFermion.jl`    — clover improvement
  - `WilsonFermion/WilsonFermion_improved.jl` — improved (Sheikholeslami-Wohlert) variant
  - `WilsonFermion/WilsonFermion_4D_wing_Adjoint.jl` — adjoint application

## Wilson Dirac operator (Euclidean, +−−− → δ_{μν} in Euclidean)

  (D_W ψ)(x) = ψ(x) − κ ∑_{μ=1}^{4}
    [ (1 − γ_μ)_{αβ} U_μ(x)_{ab} ψ_β^b(x+μ̂)
    + (1 + γ_μ)_{αβ} U†_μ(x−μ̂)_{ab} ψ_β^b(x−μ̂) ]

  where κ = 1/(2*Dim*r + 2*M) is the hopping parameter (Dim=4, r=1 typical).
  The Wilson term adds −κ r ∑_μ [ψ(x+μ̂) − 2ψ(x) + ψ(x−μ̂)] to remove doublers.

## γ5-Hermiticity

  D† = γ5 D γ5   (fundamental property; used to construct H = γ5 D)

## Clover improvement (Wilson-Clover, Sheikholeslami-Wohlert)

  D_clover = D_W + c_sw/4 ∑_{μ<ν} σ_{μν} F_{μν}(x)

  Source: `WilsoncloverFermion.jl`, `clover_data.jl`
-/

set_option autoImplicit false

open CATEPTMain.AFPBridgeFramework.TacticStubs

namespace CATEPTMain.AFPBridge.LDO

-- ── Wilson fermion parameters ────────────────────────────────────────────────
/-- Wilson fermion operator parameters.
  Source: fields of `Wilson_Dirac_operator` struct in WilsonFermion.jl. -/
structure WilsonParams where
  κ   : Float   -- hopping parameter
  r   : Float   -- Wilson term (default 1)
  bc  : BoundaryCondition 4  -- boundary conditions per direction
  hasClov : Bool  -- whether clover improvement is active
  cSW : Float   -- Sheikholeslami-Wohlert coefficient (if hasClov)

/-- Standard critical hopping parameter relation (massless limit):
    κ_c = 1 / (2 * Dim * r + 2 * M).
  Source: `κ_wilson = 1 / (2 * Dim * r + 2M)` in DomainwallFermion.jl. -/
def wilsonKappaFromM (Dim r M : Float) : Float := 1.0 / (2.0 * r * Dim + 2.0 * M)

-- ── Hopping half-projectors ──────────────────────────────────────────────────
-- Source: `rplusγ` and `rminusγ` arrays in Wilson_Dirac_operator struct.
--   rplusγ[α,β,μ]  = r*δ_{αβ} + (γ_μ)_{αβ}   (forward hopping projector)
--   rminusγ[α,β,μ] = r*δ_{αβ} - (γ_μ)_{αβ}   (backward hopping projector)

/-- Forward half-projector (1 + γ_μ)/2 or (r + γ_μ) depending on normalisation.
  Source: `rplusγ::Array{ComplexF64,3}` of shape (NG,NG,Dim). -/
axiom rPlusGamma  (r : Float) (μ : EuclidIdx) (α β : Fin 4) : ℂ
axiom rMinusGamma (r : Float) (μ : EuclidIdx) (α β : Fin 4) : ℂ

/-- Gamma-5 hermiticity property of hopping projectors:
    (1 − γ_μ)† = (1 + γ_μ) for Euclidean γ_μ (anti-Hermitian).
  This is the algebraic core of D† = γ5 D γ5.
  Source: implicit in WilsonFermion_4D_wing_Adjoint.jl. -/
axiom rPlusGamma_adjoint_eq_rMinus (r : Float) (μ : EuclidIdx) (α β : Fin 4) :
    star (rPlusGamma r μ α β) = rMinusGamma r μ β α  -- phase2_high

-- ── Wilson Dirac operator application ────────────────────────────────────────
/-- Wilson Dirac operator `D_W x` in 4D.
  Source: `Dx!(xout, U, x, A, 4)` called from `Dx!` in WilsonFermion_4D.jl.
  Implements:
    xout_α^a(x) = ∑_β x_β^a(x)
      − κ ∑_μ [ (r-γ_μ)_{αβ} U_μ(x)_{ab} x_β^b(x+μ̂)
               + (r+γ_μ)_{αβ} U†_μ(x-μ̂)_{ab} x_β^b(x-μ̂) ] -/
axiom wilsonDx (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4

/-- Adjoint Wilson operator `D†_W x`.
  Source: `Ddagx!(xout, U, x, A, 4)` in WilsonFermion_4D.jl. -/
axiom wilsonDdagx (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4

/-- Hopping-only part `T x` (the κ-dependent part): D = 1 - T.
  Source: `Tx!(xout, U, x, A, 4)` called from `Tx!` in WilsonFermion_4D.jl. -/
axiom wilsonTx (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4

/-- Decomposition D = 1 - T.
  Source: comment `W = (1 - T)x` in WilsonFermion_4D.jl. -/
axiom wilsonD_eq_one_minus_T (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) :
    wilsonDx NC NX NY NZ NT p U x =
    axpby_fermion NC NX NY NZ NT 4 1 (-1)
      x (wilsonTx NC NX NY NZ NT p U x)

-- ── γ5-Hermiticity ───────────────────────────────────────────────────────────
/-- Apply γ5 to a 4-spinor (acts on spin index only).
  Source: `apply_γ5!(F)` in AbstractFermions.jl.
  γ5 in Euclidean: diagonal matrix with entries (+1,+1,-1,-1). -/
axiom applyGamma5 (NC NX NY NZ NT : ℕ)
    (ψ : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4

/-- γ5 is involutive: γ5² = 1.
  Source: `(γ^5)² = 1` (Euclidean version of gamma5_sq_one). -/
axiom applyGamma5_sq (NC NX NY NZ NT : ℕ)
    (ψ : FermionField NC NX NY NZ NT 4) :
    applyGamma5 NC NX NY NZ NT (applyGamma5 NC NX NY NZ NT ψ) = ψ

/-- Structural axiom for γ5-Hermiticity of the Wilson Dirac operator.
  Physical basis:
    (D_W)_{x,y} = δ_{x,y} - κ Σ_μ [(1-γ_μ) U_μ(x) δ_{y,x+μ̂} + (1+γ_μ) U†_μ(y) δ_{y,x-μ̂}]
  Taking the adjoint: D†_W|_{x,y} = (D_W)†_{y,x} = (D_W)_{x,y} with μ → -μ, U ↔ U†
  Using γ5 γ_μ = -γ_μ γ5: γ5 (1±γ_μ) = (1∓γ_μ) γ5
  Hence D†_W = γ5 D_W γ5 component-wise.
  Phase-2: formal proof via Matrix.conjTranspose + rPlusGamma_adjoint_eq_rMinus. -/
axiom wilsonDdagx_eq_gamma5Dgamma5 (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) :
    wilsonDdagx NC NX NY NZ NT p U x =
    applyGamma5 NC NX NY NZ NT
      (wilsonDx NC NX NY NZ NT p U
        (applyGamma5 NC NX NY NZ NT x))

/-- **γ5-Hermiticity**: D†_W = γ5 D_W γ5.
  This is the fundamental property of Wilson fermions that ensures the
  eigenvalues of D_W come in complex conjugate pairs (Ginsparg-Wilson
  condition in the ultralocal limit).
  Source: `Ddagx!` = application of `γ5 Dx γ5`; see `γ5D_Wilson_operator`. -/
theorem wilson_gamma5_hermiticity (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) :
    wilsonDdagx NC NX NY NZ NT p U x =
    applyGamma5 NC NX NY NZ NT
      (wilsonDx NC NX NY NZ NT p U
        (applyGamma5 NC NX NY NZ NT x)) :=
  wilsonDdagx_eq_gamma5Dgamma5 NC NX NY NZ NT p U x

-- ── DdagD positivity ─────────────────────────────────────────────────────────
/-- DdagD = D†D is positive semi-definite: ‖Dx‖² ≥ 0.
  Source: Ensures CG convergence for DdagD_operator; see Diracoperators.jl. -/
theorem wilsonDdagD_nonneg (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) :
    0 ≤ normSqFermion NC NX NY NZ NT 4
      (wilsonDx NC NX NY NZ NT p U x) := by
  exact normSq_nonneg NC NX NY NZ NT 4 _

-- ── Even-odd decomposition ───────────────────────────────────────────────────
/-- Checkerboard (even-odd) preconditioning site parity.
    parity(x,y,z,t) = (x+y+z+t) mod 2.
  Source: `iseven::Bool` flag in Toex!, calc_beff!, etc. in WilsonFermion_4D.jl. -/
def siteParity (ix iy iz it : ℕ) : Bool := (ix + iy + iz + it) % 2 == 0

/-- T_{oe} (odd→even off-diagonal hopping block).
  Source: `Toex!(xout, U, x, A, isodd)` in WilsonFermion_4D.jl. -/
axiom wilsonToex (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4)
    (isEven : Bool) : FermionField NC NX NY NZ NT 4

/-- Effective RHS for even-odd preconditioned solve: b_eff = b_e + κ T_{oe} b_o.
  Source: `calc_beff!(xout, U, x, A)` in WilsonFermion_4D.jl:
    temp = Toex(x, odd)
    xout = x + temp (even part). -/
axiom wilsonBeff (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (b : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4

-- ── Clover (Wilson-Sheikholeslami-Wohlert) term ───────────────────────────────
/-- Clover (field strength) contribution to the Dirac operator.
  Source: `WilsoncloverFermion.jl` and `clover_data.jl`.
  D_clover = D_W + c_SW/4 ∑_{μ<ν} σ_{μν} F_{μν}.
  The clover term corrects O(a) discretisation errors. -/
axiom wilsonCloverTerm (NC NX NY NZ NT : ℕ) (cSW : Float)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4

/-- Wilson-Clover operator = Wilson + Clover term.
  Source: `has_cloverterm(D) = true` branch in Dirac_operator constructor. -/
noncomputable def wilsonCloverDx (NC NX NY NZ NT : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY NZ NT 4)
    (x : FermionField NC NX NY NZ NT 4) : FermionField NC NX NY NZ NT 4 :=
  axpby_fermion NC NX NY NZ NT 4 1 1
    (wilsonDx NC NX NY NZ NT p U x)
    (wilsonCloverTerm NC NX NY NZ NT p.cSW U x)

-- ── 2D Wilson fermion ─────────────────────────────────────────────────────────
/-- Wilson Dirac operator in 2D (for testing/toy models).
  Source: `WilsonFermion_2D.jl`, `WilsonFermion_2D_wing.jl`.
  Same structure as 4D but sum over μ ∈ {1,2}. -/
axiom wilsonDx2D (NC NX NY : ℕ) (p : WilsonParams)
    (U : GaugeField NC NX NY 1 1 2)
    (x : FermionField NC NX NY 1 1 4) : FermionField NC NX NY 1 1 4

end CATEPTMain.AFPBridge.LDO
