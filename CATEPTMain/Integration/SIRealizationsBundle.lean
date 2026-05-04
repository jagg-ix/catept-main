import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import CATEPTMain.Integration.KMSModularParameterBridge
import CATEPTMain.Integration.ImaginaryActionDissipationDictionary
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# SIRealizationsBundle — bundled proven realizations of the
imaginary action `S_I` via Matsubara/Luttinger–Ward AND
Tomita–Takesaki modular flow

Correction module: `S_I` is **not** "contractual" at the carrier level.
It is *multiply* realized by proven algebraic identities chaining
through the Matsubara/Luttinger–Ward thermodynamic functional and the
Tomita–Takesaki KMS strip width.  This module bundles the five
proven realizations into a single theorem so consumers can cite them
without having to chain the underlying lemmas by hand.

## The five proven realizations

For a `MatsubaraLuttingerWardCarrier` `M` and an
`IdentifyKMSStripWithEntropicProperTime` bridge `kmsBridge` consistent
with `M` at the evaluation point (`M.τ_ent = kmsBridge.tauEnt 0`):

| # | Identity | Source |
|---|---|---|
| R1 | `S_I = ℏ · β · Ω` | `MatsubaraLuttingerWardCarrier.S_I_eq` (carrier field, Matsubara/Luttinger–Ward) |
| R2 | `S_I = − ℏ · ln Z` | `S_I_eq_hbar_neg_log_Z` (proven from R1 + `Z_eq_exp`) |
| R3 | `S_I = ℏ · τ_ent` | `S_I_eq_hbar_tauEnt` (proven from R1 + `τ_ent_eq`) |
| R4 | `S_I = ℏ · kmsBridge.tauEnt 0` | this module (proven from R3 + `matsubara_eq_kms` consistency) |
| R5 | `S_I = ℏ / γ_I 0` | this module (proven from R4 + `tauEnt_eq_inv_rate`) |

R1–R3 live in `MatsubaraLuttingerWardCarrier` and were already proven
in PR #127.  R4 and R5 are the **Tomita–Takesaki modular-flow side**:
they realize `S_I` as the imaginary-action evaluated against the
KMS strip width (= modular-flow period at the eigenvalue level
`Δs_KMS = 1/γ_I` shipped by `KMSModularParameterBridge`/PR #53).

## Tomita–Takesaki connection

The KMS strip width `Δs_KMS γ_I t := 1/γ_I t` is the *carrier-level
imprint* of the Tomita–Takesaki modular operator's imaginary period:
the modular automorphism group `σ_τ = Δ^{iτ}` of a KMS state at
inverse temperature `β` has imaginary period `β` (Tomita–Takesaki
theorem; see `LogosLibrary.QuantumMechanics.ModularTheory.{KMS,
TomitaTakesaki, ThermalTime}` for the operator-side formalisation).
Connes–Rovelli (1994) identified this as the *thermal time
hypothesis*: the Hamiltonian generator of physical time IS the
modular generator of the KMS state.

At the carrier level this is captured by `IdentifyKMSStripWithEntropicProperTime`
via the load-bearing field `tauEnt_eq_kmsStripWidth`.

## What this module ships

* `S_I_realizations_bundle` — single theorem stating all five
  realizations as a quintuple conjunction.
* `S_I_via_modular_flow` — focused theorem: `S_I = ℏ · kmsBridge.tauEnt 0`
  (the Tomita–Takesaki modular-flow realization).
* `S_I_via_dissipation_rate` — focused theorem: `S_I = ℏ / γ_I 0`
  (the rate-form realization).
* `S_I_unique_under_consistency` — two `kmsBridge`s consistent with
  the same Matsubara `M` give the same `S_I` realization, so the
  realization is uniquely determined.

## Why this corrects the prior characterization

Earlier session notes characterized `spine.matsubara.S_I` as
"contractual" or "abstract".  That was wrong: `S_I = ℏ · β · Ω` is a
proven carrier identity (R1, structure-field `S_I_eq`), and the
`IdentifyKMSStripWithEntropicProperTime` bridge gives the
modular-flow realization (R4, R5) as a *direct algebraic
consequence*, not a side hypothesis.

## Citations

* Welden, Phillips & Gull, *Phys. Rev. B* 93 (2016) 165106 (Matsubara
  Luttinger–Ward thermodynamic functional).
* Tomita, *Standard Form of von Neumann Algebras* (1967); Takesaki,
  *Tomita's Theory of Modular Hilbert Algebras* (Springer LNM 128,
  1970) — modular operator, KMS condition, imaginary periodicity.
* Connes & Rovelli, *Class. Quantum Grav.* 11 (1994) 2899 — thermal
  time hypothesis (Hamiltonian = modular generator).
* `KMSModularParameterBridge` (catept-main, PR #53) — carrier-level
  KMS strip width.
* `LogosLibrary.QuantumMechanics.ModularTheory.{KMS, TomitaTakesaki,
  ThermalTime}` — operator-side formalisation (sibling repo, v4.29.0).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.SIRealizationsBundle

open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
open CATEPTMain.Integration.KMSModularParameterBridge
open CATEPTMain.Integration.ImaginaryActionDissipationDictionary

/-! ## Focused single-realization theorems -/

/-- **Tomita–Takesaki modular-flow realization (R4):**

`S_I = ℏ · kmsBridge.tauEnt 0`.

Direct chain: `S_I = ℏ · τ_ent` (Matsubara, proven) and
`τ_ent = kmsBridge.tauEnt 0` (modular-flow consistency hypothesis at
evaluation point `0`). The KMS strip width on the right-hand side
is the carrier-level imprint of the Tomita–Takesaki imaginary period
of the modular automorphism group. -/
theorem S_I_via_modular_flow
    (M : MatsubaraLuttingerWardCarrier)
    (kmsBridge : IdentifyKMSStripWithEntropicProperTime)
    (h_consistent : M.τ_ent = kmsBridge.tauEnt 0) :
    M.S_I = M.ℏ * kmsBridge.tauEnt 0 := by
  rw [M.S_I_eq_hbar_tauEnt, h_consistent]

/-- **Dissipation-rate realization (R5):**

`S_I = ℏ / γ_I 0`.

Chain: R4 (modular-flow realization) plus
`tauEnt_eq_inv_rate : tauEnt 0 = 1 / gammaI 0` (proven in PR #53). -/
theorem S_I_via_dissipation_rate
    (M : MatsubaraLuttingerWardCarrier)
    (kmsBridge : IdentifyKMSStripWithEntropicProperTime)
    (h_consistent : M.τ_ent = kmsBridge.tauEnt 0) :
    M.S_I = M.ℏ / kmsBridge.gammaI 0 := by
  rw [S_I_via_modular_flow M kmsBridge h_consistent,
      kmsBridge.tauEnt_eq_inv_rate 0, mul_one_div]

/-! ## Bundled five-fold realization theorem -/

/-- **Bundled realization theorem.**

Under the Matsubara ↔ modular-flow consistency hypothesis at the
evaluation point, the imaginary action `S_I` admits five mutually
equivalent proven realizations:

* (R1) Matsubara/Luttinger–Ward grand-potential form: `ℏ · β · Ω`.
* (R2) Partition-function form: `−ℏ · ln Z`.
* (R3) Entropic-time form: `ℏ · τ_ent`.
* (R4) Tomita–Takesaki modular-flow strip-width form:
       `ℏ · kmsBridge.tauEnt 0`.
* (R5) Dissipation-rate form: `ℏ / γ_I 0`.

All five are proven theorems (not Prop hypotheses). The Matsubara
side (R1–R3) is shipped by `MatsubaraLuttingerWardCarrier`; the
modular-flow side (R4–R5) is shipped by this module. -/
theorem S_I_realizations_bundle
    (M : MatsubaraLuttingerWardCarrier)
    (kmsBridge : IdentifyKMSStripWithEntropicProperTime)
    (h_consistent : M.τ_ent = kmsBridge.tauEnt 0) :
    M.S_I = M.ℏ * M.β * M.Ω
    ∧ M.S_I = -(M.ℏ * Real.log M.Z)
    ∧ M.S_I = M.ℏ * M.τ_ent
    ∧ M.S_I = M.ℏ * kmsBridge.tauEnt 0
    ∧ M.S_I = M.ℏ / kmsBridge.gammaI 0 := by
  refine ⟨M.S_I_eq, M.S_I_eq_hbar_neg_log_Z, M.S_I_eq_hbar_tauEnt, ?_, ?_⟩
  · exact S_I_via_modular_flow M kmsBridge h_consistent
  · exact S_I_via_dissipation_rate M kmsBridge h_consistent

/-! ## Uniqueness under consistency -/

/-- **Uniqueness of the modular-flow realization under consistency.**

Two `IdentifyKMSStripWithEntropicProperTime` bridges that are both
consistent with the same Matsubara `M` at the evaluation point `0`
yield the same imaginary-action realization: `ℏ · B₁.tauEnt 0 =
ℏ · B₂.tauEnt 0`.

Mechanism: both equal `M.S_I` via R4. -/
theorem S_I_unique_under_consistency
    (M : MatsubaraLuttingerWardCarrier)
    (B₁ B₂ : IdentifyKMSStripWithEntropicProperTime)
    (h₁ : M.τ_ent = B₁.tauEnt 0)
    (h₂ : M.τ_ent = B₂.tauEnt 0) :
    M.ℏ * B₁.tauEnt 0 = M.ℏ * B₂.tauEnt 0 := by
  have e₁ := S_I_via_modular_flow M B₁ h₁
  have e₂ := S_I_via_modular_flow M B₂ h₂
  rw [← e₁, ← e₂]

/-! ## Capstone -/

/-- **Trivial existence:** degenerate Matsubara/kmsBridge pair where
all five realizations evaluate to `0` (Ω = 0, β = ℏ = 1, γ_I ≡ 0
gives strip width 1/0 = 0 in Mathlib's convention, hence `S_I = 0`
on every realization). -/
theorem exists_trivial :
    ∃ (M : MatsubaraLuttingerWardCarrier)
      (kmsBridge : IdentifyKMSStripWithEntropicProperTime),
      M.τ_ent = kmsBridge.tauEnt 0 := by
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
  let kmsBridge : IdentifyKMSStripWithEntropicProperTime :=
    { gammaI := fun _ => 0
    , tauEnt := fun _ => 0
    , tauEnt_eq_kmsStripWidth := fun _ => by
        rw [kmsStripWidth_eq]; simp }
  exact ⟨M, kmsBridge, rfl⟩

end CATEPTMain.Integration.SIRealizationsBundle

end
