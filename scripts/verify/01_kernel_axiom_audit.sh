#!/usr/bin/env bash
# 01_kernel_axiom_audit.sh — verify the two main consistency theorems
# depend only on the standard Lean kernel axioms.
#
# Mirrors README §4 ("The Testable Guarantee").
#
# Implementation: greps the `lake build CATEPTMain.Showcase.QMGRUnification`
# output for the canonical `#print axioms` info: lines emitted by the
# directives at the end of `CATEPTMain/Showcase/QMGRUnification.lean`
# (which mirror the showcase on the feat/publication branch under the
# canonical `CATEPT.Showcase.QMGRUnification.*` symbol namespace).

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="01_kernel_axiom_audit"
verify_banner "$NAME" "QM/GR consistency theorems use only kernel axioms"

verify_run "$NAME" "lake build CATEPTMain.Showcase.QMGRUnification 2>&1 \
  | grep -E \"'CATEPT\\.Showcase\\.QMGRUnification\\.(qm|gr_minkowski)_satisfies_catept_spine' depends on axioms\""

ok=0
verify_match "$NAME" "'CATEPT\\.Showcase\\.QMGRUnification\\.qm_satisfies_catept_spine' depends on axioms: \\[propext," 1 || ok=1
verify_match "$NAME" "'CATEPT\\.Showcase\\.QMGRUnification\\.gr_minkowski_satisfies_catept_spine' depends on axioms: \\[propext," 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "expected kernel-axiom triple lines not found"
  exit 1
fi
