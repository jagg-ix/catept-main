import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# MatsubaraLuttingerWardCarrier — non-speculative CAT/EPT foundation from Matsubara–Luttinger–Ward

Carrier-level slice grounding the CAT/EPT imaginary-action and
entropic-proper-time identifications in the standard finite-temperature
many-body QFT formalism (intake `docs/intake/matsubara-si.md`, REPLYID
20260129-00129; Welden et al. 2016).

## Core identifications (verbatim from the intake)

| CAT/EPT object        | Matsubara / Luttinger–Ward expression  |
|-----------------------|----------------------------------------|
| `S_I` (imaginary action) | `ℏ · β · Ω[G]  =  ℏ · Φ[G]`         |
| `τ_ent` (entropic proper time) | `β · Ω  =  −ln Z`             |
| `Z`  (partition function) | `exp(−β · Ω)`                       |
| `Σ`  (self-energy)        | `δS_I / δG`                         |
| Dyson equation            | `G⁻¹  =  G₀⁻¹  −  Σ`                |

The intake explicitly states (§9 final synthesis): *"Imaginary action =
Luttinger–Ward / thermodynamic functional; entropic time =
thermodynamic accumulation (free-energy scale); dynamics = variational
response of this functional."*  These are **non-speculative**
identifications grounded in standard QFT.

## Carrier scope

Magnitude-level real-valued surrogates `(β, ℏ, Ω, Z, S_I, τ_ent)`.
The operator-side primitives (`G`, `Σ`, the Dyson equation, the
Luttinger–Ward functional `Φ[G]`) stay abstract; we expose only the
real-arithmetic identifications proved at the carrier level.

## What this module ships

* `MatsubaraLuttingerWardCarrier` — bundle of real witnesses with
  positivity invariants and the partition-function identity
  `Z = exp(−β·Ω)`.
* `tauEnt_eq_beta_Omega` — extraction.
* `tauEnt_eq_neg_log_Z` — proven: `τ_ent = −ln Z`.
* `S_I_eq_hbar_tauEnt` — proven: `S_I = ℏ · τ_ent`.
* `S_I_eq_hbar_neg_log_Z` — proven: `S_I = −ℏ · ln Z`.
* `Z_pos` — proven: `Z > 0` (consequence of `exp` positivity).
* `tauEnt_pos_iff_Z_lt_one` — proven dichotomy at `β·Ω > 0`.
* `exists_trivial` and capstone bundle.

## Honest scope

* Operator-G, Σ, and the Luttinger–Ward functional `Φ[G]` are not
  defined here — they require operator-algebra machinery beyond the
  carrier scope.  Their identification with `S_I/ℏ` is documented at
  the docstring level only.
* The Dyson equation `G⁻¹ = G₀⁻¹ − Σ` is similarly stated in the
  docstring; the carrier-level proof is operator-free.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.MatsubaraLuttingerWardCarrier

/-- **Matsubara–Luttinger–Ward CAT/EPT carrier.**

Holds the magnitude-level data for the standard-QFT grounding of
CAT/EPT's imaginary action and entropic proper time:

* `β`  — inverse temperature `> 0`
* `ℏ`  — reduced Planck constant `> 0`
* `Ω`  — grand potential (real, sign unconstrained)
* `Z`  — partition function `= exp(−β · Ω)` (forced by the field
       `Z_eq_exp`)
* `S_I` — imaginary action `= ℏ · β · Ω`
* `τ_ent` — entropic proper time `= β · Ω`
-/
structure MatsubaraLuttingerWardCarrier where
  /-- Inverse temperature. -/
  β        : ℝ
  /-- Reduced Planck constant. -/
  ℏ        : ℝ
  /-- Grand potential. -/
  Ω        : ℝ
  /-- Partition function. -/
  Z        : ℝ
  /-- Imaginary action. -/
  S_I      : ℝ
  /-- Entropic proper time. -/
  τ_ent    : ℝ
  /-- Strict positivity of `β`. -/
  β_pos    : 0 < β
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos    : 0 < ℏ
  /-- **Partition-function identity**: `Z = exp(−β · Ω)`. -/
  Z_eq_exp : Z = Real.exp (-(β * Ω))
  /-- **Entropic-time identification**: `τ_ent = β · Ω`. -/
  τ_ent_eq : τ_ent = β * Ω
  /-- **Imaginary-action identification**: `S_I = ℏ · β · Ω`. -/
  S_I_eq   : S_I = ℏ * β * Ω

namespace MatsubaraLuttingerWardCarrier

variable (M : MatsubaraLuttingerWardCarrier)

/-- **Extraction:** entropic time equals `β · Ω`. -/
theorem tauEnt_eq_beta_Omega : M.τ_ent = M.β * M.Ω := M.τ_ent_eq

/-- **Proven:** the partition function is strictly positive
(consequence of `exp > 0`). -/
theorem Z_pos : 0 < M.Z := by
  rw [M.Z_eq_exp]
  exact Real.exp_pos _

/-- **Proven:** `S_I = ℏ · τ_ent`. -/
theorem S_I_eq_hbar_tauEnt : M.S_I = M.ℏ * M.τ_ent := by
  rw [M.S_I_eq, M.τ_ent_eq]
  ring

/-- **Proven:** `τ_ent = − ln Z`.

The intake's central identification: entropic time is the negative
log-partition function. -/
theorem tauEnt_eq_neg_log_Z : M.τ_ent = - Real.log M.Z := by
  rw [M.τ_ent_eq, M.Z_eq_exp, Real.log_exp]
  ring

/-- **Proven:** `S_I = − ℏ · ln Z`. -/
theorem S_I_eq_hbar_neg_log_Z : M.S_I = -(M.ℏ * Real.log M.Z) := by
  rw [M.S_I_eq_hbar_tauEnt, M.tauEnt_eq_neg_log_Z]
  ring

/-- **Proven dichotomy:** `τ_ent > 0 ↔ Z < 1`.

`τ_ent = − ln Z` and `Z > 0`, so `τ_ent > 0 ↔ ln Z < 0 ↔ Z < 1`. -/
theorem tauEnt_pos_iff_Z_lt_one : 0 < M.τ_ent ↔ M.Z < 1 := by
  rw [M.tauEnt_eq_neg_log_Z]
  constructor
  · intro h
    have hlog : Real.log M.Z < 0 := by linarith
    have hZpos : 0 < M.Z := M.Z_pos
    exact (Real.log_neg_iff hZpos).mp hlog
  · intro h
    have hZpos : 0 < M.Z := M.Z_pos
    have hlog : Real.log M.Z < 0 := (Real.log_neg_iff hZpos).mpr h
    linarith

/-- **Proven dichotomy:** `τ_ent < 0 ↔ Z > 1`. -/
theorem tauEnt_neg_iff_Z_gt_one : M.τ_ent < 0 ↔ 1 < M.Z := by
  rw [M.tauEnt_eq_neg_log_Z]
  constructor
  · intro h
    have hlog : 0 < Real.log M.Z := by linarith
    have hZpos : 0 < M.Z := M.Z_pos
    exact (Real.log_pos_iff (le_of_lt hZpos)).mp hlog
  · intro h
    have hZpos : 0 < M.Z := M.Z_pos
    have hlog : 0 < Real.log M.Z := Real.log_pos h
    linarith

/-- **Trivial existence:** `β = ℏ = 1`, `Ω = 0`, hence `Z = 1`,
`S_I = τ_ent = 0`. -/
theorem exists_trivial : ∃ _ : MatsubaraLuttingerWardCarrier, True := by
  refine ⟨{ β        := 1
          , ℏ        := 1
          , Ω        := 0
          , Z        := 1
          , S_I      := 0
          , τ_ent    := 0
          , β_pos    := by norm_num
          , ℏ_pos    := by norm_num
          , Z_eq_exp := by simp
          , τ_ent_eq := by ring
          , S_I_eq   := by ring }, trivial⟩

end MatsubaraLuttingerWardCarrier

/-! ## Capstone -/

/-- **Matsubara–Luttinger–Ward CAT/EPT bundle.** -/
theorem matsubara_luttinger_ward_bundle :
    ∃ _ : MatsubaraLuttingerWardCarrier, True :=
  MatsubaraLuttingerWardCarrier.exists_trivial

end CATEPTMain.Integration.MatsubaraLuttingerWardCarrier

end
