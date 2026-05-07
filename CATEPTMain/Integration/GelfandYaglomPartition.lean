import CATEPTMain.Integration.GelfandYaglomJacobi
import CATEPTMain.Integration.GelfandYaglomDetRatio
import CATEPTMain.Integration.GelfandYaglomAsymptotics
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Gel'fand–Yaglom Partition-Function Ratio (T-FF Phase 5)

Phase-5 honest content: the **inverse** of the Phase-3 GY
determinant-ratio, which is the harmonic-oscillator partition
function relative to the free-particle baseline:

  `Z_HO(ω, T) / Z_free(T)  =  T / ψ_ω(T)  =  ω T / sinh(ω T)`.

Concretely we expose `gyPartRatio ω T := T / gyJacobi ω T` and
prove the closed-form identification, free-particle baseline,
parity symmetry, and the cancellation identity
`gyDetRatio · gyPartRatio = 1` on the physical regime `T > 0`
(using strict positivity of `ψ_ω(T)` from Phase 4).

This is the standard reading of the GY ratio in equilibrium
statistical mechanics: the determinant ratio counts modes (the
spectral side) while its inverse is the partition function (the
canonical-ensemble side).

## Stages NOT discharged here

* High-temperature `ω T → 0` ↦ classical limit (`Z_HO/Z_free → 1`)
  and low-temperature `ω T → ∞` ↦ ground-state dominance
  (`Z_HO/Z_free ∼ 2 ω T · e^{−ω T}`) — both follow from
  `Real.sinh` asymptotics and are deferred to Phase 6+.
* Connection to the Mehler-kernel partition function via the
  oscillator heat kernel `Tr e^{−T H} = 1/(2 sinh(ω T/2))` —
  needs the trace-class argument.

## Phase status

Phase-5 — honest partition-ratio identity at the Jacobi-quotient
level, machine-checked, kernel-only `[propext, Classical.choice,
Quot.sound]` axioms.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.GelfandYaglomPartition

open CATEPTMain.Integration.GelfandYaglomJacobi
open CATEPTMain.Integration.GelfandYaglomDetRatio
open CATEPTMain.Integration.GelfandYaglomAsymptotics

noncomputable section

/-- **Gel'fand–Yaglom partition-function ratio** at the
    Jacobi-quotient level:
    `gyPartRatio ω T := T / ψ_ω(T)`, the inverse of `gyDetRatio`,
    playing the role of `Z_HO(ω,T) / Z_free(T)` once the
    spectral-zeta identification is in place. -/
def gyPartRatio (ω T : ℝ) : ℝ := T / gyJacobi ω T

/-- **Free-particle baseline**: at `ω = 0` the partition ratio is
    identically `1` for every `T ≠ 0`, since `ψ_0(T) = T`. -/
theorem gyPartRatio_omega_zero (T : ℝ) (hT : T ≠ 0) :
    gyPartRatio 0 T = 1 := by
  unfold gyPartRatio
  rw [gyJacobi_omega_zero]
  exact div_self hT

/-- **Closed-form identity**: for `ω ≠ 0` and `T ≠ 0`, the
    partition ratio equals `ω T / sinh(ω T)`. -/
theorem gyPartRatio_eq_inv_sinh_form (ω T : ℝ) (hω : ω ≠ 0) (hT : T ≠ 0) :
    gyPartRatio ω T = (ω * T) / Real.sinh (ω * T) := by
  unfold gyPartRatio gyJacobi
  rw [if_neg hω]
  field_simp

/-- **Parity symmetry** `ω ↦ −ω`: the partition ratio depends only
    on `|ω|`. -/
theorem gyPartRatio_neg_omega (ω T : ℝ) :
    gyPartRatio (-ω) T = gyPartRatio ω T := by
  unfold gyPartRatio
  rw [gyJacobi_neg_omega]

/-- **Source-endpoint degeneracy**: at `T = 0` the ratio
    `0 / ψ_ω(0)` is `0` by Lean's division convention. -/
theorem gyPartRatio_T_zero (ω : ℝ) :
    gyPartRatio ω 0 = 0 := by
  unfold gyPartRatio
  simp

/-- **Cancellation identity**: on the physical regime `T > 0`, the
    determinant ratio and partition ratio are reciprocals,
        `gyDetRatio ω T · gyPartRatio ω T = 1`,
    using strict positivity `ψ_ω(T) > 0` (Phase-4) to ensure
    non-vanishing of the denominators. -/
theorem gyDetRatio_mul_partRatio_eq_one (ω T : ℝ) (hT : 0 < T) :
    gyDetRatio ω T * gyPartRatio ω T = 1 := by
  unfold gyDetRatio gyPartRatio
  have hψ : gyJacobi ω T ≠ 0 := ne_of_gt (gyJacobi_pos ω T hT)
  have hT' : T ≠ 0 := ne_of_gt hT
  field_simp

end

end CATEPTMain.Integration.GelfandYaglomPartition
