import NavierStokesClean.CATEPT.ArakiRelativeEntropyBridge
import Mathlib.Tactic.Linarith

/-!
# CATEPT Madelung → ADM Matter Bridge (Spatial NS Carrier)

Structural bridge from spatial NS trajectory data to a Madelung-style state and
ADM matter tensors, grounded on existing clean definitions:

- `rho := spatialEnstrophy`
- `pressure := palinstrophySpatial`
- `imaginaryDefect := spatialImaginaryNoetherDefect`
- `tauPhaseRate := nsArakiRelativeEntropySpatial`

No new axioms; local-field reconstruction is intentionally out of scope.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

open NavierStokesClean NavierStokesClean.Galerkin

noncomputable section

abbrev Idx3 := Fin 3
abbrev Vec3 := Idx3 → ℝ
abbrev Tensor2 := Idx3 → Idx3 → ℝ

/-- Kronecker delta on spatial indices. -/
def delta3 (i j : Idx3) : ℝ :=
  if i = j then 1 else 0

/-- Madelung-style hydrodynamic state extracted from a spatial trajectory-time point. -/
structure MadelungHydroState where
  rho : ℝ
  rho_nonneg : 0 ≤ rho
  tauPhaseRate : ℝ
  tauPhaseRate_eq_rho_over_two_nu : tauPhaseRate = rho / (2 * nsNu)
  velocity : Vec3
  pressure : ℝ
  quantumPotential : ℝ
  imaginaryDefect : ℝ

/-- Canonical extraction from spatial NS trajectory at time `t`. -/
def madelungFromSpatialTrajectory
    (traj : NSSpaceTrajectory) (t : ℝ) : MadelungHydroState where
  rho := spatialEnstrophy (traj t)
  rho_nonneg := spatialEnstrophy_nonneg (traj t)
  tauPhaseRate := nsArakiRelativeEntropySpatial traj t
  tauPhaseRate_eq_rho_over_two_nu := by
    rfl
  velocity := fun _ => 0
  pressure := palinstrophySpatial (traj t)
  quantumPotential := 0
  imaginaryDefect := spatialImaginaryNoetherDefect traj t

theorem madelung_rho_eq_spatialEnstrophy
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (madelungFromSpatialTrajectory traj t).rho = spatialEnstrophy (traj t) :=
  rfl

theorem madelung_phase_rate_eq_araki_rate
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (madelungFromSpatialTrajectory traj t).tauPhaseRate =
      nsArakiRelativeEntropySpatial traj t :=
  rfl

theorem madelung_velocity_proxy_is_zero
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (madelungFromSpatialTrajectory traj t).velocity = fun _ => 0 :=
  rfl

theorem madelung_quantum_potential_proxy_is_zero
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (madelungFromSpatialTrajectory traj t).quantumPotential = 0 :=
  rfl

theorem madelung_pressure_proxy_eq_palinstrophy
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (madelungFromSpatialTrajectory traj t).pressure = palinstrophySpatial (traj t) :=
  rfl

theorem madelung_defect_eq_spatial_defect
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (madelungFromSpatialTrajectory traj t).imaginaryDefect =
      spatialImaginaryNoetherDefect traj t :=
  rfl

/-- Effective Dirac mass channel: `m_D = D_I / rho` on `{rho > 0}`. -/
def diracMassFromMadelung
    (m : MadelungHydroState) (_hRho : 0 < m.rho) : ℝ :=
  m.imaginaryDefect / m.rho

theorem dirac_mass_nonneg_iff_defect_nonneg
    (m : MadelungHydroState) (hRho : 0 < m.rho) :
    0 ≤ diracMassFromMadelung m hRho ↔ 0 ≤ m.imaginaryDefect := by
  unfold diracMassFromMadelung
  constructor
  · intro hMass
    have hMul : (m.imaginaryDefect / m.rho) * m.rho ≥ 0 :=
      mul_nonneg hMass (le_of_lt hRho)
    have hRhoNe : m.rho ≠ 0 := ne_of_gt hRho
    rwa [div_mul_cancel₀ m.imaginaryDefect hRhoNe] at hMul
  · intro hDefect
    exact div_nonneg hDefect (le_of_lt hRho)

/-- Trajectory-level bridge: nonnegative Dirac mass channel iff `VS ≤ νP`. -/
theorem dirac_mass_nonneg_iff_vs_le_nuP
    (traj : NSSpaceTrajectory) (t : ℝ)
    (hRho : 0 < (madelungFromSpatialTrajectory traj t).rho) :
    0 ≤ diracMassFromMadelung (madelungFromSpatialTrajectory traj t) hRho ↔
      vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) := by
  have hMass :
      0 ≤ diracMassFromMadelung (madelungFromSpatialTrajectory traj t) hRho ↔
        0 ≤ (madelungFromSpatialTrajectory traj t).imaginaryDefect :=
    dirac_mass_nonneg_iff_defect_nonneg (madelungFromSpatialTrajectory traj t) hRho
  have hDefect :
      0 ≤ (madelungFromSpatialTrajectory traj t).imaginaryDefect ↔
        vorticityStretching (traj t) ≤ nsNu * palinstrophySpatial (traj t) := by
    simpa [madelung_defect_eq_spatial_defect] using
      (spatial_defect_nonneg_iff_vs_le_nuP traj t)
  exact hMass.trans hDefect

/-- ADM matter source tuple `(rho, j_i, S_ij)` from Madelung channels. -/
structure ADMMatterTensors where
  rhoADM : ℝ
  jADM : Vec3
  sADM : Tensor2

/-- Isotropic stress shift used in the scalarized ADM mapping. -/
def isotropicStressShift (m : MadelungHydroState) : ℝ :=
  m.pressure + m.quantumPotential + m.imaginaryDefect

/-- Madelung → ADM matter mapping. -/
def admMatterFromMadelung (m : MadelungHydroState) : ADMMatterTensors where
  rhoADM := m.rho
  jADM := fun i => m.rho * m.velocity i
  sADM := fun i j =>
    m.rho * m.velocity i * m.velocity j + isotropicStressShift m * delta3 i j

theorem adm_rho_eq_madelung_rho (m : MadelungHydroState) :
    (admMatterFromMadelung m).rhoADM = m.rho :=
  rfl

theorem adm_j_component_formula (m : MadelungHydroState) (i : Idx3) :
    (admMatterFromMadelung m).jADM i = m.rho * m.velocity i :=
  rfl

theorem adm_stress_offdiag_formula
    (m : MadelungHydroState) (i j : Idx3) (hij : i ≠ j) :
    (admMatterFromMadelung m).sADM i j =
      m.rho * m.velocity i * m.velocity j := by
  unfold admMatterFromMadelung delta3 isotropicStressShift
  simp [hij]

theorem adm_stress_diag_formula
    (m : MadelungHydroState) (i : Idx3) :
    (admMatterFromMadelung m).sADM i i =
      m.rho * m.velocity i * m.velocity i + isotropicStressShift m := by
  unfold admMatterFromMadelung delta3
  simp

/-- Trajectory-level composition: `traj → Madelung → ADM matter`. -/
def nsSpatialTrajectoryToADMMatter
    (traj : NSSpaceTrajectory) (t : ℝ) : ADMMatterTensors :=
  admMatterFromMadelung (madelungFromSpatialTrajectory traj t)

theorem ns_to_adm_rho_eq_spatial_enstrophy
    (traj : NSSpaceTrajectory) (t : ℝ) :
    (nsSpatialTrajectoryToADMMatter traj t).rhoADM =
      spatialEnstrophy (traj t) :=
  rfl

theorem ns_to_adm_isotropic_shift_contains_defect
    (traj : NSSpaceTrajectory) (t : ℝ) :
    isotropicStressShift (madelungFromSpatialTrajectory traj t) =
      palinstrophySpatial (traj t) + spatialImaginaryNoetherDefect traj t := by
  unfold isotropicStressShift madelungFromSpatialTrajectory
  ring

end

end NavierStokesClean.CATEPT
