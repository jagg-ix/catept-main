# Third-party vendoring (offline-friendly)

This repo can run in environments without internet by vendoring wheels for heavy dependencies.

## Why this exists
Some environments (e.g., sandboxes/CI runners) do not have QuTiP or EinsteinPy installed and cannot fetch them.
Instead of silently falling back, you can **build wheels from local clones** and vendor them into this repo.

## What you do
1) Obtain local clones of:
   - QuTiP (`qutip`)
   - EinsteinPy (`einsteinpy`)
2) Build wheels and drop them into:
   - `third_party/wheels/`

Then install using only the wheelhouse.

## Commands
From repo root:

```bash
make vendor_deps QUTIP_REPO=/path/to/qutip EINSTEINPY_REPO=/path/to/einsteinpy
```

This will:
- build wheels into `third_party/wheels/`
- write `third_party/INSTALL_OFFLINE.md` with the exact install command for your platform

## Offline install (example)

```bash
python -m pip install --no-index --find-links third_party/wheels -r requirements.txt
python -m pip install --no-index --find-links third_party/wheels qutip einsteinpy
```

Notes:
- Wheels are platform-specific. Build them on the same OS/Python version you intend to run.
- If a dependency only builds as an sdist, you may need system build tools (BLAS/LAPACK, compilers).


## Prefer prebuilt wheels

If you have internet access, prefer vendoring wheels instead of building from source:

```bash
make vendor_wheels
# or include common deps too:
make vendor_wheels_all_deps
```


## Wheelhouse (offline)
See `third_party/WHEELHOUSE.md`.
