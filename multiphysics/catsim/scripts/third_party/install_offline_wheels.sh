#!/usr/bin/env bash
set -euo pipefail

REQUIREMENTS="${REQUIREMENTS:-0}"
PYTHON="${PYTHON:-python3}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

INFO="$("${PYTHON}" "${ROOT}/scripts/third_party/detect_platform.py")"
PLAT="$(echo "$INFO" | "${PYTHON}" -c "import sys,json; print(json.load(sys.stdin)['platform'])")"
TAG="$(echo "$INFO" | "${PYTHON}" -c "import sys,json; print(json.load(sys.stdin)['python_tag'])")"

WHEELDIR="${ROOT}/third_party/wheelhouse/${PLAT}/${TAG}"
echo "Detected platform=${PLAT} python_tag=${TAG}"
echo "Wheel directory: ${WHEELDIR}"

if [[ ! -d "${WHEELDIR}" ]]; then
  echo "ERROR: wheel directory not found: ${WHEELDIR}"
  exit 2
fi

COUNT=$(ls -1 "${WHEELDIR}"/*.whl 2>/dev/null | wc -l | tr -d ' ')
if [[ "${COUNT}" == "0" ]]; then
  echo "ERROR: no wheels found in ${WHEELDIR}"
  echo "Populate wheels on this platform using: make vendor_wheels_here"
  exit 2
fi

if [[ "${REQUIREMENTS}" == "1" ]]; then
  "${PYTHON}" -m pip install --no-index --find-links "${WHEELDIR}" -r "${ROOT}/requirements.txt"
fi

"${PYTHON}" -m pip install --no-index --find-links "${WHEELDIR}" qutip einsteinpy

echo "OK: installed from offline wheelhouse."
