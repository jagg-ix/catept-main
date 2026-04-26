# Target 60 Option (b) — Importer Migration Map

**Task code**: `catept_arch_t60_plugin_slot_decoupling_20260425`  
**Date**: 2026-04-26

---

## Goal

Provide a concrete migration map for all current consumers of
`CATEPTMain.Integration.TheoryPluginArchitecture`, so the plugin-slot split can
be executed as a controlled sequence rather than an all-at-once refactor.

---

## Reusable Tool

Run:

```bash
scripts/t60_plugin_slot_importer_map.sh
```

The tool emits:

- full importer table (fan-in + coupling category)
- direct-sibling rewrite targets per file

---

## Current Importer Topology (2026-04-26)

- Importers: **11**
- Anchor file (direct `CATEPTPort` coupling): **1**
- Adapter-chain consumers: **1**
- Direct architecture consumers: **9**

### Coupling categories

1. `anchor_direct_cateptport`
   - `CATEPTMain/Integration/TheoryPluginAdapter.lean`
2. `adapter_chain_consumer`
   - `CATEPTMain/Integration/TheoryPluginPhyslibConstructBridge.lean`
3. `direct_arch_consumer`
   - all remaining 9 importer files

---

## Migration Modes

### Mode A (recommended for v0.1.0): shim-first

- Keep existing `import CATEPTMain.Integration.TheoryPluginArchitecture` in all
  11 files.
- Convert in-tree `TheoryPluginArchitecture.lean` into a thin re-export shim
  over sibling namespace.
- Zero importer churn in first landing.

### Mode B: direct-sibling imports

- Rewrite all 11 importer files to:

```lean
import CATEPTPluginArchitecture.Integration.TheoryPluginArchitecture
```

- Use when the sibling API is stable and we want to remove shim indirection.

---

## Suggested Execution Order (if Mode B is chosen)

1. `TheoryPluginAdapter.lean` (anchor)
2. `TheoryPluginPhyslibConstructBridge.lean` (depends on adapter)
3. remaining 9 direct architecture consumers in one batch

This preserves a monotone dependency path during rewrites.

---

## Safety Notes

- This map is intentionally docs/tools-only and does not modify active helper
  files in T60s2/T61 lanes.
- Re-run the script before actual rewrite/merge to ensure importer list is
  current.
