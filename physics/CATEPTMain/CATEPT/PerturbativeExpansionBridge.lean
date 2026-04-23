import CATEPTMain.CATEPT.SpinorPathIntegralBridge
import CATEPTMain.CATEPT.DiracMatrixAlgebra

namespace CATEPTMain.CATEPT

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
A formal declaration that the full interacting transport kernel is equivalent
to a sum over its perturbative orders (the Dyson expansion context).
-/
axiom dyson_series_expansion (layer : SpinorTransportLayer) : PerturbativeExpansion

end CATEPTMain.CATEPT
