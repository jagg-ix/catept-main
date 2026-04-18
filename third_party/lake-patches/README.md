# Lake Package Patch Workflow (Legacy/Archival)

This folder stores tracked patch files for historic edits made under `.lake/packages`.

Why: `.lake/` is ignored in the main repository, so direct edits to dependency
checkouts disappear on a fresh environment unless you export them.

## Standard Lean4 workflow (default in this repo)

This repo treats direct `.lake/packages` patching as non-standard and disabled by default.

Use the community-standard dependency workflow:

1. Edit the real dependency source repository (path or git dependency).
2. Commit there.
3. Run `lake update` in this repo.
4. Build targets normally.

For GaussianField, this is already wired via a path dependency in `lakefile.lean`.

## Leveraging archived patches without editing `.lake`

If you need to reuse archived patch content, apply it to the real source
dependency repo (path dependency), not to `.lake/packages`.

From repo root:

```bash
./scripts/apply_source_dependency_patches.sh --check GaussianField
./scripts/apply_source_dependency_patches.sh GaussianField
```

Then commit in the source repo and rehydrate in this repo:

```bash
cd /Users/macbookpro/lab/tau/tau-information-dynamics/gaussian-field
git add -A && git commit -m "Apply archived GaussianField patch"
cd /Users/macbookpro/lab/tau/tau-information-dynamics/catept-main
lake update
```

This keeps all maintained code outside `.lake/packages` while still reusing
historical patch artifacts.

## Preferred long-term workflow (avoid `.lake` edits entirely)

Use an editable source dependency and stop editing files in `.lake/packages`.

For GaussianField in this repo:

1. Keep the source checkout at:
	- `/Users/macbookpro/lab/tau/tau-information-dynamics/gaussian-field`
2. Keep `lakefile.lean` wired to it via:
	- `require GaussianField from "/Users/macbookpro/lab/tau/tau-information-dynamics/gaussian-field"`
3. Edit and commit changes in that source repo, not in `.lake/packages/GaussianField`.
4. Run `lake update` in this repo to rehydrate manifest state.

The patch workflow below is legacy-only archival fallback for migration of old edits.
Do not use it for new development.

## 1) Export current dependency edits

Run from the main repo root:

```bash
ALLOW_LAKE_PACKAGE_PATCH=1 ./scripts/export_lake_patches.sh
```

Optional: export only specific packages:

```bash
ALLOW_LAKE_PACKAGE_PATCH=1 ./scripts/export_lake_patches.sh GaussianField mathlib
```

This writes:
- `third_party/lake-patches/<Package>.patch`
- `third_party/lake-patches/<Package>.base-rev`

The patch includes tracked diffs and untracked new files.

## 2) Rehydrate and apply on a new machine (legacy fallback)

```bash
lake update
ALLOW_LAKE_PACKAGE_PATCH=1 \
./scripts/apply_lake_patches.sh
```

Optional: apply only selected packages:

```bash
ALLOW_LAKE_PACKAGE_PATCH=1 ./scripts/apply_lake_patches.sh GaussianField
```

Then run your normal build target(s).

## Notes

- `*.base-rev` records the dependency commit that the patch was exported from.
- If revisions differ, apply attempts a 3-way merge and warns.
- Keep these patch files committed in the main repo.

## Troubleshooting

If `./scripts/apply_lake_patches.sh` reports `patch does not apply` for a package,
the local checkout is usually dirty or on a different file state than the patch base.

For a deterministic reset of a single package checkout:

```bash
rm -rf .lake/packages/GaussianField
lake update
ALLOW_LAKE_PACKAGE_PATCH=1 ./scripts/apply_lake_patches.sh
```

Then re-run your usual build target.
