# Offline setup (hand-off workflow)

## 1) Populate the wheelhouse on an internet machine
From repo root:

```bash
make fetch_wheelhouse_matrix
```

Customize as needed:

```bash
PACKAGES="qutip einsteinpy numpy scipy sympy astropy matplotlib" make fetch_wheelhouse_matrix
PYTAGS="cp311" PLATFORMS="macos_x86_64" make fetch_wheelhouse_matrix
```

This writes:
- `third_party/wheelhouse/_matrix_report.txt`
- `third_party/wheelhouse/MANIFEST.txt`
- `third_party/wheelhouse/SHA256SUMS.txt`

## 2) Verify integrity
```bash
make verify_wheelhouse_checksums
```

## 3) Hand-off to offline machine
On the offline machine:

```bash
make install_offline_wheels_with_requirements
make end2end_sgi_suite_require_qutip_einsteinpy
```

## Notes
- Some packages may not publish wheels for all platform/python combos.
- This repo defaults to online workflows; offline workflows are opt-in.


## Lite bundle note
This distribution is a **lite** repo bundle and does not include pre-downloaded wheels.
Run `make fetch_wheelhouse_matrix` on an internet machine to populate `third_party/wheelhouse/`.
