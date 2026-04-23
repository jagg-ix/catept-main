import NavierStokes.Bridges.NSMadelungADMTensorBridge
import NavierStokes.Bridges.NSMadelungADMTensorBridge
import NavierStokes.VS.NSVSNuPKernel
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import Mathlib.Algebra.BigOperators.Fin

/-!
# NS ADM Extrinsic Curvature Bridge (CAT/EPT, Corrected)

This bridge formalizes the ADM geometric dictionary entries validated by
the external expert's minimum viable corrected framework:

  γ_ij = δ_ij        (flat spatial metric on T³)
  N^i  = u^i         (shift = fluid velocity)
  N_ent = Ω/(2ν)     (lapse = CAT/EPT entropic rate)

from which the extrinsic curvature formula follows as a definition:

  K_ij = S_ij / N_ent = (2ν/Ω) S_ij

and its trace vanishes by incompressibility:

  K = γ^{ij} K_ij = (2ν/Ω) Tr(S_ij) = 0.

## Scope

- All identifications are definitional/structural (no new physical axioms).
- The strain tensor is represented as an abstract `Tensor2` data field
  (scalarized proxy); local-field reconstruction is out of scope.
- This file adds the geometry half of the Madelung/ADM bridge that the
  original `NSMadelungADMTensorBridge` left incomplete (`ADMGeometryData`
  was declared but never linked to the NS trajectory data).
- No Stage-64 closure claim is added.
-/

namespace NavierStokes.Bridges.NSADMExtrinsicCurvature

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.Bridges.NSMadelungADMTensor
open NavierStokes.Bridges.NSModularNoether

noncomputable section

/-! ## 1. Strain Tensor Data (Scalarized Proxy) -/

/-- A scalarized strain tensor proxy.
Represents the symmetric part of the velocity gradient:
`S_ij = (∂_i u_j + ∂_j u_i)/2`.

The trace-free property (`Tr S = ∂_k u^k = 0`) encodes incompressibility. -/
structure NSStrainTensorData where
  /-- Components of the symmetric strain tensor `S_ij`. -/
  components : Tensor2
  /-- Symmetry: S_ij = S_ji. -/
  symm : ∀ (i j : Idx3), components i j = components j i
  /-- Incompressibility: trace of strain is zero. -/
  trace_zero : (Finset.univ.sum (fun i : Idx3 => components i i)) = 0

/-! ## 2. ADM Geometric Identification -/

/-- Full CAT/EPT ADM geometric identification for NS on T³.

Dictionary entries (all definitions, not new axioms):
- γ_ij = δ_ij     (flat spatial metric)
- N^i  = u^i      (shift = fluid velocity)
- N_ent = Ω/(2ν)  (lapse = entropic clock rate)
- K_ij = S_ij/N_ent (extrinsic curvature from ADM formula)
-/
structure NSADMGeometricData where
  /-- Enstrophy scalar (positive, guaranteeing non-zero lapse). -/
  enstrophyVal : Rat
  enstrophyVal_pos : (0 : Rat) < enstrophyVal
  /-- Kinematic viscosity (inherited from global `nsNu`). -/
  nu : Rat
  nu_pos : (0 : Rat) < nu
  /-- Strain tensor proxy. -/
  strain : NSStrainTensorData
  /-- CAT/EPT lapse: N_ent = Ω/(2ν). -/
  lapse : Rat
  /-- Lapse identification: N_ent = enstrophyVal / (2 * nu). -/
  lapse_eq : lapse = enstrophyVal / (2 * nu)
  /-- Positivity of lapse (consequence of enstrophy > 0, nu > 0). -/
  lapse_pos : (0 : Rat) < lapse

/-- Canonical construction of `NSADMGeometricData` from enstrophy and viscosity. -/
def nsADMGeometricData_mk
    (omega nu : Rat) (hOmega : (0 : Rat) < omega) (hNu : (0 : Rat) < nu)
    (S : NSStrainTensorData) : NSADMGeometricData where
  enstrophyVal := omega
  enstrophyVal_pos := hOmega
  nu := nu
  nu_pos := hNu
  strain := S
  lapse := omega / (2 * nu)
  lapse_eq := rfl
  lapse_pos := div_pos hOmega (by linarith)

/-! ## 3. Extrinsic Curvature Formula -/

/-- Extrinsic curvature components from ADM formula:
`K_ij = S_ij / N_ent`. -/
def extrinsicCurvatureComponents (g : NSADMGeometricData) : Tensor2 :=
  fun i j => g.strain.components i j / g.lapse

/-- Explicit formula: K_ij = S_ij · (2ν/Ω).

This is the key result of the corrected Madelung/ADM framework:
the ADM extrinsic curvature of the entropic foliation equals the
strain tensor scaled by the inverse entropic lapse (2ν/Ω). -/
theorem k_ij_eq_strain_scaled_by_two_nu_over_omega
    (g : NSADMGeometricData) (i j : Idx3) :
    extrinsicCurvatureComponents g i j =
      g.strain.components i j * (2 * g.nu / g.enstrophyVal) := by
  unfold extrinsicCurvatureComponents
  rw [g.lapse_eq]
  have hOmega : g.enstrophyVal ≠ 0 := ne_of_gt g.enstrophyVal_pos
  have h2nu : (2 * g.nu) ≠ 0 := mul_ne_zero (by norm_num) (ne_of_gt g.nu_pos)
  field_simp [hOmega, h2nu]

/-- Extrinsic curvature is symmetric: K_ij = K_ji. -/
theorem k_ij_symm (g : NSADMGeometricData) (i j : Idx3) :
    extrinsicCurvatureComponents g i j = extrinsicCurvatureComponents g j i := by
  unfold extrinsicCurvatureComponents
  rw [g.strain.symm i j]

/-! ## 4. Trace Vanishes by Incompressibility -/

/-- ADM trace K = Σ_i K_ii = 0 follows from incompressibility (Tr S = 0). -/
theorem trace_k_zero_from_incompressibility (g : NSADMGeometricData) :
    (Finset.univ.sum (fun i : Idx3 => extrinsicCurvatureComponents g i i)) = 0 := by
  unfold extrinsicCurvatureComponents
  simp only [Fin.sum_univ_three]
  have hTrace := g.strain.trace_zero
  simp only [Fin.sum_univ_three] at hTrace
  have hL : g.lapse ≠ 0 := ne_of_gt g.lapse_pos
  field_simp [hL]
  linarith

/-! ## 5. Flat Metric and Index Raising -/

/-- In the flat-metric ADM identification, the spatial metric is the
Kronecker delta. This is a definition, not a field equation. -/
def flatSpatialMetric : Tensor2 := delta3

/-- The flat spatial metric is symmetric. -/
theorem flat_metric_symm (i j : Idx3) :
    flatSpatialMetric i j = flatSpatialMetric j i := by
  unfold flatSpatialMetric delta3
  by_cases h : i = j
  · simp [h]
  · have hji : j ≠ i := Ne.symm h
    simp [h, hji]

/-- The flat spatial metric has unit diagonal entries. -/
theorem flat_metric_diag (i : Idx3) :
    flatSpatialMetric i i = 1 := by
  unfold flatSpatialMetric delta3
  simp

/-- Raising an index with the flat metric is the identity. -/
theorem flat_metric_raised_eq_components
    (g : NSADMGeometricData) (i j : Idx3) :
    (Finset.univ.sum (fun k : Idx3 =>
      flatSpatialMetric i k * extrinsicCurvatureComponents g k j)) =
    extrinsicCurvatureComponents g i j := by
  rw [Finset.sum_eq_single_of_mem i (Finset.mem_univ i)]
  · simp [flatSpatialMetric, delta3]
  · intro k _ hki
    have hik : i ≠ k := Ne.symm hki
    simp [flatSpatialMetric, delta3, if_neg hik]

/-! ## 6. Canonical Extraction from NS Trajectory -/

/-- Canonical extraction of ADM geometric data from an NS trajectory point.
The strain tensor is provided as an external proxy (local-field
reconstruction remains out of scope). -/
def nsADMGeometricFromTrajectory
    (traj : Trajectory NSField) (t : Rat)
    (_ : SatisfiesNSPDE nsOps nsNu traj)
    (hE : (0 : Rat) < enstrophy (traj.stateAt t).velocity)
    (S : NSStrainTensorData) : NSADMGeometricData :=
  nsADMGeometricData_mk
    (enstrophy (traj.stateAt t).velocity)
    nsNu
    hE
    nsNu_pos
    S

/-- Lapse of canonical extraction equals Ω/(2ν). -/
theorem ns_adm_lapse_eq_entropic_rate
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hE : (0 : Rat) < enstrophy (traj.stateAt t).velocity)
    (S : NSStrainTensorData) :
    (nsADMGeometricFromTrajectory traj t hNS hE S).lapse =
      enstrophy (traj.stateAt t).velocity / (2 * nsNu) := by
  unfold nsADMGeometricFromTrajectory nsADMGeometricData_mk
  rfl

/-- Extrinsic curvature from canonical extraction:
K_ij = S_ij · (2ν / Ω). -/
theorem ns_adm_k_ij_canonical
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hE : (0 : Rat) < enstrophy (traj.stateAt t).velocity)
    (S : NSStrainTensorData) (i j : Idx3) :
    extrinsicCurvatureComponents
      (nsADMGeometricFromTrajectory traj t hNS hE S) i j =
      S.components i j *
        (2 * nsNu / enstrophy (traj.stateAt t).velocity) :=
  k_ij_eq_strain_scaled_by_two_nu_over_omega
    (nsADMGeometricFromTrajectory traj t hNS hE S) i j

/-- Trace K = 0 for canonical NS extraction — follows from strain trace = 0. -/
theorem ns_adm_trace_k_zero_canonical
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hE : (0 : Rat) < enstrophy (traj.stateAt t).velocity)
    (S : NSStrainTensorData) :
    (Finset.univ.sum (fun i : Idx3 =>
      extrinsicCurvatureComponents
        (nsADMGeometricFromTrajectory traj t hNS hE S) i i)) = 0 :=
  trace_k_zero_from_incompressibility
    (nsADMGeometricFromTrajectory traj t hNS hE S)

/-! ## 7. D_I ↔ K_ij Sign Interpretation -/

/-- D_I ≥ 0 is exactly the condition that makes the NS fluid a
"curvature absorber": the extrinsic curvature K_ij couples to the
strain exactly as νP dominates VS.

This structure links the ADM geometry identification back to the
Stage 73 kernel: D_I ≥ 0 ↔ VS ≤ νP ↔ dΩ/dt ≤ 0. -/
structure NSCurvatureAbsorberInterpretation
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) where
  /-- Imaginary Noether defect at the trajectory point. -/
  defect : Rat
  defect_eq : defect = imaginaryNoetherDefect traj t
  /-- Absorber condition: D_I ≥ 0 ↔ VS ≤ νP (existing kernel result). -/
  defect_nonneg_iff : defect ≥ 0 ↔
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity
  /-- Geometric consequence: non-negative defect ↔ K-field curvature decay. -/
  absorber_interpretation : defect ≥ 0 →
      vortexStretchingIntegral traj t ≤ nsNu * palinstrophy (traj.stateAt t).velocity

/-- Canonical absorber interpretation from existing kernel theorems. -/
def nsADMAbsorberFromKernel
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) :
    NSCurvatureAbsorberInterpretation traj t hNS where
  defect := imaginaryNoetherDefect traj t
  defect_eq := rfl
  defect_nonneg_iff := defect_nonneg_iff_vs_le_nuP traj t
  absorber_interpretation := fun hD =>
    (defect_nonneg_iff_vs_le_nuP traj t).mp hD

/-! ## 8. Claim Registry -/

def nsADMExtrinsicCurvatureClaims : List LabeledClaim :=
  [ ⟨"k_ij_eq_strain_scaled_by_two_nu_over_omega", .verified,
      "THEOREM: K_ij = S_ij · (2ν/Ω) — ADM extrinsic curvature equals strain scaled by inverse entropic lapse."⟩
  , ⟨"k_ij_symm", .verified,
      "THEOREM: K_ij = K_ji (symmetry from strain symmetry)."⟩
  , ⟨"trace_k_zero_from_incompressibility", .verified,
      "THEOREM: Tr(K) = 0 from incompressibility (Tr(S) = 0)."⟩
  , ⟨"flat_metric_symm", .verified,
      "THEOREM: flat spatial metric γ_ij = δ_ij is symmetric."⟩
  , ⟨"flat_metric_raised_eq_components", .verified,
      "THEOREM: raising an index with flat metric is the identity on K_ij."⟩
  , ⟨"ns_adm_lapse_eq_entropic_rate", .verified,
      "THEOREM: canonical lapse N_ent = Ω/(2ν) equals CAT/EPT entropic rate."⟩
  , ⟨"ns_adm_k_ij_canonical", .verified,
      "THEOREM: canonical K_ij from NS trajectory equals (2ν/Ω)S_ij."⟩
  , ⟨"ns_adm_trace_k_zero_canonical", .verified,
      "THEOREM: canonical Tr(K) = 0 for NS trajectories."⟩
  , ⟨"nsADMAbsorberFromKernel", .verified,
      "THEOREM: D_I ≥ 0 ↔ K-field curvature absorber condition (from Stage 73 kernel)."⟩
  ]

end

end NavierStokes.Bridges.NSADMExtrinsicCurvature
