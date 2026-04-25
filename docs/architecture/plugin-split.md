# Plugin split — coordination hub

`catept-main` consumes its plugin sources via two mechanisms:

1. **In-tree** — sources live under `CATEPTMain/` and are built by the
   `CATEPTMain` lake target.
2. **Sibling-repo (pinned)** — sources live in their own GitHub repo and
   are pulled in via `require ... from git ... @ "<sha>"` in
   [`lakefile.lean`](../../lakefile.lean), with the SHA recorded in
   [`lake-manifest.json`](../../lake-manifest.json).

This document is the index for the sibling-repo half. It records which
plugins are split, where they live, what version they're pinned to, and
how to add or update one.

For the operational manual (extraction steps, re-integration steps,
sibling-CI template, rollback procedure, per-plugin checklist), see the
[**plugin-split-playbook.md**](plugin-split-playbook.md). For the
target-level decomposition with measurable DONE criteria, see the
[**target-4-plan.md**](targets/target-4-plan.md).

---

## Why splits

Today most plugins live in `CATEPTMain/`. The cost of that monorepo:

- A single failing plugin breaks the whole CI matrix.
- Pin bumps on Mathlib cascade through every plugin at once.
- The "core + Bridges" publication surface (5 files) is indistinguishable
  in the dep graph from 20+ Integration plugins.
- Plugin authors cannot version independently.

Splitting a plugin to its own repo gives it: an independent CI, an
independent version cadence, and a precise pin SHA in `catept-main`.
The pattern is the one already used by `xiyin137/OSreconstruction` (the
de-facto exemplar) and `mrdouglasny/hille-yosida` (the underlying
package the first sibling wraps).

---

## Current sibling inventory

Pin SHAs are authoritative in [`lake-manifest.json`](../../lake-manifest.json);
this table is informational and may lag. Re-run
`grep -A5 '"name": "«catept-plugin-' lake-manifest.json` for the live
state.

| Sibling repo | Pin SHA | Tag | Sentinel theorems | Re-export shim |
|---|---|---|---|---|
| [`jagg-ix/catept-plugin-hille-yosida`](https://github.com/jagg-ix/catept-plugin-hille-yosida) | `a25792615fe64d7a551dc32a940d60c219fa3d06` | `v0.1.0` | 5 | [`CATEPTMain/Integration/HilleYosidaBridge.lean`](../../CATEPTMain/Integration/HilleYosidaBridge.lean) |
| [`jagg-ix/catept-plugin-brownian-motion`](https://github.com/jagg-ix/catept-plugin-brownian-motion) | `318d4d750a09f5fde73c0c62cd790c57bb8e1bdf` | `v0.1.0` | 1 | [`CATEPTMain/Integration/BrownianMotionBridge.lean`](../../CATEPTMain/Integration/BrownianMotionBridge.lean) |
| [`jagg-ix/catept-plugin-dimensional-analysis`](https://github.com/jagg-ix/catept-plugin-dimensional-analysis) | `d89c87a3612d9c1fccf469b13ad3d12c29ac3f40` | `v0.1.0` | 1 | [`CATEPTMain/Integration/LeanDimensionalAnalysisBridge.lean`](../../CATEPTMain/Integration/LeanDimensionalAnalysisBridge.lean) |
| [`jagg-ix/catept-plugin-cslib`](https://github.com/jagg-ix/catept-plugin-cslib) | `b71b95fc5859ef6277c994212979e009c79c1b76` | `v0.1.0` | 1 | [`CATEPTMain/Integration/CslibBridge.lean`](../../CATEPTMain/Integration/CslibBridge.lean) |
| [`jagg-ix/catept-plugin-quantum-info`](https://github.com/jagg-ix/catept-plugin-quantum-info) | `ad9eada1f4449bdc7d5a25704a1c555b7bbc989f` | `v0.1.0` | 1 | [`CATEPTMain/Integration/QuantumInfoBridge.lean`](../../CATEPTMain/Integration/QuantumInfoBridge.lean) |
| [`jagg-ix/catept-plugin-gaussian-field-lsi`](https://github.com/jagg-ix/catept-plugin-gaussian-field-lsi) | `3783875a6d58d59fdc93a9c10988c4fefe5cb6c5` | `v0.1.0` | 6 | [`CATEPTMain/Integration/GaussianFieldLogSobolevBridge.lean`](../../CATEPTMain/Integration/GaussianFieldLogSobolevBridge.lean) |
| [`jagg-ix/catept-plugin-spectral-physics`](https://github.com/jagg-ix/catept-plugin-spectral-physics) | `95b216bf92f2e8306abc14ec733f70da50411004` | `v0.1.0` | 10 | [`CATEPTMain/Integration/SpectralPhysicsBridge.lean`](../../CATEPTMain/Integration/SpectralPhysicsBridge.lean) |
| [`jagg-ix/catept-plugin-degiorgi`](https://github.com/jagg-ix/catept-plugin-degiorgi) | `5b06dc824b0dfb6c12cba57c1a364d142c678c93` | `v0.1.0` | 8 | [`CATEPTMain/Integration/DeGiorgiBridge.lean`](../../CATEPTMain/Integration/DeGiorgiBridge.lean) |
| [`jagg-ix/catept-plugin-maxwell-curvespace-pphi2`](https://github.com/jagg-ix/catept-plugin-maxwell-curvespace-pphi2) | `be3d80bd7946461bb0a8c3e3f737b29bd2f69efa` | `v0.1.0` | 1 | [`CATEPTMain/Integration/MaxwellCurveSpacePphi2Bridge.lean`](../../CATEPTMain/Integration/MaxwellCurveSpacePphi2Bridge.lean) |
| [`jagg-ix/catept-plugin-vml-landau`](https://github.com/jagg-ix/catept-plugin-vml-landau) | `7ef1b4b0d7c171aeee9f395b87a5ebb4a38add7d` | `v0.1.0` | 5 | [`CATEPTMain/Integration/VMLLandauBridge.lean`](../../CATEPTMain/Integration/VMLLandauBridge.lean) |
| [`jagg-ix/catept-plugin-bochner-minlos`](https://github.com/jagg-ix/catept-plugin-bochner-minlos) | `dae9f683e724970f7d335cf4223b24bac8f4fa65` | `v0.1.0` | 1 | [`CATEPTMain/Integration/BochnerMinlosBridge.lean`](../../CATEPTMain/Integration/BochnerMinlosBridge.lean) |
| [`jagg-ix/catept-plugin-carleson`](https://github.com/jagg-ix/catept-plugin-carleson) | `684eeb46e364a0fca7709bb0c6c8ea6063538c57` | `v0.1.0` | 2 | [`CATEPTMain/Integration/CarlesonBridge.lean`](../../CATEPTMain/Integration/CarlesonBridge.lean) |
| [`jagg-ix/catept-plugin-gibbs-measure`](https://github.com/jagg-ix/catept-plugin-gibbs-measure) | `6b0c701baddadfecf454b9319ab9071ecec0dd49` | `v0.1.0` | 1 | [`CATEPTMain/Integration/GibbsMeasureBridge.lean`](../../CATEPTMain/Integration/GibbsMeasureBridge.lean) |
| [`jagg-ix/catept-plugin-hopf-lean`](https://github.com/jagg-ix/catept-plugin-hopf-lean) | `6236741efbba64355b24ca699482c2acd3d67ac0` | `v0.1.0` | 1 | [`CATEPTMain/Integration/HopfLeanBridge.lean`](../../CATEPTMain/Integration/HopfLeanBridge.lean) |
| [`jagg-ix/catept-plugin-kolmogorov-complexity`](https://github.com/jagg-ix/catept-plugin-kolmogorov-complexity) | `b29f32d938dd6db0287ec6c6298934ffeda423e9` | `v0.1.0` | 1 | [`CATEPTMain/Integration/KolmogorovComplexityBridge.lean`](../../CATEPTMain/Integration/KolmogorovComplexityBridge.lean) |
| [`jagg-ix/catept-plugin-thermodynamics-lean`](https://github.com/jagg-ix/catept-plugin-thermodynamics-lean) | `9a97fce70dd7e179c3219103df1f4a4053668aac` | `v0.1.0` | 1 | [`CATEPTMain/Integration/ThermodynamicsLeanBridge.lean`](../../CATEPTMain/Integration/ThermodynamicsLeanBridge.lean) |

Each sibling exposes its theorems under a `CATEPTPlugin<Name>`
namespace. The thin re-export shim in `CATEPTMain/Integration/` makes
them also reachable under the original `CATEPTMain.Integration.<Old>`
namespace, so existing consumers (e.g. `CATEPTMain.lean`,
`External/Registry.lean`) keep compiling without source changes.

### Related external pins (not catept-plugin-* siblings)

These predate Target 4 but follow the same coordination-hub pattern.
They are listed in [`lakefile.lean`](../../lakefile.lean) and are not
considered "splits" because they were never in-tree.

| External repo | What it provides |
|---|---|
| `xiyin137/OSreconstruction` | Osterwalder–Schrader Wightman/Minkowski coincidence (Target 2 publication-bridge exemplar) |
| `mrdouglasny/hille-yosida` | C₀-semigroup theory used by `catept-plugin-hille-yosida` |
| `mrdouglasny/bochner` | Bochner–Minlos theorem |
| `mrdouglasny/pphi2` + `jagg-ix/pphi2N` | φ⁴ + O(N) σ-model |
| `jagg-ix/gaussian-field`, `jagg-ix/lgt`, `jagg-ix/aristotle`, … | further pinned packages, see lakefile |

---

## Pin-bump workflow

When a sibling repo's `main` advances and `catept-main` should pick up
the new commit, the maintainer runs:

```bash
# 1. Identify the new SHA (e.g. from the sibling's commit page).
SIBLING=catept-plugin-hille-yosida
NEW_SHA=$(gh api repos/jagg-ix/$SIBLING/commits/main --jq .sha)

# 2. Update the pin in lakefile.lean — replace the old @ "<old-sha>" with @ "<new-sha>".
#    Either edit by hand or:
sed -i '' -E "s|(catept-plugin-hille-yosida\.git\" @ \")[a-f0-9]+|\1$NEW_SHA|" lakefile.lean

# 3. Resolve the pin and refresh lake-manifest.json.
lake update $SIBLING

# 4. Rebuild and run the sentinel-theorem axiom check
#    (.github/workflows/axiom-gate.yml does this automatically on push).
lake build
```

**Rule:** the sibling's CI must be green on its `main` at the
post-bump SHA before catept-main bumps to it. The sibling-CI template
in the playbook checks `#print axioms` on the sentinel theorems on
every push, so a green badge is sufficient evidence.

If the bump fails (build break, axiom regression):

1. Don't revert immediately — the pin can stay at the old SHA. The
   sibling repo continues to live; the bump just doesn't happen.
2. File an issue against the sibling for the regression.
3. When the sibling is fixed, re-run the bump procedure.

---

## Adding a new sibling

Follow the steps in [**plugin-split-playbook.md**](plugin-split-playbook.md):

1. **T4.1-style selection** — confirm the plugin meets the four
   selection criteria (≤ 3 `CATEPTMain.*` imports, no `Integration/*`
   outgoing deps, ≥ 1 verifiable theorem, willing maintainer).
2. **Extraction** — 9-step procedure: new repo, lakefile, lean-toolchain,
   namespace-renamed sources, lake build, axiom check, README contract,
   tag, push.
3. **Re-integration** — 7-step procedure: lakefile require, lake update,
   re-export shim (or consumer rename), delete in-tree copy,
   lake build, axiom-gate check, single atomic commit.
4. **Sibling CI** — copy the workflow template from the playbook into
   the new repo's `.github/workflows/axiom-gate.yml`.

When adding the new sibling, append a row to the **Current sibling
inventory** table above with the pin SHA, tag, sentinel-theorem count,
and shim path.

---

## See also

- [`plugin-split-playbook.md`](plugin-split-playbook.md) — operational manual
- [`targets/target-4-plan.md`](targets/target-4-plan.md) — six middle-targets with measurable DONE criteria
- [`targets/target-4-sibling-ci-axiom-gate.yml`](targets/target-4-sibling-ci-axiom-gate.yml) — workflow file pending application by maintainer with `gh auth refresh -s workflow`
