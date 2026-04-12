# CATEPT Main (Lean 4.29 Clean Migration)

This repository is a clean Lean 4.29 migration target.

## Included compatible module lane

- `physlib` (local pin)
- `bochner` / `BochnerMinlos` (local pin)
- `hille-yosida` (local pin)
- `cslib-inspect` (local pin)
- `pphi2` (local pin)

## Notes

- Dependencies are pinned by commit in `lakefile.lean` for reproducibility.
- Legacy or RC packages are intentionally excluded from the initial clean lane.
