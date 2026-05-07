# Orphan-triage audit — inventory + per-root disposition (2026-05-07)

Tracks `catept_spine_orphan_triage_audit_20260503`. First milestone: enumerate the actual orphan surface, classify each root, recommend disposition.

## Counts (computed by AST-aware reachability scan from `CATEPTMain.lean`)

```
Total .lean files in CATEPTMain/ (excl. Experimental/):  832
Reachable from the root barrel:                          686
ORPHAN total:                                            146
  Documentation-style (WORKLOG/PHASE/INTAKE/RESTRUCTURE):  41
  Real orphans:                                          105
    Roots (need wiring or deletion):                      24
    Leaves (transitively reachable through other orphans): 81
```

The task title `381 remaining orphans` was a stale snapshot from 2026-05-03; the actual count after subsequent wiring (PRs #38–#40 publication ports, OrphanAggregator) is **146**, and the **real triage surface is 24 roots**.

## The 41 documentation orphans

`*WORKLOG.lean`, `PHASE{1,2,3}_*.lean`, `*INTAKE*.lean`, `RESTRUCTURE_WORKLOG.lean`, `CALCULUS_PORT_WORKLOG.lean`. **Disposition: keep as documentation, never wire to spine.** They carry decision logs and migration histories; they're not load-bearing code. No action required.

## The 81 leaves

These are unreachable from `CATEPTMain.lean` because their parent root is unreachable. They will resolve automatically when each root is wired or deleted; no per-leaf decisions needed before the root-level triage.

## The 24 roots — per-root disposition

Categorized by what the file does and the recommended action.

### Category A — audit files (4 roots)

These are reviewer-facing `#print axioms` ledgers. They emit info lines but produce no symbols other consumers depend on. Wiring them into `CATEPTMain.lean` makes the audit run as part of default `lake build`.

| Root | Path | Leaves | Disposition |
|---|---|---:|---|
| `CATEPTMain.Integration.SlotConsistentFix_Audit` | `CATEPTMain/Integration/SlotConsistentFix_Audit.lean` | 0 | **WIRE** to root barrel — already proven kernel-only on every CI run; just isn't imported from `CATEPTMain.lean` yet |
| `CATEPTMain.CATEPT_ProperTime.Audit` | `CATEPTMain/CATEPT_ProperTime/Audit.lean` | 1 | **WIRE** — covers the 11 axiom-witnesses retired in PRs #50/#52/#54/#55. The 1 leaf is `SchwingerKeldyshADMBridge` (also in this category, see C). |
| `CATEPTMain.Integration.CIE_All_Audit` | `CATEPTMain/Integration/CIE_All_Audit.lean` | 8 | **WIRE** — bundles the 8 CIE causality bridges (KrausEntropicDamping, LorentzInvariantCausalBounds, etc.). Audit is reviewer-facing for causal-implementability claims. |
| `CATEPTMain.Integration.CIE_001_Audit`, `CIE_002_Audit`, `CIE_003_Audit` | same dir | 0+0+1 | **DELETE** — these are per-CIE audits superseded by `CIE_All_Audit`. Keeping all four means duplicating the same `#print axioms` content; pick the All variant. |

### Category B — orphan-bundle aggregators (5 roots)

These are subset spines following the `OrphanAggregator` pattern: each bundles an under-spine cluster of related-but-not-yet-wired modules.

| Root | Leaves | Disposition |
|---|---:|---|
| `CATEPTMain.Integration.FoundationsOrphanBundle` | 39 | **EVALUATE** — biggest cluster. Contains `CATEPT.CATEPT.{Basic, BellCHSHBohm…, BohmianBorn…, AdvancedFoundations, ...}`. Decision: either fold into `OrphanAggregator` or split each leaf-set into one focused bundle. |
| `CATEPTMain.Integration.QMOrphanBundle` | 8 | **WIRE** as a single import in `CATEPTMain.lean`; cluster is small and self-contained. |
| `CATEPTMain.Integration.EMOrphanBundle` | 2 | **WIRE** — two QED/QCD core abstractions. |
| `CATEPTMain.Integration.GROrphanBundle` | 1 | **WIRE** — one `ADMWDWEntropicHolographyBridge` leaf. |
| `CATEPTMain.Integration.ThermoOrphanBundle` | 2 | **WIRE** — two thermo leaves. |

### Category C — rotted bridges (7 roots, all explicitly quarantined in OrphanAggregator)

Each of these is a draft/incomplete bridge whose proof body has tactic drift, missing types, or false-as-stated claims. The `OrphanAggregator` already has them commented out with per-file rationales (see lines 100–119 of `CATEPTMain/Spine/OrphanAggregator.lean`).

| Root | Why quarantined | Disposition |
|---|---|---|
| `CATEPTMain.Integration.OperatorPathIntegralFoundation` | `congr 1` leaves unsolved goal at L39 | **FIX or DELETE** |
| `CATEPTMain.Integration.LorentzianRateKernelBridge` | `lorentzianKernel_from_rate_exp` is false-as-stated without a `hbar ≠ 0` hypothesis | **FIX** (add hypothesis) or DELETE |
| `CATEPTMain.Integration.WickRotationBridge` | 5 elaboration / linarith / type-mismatch issues | **FIX or DELETE** |
| `CATEPTMain.Integration.NormalizationOpenSystemBridge` | Lean-3 `constant` keyword, placeholder types never registered | **REWRITE** with `def X := Unit` pattern (same as PRs #50/#52/#54/#55) |
| `CATEPTMain.Integration.EntropySourceAdmissibilityBridge` | 4 issues including unbound `P` | **FIX or DELETE** |
| `CATEPTMain.Integration.GTDEntropyAffineBridge` | tactic drift; was untracked | **FIX or DELETE** |
| `CATEPTMain.Integration.KrausGKSLContinuousLimitBridge` | (not yet investigated) | **TRIAGE** |

Note: `SchwingerKeldyshADMBridge` was in this list before PR #54 retired its axioms; needs re-wiring now that it builds clean.

### Category D — Showcase (1 root)

| Root | Leaves | Disposition |
|---|---:|---|
| `CATEPTMain.Showcase.QMGRUnification` | 0 | **WIRE** — already imported on `feat/publication`; root barrel on main hasn't picked it up. Same QM↔GR unification surface that's audited by `SubstantiveAudit.lean` in PR #61. |

### Category E — old foundations (3 roots)

| Root | Leaves | Disposition |
|---|---:|---|
| `CATEPTMain.CATEPT.CATEPT.ArrowMpemba` | 0 | **EVALUATE** — old Mpemba effect bridge. May be superseded by other arrow-of-time work. |
| `CATEPTMain.CATEPT.CATEPT.Core` | 34 | **EVALUATE** — 34 leaves under it. The leaf list (`Basic`, `BellCHSHBohm…`, `BohmianBornRule…`, …) suggests this is an obsolete root that the curated tree has moved past. Likely candidate for deletion if the substance has migrated to other roots. |
| `CATEPTMain.CATEPT.CATEPT.Examples.README` | 30 | **DELETE** — examples README that pulls 30 example files. The Examples tree is documentation-style; never load-bearing. |

### Category F — orphans that should have been wired earlier (3 roots)

| Root | Leaves | Disposition |
|---|---:|---|
| `CATEPTMain.Integration.UnificationSpineHonestWitness` | 0 | **WIRE** — the Pattern-1 honest constructor from PR #38. Already imported on feat/publication; needs main wiring. |
| `CATEPTMain.Integration.EntropicTimeScaleNoetherBridge` | 0 | **WIRE or EVALUATE** — Noether bridge for entropic-time scaling. |
| `CATEPTMain.Domains.{...}` (1 entry, name TBD) | small | **WIRE** if substantive |

## Sibling-vs-local refactor (the second prong)

Independent of the orphan inventory: the `OrphanAggregator` cannot fully compile because of namespace collisions between `catept-main`'s own declarations and `catept-core`'s `CATEPTMainExtracted/CATEPT/CATEPT/{Foundations, MeasurePathIntegral}.lean` (both declare `ComplexHamiltonian`, `MeasurePathIntegralModel` under namespace `CATEPTMain.CATEPT.CATEPT`).

PR #57 partially closed this by retiring the `ModularData` in-tree duplicate. The remaining work:

1. Gut the `ComplexAction`, `ComplexHamiltonian`, `entropicTime`+theorems, `MeasurePathIntegralModel`+~25 theorems from `CATEPTMain/CATEPT/CATEPT/CATEPTPrelude.lean`.
2. Migrate ~10–15 catept-main consumers from `m.μ`/`α` to `m.mu`/`alpha` (catept-core uses Latin field names, catept-main uses Greek).
3. Drop `NavierStokesClean`'s vendored copy of `CATEPTMain/AFPBridge/CATEPT/CATEPTPrelude.lean` (3-way collision).

This is multi-day cross-repo work tracked under this same task. After it lands, every `OrphanAggregator` import works and the orphan-triage roots become individually visible/buildable.

## Recommended sequencing

The triage workload is much smaller than the headline number suggests — 24 roots, of which **8 are clear WIREs** (audits + showcase + honest-witness), **5 are aggregator decisions**, **7 are quarantined-rotted-bridges** (need fix-or-delete each), **3 are old foundations** (likely DELETE), and **1 is a small evaluate-and-keep**.

Suggested staging:

1. **Milestone 1 (this PR)**: planning doc — recorded.
2. **Milestone 2 — easy WIREs (1–2 hours)**: wire 8 obvious-keep roots into `CATEPTMain.lean`. Eliminates ~12+ leaves automatically.
3. **Milestone 3 — bundle decisions (2–4 hours)**: pick a per-bundle disposition (collapse into `OrphanAggregator` or wire individually). Eliminates ~50+ leaves.
4. **Milestone 4 — rotted bridge triage (2–6 hours)**: fix-or-delete each of the 7 quarantined bridges. The Lean-3 `constant`-keyword pattern is solved by the PR #50/#52/#54/#55 trivial-witness recipe.
5. **Milestone 5 — sibling-vs-local refactor (multi-day)**: the structural deduplication that lets `OrphanAggregator` fully compile.

After milestones 2–4, `OrphanAggregator` should be substantially smaller (its imports get folded into `CATEPTMain.lean` proper), and the live tree's "orphan" count should drop from 146 → ~30 (only the 41 docs + a handful of evaluate-and-delete leftovers).

## Companion tooling

The reachability scan that produced these counts is reproducible. Reviewers can re-run it from the repo root:

```bash
python3 -c "
from pathlib import Path; import re; from collections import defaultdict
ROOT = Path('.'); IMP = re.compile(r'^\s*import\s+([\w.]+)', re.MULTILINE)
files = [p for p in (ROOT/'CATEPTMain').rglob('*.lean') if '/Experimental/' not in str(p)]
mods = {str(p.relative_to(ROOT).with_suffix('')).replace('/', '.') for p in files}; mods.add('CATEPTMain')
imps = {str(p.relative_to(ROOT).with_suffix('')).replace('/', '.'):
        [i for i in IMP.findall(p.read_text()) if i in mods] for p in files+[ROOT/'CATEPTMain.lean']}
reached, frontier = set(), {'CATEPTMain'}
while frontier:
    m = frontier.pop()
    if m not in reached: reached.add(m); frontier |= set(imps.get(m,[]))
print(f'orphans={len(mods-reached)}, reached={len(reached)}, total={len(mods)}')
"
```
