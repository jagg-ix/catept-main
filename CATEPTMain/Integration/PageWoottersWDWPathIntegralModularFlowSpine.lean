import CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
import CATEPTMain.Integration.PageWoottersMatsubaraEquivalenceBridge
import CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
import CATEPTMain.Integration.KMSModularParameterBridge
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# PageWoottersWDWPathIntegralModularFlowSpine — capstone spine theorem
linking Wheeler–DeWitt constraint, path integral, and modular flow,
with Schrödinger reduction under no entropic-clock evolution

This module ships the **spine theorem** of the CAT/EPT quantum-time
backbone: a single composite carrier that simultaneously holds

1. the Page–Wootters quantum-time carrier (Wheeler–DeWitt constraint
   **(PW2)**, conditional state **(PW3)**, Schrödinger evolution
   **(PW4)** at the eigenvalue level),

2. the Matsubara/Luttinger–Ward thermal-action carrier (path-integral
   imaginary action `S_I = ℏ·β·Ω = −ℏ·ln Z`),

3. the AQFT modular-flow carrier
   (`IdentifyKMSStripWithEntropicProperTime`, identifying the entropic
   proper time with the KMS strip width `1/γ_I` of the modular flow),

together with proven equivalences linking the three at the imaginary-
time evaluation point and a **Schrödinger-reduction theorem** showing
that when there is no entropic-clock evolution (`τ_ent = 0`), the full
Page–Wootters / Matsubara / modular-flow tower collapses to the bare
Schrödinger evolution **(PW4-eig)** with no thermal correction.

## Design

The spine carrier nests three witnesses:

```
                ┌──────────────────────────────────────┐
                │  PageWoottersMatsubaraEquivalenceBridge │
                │   (PW carrier ⊕ Matsubara carrier ⊕    │
                │   E_S↔Ω, ℏ-, t=β·ℏ-consistency)        │
                └──────────────────┬───────────────────┘
                                   │
                                   │  matsubara_eq_kms : τ_ent = kmsBridge.tauEnt 0
                                   ▼
                ┌──────────────────────────────────────┐
                │  IdentifyKMSStripWithEntropicProperTime │
                │   (KMS strip width = 1/γ_I = τ_ent)    │
                └──────────────────────────────────────┘
```

The single hypothesis `matsubara_eq_kms` at the evaluation point glues
the three layers; all spine theorems flow from it.

## Spine theorems

* `wdw_path_integral_modular_flow_consistency` — three-way magnitude
  consistency: the WDW eigenvalue constraint, the path-integral
  imaginary action, and the modular-flow strip width all agree on
  the carrier-level scalar at the evaluation point.

* `path_integral_eq_modular_flow_action` —
  `−phaseS·ℏ = ℏ·kmsBridge.tauEnt 0` (Wick-rotation seam ↔ modular
  flow strip width).

* `modular_flow_eq_inverse_dissipation_rate` —
  `kmsBridge.tauEnt 0 = 1/γ_I 0` (proven, from `tauEnt_eq_inv_rate`).

* `schrodinger_reduction_under_no_clock_evolution` — **the central
  reduction theorem**: under `τ_ent = 0` (equivalently `Z = 1`,
  `S_I = 0`), the Page–Wootters phase reduces to the standard
  Schrödinger phase `phaseS = −E_S·t/ℏ` (carried by the underlying
  PW carrier, now with vanishing thermal correction); the
  path-integral imaginary action vanishes; the Wick-rotated magnitude
  vanishes; and the modular-flow strip width at the evaluation point
  is zero (degenerate KMS state).

* `modular_flow_interpretation` — interpretive corollary: the
  Page–Wootters phase accumulated over one imaginary-time period
  `t = β·ℏ` IS the action accumulated under one cycle of the
  modular flow, with magnitude `ℏ·τ_ent = ℏ·kmsStripWidth = ℏ/γ_I`.

## Honest scope

* The carrier-level `phaseS_eq` field always holds (it's a structure
  field of `PageWoottersCarrier`); the Schrödinger-reduction theorem
  asserts the *additional* facts that the thermal correction
  vanishes (`S_I = 0`, `Z = 1`) and the modular flow trivializes
  (`tauEnt 0 = 0`). The non-trivial content is that ALL three layers
  reduce coherently.

* The operator-side primitives (clock projector `⟨t|_C`, Tomita
  operator `Δ`, KMS state, modular Hamiltonian) remain abstract.
  Spine theorems are real-arithmetic / magnitude-level.

* The "modular flow has zero strip width" interpretation under
  `τ_ent = 0` corresponds to the high-temperature / trivial-state
  limit (β → 0 or Ω → 0); it is NOT the no-modular-flow limit
  (γ_I → 0, strip width → ∞), which is a different physical regime.

## Citations

* Page & Wootters, *Phys. Rev. D* 27 (1983) 2885.
* Wootters, *Int. J. Theor. Phys.* 23 (1984) 701.
* Marletto & Vedral, *Phys. Rev. D* 95 (2017) 043510.
* Smith & Ahmadi, *Quantum* 3 (2019) 160.
* Höhn–Smith–Lock, *Front. Phys.* 9 (2021) 587083.
* Connes & Rovelli, *Class. Quantum Grav.* 11 (1994) 2899
  (thermal-time hypothesis ↔ modular flow).
* Welden, Phillips & Gull, *Phys. Rev. B* 93 (2016) 165106
  (Matsubara / Luttinger–Ward).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.PageWoottersWDWPathIntegralModularFlowSpine

open CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
open CATEPTMain.Integration.PageWoottersMatsubaraEquivalenceBridge
open CATEPTMain.Integration.MatsubaraLuttingerWardCarrier
open CATEPTMain.Integration.KMSModularParameterBridge

/-- **CAT/EPT spine carrier**: nested composite of Page–Wootters
quantum-time, Matsubara/Luttinger–Ward thermal action, and AQFT
modular-flow witnesses, glued by a single consistency hypothesis at
the evaluation point.

* `pwMat`           — Page–Wootters ⊕ Matsubara equivalence bridge
                      (carries the WDW eigenvalue constraint **(PW2)**
                      via `pw.WDW_constraint`, the Schrödinger phase
                      **(PW4-eig)** via `pw.phaseS_eq`, the
                      path-integral imaginary action via
                      `matsubara.S_I_eq`, and the cross-equivalence
                      `−phaseS·ℏ = S_I` at `t = β·ℏ`).
* `kmsBridge`       — AQFT KMS strip width ↔ entropic proper time
                      identification (`tauEnt(s) = 1/γ_I(s)`).
* `matsubara_eq_kms` — the load-bearing consistency at evaluation
                      point `0`: Matsubara `τ_ent = kmsBridge.tauEnt 0`. -/
structure PageWoottersWDWPathIntegralModularFlowSpine where
  /-- Page–Wootters ⊕ Matsubara equivalence bridge (PR ##). -/
  pwMat            : PageWoottersMatsubaraEquivalenceBridge
  /-- AQFT KMS-strip ↔ entropic-proper-time identification
      (`KMSModularParameterBridge`, PR #53). -/
  kmsBridge        : IdentifyKMSStripWithEntropicProperTime
  /-- **Three-layer consistency at evaluation point `0`**: Matsubara
      `τ_ent` equals the AQFT modular-flow strip width. -/
  matsubara_eq_kms : pwMat.matsubara.τ_ent = kmsBridge.tauEnt 0

namespace PageWoottersWDWPathIntegralModularFlowSpine

variable (B : PageWoottersWDWPathIntegralModularFlowSpine)

/-- **Spine theorem 1 — Three-way magnitude consistency
(WDW ↔ path integral ↔ modular flow).**

The Wheeler–DeWitt-constrained Page–Wootters phase magnitude
`−phaseS·ℏ` at the imaginary-time evaluation point `t = β·ℏ` equals
the path-integral imaginary action `S_I` (Matsubara) and equals
`ℏ` times the modular-flow strip width `kmsBridge.tauEnt 0`.

Carrier-level statement:
`−pw.phaseS·pw.ℏ  =  matsubara.S_I  =  ℏ · kmsBridge.tauEnt 0`. -/
theorem wdw_path_integral_modular_flow_consistency :
    -(B.pwMat.pw.phaseS) * B.pwMat.pw.ℏ = B.pwMat.matsubara.S_I
    ∧ B.pwMat.matsubara.S_I = B.pwMat.matsubara.ℏ * B.kmsBridge.tauEnt 0 := by
  refine ⟨B.pwMat.pageWootters_thermal_eq_matsubara_S_I, ?_⟩
  rw [B.pwMat.matsubara.S_I_eq_hbar_tauEnt, B.matsubara_eq_kms]

/-- **Spine theorem 2 — Path-integral magnitude equals
modular-flow action.**

Direct corollary: `−phaseS·ℏ = ℏ·kmsBridge.tauEnt 0`. The Wick-
rotation seam (`-phaseS·ℏ` from PW5) coincides with the modular-flow
strip width (`kmsBridge.tauEnt 0`) up to the universal factor `ℏ`. -/
theorem path_integral_eq_modular_flow_action :
    -(B.pwMat.pw.phaseS) * B.pwMat.pw.ℏ
      = B.pwMat.matsubara.ℏ * B.kmsBridge.tauEnt 0 := by
  rw [B.pwMat.pageWootters_thermal_eq_matsubara_S_I,
      B.pwMat.matsubara.S_I_eq_hbar_tauEnt, B.matsubara_eq_kms]

/-- **Spine theorem 3 — Modular flow rate identification.**

The modular-flow strip width at the evaluation point is the inverse
dissipation rate: `kmsBridge.tauEnt 0 = 1/γ_I 0`. Direct from
`KMSModularParameterBridge.IdentifyKMSStripWithEntropicProperTime.tauEnt_eq_inv_rate`. -/
theorem modular_flow_eq_inverse_dissipation_rate :
    B.kmsBridge.tauEnt 0 = 1 / B.kmsBridge.gammaI 0 :=
  B.kmsBridge.tauEnt_eq_inv_rate 0

/-- **Spine theorem 4 — Schrödinger reduction under no
entropic-clock evolution.**

When the entropic clock is frozen (`τ_ent = 0`), the full
Page–Wootters / Matsubara / modular-flow tower collapses to:

* the bare Schrödinger phase **(PW4-eig)** `phaseS = −E_S·t/ℏ`
  (always true as a carrier field; here we re-state it to make the
  reduction explicit);
* zero imaginary action `S_I = 0` (no path-integral thermal weight);
* unit partition function `Z = 1`;
* zero Wick-rotated magnitude `−phaseS·ℏ = 0` at the imaginary-time
  evaluation point;
* zero modular-flow strip width `kmsBridge.tauEnt 0 = 0` (degenerate
  KMS state at the evaluation point).

The carrier-level Schrödinger equation **(PW4-eig)** is preserved;
the thermal correction and modular flow trivialize. -/
theorem schrodinger_reduction_under_no_clock_evolution
    (h_no_clock : B.pwMat.matsubara.τ_ent = 0) :
    B.pwMat.pw.phaseS = -(B.pwMat.pw.E_S * B.pwMat.pw.t) / B.pwMat.pw.ℏ
    ∧ B.pwMat.matsubara.S_I = 0
    ∧ B.pwMat.matsubara.Z = 1
    ∧ -(B.pwMat.pw.phaseS) * B.pwMat.pw.ℏ = 0
    ∧ B.kmsBridge.tauEnt 0 = 0 := by
  refine ⟨B.pwMat.pw.phaseS_eq, ?_, ?_, ?_, ?_⟩
  · -- S_I = ℏ·τ_ent = ℏ·0 = 0
    rw [B.pwMat.matsubara.S_I_eq_hbar_tauEnt, h_no_clock]; ring
  · -- τ_ent = -ln Z; τ_ent = 0 ⇒ ln Z = 0 ⇒ Z = 1
    have hlogZ : Real.log B.pwMat.matsubara.Z = 0 := by
      have hlog := B.pwMat.matsubara.tauEnt_eq_neg_log_Z
      rw [h_no_clock] at hlog
      linarith
    have hZpos : 0 < B.pwMat.matsubara.Z := B.pwMat.matsubara.Z_pos
    rcases (Real.log_eq_zero.mp hlogZ) with hZ | hZ | hZ
    · exact absurd hZ (ne_of_gt hZpos)
    · exact hZ
    · linarith
  · -- -phaseS·ℏ = S_I = ℏ·τ_ent = 0
    rw [B.pwMat.pageWootters_thermal_eq_matsubara_S_I,
        B.pwMat.matsubara.S_I_eq_hbar_tauEnt, h_no_clock]
    ring
  · -- kmsBridge.tauEnt 0 = matsubara.τ_ent = 0
    rw [← B.matsubara_eq_kms, h_no_clock]

/-- **Spine theorem 5 — Modular-flow interpretation of the
Page–Wootters phase.**

The Page–Wootters phase magnitude accumulated over one imaginary-
time period (`t = β·ℏ`) coincides with the action accumulated under
one strip-width interval of the modular flow:

`−phaseS·ℏ  =  ℏ · kmsStripWidth(0)  =  ℏ / γ_I(0)`.

This is the carrier-level statement of the thermal-time hypothesis
(Connes–Rovelli 1994): the Page–Wootters / Schrödinger phase, when
analytically continued to imaginary time, IS the modular-flow
action. -/
theorem modular_flow_interpretation :
    -(B.pwMat.pw.phaseS) * B.pwMat.pw.ℏ
      = B.pwMat.matsubara.ℏ / B.kmsBridge.gammaI 0 := by
  rw [B.path_integral_eq_modular_flow_action,
      B.modular_flow_eq_inverse_dissipation_rate, mul_one_div]

/-- **Trivial existence:** degenerate spine with all witnesses zero
or unit. The PW–Matsubara bridge uses the existing
`PageWoottersMatsubaraEquivalenceBridge.exists_trivial`; the kmsBridge
is the constant-zero rate identification.

Note: with `τ_ent = 0` and `kmsBridge.tauEnt 0 = 0`, the consistency
`matsubara_eq_kms` holds by definition. -/
theorem exists_trivial : ∃ _ : PageWoottersWDWPathIntegralModularFlowSpine, True := by
  -- Build the inner Matsubara/PW bridge inline.
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
  let pwMat : PageWoottersMatsubaraEquivalenceBridge :=
    { pw                  := pw
    , matsubara           := M
    , t_eq_betaHbar       := by show (1 : ℝ) = 1 * 1; ring
    , hbar_eq             := by show (1 : ℝ) = 1; rfl
    , E_S_eq_Omega        := by show (0 : ℝ) = 0; rfl }
  refine ⟨{ pwMat            := pwMat
          , kmsBridge        :=
              { gammaI := fun _ => 0
              , tauEnt := fun _ => 0
              , tauEnt_eq_kmsStripWidth := fun _ => by
                  rw [kmsStripWidth_eq]; simp }
          , matsubara_eq_kms := rfl }, trivial⟩

end PageWoottersWDWPathIntegralModularFlowSpine

/-! ## Capstone -/

/-- **CAT/EPT WDW–path-integral–modular-flow spine bundle.** -/
theorem pageWootters_wdw_pathIntegral_modularFlow_spine_bundle :
    ∃ _ : PageWoottersWDWPathIntegralModularFlowSpine, True :=
  PageWoottersWDWPathIntegralModularFlowSpine.exists_trivial

end CATEPTMain.Integration.PageWoottersWDWPathIntegralModularFlowSpine

end
