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

### External Lean 4 dependencies

Thanks to the upstream authors and maintainers of Mathlib4, Physlib,
BochnerMinlos, HilleYosida, pphi2, pphi2N, GaussianField, LGT, cslib,
DeGiorgi, spectralPhysics, DimensionalAnalysis, UnifiedTheory, aristotle,
aqeiBridge, lean-inf, and QuantumAlgebra. Pinned revisions live in
[`lakefile.lean`](lakefile.lean).

## License

Apache-2.0. See [`LICENSE`](LICENSE).
