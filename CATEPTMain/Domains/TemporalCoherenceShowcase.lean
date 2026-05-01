import CATEPTMain.Domains.TemporalSynchronization
import CATEPTMain.Integration.PhyslibCATEPTSpaceTimeAdapter

/-!
# TemporalCoherenceShowcase — Cross-Theory Time Audit Surface

Dedicated audit-gate dashboard for the cross-domain temporal-synchronization
layer.  Audits:
- the `SharedClockWitness` infrastructure and the harmonic ⊕ minkowski ⊕ qm
  three-way demo at τ = 0,
- the `LorentzianSpaceTime` abstraction layer and its Physlib SR instance,
- the joint **QM ⊕ classical ⊕ Physlib-SR** framework spine identification.

This file is **intentionally separate** from `CoherenceShowcase.lean`.  The
latter is the spine + per-adapter + per-invariant audit surface that
actively-running parallel work (path-integral T-A → T-W series) appends to;
keeping the temporal-synchronization audit in its own file avoids merge
collisions on every commit while still exposing the kernel-axiom check.

Expected (every line on `[propext, Classical.choice, Quot.sound]`):

  Pairwise lemmas:
    SharedClockWitness.refl
    SharedClockWitness.symm
    SharedClockWitness.trans
    SharedClockWitness.sharedτ_nonneg

  Pairwise demos at τ = 0:
    harmonicMinkowskiSync
    harmonicQMSync
    qmMinkowskiSync

  Triple-domain synchronization:
    tripleSyncAtZero
    tripleSync_sharedτ_eq_zero
    tripleSync_transitive

Any axiom outside `[propext, Classical.choice, Quot.sound]` is a
regression — the SharedClockWitness layer must add zero non-kernel
dependencies.
-/

namespace CATEPTMain.Temporal

-- ═══════════════════════════════════════════════════════════════════════
-- KERNEL-AXIOM AUDIT — SharedClockWitness lemmas
-- ═══════════════════════════════════════════════════════════════════════

#print axioms CATEPTMain.Temporal.SharedClockWitness.refl
#print axioms CATEPTMain.Temporal.SharedClockWitness.symm
#print axioms CATEPTMain.Temporal.SharedClockWitness.trans
#print axioms CATEPTMain.Temporal.SharedClockWitness.sharedτ_nonneg

-- ═══════════════════════════════════════════════════════════════════════
-- KERNEL-AXIOM AUDIT — pairwise demos at τ = 0
-- ═══════════════════════════════════════════════════════════════════════

#print axioms CATEPTMain.Temporal.harmonicMinkowskiSync
#print axioms CATEPTMain.Temporal.harmonicQMSync
#print axioms CATEPTMain.Temporal.qmMinkowskiSync

-- ═══════════════════════════════════════════════════════════════════════
-- KERNEL-AXIOM AUDIT — triple-domain synchronization
-- ═══════════════════════════════════════════════════════════════════════

#print axioms CATEPTMain.Temporal.tripleSyncAtZero
#print axioms CATEPTMain.Temporal.tripleSync_sharedτ_eq_zero
#print axioms CATEPTMain.Temporal.tripleSync_transitive

end CATEPTMain.Temporal

-- ═══════════════════════════════════════════════════════════════════════
-- KERNEL-AXIOM AUDIT — Physlib ↔ CAT/EPT SpaceTime Adapter
-- ═══════════════════════════════════════════════════════════════════════

-- Generic LorentzianSpaceTime → TemporalFramework lift:
#print axioms CATEPTMain.Integration.LorentzianSpaceTime.toTemporalFramework
#print axioms CATEPTMain.Integration.LorentzianSpaceTime.coherence_spine_of_lift
#print axioms CATEPTMain.Integration.LorentzianSpaceTime.liveOfTimelike

-- Physlib SR instance + named lift:
#print axioms CATEPTMain.Integration.physlibLorentzianSpaceTime
#print axioms CATEPTMain.Integration.physlibSRTemporalFramework
#print axioms CATEPTMain.Integration.physlibSRTemporalFramework_coherent
#print axioms CATEPTMain.Integration.physlibSRLive

-- Joint QM ⊕ classical ⊕ Physlib-SR framework:
#print axioms CATEPTMain.Integration.harmonicSRQM
#print axioms CATEPTMain.Integration.harmonicSRQM_satisfies_spine
#print axioms CATEPTMain.Integration.harmonicSRQM_clock_decomposition
