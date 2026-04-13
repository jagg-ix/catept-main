import NavierStokes.NSK41EPTUniversalityBridge
import NavierStokes.ThermodynamicRegularityBridge
import NavierStokes.SubcriticalConditionalRegularity

/-!
# NSKolmogorovTuringRefinementBridge

Bridges the current NS CAT/EPT K41 ladder route with a finite-cutoff
("machine-certifiable") route in a way that makes the unresolved transport
obligation explicit.

Key idea:
- K41 lane gives post-threshold control (`τ_ent ≥ τ_iso`).
- A finite-cutoff lane can target pre-threshold control (`τ_ent ≤ τ_iso`).
- Gluing both yields all-time `VS ≤ νP` for the large-data branch.

This file is intentionally minimal and proof-structural.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

open NavierStokes.SubcriticalRegularity

/-- Canonical initial enstrophy square. -/
def initialEnstrophySq (traj : Trajectory NSField) : Rat :=
  enstrophy (traj.stateAt 0).velocity *
    enstrophy (traj.stateAt 0).velocity

/-- Canonical stage cutoff used by the K41 large-data split. -/
def largeDataCutoff : Rat :=
  40 * (nsNu * nsNu * nsNu * nsNu)

/-- Local VS≤νP predicate (same inequality shape as the root contract). -/
def LocalVSLeNuP (traj : Trajectory NSField) (t : Rat) : Prop :=
  vortexStretchingIntegral traj t ≤
    nsNu * palinstrophy (traj.stateAt t).velocity

/-- A finite-cutoff (machine-checkable) certificate up to entropic bound `K`.

This abstracts a lane where one verifies the inequality only for states/times whose
entropic proper time has not exceeded a finite horizon/cutoff. -/
def MachineCutoffCert (K : Rat) : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    entropicProperTime traj t ≤ K →
    LocalVSLeNuP traj t

/-- Monotonicity in cutoff: a certificate at `K₂` yields one at any `K₁ ≤ K₂`. -/
theorem machineCutoffCert_mono
    {K1 K2 : Rat}
    (hLe : K1 ≤ K2)
    (hK2 : MachineCutoffCert K2) :
    MachineCutoffCert K1 := by
  intro traj t ht hNS hFS hTau
  exact hK2 traj t ht hNS hFS (le_trans hTau hLe)

/-- Single-trajectory adapter:
a machine certificate at the exact K41 threshold `τ_iso` discharges the
pre-threshold region for that trajectory. -/
theorem prethreshold_of_machine_cutoff
    (traj : Trajectory NSField)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hLarge : initialEnstrophySq traj > largeDataCutoff)
    (hMC : MachineCutoffCert (tauIso traj hNS hFS hLarge)) :
    ∀ (t : Rat),
      0 ≤ t →
      entropicProperTime traj t ≤ tauIso traj hNS hFS hLarge →
      LocalVSLeNuP traj t := by
  intro t ht hTau
  exact hMC traj t ht hNS hFS hTau

/-- Single-trajectory adapter with an upper-bound cutoff:
if a machine certificate is available at `K ≥ τ_iso`, monotonicity yields the
exact pre-threshold contract at `τ_iso`. -/
theorem prethreshold_of_machine_cutoff_upper
    (traj : Trajectory NSField)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hLarge : initialEnstrophySq traj > largeDataCutoff)
    (K : Rat)
    (hTauLeK : tauIso traj hNS hFS hLarge ≤ K)
    (hMC : MachineCutoffCert K) :
    ∀ (t : Rat),
      0 ≤ t →
      entropicProperTime traj t ≤ tauIso traj hNS hFS hLarge →
      LocalVSLeNuP traj t := by
  have hAtTau : MachineCutoffCert (tauIso traj hNS hFS hLarge) :=
    machineCutoffCert_mono hTauLeK hMC
  exact prethreshold_of_machine_cutoff traj hNS hFS hLarge hAtTau

/-- Global family contract:
for each large-data trajectory, a machine certificate at `τ_iso` exists. -/
def MachineFamilyAtTauIso : Prop :=
  ∀ (traj : Trajectory NSField)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hLarge : initialEnstrophySq traj > largeDataCutoff),
    MachineCutoffCert (tauIso traj hNS hFS hLarge)

/-- Large-data pre-threshold lane.

Given the K41 threshold witness `τ_iso`, this contract asks for a constructive
proof/certificate on the complementary region `τ_ent ≤ τ_iso`. -/
def LargeDataPreThresholdContract : Prop :=
  ∀ (traj : Trajectory NSField)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hLarge :
      initialEnstrophySq traj > largeDataCutoff),
    let τiso := tauIso traj hNS hFS hLarge
    ∀ (t : Rat),
      0 ≤ t →
      entropicProperTime traj t ≤ τiso →
      LocalVSLeNuP traj t

/-- Global adapter: a machine family at `τ_iso` yields the full
`LargeDataPreThresholdContract`. -/
theorem largeDataPreThreshold_of_machine_family
    (hFam : MachineFamilyAtTauIso) :
    LargeDataPreThresholdContract := by
  intro traj hNS hFS hLarge
  exact prethreshold_of_machine_cutoff traj hNS hFS hLarge
    (hFam traj hNS hFS hLarge)

/-- K41 post-threshold control already available in the current development. -/
theorem k41_post_threshold_control
    (traj : Trajectory NSField)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hLarge :
      initialEnstrophySq traj > largeDataCutoff) :
    ∀ (t : Rat),
      0 ≤ t →
      tauIso traj hNS hFS hLarge ≤ entropicProperTime traj t →
      LocalVSLeNuP traj t := by
  intro t ht hTau
  exact vs_le_nuP_of_ept traj hNS hFS hLarge t ht hTau

/-- Large-data gluing theorem: pre-threshold + K41 post-threshold gives all-time control.

This theorem isolates the remaining burden to `LargeDataPreThresholdContract`.
No new PDE content is asserted here. -/
theorem largeData_all_times_of_prethreshold
    (hPre : LargeDataPreThresholdContract)
    (traj : Trajectory NSField)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj)
    (hLarge :
      initialEnstrophySq traj > largeDataCutoff) :
    ∀ (t : Rat), 0 ≤ t → LocalVSLeNuP traj t := by
  intro t ht
  let τiso := tauIso traj hNS hFS hLarge
  have hSplit : entropicProperTime traj t ≤ τiso ∨ τiso ≤ entropicProperTime traj t :=
    le_total (entropicProperTime traj t) τiso
  cases hSplit with
  | inl hLE =>
      exact (hPre traj hNS hFS hLarge) t ht hLE
  | inr hGE =>
      exact k41_post_threshold_control traj hNS hFS hLarge t ht hGE

/-- Meta-reduction theorem:

If one has a family of finite-cutoff certificates strong enough to discharge the
large-data pre-threshold region, then K41 closes the complementary post-threshold
region. This is the precise "ladder + machine" composition shape. -/
theorem ladder_plus_machine_reduction
    (hPre : LargeDataPreThresholdContract) :
    ∀ (traj : Trajectory NSField)
      (_hNS : SatisfiesNSPDE nsOps nsNu traj)
      (_hFS : RespectsFunctionSpaces nsSpacesR3 traj)
      (_hLarge : initialEnstrophySq traj > largeDataCutoff),
      ∀ (t : Rat), 0 ≤ t → LocalVSLeNuP traj t := by
  exact largeData_all_times_of_prethreshold hPre

/-- End-to-end large-data route:
machine family at `τ_iso` + K41 post-threshold control gives all-time VS≤νP. -/
theorem largeData_all_times_of_machine_family
    (hFam : MachineFamilyAtTauIso) :
    ∀ (traj : Trajectory NSField)
      (_hNS : SatisfiesNSPDE nsOps nsNu traj)
      (_hFS : RespectsFunctionSpaces nsSpacesR3 traj)
      (_hLarge : initialEnstrophySq traj > largeDataCutoff),
      ∀ (t : Rat), 0 ≤ t → LocalVSLeNuP traj t := by
  exact ladder_plus_machine_reduction
    (largeDataPreThreshold_of_machine_family hFam)

/-- Small-data all-time contract (complementary branch to K41 large-data lane). -/
def SmallDataAllTimesContract : Prop :=
  ∀ (traj : Trajectory NSField)
    (_hNS : SatisfiesNSPDE nsOps nsNu traj)
    (_hFS : RespectsFunctionSpaces nsSpacesR3 traj),
    initialEnstrophySq traj ≤ largeDataCutoff →
    ∀ (t : Rat), 0 ≤ t → LocalVSLeNuP traj t

/-- Full split reduction:
if small-data trajectories are covered and large-data trajectories are covered by
the machine+ladder route, then the root real-sector contract holds. -/
theorem realNoether_contract_of_small_large_split
    (hSmall : SmallDataAllTimesContract)
    (hLargeFam : MachineFamilyAtTauIso) :
    RealNoetherToSliceVSContract := by
  intro traj t ht hNS hFS
  have hSplit : initialEnstrophySq traj ≤ largeDataCutoff ∨
      initialEnstrophySq traj > largeDataCutoff := by
    exact le_or_gt (initialEnstrophySq traj) largeDataCutoff
  cases hSplit with
  | inl hSmallInit =>
      exact hSmall traj hNS hFS hSmallInit t ht
  | inr hLargeInit =>
      exact largeData_all_times_of_machine_family hLargeFam traj hNS hFS hLargeInit t ht

/-- Immediate corollary to the project target statement. -/
theorem preciseGap_of_small_large_split
    (hSmall : SmallDataAllTimesContract)
    (hLargeFam : MachineFamilyAtTauIso) :
    PreciseGapStatement :=
  realNoether_contract_implies_precise_gap
    (realNoether_contract_of_small_large_split hSmall hLargeFam)

/-- Adapter from the existing subcritical initial-data lane to the small-data side
of this split bridge. -/
theorem smallDataAllTimes_of_initialSubcritical
    (hInit : InitialDataSubcriticalProp) :
    SmallDataAllTimesContract := by
  intro traj hNS hFS _hSmall t ht
  exact (initial_subcritical_implies_vs_le_nuP_all_traj hInit) traj t ht hNS hFS

/-- Combined corollary:
existing subcritical-initial-data route + machine-family large-data route. -/
theorem preciseGap_of_initialSubcritical_and_machine_family
    (hInit : InitialDataSubcriticalProp)
    (hLargeFam : MachineFamilyAtTauIso) :
    PreciseGapStatement :=
  preciseGap_of_small_large_split
    (smallDataAllTimes_of_initialSubcritical hInit) hLargeFam

/-- Registry entry for audit/readability. -/
def kolmogorovTuringBridgeClaims : List LabeledClaim :=
  [ ⟨"machineCutoffCert_mono", .verified,
      "THEOREM: finite-cutoff certificate is monotone in K (K1≤K2 ⇒ cert K2 ⇒ cert K1)"⟩
  , ⟨"prethreshold_of_machine_cutoff", .verified,
      "THEOREM: machine cert at τ_iso discharges large-data pre-threshold region"⟩
  , ⟨"prethreshold_of_machine_cutoff_upper", .verified,
      "THEOREM: machine cert at K≥τ_iso discharges pre-threshold region via monotonicity"⟩
  , ⟨"largeDataPreThreshold_of_machine_family", .verified,
      "THEOREM: global machine family at τ_iso implies LargeDataPreThresholdContract"⟩
  , ⟨"k41_post_threshold_control", .verified,
      "THEOREM: existing K41 lane gives VS≤νP for τ_ent≥τ_iso in large-data branch"⟩
  , ⟨"largeData_all_times_of_prethreshold", .verified,
      "THEOREM: pre-threshold contract + K41 post-threshold control glue to all-time VS≤νP (large-data)"⟩
  , ⟨"largeData_all_times_of_machine_family", .verified,
      "THEOREM: machine-family pre-threshold certs + K41 post-threshold imply all-time VS≤νP (large-data)"⟩
  , ⟨"realNoether_contract_of_small_large_split", .verified,
      "THEOREM: small-data all-time contract + large-data machine-family route imply RealNoetherToSliceVSContract"⟩
  , ⟨"preciseGap_of_small_large_split", .verified,
      "THEOREM: same split implies PreciseGapStatement via realNoether_contract_implies_precise_gap"⟩
  , ⟨"smallDataAllTimes_of_initialSubcritical", .verified,
      "THEOREM: InitialDataSubcriticalProp instantiates the small-data side of the split bridge"⟩
  , ⟨"preciseGap_of_initialSubcritical_and_machine_family", .verified,
      "THEOREM: InitialDataSubcriticalProp + MachineFamilyAtTauIso imply PreciseGapStatement"⟩
  , ⟨"ladder_plus_machine_reduction", .verified,
      "THEOREM: explicit reduction shape for Kolmogorov-ladder + finite-machine composition"⟩ ]

end

end NavierStokes.Millennium
