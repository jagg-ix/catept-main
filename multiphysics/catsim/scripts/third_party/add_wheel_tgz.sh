#!/usr/bin/env bash
set -euo pipefail

TGZ="${TGZ:-${1:-}}"
PLATFORM="${PLATFORM:-}"
PYTAG="${PYTAG:-}"

if [[ -z "${TGZ}" || -z "${PLATFORM}" || -z "${PYTAG}" ]]; then
  echo "Usage:"
  echo "  make add_wheel_tgz TGZ=/path/to/wheels.tgz PLATFORM=macos_x86_64 PYTAG=cp310"
  exit 2
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEST="${ROOT}/third_party/wheelhouse/${PLATFORM}/${PYTAG}"
mkdir -p "${DEST}"

echo "Extracting ${TGZ} -> ${DEST}"
tar -xf "${TGZ}" -C "${DEST}"

echo "Wheel count now:"
ls -1 "${DEST}"/*.whl 2>/dev/null | wc -l | tr -d ' '
