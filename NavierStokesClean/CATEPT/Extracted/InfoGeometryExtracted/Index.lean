import NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.Foundations
import NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.Atoms
import NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.HolladaySymmetryCore
import NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.UnifiedComplexActionCore

namespace NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted

noncomputable section

/-!
Top-level theorem/index surface for extracted InfoGeometry information-geometry modules.
This provides a stable anchor set for downstream integration and audits.
-/

/-- Canonical theorem anchors exposed by extracted core modules. -/
def theoremIndex : List String :=
  [ "HamiltonJacobi_properTimePhase"
  , "Phase_EM_spin_gravity"
  , "InfluenceFunctional_imPart_nonneg"
  , "Clock_def_time_from_phase"
  , "Phase_Gravity_Thermal_Symmetry_Unification"
  , "HolladayVonBaeyerTheorem"
  , "omegaLT_point_from_atoms_eq"
  , "effective_g_atom_0120_eq"
  , "extractedClockFromAtomPhase_eq"
  ]

/-- Canonical atom declaration anchors from 0099..0120 ingestion. -/
def atomDeclIndex : List String :=
  [ "S0099.omegaLT_point"
  , "S0101.omegaLT_expect"
  , "S0102.a_mu_with_backreaction"
  , "S0105.gravitational_constant"
  , "S0107.simulate_writhe_distribution"
  , "S0110.effective_g"
  , "S0112.hyperbolic_volume"
  , "S0120.effective_g"
  ]

/-- Module-level import surface for quick tooling introspection. -/
def moduleIndex : List String :=
  [ "NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.Foundations"
  , "NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.Atoms"
  , "NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.HolladaySymmetryCore"
  , "NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted.UnifiedComplexActionCore"
  ]

/-- The extracted theorem index is intentionally non-empty. -/
theorem theoremIndex_nonempty : theoremIndex ≠ [] := by
  simp [theoremIndex]

/-- The atom declaration index is intentionally non-empty. -/
theorem atomDeclIndex_nonempty : atomDeclIndex ≠ [] := by
  simp [atomDeclIndex]

/-- Required anchor theorem name is present. -/
theorem theoremIndex_contains_hamiltonJacobi :
    "HamiltonJacobi_properTimePhase" ∈ theoremIndex := by
  simp [theoremIndex]

/-- Required atom anchor is present. -/
theorem atomDeclIndex_contains_omegaLT :
    "S0099.omegaLT_point" ∈ atomDeclIndex := by
  simp [atomDeclIndex]

/-- Expose a lightweight audit checksum based on index lengths. -/
def extractedIndexFootprint : Nat :=
  theoremIndex.length + atomDeclIndex.length + moduleIndex.length

theorem extractedIndexFootprint_pos : 0 < extractedIndexFootprint := by
  decide

end

end NavierStokesClean.CATEPT.Extracted.InfoGeometryExtracted
