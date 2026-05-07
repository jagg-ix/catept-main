import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.LinearCombination

/-!
# Path-Integral Benchmark Ladder Bridge (T88)

Stage 1+3 and Stage 4 of the normalization benchmark ladder
`REPLYID:20260427-PI-NORM-RENORM-01`.

## Stages discharged here (additive, no Phase-1 placeholder modified)

* **Stage 1+3 — Free-particle / FK damping composition law.**
  At the level of the FK damping factor `D(t) = exp(-V·t)` the kernel
  composition law `D(t₁+t₂) = D(t₁) · D(t₂)` is an algebraic identity
  in `ℝ`. This is the multiplicative half of the free-particle
  composition test; the oscillatory prefactor `√(m/(2πiℏ t))` is
  deferred (would require complex Gaussian integration infra).

* **Stage 4 — Euclidean harmonic-oscillator partition function.**
  For oscillator eigenvalues `λ_k = ℏω(k+½)` the *finite* spectral
  trace is a geometric sum; combined with the algebraic sinh identity
  `exp(-x/2) / (1 - exp(-x)) = 1 / (2 sinh(x/2))` this gives the
  textbook closed form `Z(β) = 1/(2 sinh(βℏω/2))` up to the controlled
  tail factor `(1 - exp(-βℏω·N))`.

## Stages NOT discharged (require new infrastructure)

Stages 2/5/6/7/8: oscillating HO kernel, source `J(x)`, vacuum-bubble
enumeration, instanton det′, UV cutoff removal for λφ⁴ in d=1,2,4.

## Phase status
Phase-1: honest algebraic identities, all proofs machine-checked,
kernel-only `[propext, Classical.choice, Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.PathIntegralBenchmarks

noncomputable section

-- ─── Stage 1+3 — multiplicative composition of FK damping ──────────────────

/-- Free-particle / FK-damping composition law (real / Euclidean half). -/
theorem fk_damping_composition (V t₁ t₂ : ℝ) :
    Real.exp (-(V * (t₁ + t₂))) =
      Real.exp (-(V * t₁)) * Real.exp (-(V * t₂)) := by
  rw [← Real.exp_add]
  congr 1; ring

/-- Initial-condition normalization at `t = 0`: `D(0) = 1`. -/
theorem fk_damping_at_zero (V : ℝ) : Real.exp (-(V * (0 : ℝ))) = 1 := by
  simp

/-- Multiplicative semigroup form of the composition law. -/
theorem fk_damping_semigroup (V : ℝ) :
    ∀ t₁ t₂ : ℝ,
      Real.exp (-(V * (t₁ + t₂))) =
        Real.exp (-(V * t₁)) * Real.exp (-(V * t₂)) :=
  fun t₁ t₂ => fk_damping_composition V t₁ t₂

-- ─── Stage 4 — Euclidean harmonic-oscillator partition closed form ─────────

private lemma exp_neg_lt_one (x : ℝ) (hx : 0 < x) : Real.exp (-x) < 1 := by
  rw [show (1 : ℝ) = Real.exp 0 from Real.exp_zero.symm]
  exact Real.exp_lt_exp.mpr (by linarith)

private lemma one_sub_exp_neg_pos (x : ℝ) (hx : 0 < x) :
    0 < 1 - Real.exp (-x) := by
  linarith [exp_neg_lt_one x hx]

/-- **Algebraic sinh identity** behind the Stage-4 closed form.

    For `x > 0`, `exp(-x/2) / (1 - exp(-x)) = 1 / (2 · sinh(x/2))`. -/
theorem harmonicOscillator_partition_sinh_form
    (x : ℝ) (hx : 0 < x) :
    Real.exp (-(x / 2)) / (1 - Real.exp (-x)) =
      1 / (2 * Real.sinh (x / 2)) := by
  have h_denom_pos : 0 < 1 - Real.exp (-x) := one_sub_exp_neg_pos x hx
  have h_denom_ne : (1 - Real.exp (-x)) ≠ 0 := ne_of_gt h_denom_pos
  have h_sinh_pos : 0 < Real.sinh (x / 2) := by
    rw [Real.sinh_pos_iff]; linarith
  have h_two_sinh_ne : (2 : ℝ) * Real.sinh (x / 2) ≠ 0 := by positivity
  have h1 : Real.exp (x / 2) * Real.exp (-(x / 2)) = 1 := by
    rw [← Real.exp_add]; simp
  have h2 : Real.exp (-(x / 2)) * Real.exp (-(x / 2)) = Real.exp (-x) := by
    rw [← Real.exp_add]; congr 1; ring
  -- Key algebraic identity: `2 · sinh(x/2) · exp(-x/2) = 1 - exp(-x)`.
  have hkey : 2 * Real.sinh (x / 2) * Real.exp (-(x / 2)) =
      1 - Real.exp (-x) := by
    rw [Real.sinh_eq]
    linear_combination h1 - h2
  rw [div_eq_div_iff h_denom_ne h_two_sinh_ne]
  linear_combination hkey

/-- **Finite spectral trace = geometric sum** for the harmonic oscillator.

    For oscillator eigenvalues `λ_k = ℏω(k + ½)` the partial Euclidean
    trace `Z_N(β) = Σ_{k<N} exp(-β · ℏω · (k + ½))` has the closed form
    `Z_N(β) = exp(-βℏω/2) · (1 - exp(-βℏω·N)) / (1 - exp(-βℏω))`. -/
theorem harmonicOscillator_partition_finite
    (x : ℝ) (hx : 0 < x) (N : ℕ) :
    (Finset.range N).sum (fun k : ℕ =>
        Real.exp (-(x * ((k : ℝ) + 1 / 2)))) =
      Real.exp (-(x / 2)) *
        ((1 - Real.exp (-(x * (N : ℝ)))) / (1 - Real.exp (-x))) := by
  have h_denom_ne : (1 - Real.exp (-x)) ≠ 0 :=
    ne_of_gt (one_sub_exp_neg_pos x hx)
  induction N with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih]
      have h_term :
          Real.exp (-(x * ((n : ℝ) + 1 / 2))) =
            Real.exp (-(x / 2)) * Real.exp (-(x * (n : ℝ))) := by
        rw [← Real.exp_add]; congr 1; ring
      have h_step :
          Real.exp (-(x * (((n + 1 : ℕ)) : ℝ))) =
            Real.exp (-(x * (n : ℝ))) * Real.exp (-x) := by
        rw [← Real.exp_add]; congr 1; push_cast; ring
      rw [h_term, h_step]
      field_simp
      ring

/-- **Stage 4 — pass condition (closed form).**

    Combining `harmonicOscillator_partition_finite` with
    `harmonicOscillator_partition_sinh_form`, the regularized
    Euclidean HO partition function satisfies

      `Z_N(β) = (1 - exp(-βℏω·N)) / (2 · sinh(βℏω/2))`,

    matching the textbook value `Z(β) = 1/(2 sinh(βℏω/2))` up to the
    controlled tail factor `(1 - exp(-βℏω·N))`. -/
theorem harmonicOscillator_partition_matches_sinh_finite
    (x : ℝ) (hx : 0 < x) (N : ℕ) :
    (Finset.range N).sum (fun k : ℕ =>
        Real.exp (-(x * ((k : ℝ) + 1 / 2)))) =
      (1 - Real.exp (-(x * (N : ℝ)))) / (2 * Real.sinh (x / 2)) := by
  rw [harmonicOscillator_partition_finite x hx N]
  have hs := harmonicOscillator_partition_sinh_form x hx
  have h_denom_ne : (1 - Real.exp (-x)) ≠ 0 :=
    ne_of_gt (one_sub_exp_neg_pos x hx)
  have h_sinh_pos : 0 < Real.sinh (x / 2) := by
    rw [Real.sinh_pos_iff]; linarith
  have h_two_sinh_ne : (2 : ℝ) * Real.sinh (x / 2) ≠ 0 := by positivity
  rw [show Real.exp (-(x / 2)) *
        ((1 - Real.exp (-(x * (N : ℝ)))) / (1 - Real.exp (-x))) =
      (Real.exp (-(x / 2)) / (1 - Real.exp (-x))) *
        (1 - Real.exp (-(x * (N : ℝ)))) from by
        field_simp]
  rw [hs]
  field_simp

end

end CATEPTMain.Integration.PathIntegralBenchmarks
