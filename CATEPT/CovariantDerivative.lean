import NavierStokesClean.CATEPT.GRTensorKernel

/-!
# CAT/EPT GR: Covariant Derivative and Geodesics (WP-GR-COVD-01)

Phase B of the multi-tool → IR → Lean pipeline.

Builds on `GRTensorKernel` (Christoffel/Riemann/Einstein definitions) to add:

- coordinate covariant derivative of a vector field: ∇_k V^i = ∂_k V^i + Γ^i_{kj} V^j
- geodesic forcing term: Γ^i_{jk} ẋ^j ẋ^k
- parallel transport predicate along a curve

## Main results (0 axioms, 0 sorry)

- `covariantDerivVector_eq_partial_of_christoffel_zero`: cov. deriv = partial when Γ = 0
- `covariantDerivVector_minkowski_eq_partial`: Minkowski specialization
- `geodesicForce_minkowski_eq_zero`: straight lines are geodesics in Minkowski
- `covariantDerivVector_minkowski_const_eq_zero`: constant fields are parallel in Minkowski
- `const_isParallelAlong_minkowski`: constant fields are parallel along any curve in Minkowski

## Zero axioms, zero sorry.
-/

set_option autoImplicit false

open BigOperators

namespace NavierStokesClean.CATEPT

noncomputable section

variable {n : Type*} [Fintype n] [DecidableEq n]

/-! ## §1. Covariant derivative of a vector field -/

/-- Covariant derivative of a vector field `V^i` in direction `k`:
      ∇_k V^i = ∂_k V^i + Γ^i_{kj} V^j

    This is the coordinate formula for the Levi-Civita connection acting
    on a contravariant vector field. The connection term Γ^i_{kj} V^j
    corrects for the rotation of basis vectors along direction k. -/
def covariantDerivVector (g : MetricField n) (V : CoordVec n → n → ℝ)
    (k i : n) (x : CoordVec n) : ℝ :=
  partialDeriv (fun y => V y i) k x + ∑ j : n, christoffel g x i k j * V x j

/-! ## §2. Key simplification theorems -/

/-- Covariant derivative equals partial derivative when Christoffel symbols vanish. -/
theorem covariantDerivVector_eq_partial_of_christoffel_zero
    {g : MetricField n} {V : CoordVec n → n → ℝ} (k i : n) (x : CoordVec n)
    (hGamma : ∀ (y : CoordVec n) (a b c : n), christoffel g y a b c = 0) :
    covariantDerivVector g V k i x = partialDeriv (fun y => V y i) k x := by
  simp [covariantDerivVector, hGamma x]

/-- For Minkowski metric, covariant derivative equals partial derivative. -/
theorem covariantDerivVector_minkowski_eq_partial
    (V : CoordVec (Fin 4) → Fin 4 → ℝ) (k i : Fin 4) (x : CoordVec (Fin 4)) :
    covariantDerivVector minkowskiMetric V k i x = partialDeriv (fun y => V y i) k x :=
  covariantDerivVector_eq_partial_of_christoffel_zero k i x christoffel_eq_zero_minkowski

/-- Covariant derivative of a constant vector field vanishes in Minkowski spacetime. -/
theorem covariantDerivVector_minkowski_const_eq_zero
    (v : Fin 4 → ℝ) (k i : Fin 4) (x : CoordVec (Fin 4)) :
    covariantDerivVector minkowskiMetric (fun _ => v) k i x = 0 := by
  have h1 : partialDeriv (fun y => v i) k x = 0 :=
    partialDeriv_eq_zero_of_const (k := k) (x := x) ⟨v i, fun _ => rfl⟩
  have h2 : ∑ j : Fin 4, christoffel minkowskiMetric x i k j * v j = 0 := by
    simp [christoffel_eq_zero_minkowski]
  simp [covariantDerivVector, h1, h2]

/-! ## §3. Geodesic forcing term -/

/-- Geodesic forcing: Γ^i_{jk} ẋ^j ẋ^k — the inertial acceleration of free-fall.

    The geodesic equation is ẍ^i + geodesicForce g ẋ i x = 0. -/
def geodesicForce (g : MetricField n) (vel : CoordVec n) (i : n) (x : CoordVec n) : ℝ :=
  ∑ j : n, ∑ k : n, christoffel g x i j k * vel j * vel k

/-- In Minkowski spacetime, the geodesic force vanishes.
    Inertial observers travel in straight lines. -/
theorem geodesicForce_minkowski_eq_zero
    (vel : CoordVec (Fin 4)) (i : Fin 4) (x : CoordVec (Fin 4)) :
    geodesicForce minkowskiMetric vel i x = 0 := by
  simp [geodesicForce, christoffel_eq_zero_minkowski]

/-- Geodesic force vanishes when all Christoffel symbols vanish. -/
theorem geodesicForce_eq_zero_of_christoffel_zero
    {g : MetricField n} (vel : CoordVec n) (i : n) (x : CoordVec n)
    (hGamma : ∀ (y : CoordVec n) (a b c : n), christoffel g y a b c = 0) :
    geodesicForce g vel i x = 0 := by
  simp [geodesicForce, hGamma x]

/-- Geodesic force vanishes for any constant metric. -/
theorem geodesicForce_eq_zero_of_metricComponentConst
    {g : MetricField n} (vel : CoordVec n) (i : n) (x : CoordVec n)
    (hconst : MetricComponentConst g) :
    geodesicForce g vel i x = 0 :=
  geodesicForce_eq_zero_of_christoffel_zero vel i x
    (christoffel_eq_zero_of_metricComponentConst (hconst := hconst))

/-! ## §4. Parallel transport predicate -/

/-- A vector field `V` is parallel along a curve `γ` if contracting the
    covariant derivative with the tangent vector vanishes:
      ∑_k γ̇^k ∇_k V^i = 0  (for all τ, all i)

    This is the standard definition of parallel transport along γ. -/
def IsParallelAlong (g : MetricField n) (γ : ℝ → CoordVec n)
    (V : CoordVec n → n → ℝ) : Prop :=
  ∀ (τ : ℝ) (i : n),
    ∑ k : n, deriv (fun s => γ s k) τ * covariantDerivVector g V k i (γ τ) = 0

/-- Constant vector fields are parallel in Minkowski spacetime along any curve. -/
theorem const_isParallelAlong_minkowski
    (γ : ℝ → CoordVec (Fin 4)) (v : Fin 4 → ℝ) :
    IsParallelAlong minkowskiMetric γ (fun _ => v) := by
  intro τ i
  simp [covariantDerivVector_minkowski_const_eq_zero v _ i (γ τ)]

end

end NavierStokesClean.CATEPT
