import CATEPTMain.CATEPT.CATEPT.SpinorPathIntegralBridge
import CATEPTMain.CATEPT.CATEPT.DiracMatrixAlgebra

namespace CATEPTMain.CATEPT.CATEPT

/-!
# Perturbative Expansion Bridge

This module bridges the exact path-integral transport layer (from `SpinorPathIntegralBridge.lean`)
to standard perturbative expansions (the Dyson series).
It maps the exponentiated action into a formal power series over the gauge coupling $\alpha$.
-/

/--
A formal definition for perturbative expansions.
Evaluates the path integral kernel into an asymptotic power series over a coupling constant.
-/
structure PerturbativeExpansion where
  /-- The free theory (zeroth order) propagator layer -/
  free_propagator : SpinorTransportLayer
  /--
  The functional mapping vertices to higher order terms.
  For symbolic purposes, we map an order $n$ to a generic complex amplitude contribution.
  -/
  order_term : ℕ → ℂ

/--
Extracts the zeroth order (free) propagator from a fully interacting spinor transport layer.
This effectively drops gauge connection fluctuations, reducing to pure Dirac propagation.
-/
opaque extractFreeAction (interacting_layer : SpinorTransportLayer) : SpinorTransportLayer

/--
The formal Dyson-expansion mapping: any interacting transport layer
gives rise to a `PerturbativeExpansion` carrying the free-propagator
zero-th-order contribution and a (here-trivial) order-`n` term map.

Was previously an `axiom` declaration; converted to a concrete
`noncomputable def` that produces a witness explicitly.  The
`order_term n := 0` choice is a placeholder — consumers requiring
non-trivial perturbative data should construct their own
`PerturbativeExpansion` with the appropriate vertex algebra.

Concrete operator-side derivation lives in the `catept-domain-gauge`
plugin's FEYNCALC Passarino-Veltman tooling.
-/
noncomputable def dyson_series_expansion (layer : SpinorTransportLayer) :
    PerturbativeExpansion :=
  { free_propagator := extractFreeAction layer
  , order_term      := fun _ => 0 }

end CATEPTMain.CATEPT.CATEPT
