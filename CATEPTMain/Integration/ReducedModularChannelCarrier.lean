import CATEPTMain.Integration.EtaSpectralDensityCarrier
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith

/-!
# ReducedModularChannelCarrier — AQFT/CAT-EPT reduced channel + master split

Structural-carrier landing pad for the unification-master-equation
identified in `REPLYID: CAT-EPT-20260415-38`:

  `O_obs^{loc} = O_stable^{loc} + Φ_mod(O_sensitive)`

with `Φ_mod` induced by local restriction composed with modular flow:

  `Φ_{O,s}(X) := E_O(σ_s^ω(X))`
  `Φ_mod(X)  ≈ exp(-τ_ent) · X` (in the reduced-density approximation)
  `τ_ent ↔ K_O / ℏ ↔ S_I / ℏ`

This is the central **new structural primitive** the five-paper
hierarchy chain (Yamasaki 1968, Power II/III/IV, AQFT modular notes)
condenses to.

## Existing infrastructure leveraged (NOT duplicated)

* `RelativeEntropyModularBridge` (PR #84) — modular Hamiltonian `K_O`
  + KMS strip; this module composes on top, doesn't redo it.
* `ImaginaryActionDissipationDictionary.IdentifyEntropicProperTimeWithImaginaryAction`
  — the `τ_ent ↔ S_I / ℏ` identification.
* `YamasakiInternalClockBridge` (PR #82, #83) and
  `QuantumTemporalOrderEnergyCAT` (PR #87) — the
  `Q_diag + e^{-τ_ent}·Re(C_Q · e^{2imτ'})` Yamasaki form is the
  Stage-I instance of the master equation.

## What's genuinely new

* `ReducedModularChannel` carrier — `Φ_{O,s}(X) = exp(-τ_ent)·X`
  at the magnitude level.
* `StableSensitiveObservableSplit` — the master equation
  `O_obs = O_stable + Φ_mod(O_sensitive)` as a `Prop`-level
  identification.

## Honest scope

* Magnitude-level surrogates.  The local Haag-Kastler algebra
  `A(O)` and modular operator `Δ_ω` stay abstract; we expose
  only the real-valued damping factor that consumers can pair
  with their preferred operator-algebra refinement.
* The "restriction `E_O` is a conditional expectation" claim
  is not enforced here; consumers add it via a Phase-2
  refinement when needed.

## What this module ships

* `ModularFlowParameter` — `s : ℝ` parameter for `σ_s^ω`.
* `ReducedModularChannel` — `Φ_s(X) = exp(-τ_ent(s))·X` magnitude-
  level damping with `τ_ent(s) ≥ 0`.
* `Φ_le_one` — the channel's magnitude is bounded by `1`.
* `StableSensitiveObservableSplit` — master equation carrier with
  `O_obs = O_stable + (Φ applied to O_sensitive)`.
* `master_equation_le_unattenuated` — Stable + sensitive without
  damping is an upper bound.
* `reduced_modular_channel_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.ReducedModularChannelCarrier

-- ============================================================================
-- 1. Reduced modular channel
-- ============================================================================

/-- **Reduced modular channel** `Φ_{O,s}` from the AQFT side.

In the reduced-density approximation:

  `Φ_s(X) ≈ exp(-τ_ent(s)) · X`,

with `τ_ent(s) ≥ 0`.  We carry just the real-valued damping factor
`magnitude(s) = exp(-τ_ent(s))` and the underlying `τ_ent(s)`. -/
structure ReducedModularChannel where
  /-- `τ_ent(s) ≥ 0` along the modular-flow parameter `s`. -/
  tauEnt          : ℝ → ℝ
  /-- Non-negativity. -/
  tauEnt_nonneg   : ∀ s, 0 ≤ tauEnt s

namespace ReducedModularChannel

variable (Φ : ReducedModularChannel)

/-- The damping magnitude `exp(-τ_ent(s))` of the channel at `s`. -/
def magnitude (s : ℝ) : ℝ := Real.exp (-(Φ.tauEnt s))

/-- Strict positivity of the magnitude. -/
theorem magnitude_pos (s : ℝ) : 0 < Φ.magnitude s :=
  Real.exp_pos _

/-- The channel magnitude is bounded by `1` (universal damping). -/
theorem magnitude_le_one (s : ℝ) : Φ.magnitude s ≤ 1 := by
  unfold magnitude
  apply Real.exp_le_one_iff.mpr
  linarith [Φ.tauEnt_nonneg s]

/-- At `τ_ent = 0` the channel reduces to identity. -/
theorem magnitude_at_zero (s : ℝ) (h : Φ.tauEnt s = 0) :
    Φ.magnitude s = 1 := by
  unfold magnitude
  rw [h]
  simp [Real.exp_zero]

/-- Trivial existence: identity channel. -/
theorem exists_trivial : ∃ _ : ReducedModularChannel, True :=
  ⟨{ tauEnt        := fun _ => 0
   , tauEnt_nonneg := fun _ => le_refl 0 }, trivial⟩

end ReducedModularChannel

-- ============================================================================
-- 2. Stable / sensitive observable split — the master equation
-- ============================================================================

/-- **Stable / sensitive observable split** — the unification master
equation from REPLYID `CAT-EPT-20260415-38`:

  `O_obs^{loc}(s) = O_stable^{loc} + Φ_s(O_sensitive)`,

i.e. the local observable decomposes into a stable sector that goes
through unmodified and a sensitive sector that picks up the reduced
modular channel's damping.

Magnitude-level carrier:

* `obsStable : ℝ → ℝ` (does not depend on `s`).
* `obsSensitive : ℝ → ℝ` (the pre-channel sensitive magnitude).
* `obsObserved : ℝ → ℝ` (the resulting observable).
* The identification: `obsObserved s = obsStable s + Φ.magnitude s · obsSensitive s`. -/
structure StableSensitiveObservableSplit where
  /-- The reduced modular channel. -/
  Φ                  : ReducedModularChannel
  /-- The stable sector magnitude. -/
  obsStable          : ℝ → ℝ
  /-- The sensitive sector magnitude (pre-channel). -/
  obsSensitive       : ℝ → ℝ
  /-- The observed local observable magnitude (post-channel). -/
  obsObserved        : ℝ → ℝ
  /-- Non-negativity of the stable sector. -/
  obsStable_nonneg   : ∀ s, 0 ≤ obsStable s
  /-- Non-negativity of the sensitive sector. -/
  obsSensitive_nonneg : ∀ s, 0 ≤ obsSensitive s
  /-- The master equation. -/
  master_equation    : ∀ s, obsObserved s = obsStable s + Φ.magnitude s * obsSensitive s

namespace StableSensitiveObservableSplit

variable (M : StableSensitiveObservableSplit)

/-- The observed observable is non-negative. -/
theorem obsObserved_nonneg (s : ℝ) : 0 ≤ M.obsObserved s := by
  rw [M.master_equation s]
  apply add_nonneg (M.obsStable_nonneg s)
  exact mul_nonneg (le_of_lt (M.Φ.magnitude_pos s)) (M.obsSensitive_nonneg s)

/-- **Master equation upper bound:** the observed observable is
bounded by the un-attenuated sum (`stable + sensitive`).

Inherited from `Φ.magnitude s ≤ 1` applied to the sensitive sector. -/
theorem master_equation_le_unattenuated (s : ℝ) :
    M.obsObserved s ≤ M.obsStable s + M.obsSensitive s := by
  rw [M.master_equation s]
  have h : M.Φ.magnitude s * M.obsSensitive s ≤ M.obsSensitive s := by
    calc M.Φ.magnitude s * M.obsSensitive s
        ≤ 1 * M.obsSensitive s :=
          mul_le_mul_of_nonneg_right (M.Φ.magnitude_le_one s) (M.obsSensitive_nonneg s)
      _ = M.obsSensitive s := one_mul _
  linarith

/-- At zero modular-flow time (`τ_ent(s) = 0`), the observed observable
equals the un-attenuated sum.  The damping is trivial. -/
theorem obsObserved_at_no_damping (s : ℝ) (h : M.Φ.tauEnt s = 0) :
    M.obsObserved s = M.obsStable s + M.obsSensitive s := by
  rw [M.master_equation s, M.Φ.magnitude_at_zero s h]
  ring

/-- Trivial existence: zero everything, trivial channel. -/
theorem exists_trivial : ∃ _ : StableSensitiveObservableSplit, True :=
  ⟨{ Φ                   := { tauEnt := fun _ => 0
                            , tauEnt_nonneg := fun _ => le_refl 0 }
   , obsStable           := fun _ => 0
   , obsSensitive        := fun _ => 0
   , obsObserved         := fun _ => 0
   , obsStable_nonneg    := fun _ => le_refl 0
   , obsSensitive_nonneg := fun _ => le_refl 0
   , master_equation     := fun _ => by simp [ReducedModularChannel.magnitude] }, trivial⟩

end StableSensitiveObservableSplit

-- ============================================================================
-- 3. Capstone bundle
-- ============================================================================

/-- **Reduced modular channel + master-equation bundle.**

All structural deliverables for the AQFT/CAT-EPT reduced-channel /
stable-sensitive split hold simultaneously:

* A reduced modular channel exists.
* A stable / sensitive observable split exists with the master
  equation discharged.

This carrier is the substrate the five-paper hierarchy
(Yamasaki / Power II / Power III / Power IV / AQFT modular)
will populate via specialised stage carriers in
`PowerHierarchyCarrier` and `FivePaperUnifiedHierarchy`. -/
theorem reduced_modular_channel_bundle :
    (∃ _ : ReducedModularChannel, True)
    ∧ (∃ _ : StableSensitiveObservableSplit, True) :=
  ⟨ReducedModularChannel.exists_trivial,
   StableSensitiveObservableSplit.exists_trivial⟩

end CATEPTMain.Integration.ReducedModularChannelCarrier

end
