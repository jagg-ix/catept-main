#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INTEGRATION_DIR="$ROOT_DIR/CATEPTMain/Integration"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: rg is required" >&2
  exit 1
fi

if [[ ! -d "$INTEGRATION_DIR" ]]; then
  echo "error: expected directory not found: $INTEGRATION_DIR" >&2
  exit 1
fi

mapfile -t importers < <(
  rg -l '^import CATEPTMain\.Integration\.TheoryPluginArchitecture$' "$INTEGRATION_DIR" -g '*.lean' \
    | sort
)

tmp="$(mktemp)"
for f in "${importers[@]}"; do
  internal_count="$(rg '^import ' "$f" \
    | awk '{print $2}' \
    | rg -N '^(CATEPTMain|NavierStokes|NavierStokesClean)\.' \
    | wc -l \
    | tr -d ' ')"

  has_adapter="no"
  if rg -q '^import CATEPTMain\.Integration\.TheoryPluginAdapter$' "$f"; then
    has_adapter="yes"
  fi

  has_cateptport="no"
  if rg -q '^import CATEPTMain\.CATEPT\.CATEPT\.CATEPTPort$' "$f"; then
    has_cateptport="yes"
  fi

  category="direct_arch_consumer"
  if [[ "$has_cateptport" == "yes" ]]; then
    category="anchor_direct_cateptport"
  elif [[ "$has_adapter" == "yes" ]]; then
    category="adapter_chain_consumer"
  fi

  printf "%s|%s|%s|%s|%s\n" \
    "$internal_count" "${f#$ROOT_DIR/}" "$has_adapter" "$has_cateptport" "$category" >> "$tmp"
done

echo "# T60 Plugin-Slot Importer Migration Map"
echo
echo "repo_root: $ROOT_DIR"
echo "importers: ${#importers[@]}"
echo
echo "| File | Internal fan-in | Imports TheoryPluginAdapter | Imports CATEPTPort | Category |"
echo "|---|---:|---|---|---|"
sort -t'|' -k1,1nr -k2,2 "$tmp" \
  | while IFS='|' read -r fanin file has_adapter has_cateptport category; do
      printf "| %s | %s | %s | %s | %s |\n" \
        "\`$file\`" "$fanin" "$has_adapter" "$has_cateptport" "$category"
    done

echo
echo "## Suggested import rewrite (direct-sibling mode)"
echo
for f in "${importers[@]}"; do
  rel="${f#$ROOT_DIR/}"
  echo "- $rel"
  echo "  - replace: import CATEPTMain.Integration.TheoryPluginArchitecture"
  echo "  - with:    import CATEPTPluginArchitecture.Integration.TheoryPluginArchitecture"
done

rm -f "$tmp"
