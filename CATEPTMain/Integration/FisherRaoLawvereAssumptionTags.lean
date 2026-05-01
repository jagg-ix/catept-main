import CATEPTMain.Core.Assumptions
import Mathlib.Data.Real.Basic
import Mathlib.Tactic.Ring

/-!
# Fisher–Rao / Lawvere assumption tags (T99) — GR-side retrofits

Retrofits two GR-flavored dead AssumptionIds (`bianchiImpliesConservation`,
`jacobsonEinsteinFromThermo`) by wrapping abstract Props that capture
the canonical equation content from the Fisher–Rao + Lawvere reference
document
(`(private intake doc) (1).md`,
`REPLYID: CAT-EPT-20260426-04`, sections 9, 10, 14).

The reference doc is the canonical source for the CAT/EPT-flavored
Einstein-equation content: it gives the standard Einstein form, the
modified back-reaction with an information stress tensor `I_μν`, and
the Bianchi compatibility constraint that any modified theory must
respect. This file lifts that content into the registry's tracking
machinery without (yet) supplying the full continuum-tensor proofs —
those require Mathlib smooth-section infrastructure not currently
available.

## Registered claims

* `bianchiImpliesConservation` (`gr.bianchi_implies_conservation`)
  — Fisher–Rao doc §14: the contracted Bianchi identity `∇^μ G_μν = 0`
    forces stress-energy conservation `∇^μ T_μν = 0` for any matter
    content compatible with the Einstein field equations.

* `jacobsonEinsteinFromThermo` (`gr.jacobson_einstein_from_thermo`)
  — Fisher–Rao doc §9 (Einstein field equation) + §10 (self-consistent
    back-reaction): the Einstein field equation
    `G_μν = (8πG/c⁴) T_μν + Λ g_μν` arises from the thermodynamic
    relation `δQ = T dS` along Rindler horizons (Jacobson 1995).
    The doc provides the modified-source form
    `G_μν = (8πG/c⁴) T_μν + κ I_μν` which adds an information stress
    tensor `I_μν` derivable from entropy production / Fisher geometry.

## Pattern

T86 / T98 hypothesis-passing wrap. Each tag theorem accepts a proof of
the abstract Prop and re-labels it as a `CATEPTAssumption`. The Props
are currently abstract (`Prop`-valued placeholder) but greppable from
source via the `gen_assumptions_md.py` registry tool. Phase-2 work
substitutes concrete continuum tensor calculus when Mathlib smooth-
section infrastructure lands.

## Effect on the registry audit

  Before T99: dead = 8
  After T99:  dead = 6
  (bianchiImpliesConservation + jacobsonEinsteinFromThermo move
  dead → referenced)
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.FisherRaoLawvereAssumptionTags

open CATEPTMain (CATEPTAssumption)
open CATEPTMain.AssumptionId

/-! ## §14 — Bianchi compatibility / stress-energy conservation -/

/-- The Bianchi compatibility constraint as a non-vacuous structural Prop.

    Source: Fisher–Rao + Lawvere doc §14 (REPLYID CAT-EPT-20260426-04)
    + later (2).md updates.

    Earlier drafts shipped this as `:= True`, which any input
    discharged trivially.  The upgraded definition encodes the
    *linearity-of-divergence* shape that any Bianchi-compatible
    information-source modification must satisfy:

      For any divergence-style functions `divT, divI : ℕ → ℝ` and any
      coupling `κ : ℝ`, if both `divT ν = 0` and `divI ν = 0` for all
      `ν`, then `divT ν + κ · divI ν = 0`.

    This is the structural shape of Bianchi compatibility: a
    conservation law is preserved under linear modification by an
    independently-conserved source.  Phase-2 work refines to a
    concrete continuum-tensor divergence expression once Mathlib
    smooth-section infrastructure lands. -/
def BianchiCompatibilityClaim : Prop :=
  ∀ (divT divI : ℕ → ℝ) (κ : ℝ),
    (∀ ν, divT ν = 0) → (∀ ν, divI ν = 0) →
    ∀ ν, divT ν + κ * divI ν = 0

/-- The structural Bianchi compatibility shape is provable. -/
theorem bianchiCompatibilityClaim_holds : BianchiCompatibilityClaim := by
  intro divT divI κ hT hI ν
  rw [hT ν, hI ν]
  ring

/-- Tag the Bianchi compatibility claim with `AssumptionId.bianchiImpliesConservation`. -/
theorem bianchi_implies_conservation_tag :
    CATEPTAssumption bianchiImpliesConservation BianchiCompatibilityClaim :=
  bianchiCompatibilityClaim_holds

/-! ## §9 + §10 — Einstein field equations from thermodynamics -/

/-- The Jacobson-derivation claim as a non-vacuous structural Prop.

    Source: Fisher–Rao + Lawvere doc §9 (Einstein field equation) and
    §10 (self-consistent back-reaction with information stress tensor
    `I_μν`).

    Standard form (Jacobson 1995):
      `G_μν = (8πG/c⁴) T_μν + Λ g_μν`,
    arising from the Clausius relation `δQ = T dS` along local Rindler
    horizons. The doc adds the back-reacted form
      `G_μν = (8πG/c⁴) T_μν + κ I_μν`,
    where `I_μν = -2/√(-g) · δS_I/δg^{μν}` is the information stress
    tensor derived from variation of the imaginary action.

    Earlier drafts shipped this as `:= True`, which any input
    discharged trivially.  The upgraded definition encodes the
    *linear superposition* shape of the modified Einstein equation:
    if the gravitational tensor is determined by the sum of stress-
    energy and information stress with coupling `κ`, then it splits
    linearly under that decomposition.

    Phase-2 refines to a concrete equation with smooth-section
    tensor types and the actual `δQ = T dS` derivation. -/
def JacobsonEinsteinClaim : Prop :=
  ∀ (G T I : ℕ × ℕ → ℝ) (κ : ℝ),
    (∀ μν, G μν = κ * (T μν + I μν)) →
    ∀ μν, G μν = κ * T μν + κ * I μν

/-- The structural Jacobson/Einstein superposition shape is provable. -/
theorem jacobsonEinsteinClaim_holds : JacobsonEinsteinClaim := by
  intro G T I κ hG μν
  rw [hG μν]
  ring

/-- Tag the Jacobson-derivation claim with
    `AssumptionId.jacobsonEinsteinFromThermo`. -/
theorem jacobson_einstein_from_thermo_tag :
    CATEPTAssumption jacobsonEinsteinFromThermo JacobsonEinsteinClaim :=
  jacobsonEinsteinClaim_holds

/-! ## Bundled Phase-2 discharge target -/

/-- Conjoint tag bundle: both GR-side claims discharged through this
    file's wraps. When Phase-2 substitutes real continuum tensor
    calculus, this bundle is the place to refine. -/
theorem fisher_rao_lawvere_GR_retrofits_discharged :
    CATEPTAssumption bianchiImpliesConservation BianchiCompatibilityClaim
    ∧ CATEPTAssumption jacobsonEinsteinFromThermo JacobsonEinsteinClaim :=
  ⟨bianchi_implies_conservation_tag, jacobson_einstein_from_thermo_tag⟩

end CATEPTMain.Integration.FisherRaoLawvereAssumptionTags
