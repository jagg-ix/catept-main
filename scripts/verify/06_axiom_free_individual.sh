#!/usr/bin/env bash
# 06_axiom_free_individual.sh — verify each of the 10 axiom-free
# compatibility theorems independently with its own grep.
#
# Mirrors README §6.2.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="06_axiom_free_individual"
verify_banner "$NAME" "Each of the 10 compatibility theorems is axiom-free"

# Per-theorem entries: <suffix-to-grep>  <expected-line-snippet>.
# expected-line-snippet must appear at least once in the build output.
declare -a SUFFIXES=(
  "quantumInfo_integration_contract"
  "bochnerMinlos_integration_contract"
  "gibbsMeasure_integration_contract"
  "hopfLean_integration_contract"
  "kolmogorovComplexity_integration_contract"
  "carleson_integration_contract"
  "concrete_witness_contract"
  "cslib_integration_contract"
  "thermodynamicsLean_integration_contract"
  "vml_landau_content_available"
)

# One build, many greps.
BUILDLOG="$LOG_DIR/${NAME}.build.out"
echo "+ lake build CATEPTMain.Domains.CoherenceShowcase  (one-off)"
lake build CATEPTMain.Domains.CoherenceShowcase >"$BUILDLOG" 2>&1
rc=$?
echo "  → exit=$rc  log=$BUILDLOG"

ok=0
PERLOG="$LOG_DIR/${NAME}.out"
: > "$PERLOG"
for s in "${SUFFIXES[@]}"; do
  line=$(grep -E "'.*\\.${s}' does not depend on any axioms" "$BUILDLOG" | head -1)
  if [ -n "$line" ]; then
    echo "  ✓ ${s}  : ${line}" | tee -a "$PERLOG"
  else
    echo "  ✗ ${s}  : NO axiom-free line found" | tee -a "$PERLOG"
    ok=1
  fi
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more contracts missing axiom-free line"
  exit 1
fi
