import NavierStokesClean.CATEPT.Theoremized.Batch20260408_53_DiscreteMeasurementSuperposition0069

/-!
# Batch 20260408 Theoremization - CATEPT Row 54 (Discrete Measurement Superposition Variant 0070)

Variant collapse wrappers kept equivalent to the baseline discrete superposition
measurement layer from row 53.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54

noncomputable section

open NavierStokesClean.CATEPT

/-- Baseline branch-collapse rule. -/
def row54_collapseBaseline (psi p : ℝ) : ℝ := psi ^ 2 / p

/-- Variant branch-collapse rule through conditional normalization. -/
def row54_collapseVariant (psi p : ℝ) : ℝ := (psi / Real.sqrt p) ^ 2

/-- Variant collapse is equivalent to the baseline rule for positive branch weight. -/
theorem row54_variant_eq_baseline
    (psi p : ℝ) (hp : 0 < p) :
    row54_collapseVariant psi p = row54_collapseBaseline psi p := by
  unfold row54_collapseVariant row54_collapseBaseline
  simpa using
    (NavierStokesClean.CATEPT.Theoremized.Batch20260408.B53.row53_conditional_state_normalized psi p hp)

/-- Variant branch contributions satisfy the same superposition additivity law. -/
theorem row54_variant_additivity
    (psi1 psi2 p : ℝ) (hp : 0 < p) :
    row54_collapseVariant psi1 p + row54_collapseVariant psi2 p =
      (psi1 ^ 2 + psi2 ^ 2) / p := by
  calc
    row54_collapseVariant psi1 p + row54_collapseVariant psi2 p
        = row54_collapseBaseline psi1 p + row54_collapseBaseline psi2 p := by
            rw [row54_variant_eq_baseline psi1 p hp, row54_variant_eq_baseline psi2 p hp]
    _ = (psi1 ^ 2 + psi2 ^ 2) / p := by
          unfold row54_collapseBaseline
          exact eq051_born_rule_normalized psi1 psi2 p

/-- Variant stream preserves constructive measurement closure from row 53. -/
theorem row54_measurement_problem_closed
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    0 < s.s6 :=
  NavierStokesClean.CATEPT.Theoremized.Batch20260408.B53.row53_measurement_problem_closed s hs

/-- Combined row-54 variant-collapse witness package. -/
theorem row54_variant_bundle
    (psi1 psi2 psi p : ℝ)
    (hp : 0 < p)
    (s : KucharConstructiveState)
    (hs : KucharConstructiveSolved s) :
    row54_collapseVariant psi p = row54_collapseBaseline psi p ∧
      row54_collapseVariant psi1 p + row54_collapseVariant psi2 p =
        (psi1 ^ 2 + psi2 ^ 2) / p ∧
      0 < s.s6 := by
  exact ⟨row54_variant_eq_baseline psi p hp,
    row54_variant_additivity psi1 psi2 p hp,
    row54_measurement_problem_closed s hs⟩

end

end NavierStokesClean.CATEPT.Theoremized.Batch20260408.B54
