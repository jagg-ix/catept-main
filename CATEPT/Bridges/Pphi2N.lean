import CATEPT.CATEPT.Foundations

/-!
# CAT/EPT ↔ pphi2N (O(N) linear sigma model) — compatibility bridge

The pphi2N package formalises the large-N mass gap of the O(N) φ⁴ linear
sigma model via Hubbard–Stratonovich. Its output for the CAT/EPT framework
is a single real datum per cutoff: the imaginary part `S_I ≥ 0` of the
regularised effective action.

**Bridge claim** (this file):
Any `Pphi2NInput ≡ (N, S_I, S_I ≥ 0)` admits the CAT/EPT entropic-time
identification `τ_ent = S_I / ℏ` with `τ_ent ≥ 0`.

**Axioms**: none beyond the Lean kernel (`propext`, `Classical.choice`,
`Quot.sound`). No physical-identification axioms are introduced in this
bridge — the pphi2N-specific content enters as data (`Pphi2NInput`), not as
axioms.
-/

set_option autoImplicit false

namespace CATEPT.Bridges.Pphi2N

open CATEPT

/-- Abstract handle for a pphi2N output. The concrete nonneg imaginary
action is supplied by the pphi2N package's mass-gap certificate; this
bridge shows the CAT/EPT identities apply to *any* such witness. -/
structure Pphi2NInput where
  /-- Rank of the O(N) internal symmetry. -/
  N : ℕ
  /-- Imaginary part of the regularised effective action, produced by
  pphi2N's Hubbard–Stratonovich large-N computation. -/
  S_I : ℝ
  /-- pphi2N's mass-gap certificate delivers `S_I ≥ 0`. -/
  S_I_nonneg : 0 ≤ S_I

/-- Entropic proper time for a pphi2N input, given a positive `ℏ`. -/
noncomputable def tauEnt (p : Pphi2NInput) (ℏ : ℝ) : ℝ :=
  entropic_time ℏ p.S_I

/-- CAT/EPT identity `τ_ent = S_I / ℏ` on pphi2N data. -/
theorem tauEnt_eq_div (p : Pphi2NInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    tauEnt p ℏ = p.S_I / ℏ :=
  eq003_entropic_time_def ℏ p.S_I hℏ

/-- Nonnegativity of entropic proper time on pphi2N data. -/
theorem tauEnt_nonneg (p : Pphi2NInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    0 ≤ tauEnt p ℏ :=
  eq003_entropic_time_nonneg ℏ p.S_I hℏ p.S_I_nonneg

/-- Linearity of entropic proper time in the imaginary-action argument,
specialised to pphi2N inputs. Useful when combining two large-N sectors. -/
theorem tauEnt_linear (p₁ p₂ : Pphi2NInput) (ℏ : ℝ) (hℏ : 0 < ℏ) :
    entropic_time ℏ (p₁.S_I + p₂.S_I)
      = entropic_time ℏ p₁.S_I + entropic_time ℏ p₂.S_I :=
  eq003_entropic_time_linear ℏ p₁.S_I p₂.S_I hℏ

end CATEPT.Bridges.Pphi2N
