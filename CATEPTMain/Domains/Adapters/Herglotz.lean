import CATEPTMain.Domains.TemporalFramework
import CATEPTMain.Domains.Invariants.Conservation
import CATEPTMain.Domains.Invariants.Reduction
import CATEPTMain.Domains.Invariants.Symmetry
import CATEPTMain.Domains.Invariants.QuantumCorrespondence
import CATEPTMain.Domains.UnifiedValidator
import CATEPTMain.Domains.ETH.Domain

/-!
# Herglotz Adapter — `TemporalFramework` for the Damped Classical Oscillator

Wraps `herglotzSuperiorSlot` from `Domains/ETH/Domain.lean`.

Configuration: `CATEPT.OscillatorJet` (position `x`, velocity `v`,
acceleration `a`).
Clock: `S_I(J) = (γ/m) · E_mech(J) / ℏ` (Herglotz contact rate × energy).

This is the contact-Hamiltonian / Herglotz formulation of the damped
classical oscillator. The clock encodes the entropy-production rate of
the oscillator as it loses energy to the bath. With `γ = 0` the clock
is identically zero (vacuum / undamped) — corresponding to a frictionless
oscillator that does NOT participate in entropic time.

This adapter ships at the **kernel tier** only — `LiveTemporalFramework`
would require constructing an `OscillatorJet` with non-zero mechanical
energy, which has type-class machinery (`CATEPT.OscillatorJet`) we don't
need to exercise just to demonstrate kernel-tier coverage.
-/

set_option autoImplicit false

namespace CATEPTMain.Temporal.Adapter

open CATEPTMain.Integration (cateptConsistencyConstraint)
open _root_.CATEPT (DampedOscillatorParams OscillatorJet mechanicalEnergy
  herglotzActionIm herglotzActionIm_nonneg)

/-- Herglotz temporal framework for a damped 1-D oscillator. -/
noncomputable def herglotz
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    TemporalFramework where
  Config := OscillatorJet
  clock := fun J => herglotzActionIm p J / hbar
  clock_nonneg := fun J =>
    div_nonneg (herglotzActionIm_nonneg p hγ hk J) (le_of_lt hbar_pos)
  witness := { x := 0, v := 0, a := 0 }  -- the static-rest jet

theorem herglotz_satisfies_spine
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    cateptConsistencyConstraint
      (herglotz p hbar hbar_pos hγ hk).toCATEPTSlot :=
  (herglotz p hbar hbar_pos hγ hk).coherence_spine

-- ── Per-invariant claims ─────────────────────────────────────────────

noncomputable def herglotz_conservation
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    ConservationInvariant (herglotz p hbar hbar_pos hγ hk) :=
  (herglotz p hbar hbar_pos hγ hk).vacuumConservation

noncomputable def herglotz_reduction
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    ReductionInvariant (herglotz p hbar hbar_pos hγ hk) where
  classicalProjection := (herglotz p hbar hbar_pos hγ hk).clock
  target := (herglotz p hbar hbar_pos hγ hk).clock
  reduces_classically := fun _ => rfl

/-- Trivial (identity) symmetry: every clock is trivially invariant under
    `id`. The damped oscillator's full symmetry analysis (time-translation
    in the contact-Hamiltonian formulation, modulo the `γ`-dissipation
    breaking) is deferred — the kernel tier is satisfied. -/
noncomputable def herglotz_symmetry
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    SymmetryInvariant (herglotz p hbar hbar_pos hγ hk) :=
  (herglotz p hbar hbar_pos hγ hk).identitySymmetry

theorem herglotz_validates
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    UnifiedValidator
      (herglotz p hbar hbar_pos hγ hk)
      (some <| herglotz_conservation p hbar hbar_pos hγ hk)
      (some <| herglotz_reduction p hbar hbar_pos hγ hk)
      (some <| herglotz_symmetry p hbar hbar_pos hγ hk)
      none :=
  ⟨(herglotz p hbar hbar_pos hγ hk).coherence_spine,
   (herglotz_conservation p hbar hbar_pos hγ hk).divergence_free,
   (herglotz_reduction p hbar hbar_pos hγ hk).reduces_classically,
   (herglotz_symmetry p hbar hbar_pos hγ hk).clock_invariant,
   trivial⟩

end CATEPTMain.Temporal.Adapter
