import Mathlib

/-!
# Batch 20260408 Theoremization - Global Row 225

DSF numerical-method scaffold extracted from
`0374_4._numerical_methods_in_lean_4.lean`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.G225

noncomputable section

structure DSFParameters where
  entropyCoupling : ℝ
  curvatureCoupling : ℝ
  relaxation : ℝ

abbrev StateVec := ℝ × ℝ

def vadd (x y : StateVec) : StateVec := (x.1 + y.1, x.2 + y.2)
def smul (a : ℝ) (x : StateVec) : StateVec := (a * x.1, a * x.2)

def entropyRate (s : StateVec) (params : DSFParameters) : ℝ :=
  params.entropyCoupling * s.1 - params.curvatureCoupling * s.2

def curvatureRate (s : StateVec) (params : DSFParameters) : ℝ :=
  params.relaxation * s.2 + params.curvatureCoupling * s.1

def dsfDifferentialSystem (params : DSFParameters) : ℝ → StateVec → StateVec :=
  fun _t s => (entropyRate s params, curvatureRate s params)

def rk4Step (f : ℝ → StateVec → StateVec) (t h : ℝ) (y : StateVec) : StateVec :=
  let k1 := f t y
  let k2 := f (t + h / 2) (vadd y (smul (h / 2) k1))
  let k3 := f (t + h / 2) (vadd y (smul (h / 2) k2))
  let k4 := f (t + h) (vadd y (smul h k3))
  vadd y (smul (h / 6) (vadd (vadd k1 (smul 2 k2)) (vadd (smul 2 k3) k4)))

def vectorNorm (x : StateVec) : ℝ := Real.sqrt (x.1 ^ 2 + x.2 ^ 2)

def adaptiveStepDSF
    (f : ℝ → StateVec → StateVec)
    (y : StateVec)
    (t h epsAbs epsRel : ℝ) : ℝ × StateVec :=
  let y1 := rk4Step f t h y
  let y2 := rk4Step f t (h / 2) y
  let err := vectorNorm (y1.1 - y2.1, y1.2 - y2.2)
  let tol := epsAbs + epsRel * max (vectorNorm y) (vectorNorm y1)
  if err ≤ tol then (|h|, y1) else (|h| / 2, y2)

theorem dsfDifferentialSystem_def (params : DSFParameters) (t : ℝ) (s : StateVec) :
    dsfDifferentialSystem params t s = (entropyRate s params, curvatureRate s params) := rfl

theorem vectorNorm_nonneg (x : StateVec) : 0 ≤ vectorNorm x := by
  unfold vectorNorm
  positivity

theorem adaptiveStepDSF_nonneg_step
    (f : ℝ → StateVec → StateVec) (y : StateVec)
    (t h epsAbs epsRel : ℝ) :
    0 ≤ (adaptiveStepDSF f y t h epsAbs epsRel).1 := by
  unfold adaptiveStepDSF
  by_cases hcond :
      vectorNorm ((rk4Step f t h y).1 - (rk4Step f t (h / 2) y).1,
          (rk4Step f t h y).2 - (rk4Step f t (h / 2) y).2)
        ≤ epsAbs + epsRel * max (vectorNorm y) (vectorNorm (rk4Step f t h y))
  · simp [hcond]
  · simp [hcond]
    positivity

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.G225
