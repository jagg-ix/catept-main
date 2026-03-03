#!/usr/bin/env bash
set -euo pipefail

PYTHON="${PYTHON:-python3}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

INFO="$("${PYTHON}" "${ROOT}/scripts/third_party/detect_platform.py")"
PLAT="$(echo "$INFO" | "${PYTHON}" -c "import sys,json; print(json.load(sys.stdin)['platform'])")"
TAG="$(echo "$INFO" | "${PYTHON}" -c "import sys,json; print(json.load(sys.stdin)['python_tag'])")"

WHEELDIR="${ROOT}/third_party/wheelhouse/${PLAT}/${TAG}"
mkdir -p "${WHEELDIR}"

PACKAGES="${PACKAGES:-qutip einsteinpy}"
EXTRA_PIP_ARGS="${EXTRA_PIP_ARGS:---only-binary=:all: --no-deps}"

echo "Vendoring wheels for ${PLAT}/${TAG} into ${WHEELDIR}"
"${PYTHON}" -V
"${PYTHON}" -m pip --version

"${PYTHON}" -m pip download ${EXTRA_PIP_ARGS} -d "${WHEELDIR}" ${PACKAGES}

echo "Done. Wheels:"
ls -1 "${WHEELDIR}" | sed 's/^/ - /'
