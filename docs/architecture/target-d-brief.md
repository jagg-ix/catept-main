# Target D — strengthen the entropic-time integration

**Worklog code**: `catept_substrate_entropic_time_integration_20260427`
**Priority**: p2
**Tag**: `catept,substrate,entropic-time,t78-followup,architecture-note-target-D`
**Estimated effort**: 1-2 hours
**Builds on**: T78 (substrate kernel), T85 (substrate-backed spacetime axioms), T86 (substrate assumption tags)

## Goal (verbatim from architecture note)

From [`docs/architecture/relational-information-substrate.md`](catept-main/docs/architecture/relational-information-substrate.md) lines ~282-291:

> ### Target D: strengthen the entropic-time integration
>
> `EntropicProperTimeCoreBridge.lean` already records the right thermodynamic
> identities, but the compatibility theorem with spacetime is still trivial.
>
> Recommended direction:
>
> - connect irreversible-cost positivity to `ept_nonneg`,
> - connect accumulated entropic time to `ept_causal_arrow`,
> - avoid duplicating this bridge elsewhere.

## Why this is the natural follow-on to T85

T85 added `SubstrateBackedSpacetimeAxioms` with substantive ∀-statements
for `ept_causal_arrow` and `noFTL` (substrate-derived from `localOrder_causal`
and `notificationDelay_le_bound`). The entropic-time bridge currently
sits at a lower rigor level — its compatibility theorem with spacetime is
literally `trivial` returning `True`. Target D pulls the same substrate
machinery used in T85 into the entropic-time bridge.

## Current state — citations

### File 1: `CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean` (100 lines, all built and audit-clean)

The compatibility theorem to upgrade lives at **lines 91-99** verbatim:

```lean
/-- Consistency with `CATEPTSpacetimeModel`: every EPT model satisfying
    `ept_nonneg` and `ept_causal_arrow` is compatible with the core witness. -/
theorem entropicProperTimeCore_spacetime_compatible
    (st : CATEPTSpacetimeModel) :
    True :=
  trivial
-- Phase-2: show that `st.ept_nonneg` corresponds to `sImag_nonneg` and
-- `st.ept_causal_arrow` corresponds to `tauEnt_integral_form`.
```

The trailing comment is literally the Phase-2 plan that Target D asks
us to execute.

The witness structure at **lines 49-67** is also relevant:

```lean
structure EntropicProperTimeCoreWitness where
  sImag_nonneg : Prop                  -- "S_I ≥ 0" claim, abstract
  tauEnt_def : Prop                    -- "τ_ent = S_I / ℏ" claim, abstract
  tauEnt_integral_form : Prop          -- "τ_ent = ∫λ dt'" claim, abstract
  suppressionFactor_bound : Prop       -- "0 < K ≤ 1"
  cosh_bound : Prop                    -- "cosh(τ_ent) ≥ 1"
  landauer_cost : Prop                 -- "k_B T ln 2 per bit"
  visibility_bound : Prop              -- "−log(V/V₀) bound"
  axiom_audit_phase1 : Prop
```

Every field is `Prop` (abstract); fields are populated externally via
`entropicProperTimeCore_integration_contract`.

### File 2: `CATEPTMain/Integration/RelationalInformationSubstrate.lean` (T78)

Already has the substantive content this bridge needs:

| Substrate field | What it gives | File line |
|---|---|---|
| `irreversibleCost : Entity → ℝ` | the substrate's S_I per entity | 74 |
| `irreversibleCost_nonneg` | `∀ e, 0 ≤ S.irreversibleCost e` | 76 |
| `tauEnt S E e := S.irreversibleCost e / E.hbar` | the τ_ent definition | 141-143 |
| `tauEnt_def` | `tauEnt S E e = irreversibleCost / hbar` (rfl) | 146-149 |
| `tauEnt_nonneg` | `∀ e, 0 ≤ tauEnt S E e` | 152-155 |
| `localOrder_causal` | strict-monotone ordinal along causal chains | (kernel field) |

### File 3: `CATEPTMain/Integration/SubstrateBackedSpacetimeAxioms.lean` (T85)

Provides the bundled substantive axioms structure that this Target D
work should compose with:

```lean
structure SubstrateBackedSpacetimeAxioms (S : RIS) where
  ept_causal_arrow_substrate :
    ∀ {n₁ n₂ e}, ... → S.localOrder e n₁ < S.localOrder e n₂
  noFTL_substrate :
    ∀ n, S.notificationDelay n ≤ S.propagationBound

def fromSubstrate (S : RIS) : SubstrateBackedSpacetimeAxioms S
```

### File 4: `CATEPTMain/Integration/CATEPTSpaceTime.lean`

Has `SubstrateSpacetimeProjection` (T78, lines 222-228) and the
canonical projection `toCATEPTSpacetimeModel` (lines 234-244). The
ept field on the projected model is `RelationalInformationSubstrate.tauEnt`.

## The gap

`entropicProperTimeCore_spacetime_compatible st : True := trivial`

This needs to become something like:

```lean
theorem entropicProperTimeCore_spacetime_compatible_substrate
    {S : RelationalInformationSubstrate}
    (E : RelationalInformationSubstrate.EntropicClock S)
    (P : SubstrateSpacetimeProjection S)
    (A : SubstrateBackedSpacetimeAxioms S) :
    -- (1) ept_nonneg corresponds to sImag_nonneg
    (∀ x : (P.toCATEPTSpacetimeModel).SpaceTime,
        0 ≤ (P.toCATEPTSpacetimeModel).ept x)
    ∧
    -- (2) ept_causal_arrow corresponds to tauEnt_integral_form
    --     (substrate's local-order monotonicity along causal chains)
    (∀ {n₁ n₂ : S.Notification} {e : S.Entity},
        S.receiver n₁ = e → S.receiver n₂ = e →
        S.causalPrecedes n₁ n₂ → S.localOrder e n₁ < S.localOrder e n₂)
```

## Concrete plan (3 deliverables, all small)

### Deliverable 1 (REQUIRED): substrate-backed compatibility theorem

Add a new theorem alongside the existing `trivial` one:

```lean
/-- **Substrate-backed compatibility.** When the spacetime model arises
    from a substrate projection, the abstract phase-1 compatibility
    upgrades to a substantive correspondence:

    1. `st.ept_nonneg` ↔ substrate's `irreversibleCost_nonneg / hbar > 0`
       (which is just `tauEnt_nonneg` — already proved in T78).
    2. `st.ept_causal_arrow` ↔ substrate's `localOrder_causal`
       (provided by T85's `SubstrateBackedSpacetimeAxioms`).

    This discharges the Phase-2 comment at the bottom of this file with
    real content. -/
theorem entropicProperTimeCore_spacetime_compatible_substrate
    {S : CATEPTMain.Integration.RelationalInformationSubstrate}
    (E : CATEPTMain.Integration.RelationalInformationSubstrate.EntropicClock S)
    (P : CATEPTMain.Integration.CATEPTSpaceTime.SubstrateSpacetimeProjection S)
    (A : CATEPTMain.Integration.SubstrateBackedSpacetimeAxioms S) :
    (∀ x : P.toCATEPTSpacetimeModel.SpaceTime,
        0 ≤ P.toCATEPTSpacetimeModel.ept x)
    ∧
    (∀ {n₁ n₂ : S.Notification} {e : S.Entity},
        S.receiver n₁ = e → S.receiver n₂ = e →
        S.causalPrecedes n₁ n₂ → S.localOrder e n₁ < S.localOrder e n₂) :=
  ⟨P.toCATEPTSpacetimeModel.ept_nonneg, A.ept_causal_arrow_substrate⟩
```

The proof is just packaging existing facts. No tactics needed.

### Deliverable 2 (REQUIRED): retire the trivial compatibility theorem in spirit

Keep the existing `entropicProperTimeCore_spacetime_compatible` for
backward compat (return type is `True`, anything that consumes it stays
working), but add a new `*_strong` variant on the model alone:

```lean
/-- Stronger compatibility: any model whose `ept_nonneg` is genuine
    discharges the substrate-side `sImag_nonneg` claim concretely.
    No substrate required — uses only the abstract model. -/
theorem entropicProperTimeCore_model_compatible_strong
    (st : CATEPTSpacetimeModel) :
    ∀ x : st.SpaceTime, 0 ≤ st.ept x :=
  st.ept_nonneg
```

This handles "without substrate" half: even an abstract model whose
ept_nonneg field is real (not := trivial) discharges the claim.

### Deliverable 3 (OPTIONAL): retire `tauEnt_integral_form` placeholder

Currently `EntropicProperTimeCoreWitness.tauEnt_integral_form` is just
`Prop`. With T85's substrate axioms in scope, you could refine the
field-level claim to a substrate-backed version. **This requires
modifying the witness structure**, which is more invasive — only do it
if Deliverables 1 and 2 land cleanly first.

## Files to touch

| File | Change |
|---|---|
| `CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean` | add 2-3 new theorems alongside the existing ones; do NOT delete the existing `entropicProperTimeCore_spacetime_compatible : True` (back-compat) |
| `CATEPTMain/Domains/CoherenceShowcase.lean` | add `#print axioms` lines for the new theorems near the T85 block |

**No new files needed.** Both deliverables are additive to existing files.

## Imports to add to the bridge file

```lean
import CATEPTMain.Integration.RelationalInformationSubstrate
import CATEPTMain.Integration.SubstrateBackedSpacetimeAxioms
```

(The file already imports `CATEPTSpaceTime`.)

## Acceptance criteria

1. `lake build CATEPTMain.Integration.EntropicProperTimeCoreBridge` succeeds.
2. `lake build CATEPTMain.Domains.CoherenceShowcase` succeeds and emits
   new `#print axioms` info lines for the new theorems, all on
   `[propext, Classical.choice, Quot.sound]`.
3. The CI gate (`.github/workflows/axiom-gate.yml`) extension from T75
   continues to pass — no changes needed to CI.
4. The existing `entropicProperTimeCore_spacetime_compatible : True`
   theorem is **preserved unchanged** (back-compat for any consumer that
   currently uses it).
5. Audit gate count grows from 95 to ~97-98 (2-3 new theorems).
6. Worklog: mark `catept_substrate_entropic_time_integration_20260427`
   `done`; log a milestone note.

## Build commands

Standard pattern from prior T-series work:

```bash
cd /private/tmp/<your-worktree>
git fetch origin
git checkout -b feat/<your-handle>/target-d-entropic-time origin/main

# Edit the file, then:
lake build CATEPTMain.Integration.EntropicProperTimeCoreBridge
lake build CATEPTMain.Domains.CoherenceShowcase

# Verify the audit gate is green:
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 | tee /tmp/audit.txt
if grep -v -E "propext|Classical\.choice|Quot\.sound|^#print|depends on axioms:|^$" /tmp/audit.txt | grep -qE "axiom|sorryAx"; then
  echo "FAIL"; exit 1
fi
echo "PASS"

# Commit + push (fast-forward direct to main, matching T70-T86 convention)
git add CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean CATEPTMain/Domains/CoherenceShowcase.lean
git commit -m "T87: substrate-backed entropic-time / spacetime compatibility (Target D)
   ..."
git push origin <commit-sha>:main
```

## Worklog protocol (multi-helper sync)

Before starting:

```bash
DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PYTHONPATH=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool \
  python3 -c "from ept_worklog.cli import main; import sys; \
    sys.argv=['wl','--db','$DB','set-task-status', \
              '--code','catept_substrate_entropic_time_integration_20260427', \
              '--status','in_progress']; main()"
```

After completion:

```bash
PYTHONPATH=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool \
  python3 -c "from ept_worklog.cli import main; import sys; \
    sys.argv=['wl','--db','$DB','set-task-status', \
              '--code','catept_substrate_entropic_time_integration_20260427', \
              '--status','done']; main()"
```

Plus a `log-note` with `--task-code` linking the milestone.

## Naming convention

Use **T87** as the commit tag (next free number after T86). My T82-T83
were "claude-opus-4-7" and the parallel agent's were "copilot-claude"
T82-T84; the next free number on the integrated history is T87.

If you're a different helper handle, branch as
`feat/<your-handle>/target-d-entropic-time` and prefix audit-line
comments with your handle's tag (e.g., `T87-codex` or `T87-copilot`).

## What this completes

After Target D lands, the architecture-note plan is **5 of 5 complete**:

| Target | Status |
|---|---|
| A — substrate kernel | done (T78) |
| B — substrate-backed spacetime axioms | done (T85) |
| C — substrate-to-Bell adapter | done (T83) |
| **D — entropic-time integration** | **THIS TASK** |
| E — substrate-facing assumption ids | done (T86) |

That closes the substrate-architecture phase of the rework cleanly.
The substrate now plays its full ontological role: ontological floor
(T78), causal-geometry discharge (T85), Bell-correlation no-FTL (T83),
entropic-time integration (this task), assumption-tracking (T86).
