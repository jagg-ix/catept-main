import NavierStokes.Analysis.ThermodynamicRegularityBridge
import NavierStokes.Galerkin.NSGalerkinPassageLimitProof
import NavierStokes.Galerkin.NSGalerkinDefectSplitBridge

/-!
# NS Defect Contract Equivalence Audit (Stage 256B)

This module records, in-kernel, that the thermodynamic root contract and the
Galerkin SA-G4 defect-transport contract are propositionally equivalent:

- `RealNoetherToSliceVSContract`
- `NSDefectTransportFromGalerkinLSCContract`

They differ only by algebraic presentation (`a ≤ b` vs `0 ≤ b - a`), so this
module makes that equivalence explicit for audit/roadmap purposes.
-/

namespace NavierStokes.DefectContractEquivalence

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.GalerkinPassageLimitProof
open NavierStokes.GalerkinDefectSplit

noncomputable section

/-- Thermodynamic contract implies Galerkin SA-G4 contract (algebraic form change). -/
theorem realNoether_contract_implies_sag4_contract :
    RealNoetherToSliceVSContract →
      NSDefectTransportFromGalerkinLSCContract := by
  intro h traj t ht hNS hFS
  have hVS :
      vortexStretchingIntegral traj t ≤
        nsNu * palinstrophy (traj.stateAt t).velocity :=
    h traj t ht hNS hFS
  linarith

/-- Galerkin SA-G4 contract implies thermodynamic contract (algebraic form change). -/
theorem sag4_contract_implies_realNoether_contract :
    NSDefectTransportFromGalerkinLSCContract →
      RealNoetherToSliceVSContract := by
  intro h traj t ht hNS hFS
  have hDefect :
      0 ≤ nsNu * palinstrophy (traj.stateAt t).velocity -
            vortexStretchingIntegral traj t :=
    h traj t ht hNS hFS
  linarith

/-- The two load-bearing root contracts are propositionally equivalent. -/
theorem realNoether_contract_iff_sag4_contract :
    RealNoetherToSliceVSContract ↔
      NSDefectTransportFromGalerkinLSCContract := by
  constructor
  · exact realNoether_contract_implies_sag4_contract
  · exact sag4_contract_implies_realNoether_contract

/-- Existing thermodynamic axiom yields SA-G4 contract immediately. -/
theorem sag4_contract_of_realNoether_axiom :
    NSDefectTransportFromGalerkinLSCContract :=
  realNoether_contract_implies_sag4_contract realNoetherToSliceVS_global_contract

/-- Existing SA-G4 axiom yields thermodynamic root contract immediately. -/
theorem realNoether_contract_of_sag4_axiom :
    RealNoetherToSliceVSContract :=
  sag4_contract_implies_realNoether_contract
    (fun traj t ht hNS hFS =>
      ns_defect_transport_from_split traj t ht hNS hFS)

def stage256BSummary : String :=
  "Stage 297C: NSDefectContractEquivalence.lean proves " ++
  "RealNoetherToSliceVSContract <-> NSDefectTransportFromGalerkinLSCContract " ++
  "(a<=b vs 0<=b-a). Both implication directions are theoremized, " ++
  "and the SA-G4 witness is now sourced from ns_defect_transport_from_split."

end

end NavierStokes.DefectContractEquivalence
