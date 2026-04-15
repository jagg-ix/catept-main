#!/usr/bin/env bash
set -euo pipefail

BASE="/Users/macbookpro/lab/tau/tau-information-dynamics"

check_repo() {
  local name="$1"
  local expected_toolchain="$2"
  local mode="$3"
  local path="$BASE/$name"

  if [[ ! -d "$path" ]]; then
    echo "MISSING  $name ($mode)"
    return
  fi

  local actual_toolchain="(none)"
  if [[ -f "$path/lean-toolchain" ]]; then
    actual_toolchain="$(tr -d '\n' < "$path/lean-toolchain")"
  fi

  local sha="(no-git)"
  if [[ -d "$path/.git" ]]; then
    sha="$(git -C "$path" rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
  fi

  echo "OK       $name"
  echo "  mode:       $mode"
  echo "  toolchain:  $actual_toolchain"
  echo "  expected:   $expected_toolchain"
  echo "  commit:     $sha"
}

check_repo "bochner" "leanprover/lean4:v4.29.0" "direct_4_29"
check_repo "hille-yosida" "leanprover/lean4:v4.29.0" "direct_4_29"
check_repo "pphi2" "leanprover/lean4:v4.29.0" "direct_4_29"
check_repo "cslib-inspect" "leanprover/lean4:v4.29.0" "direct_4_29"
check_repo "lean-quantuminfo-inspect" "leanprover/lean4:v4.28.0" "bridge_upgrade_required"
check_repo "brownian-motion-inspect" "leanprover/lean4:v4.28.0-rc1" "bridge_upgrade_required"
check_repo "kolmogorov-complexity-lean-inspect" "leanprover/lean4:v4.29.0-rc8" "bridge_upgrade_required"
check_repo "ThermodynamicsLean-inspect" "leanprover/lean4:v4.24.0-rc1" "legacy_port_required"
check_repo "carleson-inspect" "leanprover/lean4:v4.15.0" "legacy_port_required"
check_repo "gibbsmeasure-inspect" "leanprover/lean4:v4.22.0" "legacy_port_required"
check_repo "hopf-lean-4.26-port" "leanprover/lean4:v4.26.0" "legacy_port_required"
check_repo "Formal-Verification-of-the-Vlasov-Maxwell-Landau-Steady-State-Theorem" "leanprover/lean4:v4.24.0" "legacy_port_required"

echo
echo "Governance checks"

# Phase-1 policy: VML can be consumed only through
# CATEPTMain.Integration.VMLSteadyStateBridge. Direct imports of external VML
# modules into CATEPTMain/Integration are forbidden until Lean 4.29 port.
REPO_ROOT="/Users/macbookpro/lab/tau/tau-information-dynamics/catept-main"
INTEGRATION_ROOT="$REPO_ROOT/CATEPTMain/Integration"

if [[ -d "$INTEGRATION_ROOT" ]]; then
  # Collect suspect imports containing VML theorem-chain identifiers while
  # excluding local CATEPTMain imports.
  VML_DIRECT_IMPORTS="$(grep -R -n -E '^import ' "$INTEGRATION_ROOT"/*.lean 2>/dev/null \
    | grep -E 'Aristotle|Landau|Vlasov|SteadyState|FormalVerification|VlasovMaxwell' \
    | grep -v 'import CATEPTMain\.' || true)"

  if [[ -n "$VML_DIRECT_IMPORTS" ]]; then
    echo "FAIL     direct VML imports detected in phase-1 integration modules"
    echo "$VML_DIRECT_IMPORTS"
    exit 1
  fi

  echo "OK       phase-1 VML import guard"
fi
