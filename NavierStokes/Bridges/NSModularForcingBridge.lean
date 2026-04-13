import NavierStokes.Bridges.EntropicTimeReparam
import NavierStokes.Bridges.NSModularNoetherBridge
import NavierStokes.NSComplexDiracEinsteinBridge
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring

/-!
# NS Modular Forcing Bridge (General, Not No-Gravity-Only)

This bridge keeps forcing explicit and encodes a modular/thermal dictionary:

- forcing term remains present in the NS balance;
- a gravity-like contribution can be represented as an inverse-temperature channel;
- no-gravity is treated as an optional specialization (`forcingTerm = 0`), not
  the only formulation.

No Stage-64 closure claim is introduced.
-/

namespace NavierStokes.Bridges.NSModularForcing

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.EntropicTimeMechanics
open NavierStokes.Bridges.NSModularNoether

noncomputable section

/-! ## 1. Modular/Thermal Forcing Dictionary -/

/-- Dictionary splitting a forcing term into:
1) gravity-like inverse-temperature channel, and
2) residual non-gravitational forcing channel. -/
structure ThermalForceDictionary where
  /-- Inverse temperature `beta` (positive). -/
  beta : Rat
  beta_pos : (0 : Rat) < beta
  /-- Gravity-like projected term in the NS forcing slot. -/
  gravityProjected : Rat
  /-- Residual (non-gravity) forcing channel. -/
  residualForcing : Rat
  /-- Full forcing term after channel composition. -/
  forcingComposed : Rat
  /-- Inverse-temperature numerator (`kappa_g`), so `gravityProjected = kappa_g / beta`. -/
  gravityInverseTempNumerator : Rat
  /-- Gravity-as-inverse-temperature mapping. -/
  gravity_as_inverse_temperature :
    gravityProjected = gravityInverseTempNumerator / beta
  /-- Full forcing split. -/
  forcing_split :
    forcingComposed = gravityProjected + residualForcing

/-- A generic NS entropic PDE model with forcing retained and dictionary-linked. -/
structure ModularForcedEntropicModel where
  pde : NSEntropicPDEData
  dict : ThermalForceDictionary
  forcing_consistent : pde.forcingTerm = dict.forcingComposed

/-- Forcing term in modular split form:
`forcing = kappa_g/beta + residual`. -/
theorem forcing_term_modular_split (m : ModularForcedEntropicModel) :
    m.pde.forcingTerm =
      m.dict.gravityInverseTempNumerator / m.dict.beta + m.dict.residualForcing := by
  calc
    m.pde.forcingTerm = m.dict.forcingComposed := m.forcing_consistent
    _ = m.dict.gravityProjected + m.dict.residualForcing := m.dict.forcing_split
    _ = m.dict.gravityInverseTempNumerator / m.dict.beta + m.dict.residualForcing := by
          rw [m.dict.gravity_as_inverse_temperature]

/-! ## 2. NS Balance with Explicit Modular Forcing -/

/-- Spatial residual with forcing represented in modular split form. -/
theorem modular_forced_spatial_residual_form (m : ModularForcedEntropicModel) :
    m.pde.spatialResidual =
      m.pde.convectionTerm + m.pde.pressureGradientTerm - m.pde.viscousDiffusionTerm -
      (m.dict.gravityInverseTempNumerator / m.dict.beta + m.dict.residualForcing) := by
  unfold NSEntropicPDEData.spatialResidual
  rw [forcing_term_modular_split m]

/-- Classical-time NS balance with explicit modular forcing split. -/
theorem modular_forced_classical_form (m : ModularForcedEntropicModel) :
    NSClassicalPDE m.pde ↔
      m.pde.timeDerivative_t +
        (m.pde.convectionTerm + m.pde.pressureGradientTerm - m.pde.viscousDiffusionTerm -
          (m.dict.gravityInverseTempNumerator / m.dict.beta + m.dict.residualForcing)) = 0 := by
  unfold NSClassicalPDE NSEntropicPDEData.spatialResidual
  rw [forcing_term_modular_split m]

/-- Entropic-time scaled NS balance with explicit modular forcing split. -/
theorem modular_forced_entropic_scaled_form (m : ModularForcedEntropicModel) :
    NSEntropicScaledPDE m.pde ↔
      m.pde.lambda * m.pde.timeDerivative_tau +
        (m.pde.convectionTerm + m.pde.pressureGradientTerm - m.pde.viscousDiffusionTerm -
          (m.dict.gravityInverseTempNumerator / m.dict.beta + m.dict.residualForcing)) = 0 := by
  unfold NSEntropicScaledPDE NSEntropicPDEData.spatialResidual
  rw [forcing_term_modular_split m]

/-- Reparameterization equivalence is unchanged by keeping forcing explicit. -/
theorem modular_forced_reparam_iff (m : ModularForcedEntropicModel) :
    NSClassicalPDE m.pde ↔ NSEntropicScaledPDE m.pde :=
  ns_pde_reparam_iff m.pde

/-! ## 3. Optional No-Gravity Specialization -/

/-- Optional no-gravity/no-residual specialization inside the general model. -/
def NoGravitySpecializationProp (m : ModularForcedEntropicModel) : Prop :=
  m.dict.gravityInverseTempNumerator = 0 ∧ m.dict.residualForcing = 0

/-- If both channels vanish, forcing vanishes (`forcingTerm = 0`). -/
theorem no_gravity_specialization_implies_forcing_zero
    (m : ModularForcedEntropicModel)
    (hNoG : NoGravitySpecializationProp m) :
    m.pde.forcingTerm = 0 := by
  rcases hNoG with ⟨hKappa, hRes⟩
  rw [forcing_term_modular_split m, hKappa, hRes]
  simp

/-- The no-gravity bridge used elsewhere is an optional specialization of this
general forced modular-flow model. -/
theorem no_gravity_profile_is_optional_specialization
    (m : ModularForcedEntropicModel)
    (hNoG : NoGravitySpecializationProp m) :
    m.pde.forcingTerm = 0 ∧
    (NSClassicalPDE m.pde ↔ NSEntropicScaledPDE m.pde) := by
  constructor
  · exact no_gravity_specialization_implies_forcing_zero m hNoG
  · exact modular_forced_reparam_iff m

/-! ## 4. Construction Helper and Claims -/

/-- Constructor witness: for any `beta>0`, numerator `kappa_g`, and residual force,
the gravity-as-inverse-temperature split is constructible. -/
theorem thermal_force_dictionary_constructible
    (beta kappa_g residual : Rat) (hBeta : (0 : Rat) < beta) :
    ∃ d : ThermalForceDictionary,
      d.beta = beta ∧
      d.gravityInverseTempNumerator = kappa_g ∧
      d.residualForcing = residual := by
  refine ⟨{ beta := beta
          , beta_pos := hBeta
          , gravityProjected := kappa_g / beta
          , residualForcing := residual
          , forcingComposed := kappa_g / beta + residual
          , gravityInverseTempNumerator := kappa_g
          , gravity_as_inverse_temperature := by rfl
          , forcing_split := by rfl }, rfl, rfl, rfl⟩

/-! ## 5. Stronger Physics-Constrained Forcing Claim -/

/-- Additional physics assumptions linking:
- complex Einstein-mass / EFE imaginary sector,
- complex Dirac mass channel,
- modular forcing channel.

These assumptions are explicit and local; no Stage-64 closure is inferred. -/
structure ComplexEinsteinDiracEfeForcingAssumptions
    (m : ModularForcedEntropicModel)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) where
  /-- Effective density channel used by the Dirac/EFE coupling. -/
  density : Rat
  density_pos : (0 : Rat) < density
  /-- Einstein imaginary-sector scalar at `(traj,t)`. -/
  einsteinImag : Rat
  /-- Imaginary stress scalar in complex EFE split. -/
  stressImag : Rat
  /-- Effective Dirac mass scalar at `(traj,t)`. -/
  diracMass : Rat
  /-- EFE coupling constant in `G_im = kappaEFE * T_im`. -/
  kappaEFE : Rat
  /-- Coupling from Einstein-imaginary sector to gravity-like forcing channel. -/
  gravityEinsteinCoupling : Rat
  /-- Dirac thermal scale (`beta * m_D = diracThermalScale`). -/
  diracThermalScale : Rat
  /-- Physics identification: `density = Omega`. -/
  density_is_enstrophy : density = enstrophy (traj.stateAt t).velocity
  /-- Complex EFE imaginary sector relation: `G_im = kappaEFE * T_im`. -/
  efe_imag_sector_relation : einsteinImag = kappaEFE * stressImag
  /-- NS/CAT-EPT identification for imaginary stress channel: `T_im = D_I`. -/
  stress_imag_is_defect :
    stressImag = imaginaryNoetherDefect traj t
  /-- Dirac mass relation: `D_I = density * m_D`. -/
  defect_is_density_times_dirac_mass :
    imaginaryNoetherDefect traj t = density * diracMass
  /-- Thermal relation: `beta * m_D = diracThermalScale`. -/
  dirac_thermal_relation :
    m.dict.beta * diracMass = diracThermalScale
  /-- Forcing channel sourced by Einstein imaginary sector. -/
  gravity_from_einstein_imag :
    m.dict.gravityProjected = gravityEinsteinCoupling * einsteinImag

/-- Derived coupling numerator from the combined Einstein-Dirac-EFE assumptions. -/
def derivedGravityNumerator
    (m : ModularForcedEntropicModel)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hPhys : ComplexEinsteinDiracEfeForcingAssumptions m traj t hNS) : Rat :=
  hPhys.gravityEinsteinCoupling * hPhys.kappaEFE * hPhys.density * hPhys.diracThermalScale

/-- Product-form stronger claim:
`beta * gravityProjected = derivedGravityNumerator`.

This is the division-free form of the inverse-temperature forcing derivation from
complex Einstein + Dirac + EFE compatibility assumptions. -/
theorem gravity_projected_times_beta_eq_derived_numerator
    (m : ModularForcedEntropicModel)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hPhys : ComplexEinsteinDiracEfeForcingAssumptions m traj t hNS) :
    m.dict.beta * m.dict.gravityProjected =
      derivedGravityNumerator m traj t hNS hPhys := by
  unfold derivedGravityNumerator
  calc
    m.dict.beta * m.dict.gravityProjected
        = m.dict.beta * (hPhys.gravityEinsteinCoupling * hPhys.einsteinImag) := by
            rw [hPhys.gravity_from_einstein_imag]
    _ = hPhys.gravityEinsteinCoupling * (m.dict.beta * hPhys.einsteinImag) := by ring
    _ = hPhys.gravityEinsteinCoupling *
          (m.dict.beta * (hPhys.kappaEFE * hPhys.stressImag)) := by
            rw [hPhys.efe_imag_sector_relation]
    _ = hPhys.gravityEinsteinCoupling * hPhys.kappaEFE *
          (m.dict.beta * hPhys.stressImag) := by ring
    _ = hPhys.gravityEinsteinCoupling * hPhys.kappaEFE *
          (m.dict.beta * imaginaryNoetherDefect traj t) := by
            rw [hPhys.stress_imag_is_defect]
    _ = hPhys.gravityEinsteinCoupling * hPhys.kappaEFE *
          (m.dict.beta * (hPhys.density * hPhys.diracMass)) := by
            rw [hPhys.defect_is_density_times_dirac_mass]
    _ = hPhys.gravityEinsteinCoupling * hPhys.kappaEFE * hPhys.density *
          (m.dict.beta * hPhys.diracMass) := by ring
    _ = hPhys.gravityEinsteinCoupling * hPhys.kappaEFE * hPhys.density *
          hPhys.diracThermalScale := by
            rw [hPhys.dirac_thermal_relation]

/-- Stronger inverse-temperature forcing law from complex Einstein+Dirac+EFE:
`gravityProjected = derivedGravityNumerator / beta`. -/
theorem gravity_projected_eq_derived_inverse_temperature_channel
    (m : ModularForcedEntropicModel)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hPhys : ComplexEinsteinDiracEfeForcingAssumptions m traj t hNS) :
    m.dict.gravityProjected =
      (derivedGravityNumerator m traj t hNS hPhys) / m.dict.beta := by
  have hProd :
      m.dict.beta * m.dict.gravityProjected =
        derivedGravityNumerator m traj t hNS hPhys :=
    gravity_projected_times_beta_eq_derived_numerator m traj t hNS hPhys
  have hBetaNe : m.dict.beta ≠ 0 := ne_of_gt m.dict.beta_pos
  exact (eq_div_iff hBetaNe).2 (by
    calc
      m.dict.gravityProjected * m.dict.beta
          = m.dict.beta * m.dict.gravityProjected := by ring
      _ = derivedGravityNumerator m traj t hNS hPhys := hProd)

/-- Stronger full forcing claim:
the forcing term is determined by derived inverse-temperature gravity channel
plus residual forcing. -/
theorem forcing_term_eq_derived_inverse_temperature_plus_residual
    (m : ModularForcedEntropicModel)
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hPhys : ComplexEinsteinDiracEfeForcingAssumptions m traj t hNS) :
    m.pde.forcingTerm =
      (derivedGravityNumerator m traj t hNS hPhys) / m.dict.beta +
      m.dict.residualForcing := by
  calc
    m.pde.forcingTerm = m.dict.gravityProjected + m.dict.residualForcing := by
      rw [m.forcing_consistent, m.dict.forcing_split]
    _ = (derivedGravityNumerator m traj t hNS hPhys) / m.dict.beta +
          m.dict.residualForcing := by
            rw [gravity_projected_eq_derived_inverse_temperature_channel m traj t hNS hPhys]

def nsModularForcingClaims : List LabeledClaim :=
  [ ⟨"forcing_term_modular_split", .verified,
      "THEOREM: forcing term can be represented as kappa_g/beta + residual forcing."⟩
  , ⟨"modular_forced_reparam_iff", .verified,
      "THEOREM: NS classical/entropic reparameterization equivalence holds with forcing retained."⟩
  , ⟨"no_gravity_profile_is_optional_specialization", .verified,
      "THEOREM: forcingTerm=0 is an optional specialization, not a required assumption."⟩
  , ⟨"thermal_force_dictionary_constructible", .verified,
      "THEOREM: gravity-as-inverse-temperature dictionary is constructible for any beta>0."⟩
  , ⟨"gravity_projected_eq_derived_inverse_temperature_channel", .partiallyVerified,
      "THEOREM: under explicit complex Einstein+Dirac+EFE compatibility assumptions, gravity-like forcing is derived as a beta-inverse channel (not arbitrary)."⟩
  , ⟨"forcing_term_eq_derived_inverse_temperature_plus_residual", .partiallyVerified,
      "THEOREM: under the same assumptions, full forcing equals derived inverse-temperature gravity channel plus residual forcing."⟩
  ]

end

end NavierStokes.Bridges.NSModularForcing
