#!/usr/bin/env bash
# 05_axiom_free_all_10.sh — verify all 10 axiom-free compatibility
# theorems print "does not depend on any axioms" simultaneously.
#
# Mirrors README §6.1.

set -u
. "$(dirname "$0")/lib.sh"
verify_repo_root

NAME="05_axiom_free_all_10"
verify_banner "$NAME" "All 10 compatibility theorems are axiom-free"

# Build the showcase and grep its #print-axioms info: lines.
verify_run "$NAME" "lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 | grep -E \"\
'CATEPTPluginQuantumInfo\\.quantumInfo_integration_contract'|\
'CATEPTPluginBochnerMinlos\\.bochnerMinlos_integration_contract'|\
'CATEPTPluginGibbsMeasure\\.gibbsMeasure_integration_contract'|\
'CATEPTPluginHopfLean\\.hopfLean_integration_contract'|\
'CATEPTPluginKolmogorovComplexity\\.kolmogorovComplexity_integration_contract'|\
'CATEPTPluginCarleson\\.carleson_integration_contract'|\
'CATEPTPluginCarleson\\.concrete_witness_contract'|\
'CATEPTPluginCslib\\.cslib_integration_contract'|\
'CATEPTPluginThermodynamicsLean\\.thermodynamicsLean_integration_contract'|\
'CATEPTPluginVMLLandau\\.vml_landau_content_available'\""

# Expect exactly 10 lines, each ending with "does not depend on any axioms".
ok=0
verify_match "$NAME" "does not depend on any axioms" 10 || ok=1
verify_no_match "$NAME" "depends on axioms: \[" || ok=1

if [ $ok -eq 0 ]; then
  verify_pass "$NAME"; exit 0
else
  verify_fail "$NAME" "expected 10 axiom-free lines and zero kernel-axiom lines"
  exit 1
fi
