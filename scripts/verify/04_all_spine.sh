#!/usr/bin/env bash
# 04_all_spine.sh — verify all four spine theorems at once
# (QM, GR Minkowski, GR full-electrovacuum, bundled headline).
#
# Mirrors README §3.3.3.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="04_all_spine"
verify_banner "$NAME" "All four spine theorems use only kernel axioms"

verify_run "$NAME" "lake build CATEPTMain.Showcase.QMGRUnification 2>&1 \
  | grep -E \"'CATEPT\\.Showcase\\.QMGRUnification\\.(qm_satisfies|gr_minkowski_satisfies|gr_electrovacuum_satisfies|qm_gr_unified)\""

ok=0
for sym in qm_satisfies_catept_spine \
           gr_minkowski_satisfies_catept_spine \
           gr_electrovacuum_satisfies_catept_spine \
           qm_gr_unified_via_entropic_proper_time
do
  verify_match "$NAME" "'CATEPT\\.Showcase\\.QMGRUnification\\.${sym}' depends on axioms: \\[propext," 1 || ok=1
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more spine theorems missing kernel-axiom line"
  exit 1
fi
