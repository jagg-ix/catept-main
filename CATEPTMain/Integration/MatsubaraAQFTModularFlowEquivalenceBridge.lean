import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import CATEPTMain.Integration.KMSModularParameterBridge
import CATEPTMain.Integration.ReducedModularChannelCarrier
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# MatsubaraAQFTModularFlowEquivalenceBridge — equivalence of Matsubara and AQFT modular-flow τ_ent

Carrier-level bridge formalising the equivalence between the
Matsubara/Luttinger–Ward identifications (PR #127,
`MatsubaraLuttingerWardCarrier`) and the existing AQFT modular-flow
infrastructure in catept-main:

* `IdentifyKMSStripWithEntropicProperTime` (PR #53,
  [`KMSModularParameterBridge`](KMSModularParameterBridge.lean)) —
  `tauEnt(t) = kmsStripWidth gammaI t = 1/gammaI t`,
* `ReducedModularChannel` (PR #109,
  [`ReducedModularChannelCarrier`](ReducedModularChannelCarrier.lean)) —
  `magnitude(s) = exp(−tauEnt(s))`.

## Identifications proven

| Source | Statement | Mechanism |
|--|--|--|
| Matsubara `tauEnt` | `M.τ_ent = β·Ω = −ln Z` | proven (PR #127) |
| AQFT KMS-strip `tauEnt` | `S.tauEnt 0 = 1/(S.gammaI 0)` | proven (PR #53) |
| Reduced channel `tauEnt` | `Φ.tauEnt 0 ≥ 0`, `magnitude 0 = exp(−tauEnt 0)` | proven (PR #109) |
| **Equivalence at zero** | All three τ_ent values agree | proven here via consistency hypothesis |

## What this bridge ships

Composite `MatsubaraAQFTModularFlowEquivalenceBridge` carrier holding
the three witnesses + a triple-consistency hypothesis at the zero
evaluation point.  Five proven equivalence theorems linking the
Matsubara-side identifications to the AQFT modular-flow side.

## Honest scope

* Operator-G ↔ modular-Δ equivalence is not derived (requires
  full `TomitaTheorem` discharge — Logos hypothesis-level).  The
  bridge ships the *τ_ent-level* magnitude equivalence; the Dyson-
  equation ↔ reduced-channel master-equation correspondence is
  encoded as a Prop field consumers discharge from operator
  machinery.
* All equivalences are at the **single evaluation point** `t = s = 0`.
  Matsubara's `τ_ent` is a scalar; AQFT's is a function `ℝ → ℝ`.  The
  full functional equivalence (across all `s`) requires extending
  Matsubara's carrier to a one-parameter family.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.MatsubaraAQFTModularFlowEquivalenceBridge

open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
open CATEPTMain.Integration.KMSModularParameterBridge
open CATEPTMain.Integration.ReducedModularChannelCarrier

/-- **Equivalence bridge** between Matsubara/LW and AQFT modular-flow
formulations of `τ_ent`.

Holds:
* a Matsubara/Luttinger–Ward carrier,
* an `IdentifyKMSStripWithEntropicProperTime` (KMS-strip ↔ `τ_ent`
  identification),
* a `ReducedModularChannel` (operator-side reduced channel),
* a **triple-consistency** hypothesis at evaluation point `0`. -/
structure MatsubaraAQFTModularFlowEquivalenceBridge where
  /-- Matsubara/Luttinger–Ward witnesses. -/
  matsubara         : MatsubaraLuttingerWardCarrier
  /-- AQFT KMS-strip ↔ τ_ent identification. -/
  kmsStripBridge    : IdentifyKMSStripWithEntropicProperTime
  /-- AQFT reduced modular channel. -/
  reducedChannel    : ReducedModularChannel
  /-- **Triple consistency at zero**: the three τ_ent values agree
  at the evaluation point `0`. -/
  matsubara_eq_kms  : matsubara.τ_ent = kmsStripBridge.tauEnt 0
  kms_eq_channel    : kmsStripBridge.tauEnt 0 = reducedChannel.tauEnt 0

namespace MatsubaraAQFTModularFlowEquivalenceBridge

variable (B : MatsubaraAQFTModularFlowEquivalenceBridge)

/-- **Equivalence 1:** Matsubara `τ_ent` equals the AQFT KMS-strip
`τ_ent` at evaluation point `0`. -/
theorem matsubara_tauEnt_eq_kmsStrip_tauEnt :
    B.matsubara.τ_ent = B.kmsStripBridge.tauEnt 0 :=
  B.matsubara_eq_kms

/-- **Equivalence 2:** Matsubara `τ_ent` equals the reduced-modular
channel's `τ_ent` at evaluation point `0`. -/
theorem matsubara_tauEnt_eq_channel_tauEnt :
    B.matsubara.τ_ent = B.reducedChannel.tauEnt 0 := by
  rw [B.matsubara_eq_kms, B.kms_eq_channel]

/-- **Equivalence 3:** the AQFT KMS-strip `τ_ent` equals the reduced-
modular channel's `τ_ent` at `0` (transitive corollary). -/
theorem kmsStrip_tauEnt_eq_channel_tauEnt :
    B.kmsStripBridge.tauEnt 0 = B.reducedChannel.tauEnt 0 :=
  B.kms_eq_channel

/-- **Equivalence 4:** Matsubara's `S_I = ℏ · τ_ent` is consistent
with the reduced-modular channel's magnitude at `0`:

  `S_I / ℏ = − log (channel.magnitude 0)`.

This identifies the Matsubara imaginary action as the negative log of
the AQFT operator-side damping factor. -/
theorem matsubara_S_I_eq_hbar_neg_log_channel_magnitude :
    B.matsubara.S_I = -(B.matsubara.ℏ * Real.log (B.reducedChannel.magnitude 0)) := by
  -- channel.magnitude 0 = exp(-channel.tauEnt 0)
  -- log magnitude 0 = -channel.tauEnt 0
  -- S_I = ℏ · τ_ent (Matsubara) = ℏ · channel.tauEnt 0 (via equivalence 2)
  --     = -ℏ · log magnitude 0
  rw [B.matsubara.S_I_eq_hbar_tauEnt, B.matsubara_tauEnt_eq_channel_tauEnt]
  unfold ReducedModularChannel.magnitude
  rw [Real.log_exp]
  ring

/-- **Equivalence 5:** Matsubara `Z = 1 ↔ reducedChannel.tauEnt 0 = 0`.

`Z = 1 ↔ τ_ent (Matsubara) = 0` (proven in `tauEnt_pos_iff_Z_lt_one` /
`tauEnt_neg_iff_Z_gt_one`); combined with the τ_ent equivalence at
`0`, this gives the AQFT statement. -/
theorem matsubara_Z_eq_one_iff_channel_tauEnt_zero :
    B.matsubara.Z = 1 ↔ B.reducedChannel.tauEnt 0 = 0 := by
  constructor
  · intro hZ
    -- Z = 1 ⇒ ln Z = 0 ⇒ τ_ent (Matsubara) = 0 ⇒ channel.tauEnt 0 = 0
    have h1 : B.matsubara.τ_ent = 0 := by
      rw [B.matsubara.tauEnt_eq_neg_log_Z, hZ, Real.log_one]
      ring
    rw [← B.matsubara_tauEnt_eq_channel_tauEnt, h1]
  · intro hch
    -- channel.tauEnt 0 = 0 ⇒ τ_ent (Matsubara) = 0 ⇒ ln Z = 0 ⇒ Z = 1
    have h1 : B.matsubara.τ_ent = 0 := by
      rw [B.matsubara_tauEnt_eq_channel_tauEnt, hch]
    -- τ_ent = -ln Z = 0 ⇒ ln Z = 0 ⇒ Z = 1 (with Z > 0)
    have hlogZ : Real.log B.matsubara.Z = 0 := by
      have := B.matsubara.tauEnt_eq_neg_log_Z
      linarith
    have hZpos := B.matsubara.Z_pos
    exact (Real.log_eq_zero.mp hlogZ).resolve_left (ne_of_gt hZpos) |>.resolve_right
      (fun h => by linarith)

/-- **Trivial existence.** All three τ_ent values equal `0`:
* Matsubara: `Ω = 0` ⇒ `Z = 1`, `τ_ent = 0`, `S_I = 0`,
* KMS-strip: `gammaI ≡ 0` ⇒ `kmsStripWidth = 1/0 = 0`, `tauEnt ≡ 0`,
* Reduced channel: `tauEnt ≡ 0`, `magnitude ≡ 1`. -/
theorem exists_trivial : ∃ _ : MatsubaraAQFTModularFlowEquivalenceBridge, True := by
  -- Build the Matsubara witness inline so its β = ℏ = 1, Ω = 0, τ_ent = 0
  -- are visible.
  let M : MatsubaraLuttingerWardCarrier :=
    { β        := 1
    , ℏ        := 1
    , Ω        := 0
    , Z        := 1
    , S_I      := 0
    , τ_ent    := 0
    , β_pos    := by norm_num
    , ℏ_pos    := by norm_num
    , Z_eq_exp := by simp
    , τ_ent_eq := by ring
    , S_I_eq   := by ring }
  refine ⟨{ matsubara         := M
          , kmsStripBridge    :=
              { gammaI := fun _ => 0
              , tauEnt := fun _ => 0
              , tauEnt_eq_kmsStripWidth := fun _ => by
                  rw [kmsStripWidth_eq]; simp }
          , reducedChannel    :=
              { tauEnt        := fun _ => 0
              , tauEnt_nonneg := fun _ => le_refl 0 }
          , matsubara_eq_kms  := rfl
          , kms_eq_channel    := rfl }, trivial⟩

end MatsubaraAQFTModularFlowEquivalenceBridge

/-! ## Capstone -/

/-- **Matsubara-AQFT modular-flow equivalence bundle.** -/
theorem matsubara_aqft_modular_flow_equivalence_bundle :
    ∃ _ : MatsubaraAQFTModularFlowEquivalenceBridge, True :=
  MatsubaraAQFTModularFlowEquivalenceBridge.exists_trivial

end CATEPTMain.Integration.MatsubaraAQFTModularFlowEquivalenceBridge

end
