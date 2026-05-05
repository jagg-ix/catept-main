#!/usr/bin/env bash
# 01_kernel_axiom_audit.sh — verify the two main consistency theorems
# depend only on the standard Lean kernel axioms.
#
# Mirrors README §4 ("The Testable Guarantee").
#
# Implementation: runs the kernel-axiom audit on the self-contained
# demo file at scripts/verify/lean/SpineDemo.lean.  The demo proves
# the same four spine theorems as the canonical
# CATEPT.Showcase.QMGRUnification on the feat/publication branch,
# and exhibits the same kernel-axiom-only signature
# `[propext, Classical.choice, Quot.sound]`.  See
# scripts/verify/README.md for the relation to the canonical
# recipe.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="01_kernel_axiom_audit"
verify_banner "$NAME" "QM/GR consistency theorems use only kernel axioms"

DEMO="scripts/verify/lean/SpineDemo.lean"
TMP="$(mktemp -t catept_${NAME}_XXXX).lean"
cat "$DEMO" > "$TMP"
cat >> "$TMP" <<'EOF'
#print axioms CATEPT.Showcase.QMGRUnificationDemo.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnificationDemo.gr_minkowski_satisfies_catept_spine
EOF

verify_run "$NAME" "lake env lean '$TMP'"

ok=0
verify_match "$NAME" "'.*qm_satisfies_catept_spine' depends on axioms: \[propext," 1 || ok=1
verify_match "$NAME" "'.*gr_minkowski_satisfies_catept_spine' depends on axioms: \[propext," 1 || ok=1
verify_match "$NAME" "Classical\\.choice" 1 || ok=1
verify_match "$NAME" "Quot\\.sound" 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"
  exit 0
else
  verify_fail "$NAME" "expected kernel-axiom triple not found"
  exit 1
fi
