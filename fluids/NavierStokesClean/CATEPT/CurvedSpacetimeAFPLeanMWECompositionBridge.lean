import NavierStokesClean.CATEPT.CurvedSpacetimeAFPLeanMWEBridge
import NavierStokesClean.CATEPT.MTPIEinsteinDerivationBridge
import NavierStokesClean.CATEPT.CurvedMaxwellEinsteinDerivation

/-!
# Curved Spacetime AFP+Lean-MWE Composition Bridge

This is a theorem-only composition layer.

- The curved MTPI core remains in `CurvedSpacetimePathIntegral`.
- `CurvedSpacetimeAFPLeanMWEBridge` provides lean-mwe source/observable lifting and
  AFP observer filtering over the same measurable carrier.
- Existing derivation bridges remain unchanged and are consumed here:
  `MTPIEinsteinDerivationBridge` and `CurvedMaxwellEinsteinDerivation`.

No new carrier identifications or global instances are introduced.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open AFPIsabellePilot

namespace CurvedSpacetimeAFPLeanMWEBridge

variable {α : Type*} [MeasurableSpace α]

/-- The theorem-only composition output: observer-filter reductions from the
AFP+lean-mwe bridge, and EFE contract derivability through both existing
derivation routes. -/
structure CompositionOutputs
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ)
    (C : ComplexEFEContract α) where
  observerFilteredElectricReduced :
    B.observerFilteredElectricExpectation observer sys stτ τ =
      B.curvedModel.normalizedExpectation
        (B.observerFilteredElectricObservable observer sys stτ τ)
  observerFilteredMagneticReduced :
    B.observerFilteredMagneticExpectation observer sys stτ τ =
      B.curvedModel.normalizedExpectation
        (B.observerFilteredMagneticObservable observer sys stτ τ)
  mtpiDerivedEFE : C.HoldsPointwise
  maxwellDerivedEFE : C.HoldsPointwise

/-- End-to-end theorem-only composition:

1. AFP observer-filtered expectations reduce to normalized expectations when the
   lean-mwe source vanishes at the sampled entropic time.
2. The same target complex-EFE contract can be obtained from the MTPI
   derivation certificate route.
3. The same target complex-EFE contract can be obtained from the existing
   curved-Maxwell->Einstein bridge route.

This theorem intentionally composes roles rather than identifying carriers. -/
theorem compose_with_existing_derivation_bridges
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ)
    (hJ : B.leanMWE.generatingSource sys stτ τ = fun _ => (0 : ℂ))
    (C : ComplexEFEContract α)
    (A : B.curvedModel.MTPIDerivationCertificate C)
    (M : PhysLeanCurvedMaxwellCertificate)
    (L : ElectrodynamicsToEinsteinLift M C) :
    CompositionOutputs B observer sys stτ τ C := by
  refine
    { observerFilteredElectricReduced := ?_
      observerFilteredMagneticReduced := ?_
      mtpiDerivedEFE := ?_
      maxwellDerivedEFE := ?_ }
  · exact B.observerFilteredElectricExpectation_zero_source observer sys stτ τ hJ
  · exact B.observerFilteredMagneticExpectation_zero_source observer sys stτ τ hJ
  · exact A.derive_holdsPointwise
  · exact derive_complex_efe_contract_from_bridge M C L

/-- Convenience specialization of `compose_with_existing_derivation_bridges`
for the observation-only constructor, where the lifted source is definitionally
zero and no explicit `hJ` argument is required from callers. -/
theorem compose_observationOnly_with_existing_derivation_bridges
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ)
    (C : ComplexEFEContract α)
    (A : CurvedMeasurePathIntegralModel.MTPIDerivationCertificate
      ((observationOnlyOfFieldLiftAtPoint curvedModel lift x afp).curvedModel) C)
    (M : PhysLeanCurvedMaxwellCertificate)
    (L : ElectrodynamicsToEinsteinLift M C) :
    CompositionOutputs
      (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
      observer sys stτ τ C := by
  simpa using
    compose_with_existing_derivation_bridges
      (B := observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
      (observer := observer)
      (sys := sys)
      (stτ := stτ)
      (τ := τ)
      (hJ := rfl)
      (C := C)
      (A := A)
      (M := M)
      (L := L)

end CurvedSpacetimeAFPLeanMWEBridge

end

end NavierStokesClean.CATEPT
