#!/usr/bin/env bash
# 07_unification_spine.sh — verify the capstone unification theorem
# `catept_unifies_QM_Thermo_EM_GR` and its six pillar-agreement
# witnesses depend only on the standard Lean kernel axioms.
#
# Mirrors the new README §5 ("The capstone: QM + Thermo + EM + GR
# share a single τ_ent").
#
# This is the framework's *single huge recipe* — one theorem
# stating that the same real scalar plays every pillar's
# τ_ent-equivalent role simultaneously.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="07_unification_spine"
verify_banner "$NAME" "Capstone: QM + Thermo + EM + GR share a single τ_ent (kernel-axiom-only)"

verify_run "$NAME" "lake build CATEPTMain.Integration.UnificationSpine 2>&1 \
  | grep -E \"'CATEPTMain\\.Integration\\.UnificationSpine\\.CATEPTUnificationBundle\\.(catept_unifies_QM_Thermo_EM_GR|unification_via_modular_flow|unification_QM_thermo_pillar|unification_QM_EM_pillar|unification_QM_GR_pillar|unification_QM_Matsubara)' depends on axioms\""

# Six theorems must each have a kernel-axiom-only line.
ok=0
for sym in catept_unifies_QM_Thermo_EM_GR \
           unification_via_modular_flow \
           unification_QM_thermo_pillar \
           unification_QM_EM_pillar \
           unification_QM_GR_pillar \
           unification_QM_Matsubara
do
  verify_match "$NAME" "'CATEPTMain\\.Integration\\.UnificationSpine\\.CATEPTUnificationBundle\\.${sym}' depends on axioms: \\[propext," 1 || ok=1
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more unification theorems missing kernel-axiom line"
  exit 1
fi
