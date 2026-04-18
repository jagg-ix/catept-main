import NavierStokes.NSQEImportG1Catalog

/-!
# NSQEImportG1AuditProvenance

Audit-oriented provenance view for the QE-derived G1 import lane.

This module provides a compact, machine-readable mapping from QE source clusters
to Lean target modules used in the Navier-Stokes audit surface, without changing
core certificate semantics.
-/

namespace NavierStokes.MillenniumAudit.G1Provenance

set_option autoImplicit false

open NavierStokes.Millennium.QEImportG1

/-- Provenance row emitted for audit tooling. -/
structure G1AuditProvenanceRow where
  family : QECoreFamily
  sourceFile : String
  targetModule : String
  contractId : String
  strictApprox : Nat
  equationsTotal : Nat
  deriving Repr, DecidableEq

/-- Full provenance projection from G1 seed clusters. -/
def g1AuditProvenanceRows : List G1AuditProvenanceRow :=
  g1SeedClusters.map (fun c =>
    { family := c.family
      sourceFile := c.sourceFile
      targetModule := c.leanTarget
      contractId := c.contractId
      strictApprox := c.strictApprox
      equationsTotal := c.equationsTotal })

/-- Audit-relevant targets for the current Path-C-focused bridge lane. -/
def g1PathCAuditTargets : List String :=
  [ "NavierStokes.NSParsevalT3Bridge"
  , "NavierStokes.NSEnstrophyPhysicalizationBridge"
  , "NavierStokes.NSGalerkinCompactness"
  , "NavierStokes.MillenniumAuditCertificate" ]

/-- G1 rows touching the Path-C audit lane. -/
def g1PathCAuditRows : List G1AuditProvenanceRow :=
  g1AuditProvenanceRows.filter (fun r => r.targetModule ∈ g1PathCAuditTargets)

theorem g1AuditProvenanceRows_nonempty : g1AuditProvenanceRows ≠ [] := by
  decide

theorem g1PathCAuditRows_nonempty : g1PathCAuditRows ≠ [] := by
  decide

/-- Strict mass carried by the full provenance projection. -/
def g1AuditStrictMass : Nat :=
  g1AuditProvenanceRows.foldl (fun acc r => acc + r.strictApprox) 0

/-- Total equation mass carried by the full provenance projection. -/
def g1AuditEquationMass : Nat :=
  g1AuditProvenanceRows.foldl (fun acc r => acc + r.equationsTotal) 0

/-- Compact summary string for worklog export hooks. -/
def g1AuditProvenanceSummary : String :=
  "G1 audit provenance ready: source cluster -> target module -> contract ID rows exported; " ++
  "Path-C audit subset nonempty."

end NavierStokes.MillenniumAudit.G1Provenance
