import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.CoherenceSpine
import CATEPTMain.Domains.JointAdapter
import CATEPTMain.Integration.UnificationSpine
import CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge
-- Pre-existing orphan-recovery wiring: bring PR #12/#13/#14 capstones
-- onto the spine (previously imported nowhere from the root barrel).
import CATEPTMain.Integration.TomitaMatsubaraAQFTSpineBridge
import CATEPTMain.Integration.TwinParadoxEntropicProperTimeBridge
import CATEPTMain.Integration.TwinParadoxAccelerationBoundsBridge

/-!
# RepoSpine — canonical “single import” for the CAT/EPT unification surface

This module exists to prevent **proof islands**.

If a helper adds a new theorem that is meant to be *load-bearing evidence* for
"CAT/EPT unifies QM, thermodynamics, electromagnetism, and GR", that theorem
should become reachable from one of the repo’s explicit spine entrypoints.

`CATEPTMain.RepoSpine` is the smallest such entrypoint that:

1. Exposes the **kernel temporal contract** (`TemporalFramework`).
2. Exposes the **structural unification** via joint sums (`JointAdapter`).
3. Exposes the **four-pillar capstone** (QM/Thermo/EM/GR) via
   `Integration.UnificationSpine`.
4. Exposes the **Paper 2 foundations spine** (Tiers A/B/C: 9 carrier-
   level bridges, 55 theorems) via
   `Integration.Paper2TierAUnifiedBundleBridge` (which doubles as
   the Tier B unified-bundle and as the Paper 2 spine aggregator,
   following the `UnificationSpine.CATEPTUnificationBundle` pattern).
5. Exposes pre-existing capstones from PRs #12/#13/#14 that were
   shipped without root-barrel wiring:
   `TomitaMatsubaraAQFTSpineBridge`,
   `TwinParadoxEntropicProperTimeBridge`,
   `TwinParadoxAccelerationBoundsBridge`.

Practical rule:

* If it is a capstone theorem, wire it here.
* If it is exploratory or lane-local, keep it out of this file and label it as
  such in its own module docstring (so it is an intentional island).
-/

set_option autoImplicit false

namespace CATEPTMain.RepoSpine

-- Kernel temporal contract + single global coherence theorem.
export CATEPTMain.Temporal (TemporalFramework LiveTemporalFramework)
export CATEPTMain.Temporal.TemporalFramework (coherence_spine)

-- Three-domain coherence spine (vacuum GR/Minkowski + live EM + live VML).
export CATEPTMain.Temporal (
  coherence_spine_GR_EM_VML
  live_dynamics_EM_VML)

-- Structural join: QM ⊕ GR ⊕ Maxwell (and the curved Maxwell extension).
export CATEPTMain.Temporal.Adapter (
  maxwellGRQM
  maxwellGRQM_satisfies_spine
  maxwellGRQM_clock_decomposition
  maxwellGRQMcurved
  maxwellGRQMcurved_satisfies_spine
  maxwellGRQMcurved_clock_decomposition)

-- Four-pillar capstone: QM / Thermo / EM / GR share a single τ_ent scalar
-- (carrier-level).
export CATEPTMain.Integration.UnificationSpine.CATEPTUnificationBundle (
  catept_unifies_QM_Thermo_EM_GR
  unification_via_modular_flow)

-- Paper 2 foundations spine (Tiers A/B/C: 9 carrier-level bridges
-- formalising `Paper2_CAT_EPT_Foundations (6).pdf` §3.2/§3.3/§4.2/§4.3/§5
-- and Appendices A/B/C).  Single-source export from
-- `Paper2TierAUnifiedBundleBridge` (which re-exports each Tier
-- module's named capstone), matching the `UnificationSpine` pattern.
export CATEPTMain.Integration.Paper2TierAUnifiedBundleBridge (
  paper2_foundations_bundle
  paper2_tier_a_unified_bundle
  thermal_hamiltonian_entropic_time_bundle
  page_wootters_dissipative_extension_bundle
  uv_coercivity_absolute_damping_bundle
  entropic_propagator_envelope_bundle
  everett_branch_suppression_bundle
  zero_dim_quadratic_action_concrete_bundle
  dbb_quantum_potential_bundle
  entropy_increase_along_worldline_bundle)

-- Pre-existing orphan-recovery: capstones from PRs #12/#13/#14
-- (Tomita-Matsubara AQFT spine; SR/entropic proper-time
-- identification; acceleration-bounded twin-paradox minima).  These
-- shipped without being imported from the root barrel and were
-- effectively orphans.
export CATEPTMain.Integration.TomitaMatsubaraAQFTSpineBridge (
  tomita_matsubara_aqft_spine_bundle)
export CATEPTMain.Integration.TwinParadoxEntropicProperTimeBridge (
  sr_proper_time_separate_from_entropic_proper_time)
export CATEPTMain.Integration.TwinParadoxAccelerationBoundsBridge (
  twin_paradox_acceleration_bounds_bundle)

end CATEPTMain.RepoSpine

