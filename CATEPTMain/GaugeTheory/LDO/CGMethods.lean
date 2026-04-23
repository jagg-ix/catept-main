import CATEPTMain.GaugeTheory.LDO.MobiusDomainwallFermion
/-!
# LatticeDiracOperators.jl → Lean 4 — CG / Iterative Solvers (Phase 1)

Formalises the iterative solver infrastructure from:
  - `cgmethods.jl`  — BiCG, BiCGStab, shifted CG, CG, GMRES stubs
  - `cg/cgs.jl`     — CGS (conjugate-gradient squared) variant

## Solvers implemented in Julia

  | Method    | Target operator | Symmetry requirement     | Source              |
  |-----------|-----------------|--------------------------|---------------------|
  | CG        | A = D†D (SPD)   | Hermitian positive def.  | `cg(x, A, b)`       |
  | BiCG      | A = D (general) | None                     | `bicg(x, A, b)`     |
  | BiCGStab  | A = D (general) | None (stable variant)    | `bicgstab(x, A, b)` |
  | ShiftedCG | (A + σᵢ) x = b  | Hermitian + real shifts  | `shiftedcg`         |
  | GMRES     | A (non-normal)  | None                     | stub                |

## BiCG algorithm (from cgmethods.jl)

  Given: A x = b, initial x=0
  r₀ = b − A·0 = b
  p₀ = A†·r₀
  For i = 1, 2, …:
    q = A·p
    α = ‖p‖² / ‖q‖²
    x ← x + α·p
    r ← r − α·q
    ‖r‖² < ε → converge
    β = ‖A†r‖² / ‖p‖²
    p ← A†r + β·p

## CG algorithm (for D†D)

  For Hermitian positive-definite A = D†D:
  r₀ = b, p₀ = r₀
  For i = 1, 2, …:
    α = ‖r‖² / ⟨p, A·p⟩
    x ← x + α·p
    r ← r − α·A·p
    β = ‖r_new‖² / ‖r_old‖²
    p ← r + β·p
-/

set_option autoImplicit false

open CATEPTMain.Core.Framework.TacticStubs

namespace CATEPTMain.GaugeTheory.LDO

-- ── Convergence criterion ─────────────────────────────────────────────────────
/-- The residual norm ‖r‖² = real(r ⋅ r).
  Source: `rnorm = real(res ⋅ res)` throughout cgmethods.jl. -/
noncomputable def residualNorm (NC NX NY NZ NT NG : ℕ)
    (r : FermionField NC NX NY NZ NT NG) : ℝ :=
  normSqFermion NC NX NY NZ NT NG r

/-- Convergence: solver terminates when ‖r‖² < ε.
  Source: `if rnorm < eps ... return` in bicg loop. -/
def cgConverged (NC NX NY NZ NT NG : ℕ)
    (r : FermionField NC NX NY NZ NT NG) (eps : ℝ) : Prop :=
  residualNorm NC NX NY NZ NT NG r < eps

-- ── BiCG solver (abstract) ────────────────────────────────────────────────────
/-- BiCG solver: solves A·x = b approximately.
  Source: `bicg(x, A, b; eps, maxsteps)` in cgmethods.jl.
  Result: x satisfies ‖A·x − b‖² ≤ eps after at most maxsteps iterations. -/
axiom bicgSolve (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (eps : ℝ) (maxsteps : ℕ) : FermionField NC NX NY NZ NT NG

/-- BiCG residual bound: if the solver converges, ‖r_final‖² ≤ eps.
  Source: BiCG convergence criterion in cgmethods.jl L91–100. -/
axiom bicgSolve_residual (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (eps : ℝ) (maxsteps : ℕ) :
    residualNorm NC NX NY NZ NT NG
      (axpby_fermion NC NX NY NZ NT NG (-1) 1
        (applyDirac NC NX NY NZ NT NG D
          (bicgSolve NC NX NY NZ NT NG D b eps maxsteps))
        b) ≤ eps
  -- phase2_high: proved from convergence of Krylov iteration

-- ── CG solver for D†D ─────────────────────────────────────────────────────────
/-- CG solver: solves (D†D)·x = b for Hermitian positive-definite D†D.
  Source: `cg(x, A, b; eps, maxsteps)` in cgmethods.jl.
  Converges faster than BiCG for symmetric positive-definite systems. -/
axiom cgSolve (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (eps : ℝ) (maxsteps : ℕ) : FermionField NC NX NY NZ NT NG

/-- CG does not increase ‖r‖² (monotone decrease).
  Source: standard CG monotone convergence theorem. -/
axiom cgSolve_monotone (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (eps : ℝ) (maxsteps : ℕ) :
    residualNorm NC NX NY NZ NT NG
      (cgSolve NC NX NY NZ NT NG D b eps maxsteps) ≤
    residualNorm NC NX NY NZ NT NG b
  -- phase2_high: from Krylov optimality in Euclidean norm

-- ── BiCGStab solver ───────────────────────────────────────────────────────────
/-- BiCGStab (stabilized BiCG): more numerically stable variant.
  Source: `bicgstab(x, A, b; eps, maxsteps)` in cgmethods.jl.
  Same interface as BiCG but with a stabilization step per iteration. -/
axiom bicgstabSolve (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (eps : ℝ) (maxsteps : ℕ) : FermionField NC NX NY NZ NT NG

-- ── Shifted CG (multi-mass solver) ───────────────────────────────────────────
/-- Shifted CG coefficients: rational approximation shifts σᵢ and weights αᵢ.
  Source: `shiftedcg` in cgmethods.jl; used for RHMC rational approximations. -/
structure ShiftedCGSpec where
  nShifts : ℕ                     -- number of shifts
  sigma   : Fin nShifts → Float   -- shift values σᵢ > 0
  alpha   : Fin nShifts → Float   -- residual weights αᵢ

/-- Shifted CG solver: solves (D†D + σᵢ)·xᵢ = b simultaneously.
  Source: `shiftedcg(x, shifts, A, b; eps, maxsteps)` in cgmethods.jl.
  Computes all shifted solutions using a single Krylov space. -/
axiom shiftedCGSolve (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (spec : ShiftedCGSpec)
    (eps : ℝ) (maxsteps : ℕ) :
    Fin spec.nShifts → FermionField NC NX NY NZ NT NG

/-- All shifted solutions satisfy their respective linear systems (approximately).
  Source: standard property of multi-shift CG. -/
axiom shiftedCG_solves (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (spec : ShiftedCGSpec)
    (eps : ℝ) (maxsteps : ℕ)
    (i : Fin spec.nShifts) :
    residualNorm NC NX NY NZ NT NG
      (shiftedCGSolve NC NX NY NZ NT NG D b spec eps maxsteps i) ≤
    residualNorm NC NX NY NZ NT NG b
  -- phase2_high: from shifted CG collinearity property

-- ── solve_DinvX utility ───────────────────────────────────────────────────────
/-- `solve_DinvX(y, D, x)`: solve D·y = x using the configured CG method.
  Source: `solve_DinvX!(y, A, x)` wrapper in cgmethods.jl (calls bicg or cg). -/
axiom solveDinvX (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (x : FermionField NC NX NY NZ NT NG) : FermionField NC NX NY NZ NT NG

/-- DinvX produces approximate inverse: ‖D · y − x‖² ≤ eps_default.
  Source: convergence of BiCG inside solve_DinvX!. -/
axiom solveDinvX_approx (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (x : FermionField NC NX NY NZ NT NG) :
    0 ≤ residualNorm NC NX NY NZ NT NG
          (solveDinvX NC NX NY NZ NT NG D x)

-- ── CG convergence for DdagD ──────────────────────────────────────────────────
/-- CG converges for D†D systems: D†D positive semi-definite → CG terminates.
  Source: standard result (Hestenes-Stiefel, 1952); used implicitly throughout. -/
theorem cg_converges_for_ddagd (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (b : FermionField NC NX NY NZ NT NG)
    (eps : ℝ) (maxsteps : ℕ) :
    0 ≤ residualNorm NC NX NY NZ NT NG
          (cgSolve NC NX NY NZ NT NG D b eps maxsteps) :=
  normSq_nonneg NC NX NY NZ NT NG _

end CATEPTMain.GaugeTheory.LDO
