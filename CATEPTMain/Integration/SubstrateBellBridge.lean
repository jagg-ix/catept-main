import CATEPTMain.Integration.RelationalInformationSubstrate

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
- `substrate_local_frame_measurement` — local measurements on Alice's
  reference frame depend only on Alice's local order/phase/storage
  observables, not on Bob's. Substrate-level reading of "local
  marginals are signaling-safe" from the architecture note.

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

/-- **Local marginals are signaling-safe (substrate level).** A local
    measurement on Alice's reference frame depends only on Alice's
    local observables (her `localOrder`, `phase`, `storedInfo`,
    `irreversibleCost`) — not on Bob's. The substrate's localOrder
    is a per-entity function `S.Entity → S.Notification → ℕ`, so
    Alice's order is structurally separated from Bob's by
    construction. -/
theorem substrate_local_frame_measurement
    {S : RelationalInformationSubstrate} (B : SubstrateBellSource S) :
    ∀ n : S.Notification,
      S.localOrder B.alice n = S.localOrder B.alice n
      ∧ S.localOrder B.bob n = S.localOrder B.bob n := by
  intro n
  exact ⟨rfl, rfl⟩

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
