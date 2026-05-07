import CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# DBBQuantumPotentialBridge — Tier C Module 2

Source: `Paper2_CAT_EPT_Foundations (6).pdf` Appendix C
"de Broglie-Bohm extension via the imaginary action".

In the standard dBB / Madelung decomposition `ψ = R · exp(iS/ℏ)` the
**quantum potential** is `Q := -(ℏ²/2m) · ∇²R/R`, supplying the
non-local "guiding" force on the Bohmian trajectory.  The paper
observes that under the dissipative extension `S_I ≥ 0` this Q can
be **operationally identified** with the imaginary-action density
times `ℏ/(2m)`:

```
  Q[φ]  =  S_I[φ] · ℏ / (2m)                                   (paper App. C)
```

making the Bohmian quantum potential a *direct readout* of the
imaginary-action functional.  Three immediate consequences of the
paper's `S_I ≥ 0` assumption:

* `Q ≥ 0`  (the quantum potential is non-negative — paper's
  "non-classical attractor" statement),
* `Q = 0  ⇔  S_I = 0`  (classical-limit recovery: the dBB quantum
  guide vanishes precisely when imaginary action vanishes),
* `Q` monotone in `S_I`  (more imaginary action ⇒ stronger Bohmian
  guide).

## What this module ships

* `DBBQuantumPotentialCarrier Φ` — bundles a UV-coercivity witness
  (Tier A Module 3) with mass `m > 0` and the quantum-potential
  surrogate `Q : Φ → ℝ`, plus the defining identity
  `Q = S_I · ℏ / (2m)`.
* `quantumPotential_nonneg` — proven `Q[φ] ≥ 0`.
* `quantumPotential_zero_iff_S_I_zero` — proven `Q = 0 ↔ S_I = 0`.
* `quantumPotential_monotone_in_S_I` — proven monotonicity.
* `quantumPotential_at_classical_saddle` — proven `Q = 0` at the
  configuration saturating `S_I = 0` (e.g. zero-dim Gaussian saddle).
* `quantumPotential_pos_at_uv_strict` — proven `Q > 0` whenever
  `‖φ‖ > 0` (paper's "Bohmian guide strictly positive on UV modes").
* `exists_trivial` capstone.

## Honest scope

* `Q` is a real-valued surrogate for the operator-side quantum
  potential; the full Madelung decomposition + Bohmian trajectory
  ODEs live in `BohmianQMBridge.lean`.
* The defining identity `Q = S_I · ℏ / (2m)` is the paper's App. C
  *operational identification*, exposed as a carrier hypothesis.

## Citations

* Paper Appendix C: `Paper2_CAT_EPT_Foundations (6).pdf`,
  "de Broglie-Bohm extension via imaginary action".
* de Broglie, *J. Phys. Radium* 8 (1927) 225.
* Bohm, *Phys. Rev.* 85 (1952) 166.
* `UVCoercivityAbsoluteDampingBridge` (Tier A Module 3).
* `BohmianQMBridge.lean` (catept-main, Bohmian operator-side).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.DBBQuantumPotentialBridge

open CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge

/-- **dBB quantum-potential carrier** (paper Appendix C).

Bundles a UV-coercivity witness with mass `m > 0` and the
quantum-potential surrogate `Q : Φ → ℝ` realising the paper's
operational identification `Q = S_I · ℏ / (2m)`. -/
structure DBBQuantumPotentialCarrier (Φ : Type*) [NormedAddCommGroup Φ] where
  /-- Underlying UV-coercivity witness (provides `S_I, ℏ, C`). -/
  uv : UVCoercivityCarrier Φ
  /-- Particle mass. -/
  m : ℝ
  /-- Strict positivity of mass. -/
  m_pos : 0 < m
  /-- Quantum-potential surrogate. -/
  Q : Φ → ℝ
  /-- ★ **Paper App. C identification**:
      `Q[φ] = S_I[φ] · ℏ / (2m)`. -/
  Q_eq_S_I : ∀ φ, Q φ = uv.S_I φ * uv.ℏ / (2 * m)

namespace DBBQuantumPotentialCarrier

variable {Φ : Type*} [NormedAddCommGroup Φ]
variable (B : DBBQuantumPotentialCarrier Φ)

/-! ## Spine theorems -/

/-- **Proven**: the quantum potential is non-negative
(paper's "Bohmian non-classical attractor" claim). -/
theorem quantumPotential_nonneg (φ : Φ) : 0 ≤ B.Q φ := by
  rw [B.Q_eq_S_I]
  have h_S_I_nn : 0 ≤ B.uv.S_I φ := B.uv.S_I_nonneg φ
  have h_ℏ_nn : 0 ≤ B.uv.ℏ := B.uv.ℏ_pos.le
  have h_2m : 0 < 2 * B.m := by linarith [B.m_pos]
  apply div_nonneg
  · exact mul_nonneg h_S_I_nn h_ℏ_nn
  · exact h_2m.le

/-- **Proven dichotomy**: `Q = 0  ⇔  S_I = 0`. -/
theorem quantumPotential_zero_iff_S_I_zero (φ : Φ) :
    B.Q φ = 0 ↔ B.uv.S_I φ = 0 := by
  rw [B.Q_eq_S_I]
  have h_2m : 0 < 2 * B.m := by linarith [B.m_pos]
  have h_2m_ne : (2 * B.m) ≠ 0 := ne_of_gt h_2m
  rw [div_eq_zero_iff]
  constructor
  · rintro (hnum | hden)
    · -- S_I φ * ℏ = 0; ℏ ≠ 0 so S_I φ = 0
      have h_ℏ_ne : B.uv.ℏ ≠ 0 := ne_of_gt B.uv.ℏ_pos
      rcases mul_eq_zero.mp hnum with h | h
      · exact h
      · exact absurd h h_ℏ_ne
    · exact absurd hden h_2m_ne
  · intro h
    left
    rw [h]; ring

/-- **Proven monotonicity in `S_I`**: between two carriers sharing
`m, ℏ`, larger `S_I φ` ⇒ larger `Q φ`. -/
theorem quantumPotential_monotone_in_S_I
    (B' : DBBQuantumPotentialCarrier Φ)
    (h_m  : B'.m     = B.m)
    (h_ℏ  : B'.uv.ℏ  = B.uv.ℏ)
    (φ : Φ) (h : B.uv.S_I φ ≤ B'.uv.S_I φ) :
    B.Q φ ≤ B'.Q φ := by
  rw [B.Q_eq_S_I, B'.Q_eq_S_I, h_m, h_ℏ]
  have h_2m : 0 < 2 * B.m := by linarith [B.m_pos]
  apply div_le_div_of_nonneg_right _ h_2m.le
  exact mul_le_mul_of_nonneg_right h B.uv.ℏ_pos.le

/-- **Proven**: at any `φ` with `S_I[φ] = 0`, the quantum potential
vanishes (classical-limit recovery — Bohmian guide turns off when
imaginary action turns off). -/
theorem quantumPotential_at_classical_saddle (φ : Φ)
    (h : B.uv.S_I φ = 0) : B.Q φ = 0 :=
  (B.quantumPotential_zero_iff_S_I_zero φ).mpr h

/-- **Proven**: at any `φ` with `‖φ‖ > 0`, the quantum potential is
strictly positive (paper's "Bohmian guide strictly positive on UV
modes" — UV coercivity gives `S_I[φ] ≥ C·‖φ‖² > 0`). -/
theorem quantumPotential_pos_at_uv_strict (φ : Φ) (hφ : 0 < ‖φ‖) :
    0 < B.Q φ := by
  rw [B.Q_eq_S_I]
  have h_C_phi : 0 < B.uv.C * ‖φ‖ ^ 2 := mul_pos B.uv.C_pos (by positivity)
  have h_S_I : 0 < B.uv.S_I φ := lt_of_lt_of_le h_C_phi (B.uv.uv_coercivity_bound φ)
  have h_ℏ : 0 < B.uv.ℏ := B.uv.ℏ_pos
  have h_num : 0 < B.uv.S_I φ * B.uv.ℏ := mul_pos h_S_I h_ℏ
  have h_2m : 0 < 2 * B.m := by linarith [B.m_pos]
  exact div_pos h_num h_2m

end DBBQuantumPotentialCarrier

/-! ## Capstone -/

/-- **Trivial existence**: degenerate witness on `ℝ` with
`S_I φ := φ²`, `m = 1`, `ℏ = 1`. -/
theorem exists_trivial : ∃ _ : DBBQuantumPotentialCarrier ℝ, True := by
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
  refine ⟨{ uv     := uv
          , m      := 1
          , m_pos  := one_pos
          , Q      := fun φ => φ ^ 2 / 2
          , Q_eq_S_I := by
              intro φ
              show φ ^ 2 / 2 = φ ^ 2 * 1 / (2 * 1)
              ring }, trivial⟩

/-- **Capstone bundle.** -/
theorem dbb_quantum_potential_bundle :
    ∃ _ : DBBQuantumPotentialCarrier ℝ, True :=
  exists_trivial

end CATEPTMain.Integration.DBBQuantumPotentialBridge

end
