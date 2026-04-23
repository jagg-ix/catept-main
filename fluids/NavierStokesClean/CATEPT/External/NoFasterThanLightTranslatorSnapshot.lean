import NavierStokesClean.CATEPT.External.NoFasterThanLightInterface

/-!
# CATEPT External Snapshot: No-FTL Isabelle Translator (Strict)

Concrete snapshot for the strict no-FTL Isabelle translator artifact:

`verification_results/afp_isabelle/no_ftl_observers_gen_rel/isabelle_tensor_ir_ruled_strict.json`

This is an opt-in metadata bridge, not a truth authority replacement.
Lean theorems remain the only closure authority.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

/-- Snapshot metadata extracted from the strict no-FTL translator artifact. -/
structure NoFasterThanLightTranslatorSnapshot where
  artifactPath : String
  generatedAtUTC : String
  irId : String
  theoremCount : Nat
  autoCloseableCount : Nat
  needsHumanCount : Nat
  theoremErrorCount : Nat

/-- Frozen snapshot values from the strict no-FTL translator artifact. -/
def noFtlStrictSnapshot : NoFasterThanLightTranslatorSnapshot where
  artifactPath :=
    "verification_results/afp_isabelle/no_ftl_observers_gen_rel/isabelle_tensor_ir_ruled_strict.json"
  generatedAtUTC := "2026-04-06T01:37:15+00:00"
  irId := "tensor_ir_isabelle_No_FTL_observers_Gen_Rel_20260406"
  theoremCount := 246
  autoCloseableCount := 224
  needsHumanCount := 22
  theoremErrorCount := 246

/-- Sample theorem identifiers from the strict snapshot, useful for audit anchors. -/
def noFtlStrictSampleTheoremIds : List String :=
  [ "No_FTL_observers_Gen_Rel.Affine.lemTranslationPartIsUnique#1"
  , "No_FTL_observers_Gen_Rel.Affine.lemLinearPartIsUnique#1"
  , "No_FTL_observers_Gen_Rel.Affine.lemLinearImpliesAffine#1"
  , "No_FTL_observers_Gen_Rel.Affine.lemTranslationImpliesAffine#1"
  , "No_FTL_observers_Gen_Rel.Affine.lemAffineDiff#1"
  , "No_FTL_observers_Gen_Rel.Affine.lemAffineImpliesTotalFunction#1"
  ]

/-- Internal metadata consistency from `_meta`: `auto + needs_human = theorem_count`. -/
theorem noFtlStrictSnapshot_meta_counts_consistent :
    noFtlStrictSnapshot.autoCloseableCount + noFtlStrictSnapshot.needsHumanCount =
      noFtlStrictSnapshot.theoremCount := by
  decide

/-- Rule-engine strict run currently reports one theorem error per theorem surface entry. -/
theorem noFtlStrictSnapshot_rule_engine_full_retry_surface :
    noFtlStrictSnapshot.theoremErrorCount = noFtlStrictSnapshot.theoremCount := by
  decide

/-- Audit anchor: strict sample theorem id list is non-empty. -/
theorem noFtlStrictSnapshot_sample_ids_nonempty :
    noFtlStrictSampleTheoremIds ≠ [] := by
  decide

/-- External no-FTL certificate can be paired with the strict translator snapshot. -/
theorem NoFasterThanLightCertificate.compatible_with_noFtlStrictSnapshot
    (w : NoFasterThanLightCertificate) :
    noFtlStrictSnapshot.theoremCount = 246 ∧ w.signalSpeed ≤ w.lightSpeed := by
  exact ⟨rfl, w.no_superluminal⟩

end

end NavierStokesClean.CATEPT.External
