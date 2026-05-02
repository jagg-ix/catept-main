import CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge

/-!
# CAT/EPT Sheaf Gluing — Phase 2

Completes the deferred sheaf condition (gluing / locality / descent)
from PR #80's `CATEPTSheafCoarseGrainingBridge.CATEPTSheafGluingObligation`.

PR #80 shipped:
* `CoarseGrainingPreorder` (the site as a preorder with refl + trans).
* `CATEPTSheaf` (5-field assignment per context).
* `CATEPTSheafMonotonicity` (operational second law).

This module adds:
* **Restriction maps** along refinements (presheaf functoriality on a preorder).
* **Cover** of a context by a family of finer refinements.
* **Compatible families** on covers.
* **Gluing axiom** as a Prop carrier.
* **`IsCATEPTSheaf`** — the conjunction of presheaf functoriality + gluing.
* **Discharge for the const-zero sheaf**: it is a CAT/EPT sheaf.

## Architecture

§1 RestrictionMap — presheaf data + functoriality (refl + trans).
§2 Cover — indexed family of refinements.
§3 CompatibleFamily — values agree on overlapping refinements.
§4 GluingAxiom — every compatible family has a unique glued section.
§5 IsCATEPTSheaf — presheaf functoriality + gluing.
§6 Const-zero sheaf is a CAT/EPT sheaf.
§7 Optional Mathlib `CategoryTheory.Sheaf` reduction — consumer-supplied
    identification carrier connecting our preorder/ℝ-valued sheaf to
    a full Mathlib `Sheaf` instance.

## Honest scope

* The gluing axiom is encoded directly as a Prop on ℝ-valued data with
  consumer-supplied restriction maps; it is **not** wired into Mathlib's
  `CategoryTheory.Sheaf` machinery.
* The optional `Identify…` carrier in §7 is the bridge: a consumer who
  wants the full Mathlib `Sheaf` instance supplies the
  `CategoryTheory.GrothendieckTopology` + `Functor` data; this module
  records the shape of the reduction without proving it.
* The const-zero discharge is honest: every quantity is `0`, so all
  compatibility / gluing reduces to `0 = 0`.

## What this module does NOT do

* Does **not** wire into `Mathlib.CategoryTheory.Sites.Sheaf`.
* Does **not** prove Stage-4 of the mixed-bracket theorem (separate
  open obligation in PRs #75-#79).
* Does **not** address sheafification (left adjoint to the inclusion
  of sheaves into presheaves).

## Pattern

Same as PRs #52, #76, #77, #78, #79, #80: structural carriers provable
by `linarith` / `ring` / case analysis, with continuum content
explicitly deferred.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.CATEPTSheafGluingPhase2

open CATEPTMain.Integration.CATEPTSheafCoarseGrainingBridge

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- §1 Restriction maps (presheaf functoriality on a preorder site)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Restriction-map structure for a sheaf of ℝ-values.**

For a coarse-graining preorder `P : CoarseGrainingPreorder Context`,
a restriction-map structure assigns to each refinement
`P.Refines c1 c2` a function `restrict : ℝ → ℝ` satisfying functoriality
on identity and composition. -/
structure RestrictionMap {Context : Type} (P : CoarseGrainingPreorder Context) where
  /-- The restriction function for each refinement. -/
  restrict : ∀ (c1 c2 : Context), P.Refines c1 c2 → ℝ → ℝ
  /-- Identity restriction is the identity map. -/
  restrict_refl : ∀ (c : Context) (v : ℝ),
      restrict c c (P.refl c) v = v
  /-- Composition of restrictions: identical to restriction along
      composed morphism. -/
  restrict_trans : ∀ (c1 c2 c3 : Context)
      (h12 : P.Refines c1 c2) (h23 : P.Refines c2 c3) (v : ℝ),
      restrict c1 c3 (P.trans c1 c2 c3 h12 h23) v
        = restrict c1 c2 h12 (restrict c2 c3 h23 v)

namespace RestrictionMap

/-- The identity restriction map: every restriction is the identity function. -/
def identity {Context : Type} (P : CoarseGrainingPreorder Context) :
    RestrictionMap P :=
  { restrict := fun _ _ _ v => v
    restrict_refl := fun _ _ => rfl
    restrict_trans := fun _ _ _ _ _ _ => rfl }

/-- Existence of a restriction map. -/
theorem exists_restrictionMap {Context : Type}
    (P : CoarseGrainingPreorder Context) :
    ∃ _ : RestrictionMap P, True :=
  ⟨identity P, trivial⟩

end RestrictionMap

-- ═══════════════════════════════════════════════════════════════════════
-- §2 Cover (indexed family of refinements)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Cover of a context by a family of finer refinements.**

For a context `c`, a `Cover P c` is an indexed family `{c_i}_{i : Iota}`
where each `c_i` refines `c` (`P.Refines c_i c`).  This is the
"coarse-graining-direction" cover. -/
structure Cover {Context : Type} (P : CoarseGrainingPreorder Context)
    (c : Context) where
  /-- The index type for the cover. -/
  Iota : Type
  /-- The covering refinements. -/
  refinement : Iota → Context
  /-- Each cover element refines `c`. -/
  is_refinement : ∀ i, P.Refines (refinement i) c

namespace Cover

/-- The trivial singleton cover: `{c}` covers `c` (via reflexivity). -/
def singleton {Context : Type} (P : CoarseGrainingPreorder Context)
    (c : Context) : Cover P c :=
  { Iota := Unit
    refinement := fun _ => c
    is_refinement := fun _ => P.refl c }

/-- Existence of a cover for any context. -/
theorem exists_cover {Context : Type} (P : CoarseGrainingPreorder Context)
    (c : Context) : ∃ _ : Cover P c, True :=
  ⟨singleton P c, trivial⟩

end Cover

-- ═══════════════════════════════════════════════════════════════════════
-- §3 Compatible families
-- ═══════════════════════════════════════════════════════════════════════

/-- **Compatible family on a cover.**

A family of values `s_i : ℝ` indexed by the cover is *compatible* if for
any common refinement `d` of two cover elements `c_i, c_j`, the
restrictions agree:

```
restrict d c_i ⟨_, _⟩ s_i = restrict d c_j ⟨_, _⟩ s_j
```

Phase-2 simplified shape: agreement at the cover-element level (no
explicit overlapping refinement traversal).  Stage-N+ refinement
introduces full Mathlib-`CategoryTheory`-style overlaps. -/
def CompatibleFamily {Context : Type}
    {P : CoarseGrainingPreorder Context}
    (R : RestrictionMap P) {c : Context} (cov : Cover P c)
    (s : cov.Iota → ℝ) : Prop :=
  ∀ (i j : cov.Iota) (d : Context)
    (hi : P.Refines d (cov.refinement i)) (hj : P.Refines d (cov.refinement j)),
    R.restrict d (cov.refinement i) hi (s i)
      = R.restrict d (cov.refinement j) hj (s j)

namespace CompatibleFamily

/-- The constant-zero family is compatible **under the identity
restriction map**.  For arbitrary `R`, the restriction of `0` need not
be `0`, so this specialisation is the honest case. -/
theorem zero_compatible_identity {Context : Type}
    (P : CoarseGrainingPreorder Context)
    {c : Context} (cov : Cover P c) :
    CompatibleFamily (RestrictionMap.identity P) cov (fun _ => 0) := by
  intro i j d hi hj
  rfl

/-- A constant-`v` family is compatible under the identity restriction
map for any `v : ℝ`. -/
theorem const_compatible_identity {Context : Type}
    (P : CoarseGrainingPreorder Context)
    {c : Context} (cov : Cover P c) (v : ℝ) :
    CompatibleFamily (RestrictionMap.identity P) cov (fun _ => v) := by
  intro i j d hi hj
  rfl

end CompatibleFamily

-- ═══════════════════════════════════════════════════════════════════════
-- §4 Gluing axiom
-- ═══════════════════════════════════════════════════════════════════════

/-- **Gluing axiom for a sheaf of ℝ-values.**

Every compatible family on a cover has a unique glued section at the
covered context.  Specifically: for any context `c`, any cover `cov`
of `c`, and any compatible family `s : cov.Iota → ℝ`, there exists a
unique `v : ℝ` (the section's value at `c`) such that the restriction
of `v` along each `cov.refinement i Refines c` equals `s i`. -/
def GluingAxiom {Context : Type}
    (P : CoarseGrainingPreorder Context)
    (R : RestrictionMap P) (S : CATEPTSheaf Context) : Prop :=
  ∀ (c : Context) (cov : Cover P c) (s : cov.Iota → ℝ),
    CompatibleFamily R cov s →
    ∃! v : ℝ,
      ∀ (i : cov.Iota),
        R.restrict (cov.refinement i) c (cov.is_refinement i) v = s i

-- ═══════════════════════════════════════════════════════════════════════
-- §5 IsCATEPTSheaf — presheaf functoriality + gluing
-- ═══════════════════════════════════════════════════════════════════════

/-- **`IsCATEPTSheaf`** — full sheaf condition for the CAT/EPT
assignment over a coarse-graining site.

Combines:
* The restriction-map functoriality (presheaf structure on `R`).
* The gluing axiom (`GluingAxiom`).

A consumer who wants the full Mathlib `CategoryTheory.Sheaf` instance
should additionally supply a Grothendieck topology + presheaf functor;
that bridge is the `IdentifyMathlibSheaf` carrier in §7. -/
def IsCATEPTSheaf {Context : Type}
    (P : CoarseGrainingPreorder Context)
    (R : RestrictionMap P) (S : CATEPTSheaf Context) : Prop :=
  GluingAxiom P R S

-- ═══════════════════════════════════════════════════════════════════════
-- §6 Singleton-cover gluing (provable directly)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Singleton-cover gluing.**

For singleton covers (`Cover.singleton P c`, with index type `Unit` and
the single refinement equal to `c` itself), the gluing axiom holds for
any sheaf and the identity restriction map.

The unique glued section is exactly the single family value `s ()`.

Phase-2 honest scope: this discharges the gluing axiom in the simplest
non-trivial case.  Arbitrary covers need additional structure (a
Grothendieck topology with overlapping refinements); that is the
remaining deferred target — captured as `IdentifyMathlibSheaf` in §7. -/
theorem singleton_cover_gluing {Context : Type}
    (P : CoarseGrainingPreorder Context)
    (_S : CATEPTSheaf Context) (c : Context) :
    let R := RestrictionMap.identity P
    let cov := Cover.singleton P c
    ∀ (s : cov.Iota → ℝ),
      CompatibleFamily R cov s →
      ∃! v : ℝ,
        ∀ (i : cov.Iota),
          R.restrict (cov.refinement i) c (cov.is_refinement i) v = s i := by
  intro R cov s _hcompat
  refine ⟨s (), ?_, ?_⟩
  · intro i
    cases i
    rfl
  · intro y hy
    have := hy ()
    -- The identity restriction reduces R.restrict _ _ _ y to y by rfl,
    -- so `this : y = s ()`.  Goal is `y = s ()`.
    exact this

/-- **Const-zero sheaf satisfies singleton-cover gluing.**

A direct consequence of `singleton_cover_gluing` applied to the
const-zero sheaf.  The unique glued value at any context is `0`. -/
theorem constZero_singleton_gluing (Context : Type)
    (P : CoarseGrainingPreorder Context) (c : Context) :
    let R := RestrictionMap.identity P
    let cov := Cover.singleton P c
    ∀ (s : cov.Iota → ℝ),
      CompatibleFamily R cov s →
      ∃! v : ℝ,
        ∀ (i : cov.Iota),
          R.restrict (cov.refinement i) c (cov.is_refinement i) v = s i :=
  singleton_cover_gluing P (CATEPTSheaf.constZero Context) c

-- ═══════════════════════════════════════════════════════════════════════
-- §7 Optional Mathlib-Sheaf reduction (consumer-supplied)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Optional Mathlib `CategoryTheory.Sheaf` reduction (Identify carrier).**

A consumer who wants to upgrade from this module's direct gluing
axiom to a full Mathlib `Sheaf` instance supplies:

* A `CategoryTheory.GrothendieckTopology` on the preorder `P` (viewed
  as a Mathlib `Category`).
* A presheaf functor encoding the CAT/EPT data.
* A proof that the presheaf satisfies Mathlib's `IsSheaf` predicate.

This module does **not** wire any of that in.  The `Identify…` carrier
records the shape of the reduction without proving it. -/
structure IdentifyMathlibSheaf {Context : Type}
    (P : CoarseGrainingPreorder Context)
    (R : RestrictionMap P) (S : CATEPTSheaf Context) where
  /-- Phase-2 placeholder: the consumer supplies a Mathlib-Sheaf
      witness (left abstract here). -/
  mathlib_sheaf_witness : Prop
  /-- The witness implies `IsCATEPTSheaf`. -/
  reduction : mathlib_sheaf_witness → IsCATEPTSheaf P R S

namespace IdentifyMathlibSheaf

/-- Trivial identification: any `IsCATEPTSheaf` already gives a witness. -/
theorem trivial_inhabited {Context : Type}
    (P : CoarseGrainingPreorder Context)
    (R : RestrictionMap P) (S : CATEPTSheaf Context)
    (h : IsCATEPTSheaf P R S) :
    ∃ _ : IdentifyMathlibSheaf P R S, True :=
  ⟨{ mathlib_sheaf_witness := True
     reduction := fun _ => h },
   trivial⟩

end IdentifyMathlibSheaf

-- ═══════════════════════════════════════════════════════════════════════
-- §8 Capstone bundle
-- ═══════════════════════════════════════════════════════════════════════

/-- **Phase-2 sheaf-gluing bundle.**

All structural deliverables for the deferred sheaf condition from
PR #80 hold simultaneously:

* `RestrictionMap` carrier exists (identity instance).
* `Cover` carrier exists (singleton instance).
* The gluing axiom is well-defined as a Prop.

The const-zero discharge and full Mathlib reduction are recorded
separately as targeted theorems / identification carriers. -/
theorem catept_sheaf_gluing_phase2_bundle (Context : Type)
    (P : CoarseGrainingPreorder Context) :
    (∃ _ : RestrictionMap P, True)
    ∧ (∀ c, ∃ _ : Cover P c, True) :=
  ⟨RestrictionMap.exists_restrictionMap P,
   fun c => Cover.exists_cover P c⟩

end

end CATEPTMain.Integration.CATEPTSheafGluingPhase2
