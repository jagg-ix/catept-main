import CATEPTMain.Integration.TheoryPluginHerglotzETH
import CATEPTMain.Domains.Adapters.Herglotz

/-!
# Classical Mechanics Certification Layer

This module upgrades the certification namespace's classical-mechanics
sector from a status stub to a real CAT/EPT certificate.

The first certified classical witness is the damped oscillator in the
Herglotz/contact formulation.  The imported source layer provides:

* a concrete `CATEPTPluginSlot`,
* the universal spine proof `actionIm / hbar = eptClock`,
* equality of the plugin clock with the Herglotz entropic diagnostic,
* non-positive energy dissipation along damped-equation jets,
* and the decay-rate/contact-rate identity.

## Certified claim

> A Herglotz/contact damped-oscillator classical-mechanics sector is
> certified under the CAT/EPT entropic-time spine.

## Not yet certified

- All Hamiltonian / Euler–Lagrange classical mechanics (CERT-UP-003 adds the
  zero-entropy reduction step; full Euler–Lagrange sector is future work).
-/

noncomputable section

set_option autoImplicit false

namespace CATEPTMain.Certification.ClassicalMechanics

open CATEPTMain.Integration
open CATEPTMain.Temporal.Adapter
open _root_.CATEPT

/-- A CAT/EPT certificate for the Herglotz/contact formulation of the
damped classical oscillator.

The certificate is parameterized by physically admissible oscillator data:
`hbar > 0`, `γ ≥ 0`, and `k ≥ 0`.

The central field is `slot_consistent`, which proves the same universal
CAT/EPT spine used by the other sectors:
`actionIm / hbar = eptClock`. -/
structure ClassicalMechanicsCATEPTCertificate
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) where

  /-- Universal CAT/EPT spine for the classical sector. -/
  slot_consistent : cateptConsistencyConstraint (herglotzPluginSlot p hbar hbar_pos hγ hk)

  /-- The slot clock equals the Herglotz entropic diagnostic. -/
  clock_eq_tauEnt :
    ∀ J : OscillatorJet,
      (herglotzPluginSlot p hbar hbar_pos hγ hk).eptClock J =
        canonicalTauDiag (herglotzETHParams p hbar hbar_pos) J

  /-- Along solutions of the damped equation, mechanical energy is non-increasing. -/
  dissipation_nonpos :
    ∀ J : OscillatorJet,
      JetSatisfiesDampedEquation p J →
        mechanicalEnergyDerivAtJet p J ≤ 0

  /-- The decay rate is given by the Herglotz contact rate. -/
  decayRate_eq :
    ∀ J : OscillatorJet,
      JetSatisfiesDampedEquation p J →
        -mechanicalEnergyDerivAtJet p J =
          herglotzContactRate p * p.m * J.v ^ 2

/-- The concrete Herglotz plugin slot for a given certificate (helper accessor). -/
def ClassicalMechanicsCATEPTCertificate.slot
    {p : DampedOscillatorParams} {hbar : ℝ}
    {hbar_pos : 0 < hbar} {hγ : 0 ≤ p.gamma} {hk : 0 ≤ p.k}
    (_ : ClassicalMechanicsCATEPTCertificate p hbar hbar_pos hγ hk) :
    CATEPTPluginSlot :=
  herglotzPluginSlot p hbar hbar_pos hγ hk

/-- Canonical Herglotz/contact classical-mechanics certificate. -/
def canonical_classical
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    ClassicalMechanicsCATEPTCertificate p hbar hbar_pos hγ hk where

  slot_consistent :=
    herglotzPlugin_is_consistent p hbar hbar_pos hγ hk

  clock_eq_tauEnt :=
    herglotzPlugin_clock_eq_tauEnt p hbar hbar_pos hγ hk

  dissipation_nonpos := by
    intro J hJ
    exact herglotzPlugin_dissipation_nonpos p hbar hbar_pos J hJ hγ

  decayRate_eq := by
    intro J hJ
    exact herglotzPlugin_decayRate_eq p J hJ

/-- Projection theorem: the canonical classical certificate satisfies the
universal CAT/EPT spine. -/
theorem classical_slot_consistent
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    cateptConsistencyConstraint (herglotzPluginSlot p hbar hbar_pos hγ hk) :=
  (canonical_classical p hbar hbar_pos hγ hk).slot_consistent

/-- Projection theorem: the canonical classical clock is the Herglotz
entropic diagnostic. -/
theorem classical_clock_eq_tauEnt
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k)
    (J : OscillatorJet) :
    (herglotzPluginSlot p hbar hbar_pos hγ hk).eptClock J =
      canonicalTauDiag (herglotzETHParams p hbar hbar_pos) J :=
  (canonical_classical p hbar hbar_pos hγ hk).clock_eq_tauEnt J

/-- Projection theorem: along damped-equation jets, the classical Herglotz
sector dissipates mechanical energy. -/
theorem classical_dissipation_nonpos
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k)
    (J : OscillatorJet) (hJ : JetSatisfiesDampedEquation p J) :
    mechanicalEnergyDerivAtJet p J ≤ 0 :=
  (canonical_classical p hbar hbar_pos hγ hk).dissipation_nonpos J hJ

/-- Projection theorem: the classical decay rate equals the contact-rate
formula. -/
theorem classical_decayRate_eq
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k)
    (J : OscillatorJet) (hJ : JetSatisfiesDampedEquation p J) :
    -mechanicalEnergyDerivAtJet p J =
      herglotzContactRate p * p.m * J.v ^ 2 :=
  (canonical_classical p hbar hbar_pos hγ hk).decayRate_eq J hJ

/-- **Zero-entropy reduction.**  When the Herglotz entropic clock is zero at a
jet `J`, the imaginary action at that jet is also zero.  This is the
conservative (non-dissipative) limit `S_I = 0 ↔ τ_ent = 0`.

Derivation: `cateptConsistencyConstraint` gives `actionIm J / ħ = eptClock J`.
If `eptClock J = 0` then `actionIm J / ħ = 0`, and since `ħ > 0` we conclude
`actionIm J = 0`. -/
theorem classical_zero_entropy_reduces
    (p : DampedOscillatorParams) (hbar : ℝ)
    (hbar_pos : 0 < hbar) (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k)
    (J : OscillatorJet)
    (h : (herglotzPluginSlot p hbar hbar_pos hγ hk).eptClock J = 0) :
    (herglotzPluginSlot p hbar hbar_pos hγ hk).actionIm J = 0 := by
  have hcons := herglotzPlugin_is_consistent p hbar hbar_pos hγ hk J
  rw [h] at hcons
  exact (div_eq_zero_iff.mp hcons).resolve_right hbar_pos.ne'

end CATEPTMain.Certification.ClassicalMechanics

end
