import Mathlib.Analysis.Calculus.Deriv.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.LinearAlgebra.Matrix.NonsingularInverse

/-!
# CAT/EPT GR Tensor Kernel (WP-GR-TENSOR-01)

Coordinate-level tensor kernel for a concrete GR start in Lean:

- coordinate partial derivative along basis directions
- Christoffel symbols
- Riemann curvature tensor
- Ricci tensor and scalar curvature
- Einstein tensor

This first milestone proves the non-vacuous baseline chain:
constant metric components -> zero Christoffel -> zero Riemann -> zero Ricci/scalar -> zero Einstein.

It also provides a concrete Minkowski specialization in 4D.
-/

set_option autoImplicit false

open BigOperators

namespace NavierStokesClean.CATEPT

noncomputable section

abbrev CoordVec (n : Type*) : Type _ := n -> ℝ
abbrev MetricField (n : Type*) : Type _ := CoordVec n -> Matrix n n ℝ

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- Partial derivative in direction `k` via line restriction `t |-> x[k:=t]`. -/
def partialDeriv (f : CoordVec n -> ℝ) (k : n) (x : CoordVec n) : ℝ :=
  deriv (fun t => f (Function.update x k t)) (x k)

/-- Coordinate metric component function `g_ij(x)`. -/
def metricComponent (g : MetricField n) (i j : n) : CoordVec n -> ℝ :=
  fun x => g x i j

/-- Coordinate partial derivative of metric component. -/
def partialMetricComponent (g : MetricField n) (i j k : n) (x : CoordVec n) : ℝ :=
  partialDeriv (metricComponent g i j) k x

/-- Inverse metric matrix field. -/
def inverseMetric (g : MetricField n) (x : CoordVec n) : Matrix n n ℝ :=
  (g x)⁻¹

/-- Christoffel symbol `Gamma^i_{jk}` from metric components. -/
def christoffel (g : MetricField n) (x : CoordVec n) (i j k : n) : ℝ :=
  (1 / 2 : ℝ) *
    ∑ l : n,
      inverseMetric g x i l *
        (partialMetricComponent g l k j x +
          partialMetricComponent g l j k x -
          partialMetricComponent g j k l x)

/-- Riemann tensor `R^i_{jkl}` from Christoffel symbols. -/
def riemann (g : MetricField n) (x : CoordVec n) (i j k l : n) : ℝ :=
  partialDeriv (fun y => christoffel g y i j l) k x -
    partialDeriv (fun y => christoffel g y i j k) l x +
    ∑ m : n,
      (christoffel g x i k m * christoffel g x m j l -
        christoffel g x i l m * christoffel g x m j k)

/-- Ricci tensor `R_jl = R^i_{jil}`. -/
def ricci (g : MetricField n) (x : CoordVec n) (j l : n) : ℝ :=
  ∑ i : n, riemann g x i j i l

/-- Scalar curvature `R = g^ij R_ij`. -/
def scalarCurvature (g : MetricField n) (x : CoordVec n) : ℝ :=
  ∑ i : n, ∑ j : n, inverseMetric g x i j * ricci g x i j

/-- Einstein tensor `G_ij = R_ij - (1/2) R g_ij`. -/
def einsteinTensor (g : MetricField n) (x : CoordVec n) (i j : n) : ℝ :=
  ricci g x i j - (1 / 2 : ℝ) * scalarCurvature g x * g x i j

/-- Componentwise constancy of metric entries in coordinates. -/
def MetricComponentConst (g : MetricField n) : Prop :=
  ∀ i j : n, ∃ c : ℝ, ∀ x : CoordVec n, metricComponent g i j x = c

/-- Directional partial derivative vanishes for constant coordinate functions. -/
theorem partialDeriv_eq_zero_of_const
    {f : CoordVec n -> ℝ}
    (k : n) (x : CoordVec n)
    (hconst : ∃ c : ℝ, ∀ y : CoordVec n, f y = c) :
    partialDeriv f k x = 0 := by
  rcases hconst with ⟨c, hc⟩
  unfold partialDeriv
  have hline : (fun t => f (Function.update x k t)) = fun _ => c := by
    funext t
    simpa using hc (Function.update x k t)
  rw [hline]
  simp

/-- Metric-component partial derivatives vanish under componentwise constancy. -/
theorem partialMetricComponent_eq_zero_of_metricComponentConst
    {g : MetricField n}
    (hconst : MetricComponentConst g) :
    ∀ (i j k : n) (x : CoordVec n), partialMetricComponent g i j k x = 0 := by
  intro i j k x
  unfold partialMetricComponent metricComponent
  exact partialDeriv_eq_zero_of_const (k := k) (x := x) (hconst i j)

/-- Christoffel symbols vanish for metrics with constant coordinate components. -/
theorem christoffel_eq_zero_of_metricComponentConst
    {g : MetricField n}
    (hconst : MetricComponentConst g) :
    ∀ (x : CoordVec n) (i j k : n), christoffel g x i j k = 0 := by
  intro x i j k
  unfold christoffel
  simp [partialMetricComponent_eq_zero_of_metricComponentConst (hconst := hconst)]

/-- Riemann tensor vanishes when Christoffels vanish identically. -/
theorem riemann_eq_zero_of_christoffel_eq_zero
    {g : MetricField n}
    (hGamma : ∀ (x : CoordVec n) (i j k : n), christoffel g x i j k = 0) :
    ∀ (x : CoordVec n) (i j k l : n), riemann g x i j k l = 0 := by
  intro x i j k l
  unfold riemann
  have hk : partialDeriv (fun y => christoffel g y i j l) k x = 0 := by
    apply partialDeriv_eq_zero_of_const (k := k) (x := x)
    refine ⟨0, ?_⟩
    intro y
    simpa using hGamma y i j l
  have hl : partialDeriv (fun y => christoffel g y i j k) l x = 0 := by
    apply partialDeriv_eq_zero_of_const (k := l) (x := x)
    refine ⟨0, ?_⟩
    intro y
    simpa using hGamma y i j k
  rw [hk, hl]
  simp [hGamma x]

/-- Ricci tensor vanishes when Riemann tensor vanishes identically. -/
theorem ricci_eq_zero_of_riemann_eq_zero
    {g : MetricField n}
    (hR : ∀ (x : CoordVec n) (i j k l : n), riemann g x i j k l = 0) :
    ∀ (x : CoordVec n) (j l : n), ricci g x j l = 0 := by
  intro x j l
  unfold ricci
  simp [hR x]

/-- Scalar curvature vanishes when Ricci tensor vanishes identically. -/
theorem scalarCurvature_eq_zero_of_ricci_eq_zero
    {g : MetricField n}
    (hRic : ∀ (x : CoordVec n) (i j : n), ricci g x i j = 0) :
    ∀ x, scalarCurvature g x = 0 := by
  intro x
  unfold scalarCurvature
  simp [hRic x]

/-- Einstein tensor vanishes when Ricci and scalar curvature vanish. -/
theorem einsteinTensor_eq_zero_of_ricci_scalar_zero
    {g : MetricField n}
    (hRic : ∀ (x : CoordVec n) (i j : n), ricci g x i j = 0)
    (hSc : ∀ x, scalarCurvature g x = 0) :
    ∀ (x : CoordVec n) (i j : n), einsteinTensor g x i j = 0 := by
  intro x i j
  unfold einsteinTensor
  simp [hRic x i j, hSc x]

/-- Constant metric field from a fixed matrix. -/
def constantMetric (A : Matrix n n ℝ) : MetricField n :=
  fun _ => A

/-- Fixed matrix metric is componentwise constant. -/
theorem metricComponentConst_constantMetric (A : Matrix n n ℝ) :
    MetricComponentConst (constantMetric A) := by
  intro i j
  refine ⟨A i j, ?_⟩
  intro x
  rfl

/-- Einstein tensor vanishes for any constant metric field. -/
theorem einsteinTensor_eq_zero_of_metricComponentConst
    {g : MetricField n}
    (hconst : MetricComponentConst g) :
    ∀ (x : CoordVec n) (i j : n), einsteinTensor g x i j = 0 := by
  have hGamma : ∀ (x : CoordVec n) (i j k : n), christoffel g x i j k = 0 :=
    christoffel_eq_zero_of_metricComponentConst (hconst := hconst)
  have hR : ∀ (x : CoordVec n) (i j k l : n), riemann g x i j k l = 0 :=
    riemann_eq_zero_of_christoffel_eq_zero (hGamma := hGamma)
  have hRic : ∀ (x : CoordVec n) (i j : n), ricci g x i j = 0 :=
    ricci_eq_zero_of_riemann_eq_zero (hR := hR)
  have hSc : ∀ x, scalarCurvature g x = 0 :=
    scalarCurvature_eq_zero_of_ricci_eq_zero (hRic := hRic)
  exact einsteinTensor_eq_zero_of_ricci_scalar_zero (hRic := hRic) (hSc := hSc)

/-- 4D Minkowski matrix in mostly-plus signature `diag(-1,1,1,1)`. -/
def minkowskiMatrix : Matrix (Fin 4) (Fin 4) ℝ :=
  fun i j =>
    if i = j then
      if i = 0 then (-1 : ℝ) else (1 : ℝ)
    else 0

/-- 4D Minkowski metric as a constant metric field. -/
def minkowskiMetric : MetricField (Fin 4) :=
  constantMetric minkowskiMatrix

/-- Minkowski metric components are constant. -/
theorem metricComponentConst_minkowski :
    MetricComponentConst (g := minkowskiMetric) :=
  metricComponentConst_constantMetric (A := minkowskiMatrix)

/-- Christoffels vanish for Minkowski metric. -/
theorem christoffel_eq_zero_minkowski :
    ∀ (x : CoordVec (Fin 4)) (i j k : Fin 4), christoffel minkowskiMetric x i j k = 0 :=
  christoffel_eq_zero_of_metricComponentConst (hconst := metricComponentConst_minkowski)

/-- Riemann tensor vanishes for Minkowski metric. -/
theorem riemann_eq_zero_minkowski :
    ∀ (x : CoordVec (Fin 4)) (i j k l : Fin 4), riemann minkowskiMetric x i j k l = 0 :=
  riemann_eq_zero_of_christoffel_eq_zero (hGamma := christoffel_eq_zero_minkowski)

/-- Einstein tensor vanishes for Minkowski metric. -/
theorem einsteinTensor_eq_zero_minkowski :
    ∀ (x : CoordVec (Fin 4)) (i j : Fin 4), einsteinTensor minkowskiMetric x i j = 0 :=
  einsteinTensor_eq_zero_of_metricComponentConst (hconst := metricComponentConst_minkowski)

end

end NavierStokesClean.CATEPT
