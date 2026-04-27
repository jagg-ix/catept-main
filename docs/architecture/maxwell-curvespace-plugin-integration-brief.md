# Maxwell-CurveSpace-Pphi2 plugin integration

**Worklog code**: `catept_maxwell_curvespace_plugin_integration_20260427`
**Priority**: p2
**Tag**: `catept,plugin-integration,maxwell,gr,qft,os-reconstruction,t88-candidate`
**Estimated effort**: 1-2 hours
**Builds on**: T66 (4-invariant slots), T78 (substrate kernel), T79 (joint TF), T82 (generic substrate constructor), T86 (assumption-tag pattern)

## Goal

The sibling repo `catept-plugin-maxwell-curvespace-pphi2` (pinned in
`lakefile.lean` at `630999098`) ships an interface-level bridge between
CAT/EPT, GR (curve-space), Maxwell EM, and QFT (Osterwalder-Schrader
reconstruction). It is currently:

* ✓ pinned in the lakefile,
* ✓ re-exported via `CATEPTMain/Integration/MaxwellCurveSpacePphi2Bridge.lean`,
* ✓ kernel-axiom clean (per its own docstring),
* ✗ NOT in the `CoherenceShowcase` 97-theorem audit gate,
* ✗ NOT lifted into a `TemporalFramework` adapter,
* ✗ Its OS Prop fields NOT linked to the registry's `osterwalderSchraderOS0`,
  `reflectionPositivity`, `bargmannHallWightman` ids (currently dead).

This task wires it in across all three layers in one self-contained
commit (T88 candidate), bringing the plugin into the protected
audit surface and making it a first-class spine adapter alongside
the other 10.

## Why this matters for the QM/GR/Maxwell/QFT unification claim

The repo's spine already covers QM (T70 adapter), GR (T66 Minkowski
adapter, T85 substrate-backed spacetime axioms), Maxwell flat-space
(T66 EM adapter), and structural QFT (T80 invariant #11
`quantumCorrespondenceConstraint`). What's missing for the full
"curved-spacetime QFT" headline is exactly the OS-reconstruction
package — which is what this plugin's `Pphi2IntegrationWitness`
provides. After integration, T79's joint TF can be extended:

```
maxwellGRQMcurved = joint maxwellCurveSpace (joint minkowski (joint em qm))
```

giving a single `TemporalFramework` whose configuration combines
GR curvature, EM 4-potential, density-matrix observables, AND a
curved-space Maxwell-coupling layer with an OS-reconstruction
witness.

## Current state — citations

### File 1: the plugin source
`.lake/packages/catept-plugin-maxwell-curvespace-pphi2/CATEPTPluginMaxwellCurveSpacePphi2/IntegrationBridge.lean`
(93 lines)

Verbatim signatures:

```lean
namespace CATEPTPluginMaxwellCurveSpacePphi2

structure CatEptMaxwellCurveSpaceModel where
  CurveSpace : Type
  MaxwellState : Type
  curvatureEnergy : CurveSpace → Real
  maxwellAction : MaxwellState → Real
  couplingEnergy : CurveSpace → MaxwellState → Real

structure Pphi2IntegrationWitness where
  os0Analyticity : Prop
  os1Regularity : Prop
  os2EuclideanInvariance : Prop
  os3ReflectionPositivity : Prop
  os4Clustering : Prop
  hasReconstruction : Prop
  massGapLowerBound : Real
  massGapPositive : 0 < massGapLowerBound

def CatEptPphi2IntegrationContract
    (m : CatEptMaxwellCurveSpaceModel)
    (w : Pphi2IntegrationWitness) : Prop :=
  (∀ x : m.CurveSpace, 0 ≤ m.curvatureEnergy x) ∧
  (∀ a : m.MaxwellState, 0 ≤ m.maxwellAction a) ∧
  (∀ x : m.CurveSpace, ∀ a : m.MaxwellState, 0 ≤ m.couplingEnergy x a) ∧
  w.os0Analyticity ∧ w.os1Regularity ∧ w.os2EuclideanInvariance ∧
  w.os3ReflectionPositivity ∧ w.os4Clustering ∧
  w.hasReconstruction ∧ 0 < w.massGapLowerBound

theorem catEpt_maxwell_curveSpace_pphi2_bridge
    (m : CatEptMaxwellCurveSpaceModel)
    (w : Pphi2IntegrationWitness)
    (hCurve : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMaxwell : ∀ a, 0 ≤ m.maxwellAction a)
    (hCoupling : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (hOS0 : w.os0Analyticity) (hOS1 : w.os1Regularity)
    (hOS2 : w.os2EuclideanInvariance) (hOS3 : w.os3ReflectionPositivity)
    (hOS4 : w.os4Clustering) (hRec : w.hasReconstruction) :
    CatEptPphi2IntegrationContract m w :=
  ⟨hCurve, hMaxwell, hCoupling, hOS0, hOS1, hOS2, hOS3, hOS4, hRec, w.massGapPositive⟩

end CATEPTPluginMaxwellCurveSpacePphi2
```

### File 2: the re-export shim
`CATEPTMain/Integration/MaxwellCurveSpacePphi2Bridge.lean`
(28 lines)

Already re-exports the four names under `CATEPTMain.Integration`:
```lean
namespace CATEPTMain.Integration
export CATEPTPluginMaxwellCurveSpacePphi2 (
  CatEptMaxwellCurveSpaceModel
  Pphi2IntegrationWitness
  CatEptPphi2IntegrationContract
  catEpt_maxwell_curveSpace_pphi2_bridge)
end CATEPTMain.Integration
```

So consumers can write `open CATEPTMain.Integration` and use the
exported names. This shim is **already in place** — do not modify.

### File 3: the audit gate
`CATEPTMain/Domains/CoherenceShowcase.lean` (97 `#print axioms` lines)

The plugin's bridge theorem is currently absent from this file.
Adding `#print axioms CATEPTMain.Integration.catEpt_maxwell_curveSpace_pphi2_bridge`
brings it under CI protection.

### File 4: the AssumptionId registry
`CATEPTMain/Core/Assumptions.lean`

Three relevant existing ids — currently dead per
`docs/architecture/ASSUMPTIONS.md`:

```lean
def osterwalderSchraderOS0 : String := "qft.os.os0_analyticity"
def reflectionPositivity   : String := "qft.os.reflection_positivity"
def bargmannHallWightman   : String := "qft.os.bargmann_hall_wightman"
```

Each maps directly onto a Prop field of `Pphi2IntegrationWitness`.

### File 5: the substrate-projection pattern (reference)
`CATEPTMain/Domains/SubstrateProjections.lean` (T82, generic constructor)

Use `ofTemporalFramework` to make the new adapter immediately a
substrate projection — same pattern as the other 10.

### File 6: the joint-TF pattern (reference)
`CATEPTMain/Domains/JointAdapter.lean` (T79)

Already provides `joint T₁ T₂` and `maxwellGRQM`. The new
`maxwellCurveSpace` adapter composes naturally into a
`maxwellGRQMcurved` extension.

## The three deliverables

### Deliverable 1 — Audit gate inclusion (5 minutes, REQUIRED)

Add to `CATEPTMain/Domains/CoherenceShowcase.lean`:

```lean
-- (near the end, after the existing audit blocks)

-- Maxwell-CurveSpace-Pphi2 plugin (T88 — interface-level QFT/GR/EM bridge).
--   Source: catept-plugin-maxwell-curvespace-pphi2 (sibling repo).
--   Provides Osterwalder-Schrader reconstruction interface for curved-
--   space Maxwell QFT.
#print axioms CATEPTMain.Integration.catEpt_maxwell_curveSpace_pphi2_bridge
```

Audit gate moves 97 → 98.

**Acceptance check**:
```bash
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 | grep "catEpt_maxwell"
# expect: depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Deliverable 2 — TemporalFramework adapter (~30 minutes, REQUIRED)

New file `CATEPTMain/Domains/Adapters/MaxwellCurveSpace.lean`:

```lean
import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge

/-!
# Maxwell-CurveSpace Adapter (T88) — first curved-spacetime adapter

Wraps the plugin's `CatEptMaxwellCurveSpaceModel` as a
`TemporalFramework`. The clock combines curvature, Maxwell action, and
their coupling — all three non-negative, hence the sum is.

This is the **first curved-spacetime adapter** in the spine. The
existing T66 EM adapter handles flat-space ‖A‖²/(2μ₀); this one
handles curved-space Maxwell with explicit gravity coupling via
the plugin's `couplingEnergy : CurveSpace → MaxwellState → ℝ`.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (CatEptMaxwellCurveSpaceModel cateptConsistencyConstraint)

abbrev MaxwellCurveSpaceConfig (m : CatEptMaxwellCurveSpaceModel) :=
  m.CurveSpace × m.MaxwellState

noncomputable def maxwellCurveSpaceClock
    (m : CatEptMaxwellCurveSpaceModel) :
    MaxwellCurveSpaceConfig m → ℝ :=
  fun p => m.curvatureEnergy p.1 + m.maxwellAction p.2 + m.couplingEnergy p.1 p.2

theorem maxwellCurveSpaceClock_nonneg
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a) :
    ∀ p : MaxwellCurveSpaceConfig m, 0 ≤ maxwellCurveSpaceClock m p := by
  intro ⟨x, a⟩
  unfold maxwellCurveSpaceClock
  have h1 := hCE x
  have h2 := hMA a
  have h3 := hCo x a
  linarith

/-- The Maxwell-curved-spacetime TemporalFramework. Caller supplies a
    populated model + non-negativity proofs + an inhabitant of the
    config type. -/
noncomputable def maxwellCurveSpace
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (witness₀ : MaxwellCurveSpaceConfig m) : TemporalFramework where
  Config := MaxwellCurveSpaceConfig m
  clock := maxwellCurveSpaceClock m
  clock_nonneg := maxwellCurveSpaceClock_nonneg m hCE hMA hCo
  witness := witness₀

theorem maxwellCurveSpace_satisfies_spine
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    cateptConsistencyConstraint
      (maxwellCurveSpace m hCE hMA hCo w).toCATEPTSlot :=
  (maxwellCurveSpace m hCE hMA hCo w).coherence_spine

-- Per-invariant claims (3/4 — QC deferred to future curve-space-quantum bridge)

noncomputable def maxwellCurveSpace_conservation
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    ConservationInvariant (maxwellCurveSpace m hCE hMA hCo w) :=
  (maxwellCurveSpace m hCE hMA hCo w).vacuumConservation

noncomputable def maxwellCurveSpace_reduction
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    ReductionInvariant (maxwellCurveSpace m hCE hMA hCo w) where
  classicalProjection := (maxwellCurveSpace m hCE hMA hCo w).clock
  target := (maxwellCurveSpace m hCE hMA hCo w).clock
  reduces_classically := fun _ => rfl

noncomputable def maxwellCurveSpace_symmetry
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    SymmetryInvariant (maxwellCurveSpace m hCE hMA hCo w) :=
  (maxwellCurveSpace m hCE hMA hCo w).identitySymmetry

theorem maxwellCurveSpace_validates
    (m : CatEptMaxwellCurveSpaceModel)
    (hCE : ∀ x, 0 ≤ m.curvatureEnergy x)
    (hMA : ∀ a, 0 ≤ m.maxwellAction a)
    (hCo : ∀ x a, 0 ≤ m.couplingEnergy x a)
    (w : MaxwellCurveSpaceConfig m) :
    UnifiedValidator (maxwellCurveSpace m hCE hMA hCo w)
      (some <| maxwellCurveSpace_conservation m hCE hMA hCo w)
      (some <| maxwellCurveSpace_reduction m hCE hMA hCo w)
      (some <| maxwellCurveSpace_symmetry m hCE hMA hCo w)
      none :=
  ⟨(maxwellCurveSpace m hCE hMA hCo w).coherence_spine,
   (maxwellCurveSpace_conservation m hCE hMA hCo w).divergence_free,
   (maxwellCurveSpace_reduction m hCE hMA hCo w).reduces_classically,
   (maxwellCurveSpace_symmetry m hCE hMA hCo w).clock_invariant,
   trivial⟩

end CATEPTMain.Temporal.Adapter
```

Add audit lines to `CoherenceShowcase.lean`:

```lean
import CATEPTMain.Domains.Adapters.MaxwellCurveSpace
-- ...
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpace_satisfies_spine
#print axioms CATEPTMain.Temporal.Adapter.maxwellCurveSpace_validates
```

Audit gate moves 98 → 100. The 11th adapter joins the 10 existing ones.

### Deliverable 3 — AssumptionId retrofits (~15 minutes, REQUIRED)

Add a new file `CATEPTMain/Integration/MaxwellCurveSpaceAssumptionTags.lean`:

```lean
import CATEPTMain.Core.Assumptions
import CATEPTMain.Integration.MaxwellCurveSpacePphi2Bridge

/-!
# Plugin OS-witness fields tagged with registry AssumptionIds

The plugin's `Pphi2IntegrationWitness` carries the OS-reconstruction
package as Prop fields. Three of those Props match existing
AssumptionIds in the registry (currently dead). This file wraps the
field accesses with `CATEPTAssumption` tags so the registry's grep
audit picks them up.

Pattern: when a caller supplies an actual proof of e.g.
`os3ReflectionPositivity`, the wrap below records that proof as the
substrate-side discharge of `AssumptionId.reflectionPositivity`.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId
open CATEPTMain.Integration (Pphi2IntegrationWitness)

theorem os0_analyticity_tag (w : Pphi2IntegrationWitness)
    (h : w.os0Analyticity) :
    CATEPTAssumption osterwalderSchraderOS0 w.os0Analyticity :=
  h

theorem reflection_positivity_tag (w : Pphi2IntegrationWitness)
    (h : w.os3ReflectionPositivity) :
    CATEPTAssumption reflectionPositivity w.os3ReflectionPositivity :=
  h

theorem has_reconstruction_tag (w : Pphi2IntegrationWitness)
    (h : w.hasReconstruction) :
    CATEPTAssumption bargmannHallWightman w.hasReconstruction :=
  h

end CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags
```

Then re-run the registry generator and verify the dead-list shrinks:

```bash
python3 tools/docs/gen_assumptions_md.py
# Expect: dead list 14 → 11; referenced 16 → 19
```

Add audit lines to `CoherenceShowcase.lean`:

```lean
import CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags
-- ...
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags.os0_analyticity_tag
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags.reflection_positivity_tag
#print axioms CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags.has_reconstruction_tag
```

Audit gate moves 100 → 103.

## Files to touch

| File | Change |
|---|---|
| `CATEPTMain/Domains/Adapters/MaxwellCurveSpace.lean` | **NEW** (Deliverable 2) |
| `CATEPTMain/Integration/MaxwellCurveSpaceAssumptionTags.lean` | **NEW** (Deliverable 3) |
| `CATEPTMain/Domains/CoherenceShowcase.lean` | add 6 `#print axioms` lines + 3 imports |

**No changes** to:
* The plugin sibling repo (`catept-plugin-maxwell-curvespace-pphi2`) —
  it stays at pin `630999098`.
* The re-export shim (`MaxwellCurveSpacePphi2Bridge.lean`).
* The registry (`Core/Assumptions.lean`) — the 3 ids being retrofitted
  already exist there, just dead.
* `lakefile.lean` — plugin already pinned.

## Acceptance criteria

1. `lake build CATEPTMain.Domains.Adapters.MaxwellCurveSpace` succeeds.
2. `lake build CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags` succeeds.
3. `lake build CATEPTMain.Domains.CoherenceShowcase` succeeds with **6
   new `info: ... depends on axioms: [propext, Classical.choice, Quot.sound]`**
   lines (audit gate 97 → 103).
4. The local audit-grep gate passes:
   ```bash
   lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 | tee /tmp/a.txt
   if grep -v -E "propext|Classical\.choice|Quot\.sound|^#print|depends on axioms:|^$" /tmp/a.txt | grep -qE "axiom|sorryAx"; then
     echo FAIL; exit 1
   fi
   ```
5. `python3 tools/docs/gen_assumptions_md.py` produces:
   - dead-list 14 → 11
   - referenced 16 → 19
   - the three `qft.os.*` ids each show ≥1 ref
6. CI gate (T75 axiom-gate.yml) continues to pass — no CI changes
   needed.
7. Worklog: `catept_maxwell_curvespace_plugin_integration_20260427`
   marked `done`; milestone note logged.

## Build commands

```bash
cd /private/tmp/catept-main-<your-handle>
git fetch origin
git checkout -b feat/<your-handle>/t88-maxwell-curvespace origin/main

# Edit the three files, then:
lake build CATEPTMain.Domains.Adapters.MaxwellCurveSpace
lake build CATEPTMain.Integration.MaxwellCurveSpaceAssumptionTags
lake build CATEPTMain.Domains.CoherenceShowcase

# Verify audit gate green:
lake build CATEPTMain.Domains.CoherenceShowcase 2>&1 | tee /tmp/audit.txt
grep -c "depends on axioms" /tmp/audit.txt    # expect 103
if grep -v -E "propext|Classical\.choice|Quot\.sound|^#print|depends on axioms:|^$" /tmp/audit.txt | grep -qE "axiom|sorryAx"; then echo FAIL; exit 1; fi
echo "PASS"

# Regenerate registry doc:
python3 tools/docs/gen_assumptions_md.py

# Pre-push checklist (per multi-helper sync protocol §10):
git fetch origin main
git log --oneline HEAD..origin/main   # must be empty (FF clean)

# Commit + push
git add CATEPTMain/Domains/Adapters/MaxwellCurveSpace.lean \
       CATEPTMain/Integration/MaxwellCurveSpaceAssumptionTags.lean \
       CATEPTMain/Domains/CoherenceShowcase.lean \
       docs/architecture/ASSUMPTIONS.md
git commit -m "T88: integrate Maxwell-CurveSpace-Pphi2 plugin into spine ..."
git push origin <your-commit-sha>:main
```

## Worklog protocol

Per `docs/architecture/multi-helper-sync-protocol.md` §3:

```bash
DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PP=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool

# Lock at start
PYTHONPATH=$PP python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','set-task-status',
  '--code','catept_maxwell_curvespace_plugin_integration_20260427',
  '--status','in_progress']
main()
"

# ... do the work, commit, push ...

# Mark done + milestone note
PYTHONPATH=$PP python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','set-task-status',
  '--code','catept_maxwell_curvespace_plugin_integration_20260427',
  '--status','done']
main()
"
```

## Naming convention

* Branch: `feat/<your-handle>/t88-maxwell-curvespace` or similar.
* Commit tag: **T88**. (T87 is the last T-tag on origin/main as of
  2026-04-27 21:30 UTC; verify with
  `git log origin/main --oneline | grep -oE "T[0-9]+" | sort -V | tail -3`
  immediately before committing — if origin moved, claim the next free
  number per the protocol's §4.)
* Audit-line comment prefix: `T88-<your-handle>` if there's any chance
  of a T-number collision.

## What this completes

After T88 lands:

* **11 adapters** (vs. 10 today): adds Maxwell-in-curved-spacetime as a
  first-class TemporalFramework alongside Minkowski, EM, VML, HO,
  Kinetic, Higgs, Herglotz, BohmianEM, QM, SR.
* **103-theorem audit gate** (vs. 97 today): plugin bridge + new
  adapter + 3 OS retrofits all under CI protection.
* **3 dead AssumptionIds retired** (`osterwalderSchraderOS0`,
  `reflectionPositivity`, `bargmannHallWightman`): registry dead-list
  shrinks 14 → 11.
* **First concrete QFT hook in the spine**: the OS Prop fields are
  greppable from source, so when upstream `mrdouglasny/pphi2` lands a
  real reflection-positivity proof, the registry retrofit shows
  exactly where to discharge the spine's QFT identification.
* **`maxwellGRQM` extends to `maxwellGRQMcurved`** via T79's `joint`
  operator — the structural QM ⊕ GR ⊕ Maxwell-flat ⊕ Maxwell-curved
  composition becomes a one-liner.

## What this does NOT do

* It does NOT supply real OS-reconstruction proofs. The OS Prop fields
  in the plugin remain abstract — Phase-2 work, scheduled to land when
  upstream `pphi2` provides the theorems.
* It does NOT add a non-vacuum `QuantumCorrespondenceInvariant` for
  the Maxwell-curve-space adapter. The 4th invariant slot (QC) remains
  `none` — same status as the EM/VML/Kinetic/Higgs/Herglotz adapters.
* It does NOT modify the plugin sibling repo. All work is in catept-main.

## Reference: other Target-style briefs

* `docs/architecture/target-d-brief.md` — the entropic-time / spacetime
  integration brief that copilot-claude executed cleanly as T87.
  Same structure as this one. Use it as a pattern reference.
* `docs/architecture/multi-helper-sync-protocol.md` — protocol for
  parallel helpers (worklog locking, T-number conflicts, safety stop).
