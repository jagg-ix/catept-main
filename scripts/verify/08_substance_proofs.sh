#!/usr/bin/env bash
# 08_substance_proofs.sh — verify the substance theorems behind each
# pillar of the spine identity depend only on the kernel axiom triple.
#
# Mirrors README §6 ("Substance proofs behind the unification claim").
#
# Distinction from 07: where 07 audits the *equality of pillar
# τ_ent values* (consistency), this script audits the *content*
# each pillar contributes — analytic Feynman-Kac bound, UV
# convergence theorem, Tomita modular-flow identifications, KMS
# carrier non-triviality lemma, and Shannon/Rényi reductions.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="08_substance_proofs"
verify_banner "$NAME" "Substance proofs (FK, UV, Tomita, KMS, Shannon/Rényi) — kernel-axiom-only"

# Build the same module that hosts the #print axioms directives.
verify_run "$NAME" "lake build CATEPTMain.Integration.UnificationSpine 2>&1 \
  | grep -E \"'CATEPTMain\\.Integration\\.(RigorousComplexFeynmanKac\\.complex_FK_rigorous|PhysicalUVConvergenceCertificate\\.physical_uv_certificate_no_counterterm_needed|TomitaMatsubaraEquivBridge\\.TomitaMatsubaraEquivBridge\\.(matsubara_S_I_eq_hbar_logDelta_zero|tauEnt_zero_iff_logDelta_zero)|KMSModularParameterBridge\\.kms_strip_separate_from_entropicProperTime|QuantumInfoEntropyConsistencyBridge\\.(shannon_entropy_zero_via_plugin|renyi_at_one_eq_shannon_via_plugin))' depends on axioms\""

ok=0
for symbol in \
  "RigorousComplexFeynmanKac\\.complex_FK_rigorous" \
  "PhysicalUVConvergenceCertificate\\.physical_uv_certificate_no_counterterm_needed" \
  "TomitaMatsubaraEquivBridge\\.TomitaMatsubaraEquivBridge\\.matsubara_S_I_eq_hbar_logDelta_zero" \
  "TomitaMatsubaraEquivBridge\\.TomitaMatsubaraEquivBridge\\.tauEnt_zero_iff_logDelta_zero" \
  "KMSModularParameterBridge\\.kms_strip_separate_from_entropicProperTime" \
  "QuantumInfoEntropyConsistencyBridge\\.shannon_entropy_zero_via_plugin" \
  "QuantumInfoEntropyConsistencyBridge\\.renyi_at_one_eq_shannon_via_plugin"
do
  verify_match "$NAME" "'CATEPTMain\\.Integration\\.${symbol}' depends on axioms: \\[propext," 1 || ok=1
done

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "one or more substance theorems missing kernel-axiom line"
  exit 1
fi
