#!/usr/bin/env bash
set -euo pipefail
OUTROOT="${1:-PAPER_TABLES/ADVANCED/DIAG/END2END_SGI_SUITE/demo_001}"
mkdir -p "$OUTROOT/logs"

export PYTHONPATH="src"

run_one () {
  local tag="$1"
  shift
  local out="$OUTROOT/$tag"
  mkdir -p "$out/logs"
  echo "## RUN $tag -> $out"
  python -m scripts.ui_modules.sgi_scan --out "$out" "$@" 2>&1 | tee "$out/logs/sgi_scan.log"
}

{
  echo "## ENV"
  python -V
  echo "PYTHONPATH=$PYTHONPATH"
  echo

echo "## DEP CHECK"
REQ=()
if [[ "${REQUIRE_QUTIP:-0}" == "1" ]]; then REQ+=(qutip); fi
if [[ "${REQUIRE_EINSTEINPY:-0}" == "1" ]]; then REQ+=(einsteinpy); fi
if [[ "${#REQ[@]}" -gt 0 ]]; then
  python scripts/diag/check_deps.py --require "${REQ[@]}" --json-out "$OUTROOT/deps_check.json"
else
  python scripts/diag/check_deps.py --json-out "$OUTROOT/deps_check.json" || true
fi
echo
  echo "## VERIFY DB"
  python scripts/diag/verify_sgi_db.py --sources-dir data/sgi/sources --out "$OUTROOT/sgidb_verify.json"
  echo

  echo "## DENSITY FIELD UNIT TEST"
  python scripts/diag/test_density_field.py
  echo

  # Common knobs for scene + metric + quantum readout
  COMMON=(--sgidb data/sgi/sgidb.sqlite --backend extended --dt 5e-6
    --template split_mirror_recombine --auto-close
    --shape tanh --ramp-frac 0.15
    --lambda-preset demo_med
    --metric-mode kerr --metric-mass-kg 1e12 --metric-a-star 0.7 --metric-theta-deg 90 --observer-mode zamo
    --scene-width-m 0.02 --scene-height-m 0.02
    --matter-energy-density 1e10 --matter-radius-m 0.003 --matter-placement top_right
    --bh-mass-kg 1e12 --bh-radius-m 0.002 --bh-a-star 0.7 --bh-placement bottom_left
    --quantum-backend qutip --channel-preset demo_med --quantum-mode timegrid
    --gamma-phi 1.0
    --bath-model dephasing_relax_excite --bath-density-scale 1.0
    --bath-dephasing-frac 1.0 --bath-relax-frac 0.2 --bath-excite-frac 0.05
    --bath-density-field scene --bath-rho-ref 1.0 --bath-density-background 1.0
  )

  echo "## SGI SUITE"
  run_one fig6a_dz --scan fig6a_dz "${COMMON[@]}"
  run_one fig6b_dv --scan fig6b_dv "${COMMON[@]}"
  run_one fig8_Td1  --scan fig8_Td1  "${COMMON[@]}"

} 2>&1 | tee "$OUTROOT/logs/run_all.log"
