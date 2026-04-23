import NavierStokesClean.CATEPT.MadelungADMBridge
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-!
# CATEPT ADM Extrinsic-Curvature Bridge (Spatial NS Carrier)

Geometric half of the Madelung/ADM dictionary on the clean carrier:

- flat spatial metric `γ_ij = δ_ij`
- entropic lapse `N_ent = Ω/(2ν)`
- extrinsic curvature `K_ij = S_ij / N_ent = S_ij * (2ν/Ω)`
- incompressibility trace law `Tr(S)=0 -> Tr(K)=0`.

All statements are structural and theorem-backed.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

open NavierStokesClean

noncomputable section

/-- Scalarized symmetric strain-tensor proxy with incompressible trace law. -/
structure NSStrainTensorData where
  components : Tensor2
  symm : ∀ i j : Idx3, components i j = components j i
  trace_zero : (Finset.univ.sum (fun i : Idx3 => components i i)) = 0

/-- Geometric ADM bundle specialized to the CAT/EPT lapse mapping. -/
structure NSADMGeometricData where
  enstrophyVal : ℝ
  enstrophyVal_pos : 0 < enstrophyVal
  nu : ℝ
  nu_pos : 0 < nu
  strain : NSStrainTensorData
  lapse : ℝ
  lapse_eq : lapse = enstrophyVal / (2 * nu)
  lapse_pos : 0 < lapse

/-- Canonical constructor with `N_ent = Ω/(2ν)`. -/
def nsADMGeometricData_mk
    (omega nu : ℝ) (hOmega : 0 < omega) (hNu : 0 < nu)
    (S : NSStrainTensorData) : NSADMGeometricData where
  enstrophyVal := omega
  enstrophyVal_pos := hOmega
  nu := nu
  nu_pos := hNu
  strain := S
  lapse := omega / (2 * nu)
  lapse_eq := rfl
  lapse_pos := div_pos hOmega (by nlinarith [hNu])

/-- Extrinsic-curvature components from ADM formula `K_ij = S_ij / N_ent`. -/
def extrinsicCurvatureComponents (g : NSADMGeometricData) : Tensor2 :=
  fun i j => g.strain.components i j / g.lapse

theorem k_ij_eq_strain_scaled_by_two_nu_over_omega
    (g : NSADMGeometricData) (i j : Idx3) :
    extrinsicCurvatureComponents g i j =
      g.strain.components i j * (2 * g.nu / g.enstrophyVal) := by
  unfold extrinsicCurvatureComponents
  rw [g.lapse_eq]
  have hOmega : g.enstrophyVal ≠ 0 := ne_of_gt g.enstrophyVal_pos
  have hTwoNu : (2 * g.nu : ℝ) ≠ 0 := by nlinarith [g.nu_pos]
  field_simp [hOmega, hTwoNu]

theorem k_ij_symm (g : NSADMGeometricData) (i j : Idx3) :
    extrinsicCurvatureComponents g i j = extrinsicCurvatureComponents g j i := by
  unfold extrinsicCurvatureComponents
  rw [g.strain.symm i j]

theorem trace_k_zero_from_incompressibility (g : NSADMGeometricData) :
    (Finset.univ.sum (fun i : Idx3 => extrinsicCurvatureComponents g i i)) = 0 := by
  unfold extrinsicCurvatureComponents
  have hsum :
      (Finset.univ.sum (fun i : Idx3 => g.strain.components i i / g.lapse)) =
        (Finset.univ.sum (fun i : Idx3 => g.strain.components i i)) / g.lapse := by
    simp [div_eq_mul_inv, Finset.sum_mul]
  rw [hsum, g.strain.trace_zero, zero_div]

/-- Flat spatial metric in the ADM identification: `γ_ij = δ_ij`. -/
def flatSpatialMetric : Tensor2 := delta3

theorem flat_metric_symm (i j : Idx3) :
    flatSpatialMetric i j = flatSpatialMetric j i := by
  unfold flatSpatialMetric delta3
  by_cases h : i = j
  · simp [h]
  · have hji : j ≠ i := Ne.symm h
    simp [h, hji]

theorem flat_metric_diag (i : Idx3) :
    flatSpatialMetric i i = 1 := by
  unfold flatSpatialMetric delta3
  simp

theorem flat_metric_raised_eq_components
    (g : NSADMGeometricData) (i j : Idx3) :
    (Finset.univ.sum (fun k : Idx3 =>
      flatSpatialMetric i k * extrinsicCurvatureComponents g k j))
      = extrinsicCurvatureComponents g i j := by
  rw [Finset.sum_eq_single_of_mem i (Finset.mem_univ i)]
  · simp [flatSpatialMetric, delta3]
  · intro k _ hki
    have hik : i ≠ k := Ne.symm hki
    simp [flatSpatialMetric, delta3, if_neg hik]

/-- Canonical geometric extraction from spatial trajectory data at time `t`. -/
def nsADMGeometricFromSpatialTrajectory
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hE : 0 < spatialEnstrophy (traj t))
    (S : NSStrainTensorData) : NSADMGeometricData :=
  nsADMGeometricData_mk (spatialEnstrophy (traj t)) nsNu hE nsNu_pos S

theorem ns_adm_lapse_eq_entropic_rate
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hE : 0 < spatialEnstrophy (traj t))
    (S : NSStrainTensorData) :
    (nsADMGeometricFromSpatialTrajectory traj t hE S).lapse =
      spatialEnstrophy (traj t) / (2 * nsNu) := by
  unfold nsADMGeometricFromSpatialTrajectory nsADMGeometricData_mk
  rfl

theorem ns_adm_k_ij_canonical
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hE : 0 < spatialEnstrophy (traj t))
    (S : NSStrainTensorData) (i j : Idx3) :
    extrinsicCurvatureComponents
      (nsADMGeometricFromSpatialTrajectory traj t hE S) i j =
      S.components i j * (2 * nsNu / spatialEnstrophy (traj t)) :=
  k_ij_eq_strain_scaled_by_two_nu_over_omega
    (nsADMGeometricFromSpatialTrajectory traj t hE S) i j

theorem ns_adm_trace_k_zero_canonical
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hE : 0 < spatialEnstrophy (traj t))
    (S : NSStrainTensorData) :
    (Finset.univ.sum (fun i : Idx3 =>
      extrinsicCurvatureComponents
        (nsADMGeometricFromSpatialTrajectory traj t hE S) i i)) = 0 :=
  trace_k_zero_from_incompressibility
    (nsADMGeometricFromSpatialTrajectory traj t hE S)

/-- Curvature-absorber criterion: `D_I ≥ 0` iff `VS ≤ νP`. -/
theorem curvature_absorber_iff_vs_le_nuP
    (traj : NSSpaceTrajectory) (t : ℝ) :
    0 ≤ spatialImaginaryNoetherDefect traj t ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) :=
  spatial_defect_nonneg_iff_vs_le_nuP traj t

end

end NavierStokesClean.CATEPT
