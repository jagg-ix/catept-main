# Verification

This repository tracks Navier-Stokes/CAT-EPT verification support in three lanes:

1. Lean theorem-contract checks (`tools/verification/check_ns_*`)
2. Benchmark mapping against LeanMillennium external statements
3. Mathematica package assets under `verification/`

Reference repository for broader CAT/EPT verification material:
- `https://github.com/jagg-ix/catept-verification`

## Local benchmark-conformance commands

```bash
# Generate statement-conformance report
python3 tools/verification/report_ns_leanmillennium_conformance.py

# Run strict bundle gate (fails on missing symbol coverage)
python3 tools/verification/run_ns_leanmillennium_conformance_bundle.py
```

Generated artifacts:

- `verification/bridge_audits/ns_leanmillennium_conformance.json`
- `verification/bridge_audits/ns_leanmillennium_conformance_bundle.json`

## Benchmark metadata

- Map: `docs/workstation/NS_LEAN_MILLENNIUM_BENCHMARK_MAP.json`
- Plan: `docs/workstation/NS_LEAN_MILLENNIUM_BENCHMARK_PLAN.md`
- Policy: required external symbols A/B/C/D/DISJ must all be mapped.
- Current policy treats axiom-backed B/D local anchors as `warn`, not hard fail.

## Notes

This file is an operational index. It intentionally avoids publication-level claims and points to reproducible local checks instead.
