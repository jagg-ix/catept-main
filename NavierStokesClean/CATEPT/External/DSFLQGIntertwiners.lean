import NavierStokesClean.CATEPT.External.DimensionalEmbeddings

namespace CATEPT.External.LQG

/--
  Intertwiner states act as the nodes of Penrose Spin Networks in Loop Quantum Gravity (LQG).
  They represent the SU(2)-invariant tensors (singlet states) mapping between
  the tensor product of incoming and outgoing SU(2) Spin-j representations.
  In physical terms, these nodes encode the quantized volume of space.
-/
structure IntertwinerSpace (incoming outgoing : List CATEPT.External.Hyperunits.SU2SpinRepresentation) where
  /-- The dimension of the invariant subspace resulting from the Clebsch-Gordan decomposition.
      This maps directly to the degrees of freedom of the quantum polyhedron's volume. -/
  invariant_dimension : ℕ

/-- Nontrivial intertwiner sector: strictly positive invariant dimension. -/
def IntertwinerSpace.nontrivial
    {incoming outgoing : List CATEPT.External.Hyperunits.SU2SpinRepresentation}
    (I : IntertwinerSpace incoming outgoing) : Prop :=
  0 < I.invariant_dimension

/-- Unfolding lemma for the nontrivial intertwiner predicate. -/
theorem IntertwinerSpace.nontrivial_iff
    {incoming outgoing : List CATEPT.External.Hyperunits.SU2SpinRepresentation}
    (I : IntertwinerSpace incoming outgoing) :
    I.nontrivial ↔ 0 < I.invariant_dimension :=
  Iff.rfl

/--
  A canonical formulation of a LQG Spin Network geometry, which couples
  graph combinatorial structures with SU(2) representations.
-/
structure SpinNetworkGeometry where
  /-- The set of edges (links), labeled by SU(2) spins mapping to quantized Areas. -/
  edges : List CATEPT.External.Hyperunits.SU2SpinRepresentation
  /-- The set of nodes (vertices), mapped to Intertwiners representing quantized Volumes. -/
  nodes : List (IntertwinerSpace edges edges)

/-- Number of edges in a spin network geometry. -/
def SpinNetworkGeometry.edgeCount (G : SpinNetworkGeometry) : ℕ :=
  G.edges.length

/-- Number of nodes in a spin network geometry. -/
def SpinNetworkGeometry.nodeCount (G : SpinNetworkGeometry) : ℕ :=
  G.nodes.length

/-- Edge count is always nonnegative. -/
theorem SpinNetworkGeometry.edgeCount_nonneg (G : SpinNetworkGeometry) :
    0 ≤ G.edgeCount := by
  unfold SpinNetworkGeometry.edgeCount
  exact Nat.zero_le _

/-- Edge count is zero exactly when there are no edges. -/
theorem SpinNetworkGeometry.edgeCount_eq_zero_iff (G : SpinNetworkGeometry) :
    G.edgeCount = 0 ↔ G.edges = [] := by
  unfold SpinNetworkGeometry.edgeCount
  simpa using List.length_eq_zero

/-- Any nonempty edge list yields strictly positive edge count. -/
theorem SpinNetworkGeometry.edgeCount_pos_of_edges_ne_nil
    (G : SpinNetworkGeometry) (h : G.edges ≠ []) :
    0 < G.edgeCount := by
  unfold SpinNetworkGeometry.edgeCount
  cases hEdges : G.edges with
  | nil =>
      exact (False.elim (h hEdges))
  | cons _ _ =>
      simp [hEdges]

/-- Node count is always nonnegative. -/
theorem SpinNetworkGeometry.nodeCount_nonneg (G : SpinNetworkGeometry) :
    0 ≤ G.nodeCount := by
  unfold SpinNetworkGeometry.nodeCount
  exact Nat.zero_le _

/-- Node count is zero exactly when there are no nodes. -/
theorem SpinNetworkGeometry.nodeCount_eq_zero_iff (G : SpinNetworkGeometry) :
    G.nodeCount = 0 ↔ G.nodes = [] := by
  unfold SpinNetworkGeometry.nodeCount
  simpa using List.length_eq_zero

/-- Any nonempty node list yields strictly positive node count. -/
theorem SpinNetworkGeometry.nodeCount_pos_of_nodes_ne_nil
    (G : SpinNetworkGeometry) (h : G.nodes ≠ []) :
    0 < G.nodeCount := by
  unfold SpinNetworkGeometry.nodeCount
  cases hNodes : G.nodes with
  | nil =>
      exact (False.elim (h hNodes))
  | cons _ _ =>
      simp [hNodes]

end CATEPT.External.LQG
