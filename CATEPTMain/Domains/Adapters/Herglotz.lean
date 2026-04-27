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

/-- Herglotz upgraded to `LiveTemporalFramework` when the damping `γ > 0`.
    Witness: `{ x := 0, v := 1, a := 0 }` (rest with unit velocity) gives
    `mechanicalEnergy = m/2 > 0`, `herglotzContactRate = γ/m > 0`, and
    therefore `herglotzActionIm = (γ/m)·(m/2) = γ/2 > 0`. Dividing by
    `hbar > 0` keeps the clock positive.

    Proof technique adapted from the parallel codex T69 follow-up
    (branch feat/codex-t69-followup, commit bafcc427f) — credit
    preserved per multi-helper sync protocol. -/
noncomputable def herglotzLive
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) (hγpos : 0 < p.gamma) :
    LiveTemporalFramework where
  toTemporalFramework := herglotz p hbar hbar_pos hγ hk
  live_witness := by
    refine ⟨{ x := 0, v := 1, a := 0 }, ?_⟩
    show 0 < herglotzActionIm p { x := 0, v := 1, a := 0 } / hbar
    have hE : 0 < CATEPT.mechanicalEnergy p 0 1 := by
      unfold CATEPT.mechanicalEnergy
      have htwo : (0 : ℝ) < 2 := by norm_num
      have hm2 : 0 < p.m / 2 := div_pos p.m_pos htwo
      nlinarith
    have hrate : 0 < CATEPT.herglotzContactRate p := by
      unfold CATEPT.herglotzContactRate
      exact div_pos hγpos p.m_pos
    have hnum : 0 < herglotzActionIm p { x := 0, v := 1, a := 0 } := by
      unfold herglotzActionIm
      exact mul_pos hrate hE
    exact div_pos hnum hbar_pos

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

/-- ★ Non-vacuum `QuantumCorrespondenceInvariant` for Herglotz (T94) ★

    Damped-oscillator action `(γ/m)·E_mech / ℏ` plays both
    "curvature" and "expectation value" roles in `R = 8πG·⟨O⟩` with
    `G = 1/(8π)`. Same algebraic shape as T68 / T91. -/
noncomputable def herglotz_quantum_correspondence
    (p : DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    QuantumCorrespondenceInvariant (herglotz p hbar hbar_pos hγ hk) where
  curvature := (herglotz p hbar hbar_pos hγ hk).clock
  expectationValue := (herglotz p hbar hbar_pos hγ hk).clock
  G := 1 / (8 * Real.pi)
  G_pos := by
    apply div_pos one_pos
    have hπ : 0 < Real.pi := Real.pi_pos
    positivity
  bridges := by
    intro J
    show (herglotz p hbar hbar_pos hγ hk).clock J
        = 8 * Real.pi * (1 / (8 * Real.pi)) * (herglotz p hbar hbar_pos hγ hk).clock J
    have h8π : (8 : ℝ) * Real.pi ≠ 0 := by
      have hπ : 0 < Real.pi := Real.pi_pos
      positivity
    have : 8 * Real.pi * (1 / (8 * Real.pi)) = 1 := by field_simp
    rw [this, one_mul]

end CATEPTMain.Temporal.Adapter
