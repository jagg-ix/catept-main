#!/usr/bin/env bash
# run_all.sh — driver that runs every numbered verification script
# and prints a final summary table.
#
# Each script writes its raw output to scripts/verify/logs/NN_*.out,
# so logs survive after the run for later inspection.

set -u
HERE="$(cd "$(dirname "$0")" && pwd)"

scripts=(
  "01_kernel_axiom_audit.sh"
  "02_gr_minkowski.sh"
  "03_gr_electrovacuum.sh"
  "04_all_spine.sh"
  "05_axiom_free_all_10.sh"
  "06_axiom_free_individual.sh"
)

declare -a results=()
declare -a names=()

for s in "${scripts[@]}"; do
  if [ ! -x "$HERE/$s" ]; then
    chmod +x "$HERE/$s" 2>/dev/null || true
  fi
  if [ -x "$HERE/$s" ]; then
    "$HERE/$s"
    results+=($?)
  else
    echo "SKIP: $s (not executable)"
    results+=(127)
  fi
  names+=("$s")
done

echo
echo "=============================================================="
echo " Summary"
echo "=============================================================="
pass=0; skip=0; fail=0
for i in "${!names[@]}"; do
  rc=${results[$i]}
  case "$rc" in
    0)  printf "  PASS  %s\n" "${names[$i]}";              pass=$((pass+1)) ;;
    77) printf "  SKIP  %s   (no showcase on this branch)\n" "${names[$i]}"; skip=$((skip+1)) ;;
    *)  printf "  FAIL  %s   (exit=%s)\n" "${names[$i]}" "$rc"; fail=$((fail+1)) ;;
  esac
done
echo "--------------------------------------------------------------"
printf "  total: %d   pass: %d   skip: %d   fail: %d\n" \
  "$((pass+skip+fail))" "$pass" "$skip" "$fail"
echo "  logs : $HERE/logs/"

if [ "$fail" -gt 0 ]; then exit 1; fi
exit 0
