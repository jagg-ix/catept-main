import CATEPTMain.Integration.PhysicalUVConvergenceCertificate

/-!
# UV Certificate Failure Modes (T-FF Phase 18)

Closes the structural T-FF plan by enumerating the canonical
ways the four named physics inputs of `PhysicalEntropicModel`
can fail and producing a kernel-only lookup function pinning
each failure mode to the structural field of the bundled
record it would invalidate.

This is a **structural audit**: we encode the five failure
modes as constructors of a finite enumeration `UVCertificateFailureMode`
and define a lookup `affectedField` that returns one of the
five named field tags `cutoff` / `coercivity` / `spectral` /
`exponentialTailBound` / `tendsToContinuum` for each.

The five modes (taken from the user's plan):

* `actionMerelyNonneg` — `S_I[Φ] ≥ 0` holds but coercivity
  `S_I[Φ] ≥ C·‖Φ‖²_UV` with positive `C` fails: invalidates
  the `coercivity` field.
* `noSpectralGap` — Stokes spectrum has no positive growth
  exponent (e.g. accumulation at zero): invalidates the
  `spectral` field.
* `highModeDensityBeatsDamping` — high-mode density of states
  outpaces the cutoff damping, so the residual fails the
  exponential tail: invalidates the `exponentialTailBound`
  field.
* `oscillatoryPhaseNonAbsolute` — partition uses an oscillatory
  phase factor without absolute convergence, so the cutoff
  family is not well-defined as a real-valued sequence:
  invalidates the `cutoff` field.
* `cutoffFamilyNonExhaustive` — cutoff family is not monotone
  or not exhaustive, so the partition does not converge to
  the continuum value: invalidates the `tendsToContinuum`
  field.

Exposed items:

* `UVCertificateFailureMode` — finite enumeration of the five
  cases, with `Repr` and `DecidableEq` derivations.
* `PhysicalEntropicModelField` — finite enumeration of the
  five named fields of `PhysicalEntropicModel`.
* `affectedField` — total lookup function pinning each
  failure mode to the field it invalidates.
* Five kernel-only `affectedField_*` lookup theorems.
* `failureModes` — the explicit five-element list.
* `affectedField_actionMerelyNonneg_eq_coercivity`,
  `affectedField_noSpectralGap_eq_spectral`,
  `affectedField_highModeDensityBeatsDamping_eq_exponentialTailBound`,
  `affectedField_oscillatoryPhaseNonAbsolute_eq_cutoff`,
  `affectedField_cutoffFamilyNonExhaustive_eq_tendsToContinuum`.

Honest scope: this is a **finite enumeration audit** at the
structural level. It does not produce counterexample models,
nor does it prove that every failure of the certificate falls
into exactly one of these five buckets. The semantic content
is: each named failure mode is paired by name with the
structural field it would invalidate.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.UVCertificateFailureModes

/-- The five canonical failure modes for the four named
physics inputs of `PhysicalEntropicModel`. -/
inductive UVCertificateFailureMode
  /-- `S_I[Φ] ≥ 0` holds but coercivity with positive `C` fails. -/
  | actionMerelyNonneg
  /-- Stokes spectrum has no positive growth exponent. -/
  | noSpectralGap
  /-- High-mode density of states beats the cutoff damping. -/
  | highModeDensityBeatsDamping
  /-- Oscillatory phase used without absolute convergence. -/
  | oscillatoryPhaseNonAbsolute
  /-- Cutoff family is not monotone or not exhaustive. -/
  | cutoffFamilyNonExhaustive
  deriving Repr, DecidableEq

/-- The five named structural fields of `PhysicalEntropicModel`. -/
inductive PhysicalEntropicModelField
  | cutoff
  | coercivity
  | spectral
  | exponentialTailBound
  | tendsToContinuum
  deriving Repr, DecidableEq

namespace UVCertificateFailureMode

/-- Lookup function: each failure mode is paired by name with
the structural field of `PhysicalEntropicModel` it
invalidates. -/
def affectedField :
    UVCertificateFailureMode → PhysicalEntropicModelField
  | .actionMerelyNonneg          => .coercivity
  | .noSpectralGap               => .spectral
  | .highModeDensityBeatsDamping => .exponentialTailBound
  | .oscillatoryPhaseNonAbsolute => .cutoff
  | .cutoffFamilyNonExhaustive   => .tendsToContinuum

/-- Explicit list of all five failure modes. -/
def failureModes : List UVCertificateFailureMode :=
  [ .actionMerelyNonneg
  , .noSpectralGap
  , .highModeDensityBeatsDamping
  , .oscillatoryPhaseNonAbsolute
  , .cutoffFamilyNonExhaustive ]

end UVCertificateFailureMode

open UVCertificateFailureMode

/-- `actionMerelyNonneg` invalidates the `coercivity` field. -/
theorem affectedField_actionMerelyNonneg_eq_coercivity :
    affectedField .actionMerelyNonneg
      = PhysicalEntropicModelField.coercivity := rfl

/-- `noSpectralGap` invalidates the `spectral` field. -/
theorem affectedField_noSpectralGap_eq_spectral :
    affectedField .noSpectralGap
      = PhysicalEntropicModelField.spectral := rfl

/-- `highModeDensityBeatsDamping` invalidates the
`exponentialTailBound` field. -/
theorem affectedField_highModeDensityBeatsDamping_eq_exponentialTailBound :
    affectedField .highModeDensityBeatsDamping
      = PhysicalEntropicModelField.exponentialTailBound := rfl

/-- `oscillatoryPhaseNonAbsolute` invalidates the `cutoff`
field. -/
theorem affectedField_oscillatoryPhaseNonAbsolute_eq_cutoff :
    affectedField .oscillatoryPhaseNonAbsolute
      = PhysicalEntropicModelField.cutoff := rfl

/-- `cutoffFamilyNonExhaustive` invalidates the
`tendsToContinuum` field. -/
theorem affectedField_cutoffFamilyNonExhaustive_eq_tendsToContinuum :
    affectedField .cutoffFamilyNonExhaustive
      = PhysicalEntropicModelField.tendsToContinuum := rfl

/-- The explicit list of failure modes has length five. -/
theorem failureModes_length : failureModes.length = 5 := rfl

end CATEPTMain.Integration.UVCertificateFailureModes
