import NavierStokesClean.CATEPT.WeylYukawaContracts
import Mathlib.Data.List.Basic

/-
# NavierStokesClean.CATEPT.WeylYukawaContractsAudit

Audit layer for `NavierStokesClean.CATEPT.WeylYukawaContracts` with NS-style status labels:
- `verified`
- `partiallyVerified`
- `openBridge`

This file is intentionally lightweight and machine-checkable, so helpers can
query closure status without re-reading the full contract source.
-/

namespace NavierStokesClean.CATEPT
namespace WeylYukawaAudit

open NavierStokesClean.CATEPT.WeylYukawa

inductive ClaimStatus where
  | verified
  | partiallyVerified
  | openBridge
  deriving DecidableEq, Repr

inductive ClaimId where
  | si_from_phase_nonneg
  | adapter_to_foundations_complex_action
  | weyl_equation_trefoil_def
  | dsf_phantom_information_preservation_def
  | dsf_dimensional_entropy_flow_def
  | yukawa_dirac_mass_matrix_def
  | yukawa_backreaction_y_eff_def
  | massless_kl_weyl_correspondence
  | weyl_chiral_information_flow
  | ew_sW2_plus_cW2_contract
  | ew_rho_tree_eq_one_contract
  | exists_biunitary_diag_contract
  deriving DecidableEq, Repr

structure LabeledClaim where
  id : ClaimId
  status : ClaimStatus
  theoremRef : String
  note : String
  deriving DecidableEq, Repr

def statusOf : ClaimId → ClaimStatus
  | .si_from_phase_nonneg => .verified
  | .adapter_to_foundations_complex_action => .verified
  | .weyl_equation_trefoil_def => .verified
  | .dsf_phantom_information_preservation_def => .verified
  | .dsf_dimensional_entropy_flow_def => .verified
  | .yukawa_dirac_mass_matrix_def => .verified
  | .yukawa_backreaction_y_eff_def => .verified
  | .massless_kl_weyl_correspondence => .openBridge
  | .weyl_chiral_information_flow => .openBridge
  | .ew_sW2_plus_cW2_contract => .verified
  | .ew_rho_tree_eq_one_contract => .verified
  | .exists_biunitary_diag_contract => .partiallyVerified

def theoremRefOf : ClaimId → String
  | .si_from_phase_nonneg => "NavierStokesClean.CATEPT.WeylYukawa.SI_from_phase_nonneg"
  | .adapter_to_foundations_complex_action =>
      "NavierStokesClean.CATEPT.WeylYukawa.toFoundationsComplexAction"
  | .weyl_equation_trefoil_def => "NavierStokesClean.CATEPT.WeylYukawa.weyl_equation_trefoil"
  | .dsf_phantom_information_preservation_def =>
      "NavierStokesClean.CATEPT.WeylYukawa.phantomInformationPreservation"
  | .dsf_dimensional_entropy_flow_def =>
      "NavierStokesClean.CATEPT.WeylYukawa.dimensionalEntropyFlow"
  | .yukawa_dirac_mass_matrix_def => "NavierStokesClean.CATEPT.WeylYukawa.DiracMassMatrix"
  | .yukawa_backreaction_y_eff_def => "NavierStokesClean.CATEPT.WeylYukawa.y_eff"
  | .massless_kl_weyl_correspondence =>
      "NavierStokesClean.CATEPT.WeylYukawa.massless_KL_weyl_correspondence"
  | .weyl_chiral_information_flow =>
      "NavierStokesClean.CATEPT.WeylYukawa.weyl_chiral_information_flow"
  | .ew_sW2_plus_cW2_contract => "NavierStokesClean.CATEPT.WeylYukawa.sW2_plus_cW2_holds"
  | .ew_rho_tree_eq_one_contract => "NavierStokesClean.CATEPT.WeylYukawa.rho_tree_eq_one_holds"
  | .exists_biunitary_diag_contract => "NavierStokesClean.CATEPT.WeylYukawa.exists_biunitary_diag"

def noteOf : ClaimId → String
  | .si_from_phase_nonneg =>
      "Kernel theorem: SI_from_phase >= 0."
  | .adapter_to_foundations_complex_action =>
      "Executable adapter into NavierStokesClean.CATEPT.ComplexAction."
  | .weyl_equation_trefoil_def =>
      "Compile-safe definitional Weyl equation contract."
  | .dsf_phantom_information_preservation_def =>
      "Compile-safe DSF preservation formula."
  | .dsf_dimensional_entropy_flow_def =>
      "Compile-safe DSF dimensional-flow formula."
  | .yukawa_dirac_mass_matrix_def =>
      "Executable Yukawa->Dirac mass matrix definition."
  | .yukawa_backreaction_y_eff_def =>
      "Executable SI/trefoil backreaction definition."
  | .massless_kl_weyl_correspondence =>
      "Open Weyl/KL bridge from extracted 0065 theorem intent."
  | .weyl_chiral_information_flow =>
      "Open chiral-information bridge from extracted 0072 theorem intent."
  | .ew_sW2_plus_cW2_contract =>
      "Textbook EW identity proved from local EW parameter definitions."
  | .ew_rho_tree_eq_one_contract =>
      "Custodial rho=1 tree relation proved from local EW mass definitions."
  | .exists_biunitary_diag_contract =>
      "General SVD/biunitary existence remains axiom; diagonal case proved constructively."

def allClaimIds : List ClaimId :=
  [ .si_from_phase_nonneg
  , .adapter_to_foundations_complex_action
  , .weyl_equation_trefoil_def
  , .dsf_phantom_information_preservation_def
  , .dsf_dimensional_entropy_flow_def
  , .yukawa_dirac_mass_matrix_def
  , .yukawa_backreaction_y_eff_def
  , .massless_kl_weyl_correspondence
  , .weyl_chiral_information_flow
  , .ew_sW2_plus_cW2_contract
  , .ew_rho_tree_eq_one_contract
  , .exists_biunitary_diag_contract
  ]

def claims : List LabeledClaim :=
  allClaimIds.map fun id =>
    { id := id
      status := statusOf id
      theoremRef := theoremRefOf id
      note := noteOf id }

def claimProp : ClaimId → Prop
  | .si_from_phase_nonneg =>
      ∀ δ : ℝ, 0 ≤ SI_from_phase δ
  | .adapter_to_foundations_complex_action =>
      ∀ (S : ScalarComplexAction) (hSI : 0 ≤ S.SI),
        (toFoundationsComplexAction S hSI).S_I () = S.SI
  | .weyl_equation_trefoil_def =>
      ∀ (op : WeylOperatorContext) (ψ : TrefoilStructure),
        weyl_equation_trefoil op ψ ↔
          op.weylOperator ψ * op.momentumOperator ψ * ψ.wavefunction = 0
  | .dsf_phantom_information_preservation_def =>
      ∀ (pc : PhantomCondition) (qNorm Δ a : ℝ),
        phantomInformationPreservation pc qNorm Δ a =
          let deviation := abs (Δ - pc qNorm a)
          (1 - deviation) * (1 / (1 + deviation))
  | .dsf_dimensional_entropy_flow_def =>
      ∀ (pc : PhantomCondition) (initialDim finalDim : Nat) (Q Δ : ℝ),
        dimensionalEntropyFlow pc initialDim finalDim Q Δ =
          let scalingFactor := Real.sqrt ((finalDim : ℝ) / (initialDim : ℝ))
          let effectiveQ := Q * scalingFactor
          abs (pc effectiveQ 1 - Δ) * ((finalDim : ℝ) - (initialDim : ℝ))
  | .yukawa_dirac_mass_matrix_def =>
      ∀ (v : ℝ) (Y : MatC),
        DiracMassMatrix v Y = ((v / sqrt2R : ℝ) : ℂ) • Y
  | .yukawa_backreaction_y_eff_def =>
      ∀ (κ : ℝ) (tag : TrefoilTag) (S : ScalarComplexAction) (y : ℝ),
        y_eff κ tag S y = y * (1 + κ * S.SI * (tag.writhe : ℝ))
  | .massless_kl_weyl_correspondence =>
      ∀ ctx : WeylContractContext,
        massless_KL_weyl_correspondence_contract ctx
  | .weyl_chiral_information_flow =>
      ∀ ctx : WeylContractContext,
        weyl_chiral_information_flow_contract ctx
  | .ew_sW2_plus_cW2_contract =>
      ∀ p : EWSMParams, sW2_plus_cW2_contract p
  | .ew_rho_tree_eq_one_contract =>
      ∀ p : EWSMParams, rho_tree_eq_one_contract p
  | .exists_biunitary_diag_contract =>
      ∀ M : MatC, ∃ d : DiagonalizationData, biunitaryDiagonalizationContract M d

theorem claimProp_available : ∀ id : ClaimId, claimProp id := by
  intro id
  cases id with
  | si_from_phase_nonneg =>
      intro δ
      exact SI_from_phase_nonneg δ
  | adapter_to_foundations_complex_action =>
      intro S hSI
      rfl
  | weyl_equation_trefoil_def =>
      intro op ψ
      rfl
  | dsf_phantom_information_preservation_def =>
      intro pc qNorm Δ a
      rfl
  | dsf_dimensional_entropy_flow_def =>
      intro pc initialDim finalDim Q Δ
      rfl
  | yukawa_dirac_mass_matrix_def =>
      intro v Y
      rfl
  | yukawa_backreaction_y_eff_def =>
      intro κ tag S y
      rfl
  | massless_kl_weyl_correspondence =>
      intro ctx
      exact massless_KL_weyl_correspondence ctx
  | weyl_chiral_information_flow =>
      intro ctx
      exact weyl_chiral_information_flow ctx
  | ew_sW2_plus_cW2_contract =>
      intro p
      exact sW2_plus_cW2_holds p
  | ew_rho_tree_eq_one_contract =>
      intro p
      exact rho_tree_eq_one_holds p
  | exists_biunitary_diag_contract =>
      intro M
      exact exists_biunitary_diag M

def claimsByStatus (st : ClaimStatus) : List LabeledClaim :=
  claims.filter (fun c => decide (c.status = st))

def openBridgeClaims : List LabeledClaim := claimsByStatus .openBridge
def partiallyVerifiedClaims : List LabeledClaim := claimsByStatus .partiallyVerified
def verifiedClaims : List LabeledClaim := claimsByStatus .verified

def openBridgeClaimIds : List ClaimId :=
  [ .massless_kl_weyl_correspondence, .weyl_chiral_information_flow ]

theorem openBridgeClaimIds_sound :
    ∀ id ∈ openBridgeClaimIds, statusOf id = .openBridge := by
  intro id hid
  simp [openBridgeClaimIds] at hid
  rcases hid with h | h
  · simpa [h, statusOf]
  · simpa [h, statusOf]

end WeylYukawaAudit
end NavierStokesClean.CATEPT
