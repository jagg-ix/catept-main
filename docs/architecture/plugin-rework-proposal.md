# Plugin Architecture — Rework Proposal

**Date**: 2026-04-24
**Status**: Proposal, not yet executed
**Scope**: catept-main plugin architecture (`CATEPTMain/Integration/TheoryPluginArchitecture.lean`)

## Motivation

catept-main's current plugin architecture uses a **Prop-law-carrying-slot**
pattern: a `CATEPTPluginSlot` structure whose fields include laws the plugin
supplier must prove (`actionIm_nonneg`, `eptClock_nonneg`), plus a separate
`cateptConsistencyConstraint` Prop the plugin must discharge.

Four sibling repositories — **Logos_Library**, **PhysicsLogic**,
**OSreconstruction**, **ModularPhysics** — implement different architectural
patterns worth adopting. This document inventories what each does, compares
against catept-main's current approach, and recommends a staged rework.

## The four architectures, compared

| Repo | Core pattern | Count/scale | Key idea worth adopting |
|---|---|---|---|
| **Logos_Library** (`xiyin137`) | "Superior Method" bridges | 354 files, ~125k lines, 114 axioms, 7 sorries | Two modules built with *no shared imports*; a bridge file asks the compiler whether the structures are definitionally equal. The compiler is the comparator. |
| **PhysicsLogic** (`xiyin137`) | Tagged-assumption registry | 213 files, 0 axioms, 89 sorries, **260 registered assumptions** | `PhysicsAssumption (id : String) (P : Prop) : Prop := P` — every non-derived premise carries a stable string id for grep/audit. |
| **OSreconstruction** (`xiyin137`) | Bridge-as-axiom-retirement | 290 files | [`OSReconstruction/Bridge/AxiomBridge.lean`](https://github.com/xiyin137/OSreconstruction/blob/main/OSReconstruction/Bridge/AxiomBridge.lean) — specific lemmas (`minkowskiSignature_eq_metricSignature := rfl`, `isLorentzMatrix_iff := …`) let the axioms `edge_of_the_wedge` / `bargmann_hall_wightman` be **replaced by theorems** using infrastructure from parallel modules. |
| **ModularPhysics** (`xiyin137`) | Coordination-hub-only repo | 1 Lean file | The repo is just a README explaining sibling-repo responsibilities; all content lives in siblings. |

### Concrete Superior-Method example (from OSreconstruction)

```lean
-- Two independently-developed namespaces:
--   LorentzLieGroup.minkowskiSignature
--   MinkowskiSpace.metricSignature

theorem minkowskiSignature_eq_metricSignature :
    LorentzLieGroup.minkowskiSignature d = MinkowskiSpace.metricSignature d := rfl
```

The theorem is `rfl` — the compiler automatically verifies the two
independently-defined structures are definitionally equal. This *is* the
compatibility proof.

### Concrete tagged-assumption example (from PhysicsLogic)

```lean
abbrev PhysicsAssumption (_id : String) (P : Prop) : Prop := P

namespace AssumptionId
  def bianchiImpliesConservation : String := "gr.bianchi_implies_conservation"
  def qiStrongSubadditivity      : String := "qi.strong_subadditivity"
  def aqftReehSchlieder          : String := "qft.aqft.reeh_schlieder"
  -- ... 260 total
end AssumptionId
```

Every physical assumption in the library becomes:
- machine-greppable (e.g. `rg "AssumptionId\.qi"` → every QI assumption)
- countable (`PhysicsLogic/ASSUMPTIONS.md` auto-generates counts)
- CI-gateable (no new `PhysicsAssumption` id without matching registry entry)

## catept-main's current plugin architecture

[`CATEPTMain/Integration/TheoryPluginArchitecture.lean`](../../CATEPTMain/Integration/TheoryPluginArchitecture.lean)
uses a Prop-law-carrying-slot pattern:

```lean
structure CATEPTPluginSlot where
  ConfigSpaceTy      : Type
  actionIm, eptClock : ConfigSpaceTy → ℝ
  hbar               : ℝ
  hbar_pos           : 0 < hbar
  actionIm_nonneg    : ∀ x, 0 ≤ actionIm x
  eptClock_nonneg    : ∀ x, 0 ≤ eptClock x

def cateptConsistencyConstraint (slot : CATEPTPluginSlot) : Prop :=
  ∀ x, slot.actionIm x / slot.hbar = slot.eptClock x

structure TheoryPlugin where
  -- 12 different slot Props the plugin must prove
  waveParticle, gaugeGeometry, localGlobal, …, cateptSpine : Prop
```

Every plugin supplies proofs of the laws. Compatibility is checked by
bundling plugins; the plugin supplier is the sole owner of correctness.

## Proposed rework — four adoption patterns

### 1. Superior-Method bridges (from Logos / OSreconstruction) — **biggest conceptual win**

Replace "plugin supplies `cateptConsistencyConstraint` as a Prop-field
obligation" with "each domain is an independent Lean namespace; bridge files
compile iff the structures line up":

```lean
-- BEFORE: one slot, lots of obligations a plugin supplier has to prove.
namespace CATEPTMain.Integration.QuantumCATEPTBridge
  theorem quantumCATEPTSlot_consistent (n : ℕ) :
    cateptConsistencyConstraint (quantumCATEPTSlot n) := …

-- AFTER: two independently-built domains + a small bridge file.
namespace CATEPTMain.Domains.QM
  def actionIm (ρ : QMState) : ℝ := vonNeumannEntropy ρ
  def eptClock (ρ : QMState) : ℝ := vonNeumannEntropy ρ    -- ℏ = 1
end CATEPTMain.Domains.QM

namespace CATEPTMain.Domains.GR
  def actionIm (g : GRMetric) : ℝ := euclideanAction g
  def eptClock (g : GRMetric) : ℝ := euclideanAction g     -- ℏ = 1
end CATEPTMain.Domains.GR

namespace CATEPTMain.Bridges.QMGR
  /-- Same functional shape on both sides: `actionIm = eptClock` via rfl. -/
  theorem qm_gr_clock_compat :
      (∀ ρ : QMState,
        CATEPTMain.Domains.QM.eptClock ρ = CATEPTMain.Domains.QM.actionIm ρ) ∧
      (∀ g : GRMetric,
        CATEPTMain.Domains.GR.eptClock g = CATEPTMain.Domains.GR.actionIm g) :=
    ⟨fun _ => rfl, fun _ => rfl⟩
end CATEPTMain.Bridges.QMGR
```

**Win**: bridge files become typecheck-and-you're-done compatibility proofs.
`rfl` wherever possible.
**Cost**: must split domain content into pure namespaces with no
cross-imports; requires curating `CATEPTMain/Domains/{QM,GR,QFT,NS}/` from
the current scattered `Integration/` bridges.

### 2. Tagged-assumption registry (from PhysicsLogic) — **machine-audit win**

Add `CATEPTMain/Core/Assumptions.lean`:

```lean
namespace CATEPTMain

abbrev CATEPTAssumption (_id : String) (P : Prop) : Prop := P

namespace AssumptionId
  def hbarIsTwoNu : String := "catept.hbar_is_2nu"        -- ℏ = 2ν
  def weylLaw     : String := "pde.weyl_law"
  def bkmCriterion : String := "ns.bkm_criterion"
  -- ...
end AssumptionId

end CATEPTMain
```

Every physical-identification `axiom` in catept-main currently declared
implicitly or as a Prop law gets wrapped as
`CATEPTAssumption AssumptionId.fooXyz (concrete Prop)`.

Enables:
- `rg "AssumptionId\.\w+"` to list every registered assumption
- Auto-generated `docs/architecture/ASSUMPTIONS.md` (PhysicsLogic's approach:
  260 registered, 252 referenced, 8 dead)
- CI gate: "no new `CATEPTAssumption` id without matching entry in
  `AssumptionId` namespace"

**Win**: every physical-identification assumption becomes greppable,
countable, auditable. No new proof power — just traceability.
**Cost**: one-time retrofit of ~50 existing `axiom` / Prop-law declarations.
Mostly mechanical.

### 3. Monorepo → coordination-hub (from ModularPhysics) — **repo-layout win**

catept-main's lakefile already has 25+ sibling deps (pphi2, pphi2N, LGT,
aristotle, OSreconstruction, Logos_Library, ...). Formalise this by making
`CATEPTMain/` itself much smaller: keep only

- the abstract core (`CATEPT/CATEPT/Foundations.lean` etc.)
- the bridge files (`CATEPT/Bridges/*.lean`)
- the coordination README
- the plugin-architecture abstract types

and push each plugin (Quantum, Gravitas port, FEYNCALC port, ...) out to its
own sibling repo that catept-main references via lakefile. catept-main today
is ~5000 Lean files across `CATEPT/`, `CATEPTMain/`, `NavierStokes/`,
`NavierStokesClean/` — some of those tracks are natural sibling candidates.

**Win**: each plugin gets its own build, CI, release cadence; catept-main's
monorepo build times drop; publication artifact becomes the spine repo +
sibling links.
**Cost**: non-trivial repo surgery; git history preservation per sibling;
cross-repo CI orchestration.

### 4. Cross-domain import diagram (from Logos) — **documentation win**

Logos_Library's README has an explicit cross-module dependency diagram
(`QM → Relativity: Unitarity ↔ 1st law`, `Info Geometry → QM: Cramér–Rao
gives 2nd proof of Heisenberg`, ...). catept-main should maintain the
equivalent: which `Bridges/` file consumes which `Core/` file, which `Core/`
file supplies which theorem lineage.

**Win**: review-facing dependency map; helps future `CATEPT.Bridges.*`
authors pick a minimal dependency target.
**Cost**: doc only, ~1 day to generate + 15-min monthly upkeep.

## Recommended sequencing

| # | Step | Effort | Payoff |
|---|---|---|---|
| 1 | Assumption registry (`CATEPTAssumption`) | 1 day | High — enables audit tooling and CI gate |
| 2 | Superior-Method bridges (rewrite `Integration/` as `Domains/` + `Bridges/`) | 1-2 weeks | Highest — changes the rigor story |
| 3 | Cross-domain dependency diagram | 1 day | Medium — publication-reviewer-facing |
| 4 | Split plugins to sibling repos | Multi-week | High long-term, but invasive |

**Recommended start**: step 1 (assumption registry) — cheap, already what
every sibling architecture has (Logos's `axiom_audit.md`, PhysicsLogic's
`ASSUMPTIONS.md`, OSreconstruction's `Bridge/AxiomBridge.lean`), and is
a prerequisite for any tightening of the axiom-gate CI. Steps 2 and 3 land
incrementally after; step 4 is a project in its own right.

## Related worklog tasks

Each adoption pattern has a matching worklog task:

| Task code | Pattern |
|---|---|
| `catept_arch_assumption_registry_20260424` | #1 Tagged-assumption registry |
| `catept_arch_superior_method_bridges_20260424` | #2 Superior-Method bridges |
| `catept_arch_cross_domain_diagram_20260424` | #3 Cross-domain dependency diagram |
| `catept_arch_plugin_siblings_split_20260424` | #4 Split plugins to sibling repos |
| `catept_arch_rework_summary_20260424` | Coordination/tracking task |

Check the worklog with:
```bash
DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
PYTHONPATH=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool
python3 -c "from ept_worklog.cli import main; import sys; sys.argv=['wl','--db','$DB','summary']; main()"
```
