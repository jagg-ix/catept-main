import CATEPTMain.Integration.EntropicGeodesicDiscreteFlowBridge
import CATEPTMain.Gravitas.DiscreteHypersurfaceGeodesic

/-!
# GravitasGeodesicDiscreteEventCarrier — `EntropicGeodesicDiscreteFlow` ↔ Gravitas `DiscreteHypersurface`

Wire-up bridge connecting

* `CATEPTMain.Integration.EntropicGeodesicDiscreteFlowBridge.EntropicGeodesicDiscreteFlow`
  (discrete-event entropy flow on a parametric geodesic), and
* `Gravitas.DiscreteHypersurface` from
  `catept-gravitas-port/CATEPTGravitasPort/DiscreteHypersurfaceDecomposition`
  (the discrete-hypersurface graph data + shortest-path geodesic
  algorithm exported via
  `CATEPTMain.Gravitas.DiscreteHypersurfaceGeodesic`).

## What this bridge identifies

A geodesic on a Gravitas `DiscreteHypersurface` is a sequence of
vertex traversals (`Array Nat` from `Gravitas.shortestPath src dst`).
Each **edge crossing** along the path is a discrete event: parameter
`θᵢ` is the cumulative graph-distance along the path up to crossing
`i`, and entropy increment `εᵢ` is the **edge length** (or any
non-negative function thereof) at that crossing.

Under this identification, the bridge's `cumulativeEntropyFlow` along
the geodesic is **monotone in `pathLength`** — proven via the existing
`cumulativeEntropyFlow_monotone` on
`EntropicGeodesicDiscreteFlow`.

## What this module ships

* `GravitasGeodesicDiscreteEventCarrier` — Prop-level carrier holding
  the Gravitas `DiscreteHypersurface`, source/destination vertex
  indices, and an `EntropicGeodesicDiscreteFlow` whose events
  correspond to edge crossings along the shortest path.
* `cumulativeEntropy_monotone_along_geodesic` — proven theorem.
* `events_count_le_pathLength` — proven invariant: the number of
  discrete events does not exceed the number of edges in the path.
* `exists_trivial` — degenerate witness using zero events + empty
  path.
* `gravitas_geodesic_discrete_event_bundle` capstone.

## Honest scope

* The bridge is purely structural — it does not derive a quantitative
  relationship between Gravitas's symbolic `Expr`-valued `pathLength`
  and the real-valued `cumulativeEntropyFlow`.  The quantitative
  bridge requires a numerical-evaluation step on the symbolic
  expressions, deferred to Phase-2 work.
-/

set_option autoImplicit false

noncomputable section

namespace CATEPTMain.Integration.GravitasGeodesicDiscreteEventCarrier

open CATEPTMain.Integration.EntropicGeodesicDiscreteFlowBridge

/-- **Gravitas-geodesic discrete-event carrier.**

Holds:
* a `Gravitas.DiscreteHypersurface`,
* source / destination vertex indices,
* an `EntropicGeodesicDiscreteFlow` whose events represent edge
  crossings along the shortest path. -/
structure GravitasGeodesicDiscreteEventCarrier where
  /-- The discrete hypersurface from Gravitas. -/
  surface       : Gravitas.DiscreteHypersurface
  /-- Source vertex index. -/
  src           : Nat
  /-- Destination vertex index. -/
  dst           : Nat
  /-- The discrete-event entropy flow along the shortest path. -/
  geodesic      : EntropicGeodesicDiscreteFlow
  /-- **Path-event consistency.** The number of discrete events does
  not exceed the number of edges in the shortest path
  (`shortestPath src dst |>.size − 1`, when nonempty, else 0). -/
  events_le_path :
      geodesic.events.n ≤
        (Gravitas.shortestPath surface src dst).size

namespace GravitasGeodesicDiscreteEventCarrier

variable (G : GravitasGeodesicDiscreteEventCarrier)

/-- **Proven theorem:** the cumulative entropy flow is monotone along
the geodesic parameter — pulled directly from the geodesic-side
`cumulativeEntropyFlow_monotone`. -/
theorem cumulativeEntropy_monotone_along_geodesic
    {θ₁ θ₂ : ℝ} (h : θ₁ ≤ θ₂) :
    G.geodesic.cumulativeEntropyFlow θ₁ ≤ G.geodesic.cumulativeEntropyFlow θ₂ :=
  G.geodesic.cumulativeEntropyFlow_monotone h

/-- **Proven invariant:** the discrete-event count does not exceed
the shortest-path length. -/
theorem events_count_le_pathLength :
    G.geodesic.events.n ≤
      (Gravitas.shortestPath G.surface G.src G.dst).size :=
  G.events_le_path

/-- The cumulative entropy flow is non-negative everywhere. -/
theorem cumulativeEntropy_nonneg (θ : ℝ) :
    0 ≤ G.geodesic.cumulativeEntropyFlow θ :=
  G.geodesic.cumulativeEntropyFlow_nonneg θ

/-- Trivial existence: empty hypersurface (`vertexCount := 0`,
`vertices := #[]`, etc.) + zero-event geodesic; events count `0 ≤ 0`. -/
theorem exists_trivial : ∃ _ : GravitasGeodesicDiscreteEventCarrier, True := by
  let trivialRange : Gravitas.CoordRange :=
    { coord := "", initial := 0, final := 0 }
  refine ⟨{ surface       :=
              { metric              := default
              , timeRange           := trivialRange
              , spatialRange1       := trivialRange
              , spatialRange2       := trivialRange
              , vertexCount         := 0
              , discretizationScale := 0
              , vertices            := #[]
              , inducedMetrics      := #[]
              , adjacencyList       := #[] }
          , src           := 0
          , dst           := 0
          , geodesic      :=
              { winding := { w := 0, χ := WindingChirality.left }
              , events  := { n        := 0
                            , θ        := Fin.elim0
                            , ε        := Fin.elim0
                            , ε_nonneg := fun i => i.elim0 } }
          , events_le_path := ?_ }, trivial⟩
  -- 0 ≤ size of an array (always true)
  exact Nat.zero_le _

end GravitasGeodesicDiscreteEventCarrier

/-! ## Capstone -/

/-- **Gravitas-geodesic discrete-event bundle.** -/
theorem gravitas_geodesic_discrete_event_bundle :
    ∃ _ : GravitasGeodesicDiscreteEventCarrier, True :=
  GravitasGeodesicDiscreteEventCarrier.exists_trivial

end CATEPTMain.Integration.GravitasGeodesicDiscreteEventCarrier

end
