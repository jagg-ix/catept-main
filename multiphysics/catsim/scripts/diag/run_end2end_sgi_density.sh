#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-PAPER_TABLES/ADVANCED/DIAG/END2END_SGI_DENSITY/demo_001}"
mkdir -p "$OUT/logs"

export PYTHONPATH="src"
{
  echo "## ENV"
  python -V
  echo "PYTHONPATH=$PYTHONPATH"
  echo
  echo "## RUN: density-field unit diagnostic"
  python scripts/diag/test_density_field.py
  echo
  echo "## RUN: SGI scan (fig6a_dz) extended+qutip multi-bath, placement-aware density-field"
  python -m scripts.ui_modules.sgi_scan     --out "$OUT"     --sgidb data/sgi/sgidb.sqlite     --scan fig6a_dz --backend extended     --dt 1e-6     --template split_mirror_recombine --auto-close     --shape tanh --ramp-frac 0.15     --lambda-preset demo_med     --metric-mode kerr --metric-mass-kg 1e12 --metric-a-star 0.7 --metric-theta-deg 90 --observer-mode zamo     --scene-width-m 0.02 --scene-height-m 0.02     --matter-energy-density 1e10 --matter-radius-m 0.003 --matter-placement top_right     --bh-mass-kg 1e12 --bh-radius-m 0.002 --bh-a-star 0.7 --bh-placement bottom_left     --quantum-backend qutip --channel-preset demo_med     --gamma-phi 1.0     --bath-model dephasing_relax_excite --bath-density-scale 1.0     --bath-dephasing-frac 1.0 --bath-relax-frac 0.2 --bath-excite-frac 0.05     --bath-density-field scene --bath-rho-ref 1.0 --bath-density-background 1.0     2>&1 | tee "$OUT/logs/sgi_scan_stdout_stderr.log"
} 2>&1 | tee "$OUT/logs/run_all.log"
