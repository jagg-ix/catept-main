# Recovery Utilities

Reusable utilities for deterministic cherry-pick recovery workflows.

## Scripts

- `build_recovery_queue.py`
  - Builds deduped replay queues from a source branch using `cherry picked from commit` trailers.
  - Produces queue artifacts (JSON/CSV) under `.recovery/` by default.

- `run_recovery_replay.py`
  - Replays a queue onto a fresh branch from a base branch.
  - Applies strict safe conflict rules and writes structured JSONL logs.

## Typical flow

```bash
# 1) Build queue
python3 tools/verification/recovery/build_recovery_queue.py \
  --base main \
  --source-branch cherry-pick-nsi-related-20260417 \
  --out-dir .recovery

# 2) Run replay
python3 tools/verification/recovery/run_recovery_replay.py \
  --queue .recovery/recovery_queue_priority.json \
  --base main
```

## Notes

- Default output directory is `.recovery/` (local workspace artifacts).
- `run_recovery_replay.py` blocks when tracked files are dirty; untracked files are allowed.
- Conflict policy is intentionally conservative. Unsafe paths are reported and skipped.
- If your source branch naming differs, always pass `--source-branch` explicitly.
