import NavierStokes.DualRiemannSphereNSBridge

/-!
# Dual-Sphere OM/FW/LDP/HJB Bridge Pack (Pre-BKM Layer)

This module registers the measure-to-PDE bridge stack (OM/FW/LDP/HJB) as an
explicit assumption package for the dual-sphere route, while preserving honest
status discipline:

- contracts (1)-(4) can be staged here as a pre-BKM package
- contract (5) `control_bkm_integral` remains the single open bridge

No Navier-Stokes closure claim is upgraded in this file.
-/

namespace NavierStokes.Millennium

set_option autoImplicit false

noncomputable section

/-- Dual-sphere contract package reduced to items (1)-(4), i.e. everything
except global BKM/vorticity control. -/
structure DualSphereToNSPreBKMContracts
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField) where
  map_to_velocity_pressure_fields :
    ∃ traj : Trajectory NSField, traj.stateAt 0 = st0
  preserve_incompressibility :
    ∀ traj : Trajectory NSField,
      traj.stateAt 0 = st0 ->
      SatisfiesNSPDE nsOps nsNu traj ->
      ∀ t : Rat, nsDivFree (traj.stateAt t).velocity
  preserve_pressure_projection :
    Prop
  recover_navier_stokes_dynamics :
    ∀ traj : Trajectory NSField,
      traj.stateAt 0 = st0 ->
      SatisfiesNSPDE nsOps nsNu traj

/-- Single remaining dual-sphere bridge obligation after pre-BKM staging:
global vorticity control (equivalently the BKM-control contract field). -/
def DualSphereSingleOpenBridge
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField) : Prop :=
  NSGlobalVorticityControl pi st0

/-- Reference-stack assumptions representing the OM/FW/LDP/HJB bridge program.

These fields are registered as bridge assumptions/references, not reproved
inside this module. -/
structure OMFWLDPHJBBridgeAssumptions
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField) where
  om_mode_to_fw_mode_convergence_reference : Prop
  ldp_renorm_to_rate_function_reference : Prop
  hjb_viscosity_solution_reference : Prop
  om_trajectory_regularization_reference : Prop
  preBKMContracts : DualSphereToNSPreBKMContracts pi st0

/-! ## B1 decomposition in the OM/FW language

The remaining B1 bridge is decomposed into the three concrete components:
1. FW equicoercivity in 3D (OM/Γ sense)
2. FW+Cameron sublevel control of `H^s`, `s > 5/2`
3. HJB viscosity-solution regularity transfer

The composition target is BKM-integral finiteness, then statewise vorticity
control (`DualSphereSingleOpenBridge`).
-/

/-- OM/FW + Cameron combined functional skeleton:
`I_hbar(v) = FW(v) + (1/hbar) S_I(v)` with `S_I/hbar = tau_ent`. -/
def fwCameronAugmentedFunctional (traj : Trajectory NSField) (T : Rat) : Rat :=
  fwRateFunctional traj T + entropicProperTime traj T

/-- B1 sub-obligation 1:
equicoercivity of FW sublevels in 3D (registered as bridge contract). -/
def FWEquicoercive3D : Prop :=
  ∀ (M T : Rat),
    0 < T ->
    ∀ (traj : Trajectory NSField),
      fwRateFunctional traj T ≤ M ->
      RespectsFunctionSpaces nsSpacesR3 traj

/-- B1 sub-obligation 2:
FW+Cameron bounded sublevels control `H^s`-class regularity (`s > 5/2`),
abstracted here through BKM-integral finiteness over admissible trajectories. -/
def FWplusCameronSublevelControlsHs : Prop :=
  ∀ (M T : Rat),
    0 < T ->
    ∀ (traj : Trajectory NSField),
      SatisfiesNSPDE nsOps nsNu traj ->
      RespectsFunctionSpaces nsSpacesR3 traj ->
      fwCameronAugmentedFunctional traj T ≤ M ->
      BKMIntegralFiniteAt traj T

/-- B1 sub-obligation 3:
HJB viscosity-solution regularity transfer interface.

This upgrades the trajectory-level BKM finite family into the statewise
vorticity-control contract used by the NS bridge chain. -/
def HJBViscosityRegularityTransfer
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField) : Prop :=
  (∀ (traj : Trajectory NSField) (T : Rat),
      0 < T ->
      traj.stateAt 0 = st0 ->
      SatisfiesNSPDE nsOps nsNu traj ->
      RespectsFunctionSpaces nsSpacesR3 traj ->
      BKMIntegralFiniteAt traj T) ->
    NSGlobalVorticityControl pi st0

/-- Structured B1 decomposition package aligned with the focused gap statement. -/
structure B1CoercivityDecomposition
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField) where
  fw_equicoercive_3d : FWEquicoercive3D
  fwpluscameron_sublevel_controls_Hs : FWplusCameronSublevelControlsHs
  hjb_viscosity_solution_regularity_transfer : HJBViscosityRegularityTransfer pi st0
  /-- Composition stage:
  from the three obligations, produce trajectory-level BKM finite control. -/
  compose_to_bkm_family :
    FWEquicoercive3D ->
    FWplusCameronSublevelControlsHs ->
    ∀ (traj : Trajectory NSField) (T : Rat),
      0 < T ->
      traj.stateAt 0 = st0 ->
      SatisfiesNSPDE nsOps nsNu traj ->
      RespectsFunctionSpaces nsSpacesR3 traj ->
      BKMIntegralFiniteAt traj T

/-- Focused B1 reducer:
the three sub-obligations imply the single open dual-sphere bridge contract. -/
theorem b1_three_subobligations_imply_single_open_bridge
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField)
    (B1 : B1CoercivityDecomposition pi st0) :
    DualSphereSingleOpenBridge pi st0 := by
  have hBKMFamily :
      ∀ (traj : Trajectory NSField) (T : Rat),
        0 < T ->
        traj.stateAt 0 = st0 ->
        SatisfiesNSPDE nsOps nsNu traj ->
        RespectsFunctionSpaces nsSpacesR3 traj ->
        BKMIntegralFiniteAt traj T :=
    B1.compose_to_bkm_family
      B1.fw_equicoercive_3d
      B1.fwpluscameron_sublevel_controls_Hs
  exact B1.hjb_viscosity_solution_regularity_transfer hBKMFamily

/-- Helper: extend pre-BKM contracts with the single open bridge contract. -/
def extendPreBKMToFullContracts
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField)
    (Cpre : DualSphereToNSPreBKMContracts pi st0)
    (hOpen : DualSphereSingleOpenBridge pi st0) :
    DualSphereToNSContracts pi st0 where
  map_to_velocity_pressure_fields := Cpre.map_to_velocity_pressure_fields
  preserve_incompressibility := Cpre.preserve_incompressibility
  preserve_pressure_projection := Cpre.preserve_pressure_projection
  recover_navier_stokes_dynamics := Cpre.recover_navier_stokes_dynamics
  control_bkm_integral := hOpen

/-- Main reducer: OM/FW/LDP/HJB assumptions + pre-BKM contracts reduce the
dual-sphere derivation to a single open bridge contract. -/
theorem dualSphere_preBKM_plus_single_open_bridge_implies_globalRegularity
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField)
    (A : OMFWLDPHJBBridgeAssumptions pi st0)
    (hPI : pi.PIWellPosed st0)
    (hOpen : DualSphereSingleOpenBridge pi st0) :
    GlobalRegularSolution nsOps nsSpacesR3 nsNu st0 := by
  let Cfull : DualSphereToNSContracts pi st0 :=
    extendPreBKMToFullContracts pi st0 A.preBKMContracts hOpen
  exact dualSphereContracts_imply_globalRegularity pi st0 Cfull hPI

/-- Variant using the focused B1 decomposition package as the provider of the
single open bridge contract. -/
theorem dualSphere_preBKM_plus_b1_decomposition_implies_globalRegularity
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField)
    (A : OMFWLDPHJBBridgeAssumptions pi st0)
    (B1 : B1CoercivityDecomposition pi st0)
    (hPI : pi.PIWellPosed st0) :
    GlobalRegularSolution nsOps nsSpacesR3 nsNu st0 := by
  have hOpen : DualSphereSingleOpenBridge pi st0 :=
    b1_three_subobligations_imply_single_open_bridge pi st0 B1
  exact dualSphere_preBKM_plus_single_open_bridge_implies_globalRegularity
    pi st0 A hPI hOpen

/-- This bridge-pack does not by itself close the dual-sphere NS gap. -/
theorem omfw_bridge_pack_not_closed
    (pi : PathIntegralInterface NSField)
    (st0 : State NSField)
    (_A : OMFWLDPHJBBridgeAssumptions pi st0) :
    ¬ DualSphereNSBridgeClosed := by
  exact dualSphereNSBridge_not_closed

/-- Epistemic status summary for this module.
Reference-stack statements are registered as partially verified external support;
the single bridge contract remains open. -/
def dualSphereOMFWEpistemicStatus : List LabeledClaim :=
  [ ⟨"om_fw_gamma_convergence_reference", .partiallyVerified,
      "OM/FW minimizer pipeline registered as external bridge support"⟩
  , ⟨"ldp_renormalization_reference", .partiallyVerified,
      "LDP renormalization-to-rate-function pattern registered as support"⟩
  , ⟨"hjb_ns_reference", .partiallyVerified,
      "HJB/LDP PDE characterization registered as support layer"⟩
  , ⟨"fw_equicoercive_3d", .openBridge,
      "B1-1: FW equicoercivity in 3D (OM/Gamma sense)"⟩
  , ⟨"fwpluscameron_sublevel_controls_Hs", .openBridge,
      "B1-2: FW+Cameron sublevels control H^s for s > 5/2"⟩
  , ⟨"hjb_viscosity_solution_regularity_transfer", .openBridge,
      "B1-3: HJB viscosity regularity transfers to BKM/state control"⟩
  , ⟨"dual_sphere_single_open_bridge", .openBridge,
      "Single remaining contract: NSGlobalVorticityControl (BKM bridge)"⟩
  ]

end

end NavierStokes.Millennium
