import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic

namespace NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted

noncomputable section

/-!
Foundational definitions extracted from the InfoGeometry gravity/information-geometry Lean fragments.
This file is intentionally compile-clean and free of `sorry`.
-/

structure ExtractedEnv where
  hbar : Real
  c : Real
  m : Real
  q : Real
  omega0 : Real
  k : Real

structure Path where
  gamma : Real -> Real

structure VectorPotential where
  A : Real -> Real

structure SpinConnection where
  omega : Real -> Real

structure SpinTensor where
  sigma : Real -> Real

/-- Proper-time to phase relation used throughout the extracted draft set. -/
def phaseFromProperTime (env : ExtractedEnv) (tau : Real) : Real :=
  - (env.m * env.c ^ 2 / env.hbar) * tau

/-- Clock postulate form used in extracted statements. -/
def clockFromPhase (env : ExtractedEnv) (dphi : Real) : Real :=
  dphi / env.omega0

/-- Algebraic sanity check for `clockFromPhase`. -/
theorem clockFromPhase_mul_omega0 (env : ExtractedEnv) (dphi : Real) (h : env.omega0 ≠ 0) :
    clockFromPhase env dphi * env.omega0 = dphi := by
  simp [clockFromPhase, h]

/-- Effective gravity coupling formula as an extracted computational anchor. -/
def effectiveG (env : ExtractedEnv) (r rCurv lambdaInfo miePhase : Real) : Real :=
  env.k * (env.hbar * env.c) / (env.m ^ 2 * lambdaInfo) *
    (1 / Real.sqrt (1 + r ^ 2 / lambdaInfo ^ 2)) *
    (1 + miePhase / Real.pi) *
    (1 + Real.exp (-rCurv))

end

end NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted
