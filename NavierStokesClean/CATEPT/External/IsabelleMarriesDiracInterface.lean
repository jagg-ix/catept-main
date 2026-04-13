import NavierStokesClean.CATEPT.WeylComplexDiracCompatibility

/-!
# CATEPT External Interface: Isabelle_Marries_Dirac

Opt-in bridge contracts for integrating AFP Isabelle_Marries_Dirac results with
existing Weyl/Dirac CAT/EPT compatibility modules.
-/

set_option autoImplicit false

namespace NavierStokesClean.CATEPT.External

noncomputable section

open NavierStokesClean.CATEPT

/-- External certificate shell for Isabelle_Marries_Dirac theorem bundles. -/
structure IsabelleMarriesDiracCertificate where
  importedTheoremCount : Nat
  hasTeleportationProtocol : Prop
  hasTeleportationProtocol_holds : hasTeleportationProtocol
  hasEntanglementProtocol : Prop
  hasEntanglementProtocol_holds : hasEntanglementProtocol
  hasGateModelClosure : Prop
  hasGateModelClosure_holds : hasGateModelClosure

/-- Compatibility anchor: current Weyl/Dirac core equation set is present. -/
theorem isabelle_dirac_core_equation_anchor :
    WeylComplexDiracCoreEquations.coreEquationCount = 15 :=
  weyl_core_equation_count_is_15

/-- Compatibility anchor: extracted A1..A7 mapping table remains available. -/
theorem isabelle_dirac_target_table_anchor :
    weyl_a1_a7_targets.length = 7 := by
  decide

/-- Expose imported protocol flags as explicit theorem-level contracts. -/
theorem IsabelleMarriesDiracCertificate.protocol_stack
    (w : IsabelleMarriesDiracCertificate) :
    w.hasTeleportationProtocol ∧ w.hasEntanglementProtocol ∧ w.hasGateModelClosure :=
  ⟨w.hasTeleportationProtocol_holds, w.hasEntanglementProtocol_holds, w.hasGateModelClosure_holds⟩

end

end NavierStokesClean.CATEPT.External
