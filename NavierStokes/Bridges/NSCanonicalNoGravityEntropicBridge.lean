import NavierStokes.Bridges.EntropicTimeReparam
import NavierStokes.Bridges.NSModularNoetherBridge

/-!
# NS Canonical No-Gravity Entropic Bridge

Canonical bridge for the forcing-free Navier-Stokes form used in the CAT/EPT
workstation document:
- no external gravity/body-force term (`forcingTerm = 0`);
- entropic-time reparameterization via `d/dt = lambda * d/dtau`;
- default CAT/EPT(NS) clock specialization `lambda = Omega/2`.

This module intentionally avoids adding new PDE closure claims.
-/

namespace NavierStokes.Bridges.NSCanonicalNoGravityEntropic

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.EntropicTimeMechanics
open NavierStokes.Bridges.NSModularNoether

noncomputable section

/-! ## 1. Canonical No-Gravity Model -/

/-- Structural NS reparameterization model with no external force term. -/
structure NoGravityEntropicModel where
  pde : NSEntropicPDEData
  no_gravity : pde.forcingTerm = 0

/-- In the canonical model, the force term is identically zero. -/
theorem no_gravity_force_zero (m : NoGravityEntropicModel) :
    m.pde.forcingTerm = 0 :=
  m.no_gravity

/-- Forcing-free spatial residual form:
`R = convection + pressure - viscous`. -/
theorem no_gravity_spatial_residual_form (m : NoGravityEntropicModel) :
    m.pde.spatialResidual =
      m.pde.convectionTerm + m.pde.pressureGradientTerm - m.pde.viscousDiffusionTerm := by
  unfold NSEntropicPDEData.spatialResidual
  simp [m.no_gravity]

/-- Classical-time forcing-free NS balance in explicit form. -/
theorem no_gravity_classical_form (m : NoGravityEntropicModel) :
    NSClassicalPDE m.pde ↔
      m.pde.timeDerivative_t +
        (m.pde.convectionTerm + m.pde.pressureGradientTerm - m.pde.viscousDiffusionTerm) = 0 := by
  unfold NSClassicalPDE NSEntropicPDEData.spatialResidual
  simp [m.no_gravity]

/-- Entropic-time forcing-free NS balance in explicit form. -/
theorem no_gravity_entropic_scaled_form (m : NoGravityEntropicModel) :
    NSEntropicScaledPDE m.pde ↔
      m.pde.lambda * m.pde.timeDerivative_tau +
        (m.pde.convectionTerm + m.pde.pressureGradientTerm - m.pde.viscousDiffusionTerm) = 0 := by
  unfold NSEntropicScaledPDE NSEntropicPDEData.spatialResidual
  simp [m.no_gravity]

/-- Canonical forcing-free reparameterization equivalence:
`NSClassicalPDE <-> NSEntropicScaledPDE`. -/
theorem no_gravity_reparam_iff (m : NoGravityEntropicModel) :
    NSClassicalPDE m.pde ↔ NSEntropicScaledPDE m.pde :=
  ns_pde_reparam_iff m.pde

/-! ## 2. CAT/EPT(NS) Default Clock -/

/-- Default CAT/EPT(NS) clock used in the canonical forcing-free rewrite. -/
def canonicalClockRateNS
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) : Rat :=
  catEptRateNS traj t hNS

/-- By definition, the default clock is `Omega/2`. -/
theorem canonical_clock_is_omega_half
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) :
    canonicalClockRateNS traj t hNS =
      enstrophy (traj.stateAt t).velocity / 2 := by
  rfl

/-- Operational entropic rate equals canonical CAT/EPT(NS) default `Omega/2`. -/
theorem operational_clock_matches_canonical_default
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj) :
    entropicRateNS traj t = canonicalClockRateNS traj t hNS :=
  entropicRateNS_eq_catEptRateNS traj t hNS

/-- Canonical no-gravity bottleneck identity remains:
`dOmega/dt = -2*(nu*P - VS)`. -/
theorem canonical_no_gravity_enstrophy_defect_identity
    (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (hFS : RespectsFunctionSpaces nsSpacesR3 traj) :
    enstrophyRate traj t = -2 * imaginaryNoetherDefect traj t :=
  enstrophyRate_eq_neg_two_imaginaryNoetherDefect traj t hNS hFS

/-! ## 3. Canonical Contract -/

/-- Canonical no-gravity CAT/EPT contract:
clock specialization (`lambda = Omega/2`) plus defect identity. -/
def CanonicalNoGravityEntropicContractProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat)
    (hNS : SatisfiesNSPDE nsOps nsNu traj)
    (_hFS : RespectsFunctionSpaces nsSpacesR3 traj),
    entropicRateNS traj t = canonicalClockRateNS traj t hNS ∧
    enstrophyRate traj t = -2 * imaginaryNoetherDefect traj t

/-- The canonical no-gravity CAT/EPT contract is theorem-backed. -/
theorem canonical_no_gravity_entropic_contract :
    CanonicalNoGravityEntropicContractProp := by
  intro traj t hNS hFS
  constructor
  · exact operational_clock_matches_canonical_default traj t hNS
  · exact canonical_no_gravity_enstrophy_defect_identity traj t hNS hFS

/-! ## 4. Claim Registry -/

def canonicalNoGravityEntropicClaims : List LabeledClaim :=
  [ ⟨"no_gravity_reparam_iff", .verified,
      "THEOREM: forcing-free NS classical form is equivalent to forcing-free entropic-time scaled form."⟩
  , ⟨"canonical_clock_is_omega_half", .verified,
      "THEOREM: canonical CAT/EPT(NS) default clock is lambda = Omega/2."⟩
  , ⟨"operational_clock_matches_canonical_default", .verified,
      "THEOREM: operational entropic rate equals canonical CAT/EPT(NS) default clock."⟩
  , ⟨"canonical_no_gravity_enstrophy_defect_identity", .verified,
      "THEOREM: forcing-free canonical bottleneck identity dOmega/dt = -2*(nu*P - VS)."⟩
  , ⟨"canonical_no_gravity_entropic_contract", .verified,
      "THEOREM: canonical no-gravity CAT/EPT contract (clock + defect identity) holds."⟩
  ]

end

end NavierStokes.Bridges.NSCanonicalNoGravityEntropic
