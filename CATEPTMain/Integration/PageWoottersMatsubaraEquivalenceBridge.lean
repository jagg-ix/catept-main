import CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# PageWoottersMatsubaraEquivalenceBridge — equivalence of Page–Wootters
clock-conditional time and Matsubara/Luttinger–Ward thermal action

Carrier-level bridge formalising the equivalence between the
Page–Wootters mechanism (PR ##: `PageWoottersQuantumTimeCarrier`,
quantum-time / clock-conditional Schrödinger evolution) and the
Matsubara/Luttinger–Ward identifications (PR #127:
`MatsubaraLuttingerWardCarrier`, thermal imaginary-action /
entropic-time identifications) at the imaginary-time evaluation point
`t = β · ℏ`.

## Mechanism (Wick rotation linking PW to Matsubara)

The Wick rotation `t ↦ −iβℏ` maps the Page–Wootters Schrödinger phase
**(PW4-eig)** `exp(−i E_S t / ℏ)` to the Matsubara Boltzmann factor
`exp(−β E_S)`.  With the system Hamiltonian eigenvalue `E_S` identified
with the grand-potential density `Ω` of Matsubara/Luttinger–Ward (a
standard identification at the single-mode level — see the
`E_S_eq_Omega` field below), this gives the magnitude correspondence

```
−phaseS · ℏ  =  β · ℏ · E_S  =  β · ℏ · Ω  =  S_I    (Matsubara) -- (PW5)→S_I
```

at the evaluation point `t = β·ℏ`.  The right-most identity is the
proven Matsubara identification `S_I = ℏ · β · Ω`
(`MatsubaraLuttingerWardCarrier.S_I_eq`); the left-most is the proven
Page–Wootters identity **(PW5)** `pageWootters_thermal_eval_identity`.

## Identifications proven

| Source | Statement | Mechanism |
|--|--|--|
| Matsubara `S_I` | `M.S_I = ℏ·β·Ω` | proven (PR #127) |
| Page–Wootters `phaseS` | `pw.phaseS = −E_S·t/ℏ` | proven here (carrier) |
| **Equivalence at thermal point** | `−pw.phaseS · pw.ℏ = M.S_I` | proven via energy-grand-potential consistency |

## What this bridge ships

Composite `PageWoottersMatsubaraEquivalenceBridge` carrier holding:
* a Page–Wootters carrier evaluated at clock reading `t = β · ℏ`,
* a Matsubara/Luttinger–Ward carrier with the same `β` and `ℏ`,
* a single-line consistency hypothesis `pw.E_S = M.Ω` (single-mode
  energy-grand-potential identification).

Five proven equivalence theorems linking Page–Wootters to Matsubara
at the thermal evaluation point.

## Honest scope

* The full operator-side Wick rotation (continuation of the unitary
  evolution `e^{−i H_S t /ℏ}` to imaginary time) requires operator-
  algebra machinery (Logos `TomitaTakesaki`, Fock-space analytic
  continuation). The carrier-level statement here is the magnitude
  identity at the thermal evaluation point only.
* The energy-grand-potential identification `pw.E_S = M.Ω` is a
  Prop hypothesis; consumers discharge it from the underlying physics
  (single-mode reduction, ideal-gas limit, or spectral decomposition
  of `H_S`).
* The Höhn–Smith–Lock trinity (PW ↔ relational-Heisenberg ↔
  deparametrized-Schrödinger) lives at the operator level; its
  carrier-level imprint is the magnitude equivalence shipped here.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.PageWoottersMatsubaraEquivalenceBridge

open CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier

/-- **Equivalence bridge** between Page–Wootters and Matsubara at the
thermal evaluation point `t = β · ℏ`.

Holds:
* a Page–Wootters carrier with clock reading `t = pw_at_thermal_point`,
* a Matsubara/Luttinger–Ward carrier with matching `β` and `ℏ`,
* a thermal-evaluation-point hypothesis `pw.t = M.β · M.ℏ`,
* an `ℏ` consistency hypothesis `pw.ℏ = M.ℏ`,
* an energy-grand-potential consistency hypothesis `pw.E_S = M.Ω`. -/
structure PageWoottersMatsubaraEquivalenceBridge where
  /-- Page–Wootters quantum-time witnesses. -/
  pw                  : PageWoottersCarrier
  /-- Matsubara/Luttinger–Ward witnesses. -/
  matsubara           : MatsubaraLuttingerWardCarrier
  /-- **Thermal evaluation point**: PW clock reading is `β · ℏ`. -/
  t_eq_betaHbar       : pw.t = matsubara.β * matsubara.ℏ
  /-- **ℏ consistency**: same reduced Planck constant. -/
  hbar_eq             : pw.ℏ = matsubara.ℏ
  /-- **Single-mode energy-grand-potential identification**:
      `pw.E_S = M.Ω`. -/
  E_S_eq_Omega        : pw.E_S = matsubara.Ω

namespace PageWoottersMatsubaraEquivalenceBridge

variable (B : PageWoottersMatsubaraEquivalenceBridge)

/-- **Equivalence 1:** Page–Wootters' `−phaseS · ℏ` at the thermal
evaluation point equals `β · ℏ · E_S` (carrier-level Wick-rotation
imprint). Direct consequence of `pageWootters_thermal_eval_identity`. -/
theorem pageWootters_thermal_eval :
    -(B.pw.phaseS) * B.pw.ℏ = B.matsubara.β * B.pw.ℏ * B.pw.E_S := by
  have h := B.pw.pageWootters_thermal_eval_identity B.matsubara.β
  -- Goal needs the hypothesis `pw.t = β · pw.ℏ`. We have `pw.t = β · M.ℏ`
  -- and `pw.ℏ = M.ℏ`.
  have ht : B.pw.t = B.matsubara.β * B.pw.ℏ := by
    rw [B.t_eq_betaHbar, B.hbar_eq]
  exact h ht

/-- **Equivalence 2:** Page–Wootters' `−phaseS · ℏ` at the thermal
evaluation point equals Matsubara's `S_I`.

This is the central magnitude-equivalence theorem: the Page–Wootters
clock-conditional phase, evaluated at the imaginary-time boundary,
recovers the Matsubara/Luttinger–Ward imaginary action. -/
theorem pageWootters_thermal_eq_matsubara_S_I :
    -(B.pw.phaseS) * B.pw.ℏ = B.matsubara.S_I := by
  rw [B.pageWootters_thermal_eval, B.matsubara.S_I_eq, B.E_S_eq_Omega, B.hbar_eq]
  ring

/-- **Equivalence 3:** Page–Wootters' `−phaseS · ℏ` at the thermal
evaluation point equals `−ℏ · ln Z` (Matsubara partition function).

Combines Equivalence 2 with `S_I_eq_hbar_neg_log_Z`. -/
theorem pageWootters_thermal_eq_neg_hbar_log_Z :
    -(B.pw.phaseS) * B.pw.ℏ = -(B.matsubara.ℏ * Real.log B.matsubara.Z) := by
  rw [B.pageWootters_thermal_eq_matsubara_S_I, B.matsubara.S_I_eq_hbar_neg_log_Z]

/-- **Equivalence 4:** Page–Wootters' clock-conditional phase, evaluated
at the imaginary-time boundary, equals (up to sign and ℏ) Matsubara's
entropic time `τ_ent = β · Ω`. -/
theorem pageWootters_phaseS_eq_neg_tauEnt :
    -(B.pw.phaseS) * B.pw.ℏ = B.matsubara.ℏ * B.matsubara.τ_ent := by
  rw [B.pageWootters_thermal_eval, B.matsubara.τ_ent_eq, B.E_S_eq_Omega, B.hbar_eq]
  ring

/-- **Equivalence 5:** zero phase ↔ unit partition function.

`pw.phaseS = 0 ↔ M.Z = 1` at the thermal evaluation point. The
forward direction uses `phaseS = 0 ⇒ S_I = 0 ⇒ ln Z = 0 ⇒ Z = 1`;
reverse direction uses the analogous Matsubara dichotomy
(`Z = 1 ↔ τ_ent = 0`). -/
theorem pageWootters_phaseS_zero_iff_Z_one :
    B.pw.phaseS = 0 ↔ B.matsubara.Z = 1 := by
  constructor
  · intro hphi
    -- pw.phaseS = 0  ⇒  -phaseS · ℏ = 0  ⇒  S_I = 0  ⇒  ln Z = 0  ⇒  Z = 1
    have hSI : B.matsubara.S_I = 0 := by
      have h := B.pageWootters_thermal_eq_matsubara_S_I
      rw [hphi] at h
      linarith
    -- S_I = ℏ · β · Ω, ℏ > 0, β > 0 ⇒ Ω = 0 ⇒ Z = exp 0 = 1
    have hOmega : B.matsubara.Ω = 0 := by
      have hSeq := B.matsubara.S_I_eq
      rw [hSI] at hSeq
      have hℏne : B.matsubara.ℏ ≠ 0 := ne_of_gt B.matsubara.ℏ_pos
      have hβne : B.matsubara.β ≠ 0 := ne_of_gt B.matsubara.β_pos
      have : B.matsubara.ℏ * B.matsubara.β * B.matsubara.Ω = 0 := hSeq.symm
      have hprod : B.matsubara.ℏ * B.matsubara.β ≠ 0 := mul_ne_zero hℏne hβne
      exact (mul_eq_zero.mp this).resolve_left hprod
    rw [B.matsubara.Z_eq_exp, hOmega]
    simp
  · intro hZ
    -- Z = 1 ⇒ Ω = 0 ⇒ pw.E_S = 0 ⇒ pw.phaseS = -E_S·t/ℏ = 0
    have hOmega : B.matsubara.Ω = 0 := by
      have hZeq := B.matsubara.Z_eq_exp
      rw [hZ] at hZeq
      -- 1 = exp(-(β · Ω))  ⇒  -(β · Ω) = 0  ⇒  Ω = 0
      have hexp : Real.exp (-(B.matsubara.β * B.matsubara.Ω)) = 1 := hZeq.symm
      have hzero : -(B.matsubara.β * B.matsubara.Ω) = 0 := by
        have := congrArg Real.log hexp
        rw [Real.log_exp, Real.log_one] at this
        exact this
      have hβne : B.matsubara.β ≠ 0 := ne_of_gt B.matsubara.β_pos
      have hbO : B.matsubara.β * B.matsubara.Ω = 0 := by linarith
      exact (mul_eq_zero.mp hbO).resolve_left hβne
    have hES : B.pw.E_S = 0 := by rw [B.E_S_eq_Omega, hOmega]
    rw [B.pw.phaseS_eq, hES]
    ring

/-- **Trivial existence.** A degenerate witness with `β = ℏ = 1`,
`Ω = E_S = 0`, `t = 1`, `phaseS = 0`, `Z = 1`, `S_I = τ_ent = 0`.
The thermal-evaluation, ℏ-consistency, and energy-grand-potential
hypotheses all hold by construction. -/
theorem exists_trivial : ∃ _ : PageWoottersMatsubaraEquivalenceBridge, True := by
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
  let pw : PageWoottersCarrier :=
    { t              := 1
    , ℏ              := 1
    , E_S            := 0
    , E_C            := 0
    , tauPW          := 1
    , phaseS         := 0
    , ℏ_pos          := by norm_num
    , WDW_constraint := by ring
    , tauPW_eq       := by ring
    , phaseS_eq      := by ring }
  refine ⟨{ pw                  := pw
          , matsubara           := M
          , t_eq_betaHbar       := by show (1 : ℝ) = 1 * 1; ring
          , hbar_eq             := by show (1 : ℝ) = 1; rfl
          , E_S_eq_Omega        := by show (0 : ℝ) = 0; rfl }, trivial⟩

end PageWoottersMatsubaraEquivalenceBridge

/-! ## Capstone -/

/-- **Page–Wootters / Matsubara equivalence bundle.** -/
theorem pageWootters_matsubara_equivalence_bundle :
    ∃ _ : PageWoottersMatsubaraEquivalenceBridge, True :=
  PageWoottersMatsubaraEquivalenceBridge.exists_trivial

end CATEPTMain.Integration.PageWoottersMatsubaraEquivalenceBridge

end
