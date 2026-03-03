# galpy (optional)

`galpy` is used for galactic dynamics (orbits, potentials, action-angle methods). In catsim it is treated as an **optional** backend.

## Why a submodule?

We want to avoid copying large third-party code into this repo while keeping a reproducible way to pull a known upstream version.

## How to initialize

If you cloned this repo as a git repository:

```bash
git submodule update --init --recursive
```

Or, if you want only galpy:

```bash
git submodule update --init third_party/galpy
```

## Runtime behavior

Nothing in the Tirole pipeline requires galpy.

- If galpy is not present, catsim continues to run normally.
- If galpy is present, we can enable orbit/trajectory scenarios via the kernel (Scenario/Engine/Clock) layer.
