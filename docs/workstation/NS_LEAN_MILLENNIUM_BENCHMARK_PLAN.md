# LeanMillennium Navier-Stokes External Benchmark Plan

Date: 2026-04-17
Scope: use `lean-dojo/LeanMillenniumPrizeProblems` as a canonical external statement benchmark for the local Navier-Stokes formalization.

## Objective

Use the upstream LeanMillennium Navier-Stokes statements as a canonical specification target, then measure local statement-level conformance without coupling local builds to upstream toolchain/runtime.

## Execution Status

- Phase 1 (`schema_and_pin`): completed.
- Phase 2 (`local_mirror_spec`): completed.
- Phase 3 (`conformance_bridge`): completed.
- Phase 4 (`conformance_report`): completed.
- Phase 5 (`local_policy_gate`): completed.

Produced:
- `docs/workstation/NS_LEAN_MILLENNIUM_BENCHMARK_MAP.json`
- `NavierStokes/Benchmark/LeanMillenniumNavierStokesSpec.lean`
- `NavierStokes/Benchmark/LeanMillenniumConformanceBridge.lean`
- `tools/verification/report_ns_leanmillennium_conformance.py`
- `tools/verification/run_ns_leanmillennium_conformance_bundle.py`
- `verification/bridge_audits/ns_leanmillennium_conformance.json`

## Why This Is Useful

1. It gives an external, independent reference for the Clay statement shape (A/B/C/D).
2. It separates statement conformance from constructive closure progress.
3. It reduces claim drift by forcing explicit map entries between local and external statement objects.

## Upstream Reference Snapshot

Repository: `https://github.com/lean-dojo/LeanMillenniumPrizeProblems`

Key files:
- `Problems/NavierStokes/Navierstokes.lean`
- `Problems/NavierStokes/MillenniumRDomain.lean`
- `Problems/NavierStokes/MillenniumBoundedDomain.lean`
- `Problems/NavierStokes/Millennium.lean`

Observed toolchain mismatch:
- Upstream: `lean4:v4.26.0`
- Local NS package: `lean4:v4.29.0`

Decision: treat upstream as external benchmark input, not a direct compile-time dependency in the local package.

## Local Mapping Targets

- A-like: `NavierStokes.Millennium.millennium_A_whole_space_existence_smoothness`
- B-like: `NavierStokes.Millennium.millennium_B_whole_space_breakdown_counterexample`
- C-like: `NavierStokes.Millennium.millennium_C_periodic_existence_smoothness`
- D-like: `NavierStokes.Millennium.millennium_D_periodic_breakdown_counterexample`

## Local Commands

```bash
# phase 4 report
python3 tools/verification/report_ns_leanmillennium_conformance.py

# phase 5 bundle gate
python3 tools/verification/run_ns_leanmillennium_conformance_bundle.py
```

Expected output shape:

```text
status=pass
hard_pass=True
output=.../verification/bridge_audits/ns_leanmillennium_conformance_bundle.json
```

## Gate Policy

- FAIL if any required mapped symbol is missing.
- FAIL if upstream pin is missing.
- WARN (not fail) for explicitly axiomatized B/D anchors.

## Non-Goals

1. Proving the Millennium problem via upstream repository.
2. Importing and building upstream code inside this package.
3. Replacing local constructive route with external statements.
