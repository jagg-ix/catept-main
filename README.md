# CATEPT — Complex Action Theory and Entropic Proper Time

A Lean 4.29 formalization of the **Complex Action Theory and Entropic Proper
Time (CAT/EPT)** framework: a machine-checked connection between **Quantum
Mechanics** and **General Relativity** via **entropic proper time**
`τ_ent = S_I / ℏ`.

> For the curated publication artifact, see the
> [`feat/publication`](https://github.com/jagg-ix/catept-main/tree/feat/publication)
> branch of this repository.

## Quick Start

```bash
git clone https://github.com/jagg-ix/catept-main.git
cd catept-main
git checkout feat/publication
lake exe cache get                    # warm Mathlib olean cache (first run)
lake build CATEPT.Showcase.QMGRUnification
```

## Quantum Mechanics ↔ General Relativity via entropic proper time

A single plugin slot carries `actionIm`, `ℏ`, and `eptClock`. The constraint

```
∀ x, actionIm(x) / ℏ = eptClock(x)
```

is proved on two instances:

| Theory | Instance | Consistency theorem |
|---|---|---|
| Quantum Mechanics (n-level density matrices) | `quantumCATEPTSlot n` | `qm_satisfies_catept_spine` |
| General Relativity (Minkowski background) | `gravitasMinkowskiSlot` | `gr_minkowski_satisfies_catept_spine` |

All proofs depend only on the Lean kernel axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Machine-checking from the command line

```bash
cat > /tmp/catept_audit.lean <<'EOF'
import CATEPT.Showcase.QMGRUnification
#print axioms CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
EOF
lake env lean /tmp/catept_audit.lean
```

Expected output (one line per theorem):

```
'…qm_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
'…gr_minkowski_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Any other axiom appearing in the list is a regression. A CI gate at
[`.github/workflows/axiom-gate.yml`](.github/workflows/axiom-gate.yml)
enforces this check on every push and pull request.

## Dependencies

Mathlib v4.29.0 and a set of pinned public Lean 4 packages; see
[`lakefile.lean`](lakefile.lean) for the full list and exact revisions.

## Coordination hub

`catept-main` acts as a coordination hub for an expanding set of
sibling-repo plugins. Each sibling lives in its own GitHub repository
with independent versioning, builds, and CI, and is pulled in here via
a SHA-pinned `require` in [`lakefile.lean`](lakefile.lean).

| Sibling repo | Pin SHA (short) | Provides |
|---|---|---|
| [`jagg-ix/catept-plugin-hille-yosida`](https://github.com/jagg-ix/catept-plugin-hille-yosida) | `a257926` | C₀-semigroup integration bridge (5 theorems) |
| [`jagg-ix/catept-plugin-brownian-motion`](https://github.com/jagg-ix/catept-plugin-brownian-motion) | `318d4d7` | Brownian-motion abstract integration contract |
| [`jagg-ix/catept-plugin-dimensional-analysis`](https://github.com/jagg-ix/catept-plugin-dimensional-analysis) | `d89c87a` | Dimensional-analysis integration contract (PHQ/LSI/CPM/IMD) |
| [`jagg-ix/catept-plugin-cslib`](https://github.com/jagg-ix/catept-plugin-cslib) | `b71b95f` | cslib integration contract (computability/automata/Ramsey) |
| [`jagg-ix/catept-plugin-quantum-info`](https://github.com/jagg-ix/catept-plugin-quantum-info) | `ad9eada` | quantum-information integration contract (CPTP/Braket/von Neumann/Rényi/Shannon/capacity) |
| [`jagg-ix/catept-plugin-gaussian-field-lsi`](https://github.com/jagg-ix/catept-plugin-gaussian-field-lsi) | `3783875` | Gaussian field log-Sobolev / spectral-gap / 2nd-moment bridge (BKM ingredient backbone) |

Authoritative pin SHAs live in [`lake-manifest.json`](lake-manifest.json).
Existing consumers reach the sibling theorems through thin re-export
shims under `CATEPTMain/Integration/` so source-level imports do not
need to change.

For the rationale, the playbook for adding a new sibling, and the
pin-bump workflow, see
[`docs/architecture/plugin-split.md`](docs/architecture/plugin-split.md).

## Acknowledgments

### Intellectual foundations

The framework builds on the entropic-dynamics research programme of
**Prof. Ariel Caticha** (University at Albany, SUNY) —
[arielcaticha.com](https://www.arielcaticha.com/entropic-dynamics-qft-and-gravity).

### Ported libraries

- [`CATEPTMain/Gravitas/`](CATEPTMain/Gravitas/) — Lean 4 port of the
  Gravitas symbolic general-relativity package (original: Wolfram
  Language).
- [`CATEPTMain/QuantumOps/IsabelleMarresDirac/`](CATEPTMain/QuantumOps/IsabelleMarresDirac/)
  — Lean 4 port from Isabelle/HOL.

### Lean 4 mathematical-physics dependencies by Michael R. Douglas

Three of the analytic-functional pillars this repository depends on are
contributed by [**mrdouglasny**](https://github.com/mrdouglasny) — Lean 4
formalizations of foundational theorems for measure-theoretic QFT and
semigroup dynamics. Whose wonderful work makes the CATEPT analytic lane
practical:

- [**bochner**](https://github.com/mrdouglasny/bochner) — the
  Bochner–Minlos theorem (characteristic functionals on nuclear spaces;
  the measure-theoretic foundation of Euclidean QFT).
- [**hille-yosida**](https://github.com/mrdouglasny/hille-yosida) — the
  Hille–Yosida generation theorem for `C₀`-semigroups (analytic backbone
  of modular flow and heat-kernel arguments).
- [**pphi2**](https://github.com/mrdouglasny/pphi2) — φ⁴ scalar field
  theory infrastructure.

### Other external Lean 4 dependencies

Thanks to the upstream authors and maintainers of Mathlib4, Physlib,
pphi2N, GaussianField, LGT, cslib, DeGiorgi, spectralPhysics,
DimensionalAnalysis, UnifiedTheory, aristotle, aqeiBridge, lean-inf, and
QuantumAlgebra. Pinned revisions live in [`lakefile.lean`](lakefile.lean).

## License

Apache-2.0. See [`LICENSE`](LICENSE).
