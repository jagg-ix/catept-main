import CATEPTMain.Integration.RelationalInformationSubstrate
import CATEPTMain.Domains.Adapters.HarmonicOscillator
import CATEPTMain.Domains.Adapters.Minkowski
import CATEPTMain.Domains.Adapters.EM
import CATEPTMain.Domains.Adapters.VML
import CATEPTMain.Domains.Adapters.Kinetic
import CATEPTMain.Domains.Adapters.Higgs
import CATEPTMain.Domains.Adapters.Herglotz
import CATEPTMain.Domains.Adapters.BohmianEM
import CATEPTMain.Domains.Adapters.QM
import CATEPTMain.Domains.Adapters.SR
import CATEPTMain.Domains.QM.Domain

/-!
# Substrate Projection Demos — leverage of the RIS kernel

The `RelationalInformationSubstrate` (introduced in
`Integration/RelationalInformationSubstrate.lean`) is the ontological
floor of the spine: every existing `TemporalFramework` adapter can be
re-derived as `S.toTemporalFramework E` for a suitable substrate `S`
and entropic clock `E`.

This file demonstrates that on one concrete adapter (T68 harmonic
oscillator). The pattern transfers verbatim to every other adapter:

  Adapter           Entity          irreversibleCost
  -------           ------          ----------------
  Minkowski         Fin 4 → ℝ        const 0
  EM (μ₀)           Fin 4 → ℝ        ‖A‖² · μ₀⁻¹/2 · ℏ
  HarmonicOscillator (this file)
  Kinetic (T)       Fin 3 → ℝ        ‖v‖² · ℏ / (2T)
  Higgs             ℝ                higgsAction · ℏ
  Herglotz          OscillatorJet    herglotzActionIm · ℏ
  BohmianEM         Fin 4 → ℝ        ‖v − A_bg‖²/2 · ℏ
  QM                DensityMatrix n  vonNeumannEntropy · ℏ
  SR                SREvent d        properTime · ℏ

Once each substrate witness is in place, the per-adapter spine proofs
collapse into the single theorem
`RelationalInformationSubstrate.toTemporalFramework_coherence` —
substrate IS the comparator, not just the slot shape.

## Why only HO here

Building the eight other substrate witnesses is mechanical, not
illuminating. One demo establishes the leverage; the rest are
follow-ups when the per-domain QC bridges call for them.

## Generic constructor (added 2026-04-27)

Rather than hand-rolling a substrate per adapter, the generic
`ofTemporalFramework T` lifts ANY TemporalFramework into a substrate
in one step. Every per-adapter witness then becomes a one-line
specialisation. The original `harmonicSubstrate` is preserved as a
hand-written demo; below it, all nine other adapters get their
substrates via the generic constructor.
-/

set_option autoImplicit false

namespace CATEPTMain.Domains.SubstrateProjections

open CATEPTMain.Integration (RelationalInformationSubstrate)
open CATEPTMain.Temporal (TemporalFramework)

/-- The harmonic-oscillator substrate. `Entity = HOConfig`, all
    inter-entity structure (notifications, causal order, propagation
    bound) is vacuous via `Empty` — the substrate's role here is
    purely to host the irreversible-cost observable
    `(q² + p²)/2`. The bounded-propagation, causal-order, and
    no-FTL laws are vacuously satisfied because there are no
    notifications. -/
noncomputable def harmonicSubstrate : RelationalInformationSubstrate where
  Entity := CATEPTMain.Temporal.Adapter.HOConfig
  InfoObject := Unit
  Notification := Empty
  sender := Empty.elim
  receiver := Empty.elim
  payload := Empty.elim
  causalPrecedes := fun n _ => n.elim
  localOrder := fun _ n => n.elim
  localOrder_causal := by intro n₁ _ _ _ _ _; exact n₁.elim
  propagationBound := 1
  propagationBound_pos := by norm_num
  notificationDelay := Empty.elim
  notificationDelay_nonneg := fun n => n.elim
  notificationDelay_le_bound := fun n => n.elim
  phase := fun _ => 0
  storedInfo := fun _ => 0
  storedInfo_nonneg := fun _ => le_refl 0
  irreversibleCost := CATEPTMain.Temporal.Adapter.hoHamiltonian
  irreversibleCost_nonneg :=
    CATEPTMain.Temporal.Adapter.hoHamiltonian_nonneg
  witness := fun _ => 0

/-- Canonical entropic clock at ℏ = 1 (the Logos / Superior-Method
    convention). -/
noncomputable def harmonicEntropicClock :
    RelationalInformationSubstrate.EntropicClock harmonicSubstrate where
  hbar := 1
  hbar_pos := one_pos

/-- ★ LEVERAGE THEOREM ★

    The substrate's projection produces the same TemporalFramework as
    the standalone T68 harmonic adapter — pointwise, by `rfl` after
    `div_one`. Every other adapter inherits an analogous witness;
    this is the proof-of-concept that the relational substrate IS the
    semantic floor of the T-series. -/
theorem harmonic_is_substrate_projection :
    ∀ x : CATEPTMain.Temporal.Adapter.HOConfig,
      (RelationalInformationSubstrate.toTemporalFramework
          harmonicSubstrate harmonicEntropicClock).clock x =
        CATEPTMain.Temporal.Adapter.harmonic.clock x := by
  intro x
  show RelationalInformationSubstrate.tauEnt
        harmonicSubstrate harmonicEntropicClock x =
      CATEPTMain.Temporal.Adapter.hoHamiltonian x
  unfold RelationalInformationSubstrate.tauEnt
  show CATEPTMain.Temporal.Adapter.hoHamiltonian x / 1 =
       CATEPTMain.Temporal.Adapter.hoHamiltonian x
  exact div_one _

/-- The substrate's entropic-time projection coheres with the CAT/EPT
    spine — without re-proving anything per-adapter. This subsumes
    `harmonic_satisfies_spine`. -/
theorem harmonicSubstrate_satisfies_spine :
    CATEPTMain.Integration.cateptConsistencyConstraint
      ((RelationalInformationSubstrate.toTemporalFramework
          harmonicSubstrate harmonicEntropicClock).toCATEPTSlot) :=
  RelationalInformationSubstrate.toTemporalFramework_coherence
    harmonicSubstrate harmonicEntropicClock

-- ═════════════════════════════════════════════════════════════════════
-- Generic substrate-from-TemporalFramework constructor (2026-04-27)
-- ═════════════════════════════════════════════════════════════════════

/-- **Generic substrate constructor.** Every `TemporalFramework` `T`
    induces a substrate where:

      Entity        := T.Config       (the adapter's points)
      irreversibleCost := T.clock     (the adapter's clock)
      witness       := T.witness
      Notification  := Empty           (vacuous causal/no-FTL laws)

    All inter-entity structure (notifications, causal precedence, local
    order, propagation delay) is vacuously satisfied because there are
    no notifications. This gives every adapter a substrate witness in
    one line: `<adapter>Substrate := ofTemporalFramework <adapter>`.

    The "real" substrate use-cases (Bell sources, modular flows,
    Lindblad evolution) require non-vacuous Notification carriers; this
    constructor is the kernel-tier projection that says: *at minimum*,
    every TemporalFramework adapter is a substrate. -/
noncomputable def ofTemporalFramework (T : TemporalFramework) :
    RelationalInformationSubstrate where
  Entity := T.Config
  InfoObject := Unit
  Notification := Empty
  sender := Empty.elim
  receiver := Empty.elim
  payload := Empty.elim
  causalPrecedes := fun n _ => n.elim
  localOrder := fun _ n => n.elim
  localOrder_causal := by intro n₁ _ _ _ _ _; exact n₁.elim
  propagationBound := 1
  propagationBound_pos := by norm_num
  notificationDelay := Empty.elim
  notificationDelay_nonneg := fun n => n.elim
  notificationDelay_le_bound := fun n => n.elim
  phase := fun _ => 0
  storedInfo := fun _ => 0
  storedInfo_nonneg := fun _ => le_refl 0
  irreversibleCost := T.clock
  irreversibleCost_nonneg := T.clock_nonneg
  witness := T.witness

/-- Canonical ℏ = 1 entropic clock for any `ofTemporalFramework T`. -/
noncomputable def ofTemporalFrameworkClock (T : TemporalFramework) :
    RelationalInformationSubstrate.EntropicClock (ofTemporalFramework T) where
  hbar := 1
  hbar_pos := one_pos

/-- ★ UNIVERSAL LEVERAGE THEOREM ★

    For every `TemporalFramework` `T`, the substrate's projection
    `(ofTemporalFramework T).toTemporalFramework E` produces a
    TemporalFramework whose `clock` equals `T.clock` pointwise. The
    proof is `div_one`. Per-adapter `*_is_substrate_projection`
    theorems are now one-line specialisations. -/
theorem ofTemporalFramework_projects_to_self (T : TemporalFramework) :
    ∀ x : T.Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (ofTemporalFramework T) (ofTemporalFrameworkClock T)).clock x =
        T.clock x := by
  intro x
  show RelationalInformationSubstrate.tauEnt
        (ofTemporalFramework T) (ofTemporalFrameworkClock T) x =
      T.clock x
  unfold RelationalInformationSubstrate.tauEnt
  show T.clock x / 1 = T.clock x
  exact div_one _

-- ═════════════════════════════════════════════════════════════════════
-- Per-adapter substrates (one-line specialisations of the generic)
-- ═════════════════════════════════════════════════════════════════════

open CATEPTMain.Temporal.Adapter
open CATEPTMain.Quantum.QUANTUM (DensityMatrix)

/-- Minkowski vacuum substrate. Clock ≡ 0. -/
noncomputable def minkowskiSubstrate : RelationalInformationSubstrate :=
  ofTemporalFramework minkowski

/-- Electromagnetic substrate. Clock = ‖A‖²/(2μ₀). -/
noncomputable def emSubstrate (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    RelationalInformationSubstrate :=
  ofTemporalFramework (em μ₀ hμ₀)

/-- VML substrate. Clock = ‖v‖²/(2T) + ‖E‖² + ‖∇B‖² (Lyapunov action). -/
noncomputable def vmlSubstrate : RelationalInformationSubstrate :=
  ofTemporalFramework vml

/-- Kinetic Maxwell-Boltzmann substrate. Clock = ‖v‖²/(2T). -/
noncomputable def kineticSubstrate (T : ℝ) (hT : 0 < T) :
    RelationalInformationSubstrate :=
  ofTemporalFramework (kinetic T hT)

/-- Higgs substrate. Clock = (λ/4)(φ²−v²)². -/
noncomputable def higgsSubstrate (v lam : ℝ) (hlam : 0 < lam) :
    RelationalInformationSubstrate :=
  ofTemporalFramework (higgs v lam hlam)

/-- Herglotz damped-oscillator substrate. Clock = (γ/m)·E_mech / ℏ. -/
noncomputable def herglotzSubstrate
    (p : _root_.CATEPT.DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    RelationalInformationSubstrate :=
  ofTemporalFramework (herglotz p hbar hbar_pos hγ hk)

/-- Bohmian-EM substrate. Clock = ‖v − A_bg‖²/2. -/
noncomputable def bohmianEMSubstrate (A_bg : Fin 4 → ℝ) :
    RelationalInformationSubstrate :=
  ofTemporalFramework (bohmianEM A_bg)

/-- QM density-matrix substrate. Clock = vonNeumannEntropy n. -/
noncomputable def qmSubstrate (n : ℕ) (ρ₀ : DensityMatrix n) :
    RelationalInformationSubstrate :=
  ofTemporalFramework (qm n ρ₀)

/-- SR proper-time substrate. Clock = √⟪p−q, p−q⟫ₘ. -/
noncomputable def srSubstrate (d : ℕ) : RelationalInformationSubstrate :=
  ofTemporalFramework (sr d)

-- ═════════════════════════════════════════════════════════════════════
-- Per-adapter projection theorems (all collapse to the generic)
-- ═════════════════════════════════════════════════════════════════════

theorem minkowski_is_substrate_projection :
    ∀ x : (Fin 4 → ℝ),
      (RelationalInformationSubstrate.toTemporalFramework
          minkowskiSubstrate
          (ofTemporalFrameworkClock minkowski)).clock x =
        minkowski.clock x :=
  ofTemporalFramework_projects_to_self minkowski

theorem em_is_substrate_projection (μ₀ : ℝ) (hμ₀ : 0 < μ₀) :
    ∀ x : (Fin 4 → ℝ),
      (RelationalInformationSubstrate.toTemporalFramework
          (emSubstrate μ₀ hμ₀)
          (ofTemporalFrameworkClock (em μ₀ hμ₀))).clock x =
        (em μ₀ hμ₀).clock x :=
  ofTemporalFramework_projects_to_self (em μ₀ hμ₀)

theorem vml_is_substrate_projection :
    ∀ x : vml.Config,
      (RelationalInformationSubstrate.toTemporalFramework
          vmlSubstrate
          (ofTemporalFrameworkClock vml)).clock x =
        vml.clock x :=
  ofTemporalFramework_projects_to_self vml

theorem kinetic_is_substrate_projection (T : ℝ) (hT : 0 < T) :
    ∀ x : (kinetic T hT).Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (kineticSubstrate T hT)
          (ofTemporalFrameworkClock (kinetic T hT))).clock x =
        (kinetic T hT).clock x :=
  ofTemporalFramework_projects_to_self (kinetic T hT)

theorem higgs_is_substrate_projection (v lam : ℝ) (hlam : 0 < lam) :
    ∀ x : (higgs v lam hlam).Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (higgsSubstrate v lam hlam)
          (ofTemporalFrameworkClock (higgs v lam hlam))).clock x =
        (higgs v lam hlam).clock x :=
  ofTemporalFramework_projects_to_self (higgs v lam hlam)

theorem herglotz_is_substrate_projection
    (p : _root_.CATEPT.DampedOscillatorParams) (hbar : ℝ) (hbar_pos : 0 < hbar)
    (hγ : 0 ≤ p.gamma) (hk : 0 ≤ p.k) :
    ∀ x : (herglotz p hbar hbar_pos hγ hk).Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (herglotzSubstrate p hbar hbar_pos hγ hk)
          (ofTemporalFrameworkClock (herglotz p hbar hbar_pos hγ hk))).clock x =
        (herglotz p hbar hbar_pos hγ hk).clock x :=
  ofTemporalFramework_projects_to_self (herglotz p hbar hbar_pos hγ hk)

theorem bohmianEM_is_substrate_projection (A_bg : Fin 4 → ℝ) :
    ∀ x : (bohmianEM A_bg).Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (bohmianEMSubstrate A_bg)
          (ofTemporalFrameworkClock (bohmianEM A_bg))).clock x =
        (bohmianEM A_bg).clock x :=
  ofTemporalFramework_projects_to_self (bohmianEM A_bg)

theorem qm_is_substrate_projection (n : ℕ) (ρ₀ : DensityMatrix n) :
    ∀ x : (qm n ρ₀).Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (qmSubstrate n ρ₀)
          (ofTemporalFrameworkClock (qm n ρ₀))).clock x =
        (qm n ρ₀).clock x :=
  ofTemporalFramework_projects_to_self (qm n ρ₀)

theorem sr_is_substrate_projection (d : ℕ) :
    ∀ x : (sr d).Config,
      (RelationalInformationSubstrate.toTemporalFramework
          (srSubstrate d)
          (ofTemporalFrameworkClock (sr d))).clock x =
        (sr d).clock x :=
  ofTemporalFramework_projects_to_self (sr d)

end CATEPTMain.Domains.SubstrateProjections
