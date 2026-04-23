/-!
# Quantum Information Integration Bridge

Provides an abstract integration contract for the `lean-quantuminfo-inspect`
package against CATEPT's quantum bridges.

**Source:** `file:///…/lean-quantuminfo-inspect`
**Toolchain status:** `bridge_upgrade_required` — package targets Lean 4 v4.28.0;
  direct import blocked until toolchain is upgraded to v4.29.0.
  This file provides an abstract witness interface stable across the upgrade.

## CATEPT leverage points

* **IMD bridge** (`AFPBridge/IMD`): `lean-quantuminfo` supplies:
  - `QuantumInfo.Finite.CPTPMap` — completely-positive trace-preserving maps;
    bridges to `IMD.Theories.Quantum` unitary / measurement channels.
  - `QuantumInfo.Finite.Braket` — typed ket/bra formalism; cross-validates
    `IMDPrelude`'s `QVec` / `QMat` representation choices.
  - `QuantumInfo.Finite.AxiomatizedEntropy.Renyi` — Rényi entropy; supplies the
    entropy quantity referenced in `No_Cloning` (information-theoretic proof).

* **HSTP bridge** (`AFPBridge/HSTP`): `QuantumInfo` von Neumann entropy aligns
  with `HSTP.Theories.Trace_Class` and `Partial_Trace`.

* **Classical info layer**: `ClassicalInfo.Entropy` (Shannon entropy) and
  `ClassicalInfo.Channel` / `ClassicalInfo.Capacity` ground the CAT/EPT
  mutual-information side-conditions.

## Phase status
Phase-1: abstract witness; bridge theorem sorry-proved.
Phase-2 work item: upgrade `lean-quantuminfo` to v4.29.0 toolchain, then
replace `QuantumInfoWitness` fields with direct imports from `QuantumInfo`
and `ClassicalInfo`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.QuantumInfo

/-- Abstract capability witness for `lean-quantuminfo`. -/
structure QuantumInfoWitness where
  /-- `QuantumInfo.Finite.CPTPMap`: CPTP channels on finite-dimensional
      Hilbert spaces are available. -/
  cptpMapAvailable : Prop
  /-- `QuantumInfo.Finite.Braket`: typed ket/bra Dirac notation available. -/
  braketAvailable : Prop
  /-- Von Neumann entropy `S(ρ) = −tr(ρ log ρ)` formally stated. -/
  vonNeumannEntropyAvailable : Prop
  /-- Rényi entropy (order α) formally stated. -/
  renyiEntropyAvailable : Prop
  /-- `ClassicalInfo.Entropy`: Shannon entropy `H(p) = −∑ pᵢ log pᵢ`
      formally stated. -/
  shannonEntropyAvailable : Prop
  /-- `ClassicalInfo.Capacity`: classical channel capacity theorem available. -/
  channelCapacityAvailable : Prop

/-- Integration contract: CATEPT's IMD and HSTP bridges obtain quantum-info
    entropy and channel witnesses once `QuantumInfoWitness` is satisfied. -/
def QuantumInfoIntegrationContract (w : QuantumInfoWitness) : Prop :=
  w.cptpMapAvailable ∧ w.braketAvailable ∧
  w.vonNeumannEntropyAvailable ∧ w.renyiEntropyAvailable ∧
  w.shannonEntropyAvailable ∧ w.channelCapacityAvailable

/-- Phase-1 bridge theorem (sorry-proved pending toolchain upgrade to v4.29.0). -/
theorem quantumInfo_integration_contract
    (w : QuantumInfoWitness)
    (hC : w.cptpMapAvailable) (hB : w.braketAvailable)
    (hV : w.vonNeumannEntropyAvailable) (hR : w.renyiEntropyAvailable)
    (hS : w.shannonEntropyAvailable) (hCap : w.channelCapacityAvailable) :
    QuantumInfoIntegrationContract w :=
  ⟨hC, hB, hV, hR, hS, hCap⟩

end CATEPTMain.Integration.QuantumInfo
