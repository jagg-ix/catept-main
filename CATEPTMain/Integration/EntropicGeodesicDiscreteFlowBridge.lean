import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Order.BigOperators.Group.Finset

/-!
# EntropicGeodesicDiscreteFlowBridge — discrete-event entropy on a parametric geodesic

Verified-content carrier for the **discrete-entropy-flow** structure
along a one-parameter geodesic, generalising the intake's specific
"trefoil collapse-geodesic" example
(`docs/intake/chatgpt-making-history-in-theory3-leverage-map.md`,
lines 982–1030, "Sector S17 — Topological and Spectral Geodesics") to
*any* geodesic whose entropy injections occur at a finite set of
parameter values.

## What is verified

The intake gives the discrete entropy-injection form

  `S_I(θ) = Σᵢ δ(θ − θᵢ) · εᵢ`

with `εᵢ ≥ 0` ("each crossing contributes ΔS_I").  This module ships
the **cumulative** form

  `cumulativeEntropyFlow θ := sum over i with θᵢ ≤ θ of εᵢ`

(replacing the distributional δ-function form with its integral) and
proves **monotonicity** from `Finset.sum_le_sum_of_subset_of_nonneg`.

## Generic structure, no knot-type commitment

The carrier is geometric/topological-type agnostic:

* `WindingChirality` (`left | right`) — abstract orientation.
* `WindingData` (integer `w` + chirality `χ`) — type-quantised winding.
* `DiscreteEntropyEvents` — finite list of `(θᵢ, εᵢ)` with `εᵢ ≥ 0`.

The **trefoil knot** is one canonical *instance* of this structure
(3-crossing torus knot with definite chirality, as in Ghys 2009
*Lorenz Attractors and the Modular Surface*, arXiv:2001.05733;
PDF on disk).  The trefoil reference is documentary — the verified
content holds for any geodesic with discrete entropy events.

## What this module ships

* `WindingChirality` — abstract orientation enum.
* `WindingData` — `(w : ℤ, χ : WindingChirality)`.
* `DiscreteEntropyEvents` — list of `(θᵢ, εᵢ)` with `εᵢ ≥ 0`.
* `cumulativeEntropyFlow` — proven-monotone cumulative sum.
* `cumulativeEntropyFlow_nonneg`, `cumulativeEntropyFlow_monotone`.
* `EntropicGeodesicDiscreteFlow` — composite carrier.
* `winding_quantization` — winding number is integer-quantised by type.
* `entropic_geodesic_discrete_flow_bundle` capstone.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.EntropicGeodesicDiscreteFlowBridge

open Finset

/-! ## §1. Generic winding data -/

/-- **Winding chirality** — abstract orientation. -/
inductive WindingChirality
  | left
  | right
  deriving DecidableEq, Inhabited, Repr

/-- **Winding data.**

Integer winding number `w ∈ ℤ` plus a chirality.  Type-level
quantisation (the winding sits in `ℤ`).

The trefoil is a `(w = 3, χ = .left)` instance; other knots, braid
periodic orbits, modular knots, etc. are equally valid instances. -/
structure WindingData where
  w     : ℤ
  χ     : WindingChirality
  deriving DecidableEq, Repr

namespace WindingData

theorem exists_trivial : ∃ _ : WindingData, True :=
  ⟨{ w := 0, χ := .left }, trivial⟩

end WindingData

/-! ## §2. Discrete entropy events -/

/-- **Discrete entropy events** along the geodesic.

A finite list of crossing parameters `θᵢ` paired with non-negative
entropy increments `εᵢ ≥ 0`. -/
structure DiscreteEntropyEvents where
  /-- Number of events. -/
  n         : ℕ
  /-- Crossing parameters (one per event). -/
  θ         : Fin n → ℝ
  /-- Entropy increments. -/
  ε         : Fin n → ℝ
  /-- Non-negativity of each increment. -/
  ε_nonneg  : ∀ i, 0 ≤ ε i

namespace DiscreteEntropyEvents

variable (E : DiscreteEntropyEvents)

/-- **Cumulative entropy flow** at parameter `θ`:
sum of `εᵢ` over events with `θᵢ ≤ θ`. -/
def cumulativeEntropyFlow (θ : ℝ) : ℝ :=
  letI : DecidablePred (fun i : Fin E.n => E.θ i ≤ θ) :=
    fun _ => Classical.propDecidable _
  ∑ i ∈ Finset.univ.filter (fun i : Fin E.n => E.θ i ≤ θ), E.ε i

/-- Cumulative entropy flow is non-negative. -/
theorem cumulativeEntropyFlow_nonneg (θ : ℝ) :
    0 ≤ E.cumulativeEntropyFlow θ :=
  Finset.sum_nonneg (fun i _ => E.ε_nonneg i)

/-- **Proven monotonicity:** `cumulativeEntropyFlow` is non-decreasing
in `θ`. The set of events with `θᵢ ≤ θ₁` is contained in the set with
`θᵢ ≤ θ₂` whenever `θ₁ ≤ θ₂`, and we sum non-negative increments
over a larger set. -/
theorem cumulativeEntropyFlow_monotone {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    E.cumulativeEntropyFlow θ₁ ≤ E.cumulativeEntropyFlow θ₂ := by
  unfold cumulativeEntropyFlow
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · intro i hi
    rw [Finset.mem_filter] at hi ⊢
    exact ⟨hi.1, le_trans hi.2 h⟩
  · intro i _ _
    exact E.ε_nonneg i

/-- Trivial existence: zero events. -/
theorem exists_trivial : ∃ _ : DiscreteEntropyEvents, True := by
  refine ⟨{ n        := 0
          , θ        := Fin.elim0
          , ε        := Fin.elim0
          , ε_nonneg := ?_ }, trivial⟩
  intro i; exact i.elim0

end DiscreteEntropyEvents

/-! ## §3. Entropic geodesic with discrete-event flow -/

/-- **Entropic geodesic with discrete-event flow.**

Holds the winding data and a discrete-entropy-event family on the
geodesic; cumulative entropy flow is automatically monotone.

Generic over the underlying knot/braid type — the structure works for
any one-parameter geodesic with a finite set of entropy injections. -/
structure EntropicGeodesicDiscreteFlow where
  /-- Winding data (integer winding + chirality). -/
  winding   : WindingData
  /-- The discrete-entropy-event family. -/
  events    : DiscreteEntropyEvents

namespace EntropicGeodesicDiscreteFlow

variable (G : EntropicGeodesicDiscreteFlow)

/-- **Extraction:** cumulative entropy flow at parameter `θ`. -/
def cumulativeEntropyFlow (θ : ℝ) : ℝ :=
  G.events.cumulativeEntropyFlow θ

/-- **Extraction:** cumulative entropy is non-negative. -/
theorem cumulativeEntropyFlow_nonneg (θ : ℝ) :
    0 ≤ G.cumulativeEntropyFlow θ :=
  G.events.cumulativeEntropyFlow_nonneg θ

/-- **Extraction (proven):** cumulative entropy flow is monotone. -/
theorem cumulativeEntropyFlow_monotone {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    G.cumulativeEntropyFlow θ₁ ≤ G.cumulativeEntropyFlow θ₂ :=
  G.events.cumulativeEntropyFlow_monotone h

/-- The winding number is integer-quantised (carrier-level). -/
theorem winding_quantization : ∃ n : ℤ, G.winding.w = n :=
  ⟨G.winding.w, rfl⟩

/-- Trivial existence. -/
theorem exists_trivial : ∃ _ : EntropicGeodesicDiscreteFlow, True := by
  obtain ⟨W, _⟩ := WindingData.exists_trivial
  obtain ⟨E, _⟩ := DiscreteEntropyEvents.exists_trivial
  exact ⟨{ winding := W, events := E }, trivial⟩

end EntropicGeodesicDiscreteFlow

/-! ## §4. Capstone -/

/-- **Discrete-flow entropic-geodesic bundle.** -/
theorem entropic_geodesic_discrete_flow_bundle :
    ∃ _ : EntropicGeodesicDiscreteFlow, True :=
  EntropicGeodesicDiscreteFlow.exists_trivial

end CATEPTMain.Integration.EntropicGeodesicDiscreteFlowBridge

end
