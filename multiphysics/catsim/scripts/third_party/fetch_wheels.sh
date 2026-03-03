#!/usr/bin/env bash
set -euo pipefail

# Fetch prebuilt wheels into third_party/wheels using pip download.
# This avoids building QuTiP from source whenever wheels are available.
#
# Usage:
#   make vendor_wheels
#   make vendor_wheels PYTHON=python3.11
#   make vendor_wheels PACKAGES="qutip einsteinpy"
#
# Optional env:
#   PYTHON=python3
#   WHEELHOUSE=third_party/wheels
#   PACKAGES="qutip einsteinpy"
#   EXTRA_PIP_ARGS="--only-binary=:all:"
#
# Note: Requires internet access unless your pip cache already contains wheels.

PYTHON="${PYTHON:-python3}"
WHEELHOUSE="${WHEELHOUSE:-third_party/wheels}"
PACKAGES="${PACKAGES:-qutip einsteinpy}"
EXTRA_PIP_ARGS="${EXTRA_PIP_ARGS:---only-binary=:all:}"

mkdir -p "${WHEELHOUSE}"

echo "== Python =="
"${PYTHON}" -V
"${PYTHON}" -m pip --version

echo "== Downloading wheels into ${WHEELHOUSE} =="
# --no-deps so we keep the wheelhouse small; you can add deps later if desired
"${PYTHON}" -m pip download ${EXTRA_PIP_ARGS} --no-deps -d "${WHEELHOUSE}" ${PACKAGES}

echo "== Done. Wheelhouse contains: =="
ls -1 "${WHEELHOUSE}" | sed 's/^/ - /'
