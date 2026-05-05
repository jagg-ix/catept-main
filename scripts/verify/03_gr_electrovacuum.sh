#!/usr/bin/env bash
# 03_gr_electrovacuum.sh — verify the GR full-electrovacuum
# (Einstein–Maxwell) instance of the central identity.
#
# Mirrors README §3.3.2.
#
# Implementation: runs against the self-contained demo file at
# scripts/verify/lean/SpineDemo.lean (see scripts/verify/README.md).

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="03_gr_electrovacuum"
verify_banner "$NAME" "GR full electrovacuum: τ_ent identity holds, kernel-axiom-only"

DEMO="scripts/verify/lean/SpineDemo.lean"
TMP="$(mktemp -t catept_${NAME}_XXXX).lean"
cat "$DEMO" > "$TMP"
cat >> "$TMP" <<'EOF'
#check @CATEPT.Showcase.QMGRUnificationDemo.gr_electrovacuum_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnificationDemo.gr_electrovacuum_satisfies_catept_spine
EOF

verify_run "$NAME" "lake env lean '$TMP'"

ok=0
verify_match "$NAME" "spineConstraint" 1 || ok=1
verify_match "$NAME" "trivialSlot 2" 1 || ok=1
verify_match "$NAME" "'.*gr_electrovacuum_satisfies_catept_spine' depends on axioms:" 1 || ok=1
verify_match "$NAME" "propext" 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "expected #check + axiom lines not found"
  exit 1
fi
