import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import CATEPTMain.Integration.KMSModularParameterBridge
import CATEPTMain.Integration.RigorousComplexFeynmanKac
import CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge
import CATEPTMain.Integration.GravitasBridge
import CATEPTMain.Integration.QuantumInfoEntropyConsistencyBridge
import CATEPTMain.Integration.UnificationSpineHonestWitness
import CATEPTMain.Showcase.QMGRUnification

/-!
# CATEPT Showcase — substantive audit ledger

Reviewer-facing artifact for the publication-readiness umbrella's
`port_first_batch_20260505` task. After six phases of helper-walking
(`scripts/publication/HELPER_WALK.md`), 18 README-named theorems were
classified SUBSTANTIVE / SUBSTANTIVE-VIA-(HELPER, CHAIN, CARRIER).

This file collects the canonical declarations of each — and their
substance-bearing helpers where applicable — and runs `#print axioms`
on every entry. Each must report kernel-only `[propext, Classical.choice,
Quot.sound]`.

Coverage map:

| Group | Source of substance | Audited symbols |
|---|---|---|
| Pool A helpers (9 substantive) | `NavierStokesClean.CATEPT.{QuantumGravity, PathIntegrals}` | 8 helper theorems |
| Pool B direct (5 substantive) | `Integration/{MatsubaraLuttingerWardCarrier, KMSModularParameterBridge, GravitasBridge}` | 5 carrier theorems |
| Pool B via-helper (1) | `Integration/RigorousComplexFeynmanKac` | `complex_FK_rigorous` |
| Pool B via-chain (1, Phase 6) | `Integration/SimplexPathIntegralNoRenormBridge` | `exponential_uv_tail_implies_no_counterterm_needed` (+ helper `tendsto_cutoff_to_continuum`) |
| Outside-original (2, Phase 3) | `Integration/QuantumInfoEntropyConsistencyBridge` | `shannon_entropy_dirac_via_plugin`, `renyi_zero_eq_log_n_via_plugin` |
| Spine showcase (4) | `Showcase/QMGRUnification` | `qm_satisfies_catept_spine`, `gr_minkowski_satisfies_catept_spine`, `gr_electrovacuum_satisfies_catept_spine`, `qm_gr_unified_via_entropic_proper_time` |
| Honest constructor (1) | `Integration/UnificationSpineHonestWitness` | `honestUnificationBundle` |

The Pool A "feat/publication-side" wrapper theorems described as `*_pos`
/ `*_doubling` / `*_le_one` re-exports in `HELPER_WALK.md` table are
aspirational `CATEPT.Bridges.{Pphi2N, QFT, GR, Gravitas}` modules
that have not yet landed (the substance lives one layer down in the
NavierStokesClean helpers audited below). When those wrapper modules
land their `#print axioms` check belongs here.

-/

set_option autoImplicit false

/-! ## Pool A helpers — class-1/class-2 analytic / arithmetic content -/

#print axioms NavierStokesClean.CATEPT.eq046_schwarzschild_positive
#print axioms NavierStokesClean.CATEPT.eq147_152_bh_entropy_positive
#print axioms NavierStokesClean.CATEPT.eq049_unruh_temperature_positive
#print axioms NavierStokesClean.CATEPT.eq147_152_bh_entropy_scaling
#print axioms NavierStokesClean.CATEPT.eq147_152_bh_entropy_doubling
#print axioms NavierStokesClean.CATEPT.eq054_damping_magnitude
#print axioms NavierStokesClean.CATEPT.eq075_propagator_well_defined
#print axioms NavierStokesClean.CATEPT.eq075_propagator_positive

/-! ## Pool B SUBSTANTIVE direct — Matsubara closed-form algebra (B15, B16, B17) -/

#print axioms CATEPTMain.Integration.MatsubaraLuttingerWardCarrier.MatsubaraLuttingerWardCarrier.S_I_eq_hbar_tauEnt
#print axioms CATEPTMain.Integration.MatsubaraLuttingerWardCarrier.MatsubaraLuttingerWardCarrier.tauEnt_eq_neg_log_Z
#print axioms CATEPTMain.Integration.MatsubaraLuttingerWardCarrier.MatsubaraLuttingerWardCarrier.S_I_eq_hbar_neg_log_Z

/-! ## Pool B SUBSTANTIVE direct — KMS strip (B11) and Bohmian-EM (B21) -/

#print axioms CATEPTMain.Integration.KMSModularParameterBridge.kms_strip_separate_from_entropicProperTime
#print axioms CATEPTMain.Integration.GravitasBridge.bohmianEM_action_expansion

/-! ## Pool B SUBSTANTIVE-VIA-HELPER — Feynman–Kac calc-integral bound (B7) -/

#print axioms CATEPTMain.Integration.RigorousComplexFeynmanKac.complex_FK_rigorous

/-! ## Pool B SUBSTANTIVE-VIA-CHAIN — UV exponential tail (B8, finalized Phase 6) -/

#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge.exponential_uv_tail_implies_no_counterterm_needed
#print axioms CATEPTMain.Integration.SimplexPathIntegralNoRenormBridge.CountertermFreeUVLimit.tendsto_cutoff_to_continuum

/-! ## Outside-original (2 new SUBSTANTIVE-VIA-HELPER from Phase 3) -/

#print axioms CATEPTMain.Integration.QuantumInfoEntropyConsistencyBridge.shannon_entropy_dirac_via_plugin
#print axioms CATEPTMain.Integration.QuantumInfoEntropyConsistencyBridge.renyi_zero_eq_log_n_via_plugin

/-! ## Spine showcase — QM ↔ GR unification surface (4 theorems, post slot-`consistent` fix) -/

#print axioms CATEPT.Showcase.QMGRUnification.qm_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_minkowski_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.gr_electrovacuum_satisfies_catept_spine
#print axioms CATEPT.Showcase.QMGRUnification.qm_gr_unified_via_entropic_proper_time

/-! ## Honest non-degenerate `CATEPTUnificationBundle` constructor

The Pattern-1 disposition for Pool B's BUNDLING capstones (B1, B3-B6).
Each cross-pillar field is discharged by a SUBSTANTIVE-verdict carrier
theorem rather than `0 = 0`; see `scripts/publication/CONSTRUCTOR_PLAN.md`. -/

#print axioms CATEPTMain.Integration.UnificationSpineHonestWitness.honestUnificationBundle
