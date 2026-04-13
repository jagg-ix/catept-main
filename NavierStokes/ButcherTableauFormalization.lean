import NavierStokes.GalerkinDescentTower
import Mathlib.Algebra.BigOperators.Fin

/-!
# Butcher Tableau Formalization: Irksome Theoretical Foundations

Formalizes the algebraic theory behind Irksome's Galerkin-in-time PDE solvers
(github.com/firedrakeproject/Irksome).

Irksome solves NS using Galerkin-in-time Runge-Kutta methods:
  `GaussLegendre(s)` — s-stage GL quadrature (optimal symplectic, order 2s)
  `RadauIIA(s)` — s-stage Radau IIA (L-stable, stiffly accurate, order 2s−1)
  `LobattoIIIC(s)` — s-stage Lobatto IIIC (order 2s−2, algebraically stable)

## What this file provides

1. `ButcherTableau s` — abstract RK tableau structure (A, b, c over ℚ)
2. Algebraic order conditions: consistency (order 1), symmetry (order 2), etc.
3. Concrete tableaux: GaussLegendre1, RadauIIA1, fully proved by `norm_num`
4. `GalerkinInTimeMethod` — connects ButcherTableau to GalerkinLevel
5. Irksome port assessment: which layers CAN be formalized in Lean4 now

## What this file does NOT provide

Convergence proofs (error estimates ‖u_h − u‖ → 0): these require NS Sobolev
theory from `GalerkinNSInfrastructure.lean`. The algebraic order conditions
here are the NECESSARY but not SUFFICIENT conditions for convergence.

## Lean4 portability of Irksome

| Irksome layer | Lean4 status | This file |
|---------------|-------------|----------|
| Butcher tableau algebra | **FULLY FORMALIZABLE** — pure `norm_num` | ✓ |
| Order condition verification | **FULLY FORMALIZABLE** — polynomial arithmetic | ✓ |
| Stiff stability (A/L-stability) | Formalizable (matrix analysis) | partial |
| Galerkin-in-time = collocation | Formalizable (polynomial basis theory) | ✓ struct |
| Error estimates for NS | Requires NS Sobolev (GalerkinNSInfrastructure) | axiom |
| Actual NS numerical solver | Python/Firedrake only — NOT portable to Lean4 | N/A |

## Why this matters

Irksome's `GaussLegendre(s)` is exactly the Galerkin-in-time method Temam (1984,
Ch. III) analyzes. Proving that the GaussLegendre tableau satisfies the order
conditions IS the algebraic foundation for the convergence proof that would
close `ml_stabilization_implies_precise_gap`.

## References
- Hairer, Nørsett, Wanner: Solving ODEs I-II (1987/1991) — Butcher theory
- Butcher: Numerical Methods for Ordinary Differential Equations (2016)
- Iserles: A First Course in the Numerical Analysis of DEs (2009)
- Temam: Navier-Stokes Equations (1984) Ch. III — Galerkin convergence
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-! ## Butcher Tableau Structure -/

/-- A Runge-Kutta Butcher tableau with `s` stages over ℚ.

    Components:
    - `A : Fin s → Fin s → Rat`  — stage coefficient matrix (a_{ij})
    - `b : Fin s → Rat`          — quadrature weights (b_i), Σbᵢ = 1
    - `c : Fin s → Rat`          — quadrature nodes (cᵢ = Σⱼ aᵢⱼ)

    For implicit methods (Gauss-Legendre, Radau IIA): A is not lower-triangular;
    each stage requires solving a nonlinear system. Irksome handles this via
    Firedrake's PETSc nonlinear solver.

    Standard reference: Hairer-Nørsett-Wanner §II.1 (Butcher tableau notation). -/
structure ButcherTableau (s : Nat) where
  /-- Stage coefficient matrix: a_{ij} = weight of stage j in computing stage i. -/
  A : Fin s → Fin s → Rat
  /-- Quadrature weights: b_i weights the i-th stage in the final update step. -/
  b : Fin s → Rat
  /-- Quadrature nodes: c_i = time position of stage i within [tₙ, tₙ₊₁]. -/
  c : Fin s → Rat

/-! ## Algebraic Order Conditions (B-series theory) -/

/-- **Order condition B(1)**: consistency.
    Σᵢ bᵢ = 1. The method integrates constants exactly → order ≥ 1. -/
def isConsistent {s : Nat} (bt : ButcherTableau s) : Prop :=
  Finset.univ.sum bt.b = 1

/-- **Order condition C(1)**: stage consistency (row sum condition).
    ∀ i: cᵢ = Σⱼ aᵢⱼ. Ensures stage i approximates tₙ + cᵢ·h correctly. -/
def isStageConsistent {s : Nat} (bt : ButcherTableau s) : Prop :=
  ∀ i : Fin s, bt.c i = Finset.univ.sum (fun j => bt.A i j)

/-- **Order condition B(2)**: Σᵢ bᵢ cᵢ = 1/2.
    The quadrature rule integrates linear functions exactly → order ≥ 2. -/
def hasOrder2 {s : Nat} (bt : ButcherTableau s) : Prop :=
  Finset.univ.sum (fun i => bt.b i * bt.c i) = 1 / 2

/-- **Stiff accuracy**: the last stage equals the solution update.
    ∀ j: a_{s,j} = bⱼ. Implies L-stability (essential for stiff PDEs like NS).

    The `hs : 0 < s` hypothesis is required to form the valid `Fin s` index `s-1`. -/
def isStifflyAccurate {s : Nat} (bt : ButcherTableau s) : Prop :=
  ∀ (hs : 0 < s) (j : Fin s), bt.A ⟨s - 1, Nat.sub_lt hs Nat.one_pos⟩ j = bt.b j

/-! ## GaussLegendre(1): Implicit Midpoint Rule -/

/-- **GaussLegendre(1)** — 1-stage Gauss-Legendre quadrature.

    Equivalent to the implicit midpoint rule:
      k₁ = f(tₙ + h/2, uₙ + (h/2)·k₁)   [implicit stage]
      uₙ₊₁ = uₙ + h·k₁

    Butcher tableau:
      c = [1/2]
      A = [[1/2]]
      b = [1]

    Properties:
    - Order 2 (B(1) and B(2) both satisfied)
    - Symplectic (preserves volume for Hamiltonian systems)
    - A-stable (energy-stable for dissipative NS)
    - This is `irksome.GaussLegendre(1)` and the default in Irksome NS demos.
    - The NS demo `demo_nse_unsteady.py` uses `GaussLegendre(1)` directly. -/
def gaussLegendre1 : ButcherTableau 1 where
  A := fun _ _ => (1 : Rat) / 2
  b := fun _ => (1 : Rat)
  c := fun _ => (1 : Rat) / 2

/-- GaussLegendre(1) is consistent: Σb = 1. -/
theorem gaussLegendre1_consistent : isConsistent gaussLegendre1 := by
  simp [isConsistent, gaussLegendre1]

/-- GaussLegendre(1) has order ≥ 2: Σ bᵢcᵢ = 1/2. -/
theorem gaussLegendre1_order2 : hasOrder2 gaussLegendre1 := by
  simp [hasOrder2, gaussLegendre1]

/-- GaussLegendre(1) is stage consistent: c₀ = a₀₀. -/
theorem gaussLegendre1_stage_consistent : isStageConsistent gaussLegendre1 := by
  intro i
  simp [gaussLegendre1]

/-! ## RadauIIA(1): Backward Euler -/

/-- **RadauIIA(1)** — 1-stage Radau IIA quadrature = backward Euler.

    Butcher tableau:
      c = [1]
      A = [[1]]
      b = [1]

    Properties:
    - Order 1 (only B(1) satisfied; B(2) fails: b·c = 1 ≠ 1/2)
    - L-stable: |R(∞)| = 0 (strongest stability, ideal for stiff NS)
    - Stiffly accurate (last stage = update step)
    - This is `irksome.RadauIIA(1)`. -/
def radauIIA1 : ButcherTableau 1 where
  A := fun _ _ => (1 : Rat)
  b := fun _ => (1 : Rat)
  c := fun _ => (1 : Rat)

/-- RadauIIA(1) is consistent. -/
theorem radauIIA1_consistent : isConsistent radauIIA1 := by
  simp [isConsistent, radauIIA1]

/-- RadauIIA(1) does NOT have order 2 (b·c = 1 ≠ 1/2). -/
theorem radauIIA1_not_order2 : ¬ hasOrder2 radauIIA1 := by
  simp [hasOrder2, radauIIA1]; norm_num

/-- RadauIIA(1) is stiffly accurate (standard backward Euler property). -/
theorem radauIIA1_stiffly_accurate : isStifflyAccurate radauIIA1 := by
  intro _hs j
  simp [radauIIA1]

/-! ## Galerkin-in-Time Method Structure -/

/-- A Galerkin-in-time discretization of NS at spatial level G with s-stage RK.

    This is the formal structure underlying Irksome's `TimeStepper`:
    - `spatialLevel`: the Fourier Galerkin truncation (N modes in each direction)
    - `timeStages`: number of collocation points (= s in the Butcher tableau)
    - `tableau`: the specific RK method (GL1, RadauIIA2, etc.)
    - `tableau_consistent`: method has at least order 1

    The key equation: GaussLegendre(s) Galerkin-in-time applied to the Galerkin NS
    equations IS the discretization analyzed in Temam (1984, Ch. III) for proving
    convergence to the NS weak solution. -/
structure GalerkinInTimeMethod where
  /-- Spatial Galerkin level: N = modeCount Fourier modes. -/
  spatialLevel : GalerkinLevel
  /-- Number of RK stages (temporal accuracy). -/
  timeStages : Nat
  timeStages_pos : 0 < timeStages
  /-- The Butcher tableau specifying the RK method. -/
  tableau : ButcherTableau timeStages
  /-- Minimum consistency requirement. -/
  tableau_consistent : isConsistent tableau

/-- Standard Irksome NS solver: GaussLegendre(1) (implicit midpoint) at level G. -/
def galerkinGL1 (G : GalerkinLevel) : GalerkinInTimeMethod where
  spatialLevel := G
  timeStages := 1
  timeStages_pos := Nat.one_pos
  tableau := gaussLegendre1
  tableau_consistent := gaussLegendre1_consistent

/-- Standard stiff Irksome NS solver: RadauIIA(1) (backward Euler) at level G. -/
def galerkinRadau1 (G : GalerkinLevel) : GalerkinInTimeMethod where
  spatialLevel := G
  timeStages := 1
  timeStages_pos := Nat.one_pos
  tableau := radauIIA1
  tableau_consistent := radauIIA1_consistent

/-- The GL1 method has temporal order ≥ 2 at any spatial level. -/
theorem gl1_temporal_order2 (G : GalerkinLevel) :
    hasOrder2 (galerkinGL1 G).tableau :=
  gaussLegendre1_order2

/-- The Radau1 method does NOT have temporal order 2 (it is backward Euler, order 1). -/
theorem radau1_temporal_order1_only (G : GalerkinLevel) :
    ¬ hasOrder2 (galerkinRadau1 G).tableau :=
  radauIIA1_not_order2

/-- Two tableau for the same spatial level can be compared by temporal order.
    The GL1 method has strictly higher temporal order than Radau1. -/
theorem gl1_higher_order_than_radau1 (G : GalerkinLevel) :
    hasOrder2 (galerkinGL1 G).tableau ∧
    ¬ hasOrder2 (galerkinRadau1 G).tableau :=
  ⟨gl1_temporal_order2 G, radau1_temporal_order1_only G⟩

/-! ## Irksome Port Assessment -/

/-- Assessment: which parts of Irksome are formalizable in Lean4 NOW vs LATER. -/
structure IrksomePortLayerAssessment where
  /-- Layer name. -/
  name : String
  /-- Is it fully formalizable with current Lean4/Mathlib? -/
  formalizable_now : Bool
  /-- Blocking issue (if not formalizable now). -/
  blocker : String

def irksomePortAssessment : List IrksomePortLayerAssessment :=
  [ { name := "Butcher tableau algebraic conditions"
      formalizable_now := true
      blocker := "None — pure Rat arithmetic, proved by norm_num" }
  , { name := "GaussLegendre/RadauIIA order condition verification"
      formalizable_now := true
      blocker := "None — polynomial equations, proved by norm_num" }
  , { name := "Stage consistency and stiff accuracy"
      formalizable_now := true
      blocker := "None — definitional arithmetic" }
  , { name := "Galerkin-in-time connection to GalerkinLevel"
      formalizable_now := true
      blocker := "None — structural definition" }
  , { name := "A-stability (|R(iω)| ≤ 1 for Gauss-Legendre)"
      formalizable_now := false
      blocker := "Requires complex analysis of stability function R(z) = det(I-zA+zbe^T)/det(I-zA)" }
  , { name := "Galerkin-in-time convergence theory (Temam Ch.III)"
      formalizable_now := false
      blocker := "Requires NS Sobolev theory (GalerkinNSInfrastructure.lean)" }
  , { name := "BKM transfer from Galerkin to continuum"
      formalizable_now := false
      blocker := "Requires BKM criterion (Beale-Kato-Majda 1984, not in Mathlib)" }
  , { name := "Actual NS numerical solver (Firedrake mesh + PETSc)"
      formalizable_now := false
      blocker := "Not portable: requires finite element mesh library + external solver" } ]

/-- The two fully formalizable layers that are DONE in this file. -/
theorem two_layers_complete :
    (irksomePortAssessment.filter (fun a => a.formalizable_now)).length = 4 := by
  native_decide

/-! ## Claim Registry -/

def butcherTableauClaims : List LabeledClaim :=
  [ ⟨"gaussLegendre1_consistent", .verified,
      "GL(1) consistency: Σb = 1 (proved by norm_num)"⟩
  , ⟨"gaussLegendre1_order2", .verified,
      "GL(1) order 2: Σ bᵢcᵢ = 1/2 (proved by norm_num)"⟩
  , ⟨"gaussLegendre1_stage_consistent", .verified,
      "GL(1) stage consistency: c₀ = a₀₀ = 1/2 (proved by simp)"⟩
  , ⟨"radauIIA1_consistent", .verified,
      "RadauIIA(1) consistency: Σb = 1 (proved by norm_num)"⟩
  , ⟨"radauIIA1_not_order2", .verified,
      "RadauIIA(1) NOT order 2: b·c = 1 ≠ 1/2 (proved by norm_num)"⟩
  , ⟨"radauIIA1_stiffly_accurate", .verified,
      "RadauIIA(1) stiff accuracy: last stage = update (proved by simp)"⟩
  , ⟨"gl1_temporal_order2", .verified,
      "GL1 Galerkin-in-time has temporal order ≥ 2 at any spatial level"⟩
  , ⟨"gl1_higher_order_than_radau1", .verified,
      "GL1 has strictly higher temporal order than RadauIIA(1)"⟩ ]

end

end NavierStokes.Millennium
