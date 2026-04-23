import NavierStokes.Galerkin.NSSuperpositionGalerkinPatternBridge
import NavierStokes.Bridges.NSSharedClockMomentumCategoryBridge

/-!
# NSSuperpositionToSharedClockFunctorBridge

Categorical bridge from the Superposition-Galerkin audit path category to the
shared clock/momentum path category.

This encodes an explicit functor-level alignment so audit paths can be pushed
into the shared CAT/EPT interface.
-/

namespace NavierStokes.SuperpositionGalerkinPattern

set_option autoImplicit false

open _root_.CategoryTheory
open NavierStokes.Bridges.NSSharedClockMomentumCategory

noncomputable section

/-- Object map from audit objects to shared clock/momentum objects.

Design intent:
- Structural closure nodes map to the momentum bottleneck object.
- Energy-only and "not-ray-load-bearing" nodes map to local clock-rate.
- Missing-control nodes map to entropic proper time (upstream channel).
-/
def auditObjToSharedObj : AuditObj → SharedObj
  | .energyOnly => .localClockRate
  | .notStructuralLoadBearing => .momentumBottleneck
  | .structuralLoadBearing => .momentumBottleneck
  | .rayResonanceSafe => .momentumBottleneck
  | .structuralAndRaySafe => .momentumBottleneck
  | .rayLoadBearing => .momentumBottleneck
  | .noBoundaryControl => .entropicProperTime
  | .noStressSeparation => .entropicProperTime
  | .notRayLoadBearing => .localClockRate

/-- Edge map into shared-category morphisms. -/
def auditEdgeToSharedHom {a b : AuditObj} (e : AuditEdge a b) :
    Quiver.Path (auditObjToSharedObj a) (auditObjToSharedObj b) := by
  cases e with
  | energy_to_notStructural =>
      simpa [auditObjToSharedObj] using
        (clockToMomentumContractHom :
          Quiver.Path SharedObj.localClockRate SharedObj.momentumBottleneck)
  | and_to_structural =>
      exact Quiver.Path.nil
  | and_to_raySafe =>
      exact Quiver.Path.nil
  | and_to_rayLoad =>
      exact Quiver.Path.nil
  | rayLoad_to_structural =>
      exact Quiver.Path.nil
  | rayLoad_to_raySafe =>
      exact Quiver.Path.nil
  | noBoundary_to_notRay =>
      simpa [auditObjToSharedObj] using
        (tauToRateContractHom :
          Quiver.Path SharedObj.entropicProperTime SharedObj.localClockRate)
  | noStress_to_notRay =>
      simpa [auditObjToSharedObj] using
        (tauToRateContractHom :
          Quiver.Path SharedObj.entropicProperTime SharedObj.localClockRate)

/-- Quiver prefunctor from audit quiver into the shared path category. -/
def auditToSharedPrefunctor : AuditObj ⥤q SharedClockMomentumCat where
  obj := auditObjToSharedObj
  map := fun {_ _} e => auditEdgeToSharedHom e

/-- Functor from audit path category to shared clock/momentum path category. -/
def auditToSharedFunctor : SGAuditCat ⥤ SharedClockMomentumCat :=
  CategoryTheory.Paths.lift auditToSharedPrefunctor

/-- Additional named generator path in the audit category. -/
def noStressToNotRayLoadHom :
    Quiver.Path AuditObj.noStressSeparation AuditObj.notRayLoadBearing :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.noStress_to_notRay

/-- Direct generator: structural-and-Ray-safe to structural load-bearing. -/
def structuralAndRaySafeToStructuralHom :
    Quiver.Path AuditObj.structuralAndRaySafe AuditObj.structuralLoadBearing :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.and_to_structural

/-- Direct generator: structural-and-Ray-safe to ray-resonance-safe. -/
def structuralAndRaySafeToRaySafeHom :
    Quiver.Path AuditObj.structuralAndRaySafe AuditObj.rayResonanceSafe :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.and_to_raySafe

/-- Direct generator: ray-load-bearing to structural load-bearing. -/
def rayLoadToStructuralHom :
    Quiver.Path AuditObj.rayLoadBearing AuditObj.structuralLoadBearing :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.rayLoad_to_structural

/-- Direct generator: ray-load-bearing to ray-resonance-safe. -/
def rayLoadToRaySafeHom :
    Quiver.Path AuditObj.rayLoadBearing AuditObj.rayResonanceSafe :=
  (CategoryTheory.Paths.of AuditObj).map AuditEdge.rayLoad_to_raySafe

/-- Composite path to ray-resonance-safe routed through ray-load-bearing. -/
def structuralAndRaySafeToRaySafeViaRayLoadPath :
    Quiver.Path AuditObj.structuralAndRaySafe AuditObj.rayResonanceSafe :=
  structuralAndRaySafeToRayLoadHom.comp rayLoadToRaySafeHom

/-- Functor image of the energy-to-not-structural generator. -/
theorem auditToShared_map_energyToNotStructural :
    auditToSharedFunctor.map energyToNotStructuralHom = clockToMomentumContractHom := by
  simp [auditToSharedFunctor, energyToNotStructuralHom, auditToSharedPrefunctor, auditEdgeToSharedHom]

/-- Functor image of the no-boundary-control generator. -/
theorem auditToShared_map_noBoundaryToNotRay :
    auditToSharedFunctor.map noBoundaryToNotRayLoadHom = tauToRateContractHom := by
  simp [auditToSharedFunctor, noBoundaryToNotRayLoadHom, auditToSharedPrefunctor, auditEdgeToSharedHom]

/-- Functor image of the no-stress-separation generator. -/
theorem auditToShared_map_noStressToNotRay :
    auditToSharedFunctor.map noStressToNotRayLoadHom = tauToRateContractHom := by
  simp [auditToSharedFunctor, noStressToNotRayLoadHom, auditToSharedPrefunctor, auditEdgeToSharedHom]

/-- Functor image of direct structural-and-Ray-safe → structural generator. -/
theorem auditToShared_map_structuralAndRaySafeToStructural :
    auditToSharedFunctor.map structuralAndRaySafeToStructuralHom =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck) := by
  simp [auditToSharedFunctor, structuralAndRaySafeToStructuralHom, auditToSharedPrefunctor,
    auditEdgeToSharedHom]
  rfl

/-- Functor image of direct structural-and-Ray-safe → ray-safe generator. -/
theorem auditToShared_map_structuralAndRaySafeToRaySafe :
    auditToSharedFunctor.map structuralAndRaySafeToRaySafeHom =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck) := by
  simp [auditToSharedFunctor, structuralAndRaySafeToRaySafeHom, auditToSharedPrefunctor,
    auditEdgeToSharedHom]
  rfl

/-- Functor image of direct ray-load-bearing → structural generator. -/
theorem auditToShared_map_rayLoadToStructural :
    auditToSharedFunctor.map rayLoadToStructuralHom =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck) := by
  simp [auditToSharedFunctor, rayLoadToStructuralHom, auditToSharedPrefunctor, auditEdgeToSharedHom]
  rfl

/-- Functor image of direct ray-load-bearing → ray-safe generator. -/
theorem auditToShared_map_rayLoadToRaySafe :
    auditToSharedFunctor.map rayLoadToRaySafeHom =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck) := by
  simp [auditToSharedFunctor, rayLoadToRaySafeHom, auditToSharedPrefunctor, auditEdgeToSharedHom]
  rfl

/-- Composite path in the audit category remains identity on momentum under the bridge. -/
theorem auditToShared_map_structuralAndRaySafeToStructuralViaRay :
    auditToSharedFunctor.map structuralAndRaySafeToStructuralViaRayPath =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck) := by
  simp [auditToSharedFunctor, structuralAndRaySafeToStructuralViaRayPath,
    structuralAndRaySafeToRayLoadHom, auditToSharedPrefunctor, auditEdgeToSharedHom]
  change
    (Quiver.Path.nil.comp
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck)) =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck)
  exact
    (Quiver.Path.comp_nil
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck))

/-- Composite path to ray-safe via ray-load-bearing remains identity under the bridge. -/
theorem auditToShared_map_structuralAndRaySafeToRaySafeViaRayLoad :
    auditToSharedFunctor.map structuralAndRaySafeToRaySafeViaRayLoadPath =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck) := by
  simp [auditToSharedFunctor, structuralAndRaySafeToRaySafeViaRayLoadPath,
    structuralAndRaySafeToRayLoadHom, rayLoadToRaySafeHom, auditToSharedPrefunctor,
    auditEdgeToSharedHom]
  change
    (Quiver.Path.nil.comp
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck)) =
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck)
  exact
    (Quiver.Path.comp_nil
      (Quiver.Path.nil : Quiver.Path SharedObj.momentumBottleneck SharedObj.momentumBottleneck))

/-- Under the bridge, both structural routes coincide (direct vs via ray-load-bearing). -/
theorem auditToShared_map_structural_routes_coincide :
    auditToSharedFunctor.map structuralAndRaySafeToStructuralHom =
      auditToSharedFunctor.map structuralAndRaySafeToStructuralViaRayPath := by
  rw [auditToShared_map_structuralAndRaySafeToStructural,
    auditToShared_map_structuralAndRaySafeToStructuralViaRay]

/-- Under the bridge, both ray-safe routes coincide (direct vs via ray-load-bearing). -/
theorem auditToShared_map_raySafe_routes_coincide :
    auditToSharedFunctor.map structuralAndRaySafeToRaySafeHom =
      auditToSharedFunctor.map structuralAndRaySafeToRaySafeViaRayLoadPath := by
  rw [auditToShared_map_structuralAndRaySafeToRaySafe,
    auditToShared_map_structuralAndRaySafeToRaySafeViaRayLoad]

/-- Compact certificate for the current SA-G4 lane:
    it is structurally load-bearing in audit semantics and its structural route
    images coincide under the shared clock/momentum bridge. -/
theorem currentSAG4Lane_structural_bridge_certificate :
    AuditObjSemantics .structuralLoadBearing currentSAG4Lane ∧
      auditToSharedFunctor.map structuralAndRaySafeToStructuralHom =
        auditToSharedFunctor.map structuralAndRaySafeToStructuralViaRayPath := by
  refine ⟨?_, ?_⟩
  exact currentSAG4Lane_in_structuralLoadBearing_via_path
  exact auditToShared_map_structural_routes_coincide

/-- Companion certificate for the ray-safety branch of the current SA-G4 lane. -/
theorem currentSAG4Lane_raySafe_bridge_certificate :
    AuditObjSemantics .rayResonanceSafe currentSAG4Lane ∧
      auditToSharedFunctor.map structuralAndRaySafeToRaySafeHom =
        auditToSharedFunctor.map structuralAndRaySafeToRaySafeViaRayLoadPath := by
  refine ⟨?_, ?_⟩
  exact currentSAG4Lane_in_structuralAndRaySafe.2
  exact auditToShared_map_raySafe_routes_coincide

def superpositionToSharedClockFunctorSummary : String :=
  "Constructed functor auditToSharedFunctor : SGAuditCat ⥤ SharedClockMomentumCat " ++
  "with explicit object/edge map; validated generator images, composed-path images, " ++
  "and route-coincidence lemmas."

end

end NavierStokes.SuperpositionGalerkinPattern
