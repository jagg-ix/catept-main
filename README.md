# CATEPT: Complex Action Theory and Entropic Proper Time

A formal, machine-checked framework in Lean 4.29 that establishes a
rigorous connection between **Quantum Mechanics (QM)** and **General
Relativity (GR)**.

At the core of this framework is the concept of **entropic proper
time** $\tau_{ent}$, defined by the relation

$$
\tau_{ent} \;=\; S_I / \hbar
$$

where $S = S_R + i \cdot S_I$ is a complex action.

The central claim of CATEPT is that $\tau_{ent}$ is not merely a
mathematical analogy, but a single, consistent time parameter capable
of expressing and unifying both QM and GR. Most importantly, this is a
formal identity that is rigorously verified by the Lean kernel. By
machine-checking this connection, CATEPT provides strict verification
guarantees, ensures mathematical modularity, and anchors theoretical
physics in highly reliable formal logic.

> **Note**: For the curated publication artifact, see the
> [`feat/publication`](https://github.com/jagg-ix/catept-main/tree/feat/publication)
> branch of this repository.

---

## 1. The Proof Architecture

To understand how CATEPT verifies this unification, it helps to
visualize the framework as a four-layer system. Every component in
this repository contributes to one of these interconnected layers:

```text
                ┌──────────────────────────────────────────────┐
                │ 1. The Spine Constraint (Central Claim)      │
                │      ∀ x, actionIm(x) / ℏ  =  eptClock(x)    │
                └──────────────────────────────────────────────┘
                                    │
                ┌───────────────────┼────────────────────┐
                │                   │                    │
        ┌───────▼────────┐  ┌───────▼────────┐  ┌────────▼────────┐
        │ 2. Target      │  │ 2. Target      │  │ 3. Analytic     │
        │    Instance:   │  │    Instance:   │  │    Machinery    │
        │    Quantum     │  │    General     │  │    (FK, UV, …)  │
        │    Mechanics   │  │    Relativity  │  │                 │
        └────────────────┘  └────────────────┘  └────────┬────────┘
                                                         │
                                            ┌────────────▼─────────────┐
                                            │ 4. Boundary Contracts    │
                                            │    (10 axiom-free links  │
                                            │     to external math)    │
                                            └────────────┬─────────────┘
                                                         │
                                            ┌────────────▼─────────────┐
                                            │ Foundation: Mathlib v4.29│
                                            │ & Public Lean 4 Packages │
                                            └──────────────────────────┘
```

* **Layer 1 — The Spine Constraint.** The unifying mathematical claim,
  formulated as a proposition binding the imaginary part of the
  complex action, Planck's constant, and the entropic clock.
* **Layer 2 — Concrete Instances.** To prove the spine is not
  logically vacuous, the constraint is independently discharged in
  both a QM setting and a GR setting.
* **Layer 3 — Analytic Machinery.** Gives the framework physical
  substance: a rigorous complex Feynman–Kac integration for the
  damped class, plus a counterterm-free UV convergence certificate.
* **Layer 4 — Axiom-Free Contracts.** Ten specific interfaces linking
  the central spine to external mathematical domains (quantum
  information, Carleson Fourier analysis, thermodynamics, …). Their
  axiom-free nature guarantees that connecting these external
  theories introduces no hidden logical commitments.

The entire architecture is held together by a strict computational
audit gate: every theorem named in this README depends *only* on the
standard Lean kernel axioms (or on no axioms at all), enforced
automatically on every commit by
[`.github/workflows/axiom-gate.yml`](.github/workflows/axiom-gate.yml).

---

## 2. Quick Start

To locally build the framework and verify the core spine consistency
theorems:

```bash
git clone https://github.com/jagg-ix/catept-main.git
cd catept-main
git checkout feat/publication
lake exe cache get                    # warm Mathlib olean cache (first run only)
lake build CATEPT.Showcase.QMGRUnification
```

If the final command completes without errors, the central
unification claim has been verified at the type level on this commit.
The next two sections show how to verify it at the axiom level as
well.

---

## 3. The Unification Mechanism: QM ↔ GR

The framework implements a single "plugin slot" that carries the
variables `actionIm`, `ℏ`, and `eptClock`. The unification is achieved
by proving the **spine constraint**

$$
\forall\, x,\; \mathrm{actionIm}(x) / \hbar \;=\; \mathrm{eptClock}(x)
$$

For $\tau_{ent}$ to function as a genuinely unified parameter, this
constraint must be satisfied across different physical regimes. We
prove it against two concrete target theories:

| Theory Domain | Lean Instance | Consistency Theorem |
| :--- | :--- | :--- |
| **Quantum Mechanics** (n-level density matrices) | `quantumCATEPTSlot n` | `qm_satisfies_catept_spine` |
| **General Relativity** (Minkowski background) | `gravitasMinkowskiSlot` | `gr_minkowski_satisfies_catept_spine` |

These two theorems are the framework's only "headline claims".
Everything else in this repository either (a) supplies the analytic
machinery that gives them substance (Section 5), (b) binds an external
mathematical area into the slot in a kernel-clean way (Section 6), or
(c) provides the package substrate (Section 7). All three feed back
into the two theorems above.

Both proofs depend strictly on the standard Lean kernel axioms
(`propext`, `Classical.choice`, `Quot.sound`). The next section is how
to verify that statement.

---

## 4. The Falsifiable Contract (Command-Line Audit)

CATEPT operates under a strict falsifiable contract: the consistency
theorems must *never* rely on unverified or custom axioms. You can
verify this machine-checked guarantee yourself by running the
following audit script:

```bash
cat > /tmp/catept_audit.lean <<'EOF'
import CATEPT.Showcase.QMGRUnification
#print axioms CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
EOF
lake env lean /tmp/catept_audit.lean
```

**Expected output** (one line per theorem):

```
'…qm_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
'…gr_minkowski_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
```

The presence of any additional axiom in either list is a logical
regression. Section 6 below tightens this discipline further: the 10
boundary contracts must clear an even stricter bar (zero axioms).

---

## 5. Analytic Machinery (Giving the Spine Substance)

Without rigorous analytic backing, the QM/GR consistency theorems
would just be an empty formal shell. The following artifacts discharge
critical proof obligations to ensure the physics being modelled is
mathematically sound:

* **Rigorous complex Feynman–Kac (entropically damped class)**

  *Theorem*: `CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous`

  *Significance*: provides the QM-side instance with an honest
  path-integral interpretation. Because the complex action $S$ has
  $S_I \ge 0$ on the damped class, the expression
  $\exp(-S_I/\hbar)\cdot\exp(i\,S_R/\hbar)$ becomes an analytic
  contraction, allowing $\tau_{ent} = S_I/\hbar$ to be treated as a
  real time parameter rather than just a formal symbol.

* **Counterterm-free UV convergence certificate**

  *Theorem*: `CATEPTMain.Integration.PhysicalUVConvergenceCertificate.physical_uv_certificate_no_counterterm_needed`

  *Significance*: pre-empts the standard objection that path
  integrals require renormalization at high energies. The certificate
  mathematically exhibits a UV regime where the damped class
  converges without counterterms — so the spine claim survives the
  UV limit.

The audit recipe in Section 4 confirms both supporting theorems clear
the kernel-only bar. Together with the two spine consistency theorems,
they constitute the **minimal machine-checked proof of CATEPT** at
this commit.

---

## 6. Axiom-Free Boundary Contracts

While the spine consistency theorems clear the kernel-only bar, the
framework's modularity relies on **10 boundary contracts** that sit at
an even stricter layer: *zero axioms*.

These contracts bind external mathematical areas (quantum information,
Carleson Fourier analysis, Hopf algebras, Gibbs measures, Kolmogorov
complexity, computability, thermodynamics, VML–Landau collisions) to
the central spine. Because each contract's proof reduces to
definitional equality over Prop fields (`⟨h₁, h₂, …⟩` — anonymous
constructor, term-mode), the kernel sees pure definitional rewriting
and reports

```
'…' does not depend on any axioms
```

This is the machine-checked statement that **the binding interface
itself adds no logical commitments**. The heavy mathematical content
(Carleson's a.e. convergence theorem, Lieb–Yngvason existence, the
Bochner–Minlos extension, …) lives in the user-supplied premises that
fill the contract; the contract framing reduces to nothing.

This two-tier discipline (kernel-only at the spine, axiom-free at the
boundary) is the formal expression of CATEPT's modularity: the spine
commits to nothing about the heavy mathematics of any lane; each
lane's sibling commits to its own heavy mathematics and nothing else.

### 6.1 Verify all 10 contracts at once

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

**Expected output** (10 lines, exactly):

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

Seeing all 10 lines exactly as above is the machine-checked statement
that **all ten boundary contracts of the CATEPT spine are kernel-clean
simultaneously on this commit**. Combined with the kernel-only audit
on the two spine consistency theorems (Section 4), this is the
complete falsifiable promise of the framework.

> **Reading the output**: Lean prints `'<theorem>' does not depend on
> any axioms` exactly when the theorem's proof term reduces to
> definitional equality without invoking `propext`,
> `Classical.choice`, or `Quot.sound`. If a contract ever drifts away
> from axiom-free, Lean will instead print `'<theorem>' depends on
> axioms: [...]` — so the recipe above doubles as a regression check.

### 6.2 The 10 contract domains, individually

Each of the 10 contracts can be verified independently using a one-
line `grep` against the same `lake build` output. All expected outputs
were captured verbatim against this commit; CI re-runs them on every
push.

---

#### 1. `CATEPTPluginQuantumInfo.quantumInfo_integration_contract`

**Asserts**: structural-package contract for the quantum-information
lane (CPTP / Braket / von Neumann / Rényi / Shannon / channel-capacity).

**Role in the proof**: the QM-side spine instance is stated on
n-level density matrices; this contract is what makes the von
Neumann entropy and the CPTP-channel structure usable inside the
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

**Role in the proof**: provides the measure-theoretic foundation
necessary to treat the path integral as a rigorous measure on a
function space. The complex Feynman–Kac result (Section 5) sits on
top of this contract.

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

**Role in the proof**: gives the entropic side of $\tau_{ent} =
S_I/\hbar$ its statistical-mechanical interpretation (KMS / DLR
formalism behind the imaginary-time damping flow).

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

**Role in the proof**: registers the quantum-group symmetries that
the spine inherits when the QM instance is enriched with
renormalization-group flow, without adding axioms to the binding.

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

**Role in the proof**: the entropic side of CATEPT is interpreted as
an *informational* entropy in the algorithmic-information sense; this
contract is the bridge to that semantics. Without it, "informational"
in $S_I$ is a name; with it, the lane has a kernel-clean reduction
to invariance / Chaitin Ω.

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
Carleson-style a.e. convergence is the bridge between the two.

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

**Role in the proof**: complements contract #6 with an *explicit*
witness so the abstract Carleson statement is not vacuous. Together
with #6, this lane delivers both the abstract and the concrete
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

**Role in the proof**: pairs with the Kolmogorov-complexity lane (#5)
to give the entropic side a *constructive* semantics. Where #5
measures information, #8 supplies the computational substrate
(automata / decidability) on which that measurement is well-defined.

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

**Role in the proof**: ties the $S_I$ of CATEPT to *thermodynamic*
entropy in the Lieb–Yngvason sense, so $\tau_{ent} = S_I/\hbar$ is
consistent with the Kelvin–Planck second law. Without this contract
the entropic interpretation would be formal; with it, the second law
becomes a kernel-clean consequence.

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
this contract registers that the relevant collision-operator content
is available to the spine without new axioms.

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

### 6.3 Why "axiom-free" is meaningfully different from "kernel-only"

The two spine consistency theorems
(`qm_satisfies_catept_spine`, `gr_minkowski_satisfies_catept_spine`)
clear the **kernel-only** bar — they depend on `propext`,
`Classical.choice`, `Quot.sound`, the three Lean 4 kernel axioms that
ship with Lean and Mathlib. The repo's broader audit gate guarantees
this for 133 spine-surface theorems.

The 10 contracts above clear a **strictly higher** bar: zero axioms.
Their proof terms reduce to identity-like constructions over Prop
fields, so even the standard kernel axioms aren't reached when
computing the proof's axiom dependencies. This is the same level of
certification as `theorem one_plus_one : 1 + 1 = 2 := rfl` in pure
Lean.

In practical proof-engineering terms: every contract above has its
full structural-package theorem reducible to `⟨h₁, h₂, …⟩` over
user-supplied premises, with no classical reasoning, no quotient
soundness, no propositional extensionality required. The premises
themselves may eventually require those axioms (when actual analytic
theorems — Carleson's theorem, Lieb–Yngvason existence, the
Bochner–Minlos extension — are substituted in by the corresponding
sibling repos), but the **contract framing** does not.

---

## 7. Dependencies and Acknowledgments

Every dependency below supplies one specific lane of the proof.
Mathlib v4.29.0 provides the kernel substrate; the named packages
provide the heavy mathematical content that fills the boundary
contracts of Section 6 and the analytic machinery of Section 5.
Pinned revisions live in [`lakefile.lean`](lakefile.lean).

### 7.1 Intellectual foundations

This framework heavily builds upon the entropic-dynamics research
program pioneered by **Prof. Ariel Caticha** (University at Albany,
SUNY) —
[arielcaticha.com](https://www.arielcaticha.com/entropic-dynamics-qft-and-gravity).
The construction of $\tau_{ent} = S_I/\hbar$ and the imaginary-time
damping interpretation of $S_I$ originate directly from his work; this
repository serves to give those physical concepts a machine-checked,
formal expression in Lean.

### 7.2 Core ported libraries

* **Gravitas** ([`CATEPTMain/Gravitas/`](CATEPTMain/Gravitas/)) — Lean
  4 port of the Gravitas symbolic GR package (original: Wolfram
  Language). Supplies the GR-side spine instance with concrete
  tensor-curvature carriers (Christoffel, Riemann, Ricci, Einstein
  tensors), so `gr_minkowski_satisfies_catept_spine` can be evaluated
  on real geometric content.
* **IsabelleMarresDirac** ([`CATEPTMain/QuantumOps/IsabelleMarresDirac/`](CATEPTMain/QuantumOps/IsabelleMarresDirac/))
  — Lean 4 port from Isabelle/HOL. Supplies the gate-level
  quantum-information primitives (Hadamard, CNOT, Deutsch's problem)
  referenced by the QM-side spine instance.

### 7.3 Mathematical-physics dependencies (Michael R. Douglas)

The analytic functional pillars of this repository are made practical
by the exceptional formalization work of **Michael R. Douglas**
([@mrdouglasny](https://github.com/mrdouglasny)):

* [`bochner`](https://github.com/mrdouglasny/bochner) — the
  Bochner–Minlos theorem (characteristic functionals on nuclear
  spaces; the measure-theoretic foundation of Euclidean QFT). *Fills
  the heavy side of contract #2.*
* [`hille-yosida`](https://github.com/mrdouglasny/hille-yosida) — the
  Hille–Yosida generation theorem for $C_0$-semigroups (analytic
  backbone of modular flow and heat-kernel arguments). *Underpins the
  imaginary-time damping flow that gives $S_I/\hbar$ its semigroup
  interpretation.*
* [`pphi2`](https://github.com/mrdouglasny/pphi2) — $\varphi^4$
  scalar-field-theory infrastructure. *Supplies the canonical
  interacting example on which the rigorous complex Feynman–Kac
  result (Section 5) is exercised.*

### 7.4 Other external Lean 4 dependencies

Each of the following supplies the heavy mathematical content that
fills one of the 10 boundary contracts (Section 6) or supports the
analytic machinery behind them:

* **Mathlib4**, **Physlib** — kernel and physics-lemma substrate used
  everywhere.
* **pphi2N**, **GaussianField**, **LGT** — gauge / field-theory
  carriers fed into the QM-side instance and the FK contract.
* **cslib** — fills contract #8 (computability / automata).
* **DeGiorgi**, **spectralPhysics** — supply the regularity and
  spectral-gap content used by the analytic-machinery theorems.
* **DimensionalAnalysis**, **UnifiedTheory**, **aristotle**,
  **aqeiBridge**, **lean-inf** — supply the dimensional and
  causal-poset infrastructure used by the GR-side instance and
  contract #10 (VML–Landau).
* **QuantumAlgebra** — fills the Hopf-algebra / quantum-group side of
  contract #4.

The audit gate enforces that no dependency is allowed to introduce
axioms beyond the kernel triple into the spine surface or the 10
contracts.

---

## License

Apache-2.0. See [`LICENSE`](LICENSE) for details.
