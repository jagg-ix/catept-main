#!/usr/bin/env bash
# 01_kernel_axiom_audit.sh — verify the two main consistency theorems
# depend only on the standard Lean kernel axioms.
#
# Mirrors README §4 ("The Testable Guarantee").
#
# Requires the showcase file CATEPT/Showcase/QMGRUnification.lean,
# which lives on the `feat/publication` branch of catept-main.  Check
# that branch out (or apply the equivalent file) before running.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="01_kernel_axiom_audit"
verify_banner "$NAME" "QM/GR consistency theorems use only kernel axioms"

TMP="$(mktemp -t catept_${NAME}_XXXX).lean"
cat > "$TMP" <<'EOF'
import CATEPT.Showcase.QMGRUnification
#print axioms CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
EOF

verify_run "$NAME" "lake env lean '$TMP'"

# Detect "showcase file not on this branch" and SKIP cleanly.
if grep -qE "unknown module prefix 'CATEPT'|unknown module prefix \"CATEPT\"|unknown identifier 'CATEPT.Showcase|module CATEPT\.Showcase\.QMGRUnification does not exist" "$LOG_DIR/$NAME.out"; then
  verify_skip "$NAME" "showcase not on current branch — switch to feat/publication or merge it in"
  exit 77
fi

ok=0
verify_match "$NAME" "'.*qm_satisfies_catept_spine' depends on axioms: \[propext, Classical.choice, Quot.sound\]" 1 || ok=1
verify_match "$NAME" "'.*gr_minkowski_satisfies_catept_spine' depends on axioms: \[propext, Classical.choice, Quot.sound\]" 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"
  exit 0
else
  verify_fail "$NAME" "expected axiom-list lines not found"
  exit 1
fi
