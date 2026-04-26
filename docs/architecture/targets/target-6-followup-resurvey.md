# Target 6 Follow-up Re-survey (T62)

**Task code**: `catept_arch_t62_target6_followup_resurvey_20260425`  
**Date**: 2026-04-26  
**Context**: Target 6 landed on `origin/main` at `d017aa7cd` (includes
`f094b96d8` orphan-tree removal and `d017aa7cd` AFPBridgeLegacy cleanup).

---

## Goal

Re-evaluate the extraction surface after the Target-6 hub-shape deletions,
then identify the safest next split lanes that do not collide with active
Wave-2 workstreams.

---

## Method

Scanned `CATEPTMain/Integration/*.lean` import headers and computed per-file
**internal dependency fan-in**:

- internal imports: `CATEPTMain.*`, `NavierStokes.*`, `NavierStokesClean.*`
- plugin imports: `CATEPTPlugin*`
- external imports: everything else (Mathlib, sibling repos, etc.)

`*_WORKLOG.lean` files were excluded.

---

## Re-survey Results

### Surface size

- Integration modules scanned: **98**

### Internal fan-in distribution

| Internal fan-in | Count |
|---|---:|
| `0` | 30 |
| `1` | 27 |
| `2` | 20 |
| `3-5` | 14 |
| `6-10` | 2 |
| `11+` | 5 |

### Key structural observations

1. **Already-split plugin shims** (`fan-in = 0`, imports `CATEPTPlugin*`): **16**
2. **External-only wrappers** (`fan-in = 0`, non-plugin): **14**  
   Mostly thin wrappers over external packages (`String*`, `SG*`, `StochasticPDE*`,
   `VMLSteadyState`, `LeanInf`), already low-risk and not load-bearing.
3. **Plugin-slot-coupled files** (direct import of
   `CATEPTMain.Integration.TheoryPluginArchitecture`): **11**  
   These remain blocked on plugin-slot decoupling (T60 option (b)).
4. **CATEPTSpaceTime-centric chain** (direct import of
   `CATEPTMain.Integration.CATEPTSpaceTime`): **21**  
   This is now the clearest cohesive non-leaf bundle surface.

### Highest fan-in anchors (still non-session-sized)

| Fan-in | File |
|---:|---|
| 28 | `CATEPTSelfConsistency.lean` |
| 26 | `NSCATEPTExtendedBridge.lean` |
| 14 | `QuantumInfoFisherBridge.lean` |
| 13 | `TheoryPluginAdapter.lean` |
| 12 | `NSCATEPTCoreBridge.lean` |

---

## Updated Shortlist (post-T6)

### Unblocked now

1. **Continue T62 documentation + inventory refresh** (this artifact).
2. **Prepare CATEPTSpaceTime bundle feasibility note**  
   Candidate cluster already visible (21 direct dependents), does not require
   immediate plugin-slot refactor.

### In progress by other helpers (avoid overlap)

1. `catept_arch_t60s2_foundations_to_catept_core_20260425` (in progress)
2. `catept_arch_t61_domain_quantum_bundle_20260425` (in progress)

### Still blocked / high-risk without upstream moves

1. **Plugin-slot-coupled lane** (`TheoryPluginArchitecture` importers)  
   Requires `catept_arch_t60_plugin_slot_decoupling_20260425`.
2. **High fan-in NS/CATEPT composites** (`fan-in >= 11`)  
   Too coupled for incremental split without prior domain decomposition.

---

## Recommendation

Treat T62 as complete with this re-survey output and move next extraction design
work to:

1. finish T60 step 2 and T61 in-flight work;
2. then choose between:
   - plugin-slot decoupling (T60 option (b)), or
   - a scoped CATEPTSpaceTime-centered bundle pilot.

