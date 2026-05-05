#!/usr/bin/env bash
# 02_gr_minkowski.sh — verify the GR Minkowski instance of the
# central identity, both at the type level (#check) and at the
# axiom level (#print axioms).
#
# Mirrors README §3.3.1.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="02_gr_minkowski"
verify_banner "$NAME" "GR Minkowski: τ_ent = S_I/ℏ holds, kernel-axiom-only"

TMP="$(mktemp -t catept_${NAME}_XXXX).lean"
cat > "$TMP" <<'EOF'
import CATEPT.Showcase.QMGRUnification
#check @CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
EOF

verify_run "$NAME" "lake env lean '$TMP'"

if grep -qE "unknown module prefix 'CATEPT'|unknown module prefix \"CATEPT\"|unknown identifier 'CATEPT.Showcase|module CATEPT\.Showcase\.QMGRUnification does not exist" "$LOG_DIR/$NAME.out"; then
  verify_skip "$NAME" "showcase not on current branch — switch to feat/publication or merge it in"
  exit 77
fi

ok=0
verify_match "$NAME" "cateptConsistencyConstraint gravitasMinkowskiSlot" 1 || ok=1
verify_match "$NAME" "'.*gr_minkowski_satisfies_catept_spine' depends on axioms: \[propext, Classical.choice, Quot.sound\]" 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "expected #check + axiom lines not found"
  exit 1
fi
