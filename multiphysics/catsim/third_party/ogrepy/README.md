# OGRePy (optional)

OGRePy is a symbolic tensor-calculus package built on SymPy, designed for
general relativity and differential geometry. In catsim, OGRePy is treated as
an **optional** backend.

We use OGRePy for:

* cross-checking CAT/EPT geometric tensor code (connections/curvature),
* implementing the **complex Einstein field equations** (complex EFE)
  in a way that can be validated against an independent symbolic engine.

## Why a submodule?

We avoid copying third-party code into this repository while keeping a
reproducible way to pull a known upstream version.

## How to initialize

```bash
git submodule update --init --recursive
```

Or, only OGRePy:

```bash
git submodule update --init third_party/ogrepy
```

## Runtime behavior

Nothing in the Tirole pipeline requires OGRePy.

* If OGRePy is not present, catsim continues to run normally.
* If OGRePy is present, Phase 6.6 (complex EFE checks) can use it as a
  cross-check backend.
