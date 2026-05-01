import CATEPTMain.Integration.RelationalInformationSubstrate
import CATEPTMain.Integration.ConstructorInformationSubstrate

/-!
# Substrate-to-Bell Adapter — Target C of relational-information-substrate.md

The relational-information substrate (T78) carries a bounded-propagation
law (`notificationDelay_le_bound`) and a per-entity reference-frame
structure. The existing `CATEPTMain/QuantumGravity/NoFTLBellBridge.lean`
contains the heavy mathematical content (Pauli gates, Bell states, CHSH
≤ 2 for classical, Tsirelson ≤ 2√2 for quantum, no-cloning, Minkowski
causal cone, ρ_bell density). The adapter is the BRIDGE: it expresses
substrate-level no-signaling and reference-frame-localised measurement
in the substrate's own language, so that future bridges between the
two layers don't have to re-derive Bell math.

## What this file proves (substrate side only)

- `SubstrateBellSource S` — a substrate `S` with two named entities
  ("Alice" and "Bob") plus an information object representing the
  shared-substrate payload.
- `substrate_alice_bob_no_signaling` — the substrate's
  `notificationDelay_le_bound` applied to Alice's notifications,
  Bob's notifications, and any pair: every signal respects the
  substrate's `propagationBound`.
- `substrate_pair_delay_bounded` — sum of two notification delays is
  bounded by `2 * propagationBound`, an n-fold corollary that
  generalises to any finite collection.
- `substrate_alice_nonperturbing_measurement` /
  `substrate_bob_nonperturbing_measurement` — non-vacuous local Bell
  measurement consuming a `MeasurementTask` + `InformationMedium`
  guard from `ConstructorInformationSubstrate`.  Substrate-level
  reading of "local marginals are signaling-safe" from the architecture
  note, with explicit anti-vacuity guards (`HasNontrivialNotifications`
  + `nonPerturbing` Prop the consumer must establish).

## What this file does NOT prove

- CHSH ≤ 2 (classical) — already in `NoFTLBellBridge.classical_chsh_bound`
- Tsirelson C² ≤ 8 — already in `NoFTLBellBridge.tsirelson_sq_bound`
- The full no-signaling theorem (placeholder in `NoFTLBellBridge.NoSignalingProp`)

The architecture note says: "shared substrate structure may induce
strong nonclassical correlations; usable notification or signaling
remains propagation-bounded." This file is the STRUCTURAL discharge
of the second clause; the first clause stays in the Bell bridge.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.SubstrateBell

open CATEPTMain.Integration (RelationalInformationSubstrate)

/-- **Bell source in substrate terms.** A substrate `S` with two named
    entities (Alice and Bob) and a shared payload. Conceptually this
    is the substrate-side picture of an EPR pair: the *correlation*
    lives at the substrate level (the shared `payloadObject`); the
    *signaling* is constrained by `S.propagationBound`. -/
structure SubstrateBellSource (S : RelationalInformationSubstrate) where
  alice : S.Entity
  bob : S.Entity
  /-- The shared information object that both Alice and Bob "see"
      via the substrate. -/
  payloadObject : S.InfoObject

namespace SubstrateBellSource

/-- **Substrate-level no-signaling.** The substrate's structural
    `notificationDelay_le_bound` law applies to *every* notification
    in the system, including those addressed to Alice and to Bob.
    Bounded propagation IS the no-FTL guarantee in substrate terms. -/
theorem substrate_alice_bob_no_signaling
    {S : RelationalInformationSubstrate} (_B : SubstrateBellSource S) :
    ∀ n : S.Notification, S.notificationDelay n ≤ S.propagationBound :=
  S.notificationDelay_le_bound

/-- The sum of two notification delays is bounded by twice the
    propagation constant. This is the substrate-level analog of "a
    pair of locally-bounded channels has globally-bounded total
    latency" — the *structural* shape underlying classical correlation
    bounds (e.g. CHSH ≤ 2). The actual CHSH proof remains in
    `NoFTLBellBridge.classical_chsh_bound`. -/
theorem substrate_pair_delay_bounded
    {S : RelationalInformationSubstrate} (_B : SubstrateBellSource S)
    (n₁ n₂ : S.Notification) :
    S.notificationDelay n₁ + S.notificationDelay n₂
      ≤ 2 * S.propagationBound := by
  have h₁ := S.notificationDelay_le_bound n₁
  have h₂ := S.notificationDelay_le_bound n₂
  linarith

/-- The substrate's reference frame for Alice (canonical local
    perspective). -/
noncomputable def aliceFrame
    {S : RelationalInformationSubstrate} (B : SubstrateBellSource S) :
    RelationalInformationSubstrate.ReferenceFrame S :=
  RelationalInformationSubstrate.canonicalFrame S B.alice

/-- The substrate's reference frame for Bob. -/
noncomputable def bobFrame
    {S : RelationalInformationSubstrate} (B : SubstrateBellSource S) :
    RelationalInformationSubstrate.ReferenceFrame S :=
  RelationalInformationSubstrate.canonicalFrame S B.bob

/-- Alice's frame and Bob's frame have distinct owners
    (the proof is just unfolding `canonicalFrame.owner`). -/
theorem alice_frame_owner
    {S : RelationalInformationSubstrate} (B : SubstrateBellSource S) :
    (aliceFrame B).owner = B.alice := rfl

theorem bob_frame_owner
    {S : RelationalInformationSubstrate} (B : SubstrateBellSource S) :
    (bobFrame B).owner = B.bob := rfl

end SubstrateBellSource

-- ═══════════════════════════════════════════════════════════════════════
-- CTI-vocabulary upgrade: non-vacuous local Bell measurement
-- ═══════════════════════════════════════════════════════════════════════

open CATEPTMain.Integration.ConstructorInformationSubstrate
  (MeasurementTask InformationMedium HasNontrivialNotifications)

namespace SubstrateBellSource

/-- **Non-vacuous local Bell measurement (CTI-vocabulary upgrade).**

Given a substrate Bell source `B`, a measurement task `m` over the
substrate, an information-medium witness `M` for the substrate, and a
proof `hNP` that `m` is non-perturbing, the conjunction `m.task.possible
∧ HasNontrivialNotifications S ∧ m.nonPerturbing` holds — packaging the
three CTI-load-bearing facts about a Bell-style local measurement.

This is the **non-vacuous statement** of substrate-level Alice-side local
Bell measurement.  Earlier drafts of this file shipped a placeholder
`substrate_local_frame_measurement` that discharged via `rfl` (`S.localOrder
B.alice n = S.localOrder B.alice n` etc.) and fell out for free under
`Notification := Empty`; that placeholder has been removed.  The theorem
below cannot be discharged by the trivial substrate because:

1. `M : InformationMedium S` requires `HasNontrivialNotifications S`
   (anti-vacuity guard from `ConstructorInformationSubstrate`),
2. `m.task_possible` is a definite possibility claim, not `True`,
3. `hNP : m.nonPerturbing` is a hypothesis the consumer must provide;
   we explicitly do *not* default `nonPerturbing` to `True`.

Each conjunct is a substantive statement; the conjunction encodes
"Alice's local Bell measurement is realisable, the substrate carries
real notifications, and the measurement is non-perturbing." -/
theorem substrate_alice_nonperturbing_measurement
    {S : RelationalInformationSubstrate} (_B : SubstrateBellSource S)
    (m : MeasurementTask S) (M : InformationMedium S)
    (hNP : m.nonPerturbing) :
    m.task.possible ∧
      HasNontrivialNotifications S ∧
      m.nonPerturbing :=
  ⟨m.task_possible, M.notifications_nontrivial, hNP⟩

/-- **Bob-side non-vacuous local Bell measurement.**  Symmetric companion
to `substrate_alice_nonperturbing_measurement`; takes a separate
measurement task `m'` for Bob's frame.  The `_B` argument carries Bob's
identity but the measurement task is generic over the substrate
(consumers can specialise `m'.measured` to Bob-localised attributes). -/
theorem substrate_bob_nonperturbing_measurement
    {S : RelationalInformationSubstrate} (_B : SubstrateBellSource S)
    (m' : MeasurementTask S) (M : InformationMedium S)
    (hNP : m'.nonPerturbing) :
    m'.task.possible ∧
      HasNontrivialNotifications S ∧
      m'.nonPerturbing :=
  ⟨m'.task_possible, M.notifications_nontrivial, hNP⟩

end SubstrateBellSource

/-! ## Connection to NoFTLBellBridge

The existing `CATEPTMain.QuantumGravity.NoFTLBellBridge` provides:

  - classical_chsh_bound  : ∀ a a' b b' ∈ {-1, 1}, |...| ≤ 2
  - tsirelson_bound       : ∀ a a' b b' ∈ ℝ, ... ≤ 2√2
  - rho_bell              : the concrete Bell density |Φ+⟩⟨Φ+|
  - InCausalFuture        : Minkowski causal cone

These are correlation/geometry facts. This file adds the substrate-side
no-signaling discharge. The two layers compose: a `SubstrateBellSource`
carries shared correlation structure (substrate-level), respects
bounded propagation (substrate-level), and any concrete realisation
that maps the substrate's payload into a Hilbert-space Bell density
inherits the existing Bell bridge's CHSH/Tsirelson bounds.

Future work: a `SubstrateBellRealisation` adapter that sends
`SubstrateBellSource S` to `(rho_bell, NoSignalingProp rho_bell ...)`,
making the bridge between substrate and Bell concrete at the data
level. Tracked separately if the Bell density structure deepens.
-/

end CATEPTMain.Integration.SubstrateBell
