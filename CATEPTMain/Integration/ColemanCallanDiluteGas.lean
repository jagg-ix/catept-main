import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity
import CATEPTMain.Integration.InstantonTunneling

/-!
# Coleman–Callan Dilute-Instanton-Gas Exponentiation (T-CC Phase 4)

Phase-4 honest content for the **dilute-instanton-gas exponentiation**
of the Coleman–Callan vacuum decay rate.  Phases 1–3 pinned the
single-instanton tunneling factor `A(S) = exp(-S)` and the bounce
action `S_b(λ) = 8π²/(3λ)`.

In the dilute-instanton-gas approximation, multi-instanton
configurations are non-interacting and weighted by `(V·κ)^n / n!`,
where `V` is the spacetime volume and `κ` is the single-instanton
"density of zero-modes" prefactor.  The full vacuum partition function
in this approximation is

  `Z(V, κ, S) = ∑_{n≥0} (V · κ · exp(-S))^n / n!  =  exp(V · κ · exp(-S))`,

which is the genuine **exponentiation of the dilute gas** and gives
the vacuum-energy density per unit volume

  `E_vac / V  =  -κ · exp(-S)`.

This file pins this closed-form `Z = exp(V·κ·exp(-S))` along with the
algebraic identities expressing the dilute-gas factorisation and the
vacuum-energy extraction.

* `diluteGasZ_at_zero_action`           — `Z(V, κ, 0) = exp(V·κ)`.
* `diluteGasZ_disjoint_volumes`         — `Z(V₁+V₂) = Z(V₁)·Z(V₂)`
                                          (disjoint regions factorise).
* `log_diluteGasZ_eq_minus_E_times_V`   — `log Z = V·κ·exp(-S) =
                                          -V · E_vac/V`
                                          (vacuum-energy extraction).
* `vacuumEnergyDensity_at_bounce_neg`   — `E_vac/V < 0` whenever
                                          `κ > 0`, witnessing genuine
                                          non-perturbative vacuum
                                          instability.

## Phase status

Phase-4 — honest exponentiation identities, kernel-only
`[propext, Classical.choice, Quot.sound]`. Genuine zero-mode integral
extraction (computing `κ` from the spectrum of `−∂² + V''(φ_b)`)
remains beyond the algebraic skeleton.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.ColemanCallanDiluteGas

open CATEPTMain.Integration.InstantonTunneling

noncomputable section

/-- **Dilute-instanton-gas partition function**:
    `Z(V, κ, S) = exp(V · κ · exp(-S))`,
    the resummation of the multi-instanton series under the
    dilute-gas approximation. -/
def diluteGasZ (V κ S : ℝ) : ℝ :=
  Real.exp (V * κ * tunnelAmplitude S)

/-- **Vacuum-energy density** of the dilute-instanton-gas vacuum:
    `E_vac/V = −κ · exp(-S)`.  Strictly negative when `κ > 0`,
    witnessing non-perturbative false-vacuum instability. -/
def vacuumEnergyDensity (κ S : ℝ) : ℝ :=
  -κ * tunnelAmplitude S

/-- **Trivial-action limit**: with vanishing instanton action
    `S = 0`, the dilute-gas partition function reduces to
    `Z = exp(V·κ)` — the trivial sector of the gas. -/
theorem diluteGasZ_at_zero_action (V κ : ℝ) :
    diluteGasZ V κ 0 = Real.exp (V * κ) := by
  unfold diluteGasZ tunnelAmplitude
  simp

/-- **Volume factorisation**: for two disjoint spacetime regions of
    volumes `V₁` and `V₂`, the dilute-gas partition functions
    multiply:
      `Z(V₁ + V₂, κ, S) = Z(V₁, κ, S) · Z(V₂, κ, S)`,
    expressing that widely-separated instantons in disjoint regions
    contribute independently. -/
theorem diluteGasZ_disjoint_volumes (V₁ V₂ κ S : ℝ) :
    diluteGasZ (V₁ + V₂) κ S
      = diluteGasZ V₁ κ S * diluteGasZ V₂ κ S := by
  unfold diluteGasZ
  rw [show (V₁ + V₂) * κ * tunnelAmplitude S
        = V₁ * κ * tunnelAmplitude S + V₂ * κ * tunnelAmplitude S by ring,
      Real.exp_add]

/-- **Vacuum-energy extraction**: the logarithm of the dilute-gas
    partition function is exactly `−V · (E_vac/V)`, identifying
    `E_vac/V = −κ · exp(-S)` as the genuine vacuum-energy density. -/
theorem log_diluteGasZ_eq_minus_E_times_V (V κ S : ℝ) :
    Real.log (diluteGasZ V κ S) = -(V * vacuumEnergyDensity κ S) := by
  unfold diluteGasZ vacuumEnergyDensity
  rw [Real.log_exp]
  ring

/-- **Strict vacuum instability**: for any positive instanton density
    `κ > 0` and any real action `S`, the dilute-gas vacuum-energy
    density is strictly negative, witnessing genuine non-perturbative
    decay of the false vacuum. -/
theorem vacuumEnergyDensity_neg
    {κ : ℝ} (hκ : 0 < κ) (S : ℝ) :
    vacuumEnergyDensity κ S < 0 := by
  unfold vacuumEnergyDensity tunnelAmplitude
  have hexp : 0 < Real.exp (-S) := Real.exp_pos _
  have : 0 < κ * Real.exp (-S) := by positivity
  linarith

end

end CATEPTMain.Integration.ColemanCallanDiluteGas
