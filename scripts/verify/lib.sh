#!/usr/bin/env bash
# scripts/verify/lib.sh — shared helpers for verification scripts.
#
# Provides:
#   verify_repo_root  : cd into repo root (parent of scripts/) and exit if
#                       lakefile.lean isn't present.
#   verify_run NAME CMD : run CMD, save raw output to logs/NAME.out, return 0
#                       on completion.
#   verify_match NAME REGEX [COUNT] : assert logs/NAME.out has at least COUNT
#                       (default 1) lines matching REGEX.
#   verify_no_match NAME REGEX : assert logs/NAME.out has zero lines matching
#                       REGEX.
#   verify_pass NAME / verify_fail NAME REASON : record result and print.
#
# Each script uses these to print a consistent banner / outcome line.

set -u

VERIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$VERIFY_DIR/../.." && pwd)"
LOG_DIR="$VERIFY_DIR/logs"
EXPECTED_DIR="$VERIFY_DIR/expected"

mkdir -p "$LOG_DIR"

verify_repo_root() {
  if [ ! -f "$REPO_ROOT/lakefile.lean" ]; then
    echo "ERROR: cannot find lakefile.lean at $REPO_ROOT" >&2
    exit 2
  fi
  cd "$REPO_ROOT"
}

verify_banner() {
  local name="$1"
  local desc="$2"
  echo
  echo "──────────────────────────────────────────────────────────────"
  echo " $name : $desc"
  echo "──────────────────────────────────────────────────────────────"
}

verify_run() {
  local name="$1"; shift
  local logfile="$LOG_DIR/$name.out"
  echo "+ $*"
  bash -c "$*" >"$logfile" 2>&1
  local rc=$?
  echo "  → exit=$rc  log=$logfile  ($(wc -l < "$logfile" | tr -d ' ') lines)"
  return $rc
}

verify_match() {
  local name="$1"; local regex="$2"; local want="${3:-1}"
  local logfile="$LOG_DIR/$name.out"
  local got
  got=$(grep -cE "$regex" "$logfile" 2>/dev/null)
  [ -z "$got" ] && got=0
  if [ "$got" -ge "$want" ]; then
    echo "  ✓ matched $got line(s) /$want for: $regex"
    return 0
  else
    echo "  ✗ matched $got line(s) /$want for: $regex"
    return 1
  fi
}

verify_no_match() {
  local name="$1"; local regex="$2"
  local logfile="$LOG_DIR/$name.out"
  local got
  got=$(grep -cE "$regex" "$logfile" 2>/dev/null)
  [ -z "$got" ] && got=0
  if [ "$got" -eq 0 ]; then
    echo "  ✓ no lines match (good): $regex"
    return 0
  else
    echo "  ✗ $got line(s) match (bad): $regex"
    return 1
  fi
}

verify_skip() {
  echo "  SKIP: $1${2:+ — $2}"
}

verify_pass() {
  echo "  PASS: $1"
}

verify_fail() {
  echo "  FAIL: $1${2:+ — $2}"
}
