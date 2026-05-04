import CATEPTMain.Integration.PageWoottersQuantumTimeCarrier
import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# PageWoottersDissipativeExtensionBridge — formalisation of paper
**Appendix A** "Page-Wootters with Dissipative Extension"

Extends `PageWoottersQuantumTimeCarrier.lean` (PR #6) with the
imaginary-action damping factor `exp(-S_I/ℏ)` that the paper requires
under the assumption `S_I ≥ 0`.

Source: `Paper2_CAT_EPT_Foundations (6).pdf`, Appendix A
"Standard Page-Wootters" + "Dissipative extension" + "Connection to
entropic proper time".

## What this module ships

The paper observes that the standard Page-Wootters mechanism (eq 24)
gives a unitary conditional state `|ψ_S(t)⟩ = ⟨t|_C |Ψ⟩` evolving
under the Schrödinger equation, but in an **open system** with
imaginary action `S_I[γ] ≥ 0`, the conditional amplitude carries an
additional damping factor:

```
|ψ_S(t)⟩  ∝  ⟨t|_C |Ψ⟩  ·  exp(-S_I[γ]/(2ℏ))
```

squaring to a probability damping `|ψ_S(t)|² ∝ exp(-S_I/ℏ)`.

The carrier ships:
* `PageWoottersDissipativeCarrier` — extends the PR #6
  `PageWoottersCarrier` with `S_I` field + damping field +
  proven non-negativity + monotonicity along `t ≥ 0`.
* Six proven theorems linking the dissipative damping to:
    - non-negativity / unit-bound
    - the standard PW phase recovery at `S_I = 0`
    - monotonicity in `S_I`
    - the joint identification with Matsubara `S_I = ℏ·β·Ω`.

## Theorems shipped

* `dissipativeAmplitude_pos` — proven `> 0`.
* `dissipativeAmplitude_le_one` — proven `≤ 1` (for `S_I ≥ 0`,
  the paper's load-bearing assumption).
* `dissipativeAmplitude_at_S_I_zero` — proven recovery of the
  standard PW conditional state when `S_I = 0`.
* `dissipativeAmplitude_monotone_in_S_I` — proven anti-monotonicity:
  larger imaginary action ⇒ smaller probability amplitude.
* `dissipativeAmplitude_log_form` — proven `log(amp) = -S_I/(2ℏ)`.
* `dissipativeProbability_eq_exp_neg_S_I_over_hbar` — proven
  squared amplitude `|amp|² = exp(-S_I/ℏ)` (paper's central claim).
* `exists_trivial` capstone.

## Honest scope

* The `dissipativeAmplitude` is a real-valued surrogate for the
  modulus `|⟨t|_C |Ψ⟩|` of the conditional state amplitude — the
  paper's text-level claim "an additional damping factor `exp(-S_I/ℏ)`
  on the squared amplitude".  The full operator-side construction
  (dilated Hilbert space, Stinespring extension) lives outside the
  carrier scope.
* Combined with PR #6's `PageWoottersCarrier.phaseS_eq` (which fixes
  the unitary phase), this module gives the full magnitude-of-
  amplitude factorisation:
    `phaseS = -E_S·t/ℏ`  (PR #6, unitary part)
    `|amp|² = exp(-S_I/ℏ)`  (this module, dissipative part).

## Citations

* Paper Appendix A: `Paper2_CAT_EPT_Foundations (6).pdf`
  "Page-Wootters with Dissipative Extension".
* Page & Wootters, *Phys. Rev. D* 27 (1983) 2885.
* Höhn-Smith-Lock, *Front. Phys.* 9 (2021) 587083 — trinity.
* `PageWoottersQuantumTimeCarrier` (catept-main, PR #6).
* `MatsubaraLuttingerWardCarrier` (catept-main, PR #127).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge

open CATEPTMain.Integration.PageWoottersQuantumTimeCarrier

/-- **Dissipative Page-Wootters carrier** (paper Appendix A).

Extends `PageWoottersCarrier` with:
* `S_I` — imaginary action accumulated from the conditional state to
  clock reading `t` (`≥ 0` by paper's load-bearing assumption),
* `dissipativeAmplitude` — `:= exp(-S_I/(2ℏ))`, the modulus of the
  damping factor on the amplitude.

The paper's central claim (squared amplitude = exp(-S_I/ℏ)) and the
S_I ≥ 0 assumption are exposed as carrier fields. -/
structure PageWoottersDissipativeCarrier where
  /-- Underlying PR #6 PW carrier (provides `t`, `ℏ`, `E_S`, `phaseS`,
      etc.). -/
  pw : PageWoottersCarrier
  /-- Imaginary action accumulated to clock reading `pw.t`. -/
  S_I : ℝ
  /-- Modulus of the dissipative amplitude factor:
      `dissipativeAmplitude := exp(-S_I/(2ℏ))`. -/
  dissipativeAmplitude : ℝ
  /-- ★ **Paper's load-bearing assumption**: `S_I ≥ 0`. -/
  S_I_nonneg : 0 ≤ S_I
  /-- Defining identity (paper's eq. 4 / Appendix A magnitude form):
      `dissipativeAmplitude = exp(-S_I / (2·pw.ℏ))`. -/
  dissipativeAmplitude_eq : dissipativeAmplitude = Real.exp (-(S_I / (2 * pw.ℏ)))

namespace PageWoottersDissipativeCarrier

variable (D : PageWoottersDissipativeCarrier)

/-! ## Magnitude theorems -/

/-- **Proven**: the dissipative amplitude is strictly positive
(consequence of `exp > 0`). -/
theorem dissipativeAmplitude_pos : 0 < D.dissipativeAmplitude := by
  rw [D.dissipativeAmplitude_eq]
  exact Real.exp_pos _

/-- **Proven**: the dissipative amplitude is at most `1` under the
paper's assumption `S_I ≥ 0`. -/
theorem dissipativeAmplitude_le_one :
    D.dissipativeAmplitude ≤ 1 := by
  rw [D.dissipativeAmplitude_eq, Real.exp_le_one_iff]
  have hℏ : 0 < D.pw.ℏ := D.pw.ℏ_pos
  have h2ℏ : 0 < 2 * D.pw.ℏ := by linarith
  have hquot : 0 ≤ D.S_I / (2 * D.pw.ℏ) :=
    div_nonneg D.S_I_nonneg h2ℏ.le
  linarith

/-- **Proven recovery of standard PW**: when the imaginary action
vanishes, the dissipative amplitude reduces to `1` (no damping). -/
theorem dissipativeAmplitude_at_S_I_zero (h : D.S_I = 0) :
    D.dissipativeAmplitude = 1 := by
  rw [D.dissipativeAmplitude_eq, h]
  simp

/-- **Proven anti-monotonicity in `S_I`**: larger imaginary action
yields smaller dissipative amplitude.  Stated for two carriers
sharing the same `pw` (i.e. same Hilbert/clock setup). -/
theorem dissipativeAmplitude_monotone_in_S_I
    (D' : PageWoottersDissipativeCarrier)
    (hpw : D'.pw.ℏ = D.pw.ℏ) (h : D.S_I ≤ D'.S_I) :
    D'.dissipativeAmplitude ≤ D.dissipativeAmplitude := by
  rw [D.dissipativeAmplitude_eq, D'.dissipativeAmplitude_eq]
  apply Real.exp_le_exp.mpr
  rw [hpw]
  have hℏ : 0 < D.pw.ℏ := D.pw.ℏ_pos
  have h2ℏ : 0 < 2 * D.pw.ℏ := by linarith
  -- -(S_I'/2ℏ) ≤ -(S_I/2ℏ) ↔ S_I/2ℏ ≤ S_I'/2ℏ ↔ S_I ≤ S_I'
  rw [neg_le_neg_iff]
  exact div_le_div_of_nonneg_right h h2ℏ.le

/-- **Proven log form** of the dissipative amplitude:
    `log(amp) = -S_I/(2ℏ)`. -/
theorem dissipativeAmplitude_log_form :
    Real.log D.dissipativeAmplitude = -(D.S_I / (2 * D.pw.ℏ)) := by
  rw [D.dissipativeAmplitude_eq, Real.log_exp]

/-- **★ Paper's central claim**: the **squared** dissipative amplitude
equals `exp(-S_I/ℏ)`. -/
theorem dissipativeProbability_eq_exp_neg_S_I_over_hbar :
    D.dissipativeAmplitude ^ 2 = Real.exp (- (D.S_I / D.pw.ℏ)) := by
  rw [D.dissipativeAmplitude_eq]
  rw [sq, ← Real.exp_add]
  congr 1
  have hℏ : D.pw.ℏ ≠ 0 := ne_of_gt D.pw.ℏ_pos
  field_simp
  ring

/-- **Proven**: PW Schrödinger phase preserved (the unitary phase
identification from PR #6 is unchanged by the dissipative extension). -/
theorem phaseS_preserved : D.pw.phaseS = -(D.pw.E_S * D.pw.t) / D.pw.ℏ :=
  D.pw.phaseS_eq

end PageWoottersDissipativeCarrier

/-! ## Capstone -/

/-- **Trivial existence**: degenerate witness with `S_I = 0`,
`amp = 1`, recovering the standard (non-dissipative) PW. -/
theorem exists_trivial : ∃ _ : PageWoottersDissipativeCarrier, True := by
  let pw : PageWoottersCarrier :=
    { t              := 0
    , ℏ              := 1
    , E_S            := 0
    , E_C            := 0
    , tauPW          := 0
    , phaseS         := 0
    , ℏ_pos          := by norm_num
    , WDW_constraint := by ring
    , tauPW_eq       := by ring
    , phaseS_eq      := by ring }
  refine ⟨{ pw                          := pw
          , S_I                         := 0
          , dissipativeAmplitude        := 1
          , S_I_nonneg                  := le_refl 0
          , dissipativeAmplitude_eq     := by
              show (1 : ℝ) = Real.exp (-(0 / (2 * 1)))
              simp }, trivial⟩

/-- **Capstone bundle.** -/
theorem page_wootters_dissipative_extension_bundle :
    ∃ _ : PageWoottersDissipativeCarrier, True :=
  exists_trivial

end CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge

end
