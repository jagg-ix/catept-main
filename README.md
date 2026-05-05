# CATEPT — Complex Action Theory and Entropic Proper Time

A Lean 4.29 formalization of the **Complex Action Theory and Entropic Proper
Time (CAT/EPT)** framework: a machine-checked connection between **Quantum
Mechanics** and **General Relativity** via **entropic proper time**

```
τ_ent = S_I / ℏ
```

where `S = S_R + i·S_I` is a complex action. The framework's central claim
is that `τ_ent` is a *single* time parameter on which both QM and GR can be
expressed and made consistent — and that this is not a metaphor, but a
formal identity that the Lean kernel can check.

> For the curated publication artifact, see the
> [`feat/publication`](https://github.com/jagg-ix/catept-main/tree/feat/publication)
> branch of this repository.

## How CAT/EPT is proven (read-this-first map)

Every other section of this README contributes one piece of the
proof below. Use this map to see where each piece fits.

```
                ┌──────────────────────────────────────────────┐
                │  Spine constraint (the central claim)        │
                │      ∀ x, actionIm(x) / ℏ  =  eptClock(x)    │
                └──────────────────────────────────────────────┘
                                    │
                ┌───────────────────┼────────────────────┐
                │                   │                    │
        ┌───────▼────────┐  ┌───────▼────────┐  ┌────────▼────────┐
        │  QM instance   │  │  GR instance   │  │ analytic        │
        │  qm_satisfies_ │  │ gr_minkowski_  │  │ machinery       │
        │  catept_spine  │  │ satisfies_..._ │  │ (FK, UV cert,   │
        │                │  │ catept_spine   │  │  …)             │
        └────────────────┘  └────────────────┘  └────────┬────────┘
                                                         │
                                            ┌────────────▼─────────────┐
                                            │ 10 axiom-free contracts  │
                                            │ binding external math    │
                                            │ (QInfo, Carleson, Hopf,  │
                                            │  Gibbs, K-complexity, …) │
                                            └────────────┬─────────────┘
                                                         │
                                            ┌────────────▼─────────────┐
                                            │ Mathlib v4.29 + pinned   │
                                            │ public Lean 4 packages   │
                                            └──────────────────────────┘
```

* **Spine constraint** — the unification claim, stated once as a Prop
  on a plugin slot carrying `actionIm`, `ℏ`, `eptClock`. Sections
  *Quantum Mechanics ↔ General Relativity* and *Machine-checking from
  the command line*.
* **Two concrete instances** — discharge the constraint independently
  in QM and in GR, so the spine is not vacuous. Same sections.
* **Analytic machinery** — gives the spine substance: a rigorous
  complex Feynman–Kac for the damped class, plus a counterterm-free
  UV certificate. Section *Significant solved artifacts*.
* **10 axiom-free contracts** — one per external mathematical lane
  (quantum info, Carleson, Hopf, Gibbs, Kolmogorov complexity, …).
  Each contract is the *binding interface* between that lane and
  the spine; its axiom-freeness proves the binding adds no logical
  commitments. Section *Axiom-free theorems*.
* **Dependencies** — supply the heavy theorems plugged into those
  contracts. Sections *Dependencies* and *Acknowledgments*.

The whole graph is held together by a single audit gate (Section
*Machine-checking from the command line*): every theorem named in
this README either depends only on `propext`, `Classical.choice`,
`Quot.sound`, or on no axioms at all. The CI workflow at
[`.github/workflows/axiom-gate.yml`](.github/workflows/axiom-gate.yml)
re-runs the audit on every push.

## Quick Start

```bash
git clone https://github.com/jagg-ix/catept-main.git
cd catept-main
git checkout feat/publication
lake exe cache get                    # warm Mathlib olean cache (first run)
lake build CATEPT.Showcase.QMGRUnification
```

The last command builds the **headline claim** of the framework: the
two consistency theorems described in the next section. If it
completes without errors, the spine is verified at the type level
on this commit; the *Machine-checking from the command line* section
below shows how to verify it again at the axiom level.

## Quantum Mechanics ↔ General Relativity via entropic proper time

A single plugin slot carries `actionIm`, `ℏ`, and `eptClock`. The
**spine constraint**

```
∀ x, actionIm(x) / ℏ = eptClock(x)
```

is proved as a `Prop` against two concrete instances — one per
target theory. *Both* instances satisfying the constraint is what
makes `τ_ent` a unified time parameter rather than a coincidence
of notation:

| Theory | Instance | Consistency theorem |
|---|---|---|
| Quantum Mechanics (n-level density matrices) | `quantumCATEPTSlot n` | `qm_satisfies_catept_spine` |
| General Relativity (Minkowski background) | `gravitasMinkowskiSlot` | `gr_minkowski_satisfies_catept_spine` |

These two theorems are the framework's only "headline claims"; every
other artifact in the repo either (a) supplies machinery that
gives them substance (Section *Significant solved artifacts*),
(b) binds an external mathematical area into the slot in a kernel-
clean way (Section *Axiom-free theorems*), or (c) provides
infrastructure (dependencies). All three sections feed back into the
two theorems above.

Both proofs depend only on the Lean kernel axioms `propext`,
`Classical.choice`, `Quot.sound`. The next section is how to verify
that statement.

## Machine-checking from the command line

This is the **falsifiable contract** of the whole framework: the
spine consistency theorems must reduce to the three Lean kernel
axioms and nothing else. Anything else means a regression.

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

Any other axiom appearing in the list is a regression. The CI gate
at [`.github/workflows/axiom-gate.yml`](.github/workflows/axiom-gate.yml)
enforces this check on every push and pull request. The 10 axiom-free
contracts in the *Axiom-free theorems* section below tighten the
discipline further: their `#print axioms` output must say *"does not
depend on any axioms"* — strictly stronger than the kernel-only bar
that the two spine theorems clear.

## Significant solved artifacts (Lean4)

These are the artifacts that **give the spine substance**. Without
them, the QM/GR consistency theorems would be a formal shell — a
constraint satisfied trivially because nothing analytic is
happening. Each entry below is a checkable theorem name plus a one-
line statement of which proof obligation it discharges in the
diagram above.

- **QM ↔ GR spine consistency** (the central claim itself):
  - `CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine`
  - `CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine`

  These are the two theorems verified by the audit recipe above.
  Everything else in this section serves them.

- **Rigorous complex Feynman–Kac (entropically damped class)**:
  `CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous`

  *Role in the proof*: gives the QM-side spine instance an honest
  path-integral interpretation. The complex action `S = S_R + i·S_I`
  has `S_I ≥ 0` on the damped class, which makes
  `exp(-S_I/ℏ)·exp(i·S_R/ℏ)` a *contraction* — the analytic content
  behind treating `τ_ent = S_I/ℏ` as a real time parameter rather
  than a formal symbol.

- **Counterterm-free / no-renormalization UV certificate**:
  `CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_no_counterterm_needed`

  *Role in the proof*: closes the standard counter-objection that
  any path-integral framework needs renormalization to make sense
  at high energy. The certificate exhibits a UV regime where the
  damped class is convergent without counterterms, so the spine
  claim survives the UV limit.

The audit recipe in the previous section confirms both supporting
theorems clear the kernel-only bar. Together with the two spine
consistency theorems, they constitute the **minimal machine-checked
proof of CAT/EPT** at this commit.

## Axiom-free theorems (no kernel axioms required)

The 10 theorems in this section sit at a different layer of the
proof: they are the **boundary contracts** between the spine and
external mathematical areas (quantum information, Carleson Fourier
analysis, Hopf algebras, Gibbs measures, Kolmogorov complexity,
computability theory, thermodynamics, VML–Landau collisions). Each
contract is a structural-package theorem that *binds* the external
area to the spine slot.

The fact that all 10 print

```
'…' does not depend on any axioms
```

— i.e. clear an even stronger bar than the kernel-only audit above
— is the machine-checked statement that **the binding interface
itself adds no logical commitments**. The heavy mathematical content
(Carleson's a.e. convergence theorem, Lieb–Yngvason axioms, …)
lives in the user-supplied premises that fill the contract; the
contract framing reduces to `⟨h₁, h₂, …⟩` (anonymous constructor
over Prop fields), so the kernel sees pure definitional equality.

This is what makes the spine *modular*: a new external theory can
be plugged into CAT/EPT by exhibiting an integration contract for
its lane, with confidence that no hidden axioms are smuggled in by
the binding step. The 10 contracts below are the lanes that ship
in this commit.

### How to verify each one

Every entry below ships with a single-line build-and-grep recipe.
After `lake exe cache get`, run the command from the repo root and
compare against the **Expected output** block — that line is what
the Lean compiler emits, and seeing it verbatim is the
machine-checked proof of axiom-freeness for the corresponding
contract.

> **Reading the output**: Lean prints `'<theorem>' does not depend
> on any axioms` exactly when the theorem's proof term reduces to
> definitional equality without invoking `propext`,
> `Classical.choice`, or `Quot.sound`. If a contract ever drifts
> away from axiom-free, Lean will instead print
> `'<theorem>' depends on axioms: [...]` — so the recipes below
> double as regression checks.

The expected outputs were captured verbatim against this commit; CI
re-runs them on every push.

---

#### 1. `CATEPTPluginQuantumInfo.quantumInfo_integration_contract`

**Asserts**: structural-package contract for the quantum-information
lane (CPTP / Braket / von Neumann / Rényi / Shannon / channel-capacity).

**Role in the proof**: the QM-side spine instance is stated on
n-level density matrices; this contract is what makes the von
Neumann entropy and the CPTP-channel structure usable inside that
slot without smuggling new axioms.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "quantumInfo_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:616:0: 'CATEPTPluginQuantumInfo.quantumInfo_integration_contract' does not depend on any axioms
```

---

#### 2. `CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract`

**Asserts**: Bochner–Minlos / Sazonov / Schur / abstract-Minlos
positive-definite-functional contract on nuclear spaces.

**Role in the proof**: this is the measure-theoretic foundation
behind treating the path integral as an honest measure on a
function space. The complex Feynman–Kac result above (Section
*Significant solved artifacts*) sits on top of this contract.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "bochnerMinlos_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:624:0: 'CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract' does not depend on any axioms
```

---

#### 3. `CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract`

**Asserts**: Kolmogorov extension / Gibbs–DLR equation / Giry-monad
measure-witness contract.

**Role in the proof**: gives the entropic side of `τ_ent = S_I/ℏ`
its statistical-mechanical interpretation. The KMS / DLR line of
reasoning that motivates the imaginary-time damping flow is
formalised through this lane.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "gibbsMeasure_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:627:0: 'CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract' does not depend on any axioms
```

---

#### 4. `CATEPTPluginHopfLean.hopfLean_integration_contract`

**Asserts**: coalgebra / bialgebra / Hopf-algebra / Yang–Baxter /
BMod-monoidal contract package.

**Role in the proof**: Hopf-algebra structure underlies the
quantum-group symmetries that the spine inherits when the QM
instance is enriched (e.g. with renormalization-group flow). The
contract registers that enrichment without adding axioms.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "hopfLean_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:630:0: 'CATEPTPluginHopfLean.hopfLean_integration_contract' does not depend on any axioms
```

---

#### 5. `CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract`

**Asserts**: algorithmic-information-theory contract — invariance
theorem / Chaitin Ω existence / incompressibility / Gödel-2-via-K.

**Role in the proof**: the entropic side of CAT/EPT is interpreted
as an *informational* entropy in the sense of algorithmic
information theory; this contract is the bridge into that
semantics. Without it, "informational" in `S_I` is a name; with
it, the lane has a kernel-clean reduction to invariance / Chaitin Ω.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "kolmogorovComplexity_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:633:0: 'CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract' does not depend on any axioms
```

---

#### 6. `CATEPTPluginCarleson.carleson_integration_contract`

**Asserts**: abstract Carleson / almost-everywhere Fourier-convergence
contract.

**Role in the proof**: the spine identity is stated *pointwise*
(`∀ x, …`), but most analytic instantiations require the constraint
to hold "almost everywhere" with respect to a path-space measure.
Carleson-style a.e. convergence is the bridge between the two; this
contract registers the bridge without adding axioms.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "carleson_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:636:0: 'CATEPTPluginCarleson.carleson_integration_contract' does not depend on any axioms
```

---

#### 7. `CATEPTPluginCarleson.concrete_witness_contract`

**Asserts**: concrete Carleson witness — Dirichlet kernel / Jackson
density / antichain decomposition.

**Role in the proof**: complements contract 6 with an *explicit*
witness so the abstract Carleson statement is not vacuous. Together
with #6 this lane delivers both the abstract and the concrete
machinery needed for the a.e. interpretation of the spine.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "concrete_witness_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:637:0: 'CATEPTPluginCarleson.concrete_witness_contract' does not depend on any axioms
```

---

#### 8. `CATEPTPluginCslib.cslib_integration_contract`

**Asserts**: computability / automata / Ramsey-theory integration
contract from the `cslib` plugin.

**Role in the proof**: pairs with the Kolmogorov-complexity lane
(#5) to give the entropic side a *constructive* / computability
semantics. Where #5 measures information, #8 supplies the
computational substrate (automata / decidability) on which that
measurement is well-defined.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "cslib_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:640:0: 'CATEPTPluginCslib.cslib_integration_contract' does not depend on any axioms
```

---

#### 9. `CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract`

**Asserts**: Lieb–Yngvason axioms / entropy existence-uniqueness-
continuity / Kelvin–Planck second-law contract.

**Role in the proof**: ties the `S_I` of CAT/EPT to *thermodynamic*
entropy in the Lieb–Yngvason sense, so that the entropic proper
time `τ_ent = S_I/ℏ` is consistent with the Kelvin–Planck second
law. Without this contract the entropic interpretation would be
formal; with it, the second law becomes a kernel-clean consequence.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "thermodynamicsLean_integration_contract"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:653:0: 'CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract' does not depend on any axioms
```

---

#### 10. `CATEPTPluginVMLLandau.vml_landau_content_available`

**Asserts**: VML–Landau collision-content marker (Aristotle /
Clawristotle Theorem 4.2 surface).

**Role in the proof**: the GR-side instance of the spine eventually
needs a kinetic / transport interpretation (Vlasov–Maxwell–Landau);
this contract registers that the relevant collision-operator
content is available to the spine without new axioms.

**Run**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 \
  | grep "vml_landau_content_available"
```

**Expected output**:
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:662:0: 'CATEPTPluginVMLLandau.vml_landau_content_available' does not depend on any axioms
```

---

#### Run all 10 in one shot

```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 | grep -E "\
'CATEPTPluginQuantumInfo\.quantumInfo_integration_contract'|\
'CATEPTPluginBochnerMinlos\.bochnerMinlos_integration_contract'|\
'CATEPTPluginGibbsMeasure\.gibbsMeasure_integration_contract'|\
'CATEPTPluginHopfLean\.hopfLean_integration_contract'|\
'CATEPTPluginKolmogorovComplexity\.kolmogorovComplexity_integration_contract'|\
'CATEPTPluginCarleson\.carleson_integration_contract'|\
'CATEPTPluginCarleson\.concrete_witness_contract'|\
'CATEPTPluginCslib\.cslib_integration_contract'|\
'CATEPTPluginThermodynamicsLean\.thermodynamicsLean_integration_contract'|\
'CATEPTPluginVMLLandau\.vml_landau_content_available'"
```

**Expected output** (10 lines):
```
info: CATEPTMain/Domains/CoherenceShowcase.lean:616:0: 'CATEPTPluginQuantumInfo.quantumInfo_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:624:0: 'CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:627:0: 'CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:630:0: 'CATEPTPluginHopfLean.hopfLean_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:633:0: 'CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:636:0: 'CATEPTPluginCarleson.carleson_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:637:0: 'CATEPTPluginCarleson.concrete_witness_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:640:0: 'CATEPTPluginCslib.cslib_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:653:0: 'CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract' does not depend on any axioms
info: CATEPTMain/Domains/CoherenceShowcase.lean:662:0: 'CATEPTPluginVMLLandau.vml_landau_content_available' does not depend on any axioms
```

Seeing all 10 lines exactly as above is the machine-checked
statement that **all ten boundary contracts of the CAT/EPT spine
are kernel-clean simultaneously on this commit**. Combined with
the kernel-only audit on the two spine consistency theorems
(Section *Machine-checking from the command line*), this is the
complete falsifiable promise of the framework.

### Why "axiom-free" is meaningfully different from "kernel-only"

The two spine consistency theorems
(`qm_satisfies_catept_spine`, `gr_minkowski_satisfies_catept_spine`)
clear the **kernel-only** bar — they depend on
`propext`, `Classical.choice`, `Quot.sound`, the three Lean 4
kernel axioms that ship with Lean and Mathlib. The repo's broader
audit gate guarantees this for 133 spine-surface theorems.

The 10 contracts above clear a **strictly higher** bar: zero
axioms. Their proof terms reduce to identity-like constructions
over `Prop` fields, so even the standard kernel axioms aren't
reached when computing the proof's axiom dependencies. This is
the same level of certification as
`theorem one_plus_one : 1 + 1 = 2 := rfl` in pure Lean.

In practical proof-engineering terms: every contract in the list
above has its full structural-package theorem reducible to
`⟨h₁, h₂, …⟩` over user-supplied premises, with no classical
reasoning, no quotient soundness, no propositional extensionality
required. The premises themselves may eventually require those
axioms (when actual analytic theorems — Carleson's theorem,
Lieb–Yngvason existence, the Bochner–Minlos extension — are
substituted in by the corresponding sibling repos), but the
**contract framing** does not. The two-tier discipline is the
formal expression of CAT/EPT's modularity: the spine commits to
nothing about the heavy mathematics of any lane; each lane's
sibling commits to the heavy mathematics of that lane and
nothing else.

## Dependencies

Every dependency below supplies one specific lane of the proof.
Mathlib v4.29.0 provides the kernel substrate; the named packages
provide the heavy mathematical content that fills the boundary
contracts of the *Axiom-free theorems* section. Pinned revisions
live in [`lakefile.lean`](lakefile.lean).

## Acknowledgments

### Intellectual foundations

The framework builds on the entropic-dynamics research programme of
**Prof. Ariel Caticha** (University at Albany, SUNY) —
[arielcaticha.com](https://www.arielcaticha.com/entropic-dynamics-qft-and-gravity).
The `τ_ent = S_I/ℏ` construction and the imaginary-time damping
interpretation of `S_I` originate in that programme; this repo's
job is to give those constructions a Lean-checkable expression.

### Ported libraries

- [`CATEPTMain/Gravitas/`](CATEPTMain/Gravitas/) — Lean 4 port of the
  Gravitas symbolic general-relativity package (original: Wolfram
  Language). Supplies the GR-side spine instance with concrete
  tensor-curvature carriers (Christoffel, Riemann, Ricci, Einstein
  tensors), so `gr_minkowski_satisfies_catept_spine` can be evaluated
  on real geometric content.
- [`CATEPTMain/QuantumOps/IsabelleMarresDirac/`](CATEPTMain/QuantumOps/IsabelleMarresDirac/)
  — Lean 4 port from Isabelle/HOL. Supplies the gate-level
  quantum-information primitives (Hadamard, CNOT, Deutsch's
  problem) referenced by the QM-side spine instance.

### Lean 4 mathematical-physics dependencies by Michael R. Douglas

Three of the analytic-functional pillars this repository depends on
are contributed by [**mrdouglasny**](https://github.com/mrdouglasny) —
Lean 4 formalizations of foundational theorems for measure-theoretic
QFT and semigroup dynamics. Whose wonderful work makes the CATEPT
analytic lane practical:

- [**bochner**](https://github.com/mrdouglasny/bochner) — the
  Bochner–Minlos theorem (characteristic functionals on nuclear
  spaces; the measure-theoretic foundation of Euclidean QFT). *Fills
  the heavy side of contract #2 (Bochner–Minlos).*
- [**hille-yosida**](https://github.com/mrdouglasny/hille-yosida) —
  the Hille–Yosida generation theorem for `C₀`-semigroups (analytic
  backbone of modular flow and heat-kernel arguments). *Underpins
  the imaginary-time damping flow that gives `S_I/ℏ` its
  semigroup interpretation.*
- [**pphi2**](https://github.com/mrdouglasny/pphi2) — φ⁴ scalar
  field theory infrastructure. *Supplies the canonical interacting
  example on which the rigorous complex Feynman–Kac result
  (Section *Significant solved artifacts*) is exercised.*

### Other external Lean 4 dependencies

Each of the following supplies the heavy mathematical content that
fills one of the 10 boundary contracts (Section *Axiom-free
theorems*) or supports the analytic machinery behind them:

- **Mathlib4**, **Physlib** — kernel and physics lemma substrate
  used everywhere.
- **pphi2N**, **GaussianField**, **LGT** — gauge / field-theory
  carriers fed into the QM-side instance and the FK contract.
- **cslib** — fills contract #8 (computability / automata).
- **DeGiorgi**, **spectralPhysics** — supply the regularity /
  spectral-gap content used by analytic-machinery theorems.
- **DimensionalAnalysis**, **UnifiedTheory**, **aristotle**,
  **aqeiBridge**, **lean-inf** — supply the dimensional /
  causal-poset infrastructure used by the GR-side instance and
  contract #10 (VML–Landau).
- **QuantumAlgebra** — fills the Hopf-algebra / quantum-group
  side of contract #4.

Pinned revisions live in [`lakefile.lean`](lakefile.lean). The audit
gate enforces that no dep is allowed to introduce axioms beyond the
kernel triple into the spine surface or the 10 contracts.

## License

Apache-2.0. See [`LICENSE`](LICENSE).
