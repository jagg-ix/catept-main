import NavierStokes.MillenniumAuditCertificate
import NavierStokes.NSQEImportG1AuditProvenance

/-!
# NSQEImportG1AuditIntegration

Integrates the QE-derived G1 provenance rows into the Millennium audit surface.

This module is intentionally lightweight: it does not alter certificate semantics,
but it exposes deterministic, machine-checkable projections that tooling can read
alongside `MillenniumAuditCertificate`.
-/

namespace NavierStokes.MillenniumAudit

set_option autoImplicit false

open NavierStokes.Millennium
open NavierStokes.MillenniumAudit.G1Provenance

/-- Contract IDs covered by the current Path-C-focused G1 provenance rows. -/
def pathCG1ContractIds : List String :=
  g1PathCAuditRows.map (fun r => r.contractId)

/-- Deterministic expected Path-C contract IDs from the seeded G1 catalog. -/
def pathCG1ContractIdsExpected : List String :=
  [ "g1.t3.lattice.shell_partition"
  , "g1.t3.brillouin.mode_cover"
  , "g1.linear_algebra.finite_projection"
  , "g1.provenance.parallel_partition" ]

theorem pathCG1RowCount : g1PathCAuditRows.length = 4 := by
  decide

theorem pathCG1ContractIds_expected :
    pathCG1ContractIds = pathCG1ContractIdsExpected := by
  decide

/-- Strict-approx mass across the Path-C subset. -/
def pathCG1StrictMass : Nat :=
  g1PathCAuditRows.foldl (fun acc r => acc + r.strictApprox) 0

theorem pathCG1StrictMass_positive : 0 < pathCG1StrictMass := by
  decide

/-- One-line summary for worklog and exporter hooks. -/
def pathCG1AuditSummary : String :=
  "G1 Path-C provenance integrated: 4 contract IDs mapped; strict mass is positive."

/-- Claim registry entries for the G1↔audit integration surface. -/
def millenniumAuditG1Claims : List LabeledClaim :=
  [ ⟨"g1_pathC_provenance_rows_nonempty", .verified,
      "THEOREM: G1 Path-C provenance rows are nonempty (machine-readable mapping present)"⟩
  , ⟨"g1_pathC_contract_ids_expected", .verified,
      "THEOREM: Path-C G1 contract IDs match deterministic expected set"⟩
  , ⟨"g1_pathC_strict_mass_positive", .verified,
      "THEOREM: Path-C G1 provenance strict mass is positive"⟩
  ]

theorem millenniumAuditG1Claims_count : millenniumAuditG1Claims.length = 3 := by
  decide

end NavierStokes.MillenniumAudit

