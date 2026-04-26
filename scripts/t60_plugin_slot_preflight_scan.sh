#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INTEGRATION_DIR="$ROOT_DIR/CATEPTMain/Integration"
CATEPTPORT_FILE="$ROOT_DIR/CATEPTMain/CATEPT/CATEPT/CATEPTPort.lean"
INTEGRATION_ARCH_FILE="$ROOT_DIR/CATEPTMain/Integration/TheoryPluginArchitecture.lean"
CORE_ARCH_FILE="$ROOT_DIR/CATEPTMain/CATEPT/CATEPT/TheoryPluginArchitecture.lean"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: rg is required" >&2
  exit 1
fi

if [[ ! -d "$INTEGRATION_DIR" ]]; then
  echo "error: expected directory not found: $INTEGRATION_DIR" >&2
  exit 1
fi

mapfile -t integration_files < <(find "$INTEGRATION_DIR" -maxdepth 1 -type f -name '*.lean' ! -name '*_WORKLOG.lean' | sort)

echo "# T60 Plugin-Slot Preflight Scan"
echo
echo "repo_root: $ROOT_DIR"
echo "integration_modules_scanned: ${#integration_files[@]}"
echo

echo "## Direct Importers: Integration.TheoryPluginArchitecture"
slot_tmp="$(mktemp)"
for f in "${integration_files[@]}"; do
  if rg -q '^import CATEPTMain\.Integration\.TheoryPluginArchitecture$' "$f"; then
    internal_count="$(rg '^import ' "$f" \
      | awk '{print $2}' \
      | rg -N '^(CATEPTMain|NavierStokes|NavierStokesClean)\.' \
      | wc -l \
      | tr -d ' ')"
    printf "%s|%s\n" "$internal_count" "${f#$ROOT_DIR/}" >> "$slot_tmp"
  fi
done

slot_count="$(wc -l < "$slot_tmp" | tr -d ' ')"
echo "count: $slot_count"
if [[ "$slot_count" -gt 0 ]]; then
  sort -t'|' -k1,1nr -k2,2 "$slot_tmp" \
    | while IFS='|' read -r n p; do
        printf -- "- %s (internal_fan_in=%s)\n" "$p" "$n"
      done
fi
echo

echo "## Direct Importers: CATEPTPort"
rg -l '^import CATEPTMain\.CATEPT\.CATEPT\.CATEPTPort$' "$ROOT_DIR/CATEPTMain" -g '*.lean' \
  | sed "s#$ROOT_DIR/##" \
  | sort \
  | sed 's/^/- /'
echo

echo "## Direct Importers: CATEPT.CATEPT.TheoryPluginArchitecture"
rg -l '^import CATEPTMain\.CATEPT\.CATEPT\.TheoryPluginArchitecture$' "$ROOT_DIR/CATEPTMain" -g '*.lean' \
  | sed "s#$ROOT_DIR/##" \
  | sort \
  | sed 's/^/- /'
echo

echo "## CATEPTPort Barrel Imports"
rg '^import ' "$CATEPTPORT_FILE" | sed 's/^/- /'
echo

echo "## File Sizes (LoC)"
wc -l "$CATEPTPORT_FILE" "$INTEGRATION_ARCH_FILE" "$CORE_ARCH_FILE" \
  | sed "s#$ROOT_DIR/##"

rm -f "$slot_tmp"
