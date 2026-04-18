# Taco Vendor Patch Export

These patches were moved out of the `multiphysics/external/taco` submodule so
the submodule working tree remains clean in this repository.

Origin:
- Previously stored under `multiphysics/external/taco/patches/`

Contents:
- `0001-entropic-proper-time-context-and-cli.patch`
- `series/0001-tensor-add-first-class-entropic-proper-time-context-.patch`
- `series/0002-tools-expose-entropic-proper-time-CLI-controls-and-r.patch`

Usage:
- Apply to a local Taco clone/fork using `git am` or `git apply` depending on
  patch format and workflow.
