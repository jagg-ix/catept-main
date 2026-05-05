#!/usr/bin/env bash
# 10_em_substance.sh — verify the substance theorems on the GR /
# electrovacuum side that link informational dissipation S_I to
# the explicit Einstein–Maxwell action structure (not just slot
# rewrite).
#
# Mirrors README §6.6 ("Electrovacuum: explicit S_I structure
# beyond the slot rewrite").
#
# Four theorems audited:
#
#   bohmianEM_action_expansion  — S_I^{EM} = ‖v‖²/2 - ⟨v,A⟩ + ‖A‖²/2
#                                 (explicit closed form for the EM
#                                 imaginary action on a Bohmian-EM slot;
#                                 closed by `simp; ring`)
#
#   bohmianEM_nonneg            — 0 ≤ S_I^{EM}(v, A_bg)  for all v, A_bg
#                                 (proves the slot belongs to the damped
#                                 class — actionIm_nonneg)
#
#   vml_vacuum_em_action_zero   — at A=0, S_I^{EM} = 0
#                                 (VML steady-state decoupling theorem;
#                                 vacuum-sector boundary condition)
#
#   gravitasEMCATEPTSlot_consistent
#                               — full spine identity τ_ent = S_I/ℏ
#                                 holds on the EM-aware slot
#                                 (not just the Minkowski slot reused
#                                  for electrovacuum)

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="10_em_substance"
verify_banner "$NAME" "EM stress-energy substance: explicit S_I structure beyond the slot rewrite"

verify_run "$NAME" "lake build CATEPTMain.Integration.UnificationSpine 2>&1 \
  | grep -A2 -E \"'CATEPTMain\\.Integration\\.GravitasBridge\\.(bohmianEM_action_expansion|bohmianEM_nonneg|vml_vacuum_em_action_zero|gravitasEMCATEPTSlot_consistent)' depends on axioms\""

ok=0
for symbol in \
  "bohmianEM_action_expansion" \
  "bohmianEM_nonneg" \
  "vml_vacuum_em_action_zero" \
  "gravitasEMCATEPTSlot_consistent"
do
  verify_match "$NAME" "'CATEPTMain\\.Integration\\.GravitasBridge\\.${symbol}' depends on axioms: \\[propext," 1 || ok=1
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more EM substance theorems missing kernel-axiom line"
  exit 1
fi
