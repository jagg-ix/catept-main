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

## Significant solved artifacts (Lean4)

Examples of “fundamental equations / significant problems” that are already formalized in this
repo (with explicit, checkable theorem names):

- **QM ↔ GR spine consistency** (entropic proper time identity across two instances):
  `CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine`,
  `CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine`
- **Rigorous complex Feynman–Kac (entropically damped class)**:
  `CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous`
- **Counterterm-free / no-renormalization UV certificate**:
  `CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_no_counterterm_needed`


## Axiom-free theorems (no kernel axioms required)

A subset of the audited surface clears an even stronger bar than
"kernel-only": **10 theorems** in `CATEPTMain/Domains/CoherenceShowcase.lean`
print

```
'…' does not depend on any axioms
```

— meaning the proof reduces to definitional equality and does not
invoke `propext`, `Classical.choice`, or `Quot.sound` at all. These
are the *most rigorously certified* statements in the spine surface:
purely computable, no classical reasoning, no quotient lifting. Each
one is the integration-contract theorem of a sibling plugin whose
proof is `⟨…⟩` (anonymous constructor, term-mode) over Prop fields,
and Lean recognises it as axiom-free at the kernel level.

| # | Theorem (fully qualified) | Sibling plugin | What it asserts |
|--:|---|---|---|
| 1 | `CATEPTPluginQuantumInfo.quantumInfo_integration_contract` | `catept-plugin-quantum-info` | CPTP / Braket / von Neumann / Rényi / Shannon / capacity contract package |
| 2 | `CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract` | `catept-plugin-bochner-minlos` | Bochner-Minlos PD / Sazonov / Schur / abstract Minlos contract |
| 3 | `CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract` | `catept-plugin-gibbs-measure` | Kolmogorov extension / Gibbs-DLR / Giry monad witness |
| 4 | `CATEPTPluginHopfLean.hopfLean_integration_contract` | `catept-plugin-hopf-lean` | coalgebra / bialgebra / Hopf / Yang-Baxter / BMod-monoidal witness |
| 5 | `CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract` | `catept-plugin-kolmogorov-complexity` | AIT invariance / Chaitin Ω / incompressibility / Gödel-2 via K |
| 6 | `CATEPTPluginCarleson.carleson_integration_contract` | `catept-plugin-carleson` | abstract Carleson / a.e. Fourier convergence contract |
| 7 | `CATEPTPluginCarleson.concrete_witness_contract` | `catept-plugin-carleson` | concrete Carleson witness (Dirichlet / Jackson / antichain) |
| 8 | `CATEPTPluginCslib.cslib_integration_contract` | `catept-plugin-cslib` | computability / automata / Ramsey integration |
| 9 | `CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract` | `catept-plugin-thermodynamics-lean` | Lieb-Yngvason axioms / entropy existence-uniqueness-continuity / Kelvin-Planck |
| 10 | `CATEPTPluginVMLLandau.vml_landau_content_available` | `catept-plugin-vml-landau` | VML-Landau collision-content marker (Aristotle/Clawristotle Theorem 4.2 surface) |


### Why "axiom-free" is meaningfully different from "kernel-only"

The repo's broader audit gate guarantees that 133 spine-surface
theorems depend on at most `propext`, `Classical.choice`, `Quot.sound` —
the three Lean 4 kernel axioms that ship with Lean and Mathlib. The
10 theorems above clear a strictly higher bar: **zero axioms**. Their
proof terms reduce to identity-like constructions over `Prop` fields,
so even the standard kernel axioms aren't reached when computing the
proof's axiom dependencies. This is the same level of certification
as e.g. `theorem one_plus_one : 1 + 1 = 2 := rfl` in pure Lean.

In practical terms: every plugin whose integration contract is in
this list has its full structural-package theorem reducible to
`⟨h1, h2, …⟩` over user-supplied premises, with no classical
reasoning, no quotient soundness, no propositional extensionality
required. The premises themselves may eventually require those
axioms (e.g. when actual analytic theorems are substituted in) but
the contract framing does not.

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
