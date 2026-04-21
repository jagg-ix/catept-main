#!/bin/bash
repos=(
"/Users/macbookpro/lab/tau/tau-information-dynamics/catept-main"
"/Users/macbookpro/lab/tau/tau-information-dynamics/tau-from-special-relativity"
"/Users/macbookpro/lab/tau/tau-information-dynamics/qcd-vortex-entanglement"
"/Users/macbookpro/lab/tau/tau-information-dynamics/DeGiorgi"
"/Users/macbookpro/lab/tau/tau-information-dynamics/Einstein-Tensor-Cycle-Cosmology"
"/Users/macbookpro/lab/tau/tau-information-dynamics/LeanDimensionalAnalysis"
"/Users/macbookpro/lab/tau/tau-information-dynamics/fuchsia"
"/Users/macbookpro/lab/tau/tau-information-dynamics/hopf-lean-4.26-port"
"/Users/macbookpro/lab/tau/tau-information-dynamics/lgt"
)
for r in "${repos[@]}"; do
  echo "Syncing $r..."
  if [ -d "$r" ]; then
    cd "$r"
    # Identify the correct slug for catept-main
    name=$(basename "$r")
    slug="$name"
    [ "$name" = "catept-main" ] && slug="navier-stokes-project-clean"
    
    # Git operations
    git add .
    git commit -m "Sync" || true
    
    # Check for jagg remote
    if ! git remote | grep -q "^jagg$"; then
      gh repo view "jagg-ix/$slug" >/dev/null 2>&1 || gh repo create "jagg-ix/$slug" --public --confirm
      git remote add jagg "https://github.com/jagg-ix/$slug.git" || git remote set-url jagg "https://github.com/jagg-ix/$slug.git"
    fi
    branch=$(git rev-parse --abbrev-ref HEAD)
    git push jagg "$branch"
  else
    echo "Directory $r not found."
  fi
done
