# Group C — Architectural targets (open, multi-hour to multi-day)

This index lists the four architectural-restructure tasks currently
open in the worklog. Each is a substantive multi-hour-to-multi-day
piece; the pattern from T88 / T93 (handoff briefs followed by direct
execution) applies.

Helpers picking up any of these should:

1. Lock the worklog task (`set-task-status … --status in_progress`)
   per [`multi-helper-sync-protocol.md`](multi-helper-sync-protocol.md) §3.
2. Branch as `feat/<your-handle>/<task-slug>` per the protocol's §2.
3. Pick the next free T-tag at commit time (check
   `git log origin/main --oneline | grep -oE "T[0-9]+" | sort -V | tail -3`).
4. Run the pre-push checklist per §10 before pushing.

## C1 · `catept_arch_target6_hub_shape_20260425` — `in_progress`, p1

> Target 6: catept-main reshaped to ModularPhysics coordination hub
> (~50% LoC reduction)

**Effort**: multi-day, invasive.
**Goal**: shrink `CATEPTMain/` to the abstract core + `Bridges/`
+ coordination README + plugin-architecture abstract types only;
push remaining content out to sibling repos referenced via lakefile.
Pattern: `xiyin137/ModularPhysics` (the coordination-hub-only repo
with one Lean file).

Pre-reqs: stable plugin-architecture abstraction (overlap with C2).

## C2 · `catept_arch_t60_plugin_slot_decoupling_20260425` — `in_progress`, p2

> Wave-2 option (b): extract CATEPTPort plugin-slot abstraction as
> catept-plugin-architecture

**Effort**: ~half-day to one-day.
**Goal**: factor out the `CATEPTPort` + `CATEPTPluginSlot` +
`SuperiorMethodSlot` interface types into a new dedicated sibling
`catept-plugin-architecture`. Existing 17 plugins re-pin to depend
on the new interface sibling. This decouples interface evolution
from any specific plugin.

Pre-reqs: none — purely an extraction pattern matching the 17 already
shipped.

## C3 · `catept_arch_t63b_quantum_ops_port_20260426` — `todo`, p2

> T63b: extract catept-quantum-ops-port (drop 3 empty IMD scaffolding
> files)

**Effort**: ~half-day.
**Goal**: extract `CATEPTMain/QuantumOps/IsabelleMarresDirac/`
content as a new sibling `catept-quantum-ops-port`, drop the three
empty scaffold files identified in the task body.

Pre-reqs: none.

## C4 · `catept_arch_t62b_extract_lapl_brief_20260425` — `todo`, p1

> T62b: extract Analysis/LAPL as catept-domain-lapl (helper brief
> drafted)

**Effort**: ~half-day.
**Goal**: extract `CATEPTMain/Analysis/LAPL/` as a new sibling
`catept-domain-lapl`, matching the pattern of the existing
`catept-domain-{quantum,gauge,geometry,core,analysis}` umbrellas.

Pre-reqs: none. The helper brief mentioned in the task title is
already drafted in the worklog details.

## Recommended sequencing

1. **C2 first** — provides the interface abstraction the rest can
   depend on cleanly.
2. **C3 in parallel** — pure extraction, no overlap with C2.
3. **C4** — same shape as C3 / T57 / similar prior extractions.
4. **C1 last** — coordinates the big reshape and assumes C2-C4 land
   first to give it a clean abstraction layer to remove.

## Cross-references

* [`plugin-rework-proposal.md`](plugin-rework-proposal.md) — original
  rework note that names targets 1-4; C1 is roughly "Target 4 +
  ModularPhysics-shape repo".
* [`relational-information-substrate.md`](relational-information-substrate.md)
  — the substrate kernel architecture the spine sits on; no Group C
  task should weaken its interface.
* [`multi-helper-sync-protocol.md`](multi-helper-sync-protocol.md) —
  read §1-§3 before starting any of these (they are exactly the
  multi-helper concerns the protocol exists to manage).

## What's already shipped vs Group C

For context, **the whole Group C is "Wave-2"-style extraction work**.
The "Wave-1" extractions are already complete (17+ plugin siblings,
5/5 Class B umbrellas, T78 substrate kernel, 11 spine adapters).
Group C is a deliberate next-phase restructure that keeps the spine
contracts stable while shrinking `catept-main` itself.
