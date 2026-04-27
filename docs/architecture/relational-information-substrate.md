# Relational Information Substrate - Repo Guidance

**Status**: conceptual architecture note
**Scope**: guidance for CAT/EPT-oriented repo updates

## Purpose

This note records a repo-facing classification of the underlying conceptual
model as a **relational information substrate**. The goal is not to add a new
physics module immediately, but to provide a stable guide for future updates to
the CAT/EPT spine, the quantum bridges, the locality layer, and the
semiclassical interfaces.

The intended use is architectural:

- to decide where new abstractions belong,
- to avoid collapsing distinct notions of time into one symbol too early,
- to keep Bell/no-signaling, causal geometry, and entropic time on one
  coherent semantic stack.

## Classification

The model is best classified as a **computational-relational causal substrate
with emergent phase time and entropic proper time**.

In repo terms, that means:

- **Ontology**: primitive reality is process- and information-first, not
  spacetime-first.
- **Causality**: bounded propagation and local ordering are primary.
- **Time**: time is layered and emergent, not a single primitive scalar.
- **Quantum structure**: nonclassical correlations arise from shared substrate
  structure plus local operational constraints.
- **Geometry**: causal geometry and later spacetime structure are projections
  of the substrate, not the starting point.

This classification fits the current CAT/EPT direction better than either a
pure QFT-first or a pure GR-first reading.

## Three Time Layers

The most important architectural consequence is that the model contains three
distinct temporal layers which should remain distinct in the codebase.

1. **Local ordering time**
   A local ordinal structure that enforces causal consistency of received
   notifications or inputs.

2. **Phase time**
   A de Broglie-like or Hamiltonian-like internal phase evolution layer that
   supports interference, coherence, and Bell-compatible correlations.

3. **Entropic proper time**
   The irreversible coarse-grained clock used by CAT/EPT, typically expressed
   as `tau_ent = S_I / hbar`.

Repo guidance:

- do not identify local order with `tau_ent`;
- do not identify phase evolution with `tau_ent`;
- instead, treat `tau_ent` as the irreversible thermodynamic projection of the
  substrate.

## Layer Map To Current Repo

| Conceptual layer | Internal role | Current repo landing | Current gap |
|---|---|---|---|
| Relational substrate | entities, information objects, notification/access structure | `CATEPTMain/Integration/RelationalInformationSubstrate.lean` | abstract kernel now present; Bell adapter still missing |
| Local temporal law | local causal ordering, inhabited dynamics | `CATEPTMain/Domains/TemporalFramework.lean` | no event-order or reference-frame structure yet |
| Entropic proper time | irreversible clock, `tau_ent = S_I / hbar` | `CATEPTMain/Integration/EntropicProperTimeCoreBridge.lean` | witness is present, but integration to spacetime is still abstract |
| Spacetime projection | causal manifold, EPT scalar, no-FTL contract | `CATEPTMain/Integration/CATEPTSpaceTime.lean` | substrate projection now exists; `ept_causal_arrow` and `noFTL` are still placeholders |
| Bell/no-signaling layer | quantum correlations without FTL signaling | `CATEPTMain/QuantumGravity/NoFTLBellBridge.lean` | Bell mathematics is present, but no substrate adapter yet |
| Assumption traceability | controlled cross-layer premises | `CATEPTMain/Core/Assumptions.lean` | no substrate-specific ids yet |
| Invariant certification | spine + conservation/reduction/symmetry/qc | `CATEPTMain/Domains/UnifiedValidator.lean` | no substrate-facing validator profile yet |
| Semiclassical bridge | curvature sourced by expectation values | `CATEPTMain/Domains/Invariants/QuantumCorrespondence.lean` | still pointwise real-valued skeleton |

## Interpretation Of Existing Files

### `RelationalInformationSubstrate.lean`

This file is the substrate kernel itself. It is intentionally abstract and small:

- entities,
- information objects,
- notifications,
- local temporal consistency,
- bounded propagation,
- phase / storage / irreversible cost,
- CAT/EPT clock projection.

It should be used as the common semantic layer for later adapters.

### `TheoryPluginQTMBridge.lean`

This file is the closest existing quantum-information projection of the substrate. Its core
claim that complex action splits into computation and communication gives a
natural place to encode the dual roles of irreversible processing and coherent
information flow.

Guidance:

- treat `Re(S)` as the irreversible or computational side of the substrate;
- treat `Im(S)` as the coherent or communication side;
- use this split when deciding where a new theorem belongs.

This file should be read as the information-processing projection of the
substrate model.

### `TemporalFramework.lean`

This file already provides the correct kernel shape for the entropic-time
projection:

- configuration space,
- nonnegative clock,
- inhabited witness,
- optional live witness.

Guidance:

- any new domain-level adapter for the substrate should enter the CAT/EPT spine
  through `TemporalFramework`;
- local order and phase may live below this layer, but `clock` should denote
  the entropic projection.

### `EntropicProperTimeCoreBridge.lean`

This file is the correct home for the thermodynamic identification
`tau_ent = S_I / hbar` and for the irreversible-cost interpretation of the
clock.

Guidance:

- use it as the canonical landing zone for "irreversible processing produces
  entropic time";
- avoid duplicating this identification in quantum or geometry files.

### `CATEPTSpaceTime.lean`

This file is the spacetime projection of the model. It should be read as the
geometric image of the substrate, not the primitive ontology.

Guidance:

- `ept_nonneg` should ultimately come from irreversible-cost positivity;
- `ept_causal_arrow` should ultimately come from substrate ordering plus
  irreversible accumulation;
- `noFTL` should ultimately come from bounded notification propagation.
- the new `SubstrateSpacetimeProjection` constructor is the preferred way to
  inject future substrate-backed models into this layer.

### `NoFTLBellBridge.lean`

This file already contains the right mathematical target for the correlation
and locality layer:

- classical CHSH bound,
- Tsirelson bound,
- Bell state infrastructure,
- no-FTL causal cone facts,
- CAT/EPT suppression of acausal modes.

Guidance:

- this should remain the definitive Bell/no-FTL theorem layer;
- future substrate work should adapt into this file's interface rather than
  re-deriving Bell mathematics from scratch.

### `Assumptions.lean`

This file is the traceability layer for any non-derived identification.

Guidance:

- when a substrate-level premise is needed before full derivation, register it
  here first;
- when a premise is later derived, retire the assumption id rather than
  deleting the history.

### `UnifiedValidator.lean`

This file is the correct place to aggregate a substrate-backed adapter once it
can claim any of:

- conservation,
- reduction,
- symmetry,
- quantum correspondence.

Guidance:

- the substrate model should not bypass the validator;
- instead, it should enter as one more certified framework profile.

## Architecture Rules For Future Updates

### Rule 1: Keep order, phase, and entropic time separate

Any future implementation should preserve the distinction:

- order enforces causality,
- phase supports quantum behavior,
- entropic time measures irreversible progression.

Collapsing these too early will make Bell, no-signaling, and thermodynamic
time harder to state cleanly.

### Rule 2: Distinguish correlation from signaling

The Bell/no-signaling reading should be:

- shared substrate structure may induce strong nonclassical correlations;
- usable notification or signaling remains propagation-bounded.

This matches the present direction of `NoFTLBellBridge.lean`.

### Rule 3: Use the QTM bridge as the substrate-facing quantum layer

If a new theorem is about coherent information flow, phase, channels, or
composition, it should prefer the `TheoryPluginQTMBridge.lean` stack rather
than ad hoc duplications in unrelated files.

### Rule 4: Use CAT/EPT only at the irreversible projection

`tau_ent` should remain the CAT/EPT clock of irreversible accumulation. It is
the thermodynamic projection of the substrate, not the whole substrate.

### Rule 5: Let geometry be projected, not primitive

Spacetime, curvature, and no-FTL geometry should be treated as projected
structure. This keeps the repo aligned with a process-first, information-first
reading.

## Concrete Repo Update Targets

### Target A: add a canonical substrate kernel

Recommended new file family:

- `CATEPTMain/Foundations/RelationalInformationSubstrate.lean`
  or
- `CATEPTMain/Integration/RelationalInformationSubstrate.lean`

Recommended contents:

- `Entity`
- `InfoObject`
- `Notification`
- `ReferenceFrame`
- `TemporalConsistent`
- bounded propagation law
- local phase carrier
- irreversible-cost accumulator

This file should be abstract and small. Its job is to define the common
language for later adapters.

### Target B: upgrade the spacetime placeholders from the substrate

`CATEPTSpaceTime.lean` currently leaves several fields as `True`.

Recommended direction:

- replace `ept_causal_arrow : True` with a Prop sourced by monotone substrate
  order plus entropic accumulation;
- replace `noFTL : True` with a Prop sourced by bounded notification
  propagation or a concrete no-signaling/no-FTL certificate.

### Target C: add a substrate-to-Bell adapter

The repo already has Bell/No-FTL mathematics. What is missing is the semantic
adapter from the substrate model into that theorem layer.

Recommended direction:

- define a Bell source in substrate terms,
- define local measurement settings in reference-frame terms,
- prove that local marginals are signaling-safe,
- connect the resulting source to the existing Bell density or no-signaling
  layer.

### Target D: strengthen the entropic-time integration

`EntropicProperTimeCoreBridge.lean` already records the right thermodynamic
identities, but the compatibility theorem with spacetime is still trivial.

Recommended direction:

- connect irreversible-cost positivity to `ept_nonneg`,
- connect accumulated entropic time to `ept_causal_arrow`,
- avoid duplicating this bridge elsewhere.

### Target E: add substrate-facing assumption ids only where unavoidable

Not every conceptual statement needs a new assumption id. Add them only when a
cross-layer claim cannot yet be proved but needs to be tracked.

Expected categories:

- substrate-to-quantum identification,
- substrate-to-causal-geometry identification,
- substrate-to-entropic-time identification.

## Immediate Reading Of The Current Stack

If we read the current repo through this note, the stack becomes:

- substrate semantics: `TheoryPluginQTMBridge`
- entropic kernel: `TemporalFramework`
- thermodynamic identification: `EntropicProperTimeCoreBridge`
- geometric projection: `CATEPTSpaceTime`
- correlation/locality layer: `NoFTLBellBridge`
- validation layer: `UnifiedValidator`
- traceability layer: `Assumptions`

That is already a coherent architecture. The main missing work is not a new
vision; it is the explicit substrate adapters that connect these layers
non-trivially.

## Summary

The relational information substrate should be treated as a guiding metamodel
for repo updates.

It says:

- begin from relational information processing,
- derive local order and phase internally,
- project irreversible accumulation into `tau_ent`,
- project bounded propagation into no-FTL geometry,
- recover Bell-compatible correlations without collapsing locality into
  signaling,
- certify each resulting domain through the CAT/EPT spine and validator.

This is the most stable way to align the repo's temporal, quantum, geometric,
and validation layers under one architecture.
