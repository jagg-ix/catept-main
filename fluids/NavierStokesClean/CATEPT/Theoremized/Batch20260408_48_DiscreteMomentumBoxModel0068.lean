import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Data.Complex.Basic

/-!
# Batch 20260408 Theoremization - CATEPT Row 48 (Discrete Momentum Box Model 0068)

Particle-in-box discrete wavefunction and momentum-variance wrappers.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B48

noncomputable section

abbrev WaveFunction := Nat → Complex

def row48_hbar : ℝ := 1

def row48_length : ℝ := 1

def row48_gridN : Nat := 100

def row48_h : ℝ := row48_length / (row48_gridN : ℝ)

/-- Particle-in-box mode profile on a finite grid. -/
def row48_boxWaveFunction (mode : Nat) : WaveFunction :=
  fun k =>
    if k ≥ row48_gridN + 1 then 0
    else
      Complex.ofReal
        (Real.sqrt (2 / row48_length) *
          Real.sin ((mode : ℝ) * Real.pi * ((k : ℝ) * row48_h) / row48_length))

/-- First-order discrete derivative. -/
def row48_discreteDerivative (psi : WaveFunction) (k : Nat) : Complex :=
  if k = 0 then (psi 1 - psi 0) / row48_h
  else if k = row48_gridN then (psi row48_gridN - psi (row48_gridN - 1)) / row48_h
  else (psi (k + 1) - psi (k - 1)) / (2 * row48_h)

/-- Discrete expectation of momentum. -/
def row48_expectationMomentum (psi : WaveFunction) : Complex :=
  (List.range (row48_gridN + 1)).foldl
    (fun sum k =>
      let psi_k := psi k
      let dpsi_k := row48_discreteDerivative psi k
      sum + star psi_k * (-Complex.I * (row48_hbar : ℂ)) * dpsi_k * (row48_h : ℂ))
    0

/-- Discrete expectation of momentum squared. -/
def row48_expectationMomentumSquared (psi : WaveFunction) : ℝ :=
  (List.range (row48_gridN + 1)).foldl
    (fun sum k =>
      let psi_k := psi k
      let d2psi_k := row48_discreteDerivative (fun m => row48_discreteDerivative psi m) k
      sum + (star psi_k * (-(row48_hbar ^ 2 : ℝ) : ℂ) * d2psi_k).re * row48_h)
    0

/-- Discrete momentum variance. -/
def row48_momentumVariance (psi : WaveFunction) : ℝ :=
  let p2 := row48_expectationMomentumSquared psi
  let p_avg := row48_expectationMomentum psi
  p2 - (p_avg.re ^ 2 + p_avg.im ^ 2)

/-- Outside-grid support is identically zero by construction. -/
theorem row48_boxWaveFunction_outside_support
    (mode k : Nat) (hk : k ≥ row48_gridN + 1) :
    row48_boxWaveFunction mode k = 0 := by
  unfold row48_boxWaveFunction
  simp [hk]

/-- Momentum variance is exactly the prescribed algebraic expression. -/
theorem row48_momentumVariance_unfold
    (psi : WaveFunction) :
    row48_momentumVariance psi =
      row48_expectationMomentumSquared psi -
        ((row48_expectationMomentum psi).re ^ 2 + (row48_expectationMomentum psi).im ^ 2) := by
  unfold row48_momentumVariance
  simp

/-- Combined row-48 discrete momentum closure witness. -/
theorem row48_discrete_momentum_bundle
    (mode : Nat) (k : Nat) (hk : k ≥ row48_gridN + 1)
    (psi : WaveFunction) :
    row48_boxWaveFunction mode k = 0 ∧
      row48_momentumVariance psi =
        row48_expectationMomentumSquared psi -
          ((row48_expectationMomentum psi).re ^ 2 + (row48_expectationMomentum psi).im ^ 2) := by
  exact ⟨row48_boxWaveFunction_outside_support mode k hk,
    row48_momentumVariance_unfold psi⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B48
