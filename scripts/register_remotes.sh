#!/usr/bin/env bash
# Register upstream remotes for all catept-main integration dependencies.
set -euo pipefail

add_remote() {
  local name="$1" url="$2"
  if git remote get-url "$name" &>/dev/null; then
    echo "  [$name] already exists, skipping"
  else
    git remote add "$name" "$url"
    echo "  [$name] added -> $url"
  fi
}

add_remote physlib              https://github.com/leanprover-community/physlib.git
add_remote bochner              https://github.com/mrdouglasny/bochner.git
add_remote hille-yosida         https://github.com/mrdouglasny/hille-yosida.git
add_remote pphi2                https://github.com/mrdouglasny/pphi2.git
add_remote thermodynamics       https://github.com/or4nge19/ThermodynamicsLean.git
add_remote carleson             https://github.com/or4nge19/carleson.git
add_remote gibbsmeasure         https://github.com/or4nge19/GibbsMeasure.git
add_remote brownian-motion      https://github.com/or4nge19/brownian-motion.git
add_remote kolmogorov-lean      https://github.com/AlexeyMilovanov/kolmogorov-complexity-lean.git
add_remote lean-quantuminfo     https://github.com/Timeroot/Lean-QuantumInfo.git
add_remote cslib                https://github.com/Timeroot/cslib.git
add_remote hopf-lean            https://github.com/al-ramsey/hopf-lean.git
add_remote lean-mwe             git@github.com:a-bekheet/lean-mwe.git

echo "Done. Current remotes:"
git remote -v
