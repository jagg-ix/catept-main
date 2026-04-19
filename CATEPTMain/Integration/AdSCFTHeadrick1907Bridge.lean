import CATEPTMain.Integration.AdSCFTBridge
import Mathlib
/-!
# AdS/CFT Entanglement Bridge (Headrick lectures, arXiv:1907.08126v1)

This module maps core equation-level content from:

  Matthew Headrick, *Lectures on entanglement entropy in field theory and holography*
  arXiv:1907.08126v1 (2019).

to Lean4 definitions and algebraic theorems that plug into the existing
`AdSCFTBridge` / `AdSCFTExtended` integration layer.

## Scope (phase-1)

We formalize the equation skeleton and prove the purely algebraic implications:

- Eq. (2.12): conditional entropy `H(A|B) = S(AB) - S(B)`
- Eq. (2.31): mutual information `I(A:B) = S(A) + S(B) - S(AB)`
- Eq. (2.34) ↔ Eq. (2.33): strong subadditivity and MI monotonicity
- Eq. (2.35): Araki-Lieb (as a predicate) and pure-state consequence `S(A)=S(B)`
- Eq. (5.6), (5.8): RT entropy and min-surface form (two-candidate version)
- Eq. (5.57): monogamy of mutual information encoded as a bridge obligation

Heavy geometric/QFT steps (replica trick, extremal-surface existence, CFT
partition-function derivations) are kept as explicit phase-2 obligations in the
worklog companion file.
-/

set_option autoImplicit false

namespace CATEPTMain.Integration.AdSCFT.Headrick1907

open CATEPTMain.Integration.AdSCFT

-- ── §2  Entropy identities (equation map) ────────────────────────────────────

/-- Eq. (2.12): conditional entropy. -/
noncomputable def conditionalEntropy (SAB SB : ℝ) : ℝ := SAB - SB

/-- Eq. (2.31): mutual information. -/
noncomputable def mutualInformation (SA SB SAB : ℝ) : ℝ := SA + SB - SAB

theorem mutualInformation_eq_entropy_gap (SA SB SAB : ℝ) :
    mutualInformation SA SB SAB = SA - conditionalEntropy SAB SB := by
  unfold mutualInformation conditionalEntropy
  ring

/-- Eq. (2.18): subadditivity as a proposition. -/
def subadditivity (SA SB SAB : ℝ) : Prop := SAB ≤ SA + SB

theorem subadditivity_iff_mutualInformation_nonneg (SA SB SAB : ℝ) :
    subadditivity SA SB SAB ↔ 0 ≤ mutualInformation SA SB SAB := by
  unfold subadditivity mutualInformation
  constructor <;> intro h <;> linarith

/-- Eq. (2.34): strong subadditivity as a proposition. -/
def strongSubadditivity (SAB SBC SB SABC : ℝ) : Prop := SAB + SBC ≥ SB + SABC

/-- Eq. (2.33): mutual-information monotonicity under adjoining `C`. -/
def mutualInfoMonotoneUnderAdjoin
    (SA SB SAB SBC SABC : ℝ) : Prop :=
  mutualInformation SA SBC SABC ≥ mutualInformation SA SB SAB

theorem strongSubadditivity_iff_mutualInfoMonotone
    (SA SB SAB SBC SABC : ℝ) :
    strongSubadditivity SAB SBC SB SABC ↔
      mutualInfoMonotoneUnderAdjoin SA SB SAB SBC SABC := by
  unfold strongSubadditivity mutualInfoMonotoneUnderAdjoin mutualInformation
  constructor <;> intro h <;> linarith

/-- Eq. (2.35): Araki-Lieb as a proposition. -/
def arakiLieb (SA SB SAB : ℝ) : Prop := SAB ≥ |SA - SB|

/-- Eq. (2.37): pure bipartite state consequence of Araki-Lieb. -/
theorem pureEntropyBalance_of_arakiLieb
    (SA SB : ℝ) (hAL : arakiLieb SA SB 0) : SA = SB := by
  unfold arakiLieb at hAL
  have hle0 : |SA - SB| ≤ 0 := by linarith
  have habs : |SA - SB| = 0 := le_antisymm hle0 (abs_nonneg _)
  have hsub : SA - SB = 0 := abs_eq_zero.mp habs
  linarith

/-- Reusable entropy-contract record for phase-2 modules. -/
structure EntropyAxioms where
  subadditivity_nonneg_mi :
    ∀ SA SB SAB : ℝ, subadditivity SA SB SAB ↔ 0 ≤ mutualInformation SA SB SAB
  ssa_mono_mi :
    ∀ SA SB SAB SBC SABC : ℝ,
      strongSubadditivity SAB SBC SB SABC ↔
        mutualInfoMonotoneUnderAdjoin SA SB SAB SBC SABC
  pure_balance_from_araki :
    ∀ SA SB : ℝ, arakiLieb SA SB 0 → SA = SB

/-- Phase-1 entropy contract extracted from Headrick's equation skeleton. -/
def phase1EntropyAxioms : EntropyAxioms :=
  { subadditivity_nonneg_mi := subadditivity_iff_mutualInformation_nonneg
    ssa_mono_mi := strongSubadditivity_iff_mutualInfoMonotone
    pure_balance_from_araki := pureEntropyBalance_of_arakiLieb }

-- ── §2.4  Rényi encoding (equation map only) ─────────────────────────────────

/-- Eq. (2.40): Rényi entropy formula in scalar form,
    expecting `trRhoPow = Tr(ρ^α) > 0`, `α ≠ 1`. -/
noncomputable def renyiEntropyFormula (α trRhoPow : ℝ) : ℝ :=
  Real.log trRhoPow / (1 - α)

/-- Eq. (2.44): Rényi mutual information formula. -/
noncomputable def renyiMutualInformation (SA SB SAB : ℝ) : ℝ := SA + SB - SAB

-- ── §5  RT equation map ───────────────────────────────────────────────────────

/-- Eq. (5.6): RT entropy alias to the existing AdS/CFT bridge definition. -/
noncomputable abbrev rtEntropy := ryu_takayanagi_entropy

/-- Eq. (5.8): two-candidate minimum-surface entropy proxy:
    `S(A) = min area(m) / (4 G_N)` for two candidate surfaces. -/
noncomputable def rtEntropyFromTwoCandidates (a₁ a₂ G_N : ℝ) : ℝ :=
  rtEntropy (min a₁ a₂) G_N

theorem rtEntropyFromTwoCandidates_le_left
    (a₁ a₂ G_N : ℝ) (hG : 0 < G_N) :
    rtEntropyFromTwoCandidates a₁ a₂ G_N ≤ rtEntropy a₁ G_N := by
  unfold rtEntropyFromTwoCandidates rtEntropy ryu_takayanagi_entropy
  exact div_le_div_of_nonneg_right (min_le_left _ _) (by linarith)

theorem rtEntropyFromTwoCandidates_le_right
    (a₁ a₂ G_N : ℝ) (hG : 0 < G_N) :
    rtEntropyFromTwoCandidates a₁ a₂ G_N ≤ rtEntropy a₂ G_N := by
  unfold rtEntropyFromTwoCandidates rtEntropy ryu_takayanagi_entropy
  exact div_le_div_of_nonneg_right (min_le_right _ _) (by linarith)

/-- Eq. (5.46)/(5.52): RT subadditivity/SSA transfer from existing bridge theorem. -/
theorem rtEntropy_subadditivity_phase1
    (G_N aAuB aAiB aA aB : ℝ) (hG : 0 < G_N)
    (hArea : aAuB + aAiB ≤ aA + aB) :
    rtEntropy aAuB G_N + rtEntropy aAiB G_N ≤
      rtEntropy aA G_N + rtEntropy aB G_N :=
  ryu_takayanagi_subadditivity G_N aAuB aAiB aA aB hG hArea

/-- Area-level SSA transfers to entropy-level SSA via positive RT scaling. -/
theorem rtEntropy_ssa_of_area_ssa
    (G_N aAB aBC aB aABC : ℝ) (hG : 0 < G_N)
    (hAreaSSA : aAB + aBC ≥ aB + aABC) :
    strongSubadditivity (rtEntropy aAB G_N) (rtEntropy aBC G_N)
      (rtEntropy aB G_N) (rtEntropy aABC G_N) := by
  unfold strongSubadditivity rtEntropy ryu_takayanagi_entropy
  have hAreaSSA' : aB + aABC ≤ aAB + aBC := by linarith [hAreaSSA]
  have hc : 0 ≤ (1 / (4 * G_N : ℝ)) := by positivity
  have hScaled :
      (aB + aABC) * (1 / (4 * G_N : ℝ)) ≤
      (aAB + aBC) * (1 / (4 * G_N : ℝ)) :=
    mul_le_mul_of_nonneg_right hAreaSSA' hc
  have hL :
      (aAB + aBC) * (1 / (4 * G_N : ℝ)) =
      aAB / (4 * G_N) + aBC / (4 * G_N) := by ring
  have hR :
      (aB + aABC) * (1 / (4 * G_N : ℝ)) =
      aB / (4 * G_N) + aABC / (4 * G_N) := by ring
  linarith [hScaled, hL, hR]

-- ── §5.4  MMI contract ───────────────────────────────────────────────────────

/-- Eq. (5.57): monogamy of mutual information (MMI) in entropy form. -/
def monogamyMutualInformation
    (SAB SBC SAC SA SB SC SABC : ℝ) : Prop :=
  SAB + SBC + SAC ≥ SA + SB + SC + SABC

/-- Area-level MMI transfers to entropy-level MMI via positive RT scaling. -/
theorem rtEntropy_mmi_of_area_mmi
    (G_N aAB aBC aAC aA aB aC aABC : ℝ) (hG : 0 < G_N)
    (hAreaMMI : aAB + aBC + aAC ≥ aA + aB + aC + aABC) :
    monogamyMutualInformation
      (rtEntropy aAB G_N) (rtEntropy aBC G_N) (rtEntropy aAC G_N)
      (rtEntropy aA G_N) (rtEntropy aB G_N) (rtEntropy aC G_N)
      (rtEntropy aABC G_N) := by
  unfold monogamyMutualInformation rtEntropy ryu_takayanagi_entropy
  have hAreaMMI' : aA + aB + aC + aABC ≤ aAB + aBC + aAC := by linarith [hAreaMMI]
  have hc : 0 ≤ (1 / (4 * G_N : ℝ)) := by positivity
  have hScaled :
      (aA + aB + aC + aABC) * (1 / (4 * G_N : ℝ)) ≤
      (aAB + aBC + aAC) * (1 / (4 * G_N : ℝ)) :=
    mul_le_mul_of_nonneg_right hAreaMMI' hc
  have hL :
      (aAB + aBC + aAC) * (1 / (4 * G_N : ℝ)) =
      aAB / (4 * G_N) + aBC / (4 * G_N) + aAC / (4 * G_N) := by ring
  have hR :
      (aA + aB + aC + aABC) * (1 / (4 * G_N : ℝ)) =
      aA / (4 * G_N) + aB / (4 * G_N) + aC / (4 * G_N) + aABC / (4 * G_N) := by ring
  linarith [hScaled, hL, hR]

/-- Integration witness for equation-level translation of arXiv:1907.08126v1. -/
structure Headrick1907Witness where
  eq2_18_subadditivity : Prop
  eq2_34_ssa : Prop
  eq2_35_arakiLieb : Prop
  eq5_6_rt : Prop
  eq5_8_rt_min_surface : Prop
  eq5_57_mmi : Prop

def Headrick1907IntegrationContract (w : Headrick1907Witness) : Prop :=
  w.eq2_18_subadditivity ∧
  w.eq2_34_ssa ∧
  w.eq2_35_arakiLieb ∧
  w.eq5_6_rt ∧
  w.eq5_8_rt_min_surface ∧
  w.eq5_57_mmi

/-- Phase-1 witness: algebraic core + RT bridge are wired; MMI is left as a
    theoremized RT-scaled transfer lane. -/
def phase1Headrick1907Witness : Headrick1907Witness :=
  { eq2_18_subadditivity :=
      ∀ SA SB SAB : ℝ, subadditivity SA SB SAB ↔ 0 ≤ mutualInformation SA SB SAB
    eq2_34_ssa :=
      ∀ SA SB SAB SBC SABC : ℝ,
        strongSubadditivity SAB SBC SB SABC ↔
          mutualInfoMonotoneUnderAdjoin SA SB SAB SBC SABC
    eq2_35_arakiLieb :=
      ∀ SA SB : ℝ, arakiLieb SA SB 0 → SA = SB
    eq5_6_rt :=
      ∀ area G_N : ℝ, 0 < area → 0 < G_N → 0 < rtEntropy area G_N
    eq5_8_rt_min_surface :=
      ∀ a₁ a₂ G_N : ℝ, 0 < G_N →
        rtEntropyFromTwoCandidates a₁ a₂ G_N ≤ rtEntropy a₁ G_N ∧
        rtEntropyFromTwoCandidates a₁ a₂ G_N ≤ rtEntropy a₂ G_N
    eq5_57_mmi :=
      ∀ G_N aAB aBC aAC aA aB aC aABC : ℝ, 0 < G_N →
        monogamyMutualInformation aAB aBC aAC aA aB aC aABC →
          monogamyMutualInformation
            (rtEntropy aAB G_N) (rtEntropy aBC G_N) (rtEntropy aAC G_N)
            (rtEntropy aA G_N) (rtEntropy aB G_N) (rtEntropy aC G_N)
            (rtEntropy aABC G_N) }

theorem phase1Headrick1907Witness_valid :
    Headrick1907IntegrationContract phase1Headrick1907Witness := by
  refine ⟨?h1, ?h2, ?h3, ?h4, ?h5, ?h6⟩
  · intro SA SB SAB
    exact subadditivity_iff_mutualInformation_nonneg SA SB SAB
  · intro SA SB SAB SBC SABC
    exact strongSubadditivity_iff_mutualInfoMonotone SA SB SAB SBC SABC
  · intro SA SB hAL
    exact pureEntropyBalance_of_arakiLieb SA SB hAL
  · intro area G_N hA hG
    exact ryu_takayanagi_entropy_pos area G_N hA hG
  · intro a₁ a₂ G_N hG
    exact ⟨rtEntropyFromTwoCandidates_le_left a₁ a₂ G_N hG,
           rtEntropyFromTwoCandidates_le_right a₁ a₂ G_N hG⟩
  · intro G_N aAB aBC aAC aA aB aC aABC hG hMMI
    exact rtEntropy_mmi_of_area_mmi G_N aAB aBC aAC aA aB aC aABC hG hMMI

end CATEPTMain.Integration.AdSCFT.Headrick1907
