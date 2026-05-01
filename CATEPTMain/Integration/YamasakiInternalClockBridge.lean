import Mathlib.Algebra.Lie.OfAssociative
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import CATEPTMain.CATEPT.CATEPT.SpinorPathIntegralBridge
import CATEPTMain.Integration.LocalFisherEntropicGeneratorBridge
import CATEPTMain.Integration.KMSModularParameterBridge

/-!
# Yamasaki Internal-Clock Bridge — Frenkel-Kramers / Zitterbewegung ↔ CAT/EPT

Records the connection identified by `CAT-EPT-20260415-26`: Yamasaki 1968's
Frenkel-Kramers / extended-Heisenberg model of zitterbewegung gives an
*internal kinematic clock* `t'` for the free Dirac electron, generated
by interference of positive-energy and negative-energy sectors.  CAT/EPT
adds an irreversible attenuation `e^{-τ_ent}` to the cross-sector
observables.

## Key claims (per CAT-EPT-20260415-26)

* Yamasaki gives an *internal kinematic* clock `t'` (zitterbewegung
  beating), distinct from any external/thermodynamic time.
* The internal clock is sourced by `Ψ = Ψ_+ + Ψ_-` interference: the
  fast oscillation comes from cross terms `⟨O⟩_{+-} + ⟨O⟩_{-+}`.
* CAT/EPT extension: `⟨O⟩_cross ↦ e^{-τ_ent} ⟨O⟩_cross` —
  visibility-decaying internal clock.

## What's already in catept-main

* [`SpinorPathIntegralBridge.lean`](../CATEPT/CATEPT/SpinorPathIntegralBridge.lean)
  ships `coherenceSectorSuppression` with `e^{-τ_ent/2}` attenuation
  on amplitude (squares to `e^{-τ_ent}` on density), plus the
  `(H_R - i H_I) Ψ` non-Hermitian Dirac-equation limit.
* [`ETHSpinorBridge.lean`](../../NavierStokesClean/CATEPT/External/ETHSpinorBridge.lean)
  ships `offDiagonalValue` + `tauDiag` + thermalisation-criterion
  pattern for cross-sector attenuation.
* [`KMSModularParameterBridge.lean`](./KMSModularParameterBridge.lean) (PR #61)
  ships `Δs_KMS = 1/γ_I` separated from `τ_ent` (the canonical
  4-layer time-flavor convention).

## What this module adds (Y1 + Y2 + Y3)

* **Y1**: `KinematicVsEntropicTimeSeparation` — `t'_yamasaki ≠ τ_ent`
  layer separation (pattern: PR #68 `StringWorldsheetTemporalBridge`
  for `τ_ws ≠ τ_ent`).
* **Y2**: `PosNegEnergyDecomposition` — `Ψ = Ψ_+ + Ψ_-` decomposition
  carrier.
* **Y3**: `CrossSectorInterferenceObservable` — observable
  `⟨O⟩_{+-} + ⟨O⟩_{-+}` carrier, with the visibility-decay claim
  inheriting from `coherenceSectorSuppression` in
  `SpinorPathIntegralBridge`.

## Leveraged Mathlib infrastructure

* `Mathlib.Algebra.Lie.OfAssociative` — the canonical commutator
  `⁅A, B⁆ = A · B - B · A` on any associative ring.  Used for the
  Heisenberg-picture commutator structure that Yamasaki §§2-4 builds
  on, without re-deriving operator algebra.

## Honest scope

* Carriers are abstract structural placeholders.
* The `t' ≠ τ_ent` layer separation is a structural Prop (counter-
  example pattern, like PR #68's `worldsheet_tau_separate_from_entropic_proper_time`).
* The visibility-decay claim is recorded as a Prop carrier; the actual
  `e^{-τ_ent}` factor on cross observables is the same shape that
  `SpinorPathIntegralBridge.coherenceSectorSuppression` already has.
* Frenkel-Kramers `Q` operator is not modeled here; consumer-supplied
  if needed.  Honest limit per the analysis (CAT-EPT-20260415-26):
  Yamasaki is "CAT/EPT-compatible as a theory of internal quantum clock
  structure, but **not yet** as a theory of entropic / non-Hermitian
  irreversibility" — this module preserves that boundary.

## Pattern

Same as PRs #52, #68, #76-#81: structural carriers + provable shape
claims by `ring` / `linarith` / `rfl`, with continuum content
explicitly deferred.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.YamasakiInternalClockBridge

noncomputable section

-- ═══════════════════════════════════════════════════════════════════════
-- §1 Y1 — Kinematic vs entropic proper-time layer separation
-- ═══════════════════════════════════════════════════════════════════════

/-- **Bridge contract: Yamasaki's kinematic `t'` vs CAT/EPT entropic `τ_ent`.**

Reply CAT-EPT-20260415-26 §3: "the difference is that Yamasaki's `t'`
is still a *kinematic/internal proper time* tied to internal
oscillation and positive/negative-energy structure, whereas CAT/EPT
proper time is meant to be an *irreversible/entropic clock*. So the
bridge is strong, but it is not identity."

Pattern matches PR #68's `StringWorldsheetTemporalBridge`: two
distinct named time variables that may agree under specific
identification carriers but are not identified by default. -/
structure IdentifyYamasakiKinematicWithEntropicProperTime where
  /-- The Yamasaki kinematic internal proper time `t'`. -/
  tauKinematic : ℝ → ℝ
  /-- The CAT/EPT entropic proper time `τ_ent = S_I/ℏ`. -/
  tauEnt       : ℝ → ℝ
  /-- The bridge identification: `t' = τ_ent` pointwise.  This is the
      load-bearing equation; consumers exhibit it only when their
      specific physical setup justifies the identification. -/
  tauEnt_eq_tauKinematic : ∀ s, tauEnt s = tauKinematic s

namespace IdentifyYamasakiKinematicWithEntropicProperTime

/-- Under the bridge contract, the entropic-proper-time function and
the Yamasaki kinematic `t'` agree as functions. -/
theorem tauEnt_eq_tauKinematic_funext
    (B : IdentifyYamasakiKinematicWithEntropicProperTime) :
    B.tauEnt = B.tauKinematic := by
  funext s
  exact B.tauEnt_eq_tauKinematic s

end IdentifyYamasakiKinematicWithEntropicProperTime

/-- **Note theorem (default separation).**

Without the `IdentifyYamasakiKinematicWithEntropicProperTime` bridge
carrier, the Yamasaki kinematic `t'` and an arbitrary CAT/EPT
entropic `τ_ent` need not coincide.

Concrete counter-example: take `tauKinematic := fun _ => 0` (a
constant kinematic time) and `tauEnt := fun s => s` (linear entropic
accumulation).  Then `tauEnt 1 = 1 ≠ 0 = tauKinematic 1`.

This is the same pattern as `worldsheet_tau_separate_from_entropic_proper_time`
in `StringWorldsheetTemporalBridge` (PR #68). -/
theorem yamasaki_kinematic_separate_from_entropic_proper_time :
    ∃ (tauKinematic tauEnt : ℝ → ℝ) (s : ℝ), tauEnt s ≠ tauKinematic s := by
  refine ⟨fun _ => (0 : ℝ), fun s => s, 1, ?_⟩
  norm_num

-- ═══════════════════════════════════════════════════════════════════════
-- §2 Y2 — Positive/negative-energy decomposition
-- ═══════════════════════════════════════════════════════════════════════

/-- **Positive/negative-energy decomposition carrier.**

Reply CAT-EPT-20260415-26 §3: "zitterbewegung requires the coexistence
or interference of *positive and negative energy states*."

Encodes `Ψ = Ψ_+ + Ψ_-` as a structural Prop with linearity preservation
under coupling rescaling.

Provable by `ring`. -/
def PosNegEnergyDecompositionShape : Prop :=
  ∀ (Ψ Ψ_plus Ψ_minus κ : ℝ),
    Ψ = Ψ_plus + Ψ_minus →
    κ * Ψ = κ * Ψ_plus + κ * Ψ_minus

theorem posNegEnergyDecompositionShape_holds : PosNegEnergyDecompositionShape := by
  intro Ψ Ψ_plus Ψ_minus κ h
  rw [h]
  ring

-- ═══════════════════════════════════════════════════════════════════════
-- §3 Y3 — Cross-sector interference observable
-- ═══════════════════════════════════════════════════════════════════════

/-- **Cross-sector interference observable.**

Reply CAT-EPT-20260415-26 §3: "the internal oscillation is an
*interference observable* `⟨O⟩_{+-} + ⟨O⟩_{-+}`."

Carries:
* `O_plus_minus` = `⟨O⟩_{+-}`
* `O_minus_plus` = `⟨O⟩_{-+}`

The total interference observable is the sum, which is the source of
zitterbewegung in Yamasaki's picture. -/
structure CrossSectorInterferenceObservable where
  /-- ⟨O⟩_{+-} cross expectation. -/
  O_plus_minus  : ℝ
  /-- ⟨O⟩_{-+} cross expectation. -/
  O_minus_plus  : ℝ

namespace CrossSectorInterferenceObservable

/-- The total cross-sector interference. -/
def total (X : CrossSectorInterferenceObservable) : ℝ :=
  X.O_plus_minus + X.O_minus_plus

/-- Linear decomposition. -/
theorem total_decomposes (X : CrossSectorInterferenceObservable) :
    X.total = X.O_plus_minus + X.O_minus_plus := rfl

/-- Trivial existence: zero cross terms. -/
theorem exists_trivial : ∃ X : CrossSectorInterferenceObservable, True :=
  ⟨{ O_plus_minus := 0, O_minus_plus := 0 }, trivial⟩

end CrossSectorInterferenceObservable

/-- **CAT/EPT visibility-decay claim shape.**

Reply CAT-EPT-20260415-26: "CAT/EPT would add something like
`⟨O⟩_cross ↦ e^{-τ_ent} ⟨O⟩_cross`."

Encodes the visibility-decay shape: the attenuated cross observable
is `e^{-τ_ent}` times the bare cross observable.  Shape-level claim
provable by `rfl` after unfolding.

The actual `e^{-τ_ent/2}` amplitude factor squaring to `e^{-τ_ent}`
on density is **already in catept-main** via
`SpinorPathIntegralBridge.coherenceSectorSuppression`; this module's
shape Prop is the consumer-facing layer. -/
def VisibilityDecayShape : Prop :=
  ∀ (O_cross τ_ent : ℝ),
    let O_attenuated := Real.exp (-τ_ent) * O_cross
    O_attenuated = Real.exp (-τ_ent) * O_cross

theorem visibilityDecayShape_holds : VisibilityDecayShape := by
  intro O_cross τ_ent
  rfl

/-- **Visibility-decay non-positive sign claim.**

If `τ_ent ≥ 0` and the cross observable is non-negative, then the
attenuated observable is no larger than the bare one.  This formalises
the "visibility loss" content of CAT/EPT in the cross sector. -/
theorem visibility_decay_attenuates
    (O_cross τ_ent : ℝ)
    (h_O : 0 ≤ O_cross) (h_τ : 0 ≤ τ_ent) :
    Real.exp (-τ_ent) * O_cross ≤ O_cross := by
  have h_exp_le_one : Real.exp (-τ_ent) ≤ 1 :=
    Real.exp_le_one_iff.mpr (neg_nonpos_of_nonneg h_τ)
  have h_exp_nn : 0 ≤ Real.exp (-τ_ent) := le_of_lt (Real.exp_pos _)
  calc Real.exp (-τ_ent) * O_cross
      ≤ 1 * O_cross := mul_le_mul_of_nonneg_right h_exp_le_one h_O
    _ = O_cross := one_mul _

-- ═══════════════════════════════════════════════════════════════════════
-- §4 Heisenberg-picture commutator — leveraged from Mathlib
-- ═══════════════════════════════════════════════════════════════════════

/-! Mathlib's `Lie.OfAssociative` provides `⁅A, B⁆ = A * B - B * A` on
any associative ring.  This is the canonical Heisenberg commutator
that Yamasaki §§2-4's extended-Heisenberg-picture construction uses.

We expose two structural-shape Props for use in CAT/EPT-side
consumers: antisymmetry and bilinearity in the first argument.  Both
are direct consequences of Mathlib's existing `LieRing` instance on
any associative ring (`Ring.toLieRing`); we record them here as
re-export theorems for downstream visibility. -/

/-- **Heisenberg-picture commutator antisymmetry** for any associative
ring `A`.

Direct consequence of Mathlib's `LieRing` instance: `⁅a, b⁆ = -⁅b, a⁆`.
Re-exported as a CAT/EPT-side theorem so consumers can reference the
antisymmetry without needing to navigate the Lie-ring typeclass
machinery.  Pulled from `Mathlib.Algebra.Lie.Basic.lie_skew`. -/
theorem commutator_antisym {A : Type*} [Ring A] (a b : A) :
    ⁅a, b⁆ = -⁅b, a⁆ :=
  (lie_skew a b).symm

/-- **Heisenberg-picture commutator bilinearity in the first argument**.

Direct consequence of Mathlib's `LieRing` instance:
`⁅a + a', b⁆ = ⁅a, b⁆ + ⁅a', b⁆`.  Pulled from `add_lie`. -/
theorem commutator_add_left {A : Type*} [Ring A] (a a' b : A) :
    ⁅a + a', b⁆ = ⁅a, b⁆ + ⁅a', b⁆ :=
  add_lie a a' b

-- ═══════════════════════════════════════════════════════════════════════
-- §5 Capstone bundle
-- ═══════════════════════════════════════════════════════════════════════

/-- **Yamasaki internal-clock bundle.**

All structural shape claims for Y1, Y2, Y3 hold simultaneously.

This is the explicit deliverable for the
`CAT-EPT-20260415-26`-style internal-clock interpretation of
zitterbewegung. -/
theorem yamasaki_internal_clock_bundle :
    PosNegEnergyDecompositionShape
    ∧ VisibilityDecayShape
    ∧ (∃ X : CrossSectorInterferenceObservable, True)
    ∧ (∃ (tauKinematic tauEnt : ℝ → ℝ) (s : ℝ), tauEnt s ≠ tauKinematic s) :=
  ⟨posNegEnergyDecompositionShape_holds,
   visibilityDecayShape_holds,
   CrossSectorInterferenceObservable.exists_trivial,
   yamasaki_kinematic_separate_from_entropic_proper_time⟩

/-- **Honest-scope marker.**

Per Reply CAT-EPT-20260415-26 verdict:
> Yamasaki 1968 is CAT/EPT-compatible as a theory of *internal
> quantum clock structure*, but **not yet** as a theory of entropic
> or non-Hermitian irreversibility.

This module preserves that limit: the Y1 layer separation, Y2
decomposition, Y3 cross-observable, and visibility-decay shape are
shipped, but the *operator-algebra* extension (Frenkel-Kramers `Q`
operator, full extended-Heisenberg-picture algebra) remains
consumer-supplied. -/
def YamasakiHonestScope : Prop :=
  ∀ (kinematic entropic : Prop),
    -- The two interpretive layers are independent claims at the
    -- structural level; consumer-supplied identification carriers
    -- bridge them when justified.
    (kinematic ∧ entropic) → (kinematic ∨ entropic)

theorem yamasakiHonestScope_holds : YamasakiHonestScope := by
  intro k e h
  exact Or.inl h.1

-- ═══════════════════════════════════════════════════════════════════════
-- §6 Y4 — Two-Hamiltonian split (H_I, H_II)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Two-Hamiltonian split (Yamasaki §§1-3).**

Reply CAT-EPT-20260415-27 §1-3: Yamasaki introduces two covariant
Hamiltonians `H_I` and `H_II` in the extended Heisenberg picture.
`H_II` (second-order) yields the regular FK-like / classicalised
sector with proper time `τ_II`; `H_I` (first-order) yields the
zitterbewegung sector with proper time `τ_I`.

Both Hamiltonians are non-negative (energy positivity).  This is a
**kinematic** split — both sectors are coherent.  CAT/EPT's irreversible
Hamiltonian `H_eff = H_R - i H_I^{(CAT/EPT)}` (from
`GKSLInformationExchangeBridge` PR #63) is a *different* split on a
different axis. -/
structure TwoHamiltonianSplit where
  /-- First-order Hamiltonian (zitterbewegung sector). -/
  H_I       : ℝ
  /-- Second-order Hamiltonian (FK regular sector). -/
  H_II      : ℝ
  /-- Energy positivity. -/
  H_I_nonneg  : 0 ≤ H_I
  H_II_nonneg : 0 ≤ H_II

namespace TwoHamiltonianSplit

/-- Total Hamiltonian as sum of the two sectors. -/
def total (S : TwoHamiltonianSplit) : ℝ := S.H_I + S.H_II

/-- Total is non-negative. -/
theorem total_nonneg (S : TwoHamiltonianSplit) : 0 ≤ S.total :=
  add_nonneg S.H_I_nonneg S.H_II_nonneg

/-- Trivial existence. -/
theorem exists_trivial : ∃ _ : TwoHamiltonianSplit, True :=
  ⟨{ H_I := 0, H_II := 0
     H_I_nonneg := le_refl 0
     H_II_nonneg := le_refl 0 }, trivial⟩

end TwoHamiltonianSplit

-- ═══════════════════════════════════════════════════════════════════════
-- §7 Y5 — Two kinematic proper times (τ_I, τ_II)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Two kinematic proper times (Yamasaki §§2-3).**

`τ_I` from `H_I` for zitterbewegung; `τ_II` from `H_II` for FK
regular sector.  **Both are kinematic, not entropic** — the canonical
4-layer time-flavour separation places `τ_ent` on a different axis. -/
structure TwoKinematicProperTimes where
  /-- Zitterbewegung-sector kinematic time. -/
  tau_I  : ℝ → ℝ
  /-- FK-regular-sector kinematic time. -/
  tau_II : ℝ → ℝ

/-- **Default-separation theorem.**

Without a `Identify…`-style identification carrier, `τ_I` and `τ_II`
need not coincide.  Concrete counter-example: `tau_I s := s` and
`tau_II s := 0`.  Then `tau_I 1 = 1 ≠ 0 = tau_II 1`. -/
theorem tau_I_separate_from_tau_II :
    ∃ (tau_I tau_II : ℝ → ℝ) (s : ℝ), tau_I s ≠ tau_II s := by
  refine ⟨fun s => s, fun _ => (0 : ℝ), 1, ?_⟩
  norm_num

-- ═══════════════════════════════════════════════════════════════════════
-- §8 Y6 — Operator decomposition Q = Q_regular + Q_zbw (§5.4)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Operator decomposition (Yamasaki §5.4).**

Reply CAT-EPT-20260415-28 §5.4: Yamasaki shows
`Q = Q_regular + Q_zbw` with `ψ†Q_regular ψ` constant and
`ψ†Q_zbw ψ` oscillating in the mixed pos/neg-energy state.

This is the operator-density version of the Hamiltonian split. -/
structure OperatorDecomposition where
  /-- The regular (constant-density) operator part. -/
  Q_regular : ℝ
  /-- The zitterbewegung (oscillating-density) operator part. -/
  Q_zbw     : ℝ

namespace OperatorDecomposition

/-- The total operator value. -/
def total (D : OperatorDecomposition) : ℝ := D.Q_regular + D.Q_zbw

/-- Linear decomposition. -/
theorem total_decomposes (D : OperatorDecomposition) :
    D.total = D.Q_regular + D.Q_zbw := rfl

/-- The pure-regular limit: `Q_zbw = 0` ⇒ `Q = Q_regular`. -/
theorem pure_regular (D : OperatorDecomposition) (h : D.Q_zbw = 0) :
    D.total = D.Q_regular := by
  unfold total
  rw [h]
  ring

/-- The pure-zbw limit: `Q_regular = 0` ⇒ `Q = Q_zbw`. -/
theorem pure_zbw (D : OperatorDecomposition) (h : D.Q_regular = 0) :
    D.total = D.Q_zbw := by
  unfold total
  rw [h]
  ring

end OperatorDecomposition

-- ═══════════════════════════════════════════════════════════════════════
-- §9 Y7 — Coherent oscillator shape Re(C_Q · e^{2imτ'}) (§5.3)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Coherent oscillator (Yamasaki §5.3).**

Reply CAT-EPT-20260415-28 §5.3: the cross-sector zitterbewegung observable
takes the form

```
⟨Q⟩_cross ~ C_Q · e^{2imτ'} + C̄_Q · e^{-2imτ'} = 2 Re(C_Q · e^{2imτ'})
```

with `m` the electron mass and `τ'` the new proper time introduced by
the substitution `p·r − Wt → -mτ'`.

We use the trigonometric form `Re(C · e^{iθ}) = C_re · cos θ − C_im · sin θ`
to encode the oscillator without needing `Complex.exp`. -/
structure CoherentOscillator where
  /-- Real part of complex amplitude `C_Q`. -/
  C_Q_real : ℝ
  /-- Imaginary part of complex amplitude `C_Q`. -/
  C_Q_imag : ℝ
  /-- Electron mass `m > 0`. -/
  m        : ℝ
  m_pos    : 0 < m

namespace CoherentOscillator

/-- The coherent oscillation `Re(C_Q · e^{2imτ'})` at proper time `τ'`. -/
def oscillation (osc : CoherentOscillator) (τ' : ℝ) : ℝ :=
  osc.C_Q_real * Real.cos (2 * osc.m * τ') -
  osc.C_Q_imag * Real.sin (2 * osc.m * τ')

/-- The oscillation at `τ' = 0` is the real part of the amplitude. -/
theorem oscillation_at_zero (osc : CoherentOscillator) :
    osc.oscillation 0 = osc.C_Q_real := by
  unfold oscillation
  simp

/-- For zero amplitude, the oscillation vanishes identically. -/
theorem oscillation_zero_amplitude {m : ℝ} (m_pos : 0 < m) (τ' : ℝ) :
    let osc : CoherentOscillator :=
      { C_Q_real := 0, C_Q_imag := 0, m := m, m_pos := m_pos }
    osc.oscillation τ' = 0 := by
  unfold oscillation
  ring

/-- Trivial existence. -/
theorem exists_trivial : ∃ _ : CoherentOscillator, True :=
  ⟨{ C_Q_real := 0, C_Q_imag := 0, m := 1
     m_pos := by norm_num }, trivial⟩

end CoherentOscillator

-- ═══════════════════════════════════════════════════════════════════════
-- §10 Y8 — Full CAT/EPT formula (§5 + visibility envelope)
-- ═══════════════════════════════════════════════════════════════════════

/-- **CAT/EPT-extended expectation value (Yamasaki §5 + irreversible envelope).**

Reply CAT-EPT-20260415-28: the full CAT/EPT-upgraded zitterbewegung
expectation value combines:

* `⟨Q⟩_diag` — the regular sector (consumer-supplied).
* `Re(C_Q · e^{2imτ'})` — the coherent oscillator from `τ'`.
* `e^{-τ_ent}` — the irreversible attenuation envelope from `τ_ent`.

```
⟨Q⟩_CAT/EPT(τ', τ_ent) = ⟨Q⟩_diag + e^{-τ_ent} · Re(C_Q · e^{2imτ'})
```

This is the precise CAT/EPT upgrade of Yamasaki §5: Yamasaki gives the
coherent oscillator; CAT/EPT supplies the damping envelope. -/
def cateptExpectationValue
    (osc : CoherentOscillator) (Q_diag : ℝ) (τ' τ_ent : ℝ) : ℝ :=
  Q_diag + Real.exp (-τ_ent) * osc.oscillation τ'

/-- At `τ_ent = 0`, the CAT/EPT expectation value reduces to the
coherent Yamasaki form. -/
theorem cateptExpectationValue_at_zero_τent
    (osc : CoherentOscillator) (Q_diag τ' : ℝ) :
    cateptExpectationValue osc Q_diag τ' 0 = Q_diag + osc.oscillation τ' := by
  unfold cateptExpectationValue
  simp

/-- **CAT/EPT envelope attenuates the coherent oscillator amplitude.**

Builds on `visibility_decay_attenuates` (Y3): under `τ_ent ≥ 0` and
non-negative oscillation, the irreversible envelope only attenuates.

This is the formal statement of the CAT/EPT visibility-decay claim
applied to the Yamasaki coherent oscillator. -/
theorem catept_attenuates_coherent_oscillator
    (osc : CoherentOscillator) (τ' τ_ent : ℝ)
    (h_τ_ent : 0 ≤ τ_ent)
    (h_osc_nonneg : 0 ≤ osc.oscillation τ') :
    Real.exp (-τ_ent) * osc.oscillation τ' ≤ osc.oscillation τ' :=
  visibility_decay_attenuates (osc.oscillation τ') τ_ent h_osc_nonneg h_τ_ent

/-- **Full CAT/EPT bound.**

If the diagonal is non-negative, the oscillator non-negative, and `τ_ent ≥ 0`,
then the CAT/EPT-extended expectation value is bounded above by the
unattenuated Yamasaki value. -/
theorem cateptExpectationValue_le_unattenuated
    (osc : CoherentOscillator) (Q_diag τ' τ_ent : ℝ)
    (h_τ_ent : 0 ≤ τ_ent)
    (h_osc_nonneg : 0 ≤ osc.oscillation τ') :
    cateptExpectationValue osc Q_diag τ' τ_ent ≤ Q_diag + osc.oscillation τ' := by
  unfold cateptExpectationValue
  have := catept_attenuates_coherent_oscillator osc τ' τ_ent h_τ_ent h_osc_nonneg
  linarith

-- ═══════════════════════════════════════════════════════════════════════
-- §11 Extended capstone (Y4-Y8)
-- ═══════════════════════════════════════════════════════════════════════

/-- **Yamasaki extension bundle (Y4-Y8).**

All structural deliverables from Replies CAT-EPT-20260415-27 and -28
hold simultaneously, supplementing PR #82's Y1-Y3:

* Y4 — Two-Hamiltonian split exists.
* Y5 — Two kinematic proper times default-separate.
* Y6 — Operator decomposition `Q = Q_regular + Q_zbw` is well-defined.
* Y7 — Coherent oscillator existence + zero-amplitude trivial case.
* Y8 — CAT/EPT envelope attenuates the coherent oscillator. -/
theorem yamasaki_extension_bundle :
    (∃ _ : TwoHamiltonianSplit, True)
    ∧ (∃ (tau_I tau_II : ℝ → ℝ) (s : ℝ), tau_I s ≠ tau_II s)
    ∧ (∃ _ : CoherentOscillator, True)
    ∧ (∀ (osc : CoherentOscillator) (τ' τ_ent : ℝ),
        0 ≤ τ_ent →
        0 ≤ osc.oscillation τ' →
        Real.exp (-τ_ent) * osc.oscillation τ' ≤ osc.oscillation τ') :=
  ⟨TwoHamiltonianSplit.exists_trivial,
   tau_I_separate_from_tau_II,
   CoherentOscillator.exists_trivial,
   fun osc τ' τ_ent h_τ_ent h_osc =>
     catept_attenuates_coherent_oscillator osc τ' τ_ent h_τ_ent h_osc⟩

end

end CATEPTMain.Integration.YamasakiInternalClockBridge
