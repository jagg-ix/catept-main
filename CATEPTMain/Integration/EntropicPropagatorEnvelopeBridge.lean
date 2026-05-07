import CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# EntropicPropagatorEnvelopeBridge — Tier B Module 2

Source: `Paper2_CAT_EPT_Foundations (6).pdf` §3.3
"Entropic propagator and damping envelope".

The paper combines the UV coercivity bound (§3.2 / Prop 1) with the
path-integral magnitude formula

```
  K_τ(φ_f, φ_i)  =  ∫ Dφ exp(iS_R[φ]/ℏ - S_I[φ]/ℏ)
                 =  exp(-S_I[γ_*]/ℏ) · K_τ^free(φ_f, φ_i)              (saddle-point factorisation)
```

to obtain the **propagator-level envelope inequality**

```
  |K_τ(φ_f, φ_i)|  ≤  exp(-C · ‖φ_i‖² / ℏ) · K_τ^free(φ_f, φ_i)        (paper §3.3 envelope)
```

i.e. the entropic propagator is bounded above by the free propagator
times the UV-coercivity envelope.  This is the propagator-level
operationalisation of Tier A Module 3's Proposition 1.

## What this module ships

* `EntropicPropagatorEnvelopeCarrier Φ` — extends `UVCoercivityCarrier`
  with a real-valued propagator magnitude `K_magnitude` and a free
  reference `K_free_magnitude`, plus the dissipative factorisation
  hypothesis `K = path_integral_damping · K_free`.
* `K_magnitude_nonneg` — proven the propagator magnitude is `≥ 0`.
* `K_envelope_bound` — proven the **paper §3.3 envelope inequality**.
* `K_le_K_free` — proven `K ≤ K_free` (entropic propagator never
  exceeds the free one).
* `K_strict_envelope` — proven strict inequality at non-zero `φ`.
* `exists_trivial` capstone.

## Honest scope

* `K_magnitude` is a real-valued surrogate for the modulus
  `|K_τ(φ_f, φ_i)|` of the propagator amplitude.  The full
  saddle-point derivation uses functional analysis (steepest descent)
  and lives in `MultiModeSourcedGaussian.lean` and friends.
* The factorisation hypothesis `K = damping · K_free` is the paper's
  saddle-point form (paper eq. 14, §3.3) and is exposed as a
  carrier hypothesis here, not derived from a path integral.

## Citations

* Paper §3.3: `Paper2_CAT_EPT_Foundations (6).pdf`,
  "Entropic propagator and damping envelope".
* `UVCoercivityAbsoluteDampingBridge` (Tier A Module 3).
* `catept-core/PathIntegrals.lean` (path_integral_damping).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge

open CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge
open CATEPTMain.CATEPT.CATEPT

/-- **Entropic propagator envelope carrier** (paper §3.3).

Bundles UV coercivity (Tier A Module 3) with a real-valued
propagator magnitude and the saddle-point dissipative factorisation
`K = path_integral_damping · K_free`. -/
structure EntropicPropagatorEnvelopeCarrier (Φ : Type*) [NormedAddCommGroup Φ] where
  /-- Underlying UV-coercivity witness (provides `C, ℏ, S_I`,
      `uv_coercivity_bound`). -/
  uv : UVCoercivityCarrier Φ
  /-- Magnitude of the entropic propagator at the saddle field
      configuration `φ`.  Real surrogate for `|K_τ(φ_f, φ_i)|`. -/
  K_magnitude : Φ → ℝ
  /-- Magnitude of the free (un-damped) propagator. -/
  K_free_magnitude : Φ → ℝ
  /-- Free propagator magnitude is non-negative. -/
  K_free_nonneg : ∀ φ, 0 ≤ K_free_magnitude φ
  /-- ★ **Paper §3.3 saddle-point factorisation**:
      `|K_τ| = exp(-S_I/ℏ) · |K_τ^free|`. -/
  K_dissipative_factorisation :
    ∀ φ : Φ,
      K_magnitude φ = path_integral_damping uv.ℏ (uv.S_I φ) * K_free_magnitude φ

namespace EntropicPropagatorEnvelopeCarrier

variable {Φ : Type*} [NormedAddCommGroup Φ]
variable (E : EntropicPropagatorEnvelopeCarrier Φ)

/-! ## Spine theorems -/

/-- **Proven**: the entropic propagator magnitude is non-negative. -/
theorem K_magnitude_nonneg (φ : Φ) : 0 ≤ E.K_magnitude φ := by
  rw [E.K_dissipative_factorisation]
  apply mul_nonneg
  · exact (E.uv.paper_proposition_1_damping_pos φ).le
  · exact E.K_free_nonneg φ

/-- **★ Paper §3.3 envelope bound**:
    `|K_τ(φ_f, φ_i)|  ≤  exp(-C · ‖φ‖² / ℏ) · K_τ^free(φ_f, φ_i)`. -/
theorem K_envelope_bound (φ : Φ) :
    E.K_magnitude φ
      ≤ Real.exp (- E.uv.C * ‖φ‖ ^ 2 / E.uv.ℏ) * E.K_free_magnitude φ := by
  rw [E.K_dissipative_factorisation]
  apply mul_le_mul_of_nonneg_right
  · exact E.uv.paper_proposition_1 φ
  · exact E.K_free_nonneg φ

/-- **Proven**: the entropic propagator never exceeds the free
propagator (since damping `≤ 1`). -/
theorem K_le_K_free (φ : Φ) :
    E.K_magnitude φ ≤ E.K_free_magnitude φ := by
  rw [E.K_dissipative_factorisation]
  have hdamp_nn : 0 ≤ path_integral_damping E.uv.ℏ (E.uv.S_I φ) :=
    (E.uv.paper_proposition_1_damping_pos φ).le
  have hdamp_le_one : path_integral_damping E.uv.ℏ (E.uv.S_I φ) ≤ 1 := by
    have := E.uv.paper_proposition_1_damping_le_one φ
    have hpos := E.uv.paper_proposition_1_damping_pos φ
    have habs : |path_integral_damping E.uv.ℏ (E.uv.S_I φ)|
        = path_integral_damping E.uv.ℏ (E.uv.S_I φ) :=
      abs_of_pos hpos
    linarith [habs ▸ this]
  calc path_integral_damping E.uv.ℏ (E.uv.S_I φ) * E.K_free_magnitude φ
      ≤ 1 * E.K_free_magnitude φ := by
        exact mul_le_mul_of_nonneg_right hdamp_le_one (E.K_free_nonneg φ)
    _ = E.K_free_magnitude φ := one_mul _

/-- **Proven strict suppression at non-zero `φ`**: when `0 < ‖φ‖`,
the entropic propagator is *strictly* below the free propagator
(paper's "high-`k` modes are suppressed faster than any power"). -/
theorem K_strict_envelope (φ : Φ) (hφ : 0 < ‖φ‖)
    (hKfree : 0 < E.K_free_magnitude φ) :
    E.K_magnitude φ < E.K_free_magnitude φ := by
  rw [E.K_dissipative_factorisation]
  have hstrict : path_integral_damping E.uv.ℏ (E.uv.S_I φ) < 1 :=
    E.uv.paper_proposition_1_strict φ hφ
  calc path_integral_damping E.uv.ℏ (E.uv.S_I φ) * E.K_free_magnitude φ
      < 1 * E.K_free_magnitude φ :=
        mul_lt_mul_of_pos_right hstrict hKfree
    _ = E.K_free_magnitude φ := one_mul _

/-- **Proven** dissipative-factor positivity at the propagator level. -/
theorem K_pos_iff (φ : Φ) :
    0 < E.K_magnitude φ ↔ 0 < E.K_free_magnitude φ := by
  rw [E.K_dissipative_factorisation]
  constructor
  · intro h
    have hdamp_nn : 0 ≤ path_integral_damping E.uv.ℏ (E.uv.S_I φ) :=
      (E.uv.paper_proposition_1_damping_pos φ).le
    rcases lt_or_eq_of_le (E.K_free_nonneg φ) with hKfree | hKfree
    · exact hKfree
    · -- if K_free = 0 then product is 0, contradicting h
      rw [← hKfree, mul_zero] at h
      exact absurd h (lt_irrefl 0)
  · intro h
    exact mul_pos (E.uv.paper_proposition_1_damping_pos φ) h

end EntropicPropagatorEnvelopeCarrier

/-! ## Capstone -/

/-- **Trivial existence**: a degenerate envelope carrier on `ℝ` with
`K_free := 0` everywhere (so both `K = 0` and the envelope holds
vacuously). -/
theorem exists_trivial : ∃ _ : EntropicPropagatorEnvelopeCarrier ℝ, True := by
  let uv : UVCoercivityCarrier ℝ :=
    { C := 1
    , C_pos := one_pos
    , S_I := fun φ => φ ^ 2
    , ℏ := 1
    , ℏ_pos := one_pos
    , uv_coercivity_bound := by
        intro φ
        show (1 : ℝ) * ‖φ‖ ^ 2 ≤ φ ^ 2
        rw [one_mul, Real.norm_eq_abs, sq_abs] }
  refine ⟨{ uv := uv
          , K_magnitude := fun _ => 0
          , K_free_magnitude := fun _ => 0
          , K_free_nonneg := by intro _; exact le_refl 0
          , K_dissipative_factorisation := by
              intro φ
              show (0 : ℝ) = path_integral_damping uv.ℏ (uv.S_I φ) * 0
              ring }, trivial⟩

/-- **Capstone bundle.** -/
theorem entropic_propagator_envelope_bundle :
    ∃ _ : EntropicPropagatorEnvelopeCarrier ℝ, True :=
  exists_trivial

end CATEPTMain.Integration.EntropicPropagatorEnvelopeBridge

end
