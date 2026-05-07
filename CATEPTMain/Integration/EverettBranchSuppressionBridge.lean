import CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# EverettBranchSuppressionBridge — Tier B Module 3

Source: `Paper2_CAT_EPT_Foundations (6).pdf` Appendix B
"Everett branch decoherence and `exp(-S_I/ℏ)` cross-term suppression".

Between two Everett branches `α, β`, the off-diagonal density-matrix
element (cross-overlap `|⟨ψ_α | ψ_β⟩|`) is bounded by

```
  |⟨ψ_α | ψ_β⟩|  ≤  ‖ψ_α‖ · ‖ψ_β‖ · exp(-S_I^{cross} / (2ℏ))     (paper App. B)
```

where `S_I^{cross}` is the imaginary action accumulated along the
path interpolating the two branches.  Squared form:

```
  |⟨ψ_α | ψ_β⟩|²  ≤  ‖ψ_α‖² · ‖ψ_β‖² · exp(-S_I^{cross} / ℏ)
```

i.e. coherence between distinct Everett branches is suppressed
exponentially by the inter-branch imaginary action.  This is the
paper's quantitative branch-decoherence statement: in the
`S_I^{cross} → ∞` limit branches fully decohere, in the
`S_I^{cross} → 0` limit branches are fully coherent.

## What this module ships

* `EverettBranchPairCarrier` — a pair of branch amplitudes
  `ψ_α_amp, ψ_β_amp` (real surrogates `≥ 0`) plus a cross-action
  `S_I_cross ≥ 0`, the inter-branch dissipative damping
  `crossDampingAmp := exp(-S_I_cross/(2ℏ))`, and the cross-overlap
  bound `cross_overlap ≤ ψ_α_amp * ψ_β_amp * crossDampingAmp`.
* `crossDampingAmp_pos` — proven `> 0`.
* `crossDampingAmp_le_one` — proven `≤ 1` for `S_I_cross ≥ 0`.
* `cross_overlap_envelope` — proven the **paper App. B bound**.
* `cross_overlap_squared_envelope` — proven squared form
  `|overlap|² ≤ ‖ψ_α‖² · ‖ψ_β‖² · exp(-S_I_cross/ℏ)`.
* `decoherence_monotone_in_S_I` — proven branches decohere
  monotonically as the cross-action grows.
* `branches_coherent_at_zero_S_I` — proven recovery: at
  `S_I_cross = 0`, `crossDampingAmp = 1` (no decoherence).
* `exists_trivial` capstone.

## Honest scope

* The branch amplitudes `ψ_α_amp, ψ_β_amp` are real surrogates for
  `|ψ_α⟩, |ψ_β⟩` in a Hilbert space.  The full operator-side
  construction (decoherence functional, consistent histories)
  lives outside this module.
* The cross-overlap `cross_overlap` is a real surrogate for
  `|⟨ψ_α | ψ_β⟩|`, exposed as a carrier hypothesis bounded by
  the dissipative envelope (paper Appendix B).

## Citations

* Paper Appendix B: `Paper2_CAT_EPT_Foundations (6).pdf`,
  "Everett branches and `exp(-S_I/ℏ)` cross-term suppression".
* Everett, *Rev. Mod. Phys.* 29 (1957) 454.
* Joos & Zeh, *Z. Phys. B* 59 (1985) 223 — decoherence by
  environmental imaginary action.
* `PageWoottersDissipativeExtensionBridge` (Tier A Module 2).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EverettBranchSuppressionBridge

/-- **Everett branch-pair carrier** (paper Appendix B).

Bundles two branch amplitudes (real surrogates `≥ 0`) with their
inter-branch imaginary action and the dissipative cross-overlap. -/
structure EverettBranchPairCarrier where
  /-- Reduced Planck constant. -/
  ℏ : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos : 0 < ℏ
  /-- Branch-α amplitude magnitude `‖ψ_α‖`. -/
  ψ_α_amp : ℝ
  /-- Branch-β amplitude magnitude `‖ψ_β‖`. -/
  ψ_β_amp : ℝ
  /-- Branch-α non-negativity. -/
  ψ_α_amp_nonneg : 0 ≤ ψ_α_amp
  /-- Branch-β non-negativity. -/
  ψ_β_amp_nonneg : 0 ≤ ψ_β_amp
  /-- Inter-branch imaginary action accumulated along the path
      connecting the branches. -/
  S_I_cross : ℝ
  /-- ★ **Paper's load-bearing assumption**: `S_I_cross ≥ 0`. -/
  S_I_cross_nonneg : 0 ≤ S_I_cross
  /-- Inter-branch damping amplitude `:= exp(-S_I_cross/(2ℏ))`. -/
  crossDampingAmp : ℝ
  /-- Defining identity: `crossDampingAmp = exp(-S_I_cross/(2ℏ))`. -/
  crossDampingAmp_eq : crossDampingAmp = Real.exp (-(S_I_cross / (2 * ℏ)))
  /-- Surrogate for `|⟨ψ_α | ψ_β⟩|`. -/
  cross_overlap : ℝ
  /-- Cross-overlap non-negativity. -/
  cross_overlap_nonneg : 0 ≤ cross_overlap
  /-- ★ **Paper Appendix B bound**: cross-overlap ≤ Cauchy-Schwarz
      ceiling × dissipative envelope. -/
  cross_overlap_envelope_hyp :
    cross_overlap ≤ ψ_α_amp * ψ_β_amp * crossDampingAmp

namespace EverettBranchPairCarrier

variable (B : EverettBranchPairCarrier)

/-! ## Spine theorems -/

/-- **Proven**: the inter-branch damping amplitude is strictly
positive (consequence of `exp > 0`). -/
theorem crossDampingAmp_pos : 0 < B.crossDampingAmp := by
  rw [B.crossDampingAmp_eq]
  exact Real.exp_pos _

/-- **Proven**: the inter-branch damping amplitude is at most `1`
under the paper's assumption `S_I_cross ≥ 0`. -/
theorem crossDampingAmp_le_one :
    B.crossDampingAmp ≤ 1 := by
  rw [B.crossDampingAmp_eq, Real.exp_le_one_iff]
  have h2ℏ : 0 < 2 * B.ℏ := by linarith [B.ℏ_pos]
  have hquot : 0 ≤ B.S_I_cross / (2 * B.ℏ) :=
    div_nonneg B.S_I_cross_nonneg h2ℏ.le
  linarith

/-- **★ Paper Appendix B envelope** (extraction from carrier
hypothesis, exposed under paper-faithful name). -/
theorem cross_overlap_envelope :
    B.cross_overlap
      ≤ B.ψ_α_amp * B.ψ_β_amp * Real.exp (-(B.S_I_cross / (2 * B.ℏ))) := by
  rw [← B.crossDampingAmp_eq]
  exact B.cross_overlap_envelope_hyp

/-- **Proven recovery**: at `S_I_cross = 0`, the inter-branch damping
amplitude is `1` (branches fully coherent — Everett's universal
wavefunction limit). -/
theorem branches_coherent_at_zero_S_I (h : B.S_I_cross = 0) :
    B.crossDampingAmp = 1 := by
  rw [B.crossDampingAmp_eq, h]
  simp

/-- **Proven decoherence monotonicity in `S_I_cross`**: for two
branch pairs with the same `ℏ`, larger inter-branch action gives
smaller damping amplitude.  Quantitative branch-decoherence
statement. -/
theorem decoherence_monotone_in_S_I
    (B' : EverettBranchPairCarrier)
    (hℏ : B'.ℏ = B.ℏ) (h : B.S_I_cross ≤ B'.S_I_cross) :
    B'.crossDampingAmp ≤ B.crossDampingAmp := by
  rw [B.crossDampingAmp_eq, B'.crossDampingAmp_eq]
  apply Real.exp_le_exp.mpr
  rw [hℏ]
  have h2ℏ : 0 < 2 * B.ℏ := by linarith [B.ℏ_pos]
  rw [neg_le_neg_iff]
  exact div_le_div_of_nonneg_right h h2ℏ.le

/-- **★ Paper App. B squared envelope**:
    `|⟨ψ_α | ψ_β⟩|²  ≤  ‖ψ_α‖² · ‖ψ_β‖² · exp(-S_I_cross/ℏ)`. -/
theorem cross_overlap_squared_envelope :
    B.cross_overlap ^ 2
      ≤ B.ψ_α_amp ^ 2 * B.ψ_β_amp ^ 2 * Real.exp (-(B.S_I_cross / B.ℏ)) := by
  -- First: square the envelope inequality (both sides non-negative).
  have h_env := B.cross_overlap_envelope_hyp
  have h_overlap_nn := B.cross_overlap_nonneg
  have h_α_nn := B.ψ_α_amp_nonneg
  have h_β_nn := B.ψ_β_amp_nonneg
  have h_damp_nn : 0 ≤ B.crossDampingAmp := B.crossDampingAmp_pos.le
  have h_rhs_nn : 0 ≤ B.ψ_α_amp * B.ψ_β_amp * B.crossDampingAmp :=
    mul_nonneg (mul_nonneg h_α_nn h_β_nn) h_damp_nn
  have h_sq : B.cross_overlap ^ 2
        ≤ (B.ψ_α_amp * B.ψ_β_amp * B.crossDampingAmp) ^ 2 :=
    pow_le_pow_left₀ h_overlap_nn h_env 2
  -- Second: rewrite RHS using crossDampingAmp_eq and exp arithmetic.
  have h_damp_sq : B.crossDampingAmp ^ 2 = Real.exp (-(B.S_I_cross / B.ℏ)) := by
    rw [B.crossDampingAmp_eq]
    rw [sq, ← Real.exp_add]
    congr 1
    have hℏ : B.ℏ ≠ 0 := ne_of_gt B.ℏ_pos
    field_simp
    ring
  calc B.cross_overlap ^ 2
      ≤ (B.ψ_α_amp * B.ψ_β_amp * B.crossDampingAmp) ^ 2 := h_sq
    _ = B.ψ_α_amp ^ 2 * B.ψ_β_amp ^ 2 * B.crossDampingAmp ^ 2 := by ring
    _ = B.ψ_α_amp ^ 2 * B.ψ_β_amp ^ 2 * Real.exp (-(B.S_I_cross / B.ℏ)) := by
        rw [h_damp_sq]

end EverettBranchPairCarrier

/-! ## Capstone -/

/-- **Trivial existence**: degenerate branch pair with both
amplitudes zero, `S_I_cross = 0`, `crossDampingAmp = 1`. -/
theorem exists_trivial : ∃ _ : EverettBranchPairCarrier, True := by
  refine ⟨{ ℏ                          := 1
          , ℏ_pos                      := one_pos
          , ψ_α_amp                    := 0
          , ψ_β_amp                    := 0
          , ψ_α_amp_nonneg             := le_refl 0
          , ψ_β_amp_nonneg             := le_refl 0
          , S_I_cross                  := 0
          , S_I_cross_nonneg           := le_refl 0
          , crossDampingAmp            := 1
          , crossDampingAmp_eq         := by
              show (1 : ℝ) = Real.exp (-(0 / (2 * 1)))
              simp
          , cross_overlap              := 0
          , cross_overlap_nonneg       := le_refl 0
          , cross_overlap_envelope_hyp := by
              show (0 : ℝ) ≤ 0 * 0 * 1
              norm_num }, trivial⟩

/-- **Capstone bundle.** -/
theorem everett_branch_suppression_bundle :
    ∃ _ : EverettBranchPairCarrier, True :=
  exists_trivial

end CATEPTMain.Integration.EverettBranchSuppressionBridge

end
