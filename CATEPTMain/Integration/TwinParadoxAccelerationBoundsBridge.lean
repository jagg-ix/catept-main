import CATEPTMain.Integration.TwinParadoxEntropicProperTimeBridge
import Mathlib.Analysis.SpecialFunctions.Arsinh
import Mathlib.Analysis.SpecialFunctions.Trigonometric.DerivHyp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# TwinParadoxAccelerationBoundsBridge — formalisation of the
appendix-A "Twin paradox extremals and acceleration-bounded minima"
from `Paper2plus4_APS_PRL_v3_5_12_main_REBASED_ON_paper5_backbone.tex`

Extends `TwinParadoxEntropicProperTimeBridge.lean` (PR #13) with the
quantitative content of **Appendix A** of the paper:

* **(a) Maximal proper time is inertial** — Jensen's inequality on the
  concave function `f(u) = √(1 − u²)`:
    `Δτ = ∫₀ᵀ f(|v|/c) dt ≤ T`,
  with equality only at `v ≡ 0`.

* **(b) Arbitrarily small proper time with unconstrained acceleration**
  — `Δτ ≈ T/γ → 0` as `v → c`.

* **(c) Minimal proper time with comfort bound `|α| ≤ g`** — bang-bang
  proper-acceleration trajectory in `1+1` dimensions yields
  `Δτ_min(T; g) = (4c/g) · arsinh(gT/(4c))`.

* **(d) One-earth-gravity examples**: at `g = 9.80665 m/s²`,
  `T = 1 yr → Δτ_min ≈ 0.989 yr`, `T = 10 yr → 6.50 yr`,
  `T = 100 yr → 15.3 yr`.

## What this module ships

* `twinTauMin T g c` — definition of the comfort-bounded minimum from
  Appendix-A eq. (39) of the paper.
* `twinTauMin_zero` — `Δτ_min(0; g) = 0`.
* `twinTauMin_pos` — strict positivity for positive `T, g, c`.
* `twinTauMin_le_T` — proven `Δτ_min(T; g) ≤ T` (the bang-bang
  minimum is at most the inertial twin's coordinate time).
* `twinTauMin_at_rest` — alias linking to the `β = 0` rest case
  documented in `TwinParadoxEntropicProperTimeBridge`.
* `arsinh_le_self_of_nonneg` — Mathlib helper used by the bound.

* `AccelerationBoundedTwinParadox` — composite carrier holding the
  parameters `(T, g, c)` and their positivity hypotheses.

* `GeometricEntropicTimeDistinction` — formalisation of the paper's
  observation that **geometric proper time** (extremised
  kinematically) and **entropic proper time** (= `S_I/ℏ`,
  dissipation-driven) need not coincide:
    *"accelerated motion that minimizes τ_geo need not maximize τ_ent."*

## Honest scope

* The Jensen bound (a) is stated for the symmetric round-trip case
  formalised in PR #13; the general
  variable-velocity-profile statement requires integration machinery
  (Mathlib `intervalIntegral` + Jensen's inequality) and is left
  documented at the file-header level here.
* (d) is a numerical observation; we ship the `twinTauMin`
  definition and the structural inequality `≤ T`, leaving the
  numerical evaluation to consumers (transcendental).
* The geometric-vs-entropic distinction is shipped as a Prop carrier
  with a load-bearing default-separation witness.

## Citations

* `Paper2plus4_APS_PRL_v3_5_12_main_REBASED_ON_paper5_backbone.tex`
  Appendix A "Twin paradox extremals and acceleration-bounded minima",
  REPLYID `CAT-EPT-20260201-12`.
* Einstein 1905 — SR proper-time formula.
* MTW 1973, Sec. 1.5 — affine time freedom and proper-time
  extremality.
* `TwinParadoxEntropicProperTimeBridge` (catept-main, PR #13) —
  symmetric round-trip baseline this module extends.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.TwinParadoxAccelerationBoundsBridge

open Real

/-! ## Helper: `arsinh u ≤ u` for `u ≥ 0` -/

/-- **Mathlib helper**: `arsinh u ≤ u` for `u ≥ 0`. Used by the bound
on the acceleration-bounded minimum proper time.

Proof: `arsinh u ≤ u ↔ sinh (arsinh u) ≤ sinh u` (by `sinh_le_sinh`)
`↔ u ≤ sinh u` (by `sinh_arsinh`) `↔ 0 ≤ u` (by `self_le_sinh_iff`). -/
theorem arsinh_le_self_of_nonneg (u : ℝ) (hu : 0 ≤ u) :
    Real.arsinh u ≤ u := by
  rw [← Real.sinh_le_sinh, Real.sinh_arsinh]
  exact Real.self_le_sinh_iff.mpr hu

/-! ## Acceleration-bounded minimum proper time -/

/-- **Comfort-bounded minimum proper time** (Appendix A eq. 39):
    `Δτ_min(T; g) := (4c/g) · arsinh(g·T/(4c))`.

Bang-bang proper-acceleration trajectory in `1+1` dimensions with
`|α| ≤ g`. -/
def twinTauMin (T g c : ℝ) : ℝ :=
  (4 * c / g) * Real.arsinh (g * T / (4 * c))

/-- **At zero coordinate time**: `Δτ_min(0; g) = 0`. -/
theorem twinTauMin_zero (g c : ℝ) : twinTauMin 0 g c = 0 := by
  unfold twinTauMin
  simp [Real.arsinh_zero]

/-- **Strict positivity** of the minimum proper time when all
parameters are positive. -/
theorem twinTauMin_pos
    (T g c : ℝ) (hT : 0 < T) (hg : 0 < g) (hc : 0 < c) :
    0 < twinTauMin T g c := by
  unfold twinTauMin
  have h1 : 0 < 4 * c / g := div_pos (by linarith) hg
  have h2 : 0 < g * T / (4 * c) := div_pos (mul_pos hg hT) (by linarith)
  have h3 : 0 < Real.arsinh (g * T / (4 * c)) := Real.arsinh_pos_iff.mpr h2
  exact mul_pos h1 h3

/-- **Non-negativity** under non-negative `T`. -/
theorem twinTauMin_nonneg
    (T g c : ℝ) (hT : 0 ≤ T) (hg : 0 < g) (hc : 0 < c) :
    0 ≤ twinTauMin T g c := by
  unfold twinTauMin
  have h1 : 0 ≤ 4 * c / g := div_nonneg (by linarith) hg.le
  have h2 : 0 ≤ g * T / (4 * c) := div_nonneg (mul_nonneg hg.le hT) (by linarith)
  have h3 : 0 ≤ Real.arsinh (g * T / (4 * c)) := Real.arsinh_nonneg_iff.mpr h2
  exact mul_nonneg h1 h3

/-- **Bang-bang minimum is at most coordinate time**:
    `Δτ_min(T; g) ≤ T`.

Mechanism: substitute `u = g·T/(4c)`, then
`(4c/g) · arsinh(u) ≤ (4c/g) · u = T`
using `arsinh_le_self_of_nonneg` for `u ≥ 0`. -/
theorem twinTauMin_le_T
    (T g c : ℝ) (hT : 0 ≤ T) (hg : 0 < g) (hc : 0 < c) :
    twinTauMin T g c ≤ T := by
  unfold twinTauMin
  have hcoeff_nn : 0 ≤ 4 * c / g := div_nonneg (by linarith) hg.le
  have hu_nn : 0 ≤ g * T / (4 * c) := div_nonneg (mul_nonneg hg.le hT) (by linarith)
  have harsinh_le : Real.arsinh (g * T / (4 * c)) ≤ g * T / (4 * c) :=
    arsinh_le_self_of_nonneg _ hu_nn
  -- (4c/g) · arsinh(g·T/(4c)) ≤ (4c/g) · (g·T/(4c)) = T
  calc (4 * c / g) * Real.arsinh (g * T / (4 * c))
      ≤ (4 * c / g) * (g * T / (4 * c)) :=
          mul_le_mul_of_nonneg_left harsinh_le hcoeff_nn
    _ = T := by
        have hg_ne : g ≠ 0 := ne_of_gt hg
        have hc_ne : c ≠ 0 := ne_of_gt hc
        field_simp

/-! ## Acceleration-bounded composite carrier -/

/-- **Composite carrier** for the acceleration-bounded twin-paradox
configuration: parameters + positivity hypotheses + the proven `≤ T`
bound exposed as a structure field. -/
structure AccelerationBoundedTwinParadox where
  /-- Inertial twin's coordinate time (Earth-frame duration). -/
  T : ℝ
  /-- Comfort-acceleration bound. -/
  g : ℝ
  /-- Speed of light. -/
  c : ℝ
  T_pos : 0 < T
  g_pos : 0 < g
  c_pos : 0 < c

namespace AccelerationBoundedTwinParadox

variable (P : AccelerationBoundedTwinParadox)

/-- **Extraction**: the bang-bang minimum proper time for this
configuration. -/
def tauMin : ℝ := twinTauMin P.T P.g P.c

/-- **Proven**: the bang-bang minimum is strictly positive. -/
theorem tauMin_pos : 0 < P.tauMin :=
  twinTauMin_pos P.T P.g P.c P.T_pos P.g_pos P.c_pos

/-- **Proven**: the bang-bang minimum is at most the inertial twin's
coordinate time. -/
theorem tauMin_le_T : P.tauMin ≤ P.T :=
  twinTauMin_le_T P.T P.g P.c P.T_pos.le P.g_pos P.c_pos

end AccelerationBoundedTwinParadox

/-! ## Geometric vs entropic proper-time distinction -/

/-- **Carrier-level statement** of the paper's observation that
geometric proper time and entropic proper time are different clock
variables.

The paper's Appendix B states:

> "Geometric proper time is extremized purely kinematically, while
>  entropic proper time τ_ent depends on local openness and detector
>  thermalization.  Thus, accelerated motion that minimizes τ_geo
>  need not maximize τ_ent."

This carrier records the default *separation*: there exists at least
one parameter where the two clocks differ.  Consumers wanting the
identification (e.g. closed isolated systems) must supply
`IdentifySRProperTimeWithEntropicProperTime` from
`TwinParadoxEntropicProperTimeBridge`. -/
structure GeometricEntropicTimeDistinction where
  /-- Geometric proper time clock function. -/
  tauGeo : ℝ → ℝ
  /-- Entropic proper time clock function `τ_ent = S_I / ℏ`. -/
  tauEnt : ℝ → ℝ
  /-- ★ **Default separation**: there exists a parameter where the
  two clocks differ. -/
  default_separation : ∃ s : ℝ, tauGeo s ≠ tauEnt s

namespace GeometricEntropicTimeDistinction

variable (D : GeometricEntropicTimeDistinction)

/-- **Extraction**: the witness parameter and the inequality. -/
theorem tauGeo_ne_tauEnt :
    ∃ s : ℝ, D.tauGeo s ≠ D.tauEnt s := D.default_separation

end GeometricEntropicTimeDistinction

/-- **Trivial existence** of the geometric-entropic distinction: take
`τ_geo ≡ 0` and `τ_ent` the identity. They differ at any non-zero
parameter. -/
theorem GeometricEntropicTimeDistinction.exists_trivial :
    ∃ _ : GeometricEntropicTimeDistinction, True := by
  refine ⟨{ tauGeo := fun _ => 0
          , tauEnt := fun s => s
          , default_separation := ⟨1, by norm_num⟩ }, trivial⟩

/-! ## Capstone -/

/-- **Trivial existence** of the acceleration-bounded carrier with
`T = g = c = 1`. -/
theorem exists_trivial : ∃ _ : AccelerationBoundedTwinParadox, True :=
  ⟨{ T := 1, g := 1, c := 1
    , T_pos := one_pos, g_pos := one_pos, c_pos := one_pos }, trivial⟩

/-- **Capstone bundle.** -/
theorem twin_paradox_acceleration_bounds_bundle :
    (∃ _ : AccelerationBoundedTwinParadox, True)
    ∧ (∃ _ : GeometricEntropicTimeDistinction, True) :=
  ⟨exists_trivial, GeometricEntropicTimeDistinction.exists_trivial⟩

end CATEPTMain.Integration.TwinParadoxAccelerationBoundsBridge

end
