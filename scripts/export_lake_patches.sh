#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_DIR="$ROOT_DIR/.lake/packages"
PATCH_DIR="$ROOT_DIR/third_party/lake-patches"

# Policy guard: reading/exporting edits from .lake/packages is legacy-only.
# Standard Lean workflow is to edit dependency source repos and run `lake update`.
if [[ "${ALLOW_LAKE_PACKAGE_PATCH:-0}" != "1" ]]; then
  echo "blocked: exporting .lake/packages patches is disabled by default"
  echo "standard workflow: edit dependency source repo, commit there, then run 'lake update'"
  echo "override (legacy only): ALLOW_LAKE_PACKAGE_PATCH=1 ./scripts/export_lake_patches.sh"
  exit 2
fi

if [[ ! -d "$PACKAGES_DIR" ]]; then
  echo "error: packages directory not found: $PACKAGES_DIR"
  echo "run 'lake update' first"
  exit 1
fi

mkdir -p "$PATCH_DIR"

collect_packages() {
  if [[ $# -gt 0 ]]; then
    printf '%s\n' "$@"
  else
    find "$PACKAGES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
  fi
}

exported=0

while IFS= read -r pkg; do
  [[ -n "$pkg" ]] || continue

  pkg_dir="$PACKAGES_DIR/$pkg"
  if [[ ! -d "$pkg_dir/.git" ]]; then
    continue
  fi

  tmp_patch="$(mktemp)"

  # Tracked edits/deletions.
  git -C "$pkg_dir" diff --binary --full-index > "$tmp_patch"

  # Untracked files are not included by git diff; add them as create-file diffs.
  while IFS= read -r untracked; do
    [[ -n "$untracked" ]] || continue
    git -C "$pkg_dir" diff --binary --full-index --no-index -- /dev/null "$untracked" >> "$tmp_patch" || true
  done < <(git -C "$pkg_dir" ls-files --others --exclude-standard)

  if [[ -s "$tmp_patch" ]]; then
    mv "$tmp_patch" "$PATCH_DIR/$pkg.patch"
    git -C "$pkg_dir" rev-parse HEAD > "$PATCH_DIR/$pkg.base-rev"
    echo "exported: $pkg -> $PATCH_DIR/$pkg.patch"
    exported=$((exported + 1))
  else
    rm -f "$tmp_patch"
    rm -f "$PATCH_DIR/$pkg.patch" "$PATCH_DIR/$pkg.base-rev"
  fi
done < <(collect_packages "$@")

if [[ "$exported" -eq 0 ]]; then
  echo "no package edits detected"
else
  echo "export complete: $exported patch file(s)"
fi
