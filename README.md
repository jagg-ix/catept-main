# CATEPT Main (Lean 4)

This repository is an integration workspace for Lean 4 formalization around
Complex Action Theory and Entropic Proper Time (CATEPT), plus related domains.
It is organized as a collection of modules, bridges, and audits.

This README is intentionally operational and conservative:
- It describes what is in the repository.
- It does not make broad physical claims beyond theorems explicitly present in code.

## Purpose

- Provide Lean 4 implementations and interfaces for CATEPT-related constructs.
- Host cross-domain bridge modules under explicit theorem/axiom boundaries.
- Keep build, audit, and dependency workflows reproducible.

## Scope

- CATEPT core definitions and plugin constraints.
- Navier-Stokes and Sobolev/Fourier supporting modules.
- Quantum and quantum-information modules.
- GR tensor/ADM-oriented modules.
- Statistical mechanics and measure-theory support modules.

## Requirements

- Lean toolchain from `lean-toolchain` (Lean 4.29 line on this branch).
- `lake` and `git`.
- Internet access for dependency fetch and cache warmup.

## Quick Start

```bash
git clone https://github.com/jagg-ix/catept-main.git
cd catept-main
lake exe cache get
lake build CATEPTMain
```

## Common Build Targets

- Full integration surface:
  - `lake build CATEPTMain`
- Bridge aggregator:
  - `lake build CATEPTMain.Bridges`
- Core-only surface:
  - `lake build CATEPT.CATEPT.Core`
- Example focused surfaces:
  - `lake build CATEPTMain.GravitasStandalone`
  - `lake build CATEPTMain.QuantumInfoStandalone`

## Verification and Audits

- Lean axiom inspection:
  - `#print axioms <theorem_name>`
- NS semantic checks:
  - `python3 tools/verification/check_ns_semantic_strictness.py --strict`
- LeanMillennium bundle:
  - `python3 tools/verification/run_ns_leanmillennium_conformance_bundle.py`

## Axiom Policy

- Kernel axioms should be inspectable via `#print axioms`.
- Domain assumptions that are not yet theoremized are declared explicitly.
- Mixed theorem/axiom status is tracked in worklogs and verification artifacts.

## Repository Layout (Top Level)

```text
CATEPTMain/        Integration bridges and domain adapters
CATEPT/            Core CATEPT framework and DSL modules
NavierStokes/      NS strategy and bridge modules
NavierStokesClean/ Clean NS carrier/types/Sobolev interfaces
QuantumInfo/       Quantum information modules
ClassicalInfo/     Classical information modules
StatMech/          Statistical mechanics modules
GibbsMeasure/      Gibbs/DLR modules
Carleson/          Carleson formalization modules
LY/                Lee-Yang modules
BrownianMotion/    Brownian/Kolmogorov modules
tools/             Verification and automation scripts
verification/      Generated audit artifacts
```

## Dependencies

- Dependencies are pinned through:
  - `lakefile.lean`
  - `lake-manifest.json`
- Main ecosystem dependency is Mathlib (version pinned by this branch).

## Current Status

- This repository contains both theoremized modules and scaffold modules.
- Read theorem statements and run `#print axioms` for exact assurance level.
