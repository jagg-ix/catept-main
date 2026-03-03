# Multi-platform wheelhouse (offline support)

Offline wheels live under:

`third_party/wheelhouse/<platform>/<python_tag>/`

Default behavior assumes internet is available. Offline is opt-in.

## Automated fetch (internet)
```bash
make fetch_wheelhouse_matrix
make verify_wheelhouse_checksums
```

See also:
- `third_party/OFFLINE_SETUP.md`
- `third_party/TODO_OFFLINE_PLATFORMS.md`
