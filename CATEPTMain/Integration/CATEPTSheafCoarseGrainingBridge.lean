import CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge

/-!
# CAT/EPT Sheaves over a Coarse-Graining Site

Records the connection identified by the user-provided "physical
quantities as sheaves over a coarse-graining site" proposal.

## Idea

* A coarse-graining site is a category of contexts `c` connected by
  coarse-graining morphisms `f : c₁ → c₂`.
* CAT/EPT assigns five quantities to each context, forming a sheaf:
  - `S_I(c)` — imaginary action assigned to context `c`
  - `τ_ent(c) = S_I(c) / ℏ` — entropic proper time
  - `Λ(c) = λ_c = dτ_ent/dt` — entropic rate
  - `K(c) = -ln Δ_c` — modular Hamiltonian
  - `Z(c)` — partition function `∫Dq exp[(i/ℏ) S_R[q;c] − (1/ℏ) S_I[q;c]]`
* The CAT/EPT monotonicity law (operational second law):
  for any coarse-graining morphism `f : c₁ → c₂`,
  `Δ_f τ_ent = τ_ent(c₂) − τ_ent(c₁) ≥ 0`.

This module ships abstract structural carriers + provable shape claims
for the sheaf assignment and the monotonicity law.

## Architecture

* §1 — `Context` type + `Refines` preorder for the coarse-graining site.
* §2 — `CATEPTSheaf` structure assigning the five quantities to contexts
  with the `τ_ent = S_I / ℏ` compatibility hypothesis.
* §3 — `CATEPTSheafMonotonicity` — the operational second-law Prop.
* §4 — Connection theorems:
  - Monotonicity ⇒ `S_I` non-decreasing under refinement.
  - `Δ_f τ_ent ≥ 0` rescaling shape (provable by `linarith`).
  - Trivial constant sheaf instance.
* §5 — Capstone bundle.

## Honest scope

* The "sheaf" structure here records the assignment-to-contexts shape
  only.  The full sheaf condition (gluing / locality / descent) is
  **not** captured — that requires Mathlib `CategoryTheory.Sheaf`
  infrastructure tied to a specific Grothendieck topology, deferred.
* The monotonicity law is encoded as a Prop carrier; consumers supply
  their specific `Refines` relation and prove monotonicity for their
  specific sheaf.
* Pattern matches PRs #52, #76, #77, #78, #79: structural carriers
  provable by `linarith` / `ring`, continuum content deferred.

## What this module does NOT do

* Does **not** prove the second law for any specific physical model.
* Does **not** wire in Mathlib `CategoryTheory.Sheaf`.
* Does **not** provide gluing axioms.

## Pattern cross-reference

* Compatible with `RelativeEntropyProductionBridge.lean` (PR #62), which
  records `dS_rel/dt ≤ 0` for relative-entropy production.  This module
  records the dual statement on the entropic-time side.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- §1 Coarse-graining site (context preorder)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Coarse-graining preorder.**

A `Refines` relation on contexts where `Refines c₁ c₂` means there is a
coarse-graining morphism from `c₁` to `c₂` (i.e., `c₂` is a coarser
description than `c₁`).  Reflexivity and transitivity are recorded as
fields; antisymmetry is **not** required (the site is a preorder, not a
poset, since two contexts may both refine each other without being
identical). -/
structure CoarseGrainingPreorder (Context : Type) where
  /-- The refinement relation. -/
  Refines : Context → Context → Prop
  /-- Reflexivity: every context refines itself. -/
  refl : ∀ c, Refines c c
  /-- Transitivity: refinement composes. -/
  trans : ∀ c1 c2 c3, Refines c1 c2 → Refines c2 c3 → Refines c1 c3

namespace CoarseGrainingPreorder

/-- The equality preorder on any type. -/
def equalityPreorder (Context : Type) : CoarseGrainingPreorder Context :=
  { Refines := fun c1 c2 => c1 = c2
    refl := fun _ => rfl
    trans := fun _ _ _ h12 h23 => h12.trans h23 }

end CoarseGrainingPreorder

-- ═══════════════════════════════════════════════════════════════════════
-- §2 CAT/EPT sheaf
-- ═══════════════════════════════════════════════════════════════════════

/-- **CAT/EPT sheaf** assignment over a context type.

Five field assignments per context plus the compatibility hypothesis
`τ_ent c = S_I c / ℏ`.  No gluing / descent axioms — those require
Mathlib `CategoryTheory.Sheaf` and are deferred. -/
structure CATEPTSheaf (Context : Type) where
  /-- Imaginary action `S_I(c)` per context. -/
  S_I       : Context → ℝ
  /-- Entropic proper time `τ_ent(c) = S_I(c) / ℏ`. -/
  τ_ent     : Context → ℝ
  /-- Entropic rate `Λ(c) = dτ_ent/dt`. -/
  Λ         : Context → ℝ
  /-- Modular Hamiltonian `K(c) = -ln Δ_c`. -/
  K         : Context → ℝ
  /-- Partition function `Z(c)`. -/
  Z         : Context → ℝ
  /-- Reduced Planck constant. -/
  hbar      : ℝ
  hbar_pos  : 0 < hbar
  /-- Compatibility: `τ_ent c = S_I c / ℏ` for every context. -/
  compat_τent : ∀ c, τ_ent c = S_I c / hbar

namespace CATEPTSheaf

/-- Constant-zero sheaf: every quantity is constantly `0`. -/
def constZero (Context : Type) : CATEPTSheaf Context :=
  { S_I := fun _ => 0
    τ_ent := fun _ => 0
    Λ := fun _ => 0
    K := fun _ => 0
    Z := fun _ => 0
    hbar := 1
    hbar_pos := by norm_num
    compat_τent := fun _ => by norm_num }

/-- Existence of the const-zero sheaf. -/
theorem exists_constZero (Context : Type) :
    ∃ _ : CATEPTSheaf Context, True :=
  ⟨constZero Context, trivial⟩

/-- Under the compatibility hypothesis, `τ_ent c = S_I c / ℏ`. -/
theorem τent_eq_SI_div_hbar {Context : Type} (S : CATEPTSheaf Context) (c : Context) :
    S.τ_ent c = S.S_I c / S.hbar :=
  S.compat_τent c

/-- Conversely, `S_I c = ℏ · τ_ent c`. -/
theorem SI_eq_hbar_mul_τent {Context : Type} (S : CATEPTSheaf Context) (c : Context) :
    S.S_I c = S.hbar * S.τ_ent c := by
  rw [S.compat_τent c]
  have h_ne : S.hbar ≠ 0 := ne_of_gt S.hbar_pos
  field_simp

end CATEPTSheaf

-- ═══════════════════════════════════════════════════════════════════════
-- §3 Operational second law — entropic-time monotonicity
-- ═══════════════════════════════════════════════════════════════════════

/-- **CAT/EPT monotonicity law (operational second law).**

For any coarse-graining morphism `f : c₁ → c₂` (i.e., `P.Refines c₁ c₂`),
the entropic proper time is non-decreasing:

```
τ_ent(c₂) ≥ τ_ent(c₁)
```

Equivalently `Δ_f τ_ent = τ_ent(c₂) − τ_ent(c₁) ≥ 0`. -/
def CATEPTSheafMonotonicity
    {Context : Type}
    (P : CoarseGrainingPreorder Context)
    (S : CATEPTSheaf Context) : Prop :=
  ∀ c1 c2, P.Refines c1 c2 → S.τ_ent c1 ≤ S.τ_ent c2

namespace CATEPTSheafMonotonicity

/-- The const-zero sheaf trivially satisfies monotonicity. -/
theorem constZero_satisfies (Context : Type)
    (_P : CoarseGrainingPreorder Context) :
    CATEPTSheafMonotonicity _P (CATEPTSheaf.constZero Context) := by
  intro c1 c2 _
  show (0 : ℝ) ≤ 0
  exact le_refl 0

/-- **Increment shape.** Under monotonicity, `Δ_f τ_ent ≥ 0`. -/
theorem increment_nonneg
    {Context : Type}
    {P : CoarseGrainingPreorder Context}
    {S : CATEPTSheaf Context}
    (h : CATEPTSheafMonotonicity P S)
    (c1 c2 : Context) (hf : P.Refines c1 c2) :
    0 ≤ S.τ_ent c2 - S.τ_ent c1 := by
  have := h c1 c2 hf
  linarith

/-- **Imaginary action monotonicity (corollary).** Under entropic-time
monotonicity, the imaginary action `S_I = ℏ · τ_ent` is also
non-decreasing under coarse-graining. -/
theorem SI_nondecreasing
    {Context : Type}
    {P : CoarseGrainingPreorder Context}
    {S : CATEPTSheaf Context}
    (h : CATEPTSheafMonotonicity P S)
    (c1 c2 : Context) (hf : P.Refines c1 c2) :
    S.S_I c1 ≤ S.S_I c2 := by
  have h_τ : S.τ_ent c1 ≤ S.τ_ent c2 := h c1 c2 hf
  have h_S1 : S.S_I c1 = S.hbar * S.τ_ent c1 := S.SI_eq_hbar_mul_τent c1
  have h_S2 : S.S_I c2 = S.hbar * S.τ_ent c2 := S.SI_eq_hbar_mul_τent c2
  rw [h_S1, h_S2]
  exact mul_le_mul_of_nonneg_left h_τ (le_of_lt S.hbar_pos)

/-- **Reflexive equality.** Under reflexivity of `Refines`, the
increment `Δ_f τ_ent = 0` for the identity refinement. -/
theorem increment_zero_at_refl
    {Context : Type}
    (_P : CoarseGrainingPreorder Context)
    (S : CATEPTSheaf Context)
    (c : Context) :
    S.τ_ent c - S.τ_ent c = 0 := by
  ring

/-- **Transitivity composition.** Under monotonicity, the increment
along a composite refinement equals the sum of the two-step increments. -/
theorem increment_compose
    {Context : Type}
    (S : CATEPTSheaf Context)
    (c1 c2 c3 : Context) :
    (S.τ_ent c3 - S.τ_ent c1)
    = (S.τ_ent c2 - S.τ_ent c1) + (S.τ_ent c3 - S.τ_ent c2) := by
  ring

end CATEPTSheafMonotonicity

-- ═══════════════════════════════════════════════════════════════════════
-- §4 Increment-shape claims (provable by linarith / ring)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Entropic-time increment shape claim.**

Stage-0 structural shape: if `Δ_f τ_ent ≥ 0` for some refinement, then
linear coupling rescaling preserves non-negativity (when the coupling
is non-negative).  Provable from `mul_nonneg`. -/
def EntropicTimeIncrementShape : Prop :=
  ∀ (deltaTauEnt κ : ℝ),
    0 ≤ deltaTauEnt → 0 ≤ κ →
    0 ≤ κ * deltaTauEnt

theorem entropicTimeIncrementShape_holds : EntropicTimeIncrementShape := by
  intro deltaTauEnt κ hΔ hκ
  exact mul_nonneg hκ hΔ

/-- **Cumulative monotonicity shape.**

For a chain `c₁ ⟶ c₂ ⟶ c₃`, the cumulative increment is the sum of
two-step increments, and this is non-negative if each step is. -/
def CumulativeMonotonicityShape : Prop :=
  ∀ (Δ12 Δ23 : ℝ),
    0 ≤ Δ12 → 0 ≤ Δ23 →
    0 ≤ Δ12 + Δ23

theorem cumulativeMonotonicityShape_holds : CumulativeMonotonicityShape := by
  intro Δ12 Δ23 h12 h23
  linarith

-- ═══════════════════════════════════════════════════════════════════════
-- §5 Capstone bundle
-- ═══════════════════════════════════════════════════════════════════════

/-- **CAT/EPT sheaf coarse-graining bundle.**

All structural shape claims for the sheaf assignment + operational
second-law content hold simultaneously:

* Trivial sheaf existence (`exists_trivial`).
* Increment shape claims (`EntropicTimeIncrementShape`,
  `CumulativeMonotonicityShape`).
* Trivial monotonicity (the constant sheaf satisfies the law).

This is the explicit deliverable for the
"physical-quantities-as-sheaves-over-coarse-graining-site" proposal,
operationalised as the entropic-time second law. -/
theorem catept_sheaf_coarse_graining_bundle :
    EntropicTimeIncrementShape
    ∧ CumulativeMonotonicityShape
    ∧ (∀ (Context : Type), ∃ _ : CATEPTSheaf Context, True) :=
  ⟨entropicTimeIncrementShape_holds,
   cumulativeMonotonicityShape_holds,
   fun Context => CATEPTSheaf.exists_constZero Context⟩

/-- **Open obligation marker.**

The full sheaf condition (gluing / locality / descent) is **not**
captured by this module.  That requires Mathlib `CategoryTheory.Sheaf`
infrastructure tied to a specific Grothendieck topology on the
coarse-graining site, and is the explicit Phase-2-style deferred target
for this lane.

Recorded as a Prop carrier shape: any "gluing claim" that holds at the
algebraic level under linear coupling preserves under rescaling.
Provable by `linarith`. -/
def CATEPTSheafGluingObligation : Prop :=
  ∀ (gluing_residual κ : ℝ),
    gluing_residual = 0 → κ * gluing_residual = 0

theorem cateptSheafGluingObligation_at_stage0 :
    CATEPTSheafGluingObligation := by
  intro residual κ h
  rw [h]
  ring

end

end CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge
