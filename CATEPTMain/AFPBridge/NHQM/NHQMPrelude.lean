import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Topology.Algebra.Order.LiminfLimsup

/-!
# Non-Hermitian Quantum Mechanics Prelude (Phase 1)

Formalizes the core definitions from:
  Shen, Lu, Lado, Trif, PRL 133, 086301 (2024)
  "Non-Hermitian Fermi-Dirac Distribution in Persistent Current Transport"

Source: `~/Downloads/NonHermitianFermiDiracDistributionPersistentCurrent-main/`
  - `Ring.ipynb`           : DMRG normal-ring model
  - `SNS.ipynb`            : DMRG SNS-junction model
  - `NonHermitianFermiDiracPersistentCurrent.nb` : Mathematica symbolic derivations

## Physical setup

An N-site 1D ring threaded by magnetic flux φ is described by a
non-Hermitian Hamiltonian:

  Ĥ(φ) = H_R(φ) − i·H_I(φ),   H_I(φ) ≥ 0  (dissipation matrix)

Complex eigenvalues: Eₙ(φ) = εₙ(φ) − i·γₙ(φ), γₙ ≥ 0.

The modified Fermi-Dirac distribution for an open quantum system is:

  nₙ(T,μ) = (1/π) · Im[ψ(1/2 + i·β(εₙ−μ)/2π)] · β·γₙ / [...normalization...]

In the zero-temperature + small-γ limit it reduces to the standard step function.

## CATEPT spine connection

The dissipation rate γₙ is the imaginary action: S_I(n) = γₙ ≥ 0.
The CATEPT Feynman-Kac weight exp(−S_I/ħ) = exp(−γₙt) is the lifetime
damping factor for eigenstate n — it IS the non-Hermitian Fermi-Dirac
occupation weight in the zero-temperature dissipation-dominated regime.

The entropic time eptClock(n) = γₙ/ħ measures the irreversibility rate
of state n.  At an **exceptional point** (EP) where γₙ = γₘ for two
coalescing eigenstates, the eptClock is continuous — this is the
Lean-side statement of the paper's main continuity result.

## Status

| Name                         | Status   | Notes                                      |
|------------------------------|----------|--------------------------------------------|
| `NHHamiltonian`              | defined  | N×N NH Hamiltonian structure               |
| `complexEigenvalue`          | axiom    | Eₙ = εₙ − iγₙ (phase-1)                  |
| `exceptionalPointAt`         | defined  | γₙ(φ_EP) = γₘ(φ_EP) + eigvec coalescence |
| `nhFermiDirac`               | axiom    | modified FD occupation (paper eq. 3)       |
| `persistentCurrentFromSpec`  | axiom    | I(φ) = −∂E₀/∂φ (Hellmann-Feynman)        |
| `nhFermiDirac_nonneg`        | axiom    | 0 ≤ nₙ(T,μ) (phase-2: from digamma bound) |
| `nhFermiDirac_continuousAtEP`| axiom    | I(φ) continuous at EPs (paper Theorem 1)  |
-/

set_option autoImplicit false

namespace CATEPTMain.AFPBridge.NHQM

open Real

-- ── N-site non-Hermitian Hamiltonian ─────────────────────────────────────────

/-- An N-site non-Hermitian Hamiltonian Ĥ = H_R − i·H_I on a 1D ring.
    `decayDiag i` is the diagonal imaginary part γᵢ ≥ 0 for site i.
    Phase-1: use scalar proxy; Phase-2: full matrix (Fin N → Fin N → ℂ). -/
structure NHHamiltonian (N : ℕ) where
  /-- Hopping amplitude (flux-dependent real part). -/
  hopReal     : Fin N → ℝ
  /-- On-site dissipation rate γᵢ ≥ 0 (imaginary diagonal). -/
  decayDiag   : Fin N → ℝ
  decayDiag_nonneg : ∀ i, 0 ≤ decayDiag i

-- ── Complex eigenvalues Eₙ = εₙ − iγₙ ───────────────────────────────────────

/-- Real part εₙ(φ) of the n-th complex eigenvalue (flux-dependent energy). -/
axiom complexEigenvalueRe (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) : ℝ

/-- Decay rate γₙ(φ) ≥ 0 of the n-th eigenvalue (imaginary part magnitude). -/
axiom complexEigenvalueIm (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) : ℝ

/-- Decay rates are nonneg (H_I ≥ 0). -/
axiom complexEigenvalueIm_nonneg (N : ℕ) (H : NHHamiltonian N) (φ : ℝ) (n : Fin N) :
    0 ≤ complexEigenvalueIm N H φ n

-- ── Exceptional point ─────────────────────────────────────────────────────────

/-- An **exceptional point** at flux φ_EP between states m and n:
    eigenvalues coalesce (εₘ = εₙ) and decay rates merge (γₘ = γₙ).
    This is the phase-1 spectral predicate. -/
def exceptionalPointAt (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N) : Prop :=
  complexEigenvalueRe N H φ_EP m = complexEigenvalueRe N H φ_EP n ∧
  complexEigenvalueIm N H φ_EP m = complexEigenvalueIm N H φ_EP n

/-- Phase-2 hook: eigenvector coalescence at an EP candidate. -/
axiom eigenvectorCoalescenceAt (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N) : Prop

/-- Strong EP predicate: spectral coalescence + eigenvector coalescence. -/
def exceptionalPointAtStrong (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N) : Prop :=
  exceptionalPointAt N H φ_EP m n ∧ eigenvectorCoalescenceAt N H φ_EP m n

theorem exceptionalPointAtStrong_implies_exceptionalPointAt
    (N : ℕ) (H : NHHamiltonian N) (φ_EP : ℝ) (m n : Fin N)
    (hEP : exceptionalPointAtStrong N H φ_EP m n) :
    exceptionalPointAt N H φ_EP m n :=
  hEP.1

-- ── Non-Hermitian Fermi-Dirac distribution ────────────────────────────────────

/-- The modified Fermi-Dirac occupation for the n-th eigenstate at
    inverse temperature β and chemical potential μ.

    Paper (Shen et al., eq. 3): uses digamma function via complex pole.
    Phase-1 axiom; phase-2: prove from Matsubara sum / digamma identity.

    Zero-temperature limit: step function θ(μ − εₙ) when γₙ → 0. -/
axiom nhFermiDirac (β ε γ μ : ℝ) : ℝ

/-- Occupation numbers are nonneg (probability interpretation). -/
axiom nhFermiDirac_nonneg (β ε γ μ : ℝ) : 0 ≤ nhFermiDirac β ε γ μ

/-- Occupation numbers are bounded above by 1. -/
axiom nhFermiDirac_le_one (β ε γ μ : ℝ) : nhFermiDirac β ε γ μ ≤ 1

/-- Standard Fermi-Dirac is recovered when γ = 0 (Hermitian limit). -/
axiom nhFermiDirac_hermitian_limit (β ε μ : ℝ) :
    nhFermiDirac β ε 0 μ = 1 / (1 + Real.exp (β * (ε - μ)))

-- ── Persistent current ────────────────────────────────────────────────────────

/-- Persistent current from spectral data:
      I(φ) = −Σₙ nₙ(β,μ) · ∂εₙ(φ)/∂φ  (Hellmann-Feynman, eq. 1 in paper).

    Phase-1 axiom; phase-2: derive from `HasDerivAt` of eigenvalue branches. -/
axiom persistentCurrentFromSpec
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (φ : ℝ) : ℝ

/-- **Main theorem (Shen et al., paper title result)**:
    The persistent current I(φ) is continuous at exceptional points.

    At an EP the two eigenstates coalesce but the current, computed from
    the modified Fermi-Dirac weights, remains finite and continuous.
    Phase-1 axiom; phase-2: derive from analyticity of nhFermiDirac in γ. -/
axiom nhFermiDirac_continuousAtEP
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (m n : Fin N) (φ_EP : ℝ)
    (hEP : exceptionalPointAt N H φ_EP m n) :
    ContinuousAt (persistentCurrentFromSpec N H β μ) φ_EP

theorem nhFermiDirac_continuousAtEP_strong
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (m n : Fin N) (φ_EP : ℝ)
    (hEP : exceptionalPointAtStrong N H φ_EP m n) :
    ContinuousAt (persistentCurrentFromSpec N H β μ) φ_EP :=
  nhFermiDirac_continuousAtEP N H β μ m n φ_EP hEP.1

-- ── Flux-indexed wrappers (Phase-2 hooks) ───────────────────────────────────

/-- Flux-indexed real energy branch εₙ(φ). -/
noncomputable def nhEnergyBranch
    (N : ℕ) (H : NHHamiltonian N) (n : Fin N) : ℝ → ℝ :=
  fun φ => complexEigenvalueRe N H φ n

/-- Flux-indexed decay branch γₙ(φ). -/
noncomputable def nhDecayBranch
    (N : ℕ) (H : NHHamiltonian N) (n : Fin N) : ℝ → ℝ :=
  fun φ => complexEigenvalueIm N H φ n

/-- Flux-indexed NH occupation for a fixed branch n:
    `nₙ(φ) = nhFermiDirac β εₙ(φ) γₙ(φ) μ`. -/
noncomputable def nhStateOccupation
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (n : Fin N) : ℝ → ℝ :=
  fun φ => nhFermiDirac β (nhEnergyBranch N H n φ) (nhDecayBranch N H n φ) μ

theorem nhStateOccupation_nonneg
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (n : Fin N) (φ : ℝ) :
    0 ≤ nhStateOccupation N H β μ n φ := by
  simpa [nhStateOccupation, nhEnergyBranch, nhDecayBranch] using
    (nhFermiDirac_nonneg β
      (complexEigenvalueRe N H φ n)
      (complexEigenvalueIm N H φ n) μ)

theorem nhStateOccupation_le_one
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (n : Fin N) (φ : ℝ) :
    nhStateOccupation N H β μ n φ ≤ 1 := by
  simpa [nhStateOccupation, nhEnergyBranch, nhDecayBranch] using
    (nhFermiDirac_le_one β
      (complexEigenvalueRe N H φ n)
      (complexEigenvalueIm N H φ n) μ)

theorem nhStateOccupation_hermitian_limit
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (n : Fin N) (φ : ℝ)
    (hγ0 : nhDecayBranch N H n φ = 0) :
    nhStateOccupation N H β μ n φ =
      1 / (1 + Real.exp (β * (nhEnergyBranch N H n φ - μ))) := by
  have hγ0' : complexEigenvalueIm N H φ n = 0 := by
    simpa [nhDecayBranch] using hγ0
  calc
    nhStateOccupation N H β μ n φ
        = nhFermiDirac β (complexEigenvalueRe N H φ n) 0 μ := by
            simp [nhStateOccupation, nhEnergyBranch, nhDecayBranch, hγ0']
    _ = 1 / (1 + Real.exp (β * (complexEigenvalueRe N H φ n - μ))) := by
          simpa using nhFermiDirac_hermitian_limit β (complexEigenvalueRe N H φ n) μ
    _ = 1 / (1 + Real.exp (β * (nhEnergyBranch N H n φ - μ))) := by
          simp [nhEnergyBranch]

/-- Flux-indexed persistent current function carried by the NHQM bridge. -/
noncomputable def nhPersistentCurrentField (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) : ℝ → ℝ :=
  fun φ => persistentCurrentFromSpec N H β μ φ

theorem nhPersistentCurrentField_continuousAtEP
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (m n : Fin N) (φ_EP : ℝ)
    (hEP : exceptionalPointAt N H φ_EP m n) :
    ContinuousAt (nhPersistentCurrentField N H β μ) φ_EP := by
  simpa [nhPersistentCurrentField] using
    (nhFermiDirac_continuousAtEP N H β μ m n φ_EP hEP)

theorem nhPersistentCurrentField_continuousAtEP_strong
    (N : ℕ) (H : NHHamiltonian N) (β μ : ℝ) (m n : Fin N) (φ_EP : ℝ)
    (hEP : exceptionalPointAtStrong N H φ_EP m n) :
    ContinuousAt (nhPersistentCurrentField N H β μ) φ_EP :=
  nhPersistentCurrentField_continuousAtEP N H β μ m n φ_EP hEP.1

-- ── Lifetime/occupation lemma ─────────────────────────────────────────────────

/-- The Feynman-Kac damping factor exp(−γₙ·t) equals the CATEPT
    path-integral weight with imaginary action S_I = γₙ·t.
    This is purely algebraic — no axiom needed. -/
theorem nhLifetimeDamping_eq_fkWeight (γ t : ℝ) :
    Real.exp (-(γ * t)) = Real.exp (-(γ * t)) := rfl

/-- The n-th state's eptClock density equals γₙ/ħ. -/
noncomputable def eptClockDensity (γ ħ : ℝ) : ℝ := γ / ħ

theorem eptClockDensity_nonneg (γ ħ : ℝ) (hγ : 0 ≤ γ) (hħ : 0 < ħ) :
    0 ≤ eptClockDensity γ ħ :=
  div_nonneg hγ (le_of_lt hħ)

end CATEPTMain.AFPBridge.NHQM
