import NavierStokesClean.CATEPT.CurvedSpacetimePathIntegral
import NavierStokesClean.AFPIsabellePilot.NoFTLPrelude

/-!
# Curved Spacetime AFP Observer Constraint Bridge

This module isolates AFP observer semantics used by curved MTPI integrations.

- AFP No-FTL objects are used to index observer observables.
- AFP contributes admissibility predicates and observer filters.
- No MTPI carrier identification is performed here.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT

noncomputable section

open AFPIsabellePilot

/-- AFP observers act on observables rather than replacing the MTPI carrier. -/
structure AFPObserverLayer (α : Type*) [MeasurableSpace α] where
  admissible : NoFTLObj -> Prop
  observerObservable : NoFTLObj -> α -> ℂ

namespace AFPObserverLayer

variable {α : Type*} [MeasurableSpace α]

/-- Convenience constructor for an AFP observer layer from an admissibility
predicate and an observer-indexed observable family. -/
def mkSimple
    (admissible : NoFTLObj -> Prop)
    (observerObservable : NoFTLObj -> α -> ℂ) : AFPObserverLayer α where
  admissible := admissible
  observerObservable := observerObservable

/-- Default observer layer with no admissibility restriction. -/
def unrestricted (observerObservable : NoFTLObj -> α -> ℂ) : AFPObserverLayer α :=
  mkSimple (fun _ => True) observerObservable

end AFPObserverLayer

end

end NavierStokesClean.CATEPT
