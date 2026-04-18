# Offline install using vendored wheels

If you have wheels in `third_party/wheels/`, you can install without internet:

```bash
python -m pip install --no-index --find-links third_party/wheels -r requirements.txt
python -m pip install --no-index --find-links third_party/wheels qutip einsteinpy
```

Then enforce backend usage:

```bash
make end2end_sgi_suite_require_qutip
# or, if you want GR features too:
make end2end_sgi_suite_require_qutip_einsteinpy
```

## Why this is preferred over building QuTiP from source
QuTiP commonly has compiled extensions and a heavier build toolchain. If wheels are available for your OS/Python,
installing wheels is faster and more reliable than source builds.
