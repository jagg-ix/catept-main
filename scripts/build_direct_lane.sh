#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/macbookpro/lab/tau/tau-information-dynamics/catept-main"

pushd "$ROOT" >/dev/null

# Build direct 4.29 lane integration root.
lake build CATEPTMain

popd >/dev/null

echo "Direct 4.29 lane build completed."
