#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEAN_REGISTRY_FILE="$REPO_ROOT/CATEPTMain/Integration/TheoryPluginPhyslibConstructBridge.lean"
PHYSLIB_ROOT="${1:-${PHYSLIB_ROOT:-/Users/macbookpro/lab/tau/tau-information-dynamics/physlib}}"

if ! command -v rg >/dev/null 2>&1; then
  echo "error: rg is required" >&2
  exit 1
fi

if [[ ! -f "$LEAN_REGISTRY_FILE" ]]; then
  echo "error: missing registry file: $LEAN_REGISTRY_FILE" >&2
  exit 1
fi

if [[ ! -d "$PHYSLIB_ROOT" ]]; then
  echo "error: missing physlib root: $PHYSLIB_ROOT" >&2
  exit 1
fi

extract_modules_from_def() {
  local def_name="$1"
  awk -v def_name="$def_name" '
    $0 ~ ("def " def_name) {in_list=1; next}
    in_list && /^[[:space:]]*\]/ {in_list=0}
    in_list {print}
  ' "$LEAN_REGISTRY_FILE" | rg -o '"[^"]+"' | tr -d '"'
}

count_tree_modules() {
  local rel="$1"
  if [[ -d "$PHYSLIB_ROOT/$rel" ]]; then
    find "$PHYSLIB_ROOT/$rel" -type f -name '*.lean' | wc -l | tr -d ' '
  else
    echo 0
  fi
}

mapfile -t modules < <(extract_modules_from_def "physlibRelevantSubmodules")
mapfile -t safe_modules < <(extract_modules_from_def "physlibSafeCoreSubmodules")

if [[ "${#modules[@]}" -eq 0 ]]; then
  echo "error: no modules extracted from registry" >&2
  exit 1
fi
if [[ "${#safe_modules[@]}" -eq 0 ]]; then
  echo "error: no modules extracted from safe-core registry" >&2
  exit 1
fi

echo "# Physlib Leverage Scan"
echo
echo "repo_root: $REPO_ROOT"
echo "physlib_root: $PHYSLIB_ROOT"
echo "registry_file: ${LEAN_REGISTRY_FILE#$REPO_ROOT/}"
echo "registry_modules: ${#modules[@]}"
echo "safe_core_modules: ${#safe_modules[@]}"
echo

echo "## Physlib Surface Counts"
printf '%-46s %6s\n' "surface" "count"
printf '%-46s %6s\n' "Physlib/QuantumMechanics" "$(count_tree_modules 'Physlib/QuantumMechanics')"
printf '%-46s %6s\n' "Physlib/Relativity" "$(count_tree_modules 'Physlib/Relativity')"
printf '%-46s %6s\n' "Physlib/StringTheory" "$(count_tree_modules 'Physlib/StringTheory')"
printf '%-46s %6s\n' "Physlib/Thermodynamics" "$(count_tree_modules 'Physlib/Thermodynamics')"
printf '%-46s %6s\n' "Physlib/StatisticalMechanics" "$(count_tree_modules 'Physlib/StatisticalMechanics')"
printf '%-46s %6s\n' "QuantumInfo" "$(count_tree_modules 'QuantumInfo')"
echo

missing=0
safe_missing=0
qm=0
rel=0
str=0
ent=0

echo "## Registry Resolution"
for m in "${modules[@]}"; do
  path="${m//./\/}.lean"
  full="$PHYSLIB_ROOT/$path"
  status="OK"
  if [[ ! -f "$full" ]]; then
    status="MISSING"
    missing=$((missing + 1))
  fi

  case "$m" in
    Physlib.QuantumMechanics.*|QuantumInfo.Finite.CPTPMap|QuantumInfo.Finite.Distance.TraceDistance)
      qm=$((qm + 1))
      ;;
  esac
  case "$m" in
    Physlib.Relativity.*)
      rel=$((rel + 1))
      ;;
  esac
  case "$m" in
    Physlib.StringTheory.*)
      str=$((str + 1))
      ;;
  esac
  case "$m" in
    Physlib.Thermodynamics.*|Physlib.StatisticalMechanics.*|QuantumInfo.Finite.Entropy.*|QuantumInfo.Finite.Distance.TraceDistance)
      ent=$((ent + 1))
      ;;
  esac

  printf -- '- [%s] %s -> %s\n' "$status" "$m" "$path"
done

echo
echo "## Safe-Core Resolution"
for m in "${safe_modules[@]}"; do
  path="${m//./\/}.lean"
  full="$PHYSLIB_ROOT/$path"
  status="OK"
  if [[ ! -f "$full" ]]; then
    status="MISSING"
    safe_missing=$((safe_missing + 1))
  fi
  printf -- '- [%s] %s -> %s\n' "$status" "$m" "$path"
done

echo
echo "## Domain Coverage (from registry)"
printf '%-46s %6d\n' "Quantum mechanics lane modules" "$qm"
printf '%-46s %6d\n' "Relativity lane modules" "$rel"
printf '%-46s %6d\n' "String-theory lane modules" "$str"
printf '%-46s %6d\n' "Entropy/thermo lane modules" "$ent"
echo

if [[ "$missing" -eq 0 && "$safe_missing" -eq 0 ]]; then
  echo "result: PASS (all registry + safe-core module paths resolve under physlib root)"
else
  echo "result: FAIL ($missing registry missing, $safe_missing safe-core missing)"
  exit 2
fi
