#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/.lake/packages"
PATCH_DIR="$ROOT_DIR/third_party/lake-patches"

# Policy guard: applying diffs directly into .lake/packages is legacy-only.
# Standard Lean workflow is to edit source dependencies and run `lake update`.
if [[ "${ALLOW_LAKE_PACKAGE_PATCH:-0}" != "1" ]]; then
  echo "blocked: patching .lake/packages is disabled by default"
  echo "standard workflow: edit dependency source repo, then run 'lake update'"
  echo "override (legacy only): ALLOW_LAKE_PACKAGE_PATCH=1 ./scripts/apply_lake_patches.sh"
  exit 2
fi

if [[ ! -d "$PATCH_DIR" ]]; then
  echo "no patch directory found: $PATCH_DIR"
  exit 0
fi

if [[ ! -d "$PACKAGES_DIR" ]]; then
  echo "error: packages directory not found: $PACKAGES_DIR"
  echo "run 'lake update' first"
  exit 1
fi

had_error=0
applied=0

shopt -s nullglob
patches=()
if [[ $# -gt 0 ]]; then
  for pkg in "$@"; do
    patches+=("$PATCH_DIR/$pkg.patch")
  done
else
  patches=("$PATCH_DIR"/*.patch)
fi

for patch in "${patches[@]}"; do
  if [[ ! -f "$patch" ]]; then
    echo "missing patch file: $patch"
    had_error=1
    continue
  fi

  pkg="$(basename "$patch" .patch)"
  pkg_dir="$PACKAGES_DIR/$pkg"

  if [[ ! -d "$pkg_dir/.git" ]]; then
    echo "missing package checkout for '$pkg': $pkg_dir"
    had_error=1
    continue
  fi

  rev_file="$PATCH_DIR/$pkg.base-rev"
  if [[ -f "$rev_file" ]]; then
    expected_rev="$(cat "$rev_file")"
    current_rev="$(git -C "$pkg_dir" rev-parse HEAD)"
    if [[ "$expected_rev" != "$current_rev" ]]; then
      echo "warning: $pkg revision differs (expected $expected_rev, found $current_rev)"
      echo "         attempting 3-way apply"
    fi
  fi

  if git -C "$pkg_dir" apply --check "$patch"; then
    git -C "$pkg_dir" apply "$patch"
    echo "applied: $pkg"
    applied=$((applied + 1))
    continue
  fi

  if git -C "$pkg_dir" apply --3way "$patch"; then
    echo "applied (3-way): $pkg"
    applied=$((applied + 1))
  else
    echo "failed to apply: $pkg ($patch)"
    had_error=1
  fi
done

if [[ "$applied" -eq 0 ]]; then
  echo "no patches applied"
else
  echo "apply complete: $applied patch file(s)"
fi

exit "$had_error"
