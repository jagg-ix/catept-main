#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCH_DIR="$ROOT_DIR/third_party/lake-patches"
MANIFEST_FILE="$ROOT_DIR/lake-manifest.json"

if [[ ! -f "$MANIFEST_FILE" ]]; then
  echo "error: missing manifest file: $MANIFEST_FILE"
  echo "run 'lake update' first"
  exit 1
fi

if [[ ! -d "$PATCH_DIR" ]]; then
  echo "no patch directory found: $PATCH_DIR"
  exit 0
fi

MODE="apply"
if [[ "${1:-}" == "--check" ]]; then
  MODE="check"
  shift
fi

resolve_source_dir() {
  local pkg="$1"
  PKG_NAME="$pkg" perl -0777 -ne '
    my $pkg = $ENV{"PKG_NAME"};
    if (/"type":\s*"path".*?"name":\s*"\Q$pkg\E".*?"dir":\s*"([^"]+)"/s) {
      print "$1\n";
      exit 0;
    }
    if (/"name":\s*"\Q$pkg\E".*?"type":\s*"path".*?"dir":\s*"([^"]+)"/s) {
      print "$1\n";
      exit 0;
    }
  ' "$MANIFEST_FILE"
}

shopt -s nullglob
patches=()
if [[ $# -gt 0 ]]; then
  for pkg in "$@"; do
    patches+=("$PATCH_DIR/$pkg.patch")
  done
else
  patches=("$PATCH_DIR"/*.patch)
fi

had_error=0
processed=0

for patch in "${patches[@]}"; do
  if [[ ! -f "$patch" ]]; then
    echo "missing patch file: $patch"
    had_error=1
    continue
  fi

  pkg="$(basename "$patch" .patch)"
  src_dir="$(resolve_source_dir "$pkg" || true)"

  if [[ -z "$src_dir" ]]; then
    echo "missing path dependency mapping for '$pkg' in $MANIFEST_FILE"
    had_error=1
    continue
  fi

  if [[ ! -d "$src_dir/.git" ]]; then
    echo "missing source checkout for '$pkg': $src_dir"
    had_error=1
    continue
  fi

  rev_file="$PATCH_DIR/$pkg.base-rev"
  if [[ -f "$rev_file" ]]; then
    expected_rev="$(cat "$rev_file")"
    current_rev="$(git -C "$src_dir" rev-parse HEAD)"
    if [[ "$expected_rev" != "$current_rev" ]]; then
      echo "warning: $pkg source revision differs (expected $expected_rev, found $current_rev)"
    fi
  fi

  if git -C "$src_dir" apply --reverse --check "$patch" >/dev/null 2>&1; then
    echo "already applied: $pkg -> $src_dir"
    processed=$((processed + 1))
    continue
  fi

  if [[ "$MODE" == "check" ]]; then
    if git -C "$src_dir" apply --check "$patch"; then
      echo "check ok: $pkg -> $src_dir"
      processed=$((processed + 1))
    else
      echo "check failed: $pkg -> $src_dir"
      had_error=1
    fi
    continue
  fi

  if git -C "$src_dir" apply --check "$patch"; then
    git -C "$src_dir" apply "$patch"
    echo "applied: $pkg -> $src_dir"
    processed=$((processed + 1))
    continue
  fi

  if git -C "$src_dir" apply --3way "$patch"; then
    echo "applied (3-way): $pkg -> $src_dir"
    processed=$((processed + 1))
  else
    echo "failed to apply: $pkg ($patch)"
    had_error=1
  fi
done

if [[ "$processed" -eq 0 ]]; then
  echo "no patches processed"
else
  echo "$MODE complete: $processed patch file(s)"
fi

exit "$had_error"
