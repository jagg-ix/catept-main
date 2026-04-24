# Target 1 — Physical-identification assumptions are greppable, countable, and CI-gated

**Priority**: p1 (recommended first of the four rework targets)
**Worklog task**: [`catept_arch_assumption_registry_20260424`](../../../)  (in worklog DB)
**Estimated effort**: ~1 day focused
**Status**: todo (ready to claim)
**Related docs**: [`../plugin-rework-proposal.md`](../plugin-rework-proposal.md) · [`../../collaboration/parallel-execution.md`](../../collaboration/parallel-execution.md)

---

## 1. Why this matters (why pick it first)

Adopts PhysicsLogic's `PhysicsAssumption` pattern: every physical-identification
premise in catept-main becomes a tagged, greppable, countable proposition
with a stable string id. This is prerequisite infrastructure for:

- **Tightening the axiom-gate CI**: no new assumption without a matching id
- **Auto-generated `ASSUMPTIONS.md`** (PhysicsLogic ships a 260-entry registry)
- **Future rework steps** (Superior-Method bridges) that will want to retire
  specific ids as they move from assumed to derived

Low risk (mostly text/annotation work, no proof changes). High payoff
(enables machine audit of physics content). Exactly the kind of work that
should land before anything more invasive.

## 2. Claiming this target

```bash
export DB=/Users/macbookpro/lab/tau/tau-information-dynamics/database/workstation_worklog.sqlite3
export PYTHONPATH=/Users/macbookpro/lab/tau/tau-information-dynamics/entropic-worklog-tool
export YOUR_HANDLE=claude-opus-4-7-worker-a     # substitute your registered handle
export CODE=catept_arch_assumption_registry_20260424

# Verify the task isn't already claimed:
python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','list-agents']; main()" 2>/dev/null || \
sqlite3 $DB "SELECT status, updated_at FROM tasks WHERE code = '$CODE';"

# Claim:
python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','set-task-status','--code','$CODE','--status','in_progress']
main()"

python3 -c "
from ept_worklog.cli import main; import sys
sys.argv=['wl','--db','$DB','log-note',
  '--title','Claiming Target 1 — assumption registry',
  '--body','Starting. Branch feat/$YOUR_HANDLE/assumption-registry. Clone catept-main-a/. ETA ~8h.',
  '--agent','$YOUR_HANDLE',
  '--kind','coordination',
  '--task-code','$CODE']
main()"
```

## 3. Setup — your own clone and branch

```bash
# Own clone (avoids .lake/ contention with other helpers)
cd /Users/macbookpro/lab/tau/tau-information-dynamics/
git clone https://github.com/jagg-ix/catept-main.git catept-main-a
cd catept-main-a
git checkout -b feat/$YOUR_HANDLE/assumption-registry

# Warm the Mathlib olean cache once
lake exe cache get
```

## 4. Scope — five concrete deliverables

| # | Deliverable | Acceptance criterion |
|---|---|---|
| D1 | `CATEPTMain/Core/Assumptions.lean` — new file | Compiles; defines `CATEPTAssumption` abbrev + `AssumptionId` namespace; exports ≥ 10 id constants covering current physical-identification assumptions |
| D2 | Retrofit ≥ 5 existing sites to use the wrapper | Build still green after retrofit; identifier call sites show `CATEPTAssumption AssumptionId.foo (...)` rather than raw `axiom foo : ...` |
| D3 | `docs/architecture/ASSUMPTIONS.md` — auto-generated | Python generator script under `tools/docs/gen_assumptions_md.py`; output lists each registered id, its reference count, and whether it's dead (zero refs) |
| D4 | Axiom-gate CI extension | `.github/workflows/axiom-gate.yml` has a step that fails when `CATEPTAssumption "<string>"` occurs with `<string>` absent from `AssumptionId` namespace |
| D5 | PR merged to `main` | CI green; publication bridges still kernel-only; free helper's approval note on the worklog task |

## 5. Code scaffolds (paste and adapt)

### D1 — `CATEPTMain/Core/Assumptions.lean`

```lean
/-
Physical-identification assumption registry.

Every non-derived physical premise in catept-main wraps through the
`CATEPTAssumption` abbrev with a stable string id. This enables:
  * `rg "AssumptionId\.\\w+"` to enumerate every registered premise,
  * auto-generated `docs/architecture/ASSUMPTIONS.md` (refs, counts, dead list),
  * CI gate that rejects unregistered ids.

Pattern borrowed from PhysicsLogic/xiyin137 — see
docs/architecture/plugin-rework-proposal.md §2.
-/

namespace CATEPTMain

/-- Explicit, labeled physical assumption.

`CATEPTAssumption id P` is definitionally `P`; the string carries no proof
power. Its role is traceability: every non-derived physical premise should
have a stable id. -/
abbrev CATEPTAssumption (_id : String) (P : Prop) : Prop := P

/-- Stable identifiers for project-level physical assumptions.

Keep these ids stable so grep/CI history stays meaningful. When retiring
an assumption (replacing its use site with a theorem), leave the id here
with a `-- RETIRED on <date> by <theorem>` comment rather than deleting. -/
namespace AssumptionId

-- CAT/EPT core
def hbarIsTwoNu                : String := "catept.hbar_is_2nu"
  -- ℏ = 2ν Constantin–Iyer identification (used in Route 6 NS)
def entropicTimeDefinition     : String := "catept.entropic_time_def"
  -- τ_ent = S_I / ℏ (baseline definition)

-- PDE / Navier–Stokes side
def weylLaw                    : String := "pde.weyl_law"
def bkmCriterion               : String := "ns.bkm_criterion"
def agmonEstimate              : String := "pde.agmon_estimate"
def fourierPalinstrophy        : String := "ns.fourier_palinstrophy"

-- QFT side
def osterwalderSchraderOS0     : String := "qft.os.os0_analyticity"
def reflectionPositivity       : String := "qft.os.reflection_positivity"

-- GR side
def bianchiImpliesConservation : String := "gr.bianchi_implies_conservation"
def hawkingTemperatureFormula  : String := "gr.hawking_temperature"

end AssumptionId

end CATEPTMain
```

### D2 — retrofit example

**Before** (hypothetical raw axiom somewhere in the tree):

```lean
/-- Constantin–Iyer identification ℏ = 2ν for Route 6 NS. -/
axiom hbar_eq_two_nu (ν : ℝ) (hν : 0 < ν) : ∃ (hbar : ℝ), hbar = 2 * ν
```

**After**:

```lean
import CATEPTMain.Core.Assumptions
open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId

/-- Constantin–Iyer identification ℏ = 2ν for Route 6 NS. -/
theorem hbar_eq_two_nu (ν : ℝ) (hν : 0 < ν) :
    CATEPTAssumption hbarIsTwoNu (∃ (hbar : ℝ), hbar = 2 * ν) := by
  exact ⟨2 * ν, rfl⟩
```

Since `CATEPTAssumption id P := P` is a definitional abbreviation, the
proof obligation is unchanged. The only mechanical difference: the
`CATEPTAssumption AssumptionId.hbarIsTwoNu` wrapper makes the site
greppable and registry-checked.

**For sites that are genuinely `axiom` (not yet provable)**: keep the
`axiom` keyword and just wrap the body:

```lean
axiom weyl_law (λ_N : ℕ → ℝ) :
  CATEPTAssumption AssumptionId.weylLaw
    (∀ N, ∃ C, λ_N N ≤ C * (N : ℝ) ^ (2/3))
```

### D3 — `tools/docs/gen_assumptions_md.py`

```python
#!/usr/bin/env python3
"""Generate docs/architecture/ASSUMPTIONS.md by grepping the Lean tree."""
import re
import subprocess
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ID_DEF_RE = re.compile(r'def\s+(\w+)\s*:\s*String\s*:=\s*"([^"]+)"')
CALL_RE = re.compile(r'CATEPTAssumption\s+(?:AssumptionId\.)?(\w+)\b')

# 1. Collect registered ids (from Assumptions.lean)
assumptions_file = ROOT / "CATEPTMain" / "Core" / "Assumptions.lean"
registered = {}  # const_name -> payload_string
for m in ID_DEF_RE.finditer(assumptions_file.read_text()):
    registered[m.group(1)] = m.group(2)

# 2. Count references across the tree
refs = Counter()
for p in ROOT.rglob("*.lean"):
    if ".lake" in p.parts or p == assumptions_file:
        continue
    try:
        for m in CALL_RE.finditer(p.read_text()):
            refs[m.group(1)] += 1
    except UnicodeDecodeError:
        pass

# 3. Emit markdown
out = ROOT / "docs" / "architecture" / "ASSUMPTIONS.md"
lines = [
    "# CATEPT Assumption Registry",
    "",
    f"- **Registered assumptions**: {len(registered)}",
    f"- **Referenced in source**: {sum(1 for k in registered if refs[k] > 0)}",
    f"- **Dead (zero references)**: {sum(1 for k in registered if refs[k] == 0)}",
    "",
    "| AssumptionId | Payload | Refs |",
    "|---|---|---:|",
]
for const, payload in sorted(registered.items()):
    lines.append(f"| `{const}` | `{payload}` | {refs[const]} |")
out.write_text("\n".join(lines) + "\n")
print(f"Wrote {out} ({len(registered)} entries, {sum(refs.values())} total refs)")
```

Run via `python3 tools/docs/gen_assumptions_md.py`.

### D4 — CI extension for `.github/workflows/axiom-gate.yml`

Insert this step **before** the final "Check sorry count" steps:

```yaml
    - name: Check assumption-registry consistency
      run: |
        cat > /tmp/check_registry.py << 'EOF'
        import re, sys
        from pathlib import Path
        ROOT = Path(".")
        ID_DEF_RE = re.compile(r'def\s+(\w+)\s*:\s*String\s*:=\s*"([^"]+)"')
        CALL_RE = re.compile(r'CATEPTAssumption\s+(?:AssumptionId\.)?(\w+)\b')

        registered = set()
        for m in ID_DEF_RE.finditer(
            (ROOT / "CATEPTMain/Core/Assumptions.lean").read_text()
        ):
            registered.add(m.group(1))

        bad = set()
        for p in ROOT.rglob("*.lean"):
            if ".lake" in p.parts: continue
            if p.name == "Assumptions.lean": continue
            for m in CALL_RE.finditer(p.read_text(errors='ignore')):
                if m.group(1) not in registered:
                    bad.add((str(p), m.group(1)))

        if bad:
            for path, name in sorted(bad):
                print(f"REGRESSION: {path} uses unregistered id {name!r}")
            sys.exit(1)
        print(f"OK: {len(registered)} registered ids, all call sites tagged")
        EOF
        python3 /tmp/check_registry.py
```

## 6. Execution plan (step-by-step)

1. **Create** `CATEPTMain/Core/Assumptions.lean` (D1). `lake build CATEPTMain.Core.Assumptions` passes.
2. **Pick 5-10 retrofit sites** by grepping for `^axiom ` in `CATEPTMain/`:
   ```bash
   rg -n "^axiom " CATEPTMain/ --type lean | head -20
   ```
   Pick ones with the simplest signatures first. Avoid files deep in `NavierStokes/` or `CATEPTMain/AFPBridge/` for the PoC pass (many interrelated axioms; leave for a later full-retrofit PR).
3. **Retrofit** each site using the pattern in §5 D2. After each, run `lake build <module>` to confirm green.
4. **Add ids** to `AssumptionId` namespace for every new retrofit.
5. **Write the generator** `tools/docs/gen_assumptions_md.py` (paste §5 D3).
6. **Run the generator** and commit the output `docs/architecture/ASSUMPTIONS.md`.
7. **Extend axiom-gate CI** per §5 D4.
8. **Full build verification**:
   ```bash
   lake build CATEPTMain
   lake build CATEPT.Bridges.Pphi2N CATEPT.Bridges.QFT CATEPT.Bridges.GR \
              CATEPT.Bridges.Gravitas CATEPT.Bridges.OSReconstruction
   ```
   All green; publication-bridge `#print axioms` shows only the kernel triad.
9. **Commit + push** `feat/$YOUR_HANDLE/assumption-registry`.
10. **Open PR** against `main`. Title: "Add CATEPTAssumption tagged-assumption registry". Link the worklog task in the description.
11. **Log milestone note**:
    ```bash
    python3 -c "
    from ept_worklog.cli import main; import sys
    sys.argv=['wl','--db','$DB','log-note',
      '--title','Target 1 complete — assumption registry landed',
      '--body','PR #<n> merged. N ids registered, M retrofitted, CI green, publication bridge axiom surface unchanged.',
      '--agent','$YOUR_HANDLE','--kind','milestone','--task-code','$CODE']
    main()"
    ```
12. **Mark task done**:
    ```bash
    python3 -c "
    from ept_worklog.cli import main; import sys
    sys.argv=['wl','--db','$DB','set-task-status','--code','$CODE','--status','done']
    main()"
    ```

## 7. Verification checklist (pre-merge)

- [ ] `CATEPTMain/Core/Assumptions.lean` compiles standalone
- [ ] `AssumptionId` namespace contains at least 10 entries
- [ ] At least 5 retrofitted sites in `CATEPTMain/` call `CATEPTAssumption`
- [ ] `docs/architecture/ASSUMPTIONS.md` is present, committed, and reflects current counts
- [ ] `tools/docs/gen_assumptions_md.py` is idempotent (re-running produces no diff)
- [ ] CI workflow `.github/workflows/axiom-gate.yml` has the new `Check assumption-registry consistency` step
- [ ] `lake build CATEPTMain` green
- [ ] `#print axioms` on every theorem in `CATEPT/Bridges/*` and `CATEPT/Showcase/QMGRUnification` still reports **only** `{propext, Classical.choice, Quot.sound}` — no regression
- [ ] PR title + body references `catept_arch_assumption_registry_20260424`

## 8. Handoff protocol (if you stop mid-task)

1. Commit and push what works on your branch.
2. Log a handoff note:
   ```bash
   python3 -c "
   from ept_worklog.cli import main; import sys
   sys.argv=['wl','--db','$DB','log-note',
     '--title','Handoff: Target 1 partial',
     '--body','Branch feat/$YOUR_HANDLE/assumption-registry at <sha>. Completed: <list>. Remaining: <list>. Known blockers: <...>. Suggested next step: <...>.',
     '--agent','$YOUR_HANDLE','--kind','handoff','--task-code','$CODE']
   main()"
   ```
3. Leave task `in_progress` — do **not** revert to `todo`. Future helpers
   read the handoff before resuming.

## 9. FAQ / gotchas

**Q. Does `abbrev CATEPTAssumption` change what `#print axioms` reports?**
No. `abbrev` is a definitional abbreviation; terms reduce through it. The
kernel axiom list is unaffected. That's the point — we get traceability
without changing proof power.

**Q. Do I need to retrofit every single `axiom` in the tree?**
No. Target 1 is the PoC: establish the pattern, retrofit 5-10 sites to
demonstrate, wire the CI check. A full retrofit pass is a separate follow-up
(not p1 urgent).

**Q. What if a retrofit breaks a downstream proof?**
Shouldn't happen — `CATEPTAssumption id P` is definitionally `P`, so the
term elaborates identically. If you hit an elaboration issue, it's almost
certainly because an implicit argument got re-resolved; add explicit
argument annotations or fall back to `show` tactic. Log a debug note and
ask the free helper for a pair.

**Q. Can I batch D1-D5 into one commit or should they be separate?**
Separate commits are preferred (D1 + ids, D2 per retrofit file, D3 script
+ generated md, D4 CI, D5 is the merged PR itself). Reviewers can then
inspect each layer independently.

**Q. The axiom-gate check in D4 uses regex — is that robust?**
Robust enough for the PoC. A future pass could use Lean's own
metaprogramming to enumerate `CATEPTAssumption` call sites via
`Lean.Environment` traversal. Document that follow-up as a p2 task.

---

**When this target is done**, Target 2 (cross-domain diagram) becomes easier
(the registry provides natural labels for diagram edges), and Target 3
(Superior-Method bridges) has a natural way to mark "retired assumption"
events in the history.
