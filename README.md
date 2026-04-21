# CATEPT Main — Lean 4 Formal Verification Hub

A Lean 4.29 integration repository for the **Causal-Algebraic Thermodynamic Entropic Proper Time (CATEPT)** framework, connecting Navier-Stokes regularity, quantum information theory, general relativity tensors, Yang-Mills mass gap, and entropic proper time into a unified formal verification surface.

## Quick Start

```bash
git clone https://github.com/jagg-ix/catept-main.git
cd catept-main
lake exe cache get   # warm Mathlib olean cache (~10 min first run)
lake build CATEPTMain
```

## Entry Points

| Surface | File | What it gives you |
|---------|------|--------------------|
| Full integration hub | `CATEPTMain.lean` | All bridges, NS, QM, GR, YM, EPT |
| GR tensors only | `CATEPTMain/GravitasStandalone.lean` | Riemann/Einstein/Weyl tensors + CATEPT bridge |
| Quantum info only | `CATEPTMain/QuantumInfoStandalone.lean` | Von Neumann entropy, quantum Fisher, EPT bridge |
| CATEPT core | `CATEPT/CATEPT/Core.lean` | Minimal foundations: EPT definitions, Δτ/t_P formula |

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
