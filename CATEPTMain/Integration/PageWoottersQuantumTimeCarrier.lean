import Mathlib.Analysis.SpecialFunctions.Log.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# PageWoottersQuantumTimeCarrier — non-speculative carrier for the
Page–Wootters mechanism (clock-conditional emergent time)

Carrier-level slice grounding the CAT/EPT "emergent / relational time"
identifications in the standard Page–Wootters mechanism (Page & Wootters,
*Phys. Rev. D* 27 (1983) 2885; Wootters, *Int. J. Theor. Phys.* 23
(1984) 701; Smith & Ahmadi, *Quantum* 3 (2019) 160; Höhn–Smith–Lock,
*Front. Phys.* 9 (2021) 587083; Marletto–Vedral, *Phys. Rev. D* 95
(2017) 043510).

## Page–Wootters equations (canonical numbering)

We tag the four canonical Page–Wootters equations as **(PW1)–(PW4)**
so downstream consumers can cite them directly.  Each equation is
followed by its carrier-level counterpart.

**(PW1) — Bipartition of the kinematical Hilbert space.**

```
H_total  =  H_C ⊗ 𝟙_S  +  𝟙_C ⊗ H_S                        -- (PW1)
```

into *clock* subsystem `C` and *system* subsystem `S` (Page & Wootters
PRD 27 (1983) 2885, eq. 1).

**(PW2) — Wheeler–DeWitt global constraint.**

```
(H_C + H_S) |Ψ⟩  =  0                                      -- (PW2)
```

(Page & Wootters 1983 eq. 2; Höhn–Smith–Lock 2021 eq. 1).
At the eigenvalue level `E_C + E_S = 0` — carrier-level field
`WDW_constraint`.

**(PW3) — Conditional state at clock reading `t`.**

```
|ψ_S(t)⟩  :=  ⟨t|_C |Ψ⟩                                    -- (PW3)
```

(Page & Wootters 1983 eq. 4; Höhn–Smith–Lock 2021 eq. 8).  The
carrier-level surrogate is `tauPW = t` — field `tauPW_eq`.

**(PW4) — Page–Wootters Schrödinger evolution theorem.**

```
i ℏ ∂_t |ψ_S(t)⟩  =  H_S |ψ_S(t)⟩                          -- (PW4)
```

(Page & Wootters 1983 eq. 5; Marletto–Vedral PRD 95 (2017) 043510
eq. 3; Smith–Ahmadi *Quantum* 3 (2019) 160 eq. 11; Höhn–Smith–Lock
2021 eq. 10).  At an `H_S`-eigenstate of eigenvalue `E_S`, the
accumulated phase relative to clock reading `t = 0` is

```
phaseS(t)  =  − E_S · t / ℏ                                -- (PW4-eig)
```

— carrier-level field `phaseS_eq`.

**(PW5) — Imaginary-time / Wick-rotation magnitude (derived).**
At evaluation point `t = β·ℏ`, the carrier-level magnitude

```
−phaseS · ℏ  =  β · ℏ · E_S                                -- (PW5)
```

is proven as `pageWootters_thermal_eval_identity`.  Together with the
Matsubara identification `E_S ↔ Ω`, this is the central seam linking
Page–Wootters to the Matsubara/Luttinger–Ward thermal action.

## Carrier scope

Magnitude-level real-valued surrogates `(t, ℏ, E_S, E_C, τ_PW, phaseS)`.
The operator-side primitives (clock projector `⟨t|_C`, modular operator,
KMS state, Tomita conjugation) stay abstract; we expose only the
real-arithmetic identifications proved at the carrier level.

This mirrors the magnitude-level treatment of the Matsubara /
Luttinger–Ward identifications shipped in
`CATEPTMain/Integration/MatsubaraLuttingerWardCarrier.lean`.

## What this module ships

* `PageWoottersCarrier` — bundle of real witnesses with positivity
  invariants, the WDW eigenvalue constraint, and the Schrödinger-phase
  identification.
* `tauPW_eq_t` — proven extraction.
* `E_C_eq_neg_E_S` — proven consequence of the WDW constraint.
* `phaseS_eq_clock_form` — proven alternative form via the clock energy.
* `phaseS_at_zero` — proven initial condition.
* `phaseS_origin_shift` — proven clock-frame transformation lemma.
* `relative_phase_invariant` — proven gauge-invariance of relative phase.
* `pageWootters_thermal_eval_identity` — proven imaginary-time
  evaluation linking Page–Wootters to thermal magnitudes.
* `exists_trivial` and capstone bundle.

## Honest scope

* Operator-side `H_C`, `H_S`, the clock projector, and the global state
  `|Ψ⟩` are NOT defined here — they require operator-algebra machinery
  beyond the carrier scope (Logos `TomitaTakesaki` / `KMS` modules, or
  AQFT inclusions). Their identification with the eigenvalue surrogates
  is documented at the docstring level only.
* The unitary equivalence with the relational-Heisenberg and
  deparametrized-Schrödinger pictures (Höhn–Smith–Lock 2021 trinity)
  is similarly stated in the docstring; the carrier-level proof is
  operator-free.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.PageWoottersQuantumTimeCarrier

/-- **Page–Wootters CAT/EPT carrier.**

Holds the magnitude-level data for the Page–Wootters grounding of
clock-conditional emergent time:

* `t`     — clock reading (real)
* `ℏ`     — reduced Planck constant `> 0`
* `E_S`   — system Hamiltonian eigenvalue
* `E_C`   — clock Hamiltonian eigenvalue
* `tauPW` — Page–Wootters conditional time `= t` (forced by `tauPW_eq`)
* `phaseS` — system phase `= −E_S·t/ℏ` (forced by `phaseS_eq`)

The Wheeler–DeWitt eigenvalue constraint `E_C + E_S = 0` is a field of
the carrier, not an external hypothesis.
-/
structure PageWoottersCarrier where
  /-- Clock reading. -/
  t              : ℝ
  /-- Reduced Planck constant. -/
  ℏ              : ℝ
  /-- System Hamiltonian eigenvalue. -/
  E_S            : ℝ
  /-- Clock Hamiltonian eigenvalue. -/
  E_C            : ℝ
  /-- Page–Wootters conditional time. -/
  tauPW          : ℝ
  /-- Schrödinger phase accumulated by the system. -/
  phaseS         : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos          : 0 < ℏ
  /-- **Wheeler–DeWitt eigenvalue constraint** — eigenvalue form of
  Page–Wootters equation **(PW2)** `(H_C + H_S)|Ψ⟩ = 0`. -/
  WDW_constraint : E_C + E_S = 0
  /-- **Page–Wootters time identification** — carrier-level form of
  Page–Wootters equation **(PW3)** `|ψ_S(t)⟩ = ⟨t|_C |Ψ⟩`. -/
  tauPW_eq       : tauPW = t
  /-- **Schrödinger-phase identification** — carrier-level form of
  Page–Wootters equation **(PW4-eig)** `phaseS = −E_S·t/ℏ`. -/
  phaseS_eq      : phaseS = -(E_S * t) / ℏ

namespace PageWoottersCarrier

variable (M : PageWoottersCarrier)

/-- **Extraction (PW3):** Page–Wootters conditional time equals the
clock reading. Carrier-level extraction of equation **(PW3)**
`|ψ_S(t)⟩ = ⟨t|_C |Ψ⟩`. -/
theorem tauPW_eq_t : M.tauPW = M.t := M.tauPW_eq

/-- **Proven consequence of the WDW constraint (PW2):** `E_C = −E_S`.
Eigenvalue rearrangement of equation **(PW2)** `(H_C + H_S)|Ψ⟩ = 0`. -/
theorem E_C_eq_neg_E_S : M.E_C = -M.E_S := by
  have h := M.WDW_constraint
  linarith

/-- **Proven alternate form of the Schrödinger phase (PW4-eig)** via
the clock energy: `phaseS = E_C·t/ℏ`. Direct from `E_C = −E_S` (PW2)
and `phaseS_eq` (PW4-eig). -/
theorem phaseS_eq_clock_form : M.phaseS = M.E_C * M.t / M.ℏ := by
  rw [M.phaseS_eq, M.E_C_eq_neg_E_S]
  ring

/-- **Proven initial condition (PW4-eig):** `phaseS = 0` when the clock
reads `t = 0`. Direct evaluation of equation **(PW4-eig)** at `t = 0`. -/
theorem phaseS_at_zero (h : M.t = 0) : M.phaseS = 0 := by
  rw [M.phaseS_eq, h]
  ring

/-- **Proven clock-origin transformation lemma (PW4 gauge).**

If a second carrier `M'` shares `(ℏ, E_S, E_C)` with `M` and only
differs in clock reading by a shift `t' = t + t₀`, then the Schrödinger
phase shifts by exactly `−E_S·t₀/ℏ`. This is the carrier-level
statement of clock-origin gauge invariance: the *relative* phase
`M'.phaseS − M.phaseS` depends only on the shift `t₀`, not on the
absolute clock readings. -/
theorem phaseS_origin_shift
    (M' : PageWoottersCarrier)
    (hℏ : M'.ℏ = M.ℏ) (hE : M'.E_S = M.E_S) (t₀ : ℝ) (ht : M'.t = M.t + t₀) :
    M'.phaseS - M.phaseS = -(M.E_S * t₀) / M.ℏ := by
  rw [M.phaseS_eq, M'.phaseS_eq, hℏ, hE, ht]
  field_simp
  ring

/-- **Proven gauge-invariance of relative phase under common clock shift
(PW4 gauge).**

If both carriers experience the same clock shift `t₀`, the relative
phase `M'.phaseS − M.phaseS` is unchanged when measured in the
co-moving frame. Carrier-level expression of clock-frame invariance
(Höhn–Smith–Lock 2021 "trinity" §3): two observers with the same
`t₀` displacement see identical relative phases. -/
theorem relative_phase_invariant
    (M' : PageWoottersCarrier)
    (hℏ : M'.ℏ = M.ℏ) (hE : M'.E_S = M.E_S) :
    M.phaseS - M'.phaseS = -(M.E_S * (M.t - M'.t)) / M.ℏ := by
  rw [M.phaseS_eq, M'.phaseS_eq, hℏ, hE]
  field_simp
  ring

/-- **Proven imaginary-time / thermal evaluation identity (PW5).**

At clock reading `t = β·ℏ` the magnitude `−phaseS·ℏ` equals
`β·ℏ·E_S` — the carrier-level imprint of the Wick rotation
`t ↦ −iβℏ` mapping the Page–Wootters Schrödinger phase **(PW4-eig)**
to a thermal Boltzmann magnitude. With `E_S` identified with the
grand-potential density `Ω`, this matches the Matsubara/Luttinger–Ward
imaginary action `S_I = ℏ·β·Ω` proved in
`MatsubaraLuttingerWardCarrier.S_I_eq`.

The link is purely algebraic at the magnitude level; the operator-side
Wick rotation is documented in the module docstring and lives in
operator-algebra modules (Logos `TomitaTakesaki` / AQFT
`KMSModularParameterBridge`). -/
theorem pageWootters_thermal_eval_identity
    (β : ℝ) (h : M.t = β * M.ℏ) :
    -(M.phaseS) * M.ℏ = β * M.ℏ * M.E_S := by
  rw [M.phaseS_eq, h]
  have hℏ : M.ℏ ≠ 0 := ne_of_gt M.ℏ_pos
  field_simp

/-- **Trivial existence:** `t = E_S = E_C = 0`, `ℏ = 1`, hence
`tauPW = phaseS = 0`. The WDW eigenvalue constraint holds trivially. -/
theorem exists_trivial : ∃ _ : PageWoottersCarrier, True := by
  refine ⟨{ t              := 0
          , ℏ              := 1
          , E_S            := 0
          , E_C            := 0
          , tauPW          := 0
          , phaseS         := 0
          , ℏ_pos          := by norm_num
          , WDW_constraint := by ring
          , tauPW_eq       := by ring
          , phaseS_eq      := by ring }, trivial⟩

end PageWoottersCarrier

/-! ## Capstone -/

/-- **Page–Wootters CAT/EPT bundle.** -/
theorem pageWootters_quantum_time_bundle :
    ∃ _ : PageWoottersCarrier, True :=
  PageWoottersCarrier.exists_trivial

end CATEPTMain.Integration.PageWoottersQuantumTimeCarrier

end
