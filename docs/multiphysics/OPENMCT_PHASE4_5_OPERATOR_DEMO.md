# Open MCT Integration (Phases 4-5)

Status: implemented (local workstation flow)

## Phase 4: Mission Views

Mission-view composition is now provided in the frontend plugin:

- `webapp/openmct/catept-openmct-plugin.js`
- `webapp/openmct/openmct.config.json`

The root now exposes:

1. `Mission Views`
2. `All Channels`

Configured mission views currently include:

- `Native Strict Matrix`
- `Chrono Operations`
- `Anomaly Validation Timeline`

Each view groups channels using explicit channel IDs and/or prefix matching.

## Phase 5: Operator E2E Demo Flow

Validator:

- `tools/multiphysics/validate_openmct_operator_demo_flow.py`

Artifact:

- `verification_results/stack_audits/openmct_operator_demo_validation.json`

What it validates:

1. Snapshot generation from stack audits
2. Adapter service restart and bind (`8093` default)
3. Frontend service restart and bind (`8094` default)
4. Adapter endpoints (`/health`, `/api/openmct/objects`, `/api/openmct/snapshot`)
5. Frontend availability (`/index.html`, `/openmct.config.json`)
6. Presence of mission-view definitions

## Usage

Dry-run (no service restarts):

```bash
python3 tools/multiphysics/validate_openmct_operator_demo_flow.py --dry-run
```

Full local operator demo validation:

```bash
python3 tools/multiphysics/validate_openmct_operator_demo_flow.py
```

Manual service control:

```bash
python3 tools/multiphysics/openmct_adapter_service.py --include-mcp-context restart
python3 tools/multiphysics/openmct_frontend_service.py restart
python3 tools/multiphysics/openmct_adapter_service.py status
python3 tools/multiphysics/openmct_frontend_service.py status
```

Open in browser:

- `http://127.0.0.1:8094/index.html`

## Notes

- This is local-first and does not depend on CI.
- Auth/multi-user hardening remains out of scope for this phase.
