#!/usr/bin/env bash
set -euo pipefail

QUTIP_REPO="${QUTIP_REPO:-${1:-}}"
EINSTEINPY_REPO="${EINSTEINPY_REPO:-${2:-}}"
WHEELHOUSE="${WHEELHOUSE:-third_party/wheels}"
PY="${PYTHON:-python}"

if [[ -z "${QUTIP_REPO}" || -z "${EINSTEINPY_REPO}" ]]; then
  echo "Usage:"
  echo "  make vendor_deps QUTIP_REPO=/path/to/qutip EINSTEINPY_REPO=/path/to/einsteinpy"
  echo "or:"
  echo "  bash scripts/third_party/build_vendor_deps.sh /path/to/qutip /path/to/einsteinpy"
  exit 2
fi

mkdir -p "${WHEELHOUSE}"

echo "== Python =="
"${PY}" -V
"${PY}" -m pip --version

echo "== Building wheels into ${WHEELHOUSE} =="

# Ensure wheel tooling
"${PY}" -m pip install -U pip wheel setuptools build

# Build QuTiP wheel
echo "-- QuTiP: ${QUTIP_REPO}"
"${PY}" -m pip wheel --no-deps -w "${WHEELHOUSE}" "${QUTIP_REPO}"

# Build EinsteinPy wheel
echo "-- EinsteinPy: ${EINSTEINPY_REPO}"
"${PY}" -m pip wheel --no-deps -w "${WHEELHOUSE}" "${EINSTEINPY_REPO}"

# Also try to prefetch common runtime deps (best-effort; may need internet if not already cached)
echo "== Best-effort: build wheels for common deps (if available locally) =="
"${PY}" -m pip wheel -w "${WHEELHOUSE}" numpy scipy sympy astropy matplotlib || true

cat > third_party/INSTALL_OFFLINE.md <<'EOF'
# Offline install instructions

This wheelhouse is platform-specific (OS/Python/ABI).
Install in a fresh venv using:

```bash
python -m pip install --no-index --find-links third_party/wheels -r requirements.txt
python -m pip install --no-index --find-links third_party/wheels qutip einsteinpy
```

Then run:

```bash
make end2end_sgi_suite_require_qutip
# or:
make end2end_sgi_suite_require_qutip_einsteinpy
```
EOF

echo "== Done =="
ls -1 "${WHEELHOUSE}" | sed 's/^/ - /'
