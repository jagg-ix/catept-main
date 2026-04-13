import Mathlib.Data.Real.Basic

/-!
# CATEPT External Interface: Pphi2 OS/QFT Layer

Opt-in certificate surface for leveraging the `pphi2` Euclidean-QFT stack
without importing that repository directly into this project.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- Certificate that external `pphi2` results provide an OS package plus a
mass-gap/reconstruction witness usable by CAT/EPT bridge theorems. -/
structure Pphi2OSCertificate where
  os0Analyticity : Prop
  os1Regularity : Prop
  os2EuclideanInvariance : Prop
  os3ReflectionPositivity : Prop
  os4Clustering : Prop
  os0_holds : os0Analyticity
  os1_holds : os1Regularity
  os2_holds : os2EuclideanInvariance
  os3_holds : os3ReflectionPositivity
  os4_holds : os4Clustering
  fullOS : Prop
  fullOS_of_components :
    os0Analyticity → os1Regularity → os2EuclideanInvariance →
      os3ReflectionPositivity → os4Clustering → fullOS
  massGapLowerBound : ℝ
  massGapPositive : 0 < massGapLowerBound
  hasReconstructionInterface : Prop
  hasReconstructionInterface_holds : hasReconstructionInterface

theorem Pphi2OSCertificate.fullOS_holds
    (w : Pphi2OSCertificate) : w.fullOS :=
  w.fullOS_of_components w.os0_holds w.os1_holds w.os2_holds w.os3_holds w.os4_holds

theorem Pphi2OSCertificate.mass_gap_positive
    (w : Pphi2OSCertificate) : 0 < w.massGapLowerBound :=
  w.massGapPositive

theorem Pphi2OSCertificate.has_reconstruction
    (w : Pphi2OSCertificate) : w.hasReconstructionInterface :=
  w.hasReconstructionInterface_holds

theorem Pphi2OSCertificate.os_bundle
    (w : Pphi2OSCertificate) :
    w.os0Analyticity ∧ w.os1Regularity ∧ w.os2EuclideanInvariance ∧
      w.os3ReflectionPositivity ∧ w.os4Clustering := by
  exact ⟨w.os0_holds, w.os1_holds, w.os2_holds, w.os3_holds, w.os4_holds⟩

end

end NavierStokesClean.CATEPT.External
