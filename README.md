# CATEPT Main — Lean 4 Formal Verification Hub

A Lean 4.29 integration repository for the **Causal-Algebraic Thermodynamic Entropic Proper Time (CATEPT)** framework, connecting Navier-Stokes regularity, quantum information theory, general relativity tensors, Yang-Mills mass gap, and entropic proper time into a unified formal verification surface.

## Architecture & Implementation Overview

Based on the `catept-core` design, this repository connects into a highly modular, rigorously verified, dual-layer architecture built in Lean 4. The primary design goal is to maintain a **"Zero-Axiom" mathematical spine** for the CAT/EPT framework, allowing distinct physical theories to plug in without compromising mathematical safety.

### The Microkernel Architecture
The system operates on a microkernel pattern tailored for formal verification:
- **`CATEPTCore` (The Foundation):** The innermost kernel containing pure, decidable mathematical limits (e.g. `imaginaryNoetherDefect`, `entropicRate`). It serves as the immutable ground truth using concrete rational types (`Rat`) to ensure structural stability over floating-point approximations.
- **Zero-Axiom Policy:** The architecture enforces that system invariants are mathematically proven. Core properties, such as `entropicTime_nonneg` or the mapping of vortex stretching to palinstrophy (`noBlowup_iff_defect_nonneg`), are strictly implemented as proven `theorem`s, rejecting unprovable assertions.
  
  *Example:*
  ```lean
  /-- Algebraic equivalence: VS ≤ nu*P iff the defect D_I is nonnegative. -/
  theorem noBlowup_iff_defect_nonneg
      (nu palinstrophy vortexStretching : Rat) :
      noBlowupCondition nu palinstrophy vortexStretching ↔
        0 ≤ imaginaryNoetherDefect nu palinstrophy vortexStretching := by
    simp [noBlowupCondition, imaginaryNoetherDefect, sub_nonneg]
  ```

### The Abstraction & Bridge Layer (`CATEPT`)
This layer maps physical concepts (measurable spaces, path integrals, modular flows) via strict structural contracts regarding measure theory, translating physical phase spaces into rigorous Lean constraints.

### Dynamic Plugin Architecture
To enable safe downstream extensions across disparate fields (fluid dynamics, quantum gravity, statistical mechanics), the system uses a formal Plugin Interface:
- **`PluginSpec`**: Defines the minimal variables a physical theory must provide (e.g., `eptClock`, `pathModel`, `measurableState`).
- **`cateptConsistencyConstraint`**: Ensures the imported theory's logic aligns with CAT/EPT constraints.
- **`PluginMeasureCertificate`**: Requires plugins to actively supply mathematical proofs (e.g., integrability bounds). The Lean compiler will reject the plugin if bounds cannot be proven finite.

  *Example:*
  ```lean
  /-- A valid plugin must mathematically prove it adheres to the core contract. -/
  structure PluginMeasureCertificate (spec : PluginSpec) where
    integrability_bound : MeasureTheory.Integrable spec.pathModel
    consistency_proof : cateptConsistencyConstraint spec
  ```

## Quick Start

```bash
git clone https://github.com/jagg-ix/catept-main.git
cd catept-main
lake exe cache get   # warm Mathlib olean cache (~10 min first run)
lake build CATEPTMain
```

## Reviewer-facing showcase — Quantum Mechanics ↔ General Relativity via entropic proper time

The file [`CATEPT/Showcase/QMGRUnification.lean`](CATEPT/Showcase/QMGRUnification.lean)
is the single machine-checkable artifact demonstrating that **CAT/EPT
admits Quantum Mechanics and General Relativity as instances of one
plugin architecture**, unified by `τ_ent = S_I / ℏ` as the shared clock.

### What it proves

Both theories supply a `CATEPTPluginSlot` (abstract carrier of
`actionRe`, `actionIm`, `ℏ`, `eptClock`) and a proof that the
universal constraint

```
cateptConsistencyConstraint slot  ≡  ∀ x, actionIm(x) / ℏ = eptClock(x)
```

holds on their slot:

| Theory | Instance | Spine theorem |
|---|---|---|
| Quantum Mechanics (n-level density matrices) | `quantumCATEPTSlot n` | `qm_satisfies_catept_spine` |
| General Relativity (Minkowski background) | `gravitasMinkowskiSlot` | `gr_minkowski_satisfies_catept_spine` |
| General Relativity (full electrovacuum plugin) | `gravitasElectrovacuumPlugin` | `gr_electrovacuum_satisfies_catept_spine` |
| **Unification headline** | — | `qm_gr_unified_via_entropic_proper_time` |

Every theorem depends on only the Lean kernel axioms — no framework
axioms, no sorries, no physical-identification axioms.

Scope disclaimer: this is a **compatibility demonstration** — the same
abstract constraint is proved in both domains. It is *not* a proof that
QM and GR are physically equivalent.

### Running the showcase from the command line

Three steps. From the repo root after `lake exe cache get`:

**1. Build the showcase:**
```bash
lake build CATEPT.Showcase.QMGRUnification
```
Expected: `Build completed successfully (... jobs).`

**2. Machine-check the unification claim (axiom audit):**
```bash
cat > /tmp/catept_showcase.lean <<'EOF'
import CATEPT.Showcase.QMGRUnification
#print axioms CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_electrovacuum_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.qm_gr_unified_via_entropic_proper_time
EOF
lake env lean /tmp/catept_showcase.lean
```
Expected output (each of the four lines):
```
'…qm_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
'…gr_minkowski_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
'…gr_electrovacuum_satisfies_catept_spine' depends on axioms: [propext, Classical.choice, Quot.sound]
'…qm_gr_unified_via_entropic_proper_time' depends on axioms: [propext, Classical.choice, Quot.sound]
```
Any other axiom appearing in the list is a regression and must be reviewed.

**3. (Optional) Inspect type signatures to confirm the universal carrier:**
```bash
cat > /tmp/catept_showcase_types.lean <<'EOF'
import CATEPT.Showcase.QMGRUnification
open CATEPT.Showcase.QMGRUnification
open CATEPTMain.Integration
#check @qm_satisfies_catept_spine
#check @gr_minkowski_satisfies_catept_spine
#check @qm_gr_unified_via_entropic_proper_time
-- All three use the same predicate `cateptConsistencyConstraint`
-- applied to their respective CATEPTPluginSlot instances.
EOF
lake env lean /tmp/catept_showcase_types.lean
```

### Pointer to the plugin architecture

The universal slot and constraint live in
[`CATEPTMain/Integration/TheoryPluginArchitecture.lean`](CATEPTMain/Integration/TheoryPluginArchitecture.lean).
The QM and GR plugin instances live in
[`CATEPTMain/Integration/QuantumCATEPTBridge.lean`](CATEPTMain/Integration/QuantumCATEPTBridge.lean)
and
[`CATEPTMain/Integration/GravitasBridge.lean`](CATEPTMain/Integration/GravitasBridge.lean).
To add a new domain as a third instance, supply a `CATEPTPluginSlot`
(or a full `TheoryPlugin`) and prove `cateptConsistencyConstraint`
for it.

## Entry Points

Verified on 2026-04-22.

| Surface | Lake target | Build command | Status | What it gives you |
|---------|-------------|---------------|--------|--------------------|
| Full integration hub | `CATEPTMain` | `lake build CATEPTMain` | Pass* | All bridges, NS, QM, GR, YM, EPT |
| Bridge aggregator | `CATEPTMain.Bridges` | `lake build CATEPTMain.Bridges` | Pass | Flattened bridge-only surface |
| GR tensors only | `CATEPTMain.GravitasStandalone` | `lake build CATEPTMain.GravitasStandalone` | Pass | Riemann/Einstein/Weyl tensors + CATEPT bridge |
| Quantum info only | `CATEPTMain.QuantumInfoStandalone` | `lake build CATEPTMain.QuantumInfoStandalone` | Pass | Von Neumann entropy, quantum Fisher, EPT bridge |
| CATEPT core | `CATEPT.CATEPT.Core` | `lake build CATEPT.CATEPT.Core` | Pass | Minimal foundations: EPT definitions, Δτ/t_P formula |

\* In heavily loaded sessions, `lake build CATEPTMain` may occasionally terminate with exit 143 (external interruption). Re-running the same command succeeds when the interrupting process is cleared.

## What Is Formalized

- **Navier-Stokes** (`NavierStokes/`, `NavierStokesClean/`) — Galerkin descent tower, BKM vorticity bound, enstrophy evolution, Fourier/Sobolev T³ analysis, Route 6 Cameron-Popkov-Zeno strategy
- **Yang-Mills mass gap** (`LGT` dep) — 2D YM via discrete differential geometry + Doeblin mixing
- **O(N) scalar field / large-N** (`pphi2N` dep) — Hubbard-Stratonovich mass gap
- **GR tensors** (`CATEPTMain/Gravitas/`) — Riemann, Ricci, Weyl, Einstein, ADM decomposition
- **Quantum information** (`QuantumInfo/`, `ClassicalInfo/`) — von Neumann entropy, quantum Fisher information, classical capacity
- **Statistical mechanics** (`StatMech/`, `GibbsMeasure/`) — DLR Gibbs measures, KMS states
- **Fourier/Sobolev on T³** (`NavierStokesClean/Sobolev/`) — Periodic Sobolev spaces, torus bridge

## Dependencies

All dependencies are pinned by commit and fetched from public GitHub repositories. No local paths required.

See `lakefile.lean` for the full list (Mathlib v4.29.0, Physlib, BochnerMinlos, HilleYosida, pphi2, pphi2N, LGT, GaussianField, lean-inf, aristotle, UnifiedTheory, DeGiorgi, spectralPhysics, aqeiBridge, DimensionalAnalysis, cslib).

## Axiom Surface

Key theorems in this repository depend only on `propext`, `Classical.choice`, and `Quot.sound` (standard Lean 4 axioms). Physics-side axioms (Weyl law, Agmon estimates, Fourier-palinstrophy inequality, etc.) are explicitly declared as `axiom` and documented.

Run `#print axioms <theorem>` in any file to inspect the full dependency chain.

## Repository Structure

```
CATEPTMain/          Integration bridges (GR, QM, YM, NS, AdS/CFT, EPT)
  Gravitas/          GR tensor library (Riemann → ADM, 0 sorry, Mathlib-only)
  AFPBridge/         AFP/Isabelle proof port pipeline
  Integration/       ~50 cross-domain bridge modules
CATEPT/              Core EPT/CATEPT framework and DSL
NavierStokes/        Route 6 NS strategy (Cameron-Popkov-Zeno)
NavierStokesClean/   Clean NS types, Galerkin, Sobolev T³
QuantumInfo/         Quantum information theory
ClassicalInfo/       Classical information theory
StatMech/            Statistical mechanics
GibbsMeasure/        DLR Gibbs measures
Carleson/            Carleson theorem formalization
LY/                  Lee-Yang theorem
BrownianMotion/      Brownian motion / Kolmogorov extension
```

## Verification

- Axiom gate: `#print axioms CATEPTMain.strategy_d_popkov_route`
- NS contract checks: `python3 tools/verification/check_ns_semantic_strictness.py --strict`
- LeanMillennium conformance: `python3 tools/verification/run_ns_leanmillennium_conformance_bundle.py`
