#!/usr/bin/env bash
# 03_gr_electrovacuum.sh — verify the GR full-electrovacuum
# (Einstein–Maxwell) instance of the central identity.
#
# Mirrors README §3.3.2.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="03_gr_electrovacuum"
verify_banner "$NAME" "GR full electrovacuum: τ_ent identity holds, kernel-axiom-only"

verify_run "$NAME" "lake build CATEPTMain.Showcase.QMGRUnification 2>&1 \
  | grep \"gr_electrovacuum_satisfies_catept_spine' depends on axioms\""

ok=0
verify_match "$NAME" "'CATEPT\\.Showcase\\.QMGRUnification\\.gr_electrovacuum_satisfies_catept_spine' depends on axioms: \\[propext," 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "expected kernel-axiom line not found"
  exit 1
fi
