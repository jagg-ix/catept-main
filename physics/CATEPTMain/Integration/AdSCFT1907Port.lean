import CATEPTMain.Integration.AdSCFTReplica1907Bridge
import Mathlib
/-!
# AdS/CFT 1907 Port Export

Single import surface for the Headrick-1907 integration stack:

- `AdSCFTHeadrick1907Bridge` (entropy/RT equation map)
- `AdSCFTReplica1907Bridge` (replica-limit contract)

Downstream modules can depend on one witness type (`Headrick1907PortWitness`)
instead of importing both modules separately.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.AdSCFT.Headrick1907

/-- Witness that a specific replica dataset satisfies the `α→1` contract. -/
structure ReplicaLimitWitness where
  data : ReplicaTraceData
  S_vN : ℝ
  contract : ReplicaLimitContract data S_vN

/-- Unified witness exported to downstream modules. -/
structure Headrick1907PortWitness where
  entropyWitness : Headrick1907Witness
  entropyContract : Headrick1907IntegrationContract entropyWitness
  entropyAxioms : EntropyAxioms
  replicaWitness : ReplicaLimitWitness

/-- Canonical phase-1 constructor: plug in any replica-limit witness and reuse
the built entropy witness/axioms from the equation bridge. -/
def mkPhase1Headrick1907PortWitness
    (rW : ReplicaLimitWitness) : Headrick1907PortWitness :=
  { entropyWitness := phase1Headrick1907Witness
    entropyContract := phase1Headrick1907Witness_valid
    entropyAxioms := phase1EntropyAxioms
    replicaWitness := rW }

/-- Downstream accessor: subadditivity ↔ MI nonnegativity. -/
theorem port_subadditivity_nonneg_mi
    (w : Headrick1907PortWitness) (SA SB SAB : ℝ) :
    subadditivity SA SB SAB ↔ 0 ≤ mutualInformation SA SB SAB :=
  w.entropyAxioms.subadditivity_nonneg_mi SA SB SAB

/-- Downstream accessor: SSA ↔ MI monotonicity under adjoining system `C`. -/
theorem port_ssa_mono_mi
    (w : Headrick1907PortWitness) (SA SB SAB SBC SABC : ℝ) :
    strongSubadditivity SAB SBC SB SABC ↔
      mutualInfoMonotoneUnderAdjoin SA SB SAB SBC SABC :=
  w.entropyAxioms.ssa_mono_mi SA SB SAB SBC SABC

/-- Downstream accessor: pure-state entropy balance from Araki-Lieb. -/
theorem port_pure_balance_from_araki
    (w : Headrick1907PortWitness) (SA SB : ℝ) :
    arakiLieb SA SB 0 → SA = SB :=
  w.entropyAxioms.pure_balance_from_araki SA SB

/-- Downstream accessor: RT-scaled SSA transfer lemma. -/
theorem port_rt_ssa_of_area_ssa
    (_w : Headrick1907PortWitness)
    (G_N aAB aBC aB aABC : ℝ) (hG : 0 < G_N)
    (hAreaSSA : aAB + aBC ≥ aB + aABC) :
    strongSubadditivity (rtEntropy aAB G_N) (rtEntropy aBC G_N)
      (rtEntropy aB G_N) (rtEntropy aABC G_N) :=
  rtEntropy_ssa_of_area_ssa G_N aAB aBC aB aABC hG hAreaSSA

/-- Downstream accessor: RT-scaled MMI transfer lemma. -/
theorem port_rt_mmi_of_area_mmi
    (_w : Headrick1907PortWitness)
    (G_N aAB aBC aAC aA aB aC aABC : ℝ) (hG : 0 < G_N)
    (hAreaMMI : aAB + aBC + aAC ≥ aA + aB + aC + aABC) :
    monogamyMutualInformation
      (rtEntropy aAB G_N) (rtEntropy aBC G_N) (rtEntropy aAC G_N)
      (rtEntropy aA G_N) (rtEntropy aB G_N) (rtEntropy aC G_N)
      (rtEntropy aABC G_N) :=
  rtEntropy_mmi_of_area_mmi G_N aAB aBC aAC aA aB aC aABC hG hAreaMMI

/-- Downstream accessor: replica-limit tendsto statement from stored witness. -/
theorem port_replica_limit
    (w : Headrick1907PortWitness) :
    Filter.Tendsto
      (fun α : ℝ => renyiFromReplica w.replicaWitness.data α)
      (nhdsWithin (1 : ℝ) {x : ℝ | x ≠ 1})
      (nhds w.replicaWitness.S_vN) :=
  replica_limit_from_contract
    w.replicaWitness.data w.replicaWitness.S_vN w.replicaWitness.contract

/-- Toy replica dataset for a pure state proxy: `Tr(ρ^α)=1` for all `α`. -/
def pureReplicaTraceData : ReplicaTraceData :=
  { trRhoPow := fun _ => 1
    trRhoPow_pos := by intro _; norm_num
    trRhoPow_one := by norm_num
    analyticNearOne := by
      simpa using (continuousAt_const : ContinuousAt (fun _ : ℝ => (1 : ℝ)) (1 : ℝ)) }

/-- The toy pure-state replica data satisfies the phase-2 limit contract with
`S_vN = 0`. -/
theorem pureReplicaLimitContract :
    ReplicaLimitContract pureReplicaTraceData 0 := by
  refine ⟨pureReplicaTraceData.analyticNearOne, ?_⟩
  simpa [renyiFromReplica, pureReplicaTraceData, renyiEntropyFormula] using
    (tendsto_const_nhds : Filter.Tendsto
      (fun _ : ℝ => (0 : ℝ))
      (nhdsWithin (1 : ℝ) {x : ℝ | x ≠ 1})
      (nhds (0 : ℝ)))

/-- Concrete replica witness exported for downstream integration tests. -/
def pureReplicaLimitWitness : ReplicaLimitWitness :=
  { data := pureReplicaTraceData
    S_vN := 0
    contract := pureReplicaLimitContract }

/-- Canonical phase-1 port witness backed by the toy replica dataset. -/
def phase1PortWitness_pureToy : Headrick1907PortWitness :=
  mkPhase1Headrick1907PortWitness pureReplicaLimitWitness

end CATEPTMain.Integration.AdSCFT.Headrick1907
