#!/usr/bin/env bash
# 02_gr_minkowski.sh — verify the GR Minkowski instance of the
# central identity at the axiom level (#print axioms).
#
# Mirrors README §3.3.1.
#
# Implementation: greps the `lake build` info: line emitted by the
# `#print axioms` directive at the bottom of
# `CATEPTMain/Showcase/QMGRUnification.lean`.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="02_gr_minkowski"
verify_banner "$NAME" "GR Minkowski: τ_ent = S_I/ℏ holds, kernel-axiom-only"

verify_run "$NAME" "lake build CATEPTMain.Showcase.QMGRUnification 2>&1 \
  | grep \"gr_minkowski_satisfies_catept_spine' depends on axioms\""

ok=0
verify_match "$NAME" "'CATEPT\\.Showcase\\.QMGRUnification\\.gr_minkowski_satisfies_catept_spine' depends on axioms: \\[propext," 1 || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "expected kernel-axiom line not found"
  exit 1
fi
