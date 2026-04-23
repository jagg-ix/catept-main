# CATEPT Main — Lean 4 Formal Verification Hub

A Lean 4.29 integration repository for the **Causal-Algebraic Thermodynamic Entropic Proper Time (CATEPT)** framework, connecting Navier-Stokes regularity, quantum information theory, general relativity tensors, Yang-Mills mass gap, and entropic proper time into a unified formal verification surface.

---

> ### 📄 Looking to review / cite the publication?
>
> The reviewer-facing publication artifact — axiom-free CAT/EPT core, four
> cross-domain compatibility bridges (pphi2N, QFT, GR, Gravitas), the
> **QM+GR unification showcase**, plus LICENSE / CITATION.cff / axiom-gate
> CI — lives on the dedicated **[`catept-publication`](https://github.com/jagg-ix/catept-main/tree/catept-publication)** branch of this repository.
>
> ```bash
> git clone https://github.com/jagg-ix/catept-main.git
> cd catept-main
> git checkout catept-publication
> lake exe cache get
> lake build CATEPT.Showcase.QMGRUnification
> ```
>
> See that branch's [README](https://github.com/jagg-ix/catept-main/blob/catept-publication/README.md)
> for the three-step command-line reproduce, expected `#print axioms`
> output, and the Acknowledgments section (Caticha's entropic-dynamics
> foundations, Gravitas port, Lean 4 dependencies).
>
> The `main` branch contains the full integration tree (kitchen-sink
> development repo); the `catept-publication` branch is the curated
> surface meant for publication citation and reviewer audits.

---

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

## Publication Surface (axiom-free)

For the publication-grade, axiom-free narrative, inspect:

| File | What it demonstrates |
|---|---|
| [`CATEPT/CATEPT/Foundations.lean`](CATEPT/CATEPT/Foundations.lean) | CAT/EPT core identities (entropic time, action-entropic identification, Landauer, Hawking temperature) — 0 axioms, 0 sorries |
| [`CATEPT/Bridges/Pphi2N.lean`](CATEPT/Bridges/Pphi2N.lean) | 3 theorems specialising the core to the O(N) large-N sigma model |
| [`CATEPT/Bridges/QFT.lean`](CATEPT/Bridges/QFT.lean) | 5 theorems specialising to Euclidean QFT (action, damping, propagator) |
| [`CATEPT/Bridges/GR.lean`](CATEPT/Bridges/GR.lean) | 5 theorems specialising to Schwarzschild / ADM / Unruh |
| [`CATEPT/Bridges/Gravitas.lean`](CATEPT/Bridges/Gravitas.lean) | 4 theorems specialising to symbolic BH thermodynamics |

Reproduce the zero-axiom claim from a fresh checkout:

```bash
lake exe cache get
lake build CATEPT
# Then, for each bridge theorem:
lake env lean -c 'import CATEPT.Bridges.Pphi2N
#print axioms CATEPT.Bridges.Pphi2N.tauEnt_eq_div'
# → depends on axioms: [propext, Classical.choice, Quot.sound]
```

The CI workflow [`.github/workflows/axiom-gate.yml`](.github/workflows/axiom-gate.yml) runs this check on every push/PR for all 17 bridge theorems; regressions break the build.

## Entry Points

Verified on 2026-04-23.

| Surface | Lake target | Build command | Status | What it gives you |
|---------|-------------|---------------|--------|--------------------|
| Full integration hub | `CATEPTMain` | `lake build CATEPTMain` | Pass* | All bridges, NS, QM, GR, YM, EPT |
| Publication spine | `CATEPT` | `lake build CATEPT` | Pass | Axiom-free core + 4 compatibility bridges |
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
