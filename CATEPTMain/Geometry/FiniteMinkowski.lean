import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Analysis.Normed.Field.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-!
# Finite Minkowski Spacetime — Pure Geometric Core

A reusable, NS-independent harvest of the finite-dimensional Minkowski
spacetime primitives (`Fin 4 → ℝ` carrier with signature `(−+++)`) and
their causal structure.

## Provenance

This module is a careful **harvest** of the *non-NS-specific* sections of

  `NavierStokesClean/CATEPT/CATEPTSpaceTime.lean`

(present in catept-main's in-tree NS lib and in the
`navier-stokes-project-clean-translator` sibling repo).  The original NS
file mixes (a) reusable Minkowski geometry, (b) NS-specific velocity
fields, (c) entropic-lapse / NS-MIS content, (d) GRTensorKernel-bound
metric types.  This module extracts only (a), keeping the dependency
graph clean for future consumers (the canonical
`CATEPTMain/Integration/CATEPTSpaceTime.lean` spine, the `Adapter` ports
in `CATEPTMain/Domains/Adapters/`, and any new geometry consumer).

Specifically harvested:
- §1 core coordinate types (`CATEPTSpace`, `CATEPTST`, `CATEPTTime`)
- §3 spacetime decomposition (`CATEPTST.time/space/ofTimeSpace`)
- §3b Minkowski causal structure (`spatialNorm2`, `minkowskiNorm2`,
  `CausalTimelike/Lightlike/Spacelike`, `Lightcone`, `InsideLightcone`
  etc., `SubluminalVelocity`, `NoFTLBound`, `causal_trichotomy`,
  `timelike_time_dominates`)

Deliberately **not** harvested:
- §2 metric types — depend on `MetricField` from GRTensorKernel
  (NS-specific machinery).
- `CATEPTVelocityField` — NS-specific.
- §3c entropic lapse — moved to a sibling file
  `EntropicLapse.lean` in a follow-up commit.
- NS-MIS / parabolic-diffusion content — stays in the NS bridge layer.

## Namespace

The harvested content lives under `CATEPTMain.Geometry.FiniteMinkowski`
(the new location), **not** under the original `NavierStokesClean.CATEPT`
namespace.  This means:

- Existing consumers that `import NavierStokesClean.CATEPT.CATEPTSpaceTime`
  are **untouched** by this PR; they continue to access the original
  symbols at the original namespace.
- New consumers should `import CATEPTMain.Geometry.FiniteMinkowski` and
  access the symbols at `CATEPTMain.Geometry.FiniteMinkowski.*`.
- When `NavierStokesClean/` becomes its own sibling
  (`catept-ns-millennium`), this module continues to compile in
  `catept-main` standalone.

## Architectural fit

```text
Mathlib only
    ↓
FiniteMinkowski (this file)              — pure geometry, zero CATEPT/NS deps
    ↓
CATEPTSTAdapter (next PR)                — bridge to CATEPTSpacetimeModel
    ↓
CATEPTSpacetimeModel + canonical spine   — already in catept-main
```

This is the proposal-targeted **harvest by concept** approach (rather
than wholesale merge of the NS-clean file).  The old NS file remains the
authoritative source for NS-specific content; this module owns the
reusable geometric core.
-/

set_option autoImplicit false

namespace CATEPTMain.Geometry.FiniteMinkowski

-- ═══════════════════════════════════════════════════════════════════════
-- §1. Core Coordinate Types
-- ═══════════════════════════════════════════════════════════════════════

/-- **3D spatial domain**: `Fin 3 → ℝ`. -/
abbrev CATEPTSpace : Type := Fin 3 → ℝ

/-- **4D spacetime domain**: `Fin 4 → ℝ` with signature convention
`(−+++)` — index `0` is the time component, indices `1,2,3` are
spatial. -/
abbrev CATEPTST : Type := Fin 4 → ℝ

/-- **1D time coordinate** alias. -/
abbrev CATEPTTime : Type := ℝ

-- ═══════════════════════════════════════════════════════════════════════
-- §3. Spacetime Decomposition
-- ═══════════════════════════════════════════════════════════════════════

namespace CATEPTST

/-- Extract the time component of a spacetime event. -/
def time (x : CATEPTST) : ℝ := x 0

/-- Extract the spatial components of a spacetime event. -/
def space (x : CATEPTST) : CATEPTSpace := fun i => x i.succ

/-- Assemble a spacetime event from a time component and spatial components. -/
def ofTimeSpace (t : ℝ) (x : CATEPTSpace) : CATEPTST := Fin.cons t x

@[simp] lemma time_ofTimeSpace (t : ℝ) (x : CATEPTSpace) :
    (ofTimeSpace t x).time = t := by
  simp [time, ofTimeSpace]

@[simp] lemma space_ofTimeSpace (t : ℝ) (x : CATEPTSpace) :
    (ofTimeSpace t x).space = x := by
  funext i; simp [space, ofTimeSpace, Fin.cons_succ]

end CATEPTST

-- ═══════════════════════════════════════════════════════════════════════
-- §3b. Minkowski Causal Structure
-- ═══════════════════════════════════════════════════════════════════════

/-- Squared spatial norm of a displacement: `Δx₁² + Δx₂² + Δx₃²`. -/
def spatialNorm2 (Δx : CATEPTST) : ℝ :=
  ∑ i : Fin 3, (Δx i.succ) ^ 2

/-- Minkowski norm squared with signature `(−+++)`:
`−Δx₀² + Δx₁² + Δx₂² + Δx₃²`.

Sign convention: timelike vectors have `minkowskiNorm2 Δx < 0`. -/
def minkowskiNorm2 (Δx : CATEPTST) : ℝ :=
  -(Δx 0) ^ 2 + spatialNorm2 Δx

/-- A displacement is **timelike** — strictly inside the lightcone. -/
def CausalTimelike (Δx : CATEPTST) : Prop := minkowskiNorm2 Δx < 0

/-- A displacement is **lightlike (null)** — on the lightcone boundary. -/
def CausalLightlike (Δx : CATEPTST) : Prop := Δx ≠ 0 ∧ minkowskiNorm2 Δx = 0

/-- A displacement is **spacelike** — strictly outside the lightcone. -/
def CausalSpacelike (Δx : CATEPTST) : Prop := minkowskiNorm2 Δx > 0

/-- The **lightcone** at event `x`: events connected by null separation. -/
def Lightcone (x : CATEPTST) : Set CATEPTST :=
  { y | minkowskiNorm2 (y - x) = 0 }

/-- Event `y` is **inside the lightcone** of `x` (timelike separated). -/
def InsideLightcone (x y : CATEPTST) : Prop := CausalTimelike (y - x)

/-- Event `y` is **on the lightcone** of `x` (null separated). -/
def OnLightcone (x y : CATEPTST) : Prop := CausalLightlike (y - x)

/-- Event `y` is **outside the lightcone** of `x` (spacelike separated). -/
def OutsideLightcone (x y : CATEPTST) : Prop := CausalSpacelike (y - x)

/-- A spatial velocity is **subluminal** (speed strictly less than `c = 1`). -/
def SubluminalVelocity (v : CATEPTSpace) : Prop :=
  ∑ i : Fin 3, (v i) ^ 2 < 1

/-- The **no-FTL predicate** on a velocity-field type: every physical
velocity is subluminal. -/
def NoFTLBound (velocityField : CATEPTSpace → Prop) : Prop :=
  ∀ v : CATEPTSpace, velocityField v → SubluminalVelocity v

-- ═══════════════════════════════════════════════════════════════════════
-- Core theorems
-- ═══════════════════════════════════════════════════════════════════════

/-- **Causal trichotomy**: every nonzero displacement is exactly one of
timelike, lightlike, or spacelike (and the zero displacement is none of
these). -/
theorem causal_trichotomy (Δx : CATEPTST) :
    CausalTimelike Δx ∨ CausalLightlike Δx ∨ CausalSpacelike Δx ∨ Δx = 0 := by
  by_cases h0 : Δx = 0
  · right; right; right; exact h0
  · rcases lt_trichotomy (minkowskiNorm2 Δx) 0 with hlt | heq | hgt
    · left; exact hlt
    · right; left; exact ⟨h0, heq⟩
    · right; right; left; exact hgt

/-- **Timelike time dominance**: if `Δx` is timelike then the squared
time component strictly dominates the squared spatial norm. -/
theorem timelike_time_dominates {Δx : CATEPTST} (h : CausalTimelike Δx) :
    (Δx 0) ^ 2 > spatialNorm2 Δx := by
  unfold CausalTimelike minkowskiNorm2 at h
  linarith

/-- **Squared norm non-negativity**: `spatialNorm2` is non-negative. -/
theorem spatialNorm2_nonneg (Δx : CATEPTST) : 0 ≤ spatialNorm2 Δx := by
  unfold spatialNorm2
  apply Finset.sum_nonneg
  intro i _
  exact sq_nonneg _

/-- **Spacelike from time-zero**: a non-zero displacement with vanishing
time component is spacelike (`spatialNorm2 Δx > 0`). -/
theorem spacelike_of_time_zero {Δx : CATEPTST}
    (h0 : Δx ≠ 0) (htime : Δx 0 = 0) : CausalSpacelike Δx := by
  -- minkowskiNorm2 = -(Δx 0)² + spatialNorm2 ≥ 0 with equality iff Δx 0 = 0
  -- and all spatial components vanish.  Here Δx 0 = 0 already, so we just
  -- need spatialNorm2 Δx > 0; that follows because Δx is non-zero.
  unfold CausalSpacelike minkowskiNorm2
  rw [htime]
  have h_nn : 0 ≤ spatialNorm2 Δx := spatialNorm2_nonneg Δx
  rcases lt_or_eq_of_le h_nn with h | h
  · linarith
  -- Sum of squares = 0 ⟹ all spatial components vanish; combined with
  -- htime, Δx = 0 contradicting h0.
  exfalso
  apply h0
  funext i
  rcases Fin.eq_zero_or_eq_succ i with hi | ⟨j, hj⟩
  · rw [hi]; exact htime
  · rw [hj]
    have hsum : ∑ (k : Fin 3), (Δx k.succ) ^ 2 = 0 := h.symm
    have h_each : ∀ k ∈ (Finset.univ : Finset (Fin 3)), 0 ≤ (Δx k.succ) ^ 2 :=
      fun k _ => sq_nonneg _
    have hk : (Δx j.succ) ^ 2 = 0 :=
      (Finset.sum_eq_zero_iff_of_nonneg h_each).mp hsum j (Finset.mem_univ j)
    exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp hk

/-- **NoFTLBound is monotone in the velocity field**: if every velocity
in the larger field is subluminal, the same holds for any sub-field. -/
theorem noFTLBound_mono {V₁ V₂ : CATEPTSpace → Prop}
    (h_le : ∀ v, V₁ v → V₂ v) (h₂ : NoFTLBound V₂) :
    NoFTLBound V₁ := by
  intro v hv
  exact h₂ v (h_le v hv)

end CATEPTMain.Geometry.FiniteMinkowski
