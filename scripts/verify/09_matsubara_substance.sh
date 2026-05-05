#!/usr/bin/env bash
# 09_matsubara_substance.sh — verify the Matsubara closed-form
# algebra and the four-way equivalence at modular-flow origin.
#
# Mirrors README §6.4 / §6.5 ("The Matsubara closed-form algebra"
# and "Four-way equivalence at modular-flow origin").
#
# Seven theorems audited:
#
#   §6.4 Closed-form Matsubara algebra (textbook identities):
#     τ_ent = β · Ω                            (Matsubara/Luttinger–Ward)
#     S_I   = ℏ · τ_ent                        (definitional spine)
#     τ_ent = -log Z                           (partition-function form)
#     S_I   = -ℏ · log Z                       (combined identity)
#
#   §6.5 Four-way equivalence at modular-flow origin:
#     τ_ent_M = τ_ent_KMS = τ_ent_chan = log Δ(0)
#                                              (4-way at 0, the strongest single statement)
#     S_I = ℏ · log Δ(0) = ℏ · τ_ent_chan(0)   (composite operator+channel identity)
#     τ_ent_M = 1 / γ_I(0)                     (KMS-strip explicit form)

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="09_matsubara_substance"
verify_banner "$NAME" "Matsubara closed-form algebra + 4-way equivalence at modular-flow origin"

verify_run "$NAME" "lake build CATEPTMain.Integration.UnificationSpine 2>&1 \
  | grep -A2 -E \"'CATEPTMain\\.Integration\\.(MatsubaraLuttingerWardCarrier\\.MatsubaraLuttingerWardCarrier\\.(tauEnt_eq_beta_Omega|S_I_eq_hbar_tauEnt|tauEnt_eq_neg_log_Z|S_I_eq_hbar_neg_log_Z)|TomitaMatsubaraAQFTSpineBridge\\.TomitaMatsubaraAQFTSpineBridge\\.(four_way_equivalence_at_zero|S_I_eq_hbar_logDelta_eq_hbar_channel|matsubara_tauEnt_eq_one_over_gammaI))' depends on axioms\""

ok=0
for symbol in \
  "MatsubaraLuttingerWardCarrier\\.MatsubaraLuttingerWardCarrier\\.tauEnt_eq_beta_Omega" \
  "MatsubaraLuttingerWardCarrier\\.MatsubaraLuttingerWardCarrier\\.S_I_eq_hbar_tauEnt" \
  "MatsubaraLuttingerWardCarrier\\.MatsubaraLuttingerWardCarrier\\.tauEnt_eq_neg_log_Z" \
  "MatsubaraLuttingerWardCarrier\\.MatsubaraLuttingerWardCarrier\\.S_I_eq_hbar_neg_log_Z" \
  "TomitaMatsubaraAQFTSpineBridge\\.TomitaMatsubaraAQFTSpineBridge\\.four_way_equivalence_at_zero" \
  "TomitaMatsubaraAQFTSpineBridge\\.TomitaMatsubaraAQFTSpineBridge\\.S_I_eq_hbar_logDelta_eq_hbar_channel" \
  "TomitaMatsubaraAQFTSpineBridge\\.TomitaMatsubaraAQFTSpineBridge\\.matsubara_tauEnt_eq_one_over_gammaI"
do
  verify_match "$NAME" "'CATEPTMain\\.Integration\\.${symbol}' depends on axioms: \\[propext," 1 || ok=1
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more Matsubara substance theorems missing kernel-axiom line"
  exit 1
fi
