import NavierStokesClean.CATEPT.GRTensorKernel
import NavierStokesClean.CATEPT.QuantumGravity

/-!
# Schwarzschild Curvature Identities (WP07/WP08)

This module introduces the first non-constant Schwarzschild-style metric instance
inside the coordinate tensor kernel and proves nontrivial curvature identities:

- explicit non-constancy of the `g_tt` component across two radii;
- antisymmetry of the Riemann tensor in its last two slots;
- vanishing of the repeated last-slot Riemann component.

The purpose is to provide a concrete bridge target for external evidence mapping
from xAct/EinsteinPy outputs into Lean theorem anchors.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open BigOperators

abbrev STCoord := CoordVec (Fin 4)

/-- Time coordinate index in the `(t,r,theta,phi)` ordering. -/
def coordT : Fin 4 := 0

/-- Radial coordinate index in the `(t,r,theta,phi)` ordering. -/
def coordR : Fin 4 := 1

/-- Radial Schwarzschild factor `f(r) = 1 - 2M/r`. -/
def schwarzschildRadialF (M : ℝ) (x : STCoord) : ℝ :=
  schwarzschild_f M (x coordR)

/-- Schwarzschild-style diagonal metric on `(t,r,theta,phi)`.

Angular slots are fixed to `1` for this first concrete kernel milestone.
The non-constant structure is concentrated in `g_tt` and `g_rr`.
-/
def schwarzschildMetric (M : ℝ) : MetricField (Fin 4) :=
  fun x i j =>
    if i = j then
      if i = coordT then
        -schwarzschildRadialF M x
      else if i = coordR then
        (schwarzschildRadialF M x)⁻¹
      else
        1
    else
      0

/-- Reference point with `r = 3`. -/
def schwarzschildPointR3 : STCoord :=
  fun i => if i = coordR then 3 else 0

/-- Reference point with `r = 4`. -/
def schwarzschildPointR4 : STCoord :=
  fun i => if i = coordR then 4 else 0

/-- `g_tt` at `r = 3`. -/
theorem schwarzschildMetric_tt_at_R3 (M : ℝ) :
    schwarzschildMetric M schwarzschildPointR3 coordT coordT = -(1 - (2 * M) / 3) := by
  unfold schwarzschildMetric schwarzschildPointR3 schwarzschildRadialF coordT coordR schwarzschild_f
  simp

/-- `g_tt` at `r = 4`. -/
theorem schwarzschildMetric_tt_at_R4 (M : ℝ) :
    schwarzschildMetric M schwarzschildPointR4 coordT coordT = -(1 - (2 * M) / 4) := by
  unfold schwarzschildMetric schwarzschildPointR4 schwarzschildRadialF coordT coordR schwarzschild_f
  simp

/-- First concrete non-constancy witness for Schwarzschild metric components. -/
theorem schwarzschildMetric_nonconstant_tt (M : ℝ) (hM : M ≠ 0) :
    schwarzschildMetric M schwarzschildPointR3 coordT coordT ≠
      schwarzschildMetric M schwarzschildPointR4 coordT coordT := by
  rw [schwarzschildMetric_tt_at_R3, schwarzschildMetric_tt_at_R4]
  intro hEq
  have hfrac : (2 * M) / 3 = (2 * M) / 4 := by linarith
  have hzero : M = 0 := by
    field_simp at hfrac
    linarith
  exact hM hzero

section CurvatureIdentities

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- Riemann antisymmetry in the last two indices (`k,l`). -/
theorem riemann_antisymm_lastTwo
    (g : MetricField n) (x : CoordVec n) (i j k l : n) :
    riemann g x i j k l = -riemann g x i j l k := by
  unfold riemann
  have hsum :
      (∑ m : n,
        (christoffel g x i k m * christoffel g x m j l -
          christoffel g x i l m * christoffel g x m j k)) =
      -∑ m : n,
        (christoffel g x i l m * christoffel g x m j k -
          christoffel g x i k m * christoffel g x m j l) := by
    calc
      (∑ m : n,
        (christoffel g x i k m * christoffel g x m j l -
          christoffel g x i l m * christoffel g x m j k))
          = ∑ m : n,
              (-(christoffel g x i l m * christoffel g x m j k -
                  christoffel g x i k m * christoffel g x m j l)) := by
            apply Finset.sum_congr rfl
            intro m hm
            ring
      _ = -∑ m : n,
            (christoffel g x i l m * christoffel g x m j k -
              christoffel g x i k m * christoffel g x m j l) := by
            simpa [Finset.sum_neg_distrib]
  rw [hsum]
  ring

/-- Repeated last index forces the Riemann component to vanish. -/
theorem riemann_lastTwo_diag_zero
    (g : MetricField n) (x : CoordVec n) (i j k : n) :
    riemann g x i j k k = 0 := by
  have h := riemann_antisymm_lastTwo (g := g) (x := x) (i := i) (j := j) (k := k) (l := k)
  linarith

end CurvatureIdentities

/-- Schwarzschild specialization of Riemann antisymmetry in `(k,l)`. -/
theorem schwarzschild_riemann_antisymm_lastTwo
    (M : ℝ) (x : STCoord) (i j k l : Fin 4) :
    riemann (schwarzschildMetric M) x i j k l =
      -riemann (schwarzschildMetric M) x i j l k :=
  riemann_antisymm_lastTwo (g := schwarzschildMetric M) (x := x) (i := i) (j := j) (k := k) (l := l)

/-- Schwarzschild specialization: `R^i_{jkk} = 0`. -/
theorem schwarzschild_riemann_diag_zero
    (M : ℝ) (x : STCoord) (i j k : Fin 4) :
    riemann (schwarzschildMetric M) x i j k k = 0 :=
  riemann_lastTwo_diag_zero (g := schwarzschildMetric M) (x := x) (i := i) (j := j) (k := k)

end

end NavierStokesClean.CATEPT
