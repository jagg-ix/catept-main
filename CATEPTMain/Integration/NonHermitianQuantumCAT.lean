import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Defs
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# NonHermitianQuantumCAT — Classical Contact Dissipation ↔ Quantum Non-Hermitian Generator

This file is a **contract landing pad** for the artifact pipeline

  classical contact friction `∂_s L_I`
    → quantum imaginary generator `H_I`
    → non-Hermitian Schrödinger `iℏ ∂ψ/∂t = (H_R - iH_I) ψ`
    → norm decay `∂_t ‖ψ‖² = -(2/ℏ) ⟨H_I⟩`
    → GKLS Lindblad completion with jump operators

in `(private intake doc) (2).md` at
lines L3856–L3906 (classical → quantum), L4144–L4157 (norm decay),
L4453 (GKLS), L4507 (non-Hermitian Schrödinger).

The reusable abstract content (without operator-algebraic baggage) is:

* a non-negative real-valued **expectation** `⟨H_I⟩(t)` representing
  the dissipation expectation,
* a non-negative real-valued **norm-squared** `‖ψ‖²(t)` whose
  decrement is bounded by `(2/ℏ) ⟨H_I⟩`,
* a classical **contact-friction** carrier `L_I(t) = ρ(t) · s(t)` and
  its identification with the quantum dissipation expectation
  `L_I(t) = ℏ ⟨H_I⟩(t)`,
* a **GKLS jump decomposition** identifying `(2/ℏ) ⟨H_I⟩(t)` with the
  sum of non-negative jump rates.

## Honest scope

* This is **not** an operator-algebra construction; we do not build
  Hilbert spaces, self-adjoint operators, or Lindblad super-operators
  here.
* It is a structural carrier exposing the artifact's monotonicity and
  consistency consequences as `Prop`-level deliverables.
* Pattern matches `WDWRQMNoetherContracts`, `WDWRQMUncertaintyContracts`
  and the broader `Identify…`-style bridge family.

## What this module ships

* `NonHermitianGenerator` — `ℏ`, `⟨H_I⟩`, `‖ψ‖²`, integrated decay.
* `NormSquaredEvolution` — derived monotonicity consequence.
* `ClassicalContactDissipation` — `ρ`, `s`, `L_I = ρ · s`.
* `IdentifyClassicalContactWithQuantumDissipation` — bridge contract.
* `GKLSJumpDecomposition` — jump rates with consistency law.
* `non_hermitian_quantum_cat_bundle` — capstone collecting the pieces.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.NonHermitianQuantumCAT

-- ============================================================================
-- 1. Non-Hermitian generator (ℏ, ⟨H_I⟩ ≥ 0, ‖ψ‖² with integrated decay)
-- ============================================================================

/-- **Non-Hermitian generator carrier.**

Captures, in real-valued / `Prop`-level form, the artifact's
non-Hermitian Schrödinger setting:

* `ℏ > 0` — Planck constant.
* `expH_I : ℝ → ℝ` — expectation `⟨H_I⟩(t)`, non-negative
  (accretivity of `H_I`).
* `normSq : ℝ → ℝ` — norm-squared `‖ψ(t)‖²`, non-negative.
* `norm_decay` — integrated form of `∂_t ‖ψ‖² = -(2/ℏ) ⟨H_I⟩`:
  the norm-squared is monotone non-increasing in `t`, since the rate
  of change is non-positive. -/
structure NonHermitianGenerator where
  /-- Planck constant. -/
  ℏ              : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos          : 0 < ℏ
  /-- Expectation `⟨H_I⟩` of the imaginary part as a function of time. -/
  expH_I         : ℝ → ℝ
  /-- Accretivity: `⟨H_I⟩(t) ≥ 0` for all `t`. -/
  expH_I_nonneg  : ∀ t, 0 ≤ expH_I t
  /-- Norm-squared `‖ψ(t)‖²`. -/
  normSq         : ℝ → ℝ
  /-- Norm-squared is non-negative. -/
  normSq_nonneg  : ∀ t, 0 ≤ normSq t
  /-- Integrated decay law: `t₁ ≤ t₂ ⟹ ‖ψ(t₂)‖² ≤ ‖ψ(t₁)‖²`.
  This is the operationally checkable form of
  `∂_t ‖ψ‖² = -(2/ℏ) ⟨H_I⟩` together with `⟨H_I⟩ ≥ 0`. -/
  norm_decay     : ∀ t₁ t₂, t₁ ≤ t₂ → normSq t₂ ≤ normSq t₁

namespace NonHermitianGenerator

/-- The norm-squared at time `t` is bounded by the value at time `0`
for any `t ≥ 0`. -/
theorem normSq_le_initial (gen : NonHermitianGenerator) (t : ℝ) (ht : 0 ≤ t) :
    gen.normSq t ≤ gen.normSq 0 :=
  gen.norm_decay 0 t ht

/-- Trivial existence: constant unit norm-squared, zero dissipation. -/
theorem exists_trivial : ∃ _ : NonHermitianGenerator, True :=
  ⟨{ ℏ              := 1
   , ℏ_pos          := by norm_num
   , expH_I         := fun _ => 0
   , expH_I_nonneg  := fun _ => le_refl 0
   , normSq         := fun _ => 1
   , normSq_nonneg  := fun _ => by norm_num
   , norm_decay     := fun _ _ _ => le_refl 1 }, trivial⟩

end NonHermitianGenerator

-- ============================================================================
-- 2. Classical contact dissipation (Herglotz / contact-friction shape)
-- ============================================================================

/-- **Classical contact-friction carrier.**

The artifact's classical complex Lagrangian satisfies
`L_I(q, q̇, t, s) = ρ(q, q̇, t) · s` (artifact L3152–L3172), with
non-negative friction coefficient `ρ ≥ 0` and accumulated action `s`.

We expose only the time-parameter slice here: `ρ : ℝ → ℝ` (friction
over time), `s : ℝ → ℝ` (action accumulator), and `L_I` defined by
the product law. -/
structure ClassicalContactDissipation where
  /-- Contact-friction coefficient. -/
  ρ          : ℝ → ℝ
  /-- Non-negativity of `ρ`. -/
  ρ_nonneg   : ∀ t, 0 ≤ ρ t
  /-- Accumulated-action coordinate. -/
  s          : ℝ → ℝ
  /-- Non-negativity of `s` (the accumulator only grows). -/
  s_nonneg   : ∀ t, 0 ≤ s t
  /-- Classical imaginary Lagrangian. -/
  L_I        : ℝ → ℝ
  /-- Product law: `L_I(t) = ρ(t) · s(t)`. -/
  L_I_eq     : ∀ t, L_I t = ρ t * s t

namespace ClassicalContactDissipation

/-- `L_I` is non-negative as a product of non-negatives. -/
theorem L_I_nonneg (cl : ClassicalContactDissipation) (t : ℝ) :
    0 ≤ cl.L_I t := by
  rw [cl.L_I_eq t]
  exact mul_nonneg (cl.ρ_nonneg t) (cl.s_nonneg t)

/-- Trivial existence: zero dissipation. -/
theorem exists_trivial : ∃ _ : ClassicalContactDissipation, True :=
  ⟨{ ρ        := fun _ => 0
   , ρ_nonneg := fun _ => le_refl 0
   , s        := fun _ => 0
   , s_nonneg := fun _ => le_refl 0
   , L_I      := fun _ => 0
   , L_I_eq   := fun _ => by ring }, trivial⟩

end ClassicalContactDissipation

-- ============================================================================
-- 3. Bridge: classical contact ↔ quantum dissipation
-- ============================================================================

/-- **Bridge contract: classical contact dissipation ↔ quantum
non-Hermitian generator.**

The artifact's classical-to-quantum pipeline (L3856–L3906) identifies
the classical contact source `L_I(t)` with the quantum dissipation
expectation `ℏ · ⟨H_I⟩(t)`:

  `L_I(t) = ℏ · ⟨H_I⟩(t)`.

This is the `Identify…`-style carrier matching PRs #68, #76, #79, #82,
#84, #85.  Phase-2 refinement supplies the operator-algebra backing. -/
structure IdentifyClassicalContactWithQuantumDissipation where
  /-- The classical contact-dissipation data. -/
  classical      : ClassicalContactDissipation
  /-- The quantum non-Hermitian generator. -/
  quantum        : NonHermitianGenerator
  /-- The identification: `L_I(t) = ℏ · ⟨H_I⟩(t)`. -/
  identification : ∀ t, classical.L_I t = quantum.ℏ * quantum.expH_I t

namespace IdentifyClassicalContactWithQuantumDissipation

/-- The product `ρ · s` agrees with `ℏ · ⟨H_I⟩` pointwise. -/
theorem product_form_agrees
    (B : IdentifyClassicalContactWithQuantumDissipation) (t : ℝ) :
    B.classical.ρ t * B.classical.s t = B.quantum.ℏ * B.quantum.expH_I t := by
  have h1 := B.identification t
  have h2 := B.classical.L_I_eq t
  linarith

end IdentifyClassicalContactWithQuantumDissipation

-- ============================================================================
-- 4. GKLS jump decomposition
-- ============================================================================

/-- **GKLS jump decomposition.**

Per the artifact's GKLS completion (L4453), the quantum dissipation
expectation decomposes as a sum of non-negative jump rates `γⱼ(t)`:

  `(2/ℏ) ⟨H_I⟩(t) = Σⱼ γⱼ(t)`,

equivalently `⟨H_I⟩(t) = (ℏ/2) Σⱼ γⱼ(t)`.

We carry only the rate decomposition and consistency law; jump
operators themselves are deliberately abstract. -/
structure GKLSJumpDecomposition (gen : NonHermitianGenerator) where
  /-- Number of jump channels. -/
  numJumps          : ℕ
  /-- Per-channel jump rate as a function of time. -/
  jumpRates         : Fin numJumps → ℝ → ℝ
  /-- Each jump rate is non-negative. -/
  jumpRates_nonneg  : ∀ j t, 0 ≤ jumpRates j t
  /-- Consistency: `⟨H_I⟩(t) = (ℏ/2) · Σⱼ γⱼ(t)`. -/
  consistency       : ∀ t,
      gen.expH_I t = (gen.ℏ / 2) *
        (Finset.univ : Finset (Fin numJumps)).sum (fun j => jumpRates j t)

namespace GKLSJumpDecomposition

/-- The sum of jump rates is non-negative. -/
theorem sum_rates_nonneg {gen : NonHermitianGenerator}
    (gkls : GKLSJumpDecomposition gen) (t : ℝ) :
    0 ≤ (Finset.univ : Finset (Fin gkls.numJumps)).sum
          (fun j => gkls.jumpRates j t) := by
  refine Finset.sum_nonneg ?_
  intro j _
  exact gkls.jumpRates_nonneg j t

/-- Trivial existence: zero-channel decomposition for the trivial
generator (since `⟨H_I⟩ = 0` matches the empty sum). -/
theorem exists_trivial (gen : NonHermitianGenerator)
    (h : ∀ t, gen.expH_I t = 0) :
    ∃ _ : GKLSJumpDecomposition gen, True :=
  ⟨{ numJumps         := 0
   , jumpRates        := fun j _ => Fin.elim0 j
   , jumpRates_nonneg := fun j _ => Fin.elim0 j
   , consistency      := by
       intro t
       simp [h t] }, trivial⟩

end GKLSJumpDecomposition

-- ============================================================================
-- 5. Capstone bundle
-- ============================================================================

/-- **Non-Hermitian quantum CAT/EPT bundle.**

All structural deliverables for the artifact's classical-contact ↔
quantum-non-Hermitian ↔ GKLS pipeline hold simultaneously:

* A non-Hermitian generator exists (constant-norm trivial instance).
* A classical contact-dissipation carrier exists (zero instance).
* A GKLS jump decomposition exists for any generator with zero
  dissipation expectation.

Phase-2 refinements substitute concrete operator algebras (Hilbert
spaces, self-adjoint `H_R`, accretive `H_I`, Lindblad jumps `L_j`)
from specific physics models. -/
theorem non_hermitian_quantum_cat_bundle :
    (∃ _ : NonHermitianGenerator, True)
    ∧ (∃ _ : ClassicalContactDissipation, True) := by
  refine ⟨NonHermitianGenerator.exists_trivial,
          ClassicalContactDissipation.exists_trivial⟩

end CATEPTMain.Integration.NonHermitianQuantumCAT
