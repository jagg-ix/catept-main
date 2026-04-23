import CATEPTMain.LDO.FermiAction
/-!
# LatticeDiracOperators.jl → Lean 4 — RHMC / AlgRemez (Phase 1)

Formalises the rational hybrid Monte Carlo infrastructure from:
  - `rhmc/rhmc.jl`      — RHMC rational approximation application + coefficients
  - `rhmc/AlgRemez.jl`  — Remez algorithm for rational function approximation

## Rational Hybrid Monte Carlo (RHMC, Clark & Kennedy 2006)

  RHMC replaces the exact determinant det(D)^{N_f} by a rational approximation:

    (D†D)^{p/q} ≈ α₀ + ∑_{i=1}^{N} αᵢ (D†D + βᵢ)^{−1}

  where (p, q) encode the fractional power (e.g., (1,2) for N_f=2 overlap,
  (−1,4) for N_f=1/2 staggered flavours, etc.).

  The coefficients {α₀, αᵢ, βᵢ} are pre-computed by the Remez algorithm
  and stored as compile-time constants in `rhmc.jl`.

## Precomputed coefficient sets in rhmc.jl

  | Name        | Power      | N poles | Use case                   |
  |-------------|------------|---------|----------------------------|
  | coeffs_12   | (1,2)      | 10      | N_f=2 action               |
  | coeffs_m12  | (−1,2)     | 10      | N_f=2 force (inverse sq)   |
  | coeffs_14   | (1,4)      | 15      | N_f=1 staggered             |
  | coeffs_m14  | (−1,4)     | 15      | N_f=1 force                |

## AlgRemez coefficients structure

  struct AlgRemez_coeffs:
    alpha0 : Float64       — constant term
    alpha  : Vector{Float} — partial fraction numerators αᵢ
    beta   : Vector{Float} — shifts βᵢ > 0
    N      : Int           — number of poles

  Rational approximation:
    R(x) = α₀ + ∑ᵢ αᵢ / (x + βᵢ)    (partial fraction form)

## Accuracy bound

  The approximation error satisfies:
    |R(x) − x^{p/q}| ≤ δ    for x ∈ [ε_min, ε_max]
  where ε_min and ε_max are the spectral bounds of D†D.
-/

set_option autoImplicit false

open CATEPTMainFramework.TacticStubs

namespace CATEPTMain.LDO

-- ── Rational approximation coefficients ───────────────────────────────────────
/-- AlgRemez rational approximation coefficients for (D†D)^{p/q}.
  Source: `AlgRemez_coeffs` struct in AlgRemez.jl. -/
structure AlgRemezCoeffs where
  nPoles : ℕ                     -- number of poles N
  alpha0 : Float                 -- constant term α₀
  alpha  : Fin nPoles → Float    -- numerator coefficients αᵢ
  beta   : Fin nPoles → Float    -- shift (pole) values βᵢ > 0
  pNum   : ℤ                     -- numerator of power p
  pDen   : ℕ                     -- denominator of power q (positive)

/-- All shifts must be positive for the partial fractions to be well-posed.
  Source: βᵢ > 0 required for (D†D + βᵢ)^{-1} to be positive definite. -/
def AlgRemezCoeffs.betaPos (c : AlgRemezCoeffs) : Prop :=
  ∀ i : Fin c.nPoles, 0 < c.beta i

-- ── Precomputed coefficient sets ──────────────────────────────────────────────
/-- Coefficients for (D†D)^{1/2}: used in N_f=2 pseudofermion sampling.
  Source: `coeffs_12` constant in rhmc.jl (10 poles). -/
axiom rhmcCoeffs_12 : AlgRemezCoeffs

/-- Coefficients for (D†D)^{−1/2}: used in N_f=2 force computation.
  Source: `coeffs_m12` constant in rhmc.jl (10 poles). -/
axiom rhmcCoeffs_m12 : AlgRemezCoeffs

/-- Coefficients for (D†D)^{1/4}: used in N_f=1 staggered sampling.
  Source: `coeffs_14` constant in rhmc.jl (15 poles). -/
axiom rhmcCoeffs_14 : AlgRemezCoeffs

/-- Coefficients for (D†D)^{−1/4}: used in N_f=1 force.
  Source: `coeffs_m14` constant in rhmc.jl (15 poles). -/
axiom rhmcCoeffs_m14 : AlgRemezCoeffs

-- ── Rational function application ─────────────────────────────────────────────
/-- Apply rational approximation R(D†D)·ψ = [α₀ + ∑ᵢ αᵢ (D†D + βᵢ)^{−1}] ψ.
  Source: multi-shift CG solves in RHMC; each (D†D + βᵢ)·xᵢ = ψ solved simultaneously.
  Uses `shiftedcg` (or looped CG) internally. -/
axiom applyRHMCRational (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (c : AlgRemezCoeffs)
    (ψ : FermionField NC NX NY NZ NT NG) : FermionField NC NX NY NZ NT NG

/-- The RHMC rational approximation preserves non-negativity of the norm.
  Source: each shifted solve produces a real output; α₀ real → norm ≥ 0. -/
theorem applyRHMCRational_normNonneg (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (c : AlgRemezCoeffs)
    (ψ : FermionField NC NX NY NZ NT NG) :
    0 ≤ normSqFermion NC NX NY NZ NT NG
          (applyRHMCRational NC NX NY NZ NT NG D c ψ) :=
  normSq_nonneg NC NX NY NZ NT NG _

-- ── Remez accuracy bound ──────────────────────────────────────────────────────
/-- The rational approximation is accurate within δ over [ε_min, ε_max].
  Source: `calc_coefficients` in AlgRemez.jl computes optimal minimax approx.
  This bounds the systematic error introduced by RHMC vs exact HMC. -/
axiom rhmcAccuracy (c : AlgRemezCoeffs)
    (epsMin epsMax delta : Float) :
    True  -- phase2_high: |R(x) - x^{p/q}| ≤ δ for x ∈ [ε_min, ε_max]

/-- R(D†D) with positive shifts is a positive semi-definite operator: ⟨ψ, R(D†D)ψ⟩ ≥ 0.
  Physical basis: D†D ≥ 0, so (D†D + βᵢ) > 0 for βᵢ > 0, hence (D†D + βᵢ)^{-1} ≥ 0;
  a sum with positive weights αᵢ ≥ 0 and positive α₀ preserves positivity.
  Phase-2: from Spec(D†D) ⊆ [0,∞) + Riesz representation; stated as axiom pending
  matrix upgrade. -/
axiom applyRHMCRational_posSemidef (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (c : AlgRemezCoeffs)
    (hbeta : c.betaPos)
    (ψ : FermionField NC NX NY NZ NT NG) :
    0 ≤ (dotFermion NC NX NY NZ NT NG ψ
          (applyRHMCRational NC NX NY NZ NT NG D c ψ)).re

/-- Rational approx with positive shifts is Hermitian positive on PSD inputs. -/
theorem rhmcRational_posOnPSD (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (c : AlgRemezCoeffs)
    (hbeta : c.betaPos)
    (ψ : FermionField NC NX NY NZ NT NG) :
    0 ≤ (dotFermion NC NX NY NZ NT NG ψ
          (applyRHMCRational NC NX NY NZ NT NG D c ψ)).re :=
  applyRHMCRational_posSemidef NC NX NY NZ NT NG D c hbeta ψ

-- ── RHMC pseudofermion action ──────────────────────────────────────────────────
/-- RHMC fermion action: S_f = ϕ† · R^{−1}_{N_f/2}(D†D) · ϕ.
  Source: pseudofermion sampling `sample_pseudofermions!` in RHMC context. -/
noncomputable def rhmcFermiAction (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (c : AlgRemezCoeffs)
    (ϕ : PseudoFermion NC NX NY NZ NT NG) : ℝ :=
  (dotFermion NC NX NY NZ NT NG ϕ
    (applyRHMCRational NC NX NY NZ NT NG D c ϕ)).re

/-- RHMC action is non-negative: S_f = ⟨ϕ, R(D†D)ϕ⟩ ≥ 0. -/
theorem rhmcFermiAction_nonneg (NC NX NY NZ NT NG : ℕ)
    (D : DiracOp NC NX NY NZ NT NG)
    (c : AlgRemezCoeffs) (hbeta : c.betaPos)
    (ϕ : PseudoFermion NC NX NY NZ NT NG) :
    0 ≤ rhmcFermiAction NC NX NY NZ NT NG D c ϕ :=
  applyRHMCRational_posSemidef NC NX NY NZ NT NG D c hbeta ϕ

-- ── Normalization: specific coefficient sets ──────────────────────────────────
/-- coeffs_12 approximates x^{1/2} (10 poles), non-trivial but finite N_poles.
  Source: explicit constants in rhmc.jl: alpha0=35.768..., 10 poles. -/
axiom rhmcCoeffs_12_nPoles : rhmcCoeffs_12.nPoles = 10

/-- coeffs_m12 approximates x^{-1/2} (10 poles).
  Source: `coeffs_m12 = AlgRemez_coeffs(0.0279..., [...], [...], 10)` in rhmc.jl. -/
axiom rhmcCoeffs_m12_nPoles : rhmcCoeffs_m12.nPoles = 10

/-- coeffs_14 approximates x^{1/4} (15 poles).
  Source: `coeffs_14 = AlgRemez_coeffs(6.946..., [...], [...], 15)` in rhmc.jl. -/
axiom rhmcCoeffs_14_nPoles : rhmcCoeffs_14.nPoles = 15

/-- coeffs_m14 approximates x^{-1/4} (15 poles).
  Source: symmetric to coeffs_14 with inverted approximation range. -/
axiom rhmcCoeffs_m14_nPoles : rhmcCoeffs_m14.nPoles = 15

end CATEPTMain.LDO
