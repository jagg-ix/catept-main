# CATEPT — Complex Action Theory and Entropic Proper Time

A Lean 4.29 formalization of the **Complex Action Theory and Entropic Proper
Time (CAT/EPT)** framework: a machine-checked connection between **Quantum
Mechanics** and **General Relativity** via **entropic proper time**
`τ_ent = S_I / ℏ`.

> For the curated publication artifact, see the
> [`feat/publication`](https://github.com/jagg-ix/catept-main/tree/feat/publication)
> branch of this repository.

## Interactive simulations (calculations) + proof lookup

This repository is the **Lean4 proof spine** for CAT/EPT. For an interactive view that pairs:

- equation statements + proof status, and
- runnable calculations / simulations that compute the same quantities,

use the companion dashboard site (deployed from the `entropic-time` repo):

- `https://jagg-ix.github.io/entropic-time/#/equations`
- `https://jagg-ix.github.io/entropic-time/#/simulations`

How to use it with this repo:

1. Open `#/simulations`, run a simulation, and note the equation IDs shown on the simulation card.
2. Open `#/equations` for those same equation IDs to see the proof/contract status.
3. Use the theorem/contract links (or the IDs) to jump into the corresponding Lean modules here.

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

These are designed to line up with the dashboard’s equation IDs and simulation cards so the
numerical calculations can be used to sanity-check constants and margins while the Lean proof
objects remain the ground truth for the statements.

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

### How to test the axiom-free claim

Single command, copy-paste from this README:

```bash
cat > /tmp/catept_axiom_free.lean <<'EOF'
import CATEPTMain.Domains.CoherenceShowcase

#print axioms CATEPTPluginQuantumInfo.quantumInfo_integration_contract
#print axioms CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract
#print axioms CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract
#print axioms CATEPTPluginHopfLean.hopfLean_integration_contract
#print axioms CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract
#print axioms CATEPTPluginCarleson.carleson_integration_contract
#print axioms CATEPTPluginCarleson.concrete_witness_contract
#print axioms CATEPTPluginCslib.cslib_integration_contract
#print axioms CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract
#print axioms CATEPTPluginVMLLandau.vml_landau_content_available
EOF

lake env lean /tmp/catept_axiom_free.lean
```

Expected output — **10 lines**, each ending in
`does not depend on any axioms`:

```
'CATEPTPluginQuantumInfo.quantumInfo_integration_contract' does not depend on any axioms
'CATEPTPluginBochnerMinlos.bochnerMinlos_integration_contract' does not depend on any axioms
'CATEPTPluginGibbsMeasure.gibbsMeasure_integration_contract' does not depend on any axioms
'CATEPTPluginHopfLean.hopfLean_integration_contract' does not depend on any axioms
'CATEPTPluginKolmogorovComplexity.kolmogorovComplexity_integration_contract' does not depend on any axioms
'CATEPTPluginCarleson.carleson_integration_contract' does not depend on any axioms
'CATEPTPluginCarleson.concrete_witness_contract' does not depend on any axioms
'CATEPTPluginCslib.cslib_integration_contract' does not depend on any axioms
'CATEPTPluginThermodynamicsLean.thermodynamicsLean_integration_contract' does not depend on any axioms
'CATEPTPluginVMLLandau.vml_landau_content_available' does not depend on any axioms
```

If any line instead reads `depends on axioms: [...]`, that theorem
has slipped from axiom-free to axiom-using and should be investigated
(usually because a Prop field changed shape and now requires
`propext` / `Classical.choice` to discharge).

A scripted sanity check, equivalent to the above, that exits non-zero
if any of the 10 fails the axiom-free test:

```bash
EXPECTED=10
GOT=$(lake env lean /tmp/catept_axiom_free.lean 2>&1 \
  | grep -c "does not depend on any axioms")
echo "axiom-free theorems found: $GOT / $EXPECTED"
[ "$GOT" -eq "$EXPECTED" ] || { echo "REGRESSION"; exit 1; }
echo "OK"
```

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
| [`jagg-ix/catept-plugin-gaussian-field-lsi`](https://github.com/jagg-ix/catept-plugin-gaussian-field-lsi) | `3783875a` | Gaussian-field Gross LSI / spectral-gap / second-moment integration contract |
| [`jagg-ix/catept-plugin-spectral-physics`](https://github.com/jagg-ix/catept-plugin-spectral-physics) | `95b216bf` | Spectral-physics integration contract (gap/Rayleigh/heat semigroup/Bakry-Émery) |
| [`jagg-ix/catept-plugin-degiorgi`](https://github.com/jagg-ix/catept-plugin-degiorgi) | `5b06dc82` | De Giorgi-Nash-Moser regularity (GNS, Poincaré, Sobolev-Poincaré, Harnack, Hölder-Moser, Lax-Milgram) |
| [`jagg-ix/catept-plugin-maxwell-curvespace-pphi2`](https://github.com/jagg-ix/catept-plugin-maxwell-curvespace-pphi2) | `be3d80bd` | Maxwell-curved-space ↔ pphi2 OS-reconstruction integration contract |
| [`jagg-ix/catept-plugin-vml-landau`](https://github.com/jagg-ix/catept-plugin-vml-landau) | `7ef1b4b0` | Vlasov-Maxwell-Landau steady-state rigidity (Aristotle/Clawristotle Theorem 4.2) |
| [`jagg-ix/catept-plugin-bochner-minlos`](https://github.com/jagg-ix/catept-plugin-bochner-minlos) | `dae9f683` | Bochner-Minlos integration bridge (PD characteristic functions, Sazonov, Schur, abstract Minlos) |
| [`jagg-ix/catept-plugin-carleson`](https://github.com/jagg-ix/catept-plugin-carleson) | `684eeb46` | Carleson integration bridge (a.e. Fourier convergence, maximal-operator bound, Dirichlet, Jackson, antichain) |
| [`jagg-ix/catept-plugin-gibbs-measure`](https://github.com/jagg-ix/catept-plugin-gibbs-measure) | `6b0c701b` | Gibbs-measure integration bridge (Kolmogorov extension, Gibbs-DLR, Giry monad witness) |
| [`jagg-ix/catept-plugin-hopf-lean`](https://github.com/jagg-ix/catept-plugin-hopf-lean) | `6236741e` | Hopf-algebra integration bridge (coalgebra/bialgebra/Hopf/Yang-Baxter/BMod-monoidal witness) |
| [`jagg-ix/catept-plugin-kolmogorov-complexity`](https://github.com/jagg-ix/catept-plugin-kolmogorov-complexity) | `b29f32d9` | Kolmogorov-complexity integration bridge (AIT invariance, Chaitin Ω, incompressibility, Gödel-2 via K) |
| [`jagg-ix/catept-plugin-thermodynamics-lean`](https://github.com/jagg-ix/catept-plugin-thermodynamics-lean) | `9a97fce7` | Lieb-Yngvason thermodynamics integration bridge (LY axioms, entropy existence/uniqueness/continuity, Kelvin-Planck) |
| [`jagg-ix/catept-plugin-bt-compat`](https://github.com/jagg-ix/catept-plugin-bt-compat) | `02918aec` | Bridge Theory compatibility (Auci EM↔Relativity: BT Eqs 1-3,6,14-20 + Doppler/Lorentz invariants) — **first extraction from CAT/EPT core, not Integration/** |

Authoritative pin SHAs live in [`lake-manifest.json`](lake-manifest.json).
Existing consumers reach the sibling theorems through thin re-export
shims under `CATEPTMain/Integration/` so source-level imports do not
need to change.

For the rationale, the playbook for adding a new sibling, and the
pin-bump workflow, see
[`docs/architecture/plugin-split.md`](docs/architecture/plugin-split.md).

## Architectural reference docs

For helpers and future agents, two docs in `docs/architecture/`
encode the structural state of the spine:

- [`catept-spine-to-ns-axiom-discharge.md`](docs/architecture/catept-spine-to-ns-axiom-discharge.md)
  — maps the CAT/EPT spine to the Navier–Stokes Millennium axiom
  `ns_periodic_smooth_solution_exists`. Distinguishes formal-equivalence
  layers (machine-checked) from the open analytic content (still
  Mathlib-gap-bound). Read before claiming any spine theorem
  "discharges NS."
- [`equation-spine-review-20260430.md`](docs/architecture/equation-spine-review-20260430.md)
  — status table for advisor-extracted equations: which are
  implemented, which are deferred (Mathlib gaps), which are
  do-not-load-bear (speculative). Records the **canonical
  layer-naming convention** that prevents drift between
  *imaginary-action accumulation*, *entropic proper time*, and
  *KMS / modular flow parameter* — three distinct named objects
  that should never be conflated.

## Bridge modules at the structural / no-renormalization seam

`CATEPTMain/Integration/` contains the structural bridge stack that
sits between the CAT/EPT spine and downstream domains. The current
end-to-end chain at the multimode finite-cutoff level:

```text
heatMode (T-S Phase 1)
  → ∫heat = entropicProperTime a       (EntropicGreenFromHeatSemigroup)
  → exp(−τ) ∈ (0,1]                     (GreenDampingUVChain)
  → ∏ exp(−τ_k) ∈ (0,1]                (GreenDampingUVChainMultimode)
  → MeasurePathIntegralModel.damping
  → complex_FK_rigorous                 (RigorousComplexFeynmanKac)
  → no_counterterm_needed               (PhysicalUVConvergenceCertificate)
```

State-dependent τ + advisor-extracted physics layers:
- `EntropicTimeIntegralStateDependent` — τ(t) = ∫₀ᵗ rate(σ) dσ with full clock-property suite (init, constant-rate ↔ CFLClock, non-negativity, monotonicity, linearity).
- `ImaginaryActionDissipationDictionary` — `β̃_I = ℏ · γ_I` with three distinct named layers (no "information time").
- `FisherLawvereEventCostBridge` — Lawvere event cost + Fisher rate carrier + KL local quadratic contract.
- `TolmanDissipationRedshiftBridge` — `γ_I^∞ = N · γ_I^loc` under entropic lapse.
- `KMSModularParameterBridge` — `Δs_KMS = 1/γ_I` rigorously separate from entropic proper time.
- `RelativeEntropyProductionBridge` — `S_rel` monotone-decreasing carrier.
- `GKSLInformationExchangeBridge` — Lindblad scalar carrier `H_eff = H_R − iℏγ_I V`, `L_V = √(2γ_I V)`.

NS-side specialisation:
- `NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge` — relative-entropy analog `Ω/(2ν)`, defect form `D_I = νP − VS`, monotonicity criterion `dS_rel/dt ≤ 0 ↔ VS ≤ νP`.

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
