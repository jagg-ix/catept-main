import CATEPTMain.Integration.GravitasBridge
import CATEPTMain.Integration.VMLCATEPTBridge
import CATEPTMain.Integration.TheoryPluginAdapter
import CATEPTMain.Integration.TheoryPluginClassicalETHBridge
import CATEPTMain.Integration.BCJBridge
import CATEPTMain.Integration.ElectroweakCATEPTBridge
import CATEPTMain.Integration.UnifiedTheorySpine
import CATEPTMain.CATEPT.CATEPT.PlanckModeBridge
import CATEPTMain.NHQM.NHQMCATEPTBridge

/-!
# Slot-`consistent` fix — kernel-axiom audit (Step 1 of
`catept_pub_slot_consistent_fix_20260506`)

Reviewer-facing reproducible audit confirming that every CATEPTPluginSlot
constructor in catept-main now ships its `consistent` field with a
proof that goes through the Lean kernel — no `sorry`, no framework axiom.

Background. After the F1 sibling change in
`catept-plugin-architecture` (commit `5173b04b`), every
`CATEPTPluginSlot` carries a required `consistent` field. The 8
constructor sites in catept-main supply it inline at construction. F3
(this file) showcases the substantive case `bohmianEMCATEPTSlot`
where `actionIm` (compact `‖v − A‖²/2`) and `eptClock` (expanded
`‖v‖²/2 − ⟨v,A⟩ + ‖A‖²/2`) are syntactically distinct but
mathematically equal — the consistency proof has to invoke `ring` on
the four-fold expansion and is genuinely substantive.

Each `#print axioms` directive must report
`[propext, Classical.choice, Quot.sound]` — kernel-only.
-/

-- ── F2 sites ────────────────────────────────────────────────────────
#print axioms CATEPTMain.Integration.VMLCATEPTBridge.kineticCATEPTSlot
#print axioms CATEPTMain.Integration.adapterCATEPTSlot
#print axioms CATEPTMain.Integration.classicalETHSiteSlot
#print axioms CATEPTMain.Integration.BCJBridge.bcjProductSlot
#print axioms CATEPTMain.Integration.ElectroweakCATEPTBridge.higgsCATEPTSlot
#print axioms CATEPTMain.Integration.UnifiedSpine.modularFlowCATEPTSlot
#print axioms CATEPTMain.CATEPT.CATEPT.PlanckModeBridge.cateptPlanckSlot
#print axioms CATEPTMain.NHQM.NHQMCATEPTBridge.nhqmCATEPTSlot

-- ── F3 substantive case ───────────────────────────────────────────
-- This is the slot whose `consistent` is a real algebraic identity
-- (`ring` on the expansion of `(v_μ − A_μ)²`), not a `div_one`
-- triviality. The slot is constructed *directly* as a
-- `CATEPTPluginSlot`, not via `SuperiorMethodSlot.toCATEPTSlot`,
-- so `actionIm ≠ eptClock` syntactically.
#print axioms CATEPTMain.Integration.GravitasBridge.bohmianEMCATEPTSlot
#print axioms CATEPTMain.Integration.GravitasBridge.bohmianEMCATEPTSlot_consistent
