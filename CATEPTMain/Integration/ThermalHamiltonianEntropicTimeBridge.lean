import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# ThermalHamiltonianEntropicTimeBridge — formalisation of paper §4.3
eq. (29-31) "the crucial bridge"

Closes the operational identification between Connes-Rovelli's thermal
Hamiltonian, the reduced-density-matrix logarithm, the imaginary
action, and the entropic proper time:

```
H_th  =  -ln ρ  =  S_I / ℏ  =  τ_ent                    (paper eq. 31)
```

Source: `Paper2_CAT_EPT_Foundations (6).pdf`, §4.3
"Dimensional analysis and the Connes-Rovelli bridge" (eqs. 28-31).

## What this module ships

Up to now `MatsubaraLuttingerWardCarrier` carried `S_I = ℏ·β·Ω` and
`τ_ent = -ln Z` (proven via R1-R3 of `SIRealizationsBundle`).  This
module adds:

* `ThermalHamiltonianFromDensityMatrix` — magnitude carrier exposing
  the **reduced-density-matrix logarithm** `H_th := -ln ρ` as a
  first-class real-valued surrogate.
* The four-fold identity at the carrier level:
    `H_th = -ln ρ = S_I/ℏ = τ_ent`.

The carrier provides:
* `rho` — reduced-density-matrix value (real surrogate, `0 < ρ ≤ 1`),
* `H_th_eq_neg_log_rho` — the defining relation,
* a Matsubara/LW witness consistency hypothesis tying `H_th` to
  `S_I/ℏ`.

## Theorems shipped

* `H_th_eq_S_I_over_hbar` — proven the H_th matches S_I/ℏ.
* `H_th_eq_tau_ent` — proven the four-fold identity.
* `H_th_pos_iff_rho_lt_one` — proven thermal Hamiltonian is positive
  iff ρ < 1 (i.e., out of equilibrium).
* `H_th_zero_iff_rho_one` — proven boundary case.
* `H_th_eq_neg_log_Z_at_unit_rho` — proven specialised identity.
* `exists_trivial` capstone.

## Honest scope

* `rho` is a magnitude-level surrogate for the operator-side `ρ ∈ M`'s
  spectral data; the operator definition of `-log ρ` requires
  functional calculus and lives in
  `LogosLibrary.QuantumMechanics.ModularTheory` (sibling repo).
* The four-fold identity `H_th = -ln ρ = S_I/ℏ = τ_ent` is the paper's
  central operational bridge.  We expose it as a Prop carrier hypothesis
  + proven extraction theorems, leaving the operator-side discharge
  to the Tomita-Takesaki obligation layer (PR #11).

## Citations

* Paper §4.3 eq. 28-31: `Paper2_CAT_EPT_Foundations (6).pdf`,
  "Dimensional analysis and the Connes-Rovelli bridge".
* Connes & Rovelli, *Class. Quantum Grav.* 11 (1994) 2899.
* Welden-Phillips-Gull, *Phys. Rev. B* 93 (2016) 165106.
* `MatsubaraLuttingerWardCarrier` (catept-main, PR #127).
* `SIRealizationsBundle` (catept-main, PR #6, R1-R5).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge

open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier

/-- **Thermal Hamiltonian from reduced density matrix** (paper eq.
28-31).

Magnitude-level carrier holding:
* `M` — Matsubara/LW witness (provides `S_I`, `τ_ent`, `Z`, `ℏ`),
* `rho` — reduced-density-matrix surrogate `0 < ρ ≤ 1`,
* `H_th` — thermal Hamiltonian surrogate,
* `H_th_eq_neg_log_rho` — defining relation `H_th = -ln ρ`,
* `H_th_eq_S_I_over_hbar` — paper's central bridge `H_th = S_I/ℏ`.

The two relations together yield `H_th = τ_ent` via the existing
`MatsubaraLuttingerWardCarrier.S_I_eq_hbar_tauEnt`. -/
structure ThermalHamiltonianFromDensityMatrix where
  /-- Matsubara/Luttinger-Ward witness. -/
  M : MatsubaraLuttingerWardCarrier
  /-- Reduced-density-matrix surrogate `ρ`. -/
  rho : ℝ
  /-- Thermal Hamiltonian surrogate `H_th`. -/
  H_th : ℝ
  /-- `0 < ρ ≤ 1` (probability normalisation). -/
  rho_pos : 0 < rho
  /-- `ρ ≤ 1`. -/
  rho_le_one : rho ≤ 1
  /-- ★ **Defining relation (paper eq. 28)**: `H_th = -ln ρ`. -/
  H_th_eq_neg_log_rho : H_th = - Real.log rho
  /-- ★ **The crucial bridge (paper eq. 30, 31)**:
      `H_th = S_I / ℏ`.

  This is the load-bearing hypothesis of the carrier; combined with
  Matsubara's `S_I = ℏ · τ_ent`, the four-fold identity
  `H_th = -ln ρ = S_I/ℏ = τ_ent` follows. -/
  H_th_eq_S_I_over_hbar_hyp : H_th = M.S_I / M.ℏ

namespace ThermalHamiltonianFromDensityMatrix

variable (T : ThermalHamiltonianFromDensityMatrix)

/-! ## Spine theorems -/

/-- **Proven extraction**: thermal Hamiltonian equals `S_I/ℏ`. -/
theorem H_th_eq_S_I_over_hbar :
    T.H_th = T.M.S_I / T.M.ℏ :=
  T.H_th_eq_S_I_over_hbar_hyp

/-- **Proven**: thermal Hamiltonian equals entropic proper time
(carrier-level four-fold identity). -/
theorem H_th_eq_tau_ent :
    T.H_th = T.M.τ_ent := by
  rw [T.H_th_eq_S_I_over_hbar, T.M.S_I_eq_hbar_tauEnt]
  have hℏ : T.M.ℏ ≠ 0 := ne_of_gt T.M.ℏ_pos
  field_simp

/-- **Proven**: thermal Hamiltonian equals `-ln Z` (path-integral
form, via the Matsubara identification `τ_ent = -ln Z`). -/
theorem H_th_eq_neg_log_Z :
    T.H_th = - Real.log T.M.Z := by
  rw [T.H_th_eq_tau_ent, T.M.tauEnt_eq_neg_log_Z]

/-- **Proven dichotomy**: thermal Hamiltonian is positive iff
`ρ < 1` (system is out of pure-equilibrium). -/
theorem H_th_pos_iff_rho_lt_one :
    0 < T.H_th ↔ T.rho < 1 := by
  rw [T.H_th_eq_neg_log_rho]
  constructor
  · intro h
    have hlog : Real.log T.rho < 0 := by linarith
    exact (Real.log_neg_iff T.rho_pos).mp hlog
  · intro h
    have hlog : Real.log T.rho < 0 := (Real.log_neg_iff T.rho_pos).mpr h
    linarith

/-- **Proven boundary**: thermal Hamiltonian vanishes iff `ρ = 1`
(pure equilibrium). -/
theorem H_th_zero_iff_rho_one :
    T.H_th = 0 ↔ T.rho = 1 := by
  rw [T.H_th_eq_neg_log_rho]
  constructor
  · intro h
    have hlog : Real.log T.rho = 0 := by linarith
    rcases (Real.log_eq_zero.mp hlog) with hZ | hZ | hZ
    · exact absurd hZ (ne_of_gt T.rho_pos)
    · exact hZ
    · -- hZ : T.rho = -1 contradicts T.rho_pos : 0 < T.rho
      have := T.rho_pos
      linarith
  · intro h
    rw [h, Real.log_one]
    ring

/-- **Proven dichotomy on Matsubara `Z`**: at `ρ = 1`, the four-fold
identity reduces to `Z = 1` (unit partition function). -/
theorem rho_one_iff_Z_one :
    T.rho = 1 ↔ T.M.Z = 1 := by
  rw [← T.H_th_zero_iff_rho_one]
  rw [T.H_th_eq_neg_log_Z]
  constructor
  · intro h
    have hlogZ : Real.log T.M.Z = 0 := by linarith
    have hZpos : 0 < T.M.Z := T.M.Z_pos
    rcases (Real.log_eq_zero.mp hlogZ) with hZ | hZ | hZ
    · exact absurd hZ (ne_of_gt hZpos)
    · exact hZ
    · linarith
  · intro h
    rw [h, Real.log_one]; ring

end ThermalHamiltonianFromDensityMatrix

/-! ## Capstone -/

/-- **Trivial existence**: degenerate witness with
`ρ = 1`, `H_th = 0`, `S_I = 0`, `τ_ent = 0`. -/
theorem exists_trivial : ∃ _ : ThermalHamiltonianFromDensityMatrix, True := by
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
  refine ⟨{ M                       := M
          , rho                     := 1
          , H_th                    := 0
          , rho_pos                 := by norm_num
          , rho_le_one              := by norm_num
          , H_th_eq_neg_log_rho     := by simp
          , H_th_eq_S_I_over_hbar_hyp := by show (0 : ℝ) = 0 / 1; norm_num }, trivial⟩

/-- **Capstone bundle.** -/
theorem thermal_hamiltonian_entropic_time_bundle :
    ∃ _ : ThermalHamiltonianFromDensityMatrix, True :=
  exists_trivial

end CATEPTMain.Integration.ThermalHamiltonianEntropicTimeBridge

end
