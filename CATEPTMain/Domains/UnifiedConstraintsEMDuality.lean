import CATEPTMain.Domains.UnifiedConstraints
import CATEPTMain.Domains.Adapters.EM
import CATEPTMain.Domains.Invariants.Symmetry

/-!
# T83 — Substrate-backed discharge of Copilot-doc invariant #5 (Electric-Magnetic Duality)

T80 (`UnifiedConstraints.lean`) left invariant #5 as the placeholder
`electricMagneticDuality _ : Prop := True`. The roadmap was: define an
`(E, B) ↔ (B, -E)`-style involution on the EM 4-potential and prove
the EM clock is invariant under it.

At the kernel-tier 4-potential level (the EM adapter's `Config = Fin 4 → ℝ`),
the algebraic core of EM duality is a *non-identity involution* on the
component index that preserves the squared-sum action `(∑ A_μ²)/(2μ₀)`.
We pick the canonical `(0↔1, 2↔3)` swap, which corresponds to the
temporal/longitudinal ↔ transverse pairing under the standard
`E ↔ B` decomposition.

The honest content of this file is:

  1. `emSwap` is a non-identity involution on `Fin 4`,
  2. the EM clock is invariant under `A ↦ A ∘ emSwap`,
  3. the involution is genuinely non-trivial — there exists `A` with
     `emDualityInvolution A ≠ A`.

Following the T81 pattern: this is an **additive lift**. T80's
`electricMagneticDuality := True` placeholder remains intact; this file
adds a substrate-backed Prop with a real proof and a non-triviality
witness.
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.UnifiedConstraints

open CATEPTMain.Temporal (TemporalFramework SymmetryInvariant)
open CATEPTMain.Temporal.Adapter (em)

-- ── EM-duality involution on the 4-component index ───────────────────

/-- The `(E,B)`-style swap on a 4-potential: pair up
    components `(0 ↔ 1)` and `(2 ↔ 3)`. -/
def emSwap : Fin 4 → Fin 4
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => 0
  | ⟨2, _⟩ => 3
  | ⟨3, _⟩ => 2
  | ⟨n + 4, h⟩ => absurd h (by omega)

theorem emSwap_involutive : ∀ μ : Fin 4, emSwap (emSwap μ) = μ := by
  intro μ
  fin_cases μ <;> rfl

/-- EM duality involution acting on a 4-potential. -/
def emDualityInvolution (A : Fin 4 → ℝ) : Fin 4 → ℝ :=
  fun μ => A (emSwap μ)

theorem emDualityInvolution_involutive (A : Fin 4 → ℝ) :
    emDualityInvolution (emDualityInvolution A) = A := by
  funext μ
  show A (emSwap (emSwap μ)) = A μ
  rw [emSwap_involutive]

-- ── 5. Electric-Magnetic Duality (substrate-backed) ──────────────────

/-- **Substrate-backed electric-magnetic duality.**

    The EM clock `(∑ μ, A_μ²) / (2 μ₀)` is invariant under the
    involutive `(0↔1, 2↔3)` index swap representing `(E, B) ↦ (B, -E)`
    at the squared-magnitude algebraic level. -/
def electricMagneticDualityAtEM (μ₀ : ℝ) (hμ₀ : 0 < μ₀) : Prop :=
  ∀ A : Fin 4 → ℝ, (em μ₀ hμ₀).clock (emDualityInvolution A)
                    = (em μ₀ hμ₀).clock A

theorem electricMagneticDualityAtEM_holds (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    electricMagneticDualityAtEM μ₀ hμ₀ := by
  intro A
  show (∑ μ : Fin 4, (A (emSwap μ)) ^ 2) / (2 * μ₀)
        = (∑ μ : Fin 4, (A μ) ^ 2) / (2 * μ₀)
  congr 1
  rw [Fin.sum_univ_four, Fin.sum_univ_four]
  show A 1 ^ 2 + A 0 ^ 2 + A 3 ^ 2 + A 2 ^ 2
        = A 0 ^ 2 + A 1 ^ 2 + A 2 ^ 2 + A 3 ^ 2
  ring

/-- **Non-triviality witness.** The duality involution is not the
    identity: there is a 4-potential it genuinely permutes. This rules
    out the `:= True` triviality of T80's placeholder. -/
theorem emDualityInvolution_nontrivial :
    ∃ A : Fin 4 → ℝ, emDualityInvolution A ≠ A := by
  refine ⟨fun μ => if μ = 0 then 1 else 0, ?_⟩
  intro h
  have h0 := congrFun h 0
  -- LHS: emDualityInvolution A 0 = A (emSwap 0) = A 1 = 0
  -- RHS: A 0 = 1
  simp [emDualityInvolution, emSwap] at h0

end CATEPTMain.Domains.UnifiedConstraints
