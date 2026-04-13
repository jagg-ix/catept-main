import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.CATEPT.CurvedSpacetimeLeanMWEToMTPIBridge
import NavierStokesClean.CATEPT.CurvedSpacetimeAFPObserverConstraintBridge

/-!
# Curved Spacetime + AFP + Lean-MWE Bridge

This module begins the three-way integration in a compile-safe, theorem-level way.

- `CurvedSpacetimePathIntegral` remains the measure-theoretic semantic layer.
- `lean-mwe` side is imported from
  `CurvedSpacetimeLeanMWEToMTPIBridge`.
- AFP No-FTL observer side is imported from
  `CurvedSpacetimeAFPObserverConstraintBridge`.

The first pass intentionally avoids forcing AFP carriers into the MTPI integration
domain. Instead, AFP observers act on observables over an existing measurable
carrier `α`.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open AFPIsabellePilot

/-- First-pass composition layer joining curved MTPI semantics, lean-mwe source
families, and AFP observer-indexed observables. -/
structure CurvedSpacetimeAFPLeanMWEBridge (α : Type*) [MeasurableSpace α] where
  curvedModel : CurvedMeasurePathIntegralModel α
  leanMWE : LeanMWEGeneratingFamily α
  afp : AFPObserverLayer α

namespace CurvedSpacetimeAFPLeanMWEBridge

variable {α : Type*} [MeasurableSpace α]

/-- Concrete bridge constructor from a curved MTPI model, a sampled `lean-mwe`
field lift, and an AFP observer layer. -/
def ofFieldLiftAtPoint
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α) : CurvedSpacetimeAFPLeanMWEBridge α where
  curvedModel := curvedModel
  leanMWE := LeanMWEGeneratingFamily.ofFieldLiftAtPoint lift x
  afp := afp

/-- Observation-first concrete bridge constructor where `lean-mwe` contributes
only sampled observables and the MTPI source remains zero. -/
def observationOnlyOfFieldLiftAtPoint
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α) : CurvedSpacetimeAFPLeanMWEBridge α where
  curvedModel := curvedModel
  leanMWE := LeanMWEGeneratingFamily.zeroSourceOfFieldLiftAtPoint lift x
  afp := afp

/-- Pointwise product of an AFP observer observable with any observable family. -/
def observerWeightedObservable
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    (observer : NoFTLObj) (O : α -> ℂ) : α -> ℂ :=
  fun x => B.afp.observerObservable observer x * O x

/-- `lean-mwe` source-coupled partition interpreted in the curved MTPI model. -/
def leanMWESourceCoupledPartition
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : ℂ :=
  B.curvedModel.sourceCoupledPartition (B.leanMWE.generatingSource sys stτ τ)

/-- Curved expectation of the lifted `lean-mwe` electric observable. -/
def leanMWEElectricExpectation
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : ℂ :=
  B.curvedModel.normalizedExpectation (B.leanMWE.electricObservable sys stτ τ)

/-- Curved expectation of the lifted `lean-mwe` magnetic observable. -/
def leanMWEMagneticExpectation
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : ℂ :=
  B.curvedModel.normalizedExpectation (B.leanMWE.magneticObservable sys stτ τ)

/-- AFP observer expectation over its own observable family. -/
def afpObserverExpectation
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    (observer : NoFTLObj) : ℂ :=
  B.curvedModel.normalizedExpectation (B.afp.observerObservable observer)

/-- AFP observer filtering applied to the lifted `lean-mwe` electric observable. -/
def observerFilteredElectricObservable
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : α -> ℂ :=
  B.observerWeightedObservable observer (B.leanMWE.electricObservable sys stτ τ)

/-- AFP observer filtering applied to the lifted `lean-mwe` magnetic observable. -/
def observerFilteredMagneticObservable
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : α -> ℂ :=
  B.observerWeightedObservable observer (B.leanMWE.magneticObservable sys stτ τ)

/-- Source-coupled expectation of the observer-filtered electric observable. -/
def observerFilteredElectricExpectation
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : ℂ :=
  B.curvedModel.sourceCoupledExpectation
    (B.leanMWE.generatingSource sys stτ τ)
    (B.observerFilteredElectricObservable observer sys stτ τ)

/-- Source-coupled expectation of the observer-filtered magnetic observable. -/
def observerFilteredMagneticExpectation
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) : ℂ :=
  B.curvedModel.sourceCoupledExpectation
    (B.leanMWE.generatingSource sys stτ τ)
    (B.observerFilteredMagneticObservable observer sys stτ τ)

/-- If the lifted `lean-mwe` source is zero, the curved partition reduces to the
ordinary partition functional. -/
theorem leanMWESourceCoupledPartition_zero
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ)
    (hJ : B.leanMWE.generatingSource sys stτ τ = fun _ => (0 : ℂ)) :
    B.leanMWESourceCoupledPartition sys stτ τ = B.curvedModel.partition := by
  unfold leanMWESourceCoupledPartition
  simpa [hJ] using B.curvedModel.sourceCoupledPartition_zero

/-- Zero-source reduction for observer-filtered electric expectations. -/
theorem observerFilteredElectricExpectation_zero_source
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ)
    (hJ : B.leanMWE.generatingSource sys stτ τ = fun _ => (0 : ℂ)) :
    B.observerFilteredElectricExpectation observer sys stτ τ =
      B.curvedModel.normalizedExpectation
        (B.observerFilteredElectricObservable observer sys stτ τ) := by
  unfold observerFilteredElectricExpectation
  simpa [hJ] using
    B.curvedModel.sourceCoupledExpectation_zero
      (B.observerFilteredElectricObservable observer sys stτ τ)

/-- Zero-source reduction for observer-filtered magnetic expectations. -/
theorem observerFilteredMagneticExpectation_zero_source
    (B : CurvedSpacetimeAFPLeanMWEBridge α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ)
    (hJ : B.leanMWE.generatingSource sys stτ τ = fun _ => (0 : ℂ)) :
    B.observerFilteredMagneticExpectation observer sys stτ τ =
      B.curvedModel.normalizedExpectation
        (B.observerFilteredMagneticObservable observer sys stτ τ) := by
  unfold observerFilteredMagneticExpectation
  simpa [hJ] using
    B.curvedModel.sourceCoupledExpectation_zero
      (B.observerFilteredMagneticObservable observer sys stτ τ)

/-- Re-export the public entropic-time Gauss law in the bridge namespace so
downstream MTPI/observer lemmas can reference the Maxwell theorem surface from
one place. -/
theorem leanMWE_gauss_tau
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) :
    MaxwellWave.divergence
      (sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ)) x = 0 := by
  simpa using MaxwellWaveEntropicTimePublic.gauss_simplified_tau sys stτ τ x

/-- Re-export the public entropic-time Faraday law in the bridge namespace. -/
theorem leanMWE_faraday_tau
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) (x : MaxwellWave.Vec3) (j : Fin 3) :
    MaxwellWave.curl
      (sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ)) x j =
      -(MaxwellWave.timeDerivComp sys.B j
        (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) := by
  simpa using MaxwellWaveEntropicTimePublic.faraday_tau sys stτ τ x j

/-- For observation-only bridges, the source-coupled partition collapses to the
base curved partition. -/
theorem observationOnly_partition_eq_partition
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp).leanMWESourceCoupledPartition sys stτ τ =
      curvedModel.partition := by
  apply leanMWESourceCoupledPartition_zero
  rfl

/-- For observation-only bridges, AFP-filtered electric expectations reduce to
ordinary curved normalized expectations of the filtered observable. -/
theorem observationOnly_observerFilteredElectricExpectation
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredElectricExpectation
      (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (CurvedSpacetimeAFPLeanMWEBridge.observerFilteredElectricObservable
          (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
          observer sys stτ τ) := by
  apply observerFilteredElectricExpectation_zero_source
  rfl

/-- For observation-only bridges, AFP-filtered magnetic expectations reduce to
ordinary curved normalized expectations of the filtered observable. -/
theorem observationOnly_observerFilteredMagneticExpectation
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredMagneticExpectation
      (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (CurvedSpacetimeAFPLeanMWEBridge.observerFilteredMagneticObservable
          (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
          observer sys stτ τ) := by
  apply observerFilteredMagneticExpectation_zero_source
  rfl

/-- Observation-only sampled electric expectations stay source-independent even
after AFP observer weighting. -/
theorem observationOnly_observerFilteredElectricExpectation_eq_weighted
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredElectricExpectation
      (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (fun y => afp.observerObservable observer y *
          lift.electricOfField
            (sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) y) := by
  rw [observationOnly_observerFilteredElectricExpectation]
  rfl

/-- Observation-only sampled magnetic expectations stay source-independent even
after AFP observer weighting. -/
theorem observationOnly_observerFilteredMagneticExpectation_eq_weighted
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredMagneticExpectation
      (observationOnlyOfFieldLiftAtPoint curvedModel lift x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (fun y => afp.observerObservable observer y *
          lift.magneticOfField
            (sys.B (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) y) := by
  rw [observationOnly_observerFilteredMagneticExpectation]
  rfl

/-- Specialization of the observation-only bridge to the canonical zero field
lift keeps the partition at the base curved partition. -/
theorem observationOnly_zeroLift_partition_eq_partition
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.leanMWESourceCoupledPartition
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.zero : LeanMWEFieldLift α) x afp)
      sys stτ τ = curvedModel.partition := by
  simpa using
    observationOnly_partition_eq_partition curvedModel
      (LeanMWEFieldLift.zero : LeanMWEFieldLift α) x afp sys stτ τ

/-- Observation-only expectation formula specialized to a concrete nonzero
component lift. -/
theorem observationOnly_componentLift_observerFilteredElectricExpectation
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (eComp bComp : Fin 3)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredElectricExpectation
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (fun y => afp.observerObservable observer y *
          (((sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) eComp : ℝ) : ℂ)) := by
  simpa [LeanMWEFieldLift.componentLift]
    using observationOnly_observerFilteredElectricExpectation_eq_weighted
      curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp)
      x afp observer sys stτ τ

/-- Observation-only magnetic expectation formula specialized to a concrete
nonzero component lift. -/
theorem observationOnly_componentLift_observerFilteredMagneticExpectation
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (eComp bComp : Fin 3)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredMagneticExpectation
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (fun y => afp.observerObservable observer y *
          (((sys.B (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) bComp : ℝ) : ℂ)) := by
  simpa [LeanMWEFieldLift.componentLift]
    using observationOnly_observerFilteredMagneticExpectation_eq_weighted
      curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp)
      x afp observer sys stτ τ

/-- In the observation-only constructor, even a concrete nonzero component
lift contributes zero MTPI source by construction. -/
theorem observationOnly_componentLift_generatingSource_eq_zero
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (eComp bComp : Fin 3)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    (observationOnlyOfFieldLiftAtPoint
      curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp).leanMWE.generatingSource
        sys stτ τ = fun _ => (0 : ℂ) := by
  rfl

/-- Observation-only partition reduction specialized to a concrete nonzero
component lift. -/
theorem observationOnly_componentLift_partition_eq_partition
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (eComp bComp : Fin 3)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.leanMWESourceCoupledPartition
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp)
      sys stτ τ =
      curvedModel.partition := by
  simpa using
    observationOnly_partition_eq_partition curvedModel
      (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp sys stτ τ

/-- Convenience bundle collecting the main observation-only reductions for a
concrete component lift instance. -/
theorem observationOnly_componentLift_reduction_bundle
    (curvedModel : CurvedMeasurePathIntegralModel α)
    (eComp bComp : Fin 3)
    (x : MaxwellWave.Vec3)
    (afp : AFPObserverLayer α)
    {m : MaxwellWave.Medium}
    (observer : NoFTLObj)
    (sys : MaxwellWave.SourceFreeMaxwell m)
    (stτ : MaxwellWaveEntropicTimePublic.EntropicSpaceTime)
    (τ : ℝ) :
    CurvedSpacetimeAFPLeanMWEBridge.leanMWESourceCoupledPartition
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp)
      sys stτ τ = curvedModel.partition ∧
    ((observationOnlyOfFieldLiftAtPoint
      curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp).leanMWE.generatingSource
        sys stτ τ = (fun _ => (0 : ℂ))) ∧
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredElectricExpectation
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (fun y => afp.observerObservable observer y *
          (((sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) eComp : ℝ) : ℂ)) ∧
    CurvedSpacetimeAFPLeanMWEBridge.observerFilteredMagneticExpectation
      (observationOnlyOfFieldLiftAtPoint
        curvedModel (LeanMWEFieldLift.componentLift (α := α) eComp bComp) x afp)
      observer sys stτ τ =
      curvedModel.normalizedExpectation
        (fun y => afp.observerObservable observer y *
          (((sys.B (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x) bComp : ℝ) : ℂ)) := by
  refine ⟨?_, ?_⟩
  · exact observationOnly_componentLift_partition_eq_partition
      curvedModel eComp bComp x afp sys stτ τ
  · refine ⟨?_, ?_⟩
    · exact observationOnly_componentLift_generatingSource_eq_zero
        curvedModel eComp bComp x afp sys stτ τ
    · refine ⟨?_, ?_⟩
      · exact observationOnly_componentLift_observerFilteredElectricExpectation
          curvedModel eComp bComp x afp observer sys stτ τ
      · exact observationOnly_componentLift_observerFilteredMagneticExpectation
          curvedModel eComp bComp x afp observer sys stτ τ

end CurvedSpacetimeAFPLeanMWEBridge

end

end NavierStokesClean.CATEPT
