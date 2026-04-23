import CATEPTMain.CATEPT.DiracMatrixAlgebra
import CATEPTMain.CATEPT.PerturbativeExpansionBridge

namespace CATEPTMain.CATEPT

/-!
# Feynman Diagram Algebra

This module defines the graph-theoretic and algebraic representation of Feynman diagrams
for use within the symbolic evaluation engine.
It connects external/internal momentum routing and maps vertices to the
`DiracAlgebra` defined in `DiracMatrixAlgebra`.
-/

/-- Identifies whether a diagram leg is incoming, outgoing, or internal. -/
inductive LegType
| incoming : LegType
| outgoing : LegType
| internal : LegType

/-- Representation of a line in a Feynman graph (e.g. holding momentum flux). -/
structure FeynmanLeg where
  /-- Role of the leg in the diagram. -/
  role : LegType
  /--
  The four-momentum flowing through this leg.
  For symbolic computation, this acts as the $p$ in Feynman slash $\not{p}$ evaluations.
  -/
  momentum : FourVector ℝ

/-- A vertex connecting multiple legs, weighted by some interaction coupling or Dirac structure. -/
structure FeynmanVertex where
  /-- The legs directly meeting at this interaction point. -/
  legs : List FeynmanLeg
  /-- The symbolic algebraic operator (like $\gamma^\mu$) at the vertex. -/
  operator : DiracAlgebra

/--
A complete graph representing a Feynman Diagram contribution.
-/
structure FeynmanDiagram where
  /-- List of all interaction vertices. -/
  vertices : List FeynmanVertex
  /-- List of all propagating lines connecting vertices. -/
  internal_legs : List FeynmanLeg
  /-- The extracted symmetry factor for the given graph topology. -/
  symmetry_factor : ℝ

/--
Evaluates a structured Feynman Diagram into its pure mathematical
Dirac trace / integral amplitude form, ready for Passarino-Veltman reduction.
-/
opaque evaluateDiagram (diagram : FeynmanDiagram) : DiracAlgebra

end CATEPTMain.CATEPT
