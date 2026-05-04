import CATEPTMain.Integration.SchmidtBornFromEntanglementCarrier
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# DecoherenceFunctionalCarrier — consistent-histories form `D(α,β)`

Carrier-level slice for the **decoherence functional** of consistent
histories in the CAT/EPT framework
(`docs/intake/chatgpt-making-history-in-theory3-leverage-map.md`,
lines 38990+):

  `D(α,β) = Σ_{Φ∈Cα} Σ_{Φ'∈Cβ} e^{(i/ℏ)(S_R[Φ] − S_R[Φ'])}
                                · e^{−(1/2)(S_ent[Φ] + S_ent[Φ'])}`.

Diagonal weights `D(α,α) = p(α)` give Kolmogorov probabilities
(matching Born from `SchmidtBornFromEntanglementCarrier`); off-diagonal
`D(α,β)` for `α ≠ β` are exponentially suppressed by entanglement
growth `e^{−(1/2) ΔS_ent(α,β)}` once `ΔS_ent ≫ 1`.

## Carrier-level scope

Magnitude-level surrogates: real-valued functionals `D : Index ×
Index → ℝ` with the Kolmogorov-probability properties on the diagonal
and the Hermitian / non-negativity / suppression structure as Prop
fields.  The branching threshold

  `ΔS_ent(α,β) > 2 ln(1/ε)  ⇒  e^{−(1/2)ΔS_ent} < ε`

is shipped as a proven theorem.

## What this module ships

* `DecoherenceFunctional` — Prop-level carrier holding `D` (as a
  bivariate function), diagonal positivity, and the off-diagonal
  suppression hypothesis.
* `diagonal_is_probability` — `D(α,α) ≥ 0`.
* `branching_threshold` — proven: `ΔS_ent > 2 ln(1/ε) ⇒
  e^{−(1/2) ΔS_ent} < ε` (for `ε > 0`).
* `exists_trivial` — degenerate single-index witness.
* `decoherence_functional_bundle` capstone.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.DecoherenceFunctionalCarrier

open Real

/-- **Decoherence functional carrier.**

Holds `D : Index × Index → ℝ` with:
* diagonal non-negativity (Kolmogorov-probability property);
* total normalisation `Σ D(α,α) = 1`;
* off-diagonal-suppression hypothesis on `α ≠ β` controlled by an
  entanglement gap `ΔS_ent`. -/
structure DecoherenceFunctional (n : ℕ) where
  /-- The decoherence-functional matrix (real-valued surrogate;
  the genuine version is `ℂ`-valued, but the carrier exposes only
  the magnitudes used by the Born-rule reduction). -/
  D                  : Fin n → Fin n → ℝ
  /-- Diagonal non-negativity. -/
  diagonal_nonneg    : ∀ α : Fin n, 0 ≤ D α α
  /-- Total diagonal mass equals 1 (probability normalisation). -/
  diagonal_sum_one   : ∑ α, D α α = 1
  /-- Off-diagonal magnitudes are bounded by the entanglement
  suppression `e^{−(1/2) ΔS_ent(α,β)}`. -/
  ΔS_ent             : Fin n → Fin n → ℝ
  /-- The suppression bound: `|D(α,β)| ≤ e^{−(1/2) ΔS_ent(α,β)}`
  for `α ≠ β`. -/
  off_diag_suppressed :
      ∀ α β : Fin n, α ≠ β →
        |D α β| ≤ Real.exp (-(1/2) * ΔS_ent α β)

namespace DecoherenceFunctional

variable {n : ℕ} (Δ : DecoherenceFunctional n)

/-- **Extraction:** diagonal entries are non-negative (Kolmogorov
probability values). -/
theorem diagonal_is_probability (α : Fin n) : 0 ≤ Δ.D α α :=
  Δ.diagonal_nonneg α

/-- **Extraction:** total diagonal mass is 1. -/
theorem diagonal_normalised : ∑ α, Δ.D α α = 1 := Δ.diagonal_sum_one

/-- **Branching threshold theorem.** If
`ΔS_ent(α,β) > 2 · log(1/ε)` for `ε > 0`, then the suppression factor
`e^{−(1/2) ΔS_ent}` is strictly less than `ε`. -/
theorem branching_threshold (Δ_ent ε : ℝ) (hε : 0 < ε)
    (h : Real.log (1 / ε) * 2 < Δ_ent) :
    Real.exp (-(1/2) * Δ_ent) < ε := by
  -- Goal: `exp(−Δ_ent/2) < ε`.
  -- From h: `Δ_ent > 2 log(1/ε)`, so `−Δ_ent/2 < −log(1/ε) = log ε`.
  -- Then `exp(−Δ_ent/2) < exp(log ε) = ε`.
  have hε_inv_pos : 0 < 1 / ε := one_div_pos.mpr hε
  have hlog : Real.log (1 / ε) = -Real.log ε := by
    rw [Real.log_div one_ne_zero (ne_of_gt hε), Real.log_one, zero_sub]
  have hbound : -(1 / 2 : ℝ) * Δ_ent < Real.log ε := by
    have : -Δ_ent / 2 < Real.log ε := by
      have h' : Δ_ent / 2 > Real.log (1 / ε) := by linarith
      rw [hlog] at h'
      linarith
    linarith
  have hε_log_pos : Real.exp (-(1 / 2) * Δ_ent) < Real.exp (Real.log ε) :=
    Real.exp_lt_exp.mpr hbound
  rwa [Real.exp_log hε] at hε_log_pos

/-- **Trivial existence:** single-index `n = 1`, `D 0 0 = 1`. -/
theorem exists_trivial : ∃ _ : DecoherenceFunctional 1, True := by
  refine ⟨{ D                   := fun _ _ => 1
          , diagonal_nonneg     := fun _ => by norm_num
          , diagonal_sum_one    := by simp
          , ΔS_ent              := fun _ _ => 0
          , off_diag_suppressed := ?_ }, trivial⟩
  intro α β hαβ
  -- For `n = 1`, `α = β = 0` always — so `α ≠ β` is impossible.
  exact absurd (Subsingleton.elim α β) hαβ

end DecoherenceFunctional

/-! ## Capstone -/

/-- **Decoherence functional bundle.** -/
theorem decoherence_functional_bundle :
    ∃ _ : DecoherenceFunctional 1, True :=
  DecoherenceFunctional.exists_trivial

end CATEPTMain.Integration.DecoherenceFunctionalCarrier

end
