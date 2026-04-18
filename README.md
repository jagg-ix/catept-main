# CATEPT Main (Lean 4.29 Clean Migration)

This repository is a clean Lean 4.29 integration hub.

## Integrated repositories

### Direct 4.29 lane (wired in `lakefile.lean`)

- `bochner`
- `hille-yosida`
- `pphi2`
- `cslib-inspect`

### CAT/EPT Maxwell-CurveSpace + pphi2 bridge

- `CATEPTMain/Integration/MaxwellCurveSpacePphi2Bridge.lean`
	- adds an interface-level integration contract between CAT/EPT curved Maxwell/CurveSpace
		assumptions and a pphi2 OS/reconstruction witness.

### Bridge or upgrade lane (tracked in integration matrix)

- `lean-quantuminfo-inspect`
- `brownian-motion-inspect`
- `kolmogorov-complexity-lean-inspect`

### Legacy port-required lane (tracked in integration matrix)

- `ThermodynamicsLean-inspect`
- `carleson-inspect`
- `gibbsmeasure-inspect`
- `hopf-lean-4.26-port`

## How integration is represented

- `lakefile.lean`: active direct 4.29 dependencies with pinned commits.
- `integration/repos.yaml`: full registry for all requested repositories.
- `CATEPTMain/External/Registry.lean`: Lean-side registry for integration visibility.
- `scripts/sync_repo_matrix.sh`: emits current local commit/toolchain snapshot.
- `scripts/build_direct_lane.sh`: builds the direct 4.29 lane.

## Commands

```bash
cd /Users/macbookpro/lab/tau/tau-information-dynamics/catept-main
bash scripts/sync_repo_matrix.sh
bash scripts/build_direct_lane.sh
```

## Verification

- Operational verification guide: `VERIFICATION.md`
- NS contract checks: `tools/verification/check_ns_semantic_strictness.py` and
  `tools/verification/check_ns_physical_theorem_contracts.py`
- LeanMillennium statement-conformance benchmark:
  - metadata map: `docs/workstation/NS_LEAN_MILLENNIUM_BENCHMARK_MAP.json`
  - local gate command: `python3 tools/verification/run_ns_leanmillennium_conformance_bundle.py`
