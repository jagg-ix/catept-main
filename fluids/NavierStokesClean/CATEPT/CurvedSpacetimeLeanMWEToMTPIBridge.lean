import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.CATEPT.MaxwellWaveEntropicTimePublic

/-!
# Curved Spacetime Lean-MWE -> MTPI Bridge

This module isolates the lean-mwe-to-MTPI side of the bridge.

- `lean-mwe` contributes sampled source/observable families indexed by Maxwell
  systems and entropic time.
- No AFP observer semantics are introduced here.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

/-- A concrete lift from sampled `lean-mwe` field values into MTPI source and
observable functions over an existing measurable carrier `α`. -/
structure LeanMWEFieldLift (α : Type*) [MeasurableSpace α] where
  sourceOfFields : MaxwellWave.Vec3 -> MaxwellWave.Vec3 -> α -> ℂ
  electricOfField : MaxwellWave.Vec3 -> α -> ℂ
  magneticOfField : MaxwellWave.Vec3 -> α -> ℂ

namespace LeanMWEFieldLift

variable {α : Type*} [MeasurableSpace α]

/-- Canonical concrete lift with zero source and zero observables. Useful as a
stable baseline for bridge wiring and theorem-level reductions. -/
def zero : LeanMWEFieldLift α where
  sourceOfFields := fun _E _B _ => 0
  electricOfField := fun _E _ => 0
  magneticOfField := fun _B _ => 0

/-- Concrete nonzero lift that uses selected electric/magnetic components at
the sampled spacetime point. -/
def componentLift (eComp bComp : Fin 3) : LeanMWEFieldLift α where
  sourceOfFields := fun E B _ => ((E eComp + B bComp : ℝ) : ℂ)
  electricOfField := fun E _ => (E eComp : ℂ)
  magneticOfField := fun B _ => (B bComp : ℂ)

end LeanMWEFieldLift

/-- The `lean-mwe` side contributes source and observable families over an
existing measurable carrier `α`. -/
structure LeanMWEGeneratingFamily (α : Type*) [MeasurableSpace α] where
  generatingSource :
    {m : MaxwellWave.Medium} ->
      MaxwellWave.SourceFreeMaxwell m ->
      MaxwellWaveEntropicTimePublic.EntropicSpaceTime ->
      ℝ -> α -> ℂ
  electricObservable :
    {m : MaxwellWave.Medium} ->
      MaxwellWave.SourceFreeMaxwell m ->
      MaxwellWaveEntropicTimePublic.EntropicSpaceTime ->
      ℝ -> α -> ℂ
  magneticObservable :
    {m : MaxwellWave.Medium} ->
      MaxwellWave.SourceFreeMaxwell m ->
      MaxwellWaveEntropicTimePublic.EntropicSpaceTime ->
      ℝ -> α -> ℂ

namespace LeanMWEGeneratingFamily

variable {α : Type*} [MeasurableSpace α]

/-- Build a concrete `lean-mwe` generating family by sampling the electric and
magnetic fields at a fixed spatial point and then applying a user-provided
field-value lift into MTPI source/observable functions. -/
def ofFieldLiftAtPoint
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3) : LeanMWEGeneratingFamily α where
  generatingSource := fun sys stτ τ =>
    lift.sourceOfFields
      (sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x)
      (sys.B (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x)
  electricObservable := fun sys stτ τ =>
    lift.electricOfField
      (sys.E (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x)
  magneticObservable := fun sys stτ τ =>
    lift.magneticOfField
      (sys.B (MaxwellWaveEntropicTimePublic.geometricTime stτ τ) x)

/-- Zero-source family at a fixed spatial point for observation-first use
cases where `lean-mwe` contributes observables but no additional MTPI source. -/
def zeroSourceOfFieldLiftAtPoint
    (lift : LeanMWEFieldLift α)
    (x : MaxwellWave.Vec3) : LeanMWEGeneratingFamily α :=
  { (ofFieldLiftAtPoint lift x) with
      generatingSource := fun _sys _stτ _τ _ => 0 }

end LeanMWEGeneratingFamily

end

end NavierStokesClean.CATEPT
