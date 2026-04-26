# Target 60 Option (b) — Plugin-Slot Decoupling Preflight

**Task code**: `catept_arch_t60_plugin_slot_decoupling_20260425`  
**Date**: 2026-04-26  
**Branch for this preflight**: `feat/codex-gpt5/t60-preflight`

---

## Goal

Convert T60 option (b) from a broad idea into an executable extraction sequence
for `CATEPTPort` / plugin-slot architecture, with measured dependency cut lines
and explicit non-overlap with active helper lanes.

---

## Reusable Scanner

Use:

```bash
scripts/t60_plugin_slot_preflight_scan.sh
```

This scanner reports:

- direct importers of `CATEPTMain.Integration.TheoryPluginArchitecture`
- direct importers of `CATEPTMain.CATEPT.CATEPT.CATEPTPort`
- direct importers of `CATEPTMain.CATEPT.CATEPT.TheoryPluginArchitecture`
- the `CATEPTPort` barrel-import set
- LoC sizing for the architecture boundary files

Importer migration companion:

- [`target-60-plugin-slot-importer-migration-map.md`](target-60-plugin-slot-importer-migration-map.md)
- `scripts/t60_plugin_slot_importer_map.sh`

---

## Measured Cut Map (2026-04-26)

### Surface summary

- Integration modules scanned: **98**
- Direct importers of `Integration.TheoryPluginArchitecture`: **11**
- Direct importers of `CATEPTPort`: **3**
- Direct importers of core `CATEPT.CATEPT.TheoryPluginArchitecture`: **3**

### `Integration.TheoryPluginArchitecture` importer set (with internal fan-in)

- `CATEPTMain/Integration/TheoryPluginAdapter.lean` (`13`)
- `CATEPTMain/Integration/UnifiedTheorySpine.lean` (`5`)
- `CATEPTMain/Integration/ComplexEinsteinPathIntegralBridge.lean` (`4`)
- `CATEPTMain/Integration/QuantumCATEPTBridge.lean` (`3`)
- `CATEPTMain/Integration/ElectroweakCATEPTBridge.lean` (`2`)
- `CATEPTMain/Integration/TheoryPluginDimSlot.lean` (`2`)
- `CATEPTMain/Integration/TheoryPluginPhyslibConstructBridge.lean` (`2`)
- `CATEPTMain/Integration/TheoryPluginStressTests.lean` (`2`)
- `CATEPTMain/Integration/VMLCATEPTBridge.lean` (`2`)
- `CATEPTMain/Integration/AlphaPathIntegralIntegration.lean` (`1`)
- `CATEPTMain/Integration/TheoryPluginClassicalETHBridge.lean` (`1`)

### `CATEPTPort` direct importers

- `CATEPTMain/Bridges.lean`
- `CATEPTMain/Integration/TheoryPluginAdapter.lean`
- `CATEPTMain/Integration/TheoryPluginArchitecture.lean`

### `CATEPTPort` barrel payload

- `FeynmanKacBridge`
- `ModularFlowBridge`
- `ComplexMeasureBridge`
- `CATEPTPlanckBridge`
- `DSFCouplingKernel`
- `UnificationChain`
- `BridgeTheoryCompatibility`

### Boundary file sizes

- `CATEPTMain/CATEPT/CATEPT/CATEPTPort.lean`: **95 LoC**
- `CATEPTMain/Integration/TheoryPluginArchitecture.lean`: **370 LoC**
- `CATEPTMain/CATEPT/CATEPT/TheoryPluginArchitecture.lean`: **254 LoC**

---

## Interpretation

1. `CATEPTPort` itself is small, but it is a barrel over a 7-module payload that
   reaches active T60 step-2 dependencies (`Foundations`, `PathIntegrals`,
   `MeasurePathIntegral`, `Core.Assumptions`) via `FeynmanKacBridge` /
   `ComplexMeasureBridge` /
   `ModularFlowBridge`.
2. The highest immediate blast radius is at
   `Integration/TheoryPluginArchitecture -> TheoryPluginAdapter`.
3. Extracting only `Integration/TheoryPluginArchitecture` without a stable
   `CATEPTPort` strategy just moves the coupling point and does not unblock
   downstream bridge extraction safely.

---

## Execution Sequence (safe with current helper work)

### Phase A: preflight and lock (this step)

- Publish measured cut map and reusable scanner.
- Do not edit active helper files in T60s2/T61 lanes.

### Phase B: wait-for-merge gate

Proceed only after `catept_arch_t60s2_foundations_to_catept_core_20260425`
lands on `origin/main`, because those files are direct upstream dependencies of
`CATEPTPort` payload modules.

### Phase C: architecture sibling extraction

Create sibling repo `jagg-ix/catept-plugin-architecture` with first cut:

- `CATEPTMain.CATEPT.CATEPT.CATEPTPort`
- `CATEPTMain.Integration.TheoryPluginArchitecture`
- optional facade exports preserving old names for low-churn migration

Keep namespace compatibility in v0.1.0 to avoid importer churn in 11 bridge
modules during first landing.

### Phase D: reintegration in `catept-main`

- pin sibling in `lakefile.lean` and `lake-manifest.json`
- convert in-tree files to thin re-export shims
- run build + axiom-gate

---

## Non-overlap Contract

This preflight intentionally avoided editing the active helper lanes:

- `catept_arch_t60s2_foundations_to_catept_core_20260425` (in progress)
- `catept_arch_t61_domain_quantum_bundle_20260425` (in progress)

Only docs + scanner were changed.
