#!/usr/bin/env bash
set -euo pipefail

BASE="/Users/macbookpro/lab/tau/tau-information-dynamics"
OUT="$BASE/catept-main/integration/repo_matrix.json"

repos=(
  "bochner"
  "hille-yosida"
  "pphi2"
  "ThermodynamicsLean-inspect"
  "carleson-inspect"
  "gibbsmeasure-inspect"
  "brownian-motion-inspect"
  "kolmogorov-complexity-lean-inspect"
  "lean-quantuminfo-inspect"
  "cslib-inspect"
  "hopf-lean-4.26-port"
  "Formal-Verification-of-the-Vlasov-Maxwell-Landau-Steady-State-Theorem"
)

printf "[\n" > "$OUT"
first=1
for name in "${repos[@]}"; do
  repo="$BASE/$name"
  [[ -d "$repo" ]] || continue

  toolchain=""
  if [[ -f "$repo/lean-toolchain" ]]; then
    toolchain="$(tr -d '\n' < "$repo/lean-toolchain")"
  fi

  commit=""
  if [[ -d "$repo/.git" ]]; then
    commit="$(git -C "$repo" rev-parse --short=12 HEAD 2>/dev/null || true)"
  fi

  if [[ $first -eq 0 ]]; then
    printf ",\n" >> "$OUT"
  fi
  first=0

  printf "  {\"name\":\"%s\",\"path\":\"%s\",\"toolchain\":\"%s\",\"commit\":\"%s\"}" \
    "$name" "$repo" "$toolchain" "$commit" >> "$OUT"
done
printf "\n]\n" >> "$OUT"

echo "Wrote $OUT"
