#!/usr/bin/env bash
# 04_all_spine.sh — verify all four spine theorems at once
# (QM, GR Minkowski, GR full-electrovacuum, bundled headline).
#
# Mirrors README §3.3.3.
#
# Implementation: runs against the self-contained demo file at
# scripts/verify/lean/SpineDemo.lean (see scripts/verify/README.md).

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="04_all_spine"
verify_banner "$NAME" "All four spine theorems use only kernel axioms"

DEMO="scripts/verify/lean/SpineDemo.lean"
TMP="$(mktemp -t catept_${NAME}_XXXX).lean"
cat "$DEMO" > "$TMP"
cat >> "$TMP" <<'EOF'
#print axioms CATEPT.Showcase.QMGRUnificationDemo.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnificationDemo.gr_minkowski_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnificationDemo.gr_electrovacuum_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnificationDemo.qm_gr_unified_via_entropic_proper_time
EOF

verify_run "$NAME" "lake env lean '$TMP'"

# All four theorems must have a kernel-axiom-only line.
ok=0
for sym in qm_satisfies_catept_spine \
           gr_minkowski_satisfies_catept_spine \
           gr_electrovacuum_satisfies_catept_spine \
           qm_gr_unified_via_entropic_proper_time
do
  verify_match "$NAME" "'.*${sym}' depends on axioms:" 1 || ok=1
done
verify_match "$NAME" "propext" 1 || ok=1
verify_match "$NAME" "Classical\\.choice" 1 || ok=1
verify_match "$NAME" "Quot\\.sound" 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more spine theorems missing kernel-axiom line"
  exit 1
fi
