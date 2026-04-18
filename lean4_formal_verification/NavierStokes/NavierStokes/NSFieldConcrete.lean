import Mathlib.Data.Real.Basic

/-!
# Stage 214A — NSFieldConcrete: Concrete NSField Carrier

Replaces `axiom NSField : Type` (and its three immediately provable companions
`nsZero`, `nsAdd`, `nsSmul`) with a concrete definition:

  `NSField := Nat → Real × Real`

This is the same underlying type as `CoeffInftyR` in `NSGalerkinCompactness`.
Because both are `abbrev` of `Nat → Real × Real`, they are definitionally equal,
which makes `canon_ns_interp := { vel := id, pres := id }` type-correct without
any coercions (Stage 214A, `NSGalerkinWeakToNSBridge`).

## Why this file exists separately

`AxiomaticEstimates.lean` is upstream of `NSGalerkinCompactness.lean` in the
import graph, so it cannot import `CoeffInftyR` directly.  This shim file imports
only `Mathlib.Data.Real.Basic` (no NavierStokes modules) and provides the carrier
before `AxiomaticEstimates` runs.

## Net counts (Stage 214A, this file)

  - New defs:   3  (nsZero, nsAdd, nsSmul — all noncomputable over Real)
  - New axioms: 0
  - Axioms retired (in AxiomaticEstimates.lean):
      NSField, NSField_nonempty, nsZero, nsAdd, nsSmul  (−5)
  - sorry:      0
  - warnings:   0
-/

namespace NavierStokes.Millennium

/-- Concrete carrier: countably-many real-valued mode pairs.

    Definitionally equal to `CoeffInftyR = Nat → Real × Real` from
    `NSGalerkinCompactness.lean` (both are `abbrev` of the same type). -/
abbrev NSField : Type := Nat → Real × Real

noncomputable instance : Nonempty NSField := ⟨fun _ => (0, 0)⟩

/-- Additive identity: all modes are zero. -/
noncomputable def nsZero : NSField := fun _ => (0, 0)

/-- Pointwise addition of mode pairs. -/
noncomputable def nsAdd (v w : NSField) : NSField :=
  fun n => ((v n).1 + (w n).1, (v n).2 + (w n).2)

/-- Pointwise scalar multiplication; `r : Rat` is cast to `Real` via `Rat.cast`. -/
noncomputable def nsSmul (r : Rat) (v : NSField) : NSField :=
  fun n => (Rat.cast r * (v n).1, Rat.cast r * (v n).2)

end NavierStokes.Millennium
