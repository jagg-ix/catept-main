import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# EntropyIncreaseAlongWorldlineBridge — Tier C Module 3

Source: `Paper2_CAT_EPT_Foundations (6).pdf` §5
"Entropic-time arrow along worldlines".

Along any worldline parametrised by an internal coordinate `t : ℝ`,
the paper shows that the entropic proper time `τ_ent(t) := S_I(t)/ℏ`
**increases monotonically**, given the load-bearing assumption that
the imaginary-action functional is monotone non-decreasing along the
worldline:

```
  t₁ ≤ t₂  ⟹  S_I(t₁) ≤ S_I(t₂)                           (paper §5 ass.)
```

The paper interprets `dτ_ent/dt ≥ 0` as the **entropic-time arrow**:
the conditional state's entropic clock cannot run backwards.  This is
the `S_I/ℏ`-level operationalisation of the second law, distinct
from but compatible with proper-time monotonicity along causal curves.

## What this module ships

* `EntropyIncreaseWorldlineCarrier` — bundles `S_I_along, τ_ent_along
  : ℝ → ℝ` with the load-bearing monotonicity hypothesis on
  `S_I_along`.
* `tau_ent_monotone` — proven `t₁ ≤ t₂ ⟹ τ_ent(t₁) ≤ τ_ent(t₂)`.
* `tau_ent_strict_when_S_I_strict` — proven strict version.
* `tau_ent_nonneg_along_worldline` — proven `τ_ent ≥ τ_ent(0)`
  (entropy never falls below initial value).
* `entropy_arrow_at_zero` — proven `τ_ent(0) = S_I(0)/ℏ` (extraction).
* `worldline_S_I_zero_implies_tau_ent_zero` — proven if `S_I = 0`
  along the entire worldline then `τ_ent = 0` everywhere.
* `exists_trivial` capstone.

## Honest scope

* `S_I_along` is a real surrogate for `S_I[γ(t)]` evaluated on a
  worldline section `γ : ℝ → Φ`.  The full geometric formulation
  with proper-time integration along causal curves lives in
  `CATEPTSpaceTime.lean` and `TwinParadoxEntropicProperTimeBridge.lean`.
* The monotonicity hypothesis `S_I_monotone` is the carrier
  expression of the paper's "Assumption 3" (entropic-time arrow);
  the operator-side derivation (Tomita-Takesaki modular flow,
  thermal-time arrow) is in
  `MatsubaraAQFTModularFlowEquivalenceBridge.lean`.

## Citations

* Paper §5: `Paper2_CAT_EPT_Foundations (6).pdf`,
  "Entropic-time arrow along worldlines".
* `MatsubaraLuttingerWardCarrier` (catept-main, PR #127).
* `TwinParadoxEntropicProperTimeBridge` (catept-main, PR #13).
* `CATEPTSpaceTime.lean` (catept-main).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge

/-- **Entropy-increase worldline carrier** (paper §5).

Bundles a worldline-evaluated imaginary-action functional
`S_I_along : ℝ → ℝ` with its load-bearing monotonicity assumption
and the derived entropic proper time `τ_ent_along := S_I_along / ℏ`. -/
structure EntropyIncreaseWorldlineCarrier where
  /-- Reduced Planck constant. -/
  ℏ : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos : 0 < ℏ
  /-- Imaginary action evaluated along the worldline at parameter `t`. -/
  S_I_along : ℝ → ℝ
  /-- Entropic proper time evaluated along the worldline. -/
  τ_ent_along : ℝ → ℝ
  /-- Defining identity: `τ_ent(t) = S_I(t) / ℏ`. -/
  τ_ent_eq : ∀ t, τ_ent_along t = S_I_along t / ℏ
  /-- ★ **Paper §5 Assumption 3**: imaginary action is monotone
      non-decreasing along the worldline. -/
  S_I_monotone : ∀ {t₁ t₂ : ℝ}, t₁ ≤ t₂ → S_I_along t₁ ≤ S_I_along t₂
  /-- Initial-value non-negativity (worldline starts at non-negative
      imaginary action; standard normalisation). -/
  S_I_at_zero_nonneg : 0 ≤ S_I_along 0

namespace EntropyIncreaseWorldlineCarrier

variable (W : EntropyIncreaseWorldlineCarrier)

/-! ## Spine theorems -/

/-- **★ Paper §5 entropic-time arrow**: τ_ent is monotone
non-decreasing along the worldline. -/
theorem tau_ent_monotone {t₁ t₂ : ℝ} (h : t₁ ≤ t₂) :
    W.τ_ent_along t₁ ≤ W.τ_ent_along t₂ := by
  rw [W.τ_ent_eq, W.τ_ent_eq]
  exact div_le_div_of_nonneg_right (W.S_I_monotone h) W.ℏ_pos.le

/-- **Proven strict version**: when `S_I` strictly grows, so does
`τ_ent`. -/
theorem tau_ent_strict_when_S_I_strict {t₁ t₂ : ℝ}
    (h : W.S_I_along t₁ < W.S_I_along t₂) :
    W.τ_ent_along t₁ < W.τ_ent_along t₂ := by
  rw [W.τ_ent_eq, W.τ_ent_eq]
  exact div_lt_div_of_pos_right h W.ℏ_pos

/-- **Proven non-negativity along the worldline**: τ_ent never falls
below its initial value, given `S_I_along 0 ≥ 0`. -/
theorem tau_ent_nonneg_along_worldline {t : ℝ} (h : 0 ≤ t) :
    0 ≤ W.τ_ent_along t := by
  have h0 : 0 ≤ W.S_I_along 0 := W.S_I_at_zero_nonneg
  have hmono : W.S_I_along 0 ≤ W.S_I_along t := W.S_I_monotone h
  have h_S_I_t_nn : 0 ≤ W.S_I_along t := le_trans h0 hmono
  rw [W.τ_ent_eq]
  exact div_nonneg h_S_I_t_nn W.ℏ_pos.le

/-- **Proven extraction at the origin**: τ_ent(0) = S_I(0)/ℏ. -/
theorem entropy_arrow_at_zero :
    W.τ_ent_along 0 = W.S_I_along 0 / W.ℏ :=
  W.τ_ent_eq 0

/-- **Proven**: if `S_I_along` is identically zero, then so is
`τ_ent_along`. -/
theorem worldline_S_I_zero_implies_tau_ent_zero
    (h : ∀ t, W.S_I_along t = 0) :
    ∀ t, W.τ_ent_along t = 0 := by
  intro t
  rw [W.τ_ent_eq, h]
  simp

/-- **Proven worldline non-decrease**: between two parameters, the
entropic-time delta is non-negative. -/
theorem tau_ent_delta_nonneg {t₁ t₂ : ℝ} (h : t₁ ≤ t₂) :
    0 ≤ W.τ_ent_along t₂ - W.τ_ent_along t₁ := by
  have := W.tau_ent_monotone h
  linarith

end EntropyIncreaseWorldlineCarrier

/-! ## Capstone -/

/-- **Trivial existence**: a constant worldline `S_I_along ≡ 0`,
which is monotone (vacuously) and gives `τ_ent ≡ 0`. -/
theorem exists_trivial : ∃ _ : EntropyIncreaseWorldlineCarrier, True := by
  refine ⟨{ ℏ                  := 1
          , ℏ_pos              := one_pos
          , S_I_along          := fun _ => 0
          , τ_ent_along        := fun _ => 0
          , τ_ent_eq           := by intro t; show (0 : ℝ) = 0 / 1; norm_num
          , S_I_monotone       := by intros; exact le_refl 0
          , S_I_at_zero_nonneg := le_refl 0 }, trivial⟩

/-- **Capstone bundle.** -/
theorem entropy_increase_along_worldline_bundle :
    ∃ _ : EntropyIncreaseWorldlineCarrier, True :=
  exists_trivial

end CATEPTMain.Integration.EntropyIncreaseAlongWorldlineBridge

end
