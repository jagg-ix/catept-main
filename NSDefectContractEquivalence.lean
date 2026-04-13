import NavierStokesClean.CATEPT.ModularNoetherCompatibility

/-!
Legacy-compat leverage surface for `NSDefectContractEquivalence.lean`.
Formal equivalence between defect-nonneg and VS<=nuP contracts.
-/

set_option autoImplicit false

namespace NavierStokesClean.LegacyCompat.NSDefectContractEquivalence

open NavierStokesClean
open NavierStokesClean.CATEPT

abbrev RealNoetherContract (traj : NSSpaceTrajectory) (t : ℝ) : Prop :=
  0 ≤ spatialImaginaryNoetherDefect traj t

abbrev SAG4Contract (traj : NSSpaceTrajectory) (t : ℝ) : Prop :=
  vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t)

lemma realNoether_contract_implies_sag4_contract
    (traj : NSSpaceTrajectory) (t : ℝ) :
    RealNoetherContract traj t → SAG4Contract traj t :=
  (defect_nonneg_iff_vs_le_nuP traj t).1

lemma sag4_contract_implies_realNoether_contract
    (traj : NSSpaceTrajectory) (t : ℝ) :
    SAG4Contract traj t → RealNoetherContract traj t :=
  (defect_nonneg_iff_vs_le_nuP traj t).2

lemma realNoether_contract_iff_sag4_contract
    (traj : NSSpaceTrajectory) (t : ℝ) :
    RealNoetherContract traj t ↔ SAG4Contract traj t :=
  defect_nonneg_iff_vs_le_nuP traj t

end NavierStokesClean.LegacyCompat.NSDefectContractEquivalence
