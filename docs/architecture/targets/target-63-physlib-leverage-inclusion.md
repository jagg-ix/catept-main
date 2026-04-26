# Target 63 — Physlib Leverage Inclusion Map

**Date**: 2026-04-26  
**Workspace source**: `/Users/macbookpro/lab/tau/tau-information-dynamics/physlib`

---

## Objective

Use the existing `Physlib` dependency in `catept-main` as a concrete upstream for
quantum mechanics, relativity, string theory, and entropy lanes while preserving
current build safety.

---

## Current Dependency Status

`catept-main` already includes Physlib in `lakefile.lean`:

- package: `Physlib`
- pin: `9ca1ee1d0cac43391399fcdc9e9fca8c94c17057`
- toolchain in `catept-main`: Lean `v4.29.0`
- toolchain in local `physlib`: Lean `v4.29.1`

Operational note: broad Physlib imports in some integration lanes still risk the
known `Distribution` namespace collision, so inclusion should remain targeted.

---

## Domain Map (requested lanes)

### Quantum mechanics

- `Physlib.QuantumMechanics.FiniteTarget.Basic`
- `Physlib.QuantumMechanics.OneDimension.HarmonicOscillator.Basic`
- `Physlib.QuantumMechanics.OneDimension.HarmonicOscillator.TISE`
- `QuantumInfo.Finite.CPTPMap`

### Relativity

- `Physlib.Relativity.Tensors.Basic`
- `Physlib.Relativity.LorentzGroup.Basic`
- `Physlib.Relativity.LorentzGroup.Boosts.Basic`
- `Physlib.Relativity.Special.ProperTime`

### String theory

- `Physlib.StringTheory.Basic`
- `Physlib.StringTheory.FTheory.SU5.Charges.AnomalyFree`

### Entropy / thermodynamics / statistical mechanics

- `QuantumInfo.Finite.Entropy.VonNeumann`
- `QuantumInfo.Finite.Entropy.Relative`
- `QuantumInfo.Finite.Entropy.SSA`
- `QuantumInfo.Finite.Entropy.DPI`
- `QuantumInfo.Finite.Distance.TraceDistance`
- `Physlib.Thermodynamics.Basic`
- `Physlib.Thermodynamics.IdealGas.Basic`
- `Physlib.StatisticalMechanics.CanonicalEnsemble.Basic`
- `Physlib.StatisticalMechanics.CanonicalEnsemble.Finite`

---

## Included in `catept-main` now

`CATEPTMain/Integration/TheoryPluginPhyslibConstructBridge.lean` now carries a
compile-safe module-path registry covering all lanes above and a proof witness
(`physlibRelevantSubmodules_coverage`) for contract-level governance checks.

---

## Verification Command

From `catept-main`:

```bash
scripts/physlib_leverage_scan.sh /Users/macbookpro/lab/tau/tau-information-dynamics/physlib
```

This validates that each registry module path resolves to an actual file under
local `physlib`, and prints lane coverage counts.

---

## Recommended Next Integration Steps

1. Create narrow bridge files that import only one lane at a time (QM,
   Relativity, StringTheory, Entropy) instead of broad umbrella imports.
2. Prioritize entropy lane first (`QuantumInfo.Finite.Entropy.*`,
   `TraceDistance`, `CPTPMap`) to replace current axiom placeholders in
   QTM / DSF bridges.
3. Add a CI hook for `scripts/physlib_leverage_scan.sh` in opt-in mode to catch
   stale module paths when Physlib pins change.
