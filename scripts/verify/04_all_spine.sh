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

TMP="$(mktemp -t catept_${NAME}_XXXX).lean"
cat > "$TMP" <<'EOF'
import CATEPT.Showcase.QMGRUnification
#print axioms CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_electrovacuum_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.qm_gr_unified_via_entropic_proper_time
EOF

verify_run "$NAME" "lake env lean '$TMP'"

if grep -qE "unknown module prefix 'CATEPT'|unknown module prefix \"CATEPT\"|unknown identifier 'CATEPT.Showcase|module CATEPT\.Showcase\.QMGRUnification does not exist" "$LOG_DIR/$NAME.out"; then
  verify_skip "$NAME" "showcase not on current branch — switch to feat/publication or merge it in"
  exit 77
fi

# All four theorems must have a kernel-axiom-only line.
ok=0
for sym in qm_satisfies_catept_spine \
           gr_minkowski_satisfies_catept_spine \
           gr_electrovacuum_satisfies_catept_spine \
           qm_gr_unified_via_entropic_proper_time
do
  verify_match "$NAME" "'.*${sym}' depends on axioms: \[propext, Classical.choice, Quot.sound\]" 1 || ok=1
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more spine theorems missing kernel-axiom line"
  exit 1
fi
