/-!
# Spacetime Harvest Catalog — Provenance Index

**Step 5 of the 2026-04-29 spacetime-harvest plan.**  Lightweight
provenance index recording where each harvested module came from
(source repo, source file, source sections), what it now provides, and
which PR landed it.

The catalog is encoded as Lean data (`HarvestEntry` struct + `List
HarvestEntry` value) so future helpers can grep / audit programmatically:

```bash
rg "step :=" CATEPTMain/Integration/SpacetimeHarvestCatalog.lean
```

A kernel-only `catalog_complete` theorem confirms all five steps are
recorded.

## Why this file exists

The 2026-04-29 architecture review identified hand-maintained tables in
`README.md`, `sibling-repo-inventory.md`, and `plugin-split.md` as a
drift risk.  The `tools/docs/gen_repo_spine.py` generator (PR #7)
addresses the *sibling-repo* drift; this catalog file addresses the
*intra-tree harvest* drift for the spacetime-harvest plan.  Treat it as
the audit trail for the 5 steps, not as authoritative source for any
given symbol — the actual definitions live in their respective files.

## Coverage

After this file lands, all 5 steps of the spacetime-harvest plan are
recorded as kernel-only `HarvestEntry` defs, and the umbrella
`spacetime_harvest_complete` theorem confirms the catalog has length 5.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SpacetimeHarvestCatalog

/-- Provenance entry for one step of the spacetime-harvest plan. -/
structure HarvestEntry where
  /-- The step index (1-5 for this plan). -/
  step : Nat
  /-- The Lean module that this step ships. -/
  targetModule : String
  /-- The PR number on `jagg-ix/catept-main` that landed it. -/
  prNumber : Nat
  /-- Source location (repo + file + sections). -/
  sourceRef : String
  /-- One-line summary of what was harvested. -/
  summary : String

namespace HarvestEntry

/-- Step 1 — `Geometry/FiniteMinkowski.lean` (PR #17). -/
def step1 : HarvestEntry where
  step := 1
  targetModule := "CATEPTMain.Geometry.FiniteMinkowski"
  prNumber := 17
  sourceRef := "NavierStokesClean/CATEPT/CATEPTSpaceTime.lean §1+§3+§3b"
  summary :=
    "Pure-geometric core: CATEPTSpace, CATEPTST, CATEPTTime, " ++
    "spatialNorm2, minkowskiNorm2, Causal{Timelike,Lightlike,Spacelike}, " ++
    "Lightcone, NoFTLBound, causal_trichotomy, timelike_time_dominates."

/-- Step 2 — `Geometry/EntropicLapse.lean` (PR #18). -/
def step2 : HarvestEntry where
  step := 2
  targetModule := "CATEPTMain.Geometry.EntropicLapse"
  prNumber := 18
  sourceRef := "NavierStokesClean/CATEPT/CATEPTSpaceTime.lean §3c"
  summary :=
    "ADM-style lapse-weighted Minkowski geometry: EntropicLapse, " ++
    "entropicNorm2, EntropicTimelike/Spacelike, unitLapse reduction, " ++
    "entropicTimelike_mono, entropicTimelike_velocity_bound."

/-- Step 3 — `Integration/CATEPTSTAdapter.lean` (PR #20). -/
def step3 : HarvestEntry where
  step := 3
  targetModule := "CATEPTMain.Integration.CATEPTSTAdapter"
  prNumber := 20
  sourceRef := "FiniteMinkowski + CATEPTSpacetimeModel (canonical spine)"
  summary :=
    "Vacuum-tier adapter from FiniteMinkowski.CATEPTST into the " ++
    "canonical CATEPTSpacetimeModel: lorentzMetric := minkowskiNorm2 (y-x), " ++
    "ept ≡ 0; finiteMinkowski_satisfies_ept_axioms via " ++
    "catept_satisfies_ept_axioms."

/-- Step 4 — `Integration/MISNoFTLBridge.lean` (this PR). -/
def step4 : HarvestEntry where
  step := 4
  targetModule := "CATEPTMain.Integration.MISNoFTLBridge"
  prNumber := 0  -- will be set after merge; recorded in commit message
  sourceRef :=
    "EntropicLapse (PR #18) + EntropicCoercivityFromPalinstrophy (P27b, PR #14) + " ++
    "FiniteMinkowski.NoFTLBound (PR #17)"
  summary :=
    "NS-specific bridge composing entropic lapse + palinstrophy " ++
    "coercivity (ν · k_UV⁴) + no-FTL bound into MISNoFTLData. " ++
    "noFTL_and_coercivity_compatible, supplies_P28_d4_rate (P28 hookup)."

/-- Step 5 — this file. -/
def step5 : HarvestEntry where
  step := 5
  targetModule := "CATEPTMain.Integration.SpacetimeHarvestCatalog"
  prNumber := 0  -- will be set after merge
  sourceRef := "self-describing"
  summary :=
    "Provenance index for the 5-step spacetime-harvest plan. " ++
    "HarvestEntry struct + List value + kernel-only catalog_complete."

end HarvestEntry

/-- **The complete spacetime-harvest catalog**: all 5 steps, in order. -/
def catalog : List HarvestEntry :=
  [HarvestEntry.step1,
   HarvestEntry.step2,
   HarvestEntry.step3,
   HarvestEntry.step4,
   HarvestEntry.step5]

/-- **Audit anchor**: the catalog has exactly 5 entries (matching the
2026-04-29 plan's 5-step structure). -/
theorem catalog_complete : catalog.length = 5 := rfl

/-- **Audit anchor**: the entries are recorded in step order. -/
theorem catalog_in_step_order :
    (catalog.map HarvestEntry.step) = [1, 2, 3, 4, 5] := rfl

end CATEPTMain.Integration.SpacetimeHarvestCatalog
