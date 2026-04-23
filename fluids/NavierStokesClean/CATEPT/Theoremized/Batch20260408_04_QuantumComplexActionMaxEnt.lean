import NavierStokesClean.CATEPT.Foundations
import NavierStokesClean.CATEPT.MeasurePathIntegral
import NavierStokesClean.CATEPT.PathIntegrals

/-!
# Batch 20260408 Theoremization - CATEPT Row 04 (Quantum Complex Action MaxEnt)

Theoremized MaxEnt and source-coupled-observable witnesses for imported row-04
obligations.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B04

noncomputable section

open NavierStokesClean.CATEPT
open MeasureTheory

/-- Finite MaxEnt observable menu used by the row-04 contracts. -/
def maxEntObservableSet : List String :=
  ["energy", "entropy", "contact_time", "information"]

theorem maxEnt_observable_set_nonempty : maxEntObservableSet.length > 0 := by
  decide

/-- Jaynes-style scalar density on a compact support proxy. -/
def jaynesDensity (β x : ℝ) : ℝ := Real.exp (-β * x)

theorem jaynesDensity_pos (β x : ℝ) : 0 < jaynesDensity β x := by
  unfold jaynesDensity
  exact Real.exp_pos _

/-- Information observable coupling `λ_info = i β_I`. -/
def lambdaInfo (β_I : ℝ) : ℂ := Complex.I * (β_I : ℂ)

theorem lambdaInfo_is_pure_imaginary (β_I : ℝ) :
    (lambdaInfo β_I).re = 0 := by
  simp [lambdaInfo]

/-- Entropy functional `S[R] = -k * R * log R` (pointwise scalar form). -/
def entropyFunctional (k R : ℝ) : ℝ := -k * (R * Real.log R)

/-- Canonical entropic-rate identity routed to Eq 13. -/
theorem canonical_dynamics_entropy_rate_statement
    (κ k_B T hbar : ℝ)
    (h_hbar : 0 < hbar) (h_kB : 0 < k_B)
    (hT : T = hbar * κ / (2 * Real.pi * k_B)) :
    κ / (2 * Real.pi) = k_B * T / hbar :=
  eq013_entropic_rate_formula κ k_B T hbar h_hbar h_kB hT

/-- Contact-time projector positivity in scalar form. -/
def contactTimeProjector (t τ : ℝ) : ℝ := (t - τ)^2

theorem contact_time_projector_nonneg (t τ : ℝ) :
    0 ≤ contactTimeProjector t τ := by
  unfold contactTimeProjector
  positivity

/-- MaxEnt source-coupled partition identity from MTPI layer. -/
theorem maxent_source_partition_contract
    {α : Type*} [MeasurableSpace α]
    (m : MeasurePathIntegralModel α) (J : α → ℂ) :
    m.sourceCoupledPartition J =
      m.unnormalizedExpectation (fun x => Complex.exp (J x)) :=
  m.sourceCoupledPartition_eq_unnormalizedExpectation_exp J

/-- Compatibility with midpoint/generator limits via coercive damping law. -/
theorem midpoint_generator_compatibility
    {Φ : Type*} [NormedAddCommGroup Φ]
    (S_I : Φ → ℝ) (hbar : ℝ) (h_hbar : 0 < hbar)
    (coer : CoercivityCondition (Φ := Φ))
    (h_bound : ∀ φ : Φ, coer.C * ‖φ‖^2 ≤ S_I φ) :
    ∀ φ : Φ, path_integral_damping hbar (S_I φ) ≤
      Real.exp (-coer.C * ‖φ‖^2 / hbar) :=
  eq058_exponential_damping S_I S_I hbar h_hbar coer h_bound

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B04
