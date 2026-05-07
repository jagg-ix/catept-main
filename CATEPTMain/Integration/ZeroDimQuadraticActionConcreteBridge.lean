import CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge
import CATEPTMain.Integration.PageWoottersDissipativeExtensionBridge
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# ZeroDimQuadraticActionConcreteBridge — Tier C Module 1

Source: `Paper2_CAT_EPT_Foundations (6).pdf` §3.3 / §4.2
"Zero-dimensional Gaussian — worked example".

Concrete instantiation of the Tier A spine on the simplest non-trivial
imaginary action: `S_I[φ] = c · φ²` with `c > 0`.  This is the
zero-dimensional Gaussian field theory the paper uses as a worked
example for the UV coercivity bound and dissipative-amplitude
formulae.

## What this module ships

* `ZeroDimQuadraticActionCarrier` — bundles `c, ℏ` with positivity.
* `S_I_at_zero` — proven `S_I[0] = 0` (saddle-point of the action).
* `S_I_pos_at_nonzero` — proven strict positivity off the saddle.
* `S_I_nonneg_everywhere` — proven non-negativity.
* `is_uv_coercive` — proven the action satisfies UV coercivity with
  `C := c` (saturating the bound).
* `toUVCoercivityCarrier` — explicit construction realising Tier A
  Module 3's `UVCoercivityCarrier ℝ`.
* `dissipativeAmp_at_zero_eq_one` — proven the dissipative amplitude
  is `1` at the saddle (no damping).
* `dissipativeAmp_lt_one_at_nonzero` — proven strict damping off the
  saddle.
* `exists_trivial` capstone.

## Honest scope

* The "zero-dim" name reflects that `φ ∈ ℝ` (no spatial extent).  The
  paper's full multi-mode Gaussian (paper §4) lives in
  `MultiModeSourcedGaussian.lean` and friends.
* The partition-function value `Z = √(π/c)` is *not* threaded through
  here — it requires `Real.sqrt` and `Real.pi`, which would couple
  this module to additional Mathlib infrastructure.  The carrier is
  purely action-functional + dissipative-amplitude level.

## Citations

* Paper §3.3, §4.2: `Paper2_CAT_EPT_Foundations (6).pdf`,
  "Zero-dim Gaussian worked example".
* `UVCoercivityAbsoluteDampingBridge` (Tier A Module 3).
* `PageWoottersDissipativeExtensionBridge` (Tier A Module 2).
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge

open CATEPTMain.Integration.UVCoercivityAbsoluteDampingBridge

/-- **Zero-dim quadratic-action carrier** (paper §3.3 / §4.2).

The simplest non-trivial imaginary action: `S_I[φ] = c · φ²` for
`φ ∈ ℝ`, `c > 0`. -/
structure ZeroDimQuadraticActionCarrier where
  /-- Quadratic coefficient `c > 0`. -/
  c : ℝ
  /-- Strict positivity of `c`. -/
  c_pos : 0 < c
  /-- Reduced Planck constant. -/
  ℏ : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos : 0 < ℏ

namespace ZeroDimQuadraticActionCarrier

variable (G : ZeroDimQuadraticActionCarrier)

/-- The imaginary-action functional `S_I[φ] := c · φ²`. -/
def S_I (φ : ℝ) : ℝ := G.c * φ ^ 2

/-- The dissipative amplitude `:= exp(-S_I[φ] / (2ℏ))`. -/
def dissipativeAmp (φ : ℝ) : ℝ := Real.exp (-(G.S_I φ / (2 * G.ℏ)))

/-! ## Action-functional theorems -/

/-- **Proven**: at the saddle `φ = 0`, `S_I = 0`. -/
theorem S_I_at_zero : G.S_I 0 = 0 := by
  unfold S_I
  ring

/-- **Proven**: off the saddle, `S_I > 0`. -/
theorem S_I_pos_at_nonzero (φ : ℝ) (hφ : φ ≠ 0) : 0 < G.S_I φ := by
  unfold S_I
  have h_sq : 0 < φ ^ 2 := by positivity
  exact mul_pos G.c_pos h_sq

/-- **Proven**: `S_I ≥ 0` for all `φ`. -/
theorem S_I_nonneg_everywhere (φ : ℝ) : 0 ≤ G.S_I φ := by
  unfold S_I
  exact mul_nonneg G.c_pos.le (by positivity)

/-- **Proven**: the action saturates the UV coercivity bound with
`C := c`. -/
theorem is_uv_coercive (φ : ℝ) : G.c * ‖φ‖ ^ 2 ≤ G.S_I φ := by
  unfold S_I
  rw [Real.norm_eq_abs, sq_abs]

/-! ## Realisation of Tier A Module 3 (`UVCoercivityCarrier ℝ`) -/

/-- **Tier A Module 3 realisation**: builds an explicit
`UVCoercivityCarrier ℝ` from `G`. -/
def toUVCoercivityCarrier : UVCoercivityCarrier ℝ where
  C := G.c
  C_pos := G.c_pos
  S_I := G.S_I
  ℏ := G.ℏ
  ℏ_pos := G.ℏ_pos
  uv_coercivity_bound := G.is_uv_coercive

/-! ## Dissipative-amplitude theorems -/

/-- **Proven**: the dissipative amplitude is strictly positive. -/
theorem dissipativeAmp_pos (φ : ℝ) : 0 < G.dissipativeAmp φ := by
  unfold dissipativeAmp
  exact Real.exp_pos _

/-- **Proven**: at the saddle, the dissipative amplitude is `1`
(no damping). -/
theorem dissipativeAmp_at_zero_eq_one : G.dissipativeAmp 0 = 1 := by
  unfold dissipativeAmp
  rw [G.S_I_at_zero]
  simp

/-- **Proven**: the dissipative amplitude is at most `1` everywhere
(consequence of `S_I ≥ 0`). -/
theorem dissipativeAmp_le_one (φ : ℝ) : G.dissipativeAmp φ ≤ 1 := by
  unfold dissipativeAmp
  rw [Real.exp_le_one_iff]
  have h2ℏ : 0 < 2 * G.ℏ := by linarith [G.ℏ_pos]
  have hquot : 0 ≤ G.S_I φ / (2 * G.ℏ) :=
    div_nonneg (G.S_I_nonneg_everywhere φ) h2ℏ.le
  linarith

/-- **Proven**: off the saddle, the dissipative amplitude is strictly
less than `1` (paper's "Gaussian damping" statement). -/
theorem dissipativeAmp_lt_one_at_nonzero (φ : ℝ) (hφ : φ ≠ 0) :
    G.dissipativeAmp φ < 1 := by
  unfold dissipativeAmp
  rw [Real.exp_lt_one_iff]
  have hpos := G.S_I_pos_at_nonzero φ hφ
  have h2ℏ : 0 < 2 * G.ℏ := by linarith [G.ℏ_pos]
  have hquot : 0 < G.S_I φ / (2 * G.ℏ) := div_pos hpos h2ℏ
  linarith

/-- **Proven squared form**: `dissipativeAmp² = exp(-S_I/ℏ)`
(paper's central squared-amplitude claim, evaluated on the
zero-dim Gaussian). -/
theorem dissipativeAmp_squared (φ : ℝ) :
    G.dissipativeAmp φ ^ 2 = Real.exp (-(G.S_I φ / G.ℏ)) := by
  unfold dissipativeAmp
  rw [sq, ← Real.exp_add]
  congr 1
  have hℏ : G.ℏ ≠ 0 := ne_of_gt G.ℏ_pos
  field_simp
  ring

end ZeroDimQuadraticActionCarrier

/-! ## Capstone -/

/-- **Trivial existence**: `c = 1, ℏ = 1`. -/
theorem exists_trivial : ∃ _ : ZeroDimQuadraticActionCarrier, True :=
  ⟨{ c     := 1
   , c_pos := one_pos
   , ℏ     := 1
   , ℏ_pos := one_pos }, trivial⟩

/-- **Capstone bundle.** -/
theorem zero_dim_quadratic_action_concrete_bundle :
    ∃ _ : ZeroDimQuadraticActionCarrier, True :=
  exists_trivial

end CATEPTMain.Integration.ZeroDimQuadraticActionConcreteBridge

end
