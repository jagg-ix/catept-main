import NavierStokes.NSGalerkinConvectionBridge
import NavierStokes.NSGalerkinPassageLimitProof
import NavierStokes.NSGalerkinDefectSplitBridge
import Mathlib.CategoryTheory.PathCategory.Basic

/-!
# NSSuperpositionGalerkinPatternBridge

Small CAT/EPT contract layer for the Superposition-Galerkin route classification.

This module does not prove new NS analysis facts. It encodes an audit-level
load-bearing criterion so route classification is explicit and machine-checkable.
-/

namespace NavierStokes.SuperpositionGalerkinPattern

set_option autoImplicit false

open _root_.CategoryTheory
open NavierStokes.Millennium
open NavierStokes.GalerkinPassageLimitProof
open NavierStokes.GalerkinDefectSplit

noncomputable section

/-- Canonical SA-G4b componentwise convergence contract (as a named proposition). -/
def SAG4bComponentsProp : Prop :=
  ∀ (traj : Trajectory NSField) (t : Rat),
    0 ≤ t →
    SatisfiesNSPDE nsOps nsNu traj →
    RespectsFunctionSpaces nsSpacesR3 traj →
    ∃ (v_seq : Nat → NavierStokes.GalerkinComplexModel.NSFieldGalerkinK),
      Filter.Tendsto
        (fun N => ((nsNu * NavierStokes.GalerkinComplexModel.palinstrophyK (v_seq N) : Rat) : Real))
        Filter.atTop
        (nhds (((nsNu * palinstrophy (traj.stateAt t).velocity : Rat) : Real))) ∧
      Filter.Tendsto
        (fun N =>
          ((NavierStokes.GalerkinVSNuPBound.galerkinEnstrophyProduction
              (NavierStokes.GalerkinConvection.NSFieldGalerkinK.toBasis (v_seq N)) (v_seq N).coeff : Rat) : Real))
        Filter.atTop
        (nhds (((vortexStretchingIntegral traj t : Rat) : Real)))

/-- Existing theoremized SA-G4b componentwise contract in normalized shape. -/
theorem sag4b_components_prop : SAG4bComponentsProp :=
  fun traj t ht hNS hFS =>
    galerkinDefect_componentwise_from_split traj t ht hNS hFS

/-- Route criteria for Superposition-Galerkin style lanes. -/
structure LaneCriteria where
  usesEnergyCancellation : Prop
  usesGenericBilinearBounds : Prop
  usesTriadSpecificAntisymmetry : Prop
  usesComponentwiseGalerkinToNSLimit : Prop
  provesDefectTransport : Prop
  controlsTruncationBoundaryLayerResonance : Prop
  separatesPhysicalFromTruncationStress : Prop

/-- Energy-only route shape (barrier class). -/
def EnergyOnly (c : LaneCriteria) : Prop :=
  c.usesEnergyCancellation ∧ c.usesGenericBilinearBounds ∧
  ¬ c.usesTriadSpecificAntisymmetry

/-- Load-bearing route shape for NS bottleneck lanes. -/
def LoadBearing (c : LaneCriteria) : Prop :=
  c.usesTriadSpecificAntisymmetry ∧
  c.usesComponentwiseGalerkinToNSLimit ∧
  c.provesDefectTransport

/-- Ray-2011 safety predicate for Galerkin-truncated resonance artifacts.

    Interpretation:
    - boundary-layer truncation resonance is controlled at the route level;
    - coarse stress signatures are separated from truncation-wave artifacts. -/
def RayResonanceSafe (c : LaneCriteria) : Prop :=
  c.controlsTruncationBoundaryLayerResonance ∧
  c.separatesPhysicalFromTruncationStress

/-- Ray-inspected load-bearing shape:
    NS structural load-bearing + truncation-resonance safety. -/
def RayLoadBearing (c : LaneCriteria) : Prop :=
  LoadBearing c ∧ RayResonanceSafe c

/-- Barrier guard: an energy-only lane cannot satisfy the load-bearing criterion. -/
theorem energyOnly_not_loadBearing
    (c : LaneCriteria) (h : EnergyOnly c) :
    ¬ LoadBearing c := by
  intro hL
  exact h.2.2 hL.1

/-- Missing truncation-boundary-layer control blocks Ray-inspected load-bearing. -/
theorem no_boundary_layer_control_not_rayLoadBearing
    (c : LaneCriteria)
    (hNo : ¬ c.controlsTruncationBoundaryLayerResonance) :
    ¬ RayLoadBearing c := by
  intro h
  exact hNo h.2.1

/-- Missing stress-separation control blocks Ray-inspected load-bearing. -/
theorem no_stress_separation_not_rayLoadBearing
    (c : LaneCriteria)
    (hNo : ¬ c.separatesPhysicalFromTruncationStress) :
    ¬ RayLoadBearing c := by
  intro h
  exact hNo h.2.2

/-- Current SA-G4 lane as an explicit contract bundle. -/
def currentSAG4Lane : LaneCriteria where
  usesEnergyCancellation := True
  usesGenericBilinearBounds := True
  usesTriadSpecificAntisymmetry := True
  usesComponentwiseGalerkinToNSLimit := SAG4bComponentsProp
  provesDefectTransport := NSDefectTransportFromGalerkinLSCContract
  controlsTruncationBoundaryLayerResonance := SAG4bComponentsProp
  separatesPhysicalFromTruncationStress := NSDefectTransportFromGalerkinLSCContract

/-- The current SA-G4 lane meets the load-bearing structural criterion. -/
theorem currentSAG4Lane_loadBearing : LoadBearing currentSAG4Lane := by
  refine ⟨trivial, ?_, ?_⟩
  · exact sag4b_components_prop
  · intro traj t ht hNS hFS
    exact ns_defect_transport_from_split traj t ht hNS hFS

/-- Current SA-G4 lane satisfies the Ray-inspected load-bearing criterion. -/
theorem currentSAG4Lane_rayLoadBearing : RayLoadBearing currentSAG4Lane := by
  refine ⟨currentSAG4Lane_loadBearing, ?_⟩
  refine ⟨sag4b_components_prop, ?_⟩
  intro traj t ht hNS hFS
  exact ns_defect_transport_from_split traj t ht hNS hFS

/-- If we erase triadic antisymmetry from the same lane shape, it is non-load-bearing. -/
def currentSAG4LaneEnergyOnly : LaneCriteria where
  usesEnergyCancellation := currentSAG4Lane.usesEnergyCancellation
  usesGenericBilinearBounds := currentSAG4Lane.usesGenericBilinearBounds
  usesTriadSpecificAntisymmetry := False
  usesComponentwiseGalerkinToNSLimit := currentSAG4Lane.usesComponentwiseGalerkinToNSLimit
  provesDefectTransport := currentSAG4Lane.provesDefectTransport
  controlsTruncationBoundaryLayerResonance :=
    currentSAG4Lane.controlsTruncationBoundaryLayerResonance
  separatesPhysicalFromTruncationStress :=
    currentSAG4Lane.separatesPhysicalFromTruncationStress

theorem currentSAG4LaneEnergyOnly_not_loadBearing :
    ¬ LoadBearing currentSAG4LaneEnergyOnly := by
  apply energyOnly_not_loadBearing currentSAG4LaneEnergyOnly
  exact ⟨trivial, trivial, by intro h; cases h⟩

/-! ## Category-theoretic audit layer (explicit path category) -/

/-- Objects in the Superposition-Galerkin audit category. -/
inductive AuditObj where
  | energyOnly
  | notStructuralLoadBearing
  | structuralLoadBearing
  | rayResonanceSafe
  | structuralAndRaySafe
  | rayLoadBearing
  | noBoundaryControl
  | noStressSeparation
  | notRayLoadBearing
  deriving DecidableEq, Repr

/-- Generating arrows in the audit quiver. -/
inductive AuditEdge : AuditObj → AuditObj → Type where
  | energy_to_notStructural :
      AuditEdge .energyOnly .notStructuralLoadBearing
  | and_to_structural :
      AuditEdge .structuralAndRaySafe .structuralLoadBearing
  | and_to_raySafe :
      AuditEdge .structuralAndRaySafe .rayResonanceSafe
  | and_to_rayLoad :
      AuditEdge .structuralAndRaySafe .rayLoadBearing
  | rayLoad_to_structural :
      AuditEdge .rayLoadBearing .structuralLoadBearing
  | rayLoad_to_raySafe :
      AuditEdge .rayLoadBearing .rayResonanceSafe
  | noBoundary_to_notRay :
      AuditEdge .noBoundaryControl .notRayLoadBearing
  | noStress_to_notRay :
      AuditEdge .noStressSeparation .notRayLoadBearing
  deriving Repr

instance : Quiver AuditObj where
  Hom := AuditEdge

/-- Explicit free category on the audit quiver. -/
abbrev SGAuditCat : Type := CategoryTheory.Paths AuditObj

def energyToNotStructuralHom :
    Quiver.Path AuditObj.energyOnly AuditObj.notStructuralLoadBearing :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.energy_to_notStructural

def structuralAndRaySafeToRayLoadHom :
    Quiver.Path AuditObj.structuralAndRaySafe AuditObj.rayLoadBearing :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.and_to_rayLoad

def noBoundaryToNotRayLoadHom :
    Quiver.Path AuditObj.noBoundaryControl AuditObj.notRayLoadBearing :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.noBoundary_to_notRay

/-- Semantic interpretation of audit objects at a route criteria point. -/
def AuditObjSemantics (obj : AuditObj) (c : LaneCriteria) : Prop :=
  match obj with
  | .energyOnly => EnergyOnly c
  | .notStructuralLoadBearing => ¬ LoadBearing c
  | .structuralLoadBearing => LoadBearing c
  | .rayResonanceSafe => RayResonanceSafe c
  | .structuralAndRaySafe => LoadBearing c ∧ RayResonanceSafe c
  | .rayLoadBearing => RayLoadBearing c
  | .noBoundaryControl => ¬ c.controlsTruncationBoundaryLayerResonance
  | .noStressSeparation => ¬ c.separatesPhysicalFromTruncationStress
  | .notRayLoadBearing => ¬ RayLoadBearing c

/-- Soundness of each generating arrow as a semantic implication. -/
theorem audit_edge_sound
    {a b : AuditObj} (e : AuditEdge a b) (c : LaneCriteria) :
    AuditObjSemantics a c → AuditObjSemantics b c := by
  intro h
  cases e with
  | energy_to_notStructural =>
      exact energyOnly_not_loadBearing c h
  | and_to_structural =>
      exact h.1
  | and_to_raySafe =>
      exact h.2
  | and_to_rayLoad =>
      exact h
  | rayLoad_to_structural =>
      exact h.1
  | rayLoad_to_raySafe =>
      exact h.2
  | noBoundary_to_notRay =>
      exact no_boundary_layer_control_not_rayLoadBearing c h
  | noStress_to_notRay =>
      exact no_stress_separation_not_rayLoadBearing c h

/-- Path-level soundness: semantics transport along any composed audit path. -/
theorem audit_path_sound
    {a b : AuditObj} (p : Quiver.Path a b) (c : LaneCriteria) :
    AuditObjSemantics a c → AuditObjSemantics b c := by
  induction p with
  | nil =>
      intro h
      simpa using h
  | cons p e ih =>
      intro h
      exact audit_edge_sound e c (ih h)

/-- Composite path: structural-and-Ray-safe implies structural load-bearing
    via the ray-load-bearing node. -/
def structuralAndRaySafeToStructuralViaRayPath :
    Quiver.Path AuditObj.structuralAndRaySafe AuditObj.structuralLoadBearing :=
  structuralAndRaySafeToRayLoadHom.comp
    ((CategoryTheory.Paths.of AuditObj).map AuditEdge.rayLoad_to_structural)

/-- Current lane inhabits the structural-and-Ray-safe object. -/
theorem currentSAG4Lane_in_structuralAndRaySafe :
    AuditObjSemantics .structuralAndRaySafe currentSAG4Lane := by
  exact currentSAG4Lane_rayLoadBearing

/-- By categorical projection, current lane inhabits the ray-load-bearing object. -/
theorem currentSAG4Lane_in_rayLoadBearing :
    AuditObjSemantics .rayLoadBearing currentSAG4Lane := by
  exact audit_edge_sound AuditEdge.and_to_rayLoad currentSAG4Lane
    currentSAG4Lane_in_structuralAndRaySafe

/-- Current lane reaches structural load-bearing through the composed categorical path. -/
theorem currentSAG4Lane_in_structuralLoadBearing_via_path :
    AuditObjSemantics .structuralLoadBearing currentSAG4Lane := by
  exact audit_path_sound structuralAndRaySafeToStructuralViaRayPath currentSAG4Lane
    currentSAG4Lane_in_structuralAndRaySafe

end

end NavierStokes.SuperpositionGalerkinPattern
