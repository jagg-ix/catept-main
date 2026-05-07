# Proposal: bake the consistency obligation into `CATEPTPluginSlot`

This proposal addresses the structural finding from `HELPER_WALK.md` Phase 3:

> The slot-`consistent` chain is genuinely shallow at every layer. `GravitasBridge.lean:90` itself says so: *"Term-mode proof via `SuperiorMethodSlot.consistent` (`fun _ => div_one _`)."*

The four publication-facing slot-satisfaction theorems

```lean
qm_satisfies_catept_spine                    -- A21
gr_minkowski_satisfies_catept_spine          -- A22
gr_electrovacuum_satisfies_catept_spine      -- A23
qm_gr_unified_via_entropic_proper_time       -- A24
```

are bundle wrappers around the universal-tautology

```lean
theorem SuperiorMethodSlot.consistent (s : SuperiorMethodSlot) :
    cateptConsistencyConstraint s.toCATEPTSlot :=
  fun _ => div_one _    -- the structurally-shallow line
```

…in `.lake/packages/catept-plugin-architecture/CATEPTPluginArchitecture/Domains/SuperiorMethod.lean:84`.

## Diagnosis — why the proof is `div_one`

`CATEPTPluginSlot` is the underlying interface. **Right now its consistency proof is *not* a required field of the structure**: it's a separate top-level definition

```lean
def cateptConsistencyConstraint (slot : CATEPTPluginSlot) : Prop :=
  ∀ x : slot.ConfigSpaceTy,
    slot.actionIm x / slot.hbar = slot.eptClock x
```

(in `.lake/packages/catept-plugin-architecture/CATEPTPluginArchitecture/Integration/TheoryPluginArchitecture.lean:82`). Any consumer can construct a slot **without supplying a proof of consistency**, then optionally prove `cateptConsistencyConstraint slot` downstream as a separate theorem.

`SuperiorMethodSlot` is a deliberately restricted form whose `toCATEPTSlot` embedding sets `actionIm := s.actionFn`, `eptClock := s.actionFn`, `hbar := 1`. So `cateptConsistencyConstraint` reduces to `∀ x, actionFn x / 1 = actionFn x`, dischargeable by `div_one`. The shipped helper `SuperiorMethodSlot.consistent` is exactly that universal trivial proof.

This is **not a bug** — the abstraction was designed to make the spine identity trivially true so domains can plug in cleanly. The reviewer-defensibility issue is that downstream theorems present the trivial discharge as a domain-specific result.

## The fix in one sentence

**Move the consistency obligation back into the structure** so a `CATEPTPluginSlot` cannot exist without a proof, and consumers see the proof at the construction site instead of buried under a downstream theorem.

```lean
-- BEFORE (what shipped, with the obligation lifted out)
structure CATEPTPluginSlot where
  ConfigSpaceTy   : Type
  actionRe        : ConfigSpaceTy → ℝ
  actionIm        : ConfigSpaceTy → ℝ
  actionIm_nonneg : ∀ x, 0 ≤ actionIm x
  hbar            : ℝ
  hbar_pos        : 0 < hbar
  eptClock        : ConfigSpaceTy → ℝ
  eptClock_nonneg : ∀ x, 0 ≤ eptClock x
  -- ↑ no consistency obligation; constraint is an external def

-- AFTER (the obligation is a required field)
structure CATEPTPluginSlot where
  ConfigSpaceTy   : Type
  actionRe        : ConfigSpaceTy → ℝ
  actionIm        : ConfigSpaceTy → ℝ
  actionIm_nonneg : ∀ x, 0 ≤ actionIm x
  hbar            : ℝ
  hbar_pos        : 0 < hbar
  eptClock        : ConfigSpaceTy → ℝ
  eptClock_nonneg : ∀ x, 0 ≤ eptClock x
  consistent      : ∀ x, actionIm x / hbar = eptClock x   -- ← required
```

`SuperiorMethodSlot` survives only as a **smart constructor** producing a `CATEPTPluginSlot` whose `consistent` field is `fun _ => div_one _` inline. A reviewer reading the slot definition sees the trivial discharge at the construction site, immediately knowing this instantiation is structurally trivial. No theorem indirection, no `SuperiorMethodSlot.consistent` universal-trivial helper.

## Multi-repo coordinated change — not a one-place edit

`CATEPTPluginSlot` lives in the `catept-plugin-architecture` sibling repo (pinned via `catept-main`'s `lakefile.lean`). The fix is **not a single-file edit**: it touches the sibling, the lakefile pin, the lake manifest, and **every constructor site** in catept-main.

### Constructor sites the fix touches

Eight in `catept-main` plus one in the sibling. Every site must add a `consistent` field value in the same PR (no defaults — defaults defeat the purpose).

| File | Constructor |
|---|---|
| `.lake/packages/catept-plugin-architecture/.../Domains/SuperiorMethod.lean` | `SuperiorMethodSlot.toCATEPTSlot` |
| `CATEPTMain/Integration/VMLCATEPTBridge.lean` | `kineticCATEPTSlot` |
| `CATEPTMain/Integration/TheoryPluginClassicalETHBridge.lean` | (anonymous) |
| `CATEPTMain/Integration/TheoryPluginAdapter.lean` | `adapterCATEPTSlot` |
| `CATEPTMain/Integration/BCJBridge.lean` | `bcjProductSlot` |
| `CATEPTMain/Integration/ElectroweakCATEPTBridge.lean` | `higgsCATEPTSlot` |
| `CATEPTMain/Integration/UnifiedTheorySpine.lean` | (anonymous) |
| `CATEPTMain/CATEPT/CATEPT/PlanckModeBridge.lean` | (anonymous) |
| `CATEPTMain/NHQM/NHQMCATEPTBridge.lean` | (anonymous) |

For sites where `actionIm = eptClock` and `hbar = 1` (most of them, since they go through `SuperiorMethodSlot`), `consistent := fun _ => div_one _` is the inline value and the trivial nature becomes visible at the construction site instead of hidden under a helper. For sites where the underlying physics gives `actionIm ≠ eptClock` or `hbar ≠ 1`, the constructor must supply a real proof — see the Bohmian-EM phase below.

### What to do with the standalone `cateptConsistencyConstraint` def

After the field lands, the standalone def becomes logically redundant: `s.consistent` is the canonical proof of the same proposition. Recommendation:

- **Keep as a `def` alias** (no change to its body):
  ```lean
  def cateptConsistencyConstraint (s : CATEPTPluginSlot) : Prop :=
    ∀ x, s.actionIm x / s.hbar = s.eptClock x
  ```
  Existing call sites that prove `cateptConsistencyConstraint slot` continue typechecking; the proof becomes `slot.consistent` (with at most an `unfold cateptConsistencyConstraint` in front, often unneeded because the propositions reduce to the same shape).
- Optionally `@[deprecated]` the def to nudge new code toward `s.consistent` directly.
- Removing the standalone outright is cleanest but maximally disruptive — every consumer would migrate. Defer that to a separate cleanup PR.

## Migration plan — three honest phases

| Phase | Work | Effect |
|---|---|---|
| **F1** | Sibling: add `consistent` field to `CATEPTPluginSlot`. Pin bump in `catept-main/lakefile.lean` + `lake-manifest.json`. | The structure now requires a proof at every construction. |
| **F2** | Single coordinated PR updating all 8 catept-main constructor sites + `SuperiorMethodSlot.toCATEPTSlot` (in the sibling, on the same multi-repo PR cycle). For sites that go through `SuperiorMethodSlot`, the inline value is `consistent := fun _ => div_one _`. Delete or `@[deprecated]` the now-redundant `SuperiorMethodSlot.consistent` helper theorem. | The trivial discharge is visible at every construction site; no buried `div_one`. |
| **F3** | **Refactor `bohmianEMSuperiorSlot` off `SuperiorMethodSlot`.** This is more invasive than "supply a real proof" because `SuperiorMethodSlot.toCATEPTSlot` *forces* `actionIm = eptClock`, which makes `consistent` trivially `div_one` regardless of what `actionFn` is. To make Bohmian-EM substantive: build a `CATEPTPluginSlot` **directly** (via `where` syntax, not `SuperiorMethodSlot`) with `actionIm := bohmianEM_imaginary_action`, a *different* `eptClock` (e.g. an entropic clock derived from a Matsubara/Tomita identity), and a real `consistent` proof using `bohmianEM_action_expansion` + `field_simp`. | The publication-facing claim becomes substantive without inventing a new structure. |

## Out of scope — three other slot-`consistent` families not addressed here

The proposal's fix targets the `CATEPTPluginSlot`-flavoured `cateptConsistencyConstraint`. Two analogous definitions exist on different slot types and have the **same** shallowness shape but are not touched here:

| Definition | Operates on | File |
|---|---|---|
| `CATEPTMain.CATEPT.CATEPT.TheoryPluginArchitecture.cateptConsistencyConstraint` | `PluginSpec` | `CATEPTMain/CATEPT/CATEPT/TheoryPluginArchitecture.lean:36` |
| `CATEPTMain.CATEPT.CATEPT.cateptConsistencyConstraint` | `NHQMCATEPTSlot N` | `CATEPTMain/CATEPT/CATEPT/NHQMCATEPTBridge.lean:71` |

If the fix is judged successful for `CATEPTPluginSlot`, the same pattern (move the obligation into the structure) applies to these two. They're separated because they live in distinct slot families.

## Why your original requirement was right

The reviewer critique — *"the heavy lifting is in the hypotheses, not the Lean proofs themselves"* — describes precisely what happens when an architectural obligation is **outside** the structure. By keeping `consistent` external, the codebase let any slot be constructed without a proof, then optionally proved consistency downstream as a separate (universally trivial) theorem. The fix is to **move the obligation back into the structure** so a slot can't exist without its proof. That was the original ask, and the proposal lands it in the form the structure should have had from the start.

## Cost / risk summary

- **Cost**: ~1 sibling-repo PR + 9 file edits in catept-main + 1 lakefile + 1 lake-manifest update; probably 1–2 days of focused work.
- **Risk**: low for trivial-discharge sites (mechanical edit). Moderate for Bohmian-EM (F3) where the refactor changes how the slot is built.
- **Reversibility**: high — the change is additive (new required field). A reverting PR would just remove the field from the sibling and un-edit the constructors.

## What this delivers

- **Reviewer-visible honesty.** Every slot's consistency proof appears at the construction site. `consistent := fun _ => div_one _` is a one-liner anyone reading the slot definition immediately understands as a trivial-by-construction case. No theorem-name indirection.
- **Structural distinction** between domains where the spine identity is trivial by construction (most slots, with `actionIm = eptClock` and `hbar = 1`) and domains where it's earned by derived algebra (Bohmian-EM after F3, electrovacuum, future Schwarzschild/AdS-CFT non-trivial cases).
- **No theorem disappears.** `cateptConsistencyConstraint` stays as an alias; existing slot-satisfaction theorems on `feat/publication` keep building (their proofs become `slot.consistent`, possibly with an `unfold`).

## Worklog hook

Tracked under `catept_pub_slot_consistent_fix_20260506` (todo, p1) — the cost is non-trivial and crosses a sibling repo boundary, so this is a planned multi-step task rather than a one-shot patch.
