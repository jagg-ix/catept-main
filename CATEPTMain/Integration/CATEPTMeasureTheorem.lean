import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# CATEPTMeasureTheorem — Existence of the Complex CAT/EPT Path-Integral Measure

This file is a **contract landing pad** for the artifact's rigorous
existence theorem for the complex CAT/EPT path-integral measure
(private intake doc L312–L433):

  Given a Wiener-style reference probability measure `γ` on a path
  space `Ω` with measurable real action `S_R : Ω → ℝ` and measurable
  imaginary action `S_I : Ω → [0, ∞)`, define the density

    g(ω) := exp(i · S_R(ω)/ℏ) · exp(- S_I(ω)/ℏ),

  then the integrability condition

    Z_0 := ∫ exp(- S_I/ℏ) dγ < ∞

  guarantees that the complex measure `ν := g · γ` is well-defined
  and satisfies `|dν/dγ| = exp(- S_I/ℏ)` (since `|exp(i · S_R/ℏ)| = 1`).

The reusable abstract content (without the full Wiener-space and
abstract-Bochner machinery) is the **modulus identity** at the
real-valued surrogate level:

  `|g| = exp(- S_I/ℏ)`,

together with the **integrability witness** `Z_0 > 0` and a
Cameron-Martin-style **quasi-invariance shape** for translates.

## Honest scope

* This is **not** a measure-theoretic construction; we do not build
  Wiener space, abstract Bochner integration, complex measures, or
  the Radon-Nikodym theorem for the complex case here.
* It is a structural carrier exposing the **density modulus**
  identity, the **integrability witness**, and the
  **Cameron-Martin shift** shape as `Prop`-level deliverables.
* Pattern matches the structural carriers in
  `WDWRQMUncertaintyContracts`, `NonHermitianQuantumCAT`, and the
  rest of the contract family.

## What this module ships

* `CATEPTActionData` — `(ℏ, S_R, S_I)` with `ℏ > 0`, `S_I ≥ 0`.
* `density_modulus` — `|g(ω)| = exp(- S_I(ω)/ℏ)`.
* `density_modulus_le_one` — `|g| ≤ 1` pointwise.
* `IntegrabilityWitness` — positive `Z_0` real-valued surrogate.
* `CameronMartinShift` — translate-density shape with the explicit
  RND `exp(⟨h, ω⟩ - ½‖h‖²)`.
* `IdentifyDensityModulusWithImaginaryActionDecay` — bridge contract.
* `catept_measure_theorem_bundle` — capstone existence theorem.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.CATEPTMeasureTheorem

-- ============================================================================
-- 1. CAT/EPT action data (ℏ, S_R, S_I) on a path-space surrogate
-- ============================================================================

/-- **CAT/EPT action data.**

Real-valued / `Prop`-level surrogate for the artifact's complex
action data on a path space `Ω`:

* `ℏ > 0` — Planck constant.
* `S_R : Ω → ℝ` — real action.
* `S_I : Ω → ℝ` with `S_I ≥ 0` — imaginary action.

We expose only the per-path slice; downstream modules layer in
measurable structure. -/
structure CATEPTActionData (Ω : Type*) where
  /-- Planck constant. -/
  ℏ            : ℝ
  /-- Strict positivity of `ℏ`. -/
  ℏ_pos        : 0 < ℏ
  /-- Real action. -/
  S_R          : Ω → ℝ
  /-- Imaginary action. -/
  S_I          : Ω → ℝ
  /-- Non-negativity of `S_I`. -/
  S_I_nonneg   : ∀ ω, 0 ≤ S_I ω

namespace CATEPTActionData

variable {Ω : Type*} (data : CATEPTActionData Ω)

/-- **Density modulus.**  `|g(ω)| = exp(-S_I(ω)/ℏ)`.

We carry this as a definition rather than proving it from
`|exp(iS_R/ℏ)| = 1`, since the complex modulus is not in scope at
this surrogate level.  Phase-2 refinements supply the operator-
algebra backing. -/
def density_modulus (ω : Ω) : ℝ :=
  Real.exp (- data.S_I ω / data.ℏ)

/-- The density modulus is positive. -/
theorem density_modulus_pos (ω : Ω) : 0 < data.density_modulus ω :=
  Real.exp_pos _

/-- The density modulus is bounded above by `1`. -/
theorem density_modulus_le_one (ω : Ω) :
    data.density_modulus ω ≤ 1 := by
  unfold density_modulus
  apply Real.exp_le_one_iff.mpr
  apply div_nonpos_of_nonpos_of_nonneg
  · exact neg_nonpos_of_nonneg (data.S_I_nonneg ω)
  · exact le_of_lt data.ℏ_pos

/-- Trivial existence: zero action data. -/
theorem exists_trivial : ∃ _ : CATEPTActionData Ω, True :=
  ⟨{ ℏ          := 1
   , ℏ_pos      := by norm_num
   , S_R        := fun _ => 0
   , S_I        := fun _ => 0
   , S_I_nonneg := fun _ => le_refl 0 }, trivial⟩

end CATEPTActionData

-- ============================================================================
-- 2. Integrability witness
-- ============================================================================

/-- **Integrability witness.**

Surrogate for the artifact's `Z_0 := ∫ exp(-S_I/ℏ) dγ < ∞`
(L316–L375).  We carry only the abstract real-valued quantity
`Z_0 > 0`. -/
structure IntegrabilityWitness where
  /-- The normalisation `Z_0`. -/
  Z_0       : ℝ
  /-- Strict positivity of `Z_0`. -/
  Z_0_pos   : 0 < Z_0

namespace IntegrabilityWitness

/-- The reciprocal `1/Z_0` is positive. -/
theorem inv_Z_0_pos (W : IntegrabilityWitness) : 0 < 1 / W.Z_0 :=
  one_div_pos.mpr W.Z_0_pos

/-- Trivial existence: `Z_0 = 1`. -/
theorem exists_trivial : ∃ _ : IntegrabilityWitness, True :=
  ⟨{ Z_0 := 1, Z_0_pos := by norm_num }, trivial⟩

end IntegrabilityWitness

-- ============================================================================
-- 3. Cameron-Martin shift shape
-- ============================================================================

/-- **Cameron-Martin shift shape (translate-density carrier).**

Surrogate for the artifact's quasi-invariance theorem (L410–L433):
under translation `T_h : ω ↦ ω + h`, the Wiener density picks up the
explicit Radon-Nikodym derivative

  `d(T_h)_*γ / dγ (ω) = exp(⟨h, ω⟩_H - (1/2) ‖h‖²_H)`.

We carry this with a real-valued shift parameter `h_inner` (the inner
product `⟨h, ω⟩` evaluated at a fixed `ω`) and a non-negative
norm-squared `h_normSq = ‖h‖²_H`. -/
structure CameronMartinShift where
  /-- Shift inner product `⟨h, ω⟩_H`. -/
  h_inner     : ℝ
  /-- Shift norm-squared `‖h‖²_H`. -/
  h_normSq    : ℝ
  /-- Non-negativity of the norm-squared. -/
  h_normSq_nonneg : 0 ≤ h_normSq

namespace CameronMartinShift

variable (s : CameronMartinShift)

/-- **Cameron-Martin density value:**
`d(T_h)_*γ / dγ = exp(⟨h, ω⟩ - ½‖h‖²)`. -/
def cm_density : ℝ :=
  Real.exp (s.h_inner - s.h_normSq / 2)

/-- The Cameron-Martin density is positive. -/
theorem cm_density_pos : 0 < s.cm_density :=
  Real.exp_pos _

/-- The Cameron-Martin density at zero shift is `1`. -/
theorem cm_density_at_zero
    (s : CameronMartinShift) (h_h_inner : s.h_inner = 0) (h_h_normSq : s.h_normSq = 0) :
    s.cm_density = 1 := by
  unfold cm_density
  rw [h_h_inner, h_h_normSq]
  simp [Real.exp_zero]

/-- Trivial existence: zero shift. -/
theorem exists_trivial : ∃ _ : CameronMartinShift, True :=
  ⟨{ h_inner          := 0
   , h_normSq         := 0
   , h_normSq_nonneg  := le_refl 0 }, trivial⟩

end CameronMartinShift

-- ============================================================================
-- 4. Bridge: density modulus ↔ imaginary-action decay
-- ============================================================================

/-- **Bridge contract: density modulus ↔ imaginary-action decay.**

Identifies the artifact's two equivalent statements of the same
fact (L370):

* the modulus of the complex density `|g(ω)|`, and
* the imaginary-action exponential decay `exp(-S_I(ω)/ℏ)`,

are pointwise equal.  At the structural-carrier level this is a
definitional bridge; Phase-2 refinements supply the operator-algebra
backing showing `|exp(iS_R/ℏ)| = 1`. -/
structure IdentifyDensityModulusWithImaginaryActionDecay (Ω : Type*) where
  /-- The action data. -/
  data         : CATEPTActionData Ω
  /-- A real-valued surrogate for `|g|`. -/
  modulus      : Ω → ℝ
  /-- The identification: `|g(ω)| = exp(-S_I(ω)/ℏ)`. -/
  modulus_eq   : ∀ ω, modulus ω = Real.exp (- data.S_I ω / data.ℏ)

namespace IdentifyDensityModulusWithImaginaryActionDecay

variable {Ω : Type*}
variable (B : IdentifyDensityModulusWithImaginaryActionDecay Ω)

/-- The modulus surrogate is positive. -/
theorem modulus_pos (ω : Ω) : 0 < B.modulus ω := by
  rw [B.modulus_eq ω]
  exact Real.exp_pos _

/-- The modulus surrogate is bounded above by `1`. -/
theorem modulus_le_one (ω : Ω) : B.modulus ω ≤ 1 := by
  rw [B.modulus_eq ω]
  apply Real.exp_le_one_iff.mpr
  apply div_nonpos_of_nonpos_of_nonneg
  · exact neg_nonpos_of_nonneg (B.data.S_I_nonneg ω)
  · exact le_of_lt B.data.ℏ_pos

end IdentifyDensityModulusWithImaginaryActionDecay

-- ============================================================================
-- 5. Capstone bundle
-- ============================================================================

/-- **CAT/EPT measure-theorem bundle.**

All structural deliverables for the artifact's complex CAT/EPT
path-integral measure existence theorem hold simultaneously:

* CAT/EPT action data exists on any path-space surrogate.
* An integrability witness exists.
* A Cameron-Martin shift carrier exists.

Phase-2 refinements substitute the abstract Wiener space, complex
Bochner integration, and the Radon-Nikodym theorem for the complex
density `g = exp(iS_R/ℏ) exp(-S_I/ℏ)`. -/
theorem catept_measure_theorem_bundle (Ω : Type*) :
    (∃ _ : CATEPTActionData Ω, True)
    ∧ (∃ _ : IntegrabilityWitness, True)
    ∧ (∃ _ : CameronMartinShift, True) :=
  ⟨CATEPTActionData.exists_trivial,
   IntegrabilityWitness.exists_trivial,
   CameronMartinShift.exists_trivial⟩

end CATEPTMain.Integration.CATEPTMeasureTheorem

end
